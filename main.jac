"""ProtoMCP – entry point."""
import from services.mcp_proxy { mcp_proxy }
import from services.mcp_server_launcher { _builtin_servers }

import from services.agent_state { confirm_tool_call }
import from services.agent_runner { agent_run }
import from services.agent_node { AgentNode }
import from services.llm_factory { create_llm }

cl import ".styles/globals.css";
cl import from "react" { useEffect }

cl {
    def:pub app(children: Any = None) -> Any {
        useEffect(
            lambda -> Any { if not document.documentElement.classList.contains(
                "dark"
            )
            and not document.documentElement.classList.contains("light") {
                document.documentElement.classList.add("dark");
            }return lambda -> None { }; },
            []
        );
        return
            <div className="min-h-screen bg-background text-foreground">
                {children}
            </div>;
    }
}
