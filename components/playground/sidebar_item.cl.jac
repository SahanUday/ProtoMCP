"""SidebarItem – server entry in the playground sidebar."""

cl import from "lucide-react" { Trash2 }

def:pub SidebarItem(props: Any) -> JsxElement {
    conn = props.conn;
    isActive = props.isActive or False;
    onSelect = props.onSelect;
    onRemove = props.onRemove;

    statusColors = {
        "connected": "bg-success",
        "connecting": "bg-warning animate-pulse",
        "error": "bg-destructive",
        "disconnected": "bg-muted-foreground/40"
    };
    dotCls = statusColors[conn.status] if conn.status in statusColors else statusColors.disconnected;
    transportLabel = "HTTP" if conn.transport == "streamable-http" else "SSE";

    caps = conn.capabilities or {};
    totalCaps = len(caps.tools or []) + len(caps.prompts or []) + len(caps.resources or []);

    return <div
        className={f"flex items-center gap-2.5 px-3 py-2.5 rounded-xl cursor-pointer transition-all group {
            'bg-primary/10 border border-primary/20 shadow-sm shadow-primary/5' if isActive else 'hover:bg-muted/60 border border-transparent'
        }"}
        onClick={onSelect}
    >
        <span className={f"w-2 h-2 rounded-full flex-shrink-0 {dotCls}"}/>
        <div className="flex-1 min-w-0">
            <p className="text-sm font-medium text-foreground truncate">{conn.name}</p>
            <p className="text-xs text-muted-foreground truncate mt-0.5">{conn.url}</p>
        </div>
        <div className="flex items-center gap-1.5 flex-shrink-0" onClick={lambda(e: Any) -> None { e.stopPropagation(); }}>
            <span className="text-xs text-muted-foreground bg-muted px-1.5 py-0.5 rounded">{transportLabel}</span>
            {conn.status == "connected" and totalCaps > 0 and <span className="text-xs text-primary bg-primary/10 px-1.5 py-0.5 rounded">{totalCaps}</span>}
            <button
                onClick={onRemove}
                className="text-muted-foreground/30 hover:text-destructive p-1 rounded-lg hover:bg-muted transition-colors opacity-0 group-hover:opacity-100 cursor-pointer"
                title="Remove server"
            >
                <Trash2 size={12}/>
            </button>
        </div>
    </div>;
}
