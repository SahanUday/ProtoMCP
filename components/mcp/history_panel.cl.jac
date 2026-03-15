"""HistoryPanel – request/response log (Logs) with timing and status badges."""

cl import from "lucide-react" { ScrollText, Trash2, ChevronDown, ChevronRight, Clock, CheckCircle, XCircle, Loader, Filter }
cl import from ..ui.json_viewer { JsonViewer }
cl import from ...store.mcp_store { useMcpStore }

def HistoryEntry(props: Any) -> JsxElement {
    hist_entry = props.entry;

    has expanded: bool = False;

    statusIcon = {
        "success": <CheckCircle size={13} className="text-success"/>,
        "error": <XCircle size={13} className="text-destructive"/>,
        "pending": <Loader size={13} className="text-warning animate-spin"/>
    };

    statusBg = {
        "success": "border-success/10 hover:border-success/20",
        "error": "border-destructive/10 hover:border-destructive/20",
        "pending": "border-warning/10 hover:border-warning/20"
    };

    entryStatus = hist_entry.status if hist_entry else "pending";
    entryIcon = statusIcon.success if entryStatus == "success" else (statusIcon.error if entryStatus == "error" else statusIcon.pending);
    entryBgCls = statusBg.success if entryStatus == "success" else (statusBg.error if entryStatus == "error" else statusBg.pending);
    entryStatusCls = "text-success" if entryStatus == "success" else ("text-destructive" if entryStatus == "error" else "text-warning");
    entryTimestamp = hist_entry.timestamp or "";
    entryServerName = hist_entry.serverName or "";
    entryDuration = hist_entry.durationMs;

    return <div className={f"border rounded-lg overflow-hidden text-xs transition-colors {entryBgCls}"}>
        <button
            className="w-full flex items-center gap-2 px-3 py-2 bg-card/30 hover:bg-card/60 transition-colors text-left cursor-pointer"
            onClick={lambda -> None { expanded = not expanded; }}
        >
            {entryIcon}
            <span className="flex-1 font-mono text-foreground/80 truncate">{hist_entry.method}</span>
            {entryDuration and <span className="flex items-center gap-0.5 text-muted-foreground/60"><Clock size={9}/>{entryDuration}ms</span>}
            {<ChevronDown size={11} className="text-muted-foreground/40 flex-shrink-0"/> if expanded else <ChevronRight size={11} className="text-muted-foreground/40 flex-shrink-0"/>}
        </button>

        {expanded and <div className="border-t border-border/50 bg-background/30 p-3 flex flex-col gap-3">
            <div className="flex items-center gap-2 text-muted-foreground/50 text-xs">
                <span>{entryTimestamp}</span>
                {entryServerName and <span className="truncate">· {entryServerName}</span>}
            </div>

            <div>
                <p className="text-muted-foreground mb-1 font-medium text-xs">Request</p>
                <JsonViewer data={hist_entry.request} maxHeight="150px"/>
            </div>

            {hist_entry.response and <div>
                <p className={f"mb-1 font-medium text-xs {entryStatusCls}"}>Response</p>
                <JsonViewer data={hist_entry.response} maxHeight="200px"/>
            </div>}

            {hist_entry.status == "pending" and <p className="text-warning text-xs italic">Waiting for response...</p>}
        </div>}
    </div>;
}

def:pub HistoryPanel(props: Any) -> JsxElement {
    history = useMcpStore(lambda(s: Any) -> Any { return s.history; });
    clearHistory = useMcpStore(lambda(s: Any) -> Any { return s.clearHistory; });

    has filter: str = "all";

    filtered = history if filter == "all" else history.filter(lambda(e: Any) -> Any {
        return e.status == filter;
    });

    return <div className="flex flex-col h-full">
        <div className="flex items-center justify-between px-4 py-3 border-b border-border flex-shrink-0">
            <div className="flex items-center gap-2">
                <ScrollText size={14} className="text-primary"/>
                <span className="text-sm font-semibold text-foreground">Logs</span>
                {len(history) > 0 and <span className="text-xs bg-primary/10 text-primary px-1.5 py-0.5 rounded-full font-medium">{len(history)}</span>}
            </div>
            <div className="flex items-center gap-1.5">
                <select
                    value={filter}
                    onChange={lambda(e: Any) -> None { filter = e.target.value; }}
                    className="bg-background border border-border rounded-lg text-xs text-foreground px-2 py-1 focus:outline-none cursor-pointer"
                >
                    <option value="all">All</option>
                    <option value="success">Success</option>
                    <option value="error">Errors</option>
                    <option value="pending">Pending</option>
                </select>
                {len(history) > 0 and <button
                    onClick={clearHistory}
                    className="text-muted-foreground/40 hover:text-destructive p-1 rounded-lg hover:bg-muted transition-colors cursor-pointer"
                    title="Clear logs"
                >
                    <Trash2 size={12}/>
                </button>}
            </div>
        </div>

        <div className="flex-1 overflow-y-auto p-2 flex flex-col gap-1.5">
            {len(filtered) == 0 and <div className="flex flex-col items-center justify-center py-12 gap-2 text-muted-foreground">
                <div className="w-10 h-10 rounded-xl bg-muted/50 flex items-center justify-center">
                    <ScrollText size={18} className="text-muted-foreground/25"/>
                </div>
                <p className="text-xs font-medium text-muted-foreground/60">No logs yet</p>
                <p className="text-xs text-muted-foreground/40">Requests will appear here</p>
            </div>}
            {len(filtered) > 0 and filtered.map(lambda(hist_entry: Any) -> Any {
                return <HistoryEntry key={hist_entry.id} entry={hist_entry}/>;
            })}
        </div>
    </div>;
}
