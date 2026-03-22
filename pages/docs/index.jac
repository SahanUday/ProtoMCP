"""Docs – Overview (landing page for /docs)."""

cl import from "@jac/runtime" { Link }
cl import from "lucide-react" {
    Zap, Search, Bot, ArrowRight, Plug, Wrench,
    MessageSquare, FolderOpen, Shield, Globe
}
cl import from ...components.docs.docs_layout { DocsLayout }

cl {
    def FeatureCard(props: Any) -> JsxElement {
        icon = props.icon;
        title = props.title;
        desc = props.desc;
        to = props.to;
        return <Link
            to={to}
            className="group block bg-card border border-border rounded-xl p-5 hover:border-primary/40 hover:shadow-md hover:shadow-primary/5 transition-all duration-200"
        >
            <div className="flex items-start gap-4">
                <div className="flex-shrink-0 w-9 h-9 rounded-lg bg-primary/10 border border-primary/20 flex items-center justify-center text-primary group-hover:bg-primary/15 transition-colors">
                    {icon}
                </div>
                <div className="flex-1 min-w-0">
                    <div className="flex items-center justify-between gap-2">
                        <h3 className="text-sm font-semibold text-foreground">{title}</h3>
                        <ArrowRight size={13} className="text-muted-foreground group-hover:text-primary group-hover:translate-x-0.5 transition-all flex-shrink-0"/>
                    </div>
                    <p className="text-sm text-muted-foreground mt-1 leading-relaxed">{desc}</p>
                </div>
            </div>
        </Link>;
    }

    def CapBadge(props: Any) -> JsxElement {
        icon = props.icon;
        label = props.label;
        return <div className="flex items-center gap-2 px-3 py-2 rounded-lg bg-muted/50 border border-border text-sm text-muted-foreground">
            <span className="text-primary">{icon}</span>
            {label}
        </div>;
    }

    def:pub page -> JsxElement {
        return <DocsLayout>
            <div>
                <div className="mb-10">
                    <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-primary/10 border border-primary/20 text-primary text-xs font-medium mb-4">
                        <Globe size={11}/>
                        Official Documentation
                    </div>
                    <h1 className="text-3xl font-bold text-foreground tracking-tight mb-3">
                        Welcome to ProtoMCP
                    </h1>
                    <p className="text-base text-muted-foreground leading-relaxed max-w-2xl">
                        {"ProtoMCP is a browser-based MCP (Model Context Protocol) client that lets you connect, explore, and interact with any MCP server — no local setup required. Test tools, run prompts, browse resources, and drive AI agents, all from your browser."}
                    </p>
                </div>

                <div className="mb-10">
                    <h2 className="text-base font-semibold text-foreground mb-4">
                        What ProtoMCP supports
                    </h2>
                    <div className="flex flex-wrap gap-2">
                        <CapBadge icon={<Wrench size={13}/>} label="Tools"/>
                        <CapBadge icon={<MessageSquare size={13}/>} label="Prompts"/>
                        <CapBadge icon={<FolderOpen size={13}/>} label="Resources"/>
                        <CapBadge icon={<Shield size={13}/>} label="Auth (Bearer / API Key / Basic)"/>
                        <CapBadge icon={<Plug size={13}/>} label="Streamable HTTP & SSE"/>
                    </div>
                </div>

                <div className="mb-10">
                    <h2 className="text-base font-semibold text-foreground mb-4">
                        Explore the docs
                    </h2>
                    <div className="grid gap-3">
                        <FeatureCard
                            icon={<Zap size={15}/>}
                            title="Quickstart"
                            desc="Connect your first MCP server and start exploring its capabilities in under a minute."
                            to="/docs/quickstart"
                        />
                        <FeatureCard
                            icon={<Search size={15}/>}
                            title="Explore Mode"
                            desc="Browse tools, prompts, and resources on any connected MCP server. Execute them manually and inspect results."
                            to="/docs/explore_mode"
                        />
                        <FeatureCard
                            icon={<Bot size={15}/>}
                            title="Agent Mode"
                            desc="Chat with an AI agent that autonomously selects and calls MCP tools to answer your questions."
                            to="/docs/agent_mode"
                        />
                        <FeatureCard
                            icon={<Plug size={15}/>}
                            title="Connect MCP"
                            desc="Connect remote hosted servers or expose a locally running MCP server through ngrok."
                            to="/docs/connect_mcp/remote"
                        />
                    </div>
                </div>

                <div className="rounded-xl border border-border bg-muted/30 p-6">
                    <h2 className="text-sm font-semibold text-foreground mb-2">
                        Two powerful modes
                    </h2>
                    <p className="text-sm text-muted-foreground leading-relaxed mb-4">
                        {"ProtoMCP ships with two distinct interaction modes. Use Explore Mode to manually inspect and test any MCP capability, and Agent Mode to have an AI do the work for you — selecting tools, chaining calls, and reasoning through complex tasks."}
                    </p>
                    <div className="flex flex-wrap gap-3">
                        <Link
                            to="/docs/explore_mode"
                            className="inline-flex items-center gap-2 text-sm font-medium text-primary hover:text-primary/80 transition-colors"
                        >
                            <Search size={13}/>
                            Explore Mode guide
                            <ArrowRight size={12}/>
                        </Link>
                        <Link
                            to="/docs/agent_mode"
                            className="inline-flex items-center gap-2 text-sm font-medium text-primary hover:text-primary/80 transition-colors"
                        >
                            <Bot size={13}/>
                            Agent Mode guide
                            <ArrowRight size={12}/>
                        </Link>
                    </div>
                </div>
            </div>
        </DocsLayout>;
    }
}
