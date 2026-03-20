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


# ── Auth header builder (mirrors useMcpClient) ────────────────────────────────
def _buildAuthHeaders(auth: Any) -> Any {
    h = {};
    if not auth { return h; }
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


# ── Hook ──────────────────────────────────────────────────────────────────────

def:pub useAgentLoop -> Any {
    store = useMcpStore();

    # useRef gives stable objects that persist across re-renders.
    # All closures reference the same ref objects regardless of when they were created.
    sessionIdRef    = useRef(None);
    eventIndexRef   = useRef(0);
    pollIntervalRef = useRef(None);
    abortRef        = useRef(False);
    pollActiveRef   = useRef(False);  # guard: only one _poll runs at a time

    # ── Tool aggregation ──────────────────────────────────────────────────────
    def _buildServerConnections() -> Any {
        enabledTools = store.llmConfig.enabledTools;
        return store.connections
            .filter(lambda(c: Any) -> Any { return c.status == "connected"; })
            .map(lambda(c: Any) -> Any {
                tools = (c.capabilities?.tools or []).filter(
                    lambda(t: Any) -> Any {
                        return not enabledTools or enabledTools.includes(t.name);
                    }
                );
                authHeaders = _buildAuthHeaders(c.auth);
                if c.sessionId {
                    authHeaders["mcp-session-id"] = c.sessionId;
                }
                return {
                    "id":        c.id,
                    "name":      c.name,
                    "url":       c.url,
                    "transport": c.transport or "streamable-http",
                    "tools":     tools,
                    "headers":   authHeaders
                };
            });
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
                    "method":  "POST",
                    "headers": {"Content-Type": "application/json"},
                    "body":    JSON.stringify({
                        "session_id":  sessionIdRef.current,
                        "since_index": eventIndexRef.current
                    })
                }
            );
            envelope = await resp.json();
            data = (envelope.data or {}).result or {};

            for event in (data.events or []) {
                eventIndexRef.current = eventIndexRef.current + 1;

                if event.type == "usage" {
                    store.addTokenUsage((event.data or {}).usage or {});

                } elif event.type == "final_response" {
                    store.addChatMessage({
                        "role":    "assistant",
                        "content": (event.data or {}).content or ""
                    });

                } elif event.type == "error" {
                    store.addChatMessage({
                        "role":      "system",
                        "content":   (event.data or {}).error or "An error occurred",
                        "errorKind": (event.data or {}).errorKind
                    });
                }

                store.addAgentTraceEvent(event);
            }

            if data.pending_confirmation {
                clearInterval(pollIntervalRef.current);
                pollActiveRef.current = False;
                store.setPendingConfirmation(data.pending_confirmation);
                return;
            }

            if not data.running {
                clearInterval(pollIntervalRef.current);
                pollActiveRef.current = False;
                store.setAgentRunning(False);
                return;
            }

        } except Exception as e {
            clearInterval(pollIntervalRef.current);
            pollActiveRef.current = False;
            store.setAgentRunning(False);
            return;
        }

        pollActiveRef.current = False;
    }

    # ── Public API ────────────────────────────────────────────────────────────

    async def runAgentLoop(connection: Any, userMessage: str) -> None {
        abortRef.current = False;
        store.setAgentRunning(True);
        store.clearAgentTrace();

        # Set directly on the ref — synchronous, visible immediately in this closure
        sessionIdRef.current  = crypto.randomUUID();
        eventIndexRef.current = 0;

        userMsg = {"role": "user", "content": userMessage};
        store.addChatMessage(userMsg);
        store.addAgentTraceEvent({
            "type":      "user_message",
            "timestamp": Date.now(),
            "data":      {"content": userMessage}
        });

        await fetch("/walker/agent_run", {
            "method":  "POST",
            "headers": {"Content-Type": "application/json"},
            "body": JSON.stringify({
                "session_id":         sessionIdRef.current,
                "llm_config":         store.llmConfig,
                "message":            userMessage,
                "chat_history":       store.chatMessages,
                "server_connections": _buildServerConnections()
            })
        });

        pollIntervalRef.current = setInterval(_poll, 500);
    }

    async def approveToolCall() -> None {
        store.setPendingConfirmation(None);
        await fetch("/function/confirm_tool_call", {
            "method":  "POST",
            "headers": {"Content-Type": "application/json"},
            "body":    JSON.stringify({"session_id": sessionIdRef.current, "approved": 1})
        });
        pollIntervalRef.current = setInterval(_poll, 500);
    }

    async def denyToolCall() -> None {
        store.setPendingConfirmation(None);
        await fetch("/function/confirm_tool_call", {
            "method":  "POST",
            "headers": {"Content-Type": "application/json"},
            "body":    JSON.stringify({"session_id": sessionIdRef.current, "approved": 0})
        });
        pollIntervalRef.current = setInterval(_poll, 500);
    }

    def abortAgent() -> None {
        abortRef.current = True;
        clearInterval(pollIntervalRef.current);
        store.setAgentRunning(False);
    }

    return {
        "runAgentLoop":    runAgentLoop,
        "abortAgent":      abortAgent,
        "approveToolCall": approveToolCall,
        "denyToolCall":    denyToolCall
    };
}
