"""Root layout – shared header across all pages."""

cl import from "@jac/runtime" { Outlet, Link }
cl import from "react" { useEffect }
cl import from "lucide-react" { Sun, Moon, ExternalLink, Github, ChevronDown, BookOpen }
cl import from ..store.mcp_store { McpProvider, useMcpStore }
cl import from ..store.llm_store { LlmProvider }
cl import from ..hooks.useMcpClient { useMcpClient }

cl {
    def AppHeader() -> JsxElement {
        has isDark: bool = False;
        has docsOpen: bool = False;

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
                            <div className="relative">
                                <button
                                    onClick={lambda -> None { docsOpen = not docsOpen;}}
                                    className="flex items-center gap-1 px-3 py-1.5 rounded-lg text-sm font-medium text-muted-foreground hover:text-foreground hover:bg-muted/60 transition-colors cursor-pointer"
                                >
                                    Docs
                                    <ChevronDown size={12} className="opacity-50"/>
                                </button>
                                {docsOpen
                                and <div
                                    className="fixed inset-0 z-40"
                                    onClick={lambda -> None { docsOpen = False;}}
                                />}
                                {docsOpen
                                and <div
                                    className="absolute top-full left-0 mt-1 w-72 bg-card border border-border rounded-xl shadow-xl p-2 z-50"
                                >
                                    <a
                                        href="https://blogs.jaseci.org/blog/2026/03/16/building-protomcp/"
                                        target="_blank"
                                        rel="noopener noreferrer"
                                        onClick={lambda -> None { docsOpen = False;}}
                                        className="flex items-start gap-3 p-3 rounded-lg hover:bg-muted/60 transition-colors group"
                                    >
                                        <div
                                            className="w-8 h-8 rounded-lg bg-primary/10 border border-primary/20 flex items-center justify-center text-primary flex-shrink-0"
                                        >
                                            <BookOpen size={14}/>
                                        </div>
                                        <div className="flex-1 min-w-0">
                                            <p
                                                className="text-sm font-medium text-foreground group-hover:text-primary transition-colors leading-snug"
                                            >
                                                Browser Automation with Walkers
                                            </p>
                                            <p
                                                className="text-xs text-muted-foreground mt-0.5"
                                            >
                                                Fix It guide — Jaseci Blog
                                            </p>
                                        </div>
                                        <ExternalLink
                                            size={11}
                                            className="text-muted-foreground mt-0.5 flex-shrink-0 opacity-60"
                                        />
                                    </a>
                                </div>}
                            </div>
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
