"""AgentPanel – full-width agent mode panel."""

cl import from "react" { useRef }
cl import from "lucide-react" { MessageSquare, Activity, Clock, Plus, Trash2, X }
cl import from ..agent.llm_config { LlmConfigPanel }
cl import from ..agent.chat_panel { ChatPanel }
cl import from ..agent.agent_trace { AgentTracePanel }
cl import from ...store.llm_store { useLlmStore }
cl import from ...hooks.useAgentLoop { useAgentLoop }

# ── Session History Item ───────────────────────────────────────────────────────
def SessionHistoryItem(props: Any) -> JsxElement {
    sess = props.sess;
    onLoad = props.onLoad;
    onDelete = props.onDelete;
    onClose = props.onClose;

    def handleLoad -> None {
        onLoad(sess.messages, sess.trace, sess.tokenUsage, sess.id, sess.title);
        onClose();
    }
    def handleDelete -> None {
        onDelete(sess.id);
    }

    return
        <div
            className="flex items-center gap-2 px-3 py-2 hover:bg-muted/50 group border-b border-border/50 last:border-0"
        >
            <button
                onClick={handleLoad}
                className="flex-1 text-left min-w-0 cursor-pointer"
            >
                <p className="text-xs font-medium text-foreground truncate">
                    {sess.title or sess.id}
                </p>
            </button>
            <button
                onClick={handleDelete}
                className="flex-shrink-0 text-muted-foreground/40 hover:text-destructive p-1 rounded transition-colors opacity-0 group-hover:opacity-100 cursor-pointer"
                title="Delete session"
            >
                <Trash2 size={11}/>
            </button>
        </div>;
}


# ── Session History Panel ──────────────────────────────────────────────────────
def SessionHistoryPanel(props: Any) -> JsxElement {
    sessions = props.sessions;
    onLoad = props.onLoad;
    onDelete = props.onDelete;
    onClose = props.onClose;

    return
        <div
            className="absolute top-[41px] left-0 z-50 w-72 bg-popover border border-border rounded-xl shadow-lg overflow-hidden"
        >
            <div
                className="flex items-center justify-between px-3 py-2 border-b border-border"
            >
                <span className="text-xs font-semibold text-foreground">
                    Session History
                </span>
                <button
                    onClick={onClose}
                    className="text-muted-foreground hover:text-foreground p-0.5 rounded cursor-pointer transition-colors"
                >
                    <X size={12}/>
                </button>
            </div>
            {sessions.length == 0
            and <div className="px-3 py-4 text-xs text-muted-foreground text-center">
                No previous sessions
            </div>}
            <div className="max-h-64 overflow-y-auto">
                {sessions.map(
                    lambda (sess: Any, idx: Any) -> Any { return
                        <SessionHistoryItem
                            key={sess.id}
                            sess={sess}
                            onLoad={onLoad}
                            onDelete={onDelete}
                            onClose={onClose}
                        />; }
                )}
            </div>
        </div>;
}


# ── Main Panel ────────────────────────────────────────────────────────────────
def:pub AgentPanel(props: Any) -> JsxElement {
    connection = props.connection;
    has activeTab: str = "chat";
    has showHistory: bool = False;

    sessionHistory = useLlmStore(lambda (s: Any) -> Any { return s.sessionHistory; });
    agentLoop = useAgentLoop();

    def handleNewSession -> None {
        agentLoop.newSession();
        showHistory = False;
    }
    def handleCloseHistory -> None {
        showHistory = False;
    }

    return
        <div className="flex-1 flex flex-col min-h-0 relative">
            <div
                className="flex items-center justify-between px-3 py-2 border-b border-border bg-card/40 flex-shrink-0"
            >
                <div className="flex items-center gap-1">
                    <LlmConfigPanel/>
                    <button
                        onClick={lambda -> None { showHistory = not showHistory;}}
                        className={f"flex items-center gap-1 text-xs px-2 py-1 rounded-md transition-colors cursor-pointer {'bg-muted text-foreground'
                            if showHistory
                            else 'text-muted-foreground hover:text-foreground hover:bg-muted/50'}"}
                        title="Session history"
                    >
                        <Clock size={12}/>
                        {sessionHistory.length > 0
                        and <span className="text-xs tabular-nums ml-0.5">
                            {sessionHistory.length}
                        </span>}
                    </button>
                    <button
                        onClick={handleNewSession}
                        className="flex items-center gap-1 text-xs text-muted-foreground hover:text-foreground px-2 py-1 rounded-md hover:bg-muted/50 transition-colors cursor-pointer"
                        title="New session"
                    >
                        <Plus size={12}/>
                    </button>
                </div>
                <div
                    className="flex items-center gap-0.5 bg-muted/50 rounded-lg p-0.5 flex-shrink-0"
                >
                    <button
                        onClick={lambda -> None { activeTab = "chat";}}
                        className={f"flex items-center gap-1.5 text-xs font-medium px-3 py-1 rounded-md transition-colors cursor-pointer {'bg-background text-foreground shadow-sm'
                            if activeTab == 'chat'
                            else 'text-muted-foreground hover:text-foreground'}"}
                    >
                        <MessageSquare size={11}/>
                        Chat
                    </button>
                    <button
                        onClick={lambda -> None { activeTab = "trace";}}
                        className={f"flex items-center gap-1.5 text-xs font-medium px-3 py-1 rounded-md transition-colors cursor-pointer {'bg-background text-foreground shadow-sm'
                            if activeTab == 'trace'
                            else 'text-muted-foreground hover:text-foreground'}"}
                    >
                        <Activity size={11}/>
                        Trace
                    </button>
                </div>
            </div>
            {showHistory
            and <SessionHistoryPanel
                sessions={sessionHistory}
                onLoad={agentLoop.loadSession}
                onDelete={agentLoop.deleteHistorySession}
                onClose={handleCloseHistory}
            />}
            <div className="flex-1 overflow-hidden min-h-0 flex flex-col">
                {activeTab == "chat"
                and <ChatPanel connection={connection} agentLoop={agentLoop}/>}{activeTab == "trace"
                and <AgentTracePanel/>}
            </div>
        </div>;
}
