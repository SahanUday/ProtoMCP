"""Root layout – shared header across all pages."""

cl import from "@jac/runtime" { Outlet, Link }
cl import from "react" { useEffect }
cl import from "lucide-react" { Sun, Moon, Github }
cl import from ..store.mcp_store { McpProvider, useMcpStore }
cl import from ..store.llm_store { LlmProvider }
cl import from ..hooks.useMcpClient { useMcpClient }

cl {
    def AppHeader() -> JsxElement {
        has isDark: bool = False;

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

        return
            <header
                className="sticky top-0 z-50 h-14 border-b border-border bg-background/80 backdrop-blur-md"
            >
                <div
                    className="max-w-screen-2xl mx-auto px-6 h-full flex items-center justify-between"
                >
                    <div className="flex items-center gap-6">
                        <Link
                            to="/"
                            className="flex items-center gap-2.5 hover:opacity-80 transition-opacity"
                        >
                            <img
                                src="static/assets/mcp.png"
                                alt="MCP"
                                className="w-7 h-7 rounded-lg object-contain"
                            />
                            <span className="font-bold text-foreground tracking-tight">
                                ProtoMCP
                            </span>
                        </Link>
                        <nav className="hidden sm:flex items-center gap-1">
                            <Link
                                to="/"
                                className="px-3 py-1.5 rounded-lg text-sm font-medium text-muted-foreground hover:text-foreground hover:bg-muted/60 transition-colors"
                            >
                                Home
                            </Link>
                            <Link
                                to="/playground"
                                className="px-3 py-1.5 rounded-lg text-sm font-medium text-muted-foreground hover:text-foreground hover:bg-muted/60 transition-colors"
                            >
                                Playground
                            </Link>
                            <Link
                                to="/mcpregistry"
                                className="px-3 py-1.5 rounded-lg text-sm font-medium text-muted-foreground hover:text-foreground hover:bg-muted/60 transition-colors"
                            >
                                MCP Servers List
                            </Link>
                            <Link
                                to="/docs"
                                className="px-3 py-1.5 rounded-lg text-sm font-medium text-muted-foreground hover:text-foreground hover:bg-muted/60 transition-colors"
                            >
                                Docs
                            </Link>
                        </nav>
                    </div>
                    <div className="flex items-center gap-2">
                        <a
                            href="https://github.com/SahanUday/ProtoMCP"
                            target="_blank"
                            rel="noopener noreferrer"
                            className="p-2 rounded-lg text-muted-foreground hover:text-foreground hover:bg-muted transition-colors"
                            title="GitHub"
                        >
                            <Github size={16}/>
                        </a>
                        <button
                            onClick={toggleTheme}
                            className="p-2 rounded-lg text-muted-foreground hover:text-foreground hover:bg-muted transition-colors cursor-pointer"
                            title="Toggle theme"
                        >
                            {isDark and <Sun size={16}/> or <Moon size={16}/>}
                        </button>
                    </div>
                </div>
            </header>;
    }

    # Reconnects connections restored from sessionStorage on page load.
    # Only targets connections with fromStorage=True to avoid conflicting
    # with connections being manually added via ConnectModal.
    def McpReconnector -> JsxElement {
        connections = useMcpStore(lambda (s: Any) -> Any { return s.connections; });
        client = useMcpClient();

        useEffect(
            lambda -> Any { toReconnect = connections.filter(
                lambda (c: Any) -> Any { return Boolean(c.fromStorage)
                and c.status == "disconnected"; }
            );for conn in toReconnect {
                client.initialize(conn).then(
                    lambda (ok: Any) -> Any { if ok {
                        client.discoverCapabilities(conn);
                    }return None; }
                );
            }return lambda -> None { }; },
            [connections]
        );

        return
            <span/>;
    }

    def:pub layout -> JsxElement {
        return
            <McpProvider>
                <LlmProvider>
                    <McpReconnector/>
                    <AppHeader/>
                    <Outlet/>
                </LlmProvider>
            </McpProvider>;
    }
}
