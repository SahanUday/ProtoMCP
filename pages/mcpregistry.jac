"""MCP Servers List – browse and discover available MCP servers from the registry."""

cl import from "lucide-react" { Server, Search }
cl import from ..data.mcp_servers { getMcpServers }
cl import from ..components.registry.server_card { RegistryServerCard }

cl {
    def:pub page -> JsxElement {
        has activeTransport: str = "all";
        has searchQuery: str = "";

        servers = getMcpServers();

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
