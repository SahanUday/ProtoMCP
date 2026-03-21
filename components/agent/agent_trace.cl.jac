"""AgentTracePanel – timeline viewer for agent loop events."""

cl import from "react" { useState }
cl import from "lucide-react" {
    Bot,
    User,
    Wrench,
    CheckCircle2,
    AlertTriangle,
    Clock,
    ChevronDown,
    ChevronRight,
    Zap,
    Hash,
    Trash2,
    Brain,
    CheckCheck,
    Radio
}
cl import from ...store.llm_store { useLlmStore }
cl import from ...components.ui.json_viewer { JsonViewer }


def TraceEvent(props: Any) -> JsxElement {
    evt = props.evt;
    prevTimestamp = props.prevTimestamp;
    has evtExpanded: bool = False;

    evtType = evt.type;
    data = evt.data or {};

    # Elapsed time since last event
    elapsed = "";
    if prevTimestamp and evt.timestamp {
        diff = evt.timestamp - prevTimestamp;
        if diff >= 1000 {
            elapsed = String(Math.round(diff / 1000 * 10) / 10) + "s";
        } else {
            elapsed = String(diff) + "ms";
        }
    }

    # Config per event type (includes new byllm StreamEvent types)
    config = {
        "user_message": {
            "icon": <User size={12}/>,
            "color": "text-primary",
            "bg": "bg-primary/10",
            "label": "User"
        },
        "llm_call_start": {
            "icon": <Zap size={12}/>,
            "color": "text-info",
            "bg": "bg-info/10",
            "label": "LLM Call"
        },
        "llm_response": {
            "icon": <Bot size={12}/>,
            "color": "text-info",
            "bg": "bg-info/10",
            "label": "LLM Response"
        },
        "tool_call": {
            "icon": <Wrench size={12}/>,
            "color": "text-primary",
            "bg": "bg-primary/10",
            "label": "Tool Call"
        },
        "tool_result": {
            "icon": <CheckCircle2 size={12}/>,
            "color": "text-success",
            "bg": "bg-success/10",
            "label": "Tool Result"
        },
        "error": {
            "icon": <AlertTriangle size={12}/>,
            "color": "text-destructive",
            "bg": "bg-destructive/10",
            "label": "Error"
        },
        "final_response": {
            "icon": <Bot size={12}/>,
            "color": "text-success",
            "bg": "bg-success/10",
            "label": "Final Response"
        },
        # ── byllm StreamEvent types ───────────────────────────────────────────
        "thought": {
            "icon": <Brain size={12}/>,
            "color": "text-warning",
            "bg": "bg-warning/10",
            "label": "Thinking"
        },
        "steps_done": {
            "icon": <CheckCheck size={12}/>,
            "color": "text-success",
            "bg": "bg-success/10",
            "label": "Steps Done"
        },
        "response_chunk": {
            "icon": <Radio size={12}/>,
            "color": "text-muted-foreground",
            "bg": "bg-muted",
            "label": "Streaming"
        },
        "usage": {
            "icon": <Hash size={12}/>,
            "color": "text-muted-foreground",
            "bg": "bg-muted",
            "label": "Usage"
        }
    };

    c = config[evtType]
        if evtType in config
        else {
            "icon": <Hash size={12}/>,
            "color": "text-muted-foreground",
            "bg": "bg-muted",
            "label": evtType
        };

    # Summary text
    summary = "";
    if evtType == "user_message" {
        content = data.content or "";
        summary = content.length > 60 and content.substring(0, 60) + "..." or content;
    } elif evtType == "llm_call_start" {
        summary = (data.model or "unknown") + " (iter " + String(
            data.iteration or 1
        ) + ", " + String(data.toolCount or 0) + " tools)";
    } elif evtType == "llm_response" {
        tokens = data.usage.total_tokens if data.usage else 0;
        summary = (data.finish_reason or "done") + (
            tokens > 0 and " · " + String(tokens) + " tokens" or ""
        );
    } elif evtType == "tool_call" {
        summary = (data.name or "?") + "(" + JSON.stringify(
            data.arguments or {}
        ).substring(
            0, 50
        ) + ")";
    } elif evtType == "tool_result" {
        result = data.result or "";
        summary = (data.name or "?") + " → " + (
            result.length > 40 and result.substring(0, 40) + "..." or result
        );
    } elif evtType == "error" {
        summary = data.error or "Unknown error";
    } elif evtType == "final_response" {
        finalContent = data.content or "";
        summary = finalContent.length > 60
        and finalContent.substring(0, 60) + "..."
        or finalContent;
    } elif evtType == "thought" {
        thoughtContent = data.content or "";
        summary = thoughtContent.length > 60
        and thoughtContent.substring(0, 60) + "..."
        or thoughtContent;
    } elif evtType == "steps_done" {
        summary = String(data.iterations or 0) + " ReAct step(s) completed";
    } elif evtType == "response_chunk" {
        summary = "streaming…";
    } elif evtType == "usage" {
        usage = data.usage or {};
        summary = "prompt " + String(usage.prompt_tokens or 0) + " · completion " + String(
            usage.completion_tokens or 0
        ) + " · total " + String(usage.total_tokens or 0);
    }

    return
        <div className="relative">
            {elapsed
            and <div className="flex items-center gap-1.5 pl-6 py-0.5">
                <Clock size={9} className="text-muted-foreground/30"/>
                <span className="text-xs text-muted-foreground/30">
                    {elapsed}
                </span>
            </div>}
            <button
                onClick={lambda -> None { evtExpanded = not evtExpanded;}}
                className="w-full flex items-start gap-2 px-2 py-1.5 rounded-lg hover:bg-muted/30 transition-colors cursor-pointer text-left"
            >
                <div
                    className={f"w-5 h-5 rounded-md flex items-center justify-center flex-shrink-0 {c.bg}"}
                >
                    <span className={c.color}>
                        {c.icon}
                    </span>
                </div>
                <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-1.5">
                        <span className={f"text-xs font-medium {c.color}"}>
                            {c.label}
                        </span>
                        {data.iteration
                        and <span className="text-xs text-muted-foreground/40">
                            #{data.iteration}
                        </span>}
                    </div>
                    <p className="text-xs text-muted-foreground truncate mt-0.5">
                        {summary}
                    </p>
                </div>
                <span className="flex-shrink-0 mt-1">
                    {evtExpanded
                    and <ChevronDown
                        size={11}
                        className="text-muted-foreground/40"
                    />
                    or <ChevronRight size={11} className="text-muted-foreground/40"/>}
                </span>
            </button>
            {evtExpanded
            and <div
                className="ml-7 mr-2 mb-2 p-2 bg-muted/20 border border-border/50 rounded-lg"
            >
                <JsonViewer data={data} collapsed={2} maxHeight="200px"/>
            </div>}
        </div>;
}

def:pub AgentTracePanel -> JsxElement {
    agentTrace = useLlmStore(lambda (s: Any) -> Any { return s.agentTrace; });
    clearAgentTrace = useLlmStore(lambda (s: Any) -> Any { return s.clearAgentTrace; });
    totalTokenUsage = useLlmStore(lambda (s: Any) -> Any { return s.totalTokenUsage; });

    return
        <div className="flex flex-col h-full overflow-hidden">
            <div
                className="flex items-center justify-between px-3 py-2 border-b border-border flex-shrink-0"
            >
                <div className="flex items-center gap-2">
                    <span className="text-xs font-semibold text-foreground">
                        Agent Trace
                    </span>
                    {len(agentTrace) > 0
                    and <span
                        className="text-xs bg-primary/10 text-primary px-1.5 py-0.5 rounded-full font-medium"
                    >
                        {len(agentTrace)}
                    </span>}
                </div>
                <div className="flex items-center gap-2">
                    {totalTokenUsage.total > 0
                    and <span className="text-xs text-muted-foreground/50">
                        {totalTokenUsage.total.toLocaleString()} tok
                    </span>}{len(agentTrace) > 0
                    and <button
                        onClick={clearAgentTrace}
                        className="text-muted-foreground/30 hover:text-destructive p-1 rounded transition-colors cursor-pointer"
                        title="Clear trace"
                    >
                        <Trash2 size={11}/>
                    </button>}
                </div>
            </div>
            <div className="flex-1 overflow-y-auto p-2">
                {len(agentTrace) == 0
                and <div
                    className="flex flex-col items-center justify-center h-full gap-2 text-muted-foreground/40"
                >
                    <Zap size={16}/>
                    <span className="text-xs">
                        No trace events yet
                    </span>
                </div>}{agentTrace.map(
                    lambda (evt: Any, idx: Any) -> Any { prevTs = agentTrace[
                        idx - 1
                    ].timestamp
                        if idx > 0
                        else None;return
                        <TraceEvent key={idx} evt={evt} prevTimestamp={prevTs}/>; }
                )}
            </div>
        </div>;
}
