"""Agent Runner – public walker + StreamEvent bridge.

agent_run:   spawned by the frontend, fires a background thread that runs the
             full byllm ReAct loop and writes every StreamEvent into agent_state.
             Returns immediately so the HTTP request is not blocked.

StreamEvent  →  ProtoMCP trace event mapping
─────────────────────────────────────────────────────────────
byllm type    ProtoMCP type      Notes
─────────────────────────────────────────────────────────────
tool_call   → tool_call          strips server_id__ prefix for display
tool_result → tool_result        strips server_id__ prefix for display
thought     → thought            LLM reasoning text (shown in trace)
steps_done  → steps_done        ReAct loop finished, final answer next
chunk       → response_chunk     streamed token; accumulated for final_response
usage       → usage              aggregated + per-call token counts
─────────────────────────────────────────────────────────────
After all chunks arrive a single  final_response  event is emitted
so the frontend can append the complete message to chat history.

byllm typed exceptions map directly to ProtoMCP's existing errorKind values:
  AuthenticationError  → "auth"
  RateLimitError       → "rate_limit"
  ModelNotFoundError   → "model_not_found"
  ByLLMError (base)    → "generic"
"""

import threading;
import time;

import from byllm.lib {
    StreamEvent,
    AuthenticationError,
    RateLimitError,
    ModelNotFoundError,
    ByLLMError
}

import from services.llm_factory  { create_llm }
import from services.agent_state  {
    init_session, append_event, mark_complete
}
import from services.agent_node   { AgentNode }


# ── Walker ────────────────────────────────────────────────────────────────────

walker:pub agent_run {
    has session_id:         str  = "";
    has llm_config:         dict = {};
    has message:            str  = "";
    has chat_history:       list = [];
    has server_connections: list = [];

    can run with Root entry {
        if not self.session_id {
            report {"ok": False, "error": "session_id is required"};
            disengage;
        }

        # Initialise per-session state immediately
        init_session(self.session_id);

        # Fire the ReAct loop in a daemon thread; return HTTP response right away
        threading.Thread(
            target = self._run_agent,
            daemon = True
        ).start();

        report {"ok": True, "session_id": self.session_id};
    }

    # ── Background thread ─────────────────────────────────────────────────────

    def _run_agent() -> None {
        ts = self._ts;

        try {
            # Instantiate the agent node with a per-request LLM model
            agent_nd = AgentNode(
                session_id         = self.session_id,
                server_connections = self.server_connections,
                llm                = create_llm(
                    provider    = self.llm_config.get("provider",    "openai"),
                    model       = self.llm_config.get("model",       "gpt-4o-mini"),
                    api_key     = self.llm_config.get("apiKey",      ""),
                    temperature = self.llm_config.get("temperature", 0.7),
                    max_tokens  = self.llm_config.get("maxTokens",   4096)
                ),
                confirm_mode       = self.llm_config.get("confirmMode", False)
            );

            # Pre-build the tool registry from already-fetched server connection data
            agent_nd.init_registry();

            append_event(self.session_id, {
                "type":      "llm_call_start",
                "timestamp": ts(),
                "data": {
                    "model":     self.llm_config.get("model", "unknown"),
                    "iteration": 1,
                    "toolCount": sum(len(c.get("tools") or []) for c in self.server_connections)
                }
            });

            # Run the full ReAct loop – yields StreamEvent objects
            final_chunks: list[str] = [];

            for event in agent_nd.run_agent(
                message       = self.message,
                chat_history  = self.chat_history,
                system_prompt = self.llm_config.get("systemPrompt", "")
            ) {
                self._handle_event(event, final_chunks);
            }

            # Emit the assembled final response so the frontend can save it
            if final_chunks {
                append_event(self.session_id, {
                    "type":      "final_response",
                    "timestamp": ts(),
                    "data":      {"content": "".join(final_chunks)}
                });
            }

        } except AuthenticationError as e {
            append_event(self.session_id, {
                "type":      "error",
                "timestamp": self._ts(),
                "data":      {"error": str(e), "errorKind": "auth"}
            });

        } except RateLimitError as e {
            append_event(self.session_id, {
                "type":      "error",
                "timestamp": self._ts(),
                "data":      {"error": str(e), "errorKind": "rate_limit"}
            });

        } except ModelNotFoundError as e {
            append_event(self.session_id, {
                "type":      "error",
                "timestamp": self._ts(),
                "data":      {"error": str(e), "errorKind": "model_not_found"}
            });

        } except ByLLMError as e {
            append_event(self.session_id, {
                "type":      "error",
                "timestamp": self._ts(),
                "data":      {"error": str(e), "errorKind": "generic"}
            });

        } except Exception as e {
            import traceback;
            print(f"[agent_runner] unexpected error: {traceback.format_exc()}");
            append_event(self.session_id, {
                "type":      "error",
                "timestamp": self._ts(),
                "data":      {"error": str(e), "errorKind": "generic"}
            });

        } finally {
            mark_complete(self.session_id);
        }
    }

    # ── StreamEvent → ProtoMCP trace event ───────────────────────────────────

    def _handle_event(event: StreamEvent, chunks: list) -> None {
        ts = self._ts();
        t  = event.event_type;
        d  = event.data;

        if t == "tool_call" {
            # Strip server_id prefix for display; keep full name in raw data
            parts  = d.get("tool", "").split("__", 1);
            server = parts[0] if len(parts) == 2 else "unknown";
            tool   = parts[1] if len(parts) == 2 else d.get("tool", "?");

            append_event(self.session_id, {
                "type":      "tool_call",
                "timestamp": ts,
                "data": {
                    "id":        d.get("call_id"),
                    "name":      tool,
                    "arguments": d.get("args"),
                    "server":    server,
                    "iteration": d.get("iteration")
                }
            });

        } elif t == "tool_result" {
            parts = d.get("tool", "").split("__", 1);
            tool  = parts[1] if len(parts) == 2 else d.get("tool", "?");

            append_event(self.session_id, {
                "type":      "tool_result",
                "timestamp": ts,
                "data": {
                    "id":        d.get("call_id"),
                    "name":      tool,
                    "result":    d.get("result"),
                    "iteration": d.get("iteration")
                }
            });

        } elif t == "thought" {
            # LLM reasoning text before a tool call – visible in trace
            append_event(self.session_id, {
                "type":      "thought",
                "timestamp": ts,
                "data": {
                    "content":   d.get("content"),
                    "iteration": d.get("iteration")
                }
            });

        } elif t == "chunk" {
            # One streamed token of the final answer
            chunks.append(d.get("content", ""));
            append_event(self.session_id, {
                "type":      "response_chunk",
                "timestamp": ts,
                "data":      {"content": d.get("content")}
            });

        } elif t == "steps_done" {
            # ReAct loop finished; final answer streaming starts next
            append_event(self.session_id, {
                "type":      "steps_done",
                "timestamp": ts,
                "data":      {"iterations": d.get("iterations")}
            });

        } elif t == "usage" {
            # Aggregated token usage across all LLM calls in this invocation
            total = d.get("total", {});
            append_event(self.session_id, {
                "type":      "usage",
                "timestamp": ts,
                "data": {
                    "usage": {
                        "prompt_tokens":     total.get("prompt_tokens",     0),
                        "completion_tokens": total.get("completion_tokens", 0),
                        "total_tokens":      total.get("total_tokens",      0)
                    },
                    "per_call": d.get("per_call", [])
                }
            });
        }
    }

    # ── Helpers ───────────────────────────────────────────────────────────────

    def _ts() -> int {
        # Current time in milliseconds (matches JS Date.now()).
        return int(time.time() * 1000);
    }
}
