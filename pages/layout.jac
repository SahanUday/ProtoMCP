"""Root layout – shared header across all pages."""

cl import from "@jac/runtime" { Outlet, Link }
cl import from "lucide-react" { Sun, Moon, ExternalLink }
cl import from ..store.mcp_store { McpProvider }

cl {
    def AppHeader() -> JsxElement {
        has isDark: bool = True;

        def toggleTheme -> None {
            isDark = not isDark;
            if isDark {
                document.documentElement.classList.add("dark");
                document.documentElement.classList.remove("light");
            } else {
                document.documentElement.classList.remove("dark");
                document.documentElement.classList.add("light");
            }
        }

        return <header className="sticky top-0 z-50 h-14 border-b border-border bg-background/80 backdrop-blur-md">
            <div className="max-w-screen-2xl mx-auto px-6 h-full flex items-center justify-between">
                <div className="flex items-center gap-6">
                    <Link to="/" className="flex items-center gap-2.5 hover:opacity-80 transition-opacity">
                        <img src="static/assets/mcp.png" alt="MCP" className="w-7 h-7 rounded-lg object-contain"/>
                        <span className="font-bold text-foreground tracking-tight">MCP Playground</span>
                    </Link>
                    <nav className="hidden sm:flex items-center gap-1">
                        <Link to="/" className="px-3 py-1.5 rounded-lg text-sm font-medium text-muted-foreground hover:text-foreground hover:bg-muted/60 transition-colors">
                            Home
                        </Link>
                        <Link to="/playground" className="px-3 py-1.5 rounded-lg text-sm font-medium text-muted-foreground hover:text-foreground hover:bg-muted/60 transition-colors">
                            Playground
                        </Link>
                        <a href="https://modelcontextprotocol.io" target="_blank" rel="noopener noreferrer" className="flex items-center gap-1 px-3 py-1.5 rounded-lg text-sm font-medium text-muted-foreground hover:text-foreground hover:bg-muted/60 transition-colors">
                            Docs
                            <ExternalLink size={11} className="opacity-50"/>
                        </a>
                    </nav>
                </div>
                <button onClick={toggleTheme} className="p-2 rounded-lg text-muted-foreground hover:text-foreground hover:bg-muted transition-colors cursor-pointer" title="Toggle theme">
                    {isDark and <Sun size={16}/> or <Moon size={16}/>}
                </button>
            </div>
        </header>;
    }

    def:pub layout -> JsxElement {
        return <McpProvider>
            <AppHeader/>
            <Outlet/>
        </McpProvider>;
    }
}
