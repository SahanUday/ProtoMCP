"""MCP Servers List – browse and discover available MCP servers from the registry."""

cl import from "@jac/runtime" { useNavigate }
cl import from "lucide-react" {
    Server, Globe, Shield, Wifi, Copy, Play, Search, Check, Zap
}

cl {
    def RegistryServerCard(props: Any) -> JsxElement {
        server = props.server;
        navigate = useNavigate();
        has copied: bool = False;

        def handleTestServer -> None {
            params = f"url={encodeURIComponent(server.url)}&transport=streamable-http&auth={server.auth}&name={encodeURIComponent(server.name)}";
            navigate(f"/testmcp?{params}");
        }

        def handleCopyUrl -> None {
            navigator.clipboard.writeText(server.url);
            copied = True;
            setTimeout(lambda -> None { copied = False; }, 1500);
        }

        transportColors = {
            "http": "text-info bg-info/10 border-info/20",
            "sse": "text-warning bg-warning/10 border-warning/20",
            "stdio": "text-muted-foreground bg-muted border-border"
        };
        transportLabels = {
            "http": "HTTP",
            "sse": "SSE",
            "stdio": "STDIO"
        };
        transportCls = transportColors[server.transport] if server.transport in transportColors else transportColors["http"];
        transportLabel = transportLabels[server.transport] if server.transport in transportLabels else server.transport.toUpperCase();

        return <div className="group relative bg-card border border-border rounded-xl overflow-hidden hover:border-primary/30 hover:shadow-lg hover:shadow-primary/5 transition-all duration-300 flex flex-col">
            <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-primary/60 via-primary/30 to-transparent opacity-0 group-hover:opacity-100 transition-opacity"/>

            <div className="p-5 flex-1">
                <div className="flex items-start gap-3 mb-3">
                    <div className="w-10 h-10 rounded-xl bg-primary/10 border border-primary/20 flex items-center justify-center flex-shrink-0 group-hover:bg-primary/15 transition-colors">
                        <Server size={18} className="text-primary"/>
                    </div>
                    <div className="min-w-0 flex-1">
                        <h3 className="text-sm font-semibold text-foreground truncate">{server.name}</h3>
                        <div className="flex items-center gap-1.5 mt-1.5 flex-wrap">
                            <span className="text-xs text-muted-foreground bg-muted px-2 py-0.5 rounded-full font-mono">{server.namespace}</span>
                            <span className="text-xs text-success bg-success/10 px-2 py-0.5 rounded-full border border-success/20 font-medium">Official</span>
                            <span className={f"inline-flex items-center gap-1 text-xs font-medium px-2 py-0.5 rounded-full border {transportCls}"}>{transportLabel}</span>
                        </div>
                    </div>
                </div>

                <p className="text-sm text-muted-foreground leading-relaxed mb-4">{server.description}</p>

                {server.authRequired and
                    <div className="flex items-center gap-1.5 mb-3 text-xs text-muted-foreground">
                        <Shield size={12} className="text-warning flex-shrink-0"/>
                        <span>Auth required · Bearer token</span>
                    </div>
                }

                <div className="flex items-center gap-2 p-2.5 bg-muted/50 rounded-lg border border-border">
                    <Globe size={11} className="text-muted-foreground flex-shrink-0"/>
                    <span className="text-xs text-muted-foreground truncate font-mono flex-1">{server.url}</span>
                    <button
                        onClick={lambda(e: Any) -> None { e.stopPropagation(); handleCopyUrl(); }}
                        className="p-1 rounded hover:bg-muted transition-colors cursor-pointer flex-shrink-0"
                        title="Copy URL"
                    >
                        {copied and <Check size={11} className="text-success"/>}
                        {not copied and <Copy size={11} className="text-muted-foreground"/>}
                    </button>
                </div>
            </div>

            <div className="p-4 pt-0">
                <button
                    onClick={handleTestServer}
                    className="w-full flex items-center justify-center gap-2 bg-primary hover:bg-primary/90 text-primary-foreground font-semibold px-4 py-2.5 rounded-xl transition-all duration-200 cursor-pointer text-sm shadow-sm shadow-primary/20 hover:shadow-primary/30"
                >
                    <Play size={13}/>
                    Test Server
                </button>
            </div>
        </div>;
    }

    def:pub page -> JsxElement {
        has activeTransport: str = "all";
        has searchQuery: str = "";

        servers = [
            {
                "id": "github-copilot",
                "name": "GitHub Copilot",
                "namespace": "github.com",
                "transport": "http",
                "description": "Official GitHub Copilot MCP server. Access Copilot-powered AI capabilities via Streamable HTTP.",
                "url": "https://api.githubcopilot.com/mcp/",
                "auth": "bearer",
                "authRequired": True
            },
            {
                "id": "webzum",
                "name": "WebZum",
                "namespace": "webzum.com",
                "transport": "http",
                "description": "WebZum MCP server providing web-based tools and integrations via Streamable HTTP.",
                "url": "https://webzum.com/api/mcp",
                "auth": "none",
                "authRequired": False
            },
            {
                "id": "astro-docs",
                "name": "Astro Docs",
                "namespace": "docs.astro.build",
                "transport": "http",
                "description": "Official Astro documentation MCP server. Query and explore the full Astro framework documentation.",
                "url": "https://mcp.docs.astro.build/mcp",
                "auth": "none",
                "authRequired": False
            },
            {
                "id": "exa-search",
                "name": "Exa Search",
                "namespace": "exa.ai",
                "transport": "http",
                "description": "Exa AI-powered search MCP server. Perform semantic web searches and retrieve structured results.",
                "url": "https://mcp.exa.ai/mcp",
                "auth": "none",
                "authRequired": False
            },
            {
                "id": "hugging-face",
                "name": "Hugging Face",
                "namespace": "hf.co",
                "transport": "http",
                "description": "Official Hugging Face MCP server. Access models, datasets, and AI resources from the Hugging Face hub.",
                "url": "https://hf.co/mcp",
                "auth": "none",
                "authRequired": False
            },
            {
                "id": "remote-mcp",
                "name": "Remote MCP",
                "namespace": "remote-mcp.com",
                "transport": "http",
                "description": "Remote MCP server providing remote tool execution and integration capabilities via Streamable HTTP.",
                "url": "https://mcp.remote-mcp.com",
                "auth": "none",
                "authRequired": False
            },
            {
                "id": "manifold",
                "name": "Manifold",
                "namespace": "manifold.markets",
                "transport": "http",
                "description": "Manifold Markets MCP server. Access prediction market data, questions, and trading information.",
                "url": "https://api.manifold.markets/v0/mcp",
                "auth": "none",
                "authRequired": False
            },
            {
                "id": "javadocs",
                "name": "Javadocs",
                "namespace": "javadocs.dev",
                "transport": "http",
                "description": "Javadocs MCP server. Search and query Java API documentation from across the Java ecosystem.",
                "url": "https://www.javadocs.dev/mcp",
                "auth": "none",
                "authRequired": False
            },
            {
                "id": "ferryhopper",
                "name": "Ferryhopper",
                "namespace": "ferryhopper.com",
                "transport": "http",
                "description": "Ferryhopper MCP server. Access ferry routes, schedules, and booking data across the Mediterranean.",
                "url": "https://mcp.ferryhopper.com/mcp",
                "auth": "none",
                "authRequired": False
            }
        ];

        def serverMatchesFilter(s: Any) -> bool {
            if activeTransport != "all" and s.transport != activeTransport {
                return False;
            }
            q = searchQuery.trim().toLowerCase();
            if q and not s.name.toLowerCase().includes(q) and not s.description.toLowerCase().includes(q) and not s.namespace.toLowerCase().includes(q) {
                return False;
            }
            return True;
        }

        filteredServers = servers.filter(serverMatchesFilter);

        transportFilters = [["all", "All"], ["http", "HTTP"], ["sse", "SSE"], ["stdio", "STDIO"]];

        return <div className="min-h-[calc(100vh-3.5rem)] bg-background">
            <div className="max-w-screen-xl mx-auto px-6 py-10">

                <div className="mb-8">
                    <div className="flex items-center gap-3 mb-2">
                        <h1 className="text-2xl font-bold text-foreground">MCP Servers List</h1>
                        <span className="inline-flex items-center gap-1.5 text-xs font-medium text-success border border-success/20 bg-success/10 px-2.5 py-1 rounded-full">
                            <span className="w-1.5 h-1.5 rounded-full bg-success animate-pulse-dot"/>
                            Official Registry
                        </span>
                    </div>
                    <p className="text-sm text-muted-foreground max-w-3xl leading-relaxed">
                        {"Browse MCP servers from the "}
                        <span className="font-semibold text-foreground">official MCP Registry</span>
                        {". Find integrations for databases, dev tools, productivity, cloud services, and more. Test any server with a remote URL instantly."}
                    </p>
                </div>

                <div className="flex flex-col sm:flex-row gap-4 mb-6">
                    <div className="relative flex-1 max-w-sm">
                        <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground pointer-events-none"/>
                        <input
                            type="text"
                            value={searchQuery}
                            onChange={lambda(e: Any) -> None { searchQuery = e.target.value; }}
                            placeholder="Search MCP servers by name..."
                            className="w-full bg-background border border-input rounded-lg pl-9 pr-4 py-2.5 text-sm text-foreground placeholder-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring/50 focus:border-ring transition-colors"
                        />
                    </div>
                </div>

                <div className="flex items-center gap-3 mb-6 pb-6 border-b border-border">
                    <span className="text-xs font-medium text-muted-foreground uppercase tracking-wide">Transport</span>
                    <div className="flex items-center gap-1">
                        {transportFilters.map(lambda(item: Any) -> Any {
                            return <button
                                key={item[0]}
                                onClick={lambda -> None { activeTransport = item[0]; }}
                                className={f"px-3 py-1.5 rounded-lg text-xs font-medium transition-all cursor-pointer {
                                    'bg-primary/10 text-primary border border-primary/30' if activeTransport == item[0] else 'text-muted-foreground hover:text-foreground hover:bg-muted border border-transparent'
                                }"}
                            >{item[1]}</button>;
                        })}
                    </div>
                </div>

                <div className="flex items-center justify-between mb-5">
                    <p className="text-sm text-muted-foreground">
                        <span className="font-semibold text-foreground">{len(filteredServers)}</span>
                        {f" server{'s' if len(filteredServers) != 1 else ''}"}
                    </p>
                </div>

                {len(filteredServers) == 0 and
                    <div className="flex flex-col items-center justify-center py-24 text-center">
                        <div className="w-16 h-16 rounded-2xl bg-primary/5 border border-primary/10 flex items-center justify-center mb-4">
                            <Server size={26} className="text-primary/30"/>
                        </div>
                        <p className="text-foreground font-semibold mb-1">No servers found</p>
                        <p className="text-sm text-muted-foreground">Try adjusting your filters or search query</p>
                    </div>
                }

                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                    {filteredServers.map(lambda(server: Any) -> Any {
                        return <RegistryServerCard key={server.id} server={server}/>;
                    })}
                </div>
            </div>
        </div>;
    }
}
