"""Docs – Quickstart."""

cl import from "@jac/runtime" { Link }
cl import from "lucide-react" {
    Zap, Server, Plug, Search, Bot, ArrowRight,
    CheckCircle2, Globe, Laptop, List
}
cl import from ...components.docs.docs_layout { DocsLayout }

cl {
    def Step(props: Any) -> JsxElement {
        num = props.num;
        title = props.title;
        children = props.children;
        return <div className="flex gap-4">
            <div className="flex-shrink-0 w-7 h-7 rounded-full bg-primary/10 border border-primary/20 flex items-center justify-center text-primary text-xs font-bold mt-0.5">
                {num}
            </div>
            <div className="flex-1 pb-8">
                <h3 className="text-sm font-semibold text-foreground mb-2">{title}</h3>
                {children}
            </div>
        </div>;
    }

    def InfoBox(props: Any) -> JsxElement {
        children = props.children;
        return <div className="rounded-lg border border-primary/20 bg-primary/5 px-4 py-3 text-sm text-muted-foreground leading-relaxed">
            {children}
        </div>;
    }

    def SectionLink(props: Any) -> JsxElement {
        to = props.to;
        icon = props.icon;
        label = props.label;
        desc = props.desc;
        return <Link
            to={to}
            className="group flex items-center justify-between gap-3 px-4 py-3 rounded-lg border border-border bg-card hover:border-primary/30 hover:bg-primary/5 transition-all"
        >
            <div className="flex items-center gap-3">
                <span className="text-primary">{icon}</span>
                <div>
                    <p className="text-sm font-medium text-foreground group-hover:text-primary transition-colors">{label}</p>
                    <p className="text-xs text-muted-foreground mt-0.5">{desc}</p>
                </div>
            </div>
            <ArrowRight size={14} className="text-muted-foreground group-hover:text-primary group-hover:translate-x-0.5 transition-all flex-shrink-0"/>
        </Link>;
    }

    def:pub page -> JsxElement {
        return <DocsLayout>
            <div>
                <div className="mb-8">
                    <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-primary/10 border border-primary/20 text-primary text-xs font-medium mb-4">
                        <Zap size={11}/>
                        Quickstart
                    </div>
                    <h1 className="text-3xl font-bold text-foreground tracking-tight mb-3">
                        Get started in minutes
                    </h1>
                    <p className="text-base text-muted-foreground leading-relaxed">
                        {"This guide walks you through connecting your first MCP server and using ProtoMCP's core features."}
                    </p>
                </div>

                <div className="mb-10">
                    <h2 className="text-lg font-semibold text-foreground mb-5 flex items-center gap-2">
                        <Server size={16} className="text-primary"/>
                        Step 1 — Connect an MCP server
                    </h2>

                    <div className="mb-5">
                        <h3 className="text-sm font-semibold text-foreground mb-3 flex items-center gap-2">
                            <List size={13} className="text-primary"/>
                            From the MCP Registry
                        </h3>
                        <p className="text-sm text-muted-foreground leading-relaxed mb-3">
                            {"ProtoMCP ships with a curated registry of public MCP servers. Head to "}
                            <Link to="/mcpregistry" className="text-primary hover:underline font-medium">MCP Servers List</Link>
                            {" to browse available servers. Each card shows the server name, description, transport type, and a direct connect button."}
                        </p>
                        <p className="text-sm text-muted-foreground leading-relaxed">
                            {"Click "}
                            <span className="font-medium text-foreground">Test Server</span>
                            {" on any registry server to open the connection modal with the URL pre-filled. Adjust authentication if needed, then click "}
                            <span className="font-medium text-foreground">Connect to Server</span>
                            {" to establish the session."}
                        </p>
                    </div>

                    <div className="mb-5">
                        <h3 className="text-sm font-semibold text-foreground mb-3 flex items-center gap-2">
                            <Globe size={13} className="text-primary"/>
                            Custom remote server
                        </h3>
                        <p className="text-sm text-muted-foreground leading-relaxed mb-3">
                            {"If you have a publicly hosted MCP server, open the Playground, click "}
                            <span className="font-medium text-foreground">+ Add</span>
                            {" in the sidebar, and paste the server URL. Select the transport (Streamable HTTP recommended, or SSE), add authentication if required, and connect."}
                        </p>
                        <InfoBox>
                            {"For a detailed walkthrough of connecting remote servers including authentication options, see the "}
                            <Link to="/docs/connect_mcp/remote" className="text-primary hover:underline font-medium">Remote MCP</Link>
                            {" guide."}
                        </InfoBox>
                    </div>

                    <div>
                        <h3 className="text-sm font-semibold text-foreground mb-3 flex items-center gap-2">
                            <Laptop size={13} className="text-primary"/>
                            Local server via ngrok
                        </h3>
                        <p className="text-sm text-muted-foreground leading-relaxed mb-3">
                            {"Running an MCP server on your machine? You can expose it to ProtoMCP using ngrok, which gives you a public HTTPS URL tunneling to your localhost port."}
                        </p>
                        <InfoBox>
                            {"Full ngrok setup instructions and jac-mcp examples are in the "}
                            <Link to="/docs/connect_mcp/local" className="text-primary hover:underline font-medium">Local MCP</Link>
                            {" guide."}
                        </InfoBox>
                    </div>
                </div>

                <div className="border-t border-border pt-8 mb-10">
                    <h2 className="text-lg font-semibold text-foreground mb-3 flex items-center gap-2">
                        <Search size={16} className="text-primary"/>
                        Step 2 — Explore Mode
                    </h2>
                    <p className="text-sm text-muted-foreground leading-relaxed mb-4">
                        {"Once connected, you land in Explore Mode. Here you can browse every capability your MCP server exposes — tools, prompts, and resources — and execute them interactively."}
                    </p>
                    <ul className="space-y-2 text-sm text-muted-foreground mb-4">
                        <li className="flex items-start gap-2">
                            <CheckCircle2 size={14} className="text-primary mt-0.5 flex-shrink-0"/>
                            Click any tool to open its parameter form and execute it
                        </li>
                        <li className="flex items-start gap-2">
                            <CheckCircle2 size={14} className="text-primary mt-0.5 flex-shrink-0"/>
                            Invoke prompts and view the structured message output
                        </li>
                        <li className="flex items-start gap-2">
                            <CheckCircle2 size={14} className="text-primary mt-0.5 flex-shrink-0"/>
                            Read resources and inspect content in JSON, text, or image format
                        </li>
                        <li className="flex items-start gap-2">
                            <CheckCircle2 size={14} className="text-primary mt-0.5 flex-shrink-0"/>
                            Search across all capabilities and view live request logs
                        </li>
                    </ul>
                    <SectionLink
                        to="/docs/explore_mode"
                        icon={<Search size={14}/>}
                        label="Explore Mode — full guide"
                        desc="Browse, execute, and inspect every MCP capability"
                    />
                </div>

                <div className="border-t border-border pt-8 mb-10">
                    <h2 className="text-lg font-semibold text-foreground mb-3 flex items-center gap-2">
                        <Bot size={16} className="text-primary"/>
                        Step 3 — Agent Mode
                    </h2>
                    <p className="text-sm text-muted-foreground leading-relaxed mb-4">
                        {"Switch to Agent Mode by clicking the "}
                        <span className="font-medium text-foreground">Agent</span>
                        {" tab in the playground. Configure your LLM provider and API key, then start chatting. The AI agent autonomously selects and executes MCP tools to answer your questions — you can watch every step unfold in the Trace panel."}
                    </p>
                    <ul className="space-y-2 text-sm text-muted-foreground mb-4">
                        <li className="flex items-start gap-2">
                            <CheckCircle2 size={14} className="text-primary mt-0.5 flex-shrink-0"/>
                            Supports OpenAI, Anthropic, Google Gemini, Groq, and Together AI
                        </li>
                        <li className="flex items-start gap-2">
                            <CheckCircle2 size={14} className="text-primary mt-0.5 flex-shrink-0"/>
                            Enable tool confirmation to approve each tool call before it runs
                        </li>
                        <li className="flex items-start gap-2">
                            <CheckCircle2 size={14} className="text-primary mt-0.5 flex-shrink-0"/>
                            Trace panel shows the full reasoning chain: thoughts, tool calls, results
                        </li>
                    </ul>
                    <SectionLink
                        to="/docs/agent_mode"
                        icon={<Bot size={14}/>}
                        label="Agent Mode — full guide"
                        desc="LLM setup, chat panel, trace panel, and session management"
                    />
                </div>

                <div className="rounded-xl border border-border bg-muted/30 p-5">
                    <p className="text-sm font-semibold text-foreground mb-3">Continue reading</p>
                    <div className="grid gap-2">
                        <SectionLink
                            to="/docs/connect_mcp/remote"
                            icon={<Globe size={13}/>}
                            label="Remote MCP"
                            desc="Connect any publicly hosted MCP server"
                        />
                        <SectionLink
                            to="/docs/connect_mcp/local"
                            icon={<Laptop size={13}/>}
                            label="Local MCP"
                            desc="Expose a local server with ngrok"
                        />
                    </div>
                </div>
            </div>
        </DocsLayout>;
    }
}
