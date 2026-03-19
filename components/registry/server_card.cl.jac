"""RegistryServerCard – card component for MCP server registry listing."""

cl import from "@jac/runtime" { useNavigate }
cl import from "lucide-react" { Server, Globe, Shield, Copy, Play, Check }

def:pub RegistryServerCard(props: Any) -> JsxElement {
    server = props.server;
    navigate = useNavigate();
    has copied: bool = False;

    def handleTestServer -> None {
        transportParam = "streamable-http" if server.transport == "http" else server.transport;
        params = f"url={encodeURIComponent(server.url)}&transport={transportParam}&auth={server.auth}&name={encodeURIComponent(server.name)}";
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

    authColors = {
        "none":    "text-success bg-success/10 border-success/20",
        "bearer":  "text-warning bg-warning/10 border-warning/20",
        "apikey":  "text-info bg-info/10 border-info/20",
        "basic":   "text-muted-foreground bg-muted border-border"
    };
    authLabels = {
        "none":   "NoAuth",
        "bearer": "Bearer",
        "apikey": "API Key",
        "basic":  "Basic"
    };
    authCls   = authColors[server.auth] if server.auth in authColors else authColors["none"];
    authLabel = authLabels[server.auth] if server.auth in authLabels else "Auth";

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
                        <span className={f"text-xs font-medium px-2 py-0.5 rounded-full border {authCls}"}>{authLabel}</span>
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
