"""ChatPanel – chat message thread with inline tool traces for agentic mode."""

cl import from "react" { useEffect, useRef, useState }
cl import from "lucide-react" {
    Send,
    StopCircle,
    Wrench,
    Bot,
    User,
    AlertTriangle,
    Trash2,
    Loader2,
    CheckCircle2,
    ChevronDown,
    ChevronRight,
    Copy,
    Check,
    ShieldCheck,
    ShieldX
}
cl import from ...store.llm_store { useLlmStore }
cl import from ...components.ui.json_viewer { JsonViewer }
cl import from ...components.ui.markdown_renderer { MarkdownRenderer }

# ── Tool Call Card ──────────────────────────────────────────────────────
def ToolCallCard(props: Any) -> JsxElement {
    tc = props.toolCall;
    has tcExpanded: bool = True;

    parsedArgs = {};
    try {
        parsedArgs = JSON.parse(tc.function.arguments);
    } except Exception {
        parsedArgs = {"raw": tc.function.arguments};
    }

    return
        <div
            className="flex items-start gap-2 p-3 bg-primary/5 border border-primary/15 rounded-lg"
        >
            <div
                className="w-6 h-6 rounded-md bg-primary/10 flex items-center justify-center flex-shrink-0 mt-0.5"
            >
                <Wrench size={12} className="text-primary"/>
            </div>
            <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2">
                    <button
                        onClick={lambda -> None { tcExpanded = not tcExpanded;}}
                        className="flex items-center gap-1 cursor-pointer"
                    >
                        {tcExpanded
                        and <ChevronDown
                            size={12}
                            className="text-muted-foreground"
                        />
                        or <ChevronRight size={12} className="text-muted-foreground"/>}
                        <span className="text-xs font-semibold font-mono text-primary">
                            {tc.function.name}
                        </span>
                    </button>
                    <span className="text-xs text-muted-foreground/50">
                        call
                    </span>
                </div>
                {tcExpanded
                and <div className="mt-2">
                    <JsonViewer data={parsedArgs} collapsed={1} maxHeight="150px"/>
                </div>}
            </div>
        </div>;
}

# ── Tool Result Card ────────────────────────────────────────────────────
def ToolResultCard(props: Any) -> JsxElement {
    msg = props.msg;
    has trExpanded: bool = False;

    parsedResult = {};
    try {
        parsedResult = JSON.parse(msg.content);
    } except Exception {
        parsedResult = {"raw": msg.content};
    }

    # Detect error
    isError = parsedResult and parsedResult.error;
    borderCls = "border-destructive/15 bg-destructive/5"
        if isError
        else "border-success/15 bg-success/5";
    iconCls = "text-destructive" if isError else "text-success";

    return
        <div
            className={f"ml-8 flex items-start gap-2 p-3 rounded-lg border {borderCls}"}
        >
            <div className="flex-shrink-0 mt-0.5">
                {isError
                and <AlertTriangle size={12} className={iconCls}/>
                or <CheckCircle2 size={12} className={iconCls}/>}
            </div>
            <div className="flex-1 min-w-0">
                <button
                    onClick={lambda -> None { trExpanded = not trExpanded;}}
                    className="flex items-center gap-1 cursor-pointer"
                >
                    {trExpanded
                    and <ChevronDown size={12} className="text-muted-foreground"/>
                    or <ChevronRight size={12} className="text-muted-foreground"/>}
                    <span
                        className={f"text-xs font-medium {isError
                        and 'text-destructive'
                        or 'text-success'}"}
                    >
                        {isError and "Error" or "Result"}
                    </span>
                    <span
                        className="text-xs text-muted-foreground/50 truncate max-w-xs"
                    >
                        {msg.content.length > 80
                        and msg.content.substring(0, 80) + "..."
                        or msg.content}
                    </span>
                </button>
                {trExpanded
                and <div className="mt-2">
                    <JsonViewer data={parsedResult} collapsed={2} maxHeight="250px"/>
                </div>}
            </div>
        </div>;
}

# ── Message Bubble ──────────────────────────────────────────────────────
def ChatMessage(props: Any) -> JsxElement {
    msg = props.msg;
    idx = props.idx;

    # User message
    if msg.role == "user" {
        return
            <div className="flex justify-end gap-2 mb-3">
                <div
                    className="max-w-[80%] bg-primary/10 border border-primary/15 rounded-2xl rounded-br-md px-4 py-2.5"
                >
                    <p className="text-sm text-foreground whitespace-pre-wrap">
                        {msg.content}
                    </p>
                </div>
                <div
                    className="w-7 h-7 rounded-full bg-primary/10 flex items-center justify-center flex-shrink-0 mt-0.5"
                >
                    <User size={13} className="text-primary"/>
                </div>
            </div>;
    }

    # Assistant message with tool calls
    if msg.role == "assistant" and msg.tool_calls and len(msg.tool_calls) > 0 {
        return
            <div className="flex gap-2 mb-3">
                <div
                    className="w-7 h-7 rounded-full bg-info/10 flex items-center justify-center flex-shrink-0 mt-0.5"
                >
                    <Bot size={13} className="text-info"/>
                </div>
                <div className="max-w-[85%] space-y-2">
                    {msg.content
                    and <div
                        className="bg-card border border-border rounded-2xl rounded-bl-md px-4 py-2.5"
                    >
                        <MarkdownRenderer content={msg.content}/>
                    </div>}
                    <div
                        className="flex items-center gap-1.5 text-xs text-muted-foreground px-1"
                    >
                        <Wrench size={11}/>
                        <span>
                            Calling{len(msg.tool_calls)} tool{len(
                                msg.tool_calls
                            ) > 1
                            and "s"
                            or ""}...
                        </span>
                    </div>
                    {msg.tool_calls.map(
                        lambda (tc: Any) -> Any { return
                            <ToolCallCard key={tc.id} toolCall={tc}/>; }
                    )}
                </div>
            </div>;
    }

    # Assistant text-only message
    if msg.role == "assistant" {
        return
            <div className="flex gap-2 mb-3">
                <div
                    className="w-7 h-7 rounded-full bg-info/10 flex items-center justify-center flex-shrink-0 mt-0.5"
                >
                    <Bot size={13} className="text-info"/>
                </div>
                <div
                    className="max-w-[85%] bg-card border border-border rounded-2xl rounded-bl-md px-4 py-2.5"
                >
                    <MarkdownRenderer content={msg.content}/>
                </div>
            </div>;
    }

    # Tool result message
    if msg.role == "tool" {
        return
            <div className="mb-2">
                <ToolResultCard msg={msg}/>
            </div>;
    }

    # System message (errors, info)
    if msg.role == "system" {
        return
            <div className="flex justify-center mb-3">
                <div
                    className="flex items-center gap-2 bg-warning/5 border border-warning/15 rounded-full px-4 py-1.5"
                >
                    <AlertTriangle size={12} className="text-warning"/>
                    <span className="text-xs text-warning">
                        {msg.content}
                    </span>
                </div>
            </div>;
    }

    return
        <></>;
}

# ── Tool Confirmation Modal ──────────────────────────────────────────────
def ToolConfirmModal(props: Any) -> JsxElement {
    pending = props.pending;
    onApprove = props.onApprove;
    onDeny = props.onDeny;

    if not pending {
        return
            <></>;
    }

    parsedArgs = {};
    try {
        parsedArgs = pending.toolArgs if pending.toolArgs else {};
    } except Exception {
        parsedArgs = {};
    }

    return
        <div
            className="flex-shrink-0 border-t border-warning/30 bg-warning/5 px-4 py-3"
        >
            <div className="flex items-start gap-3">
                <div
                    className="w-7 h-7 rounded-full bg-warning/15 flex items-center justify-center flex-shrink-0 mt-0.5"
                >
                    <ShieldCheck size={14} className="text-warning"/>
                </div>
                <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 mb-1">
                        <span className="text-xs font-semibold text-warning">
                            Tool Call Confirmation
                        </span>
                        {pending.serverName
                        and <span className="text-xs text-muted-foreground/50">
                            via{pending.serverName}
                        </span>}
                    </div>
                    <p className="text-xs text-foreground font-mono font-medium mb-2">
                        {pending.toolName}
                    </p>
                    {parsedArgs
                    and len(Object.keys(parsedArgs)) > 0
                    and <div className="mb-3">
                        <JsonViewer data={parsedArgs} collapsed={1} maxHeight="100px"/>
                    </div>}
                    <div className="flex gap-2">
                        <button
                            onClick={onApprove}
                            className="flex items-center gap-1.5 bg-success/15 hover:bg-success/25 text-success border border-success/25 text-xs font-medium px-3 py-1.5 rounded-lg transition-colors cursor-pointer"
                        >
                            <ShieldCheck size={12}/>
                            Approve
                        </button>
                        <button
                            onClick={onDeny}
                            className="flex items-center gap-1.5 bg-destructive/10 hover:bg-destructive/20 text-destructive border border-destructive/20 text-xs font-medium px-3 py-1.5 rounded-lg transition-colors cursor-pointer"
                        >
                            <ShieldX size={12}/>
                            Deny
                        </button>
                    </div>
                </div>
            </div>
        </div>;
}

# ── Main Chat Panel ────────────────────────────────────────────────────
def:pub ChatPanel(props: Any) -> JsxElement {
    connection = props.connection;
    agentLoop = props.agentLoop;

    chatMessages = useLlmStore(lambda (s: Any) -> Any { return s.chatMessages; });
    agentRunning = useLlmStore(lambda (s: Any) -> Any { return s.agentRunning; });
    agentStatus = useLlmStore(lambda (s: Any) -> Any { return s.agentStatus; });
    streamingContent = useLlmStore(lambda (s: Any) -> Any { return s.streamingContent; });
    totalTokenUsage = useLlmStore(lambda (s: Any) -> Any { return s.totalTokenUsage; });
    llmConfig = useLlmStore(lambda (s: Any) -> Any { return s.llmConfig; });
    pendingConfirmation = useLlmStore(
        lambda (s: Any) -> Any { return s.pendingConfirmation; }
    );

    has inputValue: str = "";
    messagesEndRef = useRef(None);

    # Auto-scroll to bottom on new messages
    useEffect(
        lambda -> Any { if messagesEndRef.current {
            messagesEndRef.current.scrollIntoView({"behavior": "smooth"});
        }return lambda -> None { }; },
        [chatMessages.length]
    );

    # Auto-scroll during streaming (instant to keep up with tokens)
    useEffect(
        lambda -> Any { if messagesEndRef.current and streamingContent {
            messagesEndRef.current.scrollIntoView({"behavior": "instant"});
        }return lambda -> None { }; },
        [streamingContent]
    );

    async def handleSend -> None {
        msg = inputValue.trim();
        if not msg or agentRunning {
            return;
        }
        if not llmConfig.apiKey {
            return;
        }
        inputValue = "";
        await agentLoop.runAgentLoop(connection, msg);
    }

    caps = connection.capabilities or {};
    toolCount = len(caps.tools or []);

    return
        <div className="flex-1 flex flex-col overflow-hidden">
            <div className="flex-1 overflow-y-auto px-4 py-4">
                {len(chatMessages) == 0
                and <div
                    className="flex flex-col items-center justify-center h-full gap-4 text-muted-foreground"
                >
                    <div
                        className="w-14 h-14 rounded-2xl bg-primary/5 border border-primary/10 flex items-center justify-center"
                    >
                        <Bot size={24} className="text-primary/40"/>
                    </div>
                    <div className="text-center">
                        <p className="text-sm font-medium text-foreground">
                            Agent Mode
                        </p>
                        <p className="text-xs text-muted-foreground mt-1 max-w-xs">
                            Chat with an LLM that can call{toolCount} tool{toolCount != 1
                            and "s"
                            or ""} on the connected MCP server.
                        </p>
                    </div>
                    {not llmConfig.apiKey
                    and <div
                        className="flex items-center gap-2 bg-warning/5 border border-warning/15 rounded-lg px-3 py-2"
                    >
                        <AlertTriangle size={12} className="text-warning"/>
                        <span className="text-xs text-warning">
                            Configure your API key in the settings above to get started.
                        </span>
                    </div>}
                </div>}{len(chatMessages) > 0
                and <>
                    {chatMessages.map(
                        lambda (msg: Any, idx: Any) -> Any { return
                            <ChatMessage key={idx} msg={msg} idx={idx}/>; }
                    )}
                    {agentRunning
                    and <div className="flex gap-2 mb-3">
                        <div
                            className="w-7 h-7 rounded-full bg-info/10 flex items-center justify-center flex-shrink-0 mt-0.5"
                        >
                            <Loader2 size={13} className="text-info animate-spin"/>
                        </div>
                        {streamingContent
                        and <div
                            className="max-w-[85%] bg-card border border-border rounded-2xl rounded-bl-md px-4 py-2.5"
                        >
                            <MarkdownRenderer content={streamingContent}/>
                            <span
                                className="inline-block w-0.5 h-3.5 bg-foreground/50 animate-pulse ml-0.5 align-text-bottom"
                            />
                        </div>
                        or <div
                            className="bg-card/50 border border-border rounded-2xl rounded-bl-md px-4 py-2.5"
                        >
                            <div className="flex items-center gap-2">
                                <span
                                    className="w-1.5 h-1.5 rounded-full bg-primary animate-pulse"
                                />
                                <span className="text-xs text-muted-foreground">
                                    {agentStatus or "Agent is thinking..."}
                                </span>
                            </div>
                        </div>}
                    </div>}
                    <div ref={messagesEndRef}/>
                </>}
            </div>
            {pendingConfirmation
            and <ToolConfirmModal
                pending={pendingConfirmation}
                onApprove={agentLoop.approveToolCall}
                onDeny={agentLoop.denyToolCall}
            />}
            <div className="flex-shrink-0 border-t border-border p-3 bg-card/30">
                <div className="px-[10%]">
                    {totalTokenUsage.total > 0
                    and <div
                        className="flex items-center gap-3 mb-2.5 px-1 text-xs text-muted-foreground/60"
                    >
                        <span>
                            Tokens:{totalTokenUsage.total.toLocaleString()}
                        </span>
                        <span>
                            ({totalTokenUsage.prompt.toLocaleString()} in /{totalTokenUsage.completion.toLocaleString()} out)
                        </span>
                    </div>}
                    <div className="flex items-end gap-2">
                        {len(chatMessages) > 0
                        and <button
                            onClick={agentLoop.deleteCurrentSession}
                            disabled={Boolean(agentRunning)}
                            className="flex-shrink-0 text-muted-foreground/40 hover:text-destructive p-2 rounded-lg hover:bg-muted transition-colors cursor-pointer disabled:opacity-30"
                            title="Clear chat"
                        >
                            <Trash2 size={15}/>
                        </button>}
                        <div className="flex-1 relative">
                            <textarea
                                value={inputValue}
                                onChange={lambda (e: Any) -> None { inputValue = e.target.value;}}
                                onKeyDown={lambda (e: Any) -> None { if e.key == "Enter"
                                and not e.shiftKey {
                                    e.preventDefault();
                                    handleSend();
                                }}}
                                placeholder={not llmConfig.apiKey
                                and "Set your API key above to start chatting..."
                                or (
                                    "Ask the agent something..." + (
                                        toolCount > 0
                                        and f" ({toolCount} tools available)"
                                        or ""
                                    )
                                )}
                                disabled={Boolean(not llmConfig.apiKey)}
                                rows={1}
                                className="w-full bg-background border border-input rounded-xl px-4 py-2.5 text-sm text-foreground placeholder-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring/50 focus:border-ring transition-colors resize-none disabled:opacity-50"
                            />
                        </div>
                        {agentRunning
                        and <button
                            onClick={agentLoop.abortAgent}
                            className="flex-shrink-0 flex items-center gap-1.5 bg-destructive hover:bg-destructive/90 text-destructive-foreground font-medium px-3.5 py-2.5 rounded-xl transition-colors cursor-pointer text-sm"
                        >
                            <StopCircle size={14}/>
                            Stop
                        </button>
                        or <button
                            onClick={handleSend}
                            disabled={Boolean(
                                not inputValue.trim() or not llmConfig.apiKey
                            )}
                            className="flex-shrink-0 flex items-center gap-1.5 bg-primary hover:bg-primary/90 text-primary-foreground font-medium px-3.5 py-2.5 rounded-xl transition-colors cursor-pointer disabled:opacity-30 disabled:cursor-default text-sm"
                        >
                            <Send size={14}/>
                        </button>}
                    </div>
                </div>
            </div>
        </div>;
}
