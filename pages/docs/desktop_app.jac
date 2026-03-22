"""Docs – Desktop App (Coming Soon)."""

cl import from "lucide-react" { Monitor, Bell, Laptop, Wifi, Zap, ArrowRight }
cl import from ...components.docs.docs_layout { DocsLayout }

cl {
    def FeatureRow(props: Any) -> JsxElement {
        icon = props.icon;
        title = props.title;
        desc = props.desc;
        return <div className="flex items-start gap-3 py-3 border-b border-border last:border-0">
            <div className="flex-shrink-0 w-8 h-8 rounded-lg bg-primary/10 border border-primary/20 flex items-center justify-center text-primary mt-0.5">
                {icon}
            </div>
            <div>
                <p className="text-sm font-medium text-foreground">{title}</p>
                <p className="text-sm text-muted-foreground mt-0.5 leading-relaxed">{desc}</p>
            </div>
        </div>;
    }

    def:pub page -> JsxElement {
        return <DocsLayout>
            <div>
                <div className="mb-10">
                    <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-primary/10 border border-primary/20 text-primary text-xs font-medium mb-4">
                        <Monitor size={11}/>
                        Desktop App
                    </div>
                    <h1 className="text-3xl font-bold text-foreground tracking-tight mb-3">
                        Desktop App
                    </h1>
                    <p className="text-base text-muted-foreground leading-relaxed">
                        {"A native desktop application for ProtoMCP is in development. It brings the full ProtoMCP experience to your desktop with direct localhost access — no ngrok or tunneling required."}
                    </p>
                </div>

                <div className="flex flex-col items-center justify-center py-12 mb-10 rounded-2xl border border-dashed border-border bg-muted/20">
                    <div className="w-16 h-16 rounded-2xl bg-primary/10 border border-primary/20 flex items-center justify-center text-primary mb-5">
                        <Monitor size={28}/>
                    </div>
                    <h2 className="text-xl font-bold text-foreground mb-2">Coming Soon</h2>
                    <p className="text-sm text-muted-foreground text-center max-w-sm leading-relaxed">
                        {"The ProtoMCP Desktop App is currently under development. Sign up to be notified when it launches."}
                    </p>
                </div>

                <div className="mb-10">
                    <h2 className="text-base font-semibold text-foreground mb-4">
                        What to expect
                    </h2>
                    <div className="border border-border rounded-xl overflow-hidden">
                        <FeatureRow
                            icon={<Laptop size={14}/>}
                            title="Direct localhost access"
                            desc="Connect to any MCP server running on your machine without ngrok or any tunneling setup. Just paste the localhost URL and connect."
                        />
                        <FeatureRow
                            icon={<Wifi size={14}/>}
                            title="All transport support"
                            desc="Natively supports Streamable HTTP, SSE, and stdio transports — including servers launched as local processes."
                        />
                        <FeatureRow
                            icon={<Zap size={14}/>}
                            title="Full ProtoMCP feature set"
                            desc="Everything you love about the web app — Explore Mode, Agent Mode, session history, and the MCP registry — available offline and without a browser."
                        />
                        <FeatureRow
                            icon={<Bell size={14}/>}
                            title="Native notifications"
                            desc="Get desktop notifications for agent task completions and tool execution results."
                        />
                    </div>
                </div>

                <div className="rounded-xl border border-primary/20 bg-primary/5 p-6">
                    <div className="flex items-start gap-3">
                        <Bell size={16} className="text-primary flex-shrink-0 mt-0.5"/>
                        <div>
                            <p className="text-sm font-semibold text-foreground mb-1">Get notified</p>
                            <p className="text-sm text-muted-foreground leading-relaxed mb-3">
                                {"Watch the "}
                                <a
                                    href="https://github.com/SahanUday/ProtoMCP"
                                    target="_blank"
                                    rel="noopener noreferrer"
                                    className="text-primary hover:underline font-medium"
                                >
                                    ProtoMCP GitHub repository
                                </a>
                                {" to be notified when the desktop app releases. In the meantime, use the web app with ngrok to work with local servers."}
                            </p>
                            <a
                                href="/docs/connect_mcp/local"
                                className="inline-flex items-center gap-1.5 text-sm font-medium text-primary hover:text-primary/80 transition-colors"
                            >
                                Set up ngrok for local servers
                                <ArrowRight size={12}/>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </DocsLayout>;
    }
}
