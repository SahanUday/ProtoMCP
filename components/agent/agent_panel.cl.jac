"""AgentPanel – full-width agent mode panel.

Layout (top → bottom):
  Single bar  – [Config dropdown ▼] left | [Chat][Trace] tabs right
  Content     – ChatPanel (flex-1) or AgentTracePanel (flex-1)

The config dropdown is absolute-positioned so it overlays the content
area and never competes with ChatPanel for flex height (fixes scroll).
"""

cl import from "lucide-react" { MessageSquare, Activity }
cl import from ..agent.llm_config { LlmConfigPanel }
cl import from ..agent.chat_panel { ChatPanel }
cl import from ..agent.agent_trace { AgentTracePanel }

def:pub AgentPanel(props: Any) -> JsxElement {
    connection = props.connection;

    has activeTab: str = "chat";

    return <div className="flex-1 flex flex-col min-h-0">
        <div className="flex items-center justify-between px-3 py-2 border-b border-border bg-card/40 flex-shrink-0">
            <LlmConfigPanel/>
            <div className="flex items-center gap-0.5 bg-muted/50 rounded-lg p-0.5 flex-shrink-0">
                <button
                    onClick={lambda -> None { activeTab = "chat"; }}
                    className={f"flex items-center gap-1.5 text-xs font-medium px-3 py-1 rounded-md transition-colors cursor-pointer {
                        'bg-background text-foreground shadow-sm' if activeTab == 'chat' else 'text-muted-foreground hover:text-foreground'
                    }"}
                >
                    <MessageSquare size={11}/>
                    Chat
                </button>
                <button
                    onClick={lambda -> None { activeTab = "trace"; }}
                    className={f"flex items-center gap-1.5 text-xs font-medium px-3 py-1 rounded-md transition-colors cursor-pointer {
                        'bg-background text-foreground shadow-sm' if activeTab == 'trace' else 'text-muted-foreground hover:text-foreground'
                    }"}
                >
                    <Activity size={11}/>
                    Trace
                </button>
            </div>
        </div>

        <div className="flex-1 overflow-hidden min-h-0 flex flex-col">
            {activeTab == "chat" and <ChatPanel connection={connection}/>}
            {activeTab == "trace" and <AgentTracePanel/>}
        </div>
    </div>;
}
