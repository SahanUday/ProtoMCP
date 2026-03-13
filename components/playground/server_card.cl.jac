"""ServerCard – connected MCP server card for the playground overview."""

cl import from "@jac/runtime" { useNavigate }
cl import from "lucide-react" {
    Server, Wrench, MessageSquare, FolderOpen,
    Wifi, Radio, Trash2, ArrowRight
}

def:pub ServerCard(props: Any) -> JsxElement {
    conn = props.conn;
    onRemove = props.onRemove;
    navigate = useNavigate();

    statusConfig = {
        "connected": {"dot": "bg-success", "label": "Connected", "labelCls": "text-success bg-success/10 border-success/20"},
        "connecting": {"dot": "bg-warning animate-pulse", "label": "Connecting", "labelCls": "text-warning bg-warning/10 border-warning/20"},
        "error": {"dot": "bg-destructive", "label": "Error", "labelCls": "text-destructive bg-destructive/10 border-destructive/20"},
        "disconnected": {"dot": "bg-muted-foreground/40", "label": "Disconnected", "labelCls": "text-muted-foreground bg-muted border-border"}
    };

    cfg = statusConfig[conn.status] if conn.status in statusConfig else statusConfig.disconnected;
    transportLabel = "Streamable HTTP" if conn.transport == "streamable-http" else "SSE";
    transportIcon = <Wifi size={12}/> if conn.transport == "streamable-http" else <Radio size={12}/>;

    caps = conn.capabilities or {};
    toolCount = len(caps.tools or []);
    promptCount = len(caps.prompts or []);
    resourceCount = len(caps.resources or []);

    return <div
        className="group relative bg-card border border-border rounded-xl overflow-hidden hover:border-primary/30 hover:shadow-lg hover:shadow-primary/5 transition-all duration-300 cursor-pointer"
        onClick={lambda -> None { navigate(f"/playground/{conn.id}"); }}
    >
        <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-primary/60 via-primary/30 to-transparent opacity-0 group-hover:opacity-100 transition-opacity"/>

        <div className="p-5">
            <div className="flex items-start justify-between mb-4">
                <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-xl bg-primary/10 border border-primary/20 flex items-center justify-center group-hover:bg-primary/15 transition-colors">
                        <Server size={18} className="text-primary"/>
                    </div>
                    <div className="min-w-0">
                        <h3 className="text-sm font-semibold text-foreground truncate max-w-48">{conn.name}</h3>
                        <p className="text-xs text-muted-foreground truncate max-w-48 mt-0.5">{conn.url}</p>
                    </div>
                </div>
                <button
                    onClick={lambda(e: Any) -> None { e.stopPropagation(); onRemove(conn.id); }}
                    className="p-1.5 rounded-lg text-muted-foreground/30 hover:text-destructive hover:bg-destructive/10 transition-colors opacity-0 group-hover:opacity-100 cursor-pointer"
                    title="Remove server"
                >
                    <Trash2 size={13}/>
                </button>
            </div>

            <div className="flex items-center gap-2 mb-4">
                <span className={f"inline-flex items-center gap-1.5 text-xs font-medium px-2 py-1 rounded-full border {cfg.labelCls}"}>
                    <span className={f"w-1.5 h-1.5 rounded-full {cfg.dot}"}/>
                    {cfg.label}
                </span>
                <span className="inline-flex items-center gap-1 text-xs text-muted-foreground bg-muted px-2 py-1 rounded-full">
                    {transportIcon}
                    {transportLabel}
                </span>
            </div>

            {conn.status == "connected" and <div className="flex items-center gap-3 pt-3 border-t border-border">
                <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
                    <Wrench size={12} className="text-primary"/>
                    <span className="font-medium">{toolCount}</span>
                    <span>tools</span>
                </div>
                <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
                    <MessageSquare size={12} className="text-info"/>
                    <span className="font-medium">{promptCount}</span>
                    <span>prompts</span>
                </div>
                <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
                    <FolderOpen size={12} className="text-warning"/>
                    <span className="font-medium">{resourceCount}</span>
                    <span>resources</span>
                </div>
            </div>}

            {conn.status != "connected" and <div className="flex items-center gap-2 pt-3 border-t border-border">
                <span className="text-xs text-muted-foreground">Click to open playground</span>
                <ArrowRight size={12} className="text-muted-foreground/50"/>
            </div>}
        </div>
    </div>;
}
