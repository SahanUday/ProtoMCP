"""Playground – connected MCP servers overview with cards."""

cl import from "@jac/runtime" { Link, useNavigate }
cl import from "lucide-react" { Plus }
cl import from ...store.mcp_store { useMcpStore }
cl import from ...components.playground.server_card { ServerCard }

cl {
    def:pub page -> JsxElement {
        connections = useMcpStore(lambda(s: Any) -> Any { return s.connections; });
        removeConnection = useMcpStore(lambda(s: Any) -> Any { return s.removeConnection; });
        navigate = useNavigate();

        if len(connections) == 0 {
            return <div className="min-h-[calc(100vh-3.5rem)] bg-background relative overflow-hidden">
                <div className="absolute inset-0 bg-grid-pattern opacity-20"/>
                <div className="absolute top-1/3 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[500px] h-[500px] bg-primary/5 rounded-full blur-[120px]"/>

                <div className="relative flex flex-col items-center justify-center min-h-[calc(100vh-3.5rem)] gap-6 px-6">
                    <div className="w-20 h-20 rounded-2xl bg-primary/5 border border-primary/10 flex items-center justify-center">
                        <img src="static/assets/mcp.png" alt="MCP" className="w-10 h-10 opacity-30"/>
                    </div>
                    <div className="text-center max-w-md">
                        <h1 className="text-2xl font-bold text-foreground mb-2">No servers connected</h1>
                        <p className="text-muted-foreground leading-relaxed">
                            {"Connect to an MCP server to explore its tools, prompts, and resources. "}
                            {"Your connected servers will appear here."}
                        </p>
                    </div>
                    <Link
                        to="/testmcp"
                        className="inline-flex items-center gap-2 bg-primary hover:bg-primary/90 text-primary-foreground font-semibold px-6 py-3 rounded-xl transition-all shadow-lg shadow-primary/25 hover:shadow-primary/40 hover:scale-[1.02]"
                    >
                        <Plus size={16}/>
                        Add MCP Server
                    </Link>
                </div>
            </div>;
        }

        return <div className="min-h-[calc(100vh-3.5rem)] bg-background">
            <div className="max-w-5xl mx-auto px-6 py-8">
                <div className="flex items-center justify-between mb-8">
                    <div>
                        <h1 className="text-2xl font-bold text-foreground">MCP Servers</h1>
                        <p className="text-sm text-muted-foreground mt-1">{len(connections)} connected server{"s" if len(connections) != 1 else ""}</p>
                    </div>
                    <Link
                        to="/testmcp"
                        className="inline-flex items-center gap-2 bg-primary hover:bg-primary/90 text-primary-foreground font-medium px-4 py-2.5 rounded-xl transition-colors shadow-sm shadow-primary/20 cursor-pointer"
                    >
                        <Plus size={14}/>
                        Add Server
                    </Link>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                    {connections.map(lambda(conn: Any) -> Any {
                        return <ServerCard key={conn.id} conn={conn} onRemove={removeConnection}/>;
                    })}
                </div>
            </div>
        </div>;
    }
}
