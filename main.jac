"""ProtoMCP – entry point."""
import from services.mcp_proxy { mcp_proxy }
import from services.mcp_server_launcher { _builtin_servers }

import from services.agent_state { confirm_tool_call }
import from services.agent_runner { agent_run }
import from services.agent_node { AgentNode }
import from services.llm_factory { create_llm }

cl import ".styles/globals.css";
cl import from "react" { useEffect }

glob GA_MEASUREMENT_ID: str = "G-GZBGYX1V5F";

cl {
    def:pub app(children: Any = None) -> Any {
        useEffect(
            lambda -> Any {
                # Dark mode init
                if not document.documentElement.classList.contains("dark")
                and not document.documentElement.classList.contains("light") {
                    document.documentElement.classList.add("dark");
                }

                # Google Analytics injection
                if GA_MEASUREMENT_ID != "G-XXXXXXXXXX" {
                    # Create script tag for GA
                    script = document.createElement("script");
                    script.async = True;
                    script.src = f"https://www.googletagmanager.com/gtag/js?id={GA_MEASUREMENT_ID}";
                    document.head.appendChild(script);

                    # Initialize gtag
                    script2 = document.createElement("script");
                    script2.innerHTML = f"""
                        window.dataLayer = window.dataLayer || [];
                        function gtag(){{dataLayer.push(arguments);}}
                        gtag('js', new Date());
                        gtag('config', '{GA_MEASUREMENT_ID}');
                    """;
                    document.head.appendChild(script2);
                }

                return lambda -> None { };
            },
            []
        );
        return
            <div className="min-h-screen bg-background text-foreground">
                {children}
            </div>;
    }
}
