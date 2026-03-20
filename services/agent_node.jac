"""AgentNode – the heart of the byllm-powered agent.

This node owns a single MCP execution tool and the by llm() method that drives
the ReAct loop.  The full tool catalog (names, descriptions, schemas) is injected
into the system context via incl_info so the LLM knows every available tool from
iteration 1.

Confirmation mode is handled transparently inside use_mcp_tool — the LLM simply
calls use_mcp_tool and the confirmation gate (if enabled) blocks until the user
approves or denies without requiring any extra tool call.

Tool flow:
  1. LLM reads available_mcp_tools in system context → knows all tool names/schemas
  2. LLM calls use_mcp_tool(name, arguments)
     a. If confirm_mode: blocks until user approves in the UI
     b. On deny: returns a denial message; LLM decides next step
     c. On approve (or confirm_mode off): executes via mcp_proxy, returns result
  3. Loop continues until finish_tool() → byllm returns final str answer
"""

import json;
import from typing { Any }
import from services.mcp_proxy { mcp_proxy }
import from services.agent_state {
    set_pending_confirmation,
    wait_for_confirmation
}


node AgentNode {
    has session_id:         str;
    has server_connections: list;      # [{id, name, url, transport, tools, headers}]
    has llm:                Any;       # byllm Model instance – set by agent_runner
    has tool_registry:      dict = {}; # keyed by server_id__tool_name
    has confirm_mode:       bool = False;

    # ── Registry initialisation ───────────────────────────────────────────────
    # Called by agent_runner immediately after construction.
    # Builds tool_registry from the already-fetched server_connections data.

    def init_registry() -> None {
        for conn in self.server_connections {
            for tool in (conn.get("tools") or []) {
                key = f"{conn['id']}__{tool['name']}";
                self.tool_registry[key] = {
                    "conn":         conn,
                    "tool_name":    tool["name"],
                    "description":  tool.get("description", ""),
                    "input_schema": tool.get("inputSchema", {})
                };
            }
        }
    }

    # ── Tool catalog for incl_info ────────────────────────────────────────────
    # Returns a compact list the LLM can read to know every available tool.

    def _tool_catalog() -> list {
        catalog = [];
        for (key, entry) in self.tool_registry.items() {
            catalog.append({
                "name":         key,
                "description":  entry["description"],
                "input_schema": entry["input_schema"]
            });
        }
        return catalog;
    }

    # ── Tool: Execute an MCP tool ─────────────────────────────────────────────
    # Confirmation gate is embedded here — transparent to the LLM.

    def use_mcp_tool(name: str, arguments: str = "{}") -> str {
        # arguments arrives as a JSON string; parse it back to a dict for MCP.
        # (byllm's schema generator cannot handle dict[str, Any] or untyped dict,
        #  so we accept str and decode here.)
        args: dict = {};
        try {
            if arguments {
                args = json.loads(arguments);
            }
        } except Exception {
            args = {};
        }

        if name not in self.tool_registry {
            return f"Unknown tool '{name}'. Check available_mcp_tools in your context for valid names.";
        }

        # Confirmation gate — blocks until user responds if confirm_mode is on
        if self.confirm_mode {
            set_pending_confirmation(self.session_id, name, args);
            approved = wait_for_confirmation(self.session_id);
            if not approved {
                return f"Tool call '{name}' was denied by the user. Do not retry this tool.";
            }
        }

        reg_entry = self.tool_registry[name];
        conn      = reg_entry["conn"];

        result = mcp_proxy(
            url       = conn["url"],
            body      = {
                "jsonrpc": "2.0",
                "id":      name,
                "method":  "tools/call",
                "params":  {
                    "name":      reg_entry["tool_name"],
                    "arguments": args
                }
            },
            headers   = conn.get("headers", {}),
            transport = conn.get("transport", "streamable-http")
        );

        if result.get("ok") {
            data    = result.get("data") or (result.get("events") or [{}])[0];
            content = data.get("result", data);
            if isinstance(content, str) {
                return content;
            } else {
                return json.dumps(content);
            }
        }
        return f"Tool error: {result.get('error', 'unknown error')}";
    }

    # ── Agent entry point ─────────────────────────────────────────────────────

    def run_agent(
        message:       str,
        chat_history:  list[dict],
        system_prompt: str
    ) -> str by self.llm(
        tools                = [self.use_mcp_tool],
        max_react_iterations = 10,
        stream               = True,
        logging              = True,
        incl_info            = {
            "system_instructions": system_prompt,
            "conversation_history": chat_history,
            "available_mcp_tools": self._tool_catalog()
        }
    );
}


# ── Semantic strings ──────────────────────────────────────────────────────────

sem AgentNode.use_mcp_tool = """
Execute an MCP tool by its full prefixed name (server_id__tool_name).
The complete list of available tools with their descriptions and argument schemas
is in available_mcp_tools in your context — use those exact names.
Pass arguments as a flat dict matching the tool's input_schema.
Returns the tool result as a string.
If the tool call requires user confirmation, it is handled automatically — just
call this tool and wait for the result.
""";

sem AgentNode.use_mcp_tool.name      = "Full prefixed tool name from available_mcp_tools, e.g. 'fs__read_file'.";
sem AgentNode.use_mcp_tool.arguments = "Tool arguments as a JSON-encoded string matching the tool's input_schema, e.g. '{\"limit\": 5, \"path\": \"/tmp\"}'. Values may be strings, numbers, booleans, lists, or nested objects. Pass '{}' if no arguments are needed.";

sem AgentNode.run_agent = """
You are a helpful AI assistant with access to external tools provided by MCP servers.

The available_mcp_tools in your context lists every tool you can call, with its
description and argument schema. Read it to understand what tools exist before acting.

Workflow:
1. Check available_mcp_tools to find the right tool for the task.
2. Call use_mcp_tool with the chosen tool name and arguments to execute it.
3. Repeat as needed, then produce a clear final answer.

Tool names follow the format  server_id__tool_name  (e.g. 'github__list_repos').
The conversation_history in your context is the prior chat — use it for continuity.
If a tool call requires user confirmation, it is handled automatically.
""";

sem AgentNode.run_agent.message       = "The user's latest message.";
sem AgentNode.run_agent.chat_history  = "Prior conversation turns [{role, content}, …] for context.";
sem AgentNode.run_agent.system_prompt = "High-level instructions that govern the agent's behaviour.";
