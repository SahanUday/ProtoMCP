"""Docs – Agent Mode."""

cl import from "@jac/runtime" { Link }
cl import from "lucide-react" {
    Bot, Zap, Settings, MessageSquare, Activity, Clock,
    Plus, Shield, CheckCircle2, ArrowRight, Info, Key,
    Sliders, Wrench, Brain, Hash, ChevronRight
}
cl import from ...components.docs.docs_layout { DocsLayout }

cl {
    def InfoBox(props: Any) -> JsxElement {
        children = props.children;
        return <div className="flex gap-3 rounded-lg border border-primary/20 bg-primary/5 px-4 py-3 text-sm text-muted-foreground leading-relaxed">
            <Info size={14} className="text-primary flex-shrink-0 mt-0.5"/>
            <div>{children}</div>
        </div>;
    }

    def TipBox(props: Any) -> JsxElement {
        children = props.children;
        return <div className="flex gap-3 rounded-lg border border-success/20 bg-success/5 px-4 py-3 text-sm text-muted-foreground leading-relaxed">
            <CheckCircle2 size={14} className="text-success flex-shrink-0 mt-0.5"/>
            <div>{children}</div>
        </div>;
    }

    def ProviderBadge(props: Any) -> JsxElement {
        name = props.name;
        models = props.models;
        return <div className="border border-border rounded-lg px-4 py-3">
            <p className="text-sm font-medium text-foreground mb-1.5">{name}</p>
            <div className="flex flex-wrap gap-1.5">
                {models.map(lambda (m: str, i: int) -> JsxElement {
                    return <span key={i} className="text-xs px-2 py-0.5 rounded bg-muted border border-border font-mono text-muted-foreground">{m}</span>;
                })}
            </div>
        </div>;
    }

    def TraceEventRow(props: Any) -> JsxElement {
        icon = props.icon;
        label = props.label;
        desc = props.desc;
        color = props.color or "text-primary";
        return <div className="flex items-start gap-3 py-2.5 border-b border-border last:border-0">
            <span className={color + " flex-shrink-0 mt-0.5"}>{icon}</span>
            <div>
                <p className="text-sm font-medium text-foreground">{label}</p>
                <p className="text-xs text-muted-foreground mt-0.5">{desc}</p>
            </div>
        </div>;
    }

    def:pub page -> JsxElement {
        return <DocsLayout>
            <div>
                <div className="mb-8">
                    <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-primary/10 border border-primary/20 text-primary text-xs font-medium mb-4">
                        <Bot size={11}/>
                        Agent Mode
                    </div>
                    <h1 className="text-3xl font-bold text-foreground tracking-tight mb-3">
                        Agent Mode
                    </h1>
                    <p className="text-base text-muted-foreground leading-relaxed">
                        {"Agent Mode turns your connected MCP server into an AI-powered assistant. You chat with an LLM that autonomously selects and executes MCP tools, chains multiple calls together, and reasons through complex tasks — while you watch every step unfold in real time."}
                    </p>
                </div>

                <div className="mb-10">
                    <h2 className="text-lg font-semibold text-foreground mb-4 flex items-center gap-2">
                        <Settings size={16} className="text-primary"/>
                        LLM configuration
                    </h2>
                    <p className="text-sm text-muted-foreground leading-relaxed mb-5">
                        {"In the Playground, switch to the "}
                        <span className="font-medium text-foreground">Agent</span>
                        {" tab, then click the "}
                        <span className="font-medium text-foreground">LLM Config</span>
                        {" button to open the configuration panel."}
                    </p>

                    <div className="mb-6">
                        <h3 className="text-sm font-semibold text-foreground mb-3 flex items-center gap-2">
                            <Zap size={13} className="text-primary"/>
                            Provider and model
                        </h3>
                        <p className="text-sm text-muted-foreground leading-relaxed mb-4">
                            {"Select your LLM provider from the dropdown. ProtoMCP supports all major providers:"}
                        </p>
                        <div className="grid gap-2.5">
                            <ProviderBadge
                                name="OpenAI"
                                models={["gpt-4o", "gpt-4o-mini", "gpt-4-turbo", "o1-mini", "o3-mini"]}
                            />
                            <ProviderBadge
                                name="Anthropic"
                                models={["claude-sonnet-4-20250514", "claude-haiku-4-20250414", "claude-opus-4-20250514"]}
                            />
                            <ProviderBadge
                                name="Google Gemini"
                                models={["gemini-2.5-pro", "gemini-2.5-flash", "gemini-2.0-flash", "gemini-1.5-pro"]}
                            />
                            <ProviderBadge
                                name="Groq"
                                models={["llama-3.1-70b-versatile", "llama-3.1-8b-instant", "mixtral-8x7b-32768"]}
                            />
                            <ProviderBadge
                                name="Together AI"
                                models={["Llama-3-70b-chat-hf", "Mixtral-8x7B-Instruct-v0.1"]}
                            />
                        </div>
                        <p className="text-sm text-muted-foreground mt-3">
                            {"You can also type any custom model name directly into the model field for self-hosted or unlisted models."}
                        </p>
                    </div>

                    <div className="mb-6">
                        <h3 className="text-sm font-semibold text-foreground mb-3 flex items-center gap-2">
                            <Key size={13} className="text-primary"/>
                            API key
                        </h3>
                        <p className="text-sm text-muted-foreground leading-relaxed mb-3">
                            {"Paste your provider API key into the API Key field. The field is masked by default — click the eye icon to reveal it. Check "}
                            <span className="font-medium text-foreground">Keep for session</span>
                            {" to save the key in your browser's sessionStorage so you don't need to re-enter it on page refresh."}
                        </p>
                        <TipBox>
                            {"Your API key is sent directly to your chosen LLM provider. It is never stored or forwarded through ProtoMCP's servers."}
                        </TipBox>
                    </div>

                    <div className="mb-6">
                        <h3 className="text-sm font-semibold text-foreground mb-3 flex items-center gap-2">
                            <Sliders size={13} className="text-primary"/>
                            Advanced parameters
                        </h3>
                        <div className="border border-border rounded-xl overflow-hidden">
                            <div className="divide-y divide-border">
                                <div className="flex items-start gap-4 px-4 py-3">
                                    <div className="w-32 flex-shrink-0">
                                        <p className="text-sm font-medium text-foreground">Temperature</p>
                                        <p className="text-xs text-muted-foreground">0.0 – 2.0</p>
                                    </div>
                                    <p className="text-sm text-muted-foreground leading-relaxed">Controls randomness. Lower values make responses more focused and deterministic; higher values make them more creative. Default: 0.7</p>
                                </div>
                                <div className="flex items-start gap-4 px-4 py-3">
                                    <div className="w-32 flex-shrink-0">
                                        <p className="text-sm font-medium text-foreground">Max Tokens</p>
                                        <p className="text-xs text-muted-foreground">100 – 128000</p>
                                    </div>
                                    <p className="text-sm text-muted-foreground leading-relaxed">Maximum number of tokens the LLM can generate per response. Default: 4096</p>
                                </div>
                                <div className="flex items-start gap-4 px-4 py-3">
                                    <div className="w-32 flex-shrink-0">
                                        <p className="text-sm font-medium text-foreground">Max Iterations</p>
                                        <p className="text-xs text-muted-foreground">1 – 50</p>
                                    </div>
                                    <p className="text-sm text-muted-foreground leading-relaxed">Maximum number of reasoning steps (tool call → result → next call) the agent can take before stopping. Default: 10</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div className="mb-6">
                        <h3 className="text-sm font-semibold text-foreground mb-3 flex items-center gap-2">
                            <MessageSquare size={13} className="text-primary"/>
                            System prompt
                        </h3>
                        <p className="text-sm text-muted-foreground leading-relaxed">
                            {"Customize the agent's behavior by editing the system prompt. The default instructs the agent to explain what it's doing and why when using tools. You can replace this with domain-specific instructions tailored to your MCP server."}
                        </p>
                    </div>

                    <div className="mb-4">
                        <h3 className="text-sm font-semibold text-foreground mb-3 flex items-center gap-2">
                            <Wrench size={13} className="text-primary"/>
                            Tool filter
                        </h3>
                        <p className="text-sm text-muted-foreground leading-relaxed">
                            {"By default, the agent has access to all tools across all connected servers. Use the Tool Filter section to enable or disable specific tools. This is useful when you want to constrain the agent to a subset of capabilities or prevent it from calling certain tools."}
                        </p>
                    </div>
                </div>

                <div className="border-t border-border pt-8 mb-10">
                    <h2 className="text-lg font-semibold text-foreground mb-4 flex items-center gap-2">
                        <MessageSquare size={16} className="text-primary"/>
                        Using the chat panel
                    </h2>
                    <p className="text-sm text-muted-foreground leading-relaxed mb-4">
                        {"Once your LLM is configured, type your message in the chat input and press "}
                        <kbd className="text-xs bg-muted border border-border px-1.5 py-0.5 rounded font-mono">Enter</kbd>
                        {" to send ("}
                        <kbd className="text-xs bg-muted border border-border px-1.5 py-0.5 rounded font-mono">Shift + Enter</kbd>
                        {" for a new line). The agent will start reasoning and executing tools to answer your request."}
                    </p>

                    <div className="flex flex-col gap-3 mb-5">
                        <div className="flex items-start gap-3 p-3 rounded-lg border border-border bg-card">
                            <div className="flex-shrink-0 w-7 h-7 rounded-full bg-primary/10 border border-primary/20 flex items-center justify-center text-xs text-primary font-bold">U</div>
                            <div>
                                <p className="text-xs text-muted-foreground mb-0.5">Your message</p>
                                <p className="text-sm text-foreground">{"Right-aligned bubble. Shows your input text."}</p>
                            </div>
                        </div>
                        <div className="flex items-start gap-3 p-3 rounded-lg border border-border bg-card">
                            <div className="flex-shrink-0 w-7 h-7 rounded-full bg-muted border border-border flex items-center justify-center">
                                <Bot size={13} className="text-muted-foreground"/>
                            </div>
                            <div>
                                <p className="text-xs text-muted-foreground mb-0.5">Agent response</p>
                                <p className="text-sm text-foreground">{"Left-aligned bubble. Renders markdown. May include tool call cards and result cards inline."}</p>
                            </div>
                        </div>
                        <div className="flex items-start gap-3 p-3 rounded-lg border border-border bg-card">
                            <div className="flex-shrink-0 w-7 h-7 rounded-full bg-primary/10 border border-primary/20 flex items-center justify-center">
                                <Wrench size={13} className="text-primary"/>
                            </div>
                            <div>
                                <p className="text-xs text-muted-foreground mb-0.5">Tool call card</p>
                                <p className="text-sm text-foreground">{"Shows which tool the agent is calling and its arguments. Expandable to see the full JSON."}</p>
                            </div>
                        </div>
                        <div className="flex items-start gap-3 p-3 rounded-lg border border-border bg-card">
                            <div className="flex-shrink-0 w-7 h-7 rounded-full bg-success/10 border border-success/20 flex items-center justify-center">
                                <CheckCircle2 size={13} className="text-success"/>
                            </div>
                            <div>
                                <p className="text-xs text-muted-foreground mb-0.5">Tool result card</p>
                                <p className="text-sm text-foreground">{"Shows the tool's output. Green for success, red for error. Expandable to see the full result."}</p>
                            </div>
                        </div>
                    </div>

                    <InfoBox>
                        {"The token count (prompt / completion / total) is shown below the input as the agent runs, so you can monitor usage in real time."}
                    </InfoBox>
                </div>

                <div className="border-t border-border pt-8 mb-10">
                    <h2 className="text-lg font-semibold text-foreground mb-4 flex items-center gap-2">
                        <Shield size={16} className="text-primary"/>
                        Tool confirmation mode
                    </h2>
                    <p className="text-sm text-muted-foreground leading-relaxed mb-4">
                        {"Enable "}
                        <span className="font-medium text-foreground">Approve each tool call before execution</span>
                        {" in the LLM Config panel to put the agent in confirmation mode. When active, the agent pauses before executing any tool and shows a confirmation dialog:"}
                    </p>
                    <div className="border border-border rounded-xl p-4 bg-card mb-4">
                        <div className="flex items-center gap-2 mb-3">
                            <Shield size={14} className="text-warning"/>
                            <p className="text-sm font-semibold text-foreground">Tool Call Confirmation</p>
                        </div>
                        <p className="text-sm text-muted-foreground mb-3">
                            {"The dialog shows the tool name, the server it belongs to, and the full arguments the agent intends to pass. You have 120 seconds to respond before the request times out."}
                        </p>
                        <div className="flex gap-2">
                            <span className="px-3 py-1.5 rounded-lg text-xs font-medium bg-success/10 border border-success/20 text-success">Approve</span>
                            <span className="px-3 py-1.5 rounded-lg text-xs font-medium bg-destructive/10 border border-destructive/20 text-destructive">Deny</span>
                        </div>
                    </div>
                    <TipBox>
                        {"Confirmation mode is recommended when working with tools that write data, modify state, or make external API calls — giving you full control over what the agent actually does."}
                    </TipBox>
                </div>

                <div className="border-t border-border pt-8 mb-10">
                    <h2 className="text-lg font-semibold text-foreground mb-4 flex items-center gap-2">
                        <Activity size={16} className="text-primary"/>
                        Trace panel
                    </h2>
                    <p className="text-sm text-muted-foreground leading-relaxed mb-5">
                        {"Click the "}
                        <span className="font-medium text-foreground">Trace</span>
                        {" tab in Agent Mode to see the full execution timeline. Every event in the agent's reasoning loop is recorded here — from the initial LLM call to each tool execution and the final response."}
                    </p>
                    <div className="border border-border rounded-xl overflow-hidden mb-4">
                        <TraceEventRow
                            icon={<MessageSquare size={14}/>}
                            label="user_message"
                            desc="Your input message that started this agent run"
                            color="text-info"
                        />
                        <TraceEventRow
                            icon={<Zap size={14}/>}
                            label="llm_call_start"
                            desc="Agent called the LLM — shows model, iteration number, and available tool count"
                            color="text-info"
                        />
                        <TraceEventRow
                            icon={<Brain size={14}/>}
                            label="thought"
                            desc="The LLM's internal reasoning text before deciding which tool to call"
                            color="text-warning"
                        />
                        <TraceEventRow
                            icon={<Wrench size={14}/>}
                            label="tool_call"
                            desc="A tool call the agent is making — shows function name and arguments"
                            color="text-primary"
                        />
                        <TraceEventRow
                            icon={<CheckCircle2 size={14}/>}
                            label="tool_result"
                            desc="The result returned by the tool — green for success, red for error"
                            color="text-success"
                        />
                        <TraceEventRow
                            icon={<Bot size={14}/>}
                            label="llm_response"
                            desc="LLM finished a generation step — shows finish reason and token count"
                            color="text-info"
                        />
                        <TraceEventRow
                            icon={<Hash size={14}/>}
                            label="usage"
                            desc="Token usage for this step: prompt tokens, completion tokens, total"
                            color="text-muted-foreground"
                        />
                        <TraceEventRow
                            icon={<CheckCircle2 size={14}/>}
                            label="final_response"
                            desc="The agent's completed response — what appears in the chat panel"
                            color="text-success"
                        />
                    </div>
                    <p className="text-sm text-muted-foreground leading-relaxed">
                        {"Each event shows the time elapsed since the previous event (in ms or seconds). Click any event to expand it and see the full JSON data. Multi-step agent runs are grouped by iteration number so you can follow the full reasoning chain."}
                    </p>
                </div>

                <div className="border-t border-border pt-8 mb-10">
                    <h2 className="text-lg font-semibold text-foreground mb-4 flex items-center gap-2">
                        <Clock size={16} className="text-primary"/>
                        Session management
                    </h2>

                    <div className="mb-5">
                        <h3 className="text-sm font-semibold text-foreground mb-2 flex items-center gap-2">
                            <Plus size={13} className="text-primary"/>
                            New session
                        </h3>
                        <p className="text-sm text-muted-foreground leading-relaxed">
                            {"Click "}
                            <span className="font-medium text-foreground">New Session</span>
                            {" (＋ icon) to start a fresh conversation. The current chat and trace are automatically saved to session history before being cleared. The agent starts with a clean context — no memory of previous messages."}
                        </p>
                    </div>

                    <div className="mb-5">
                        <h3 className="text-sm font-semibold text-foreground mb-2 flex items-center gap-2">
                            <Clock size={13} className="text-primary"/>
                            Session history
                        </h3>
                        <p className="text-sm text-muted-foreground leading-relaxed mb-3">
                            {"Click the "}
                            <span className="font-medium text-foreground">History</span>
                            {" button (clock icon) to open the session history panel. Up to 5 previous sessions are stored in your browser's sessionStorage. Each entry shows:"}
                        </p>
                        <ul className="space-y-1.5 text-sm text-muted-foreground mb-3">
                            <li className="flex items-start gap-2">
                                <ChevronRight size={13} className="text-primary mt-0.5 flex-shrink-0"/>
                                The title (first message you sent in that session)
                            </li>
                            <li className="flex items-start gap-2">
                                <ChevronRight size={13} className="text-primary mt-0.5 flex-shrink-0"/>
                                Timestamp of when the session was created
                            </li>
                        </ul>
                        <p className="text-sm text-muted-foreground leading-relaxed">
                            {"Click a session to restore its full chat history, trace events, and token usage. Hover a session to reveal the delete button."}
                        </p>
                    </div>

                    <div>
                        <h3 className="text-sm font-semibold text-foreground mb-2 flex items-center gap-2">
                            <Activity size={13} className="text-primary"/>
                            Stop and cancel
                        </h3>
                        <p className="text-sm text-muted-foreground leading-relaxed">
                            {"While the agent is running, the Send button becomes a red "}
                            <span className="font-medium text-foreground">Stop</span>
                            {" button. Click it to immediately cancel the agent run. The backend terminates the reasoning loop and the SSE stream closes."}
                        </p>
                    </div>
                </div>

                <div className="rounded-xl border border-border bg-muted/30 p-5">
                    <p className="text-sm font-semibold text-foreground mb-1">Explore before you automate</p>
                    <p className="text-sm text-muted-foreground mb-3">
                        {"Not sure which tools your server exposes? Use Explore Mode first to browse and test capabilities manually, then switch to Agent Mode to automate them."}
                    </p>
                    <Link
                        to="/docs/explore_mode"
                        className="inline-flex items-center gap-2 text-sm font-medium text-primary hover:text-primary/80 transition-colors"
                    >
                        Explore Mode guide
                        <ArrowRight size={12}/>
                    </Link>
                </div>
            </div>
        </DocsLayout>;
    }
}
