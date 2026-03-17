"""ProtoMCP – entry point."""

import from services.mcp_proxy { mcp_proxy }
import from services.mcp_server_launcher { _builtin_servers }

cl import ".styles/globals.css";
cl import from "react" { useEffect }

cl {
    def:pub app(children: Any = None) -> Any {
        useEffect(lambda -> Any {
            if not document.documentElement.classList.contains("dark") and not document.documentElement.classList.contains("light") {
                document.documentElement.classList.add("dark");
            }
            return lambda -> None {};
        }, []);

        return <div className="min-h-screen bg-background text-foreground">{children}</div>;
    }
}
