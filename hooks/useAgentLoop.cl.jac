"""useAgentLoop – thin frontend driver for the byllm-powered backend agent.

Fire-and-stream pattern:

  1. runAgentLoop  → POST /walker/agent_run
                     response is text/event-stream — each line is a JSON event
  2. stream reader  drains the response body in real-time (no polling)
  3. approveToolCall / denyToolCall → POST /function/confirm_tool_call

Every event the backend emits is forwarded directly to addAgentTraceEvent,
so the existing AgentTracePanel renders without any changes to its event
format.  The 'final_response' event drives addChatMessage for chat history.

Special event types added by byllm (visible in the trace view):
  thought        – LLM reasoning text emitted before a tool call
  steps_done     – ReAct loop finished, streamed final answer follows
  response_chunk – one streamed token of the final answer
  usage          – aggregated + per-call token counts
  pending_confirmation – agent waiting for user approval (confirm_mode only)
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

# ── Session history helpers ───────────────────────────────────────────────────
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

def _prependHistory(hist: list, newEntry: dict, cid: str) -> Any {
    return hist.filter(lambda (s: dict) -> bool { return s.id != cid; }).concat(
        [newEntry]
    ).slice(
        0, 5
    );
}

def _removeFromHistory(hist: list, cid: str) -> Any {
    return hist.filter(lambda (s: dict) -> bool { return s.id != cid; });
}


# ── Hook ──────────────────────────────────────────────────────────────────────
def:pub useAgentLoop -> Any {
    mcpStore = useMcpStore();
    llmStore = useLlmStore();

    sessionIdRef = useRef(None);
    conversationIdRef = useRef("");
    readerRef = useRef(None);
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

    # ── SSE stream reader ─────────────────────────────────────────────────────
    def _dispatchEvent(event: Any) -> None {
        if event.type == "usage" {
            llmStore.addTokenUsage((event.data or {}).usage or {});
        } elif event.type == "final_response" {
            # Clear streaming state then commit the final message.
            llmStore.setAgentStatus("");
            llmStore.clearStreamingContent();
            llmStore.addChatMessage(
                {"role": "assistant", "content": (event.data or {}).content or ""}
            );
        } elif event.type == "error" {
            llmStore.setAgentStatus("");
            llmStore.clearStreamingContent();
            llmStore.addChatMessage(
                {
                    "role": "system",
                    "content": (event.data or {}).error or "An error occurred",
                    "errorKind": (event.data or {}).errorKind
                }
            );
        } elif event.type == "pending_confirmation" {
            data = event.data or {};
            llmStore.setPendingConfirmation(
                {
                    "toolName": data.tool_name,
                    "toolArgs": data.arguments,
                    "serverName": data.server_name
                }
            );
        } elif event.type == "confirmation_resolved" {
            llmStore.setPendingConfirmation(None);
        } elif event.type == "thought" {
            llmStore.setAgentStatus("Thinking...");
        } elif event.type == "tool_call" {
            toolName = ((event.data or {}).name or "tool");
            llmStore.setAgentStatus(f"Using tool: {toolName}");
        } elif event.type == "tool_result" {
            llmStore.setAgentStatus("Processing result...");
        } elif event.type == "steps_done" {
            llmStore.setAgentStatus("Writing response...");
        } elif event.type == "response_chunk" {
            llmStore.appendStreamingContent((event.data or {}).content or "");
        }
        llmStore.addAgentTraceEvent(event);
    }

    async def _readStream(response: Any) -> None {
        try {
            if not response.ok {
                console.error(
                    "[useAgentLoop] HTTP error:", response.status, response.statusText
                );
                llmStore.setAgentRunning(False);
                return;
            }
            if not response.body {
                llmStore.setAgentRunning(False);
                return;
            }
            reader = response.body.getReader();
            readerRef.current = reader;
            decoder = Reflect.construct(TextDecoder, []);
            buffer = "";

            while True {
                chunk = await reader.read();
                if chunk.done {
                    break;
                }
                buffer = buffer + decoder.decode(chunk.value, {"stream": True});
                lines = buffer.split(String.fromCharCode(10));
                buffer = lines.pop();
                for line in lines {
                    trimmed = line.trim();
                    if not trimmed {
                        continue;
                    }
                    try {
                        event = JSON.parse(trimmed);
                        _dispatchEvent(event);
                    } except Exception as parseErr {
                        console.warn(
                            "[useAgentLoop] failed to parse line:", trimmed, parseErr
                        );
                        continue;
                    }
                }
            }
        } except Exception as e {
            llmStore.setAgentRunning(False);
        } finally {
            llmStore.setAgentRunning(False);
        }
    }

    # ── Public API ────────────────────────────────────────────────────────────
    async def runAgentLoop(connection: Any, userMessage: str) -> None {
        if llmStore.agentRunning {
            return;
        }
        if not conversationIdRef.current {
            conversationIdRef.current = crypto.randomUUID();
            firstMsgRef.current = userMessage;
            llmStore.setAgentSessionId(conversationIdRef.current);
        }

        llmStore.setAgentRunning(True);
        llmStore.setAgentStatus("Thinking...");
        llmStore.clearStreamingContent();
        llmStore.clearAgentTrace();

        sessionIdRef.current = crypto.randomUUID();

        userMsg = {"role": "user", "content": userMessage};
        chatHistorySnapshot = llmStore.chatMessages;
        llmStore.addChatMessage(userMsg);
        llmStore.addAgentTraceEvent(
            {
                "type": "user_message",
                "timestamp": Date.now(),
                "data": {"content": userMessage}
            }
        );

        response = await fetch(
            "/walker/agent_run",
            {
                "method": "POST",
                "headers": {"Content-Type": "application/json"},
                "body": JSON.stringify(
                    {
                        "session_id": sessionIdRef.current,
                        "llm_config": llmStore.llmConfig,
                        "message": userMessage,
                        "chat_history": chatHistorySnapshot,
                        "server_connections": _buildServerConnections()
                    }
                )
            }
        );

        await _readStream(response);
    }

    def newSession() -> None {
        abortAgent();
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
        llmStore.clearChat();
        llmStore.setAgentSessionId("");
    }

    def deleteCurrentSession() -> None {
        abortAgent();
        cid = conversationIdRef.current;
        if cid {
            llmStore.setSessionHistory(
                _removeFromHistory(llmStore.sessionHistory, cid)
            );
        }
        firstMsgRef.current = "";
        conversationIdRef.current = "";
        sessionIdRef.current = None;
        llmStore.clearChat();
        llmStore.setAgentSessionId("");
    }

    async def deleteHistorySession(sessionId: str) -> None {
        llmStore.setSessionHistory(
            _removeFromHistory(llmStore.sessionHistory, sessionId)
        );
    }

    def loadSession(
        msgs: Any, trace: Any, tokenUsage: Any, sid: str, title: str
    ) -> None {
        abortAgent();
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
        llmStore.loadSession(msgs, trace, tokenUsage, sid);
        conversationIdRef.current = sid;
        firstMsgRef.current = title;
        sessionIdRef.current = None;
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
    }

    async def abortAgent() -> None {
        if sessionIdRef.current {
            fetch(
                "/function/end_session",
                {
                    "method": "POST",
                    "headers": {"Content-Type": "application/json"},
                    "body": JSON.stringify({"session_id": sessionIdRef.current})
                }
            );
        }
        if readerRef.current {
            readerRef.current.cancel();
            readerRef.current = None;
        }
        llmStore.setPendingConfirmation(None);
        llmStore.setAgentStatus("");
        llmStore.clearStreamingContent();
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
