"""ProtoMCP – entry point."""
import from services.mcp_proxy { mcp_proxy }
import from services.mcp_server_launcher { _builtin_servers }

import from services.agent_state { confirm_tool_call }
import from services.agent_runner { agent_run }
import from services.agent_node { AgentNode }
import from services.llm_factory { create_llm }

cl import ".styles/globals.css";
cl import from "react" { useEffect }
cl import from .components.Analytics { Analytics }

cl glob GA_MEASUREMENT_ID: str = "G-GZBGYX1V5F";

cl {
    def:pub app(children: Any = None) -> Any {
        useEffect(
            lambda -> Any {
                # Dark mode init
                if not document.documentElement.classList.contains("dark")
                and not document.documentElement.classList.contains("light") {
                    document.documentElement.classList.add("dark");
                }

                # Google Analytics script injection (run once)
                if GA_MEASUREMENT_ID != "" and not window.ga_initialized {
                    window.ga_initialized = true;

                    # Create gtag.js script tag
                    script1 = document.createElement("script");
                    script1.setAttribute("async", "true");
                    script1.src = "https://www.googletagmanager.com/gtag/js?id=" + GA_MEASUREMENT_ID;
                    document.head.appendChild(script1);

                    # Create inline script for gtag initialization
                    script2 = document.createElement("script");
                    script2.text = "window.dataLayer=window.dataLayer||[];function gtag(){dataLayer.push(arguments);}gtag('js',new Date());gtag('config','" + GA_MEASUREMENT_ID + "',{send_page_view:false});";
                    document.head.appendChild(script2);
                }

                return lambda -> None { };
            },
            []
        );
        return
            <div className="min-h-screen bg-background text-foreground">
                <Analytics/>
                {children}
            </div>;
    }
}
