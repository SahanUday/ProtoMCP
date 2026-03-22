"""Docs – Explore Mode."""

cl import from "@jac/runtime" { Link }
cl import from "lucide-react" {
    Search, Wrench, MessageSquare, FolderOpen, ArrowRight,
    CheckCircle2, RefreshCw, ScrollText, Info, Zap
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

    def TabCard(props: Any) -> JsxElement {
        icon = props.icon;
        title = props.title;
        desc = props.desc;
        items = props.items;
        return <div className="border border-border rounded-xl overflow-hidden">
            <div className="flex items-center gap-3 px-4 py-3 bg-muted/40 border-b border-border">
                <span className="text-primary">{icon}</span>
                <p className="text-sm font-semibold text-foreground">{title}</p>
            </div>
            <div className="px-4 py-4">
                <p className="text-sm text-muted-foreground leading-relaxed mb-3">{desc}</p>
                <ul className="space-y-1.5">
                    {items.map(lambda (item: Any, i: int) -> JsxElement {
                        return <li key={i} className="flex items-start gap-2 text-sm text-muted-foreground">
                            <CheckCircle2 size={13} className="text-primary mt-0.5 flex-shrink-0"/>
                            {item}
                        </li>;
                    })}
                </ul>
            </div>
        </div>;
    }

    def:pub page -> JsxElement {
        return <DocsLayout>
            <div>
                <div className="mb-8">
                    <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-primary/10 border border-primary/20 text-primary text-xs font-medium mb-4">
                        <Search size={11}/>
                        Explore Mode
                    </div>
                    <h1 className="text-3xl font-bold text-foreground tracking-tight mb-3">
                        Explore Mode
                    </h1>
                    <p className="text-base text-muted-foreground leading-relaxed">
                        {"Explore Mode is ProtoMCP's interactive capability browser. Without any AI or LLM, you can inspect every tool, prompt, and resource that your connected MCP server exposes — and execute them directly from the UI."}
                    </p>
                </div>

                <div className="mb-10">
                    <h2 className="text-lg font-semibold text-foreground mb-4 flex items-center gap-2">
                        <Zap size={16} className="text-primary"/>
                        Getting into Explore Mode
                    </h2>
                    <ol className="space-y-4">
                        <li className="flex gap-4">
                            <div className="flex-shrink-0 w-6 h-6 rounded-full bg-primary/10 border border-primary/20 flex items-center justify-center text-primary text-xs font-bold mt-0.5">1</div>
                            <div>
                                <p className="text-sm text-muted-foreground leading-relaxed">
                                    {"Navigate to the "}
                                    <Link to="/playground" className="text-primary hover:underline font-medium">Playground</Link>
                                    {" and connect an MCP server using "}
                                    <span className="font-medium text-foreground">+ Add</span>
                                    {" in the sidebar."}
                                </p>
                            </div>
                        </li>
                        <li className="flex gap-4">
                            <div className="flex-shrink-0 w-6 h-6 rounded-full bg-primary/10 border border-primary/20 flex items-center justify-center text-primary text-xs font-bold mt-0.5">2</div>
                            <div>
                                <p className="text-sm text-muted-foreground leading-relaxed">
                                    {"Click on the connected server in the sidebar. You will land on the server's Explore view with the "}
                                    <span className="font-medium text-foreground">Explorer</span>
                                    {" tab active by default."}
                                </p>
                            </div>
                        </li>
                        <li className="flex gap-4">
                            <div className="flex-shrink-0 w-6 h-6 rounded-full bg-primary/10 border border-primary/20 flex items-center justify-center text-primary text-xs font-bold mt-0.5">3</div>
                            <div>
                                <p className="text-sm text-muted-foreground leading-relaxed">
                                    {"Use the "}
                                    <span className="font-medium text-foreground">Tools</span>
                                    {", "}
                                    <span className="font-medium text-foreground">Prompts</span>
                                    {", and "}
                                    <span className="font-medium text-foreground">Resources</span>
                                    {" tabs to switch between capability types."}
                                </p>
                            </div>
                        </li>
                    </ol>
                </div>

                <div className="border-t border-border pt-8 mb-10">
                    <h2 className="text-lg font-semibold text-foreground mb-5 flex items-center gap-2">
                        <Search size={16} className="text-primary"/>
                        Capability tabs
                    </h2>
                    <div className="flex flex-col gap-4">
                        <TabCard
                            icon={<Wrench size={15}/>}
                            title="Tools"
                            desc="Browse all tools the server exposes. Each tool shows its name, description, and parameter count. Click any tool to open its execution page."
                            items={[
                                "Auto-generated parameter form built from the tool's JSON schema",
                                "Required and optional fields clearly marked with descriptions",
                                "Execute button calls the tool on the live MCP server",
                                "Result viewer shows the response — supports JSON, text, and error display",
                                "Copy-to-clipboard on any result"
                            ]}
                        />
                        <TabCard
                            icon={<MessageSquare size={15}/>}
                            title="Prompts"
                            desc="Browse server-defined prompt templates. Each prompt can accept arguments and returns a structured message array."
                            items={[
                                "Input fields for each prompt argument",
                                "Get Prompt button invokes the prompt on the server",
                                "Result displays as a role-based message list (user / assistant)",
                                "Supports rich content including text and structured data"
                            ]}
                        />
                        <TabCard
                            icon={<FolderOpen size={15}/>}
                            title="Resources"
                            desc="Browse all read-only resources the server exposes, such as documents, data files, or reference material."
                            items={[
                                "Shows resource name, URI, MIME type, and description",
                                "Read Resource button fetches the content from the server",
                                "Content viewer handles text, JSON, and image MIME types",
                                "Copy resource content to clipboard",
                                "Retry on failure"
                            ]}
                        />
                    </div>
                </div>

                <div className="border-t border-border pt-8 mb-10">
                    <h2 className="text-lg font-semibold text-foreground mb-4 flex items-center gap-2">
                        <Search size={16} className="text-primary"/>
                        Search
                    </h2>
                    <p className="text-sm text-muted-foreground leading-relaxed mb-3">
                        {"When a server has 3 or more capabilities of a given type, a search bar appears at the top of the list. It filters in real time by name, description, or URI — case insensitive."}
                    </p>
                    <InfoBox>
                        {"Search works independently per tab. Searching in Tools does not affect what is shown in Prompts or Resources."}
                    </InfoBox>
                </div>

                <div className="border-t border-border pt-8 mb-10">
                    <h2 className="text-lg font-semibold text-foreground mb-4 flex items-center gap-2">
                        <RefreshCw size={16} className="text-primary"/>
                        Server info and refresh
                    </h2>
                    <p className="text-sm text-muted-foreground leading-relaxed mb-3">
                        {"The top of the explorer shows a live header with:"}
                    </p>
                    <ul className="space-y-2 text-sm text-muted-foreground mb-4">
                        <li className="flex items-start gap-2">
                            <CheckCircle2 size={13} className="text-primary mt-0.5 flex-shrink-0"/>
                            Server name and version
                        </li>
                        <li className="flex items-start gap-2">
                            <CheckCircle2 size={13} className="text-primary mt-0.5 flex-shrink-0"/>
                            Transport type badge (Streamable HTTP / SSE)
                        </li>
                        <li className="flex items-start gap-2">
                            <CheckCircle2 size={13} className="text-primary mt-0.5 flex-shrink-0"/>
                            Live status indicator (connected / connecting / error)
                        </li>
                        <li className="flex items-start gap-2">
                            <CheckCircle2 size={13} className="text-primary mt-0.5 flex-shrink-0"/>
                            Tool, prompt, and resource count badges
                        </li>
                    </ul>
                    <p className="text-sm text-muted-foreground leading-relaxed">
                        {"Click the "}
                        <span className="font-medium text-foreground">Refresh</span>
                        {" button (↺) to re-discover capabilities from the server. This is useful if the server has been updated while you are connected."}
                    </p>
                </div>

                <div className="border-t border-border pt-8 mb-10">
                    <h2 className="text-lg font-semibold text-foreground mb-4 flex items-center gap-2">
                        <ScrollText size={16} className="text-primary"/>
                        Request logs
                    </h2>
                    <p className="text-sm text-muted-foreground leading-relaxed">
                        {"Click the "}
                        <span className="font-medium text-foreground">Logs</span>
                        {" button in the top bar to open the request history panel on the right. Every MCP request and response is recorded here — useful for debugging and inspecting the raw JSON-RPC messages being exchanged with the server."}
                    </p>
                </div>

                <div className="border-t border-border pt-8 mb-10">
                    <h2 className="text-lg font-semibold text-foreground mb-4 flex items-center gap-2">
                        <Search size={16} className="text-primary"/>
                        Managing multiple servers
                    </h2>
                    <p className="text-sm text-muted-foreground leading-relaxed mb-3">
                        {"The left sidebar shows all your connected servers. Each entry displays the server name, URL, transport type, and capability count. You can:"}
                    </p>
                    <ul className="space-y-2 text-sm text-muted-foreground">
                        <li className="flex items-start gap-2">
                            <CheckCircle2 size={13} className="text-primary mt-0.5 flex-shrink-0"/>
                            Click any server to switch to it
                        </li>
                        <li className="flex items-start gap-2">
                            <CheckCircle2 size={13} className="text-primary mt-0.5 flex-shrink-0"/>
                            Hover to reveal the delete button and remove a connection
                        </li>
                        <li className="flex items-start gap-2">
                            <CheckCircle2 size={13} className="text-primary mt-0.5 flex-shrink-0"/>
                            Click ＋ Add to connect additional servers at any time
                        </li>
                        <li className="flex items-start gap-2">
                            <CheckCircle2 size={13} className="text-primary mt-0.5 flex-shrink-0"/>
                            All connections persist across page refreshes within the session
                        </li>
                    </ul>
                </div>

                <div className="rounded-xl border border-border bg-muted/30 p-5">
                    <p className="text-sm font-semibold text-foreground mb-1">Ready to automate?</p>
                    <p className="text-sm text-muted-foreground mb-3">
                        {"Switch to Agent Mode to have an AI select and run tools on your behalf — turning manual exploration into intelligent automation."}
                    </p>
                    <Link
                        to="/docs/agent_mode"
                        className="inline-flex items-center gap-2 text-sm font-medium text-primary hover:text-primary/80 transition-colors"
                    >
                        Agent Mode guide
                        <ArrowRight size={12}/>
                    </Link>
                </div>
            </div>
        </DocsLayout>;
    }
}
