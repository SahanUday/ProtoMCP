"""useAgentLoop – thin frontend driver for the byllm-powered backend agent.

Replaces the old per-turn frontend ReAct loop with a simple fire-and-poll
pattern:

  1. runAgentLoop  → POST /walker/agent_run   (returns immediately)
  2. poll()        → POST /function/get_agent_events  (every 500 ms)
  3. approveToolCall / denyToolCall → POST /function/confirm_tool_call

Every event the backend emits is forwarded directly to addAgentTraceEvent,
so the existing AgentTracePanel renders without any changes to its event
format.  The 'final_response' event drives addChatMessage for chat history.

Special event types added by byllm (new in the trace view):
  thought        – LLM reasoning text emitted before a tool call
  steps_done     – ReAct loop finished, streamed final answer follows
  response_chunk – one streamed token of the final answer
  usage          – aggregated + per-call token counts
"""

cl import from "react" { useRef }
cl import from ..store.mcp_store { useMcpStore }
cl import from ..store.llm_store { useLlmStore }


# ── Auth header builder (mirrors useMcpClient) ────────────────────────────────
def _buildAuthHeaders(auth: Any) -> Any {
    h = {};
    if not auth {
        return h;
    }
    if auth.type == "bearer" and auth.value {
        h.Authorization = "Bearer " + auth.value;
    } elif auth.type == "apikey" and auth.value {
        key_name = auth.headerName or "X-API-Key";
        h[key_name] = auth.value;
    } elif auth.type == "basic" and auth.value {
        h.Authorization = "Basic " + auth.value;
    }
    return h;
}

# ── Session history helpers (module-level so Any params work correctly) ────────

# Build a history entry dict from raw session data.
def _buildHistoryEntry(
    cid: str, title: str, msgs: Any, trace: Any, tokenUsage: Any
) -> dict {
    return {
        "id": cid,
        "title": title,
        "createdAt": Date.now(),
        "messages": msgs,
        "trace": trace,
        "tokenUsage": tokenUsage
    };
}

# Prepend a new entry to history, deduplicate by id, keep max 5.
def _prependHistory(hist: list, newEntry: Any, cid: str) -> Any {
    return hist.filter(lambda (s: str) -> bool { return s.id != cid; }).concat(
        [newEntry]
    ).slice(
        0, 5
    );
}

# Remove one session from the history list by id.
def _removeFromHistory(hist: list, cid: str) -> Any {
    return hist.filter(lambda (s: str) -> bool { return s.id != cid; });
}


# ── Hook ──────────────────────────────────────────────────────────────────────
def:pub useAgentLoop -> Any {
    mcpStore = useMcpStore();
    llmStore = useLlmStore();

    # useRef gives stable objects that persist across re-renders.
    # All closures reference the same ref objects regardless of when they were created.
    sessionIdRef = useRef(None);  # backend run ID (new UUID per runAgentLoop call)
    conversationIdRef = useRef(
        ""
    );  # conversation ID (stable across turns, used for history)
    eventIndexRef = useRef(0);
    pollIntervalRef = useRef(None);
    abortRef = useRef(False);
    pollActiveRef = useRef(False);  # guard: only one _poll runs at a time
    # Title of the current conversation = first user message sent.
    # Set once when conversationIdRef is assigned; cleared on newSession/delete/load.
    firstMsgRef = useRef("");

    # ── Tool aggregation ──────────────────────────────────────────────────────
    def _buildServerConnections() -> Any {
        enabledTools = llmStore.llmConfig.enabledTools;
        return mcpStore.connections.filter(
            lambda (c: Any) -> Any { return c.status == "connected"; }
        ).map(
            lambda (c: Any) -> Any { tools = (c.capabilities?.tools or []).filter(
                lambda (t: Any) -> Any { return not enabledTools
                or enabledTools.includes(t.name); }
            );authHeaders = _buildAuthHeaders(c.auth);if c.sessionId {
                authHeaders["mcp-session-id"] = c.sessionId;
            }return {
                "id": c.id,
                "name": c.name,
                "url": c.url,
                "transport": c.transport or "streamable-http",
                "tools": tools,
                "headers": authHeaders
            }; }
        );
    }

    # ── Polling ───────────────────────────────────────────────────────────────
    async def _poll() -> None {
        # Guard: skip if a poll is already in flight. setInterval fires every
        # 500 ms regardless of whether the previous async callback finished,
        # so without this guard overlapping polls can call clearInterval on
        # the *next* interval (created by approveToolCall) and kill polling.
        if pollActiveRef.current or abortRef.current {
            return;
        }
        pollActiveRef.current = True;

        try {
            resp = await fetch(
                "/function/get_agent_events",
                {
                    "method": "POST",
                    "headers": {"Content-Type": "application/json"},
                    "body": JSON.stringify(
                        {
                            "session_id": sessionIdRef.current,
                            "since_index": eventIndexRef.current
                        }
                    )
                }
            );
            envelope = await resp.json();
            data = (envelope.data or {}).result or {};

            for event in (data.events or []) {
                eventIndexRef.current = eventIndexRef.current + 1;

                if event.type == "usage" {
                    llmStore.addTokenUsage((event.data or {}).usage or {});
                } elif event.type == "final_response" {
                    llmStore.addChatMessage(
                        {
                            "role": "assistant",
                            "content": (event.data or {}).content or ""
                        }
                    );
                } elif event.type == "error" {
                    llmStore.addChatMessage(
                        {
                            "role": "system",
                            "content": (event.data or {}).error or "An error occurred",
                            "errorKind": (event.data or {}).errorKind
                        }
                    );
                }

                llmStore.addAgentTraceEvent(event);
            }

            if data.pending_confirmation {
                clearInterval(pollIntervalRef.current);
                pollActiveRef.current = False;
                llmStore.setPendingConfirmation(data.pending_confirmation);
                return;
            }

            if not data.running {
                clearInterval(pollIntervalRef.current);
                pollActiveRef.current = False;
                llmStore.setAgentRunning(False);
                return;
            }
        } except Exception as e {
            clearInterval(pollIntervalRef.current);
            pollActiveRef.current = False;
            llmStore.setAgentRunning(False);
            return;
        }

        pollActiveRef.current = False;
    }

    # ── Public API ────────────────────────────────────────────────────────────
    async def runAgentLoop(connection: Any, userMessage: str) -> None {
        # Start a fresh conversation if none is active.
        # conversationIdRef is stable across turns; sessionIdRef is a new backend run each time.
        if not conversationIdRef.current {
            conversationIdRef.current = crypto.randomUUID();
            firstMsgRef.current = userMessage;
            llmStore.setAgentSessionId(conversationIdRef.current);
        }

        abortRef.current = False;
        llmStore.setAgentRunning(True);
        llmStore.clearAgentTrace();

        sessionIdRef.current = crypto.randomUUID();
        eventIndexRef.current = 0;

        userMsg = {"role": "user", "content": userMessage};
        llmStore.addChatMessage(userMsg);
        llmStore.addAgentTraceEvent(
            {
                "type": "user_message",
                "timestamp": Date.now(),
                "data": {"content": userMessage}
            }
        );

        await fetch(
            "/walker/agent_run",
            {
                "method": "POST",
                "headers": {"Content-Type": "application/json"},
                "body": JSON.stringify(
                    {
                        "session_id": sessionIdRef.current,
                        "llm_config": llmStore.llmConfig,
                        "message": userMessage,
                        "chat_history": llmStore.chatMessages,
                        "server_connections": _buildServerConnections()
                    }
                )
            }
        );

        pollIntervalRef.current = setInterval(_poll, 500);
    }

    # Save current conversation to history then start a blank one.
    def newSession() -> None {
        cid = conversationIdRef.current;
        if cid and firstMsgRef.current {
            newEntry = _buildHistoryEntry(
                cid,
                firstMsgRef.current,
                llmStore.chatMessages,
                llmStore.agentTrace,
                llmStore.totalTokenUsage
            );
            llmStore.setSessionHistory(
                _prependHistory(llmStore.sessionHistory, newEntry, cid)
            );
        }
        firstMsgRef.current = "";
        conversationIdRef.current = "";
        sessionIdRef.current = None;
        eventIndexRef.current = 0;
        llmStore.clearChat();
        llmStore.setAgentSessionId("");
    }

    # Delete active backend session + clear UI (no history save).
    async def deleteCurrentSession() -> None {
        sid = sessionIdRef.current;
        if sid {
            await fetch(
                "/function/delete_session",
                {
                    "method": "POST",
                    "headers": {"Content-Type": "application/json"},
                    "body": JSON.stringify({"session_id": sid})
                }
            );
        }
        firstMsgRef.current = "";
        conversationIdRef.current = "";
        sessionIdRef.current = None;
        eventIndexRef.current = 0;
        llmStore.clearChat();
        llmStore.setAgentSessionId("");
    }

    # Remove a history entry from the list (backend sessions auto-evict).
    async def deleteHistorySession(sessionId: str) -> None {
        llmStore.setSessionHistory(
            _removeFromHistory(llmStore.sessionHistory, sessionId)
        );
    }

    # Auto-save current conversation to history, then restore the chosen one.
    def loadSession(
        msgs: Any, trace: Any, tokenUsage: Any, sid: str, title: str
    ) -> None {
        # Save current conversation before switching (only if there's content).
        cid = conversationIdRef.current;
        if cid and firstMsgRef.current {
            newEntry = _buildHistoryEntry(
                cid,
                firstMsgRef.current,
                llmStore.chatMessages,
                llmStore.agentTrace,
                llmStore.totalTokenUsage
            );
            llmStore.setSessionHistory(
                _prependHistory(llmStore.sessionHistory, newEntry, cid)
            );
        }

        # Restore the chosen session.
        llmStore.loadSession(msgs, trace, tokenUsage, sid);
        conversationIdRef.current = sid;
        firstMsgRef.current = title;
        sessionIdRef.current = None;
        eventIndexRef.current = 0;
    }

    async def approveToolCall() -> None {
        llmStore.setPendingConfirmation(None);
        await fetch(
            "/function/confirm_tool_call",
            {
                "method": "POST",
                "headers": {"Content-Type": "application/json"},
                "body": JSON.stringify(
                    {"session_id": sessionIdRef.current, "approved": "True"}
                )
            }
        );
        pollIntervalRef.current = setInterval(_poll, 500);
    }

    async def denyToolCall() -> None {
        llmStore.setPendingConfirmation(None);
        await fetch(
            "/function/confirm_tool_call",
            {
                "method": "POST",
                "headers": {"Content-Type": "application/json"},
                "body": JSON.stringify(
                    {"session_id": sessionIdRef.current, "approved": "False"}
                )
            }
        );
        pollIntervalRef.current = setInterval(_poll, 500);
    }

    def abortAgent() -> None {
        abortRef.current = True;
        clearInterval(pollIntervalRef.current);
        llmStore.setAgentRunning(False);
    }

    return {
        "runAgentLoop": runAgentLoop,
        "newSession": newSession,
        "deleteCurrentSession": deleteCurrentSession,
        "deleteHistorySession": deleteHistorySession,
        "loadSession": loadSession,
        "abortAgent": abortAgent,
        "approveToolCall": approveToolCall,
        "denyToolCall": denyToolCall
    };
}
