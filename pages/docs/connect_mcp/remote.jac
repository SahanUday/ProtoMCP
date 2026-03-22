"""Docs – Connect MCP / Remote MCP."""

cl import from "@jac/runtime" { Link }
cl import from "lucide-react" {
    Globe, Plug, Shield, Key, Lock, User,
    CheckCircle2, ArrowRight, Info, Zap, Radio
}
cl import from ....components.docs.docs_layout { DocsLayout }
cl import from ....components.docs.code_block { CodeBlock }

cl {
    def InfoBox(props: Any) -> JsxElement {
        children = props.children;
        return <div className="flex gap-3 rounded-lg border border-primary/20 bg-primary/5 px-4 py-3 text-sm text-muted-foreground leading-relaxed">
            <Info size={14} className="text-primary flex-shrink-0 mt-0.5"/>
            <div>{children}</div>
        </div>;
    }

    def AuthCard(props: Any) -> JsxElement {
        icon = props.icon;
        title = props.title;
        desc = props.desc;
        badge = props.badge or None;
        return <div className="flex items-start gap-3 p-4 rounded-lg border border-border bg-card">
            <div className="flex-shrink-0 w-8 h-8 rounded-lg bg-primary/10 border border-primary/20 flex items-center justify-center text-primary">
                {icon}
            </div>
            <div className="flex-1">
                <div className="flex items-center gap-2 mb-1">
                    <p className="text-sm font-medium text-foreground">{title}</p>
                    {badge and <span className="text-xs px-2 py-0.5 rounded-full bg-success/10 border border-success/20 text-success font-medium">{badge}</span>}
                </div>
                <p className="text-xs text-muted-foreground leading-relaxed">{desc}</p>
            </div>
        </div>;
    }

    def:pub page -> JsxElement {
        codeExampleUrl = "https://your-mcp-server.example.com/mcp/";
        return <DocsLayout>
            <div>
                <div className="mb-8">
                    <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-primary/10 border border-primary/20 text-primary text-xs font-medium mb-4">
                        <Globe size={11}/>
                        Connect MCP
                    </div>
                    <h1 className="text-3xl font-bold text-foreground tracking-tight mb-3">
                        Remote MCP
                    </h1>
                    <p className="text-base text-muted-foreground leading-relaxed">
                        {"Connect to any publicly hosted MCP server using its HTTPS URL. Supports Streamable HTTP and SSE transports, with multiple authentication options."}
                    </p>
                </div>

                <div className="mb-10">
                    <h2 className="text-lg font-semibold text-foreground mb-4 flex items-center gap-2">
                        <Plug size={16} className="text-primary"/>
                        How to connect
                    </h2>

                    <ol className="space-y-5">
                        <li className="flex gap-4">
                            <div className="flex-shrink-0 w-6 h-6 rounded-full bg-primary/10 border border-primary/20 flex items-center justify-center text-primary text-xs font-bold mt-0.5">1</div>
                            <div className="flex-1">
                                <p className="text-sm font-medium text-foreground mb-1">Open the Playground</p>
                                <p className="text-sm text-muted-foreground leading-relaxed">
                                    {"Navigate to the "}
                                    <Link to="/playground" className="text-primary hover:underline font-medium">Playground</Link>
                                    {" and click "}
                                    <span className="font-medium text-foreground">+ Add</span>
                                    {" in the left sidebar to open the connection modal."}
                                </p>
                            </div>
                        </li>
                        <li className="flex gap-4">
                            <div className="flex-shrink-0 w-6 h-6 rounded-full bg-primary/10 border border-primary/20 flex items-center justify-center text-primary text-xs font-bold mt-0.5">2</div>
                            <div className="flex-1">
                                <p className="text-sm font-medium text-foreground mb-1">Enter the server URL</p>
                                <p className="text-sm text-muted-foreground leading-relaxed mb-2">
                                    {"Paste the full HTTPS URL of the remote server. For example:"}
                                </p>
                                <CodeBlock code={codeExampleUrl}/>
                            </div>
                        </li>
                        <li className="flex gap-4">
                            <div className="flex-shrink-0 w-6 h-6 rounded-full bg-primary/10 border border-primary/20 flex items-center justify-center text-primary text-xs font-bold mt-0.5">3</div>
                            <div className="flex-1">
                                <p className="text-sm font-medium text-foreground mb-1">Select the transport</p>
                                <div className="flex flex-col gap-2">
                                    <div className="flex items-start gap-3 px-3 py-2.5 rounded-lg border border-border bg-card">
                                        <Zap size={13} className="text-primary mt-0.5 flex-shrink-0"/>
                                        <div>
                                            <p className="text-sm font-medium text-foreground">Streamable HTTP</p>
                                            <p className="text-xs text-muted-foreground mt-0.5">{"Recommended. Modern bidirectional streaming over a single POST endpoint (/mcp)."}</p>
                                        </div>
                                    </div>
                                    <div className="flex items-start gap-3 px-3 py-2.5 rounded-lg border border-border bg-card">
                                        <Radio size={13} className="text-muted-foreground mt-0.5 flex-shrink-0"/>
                                        <div>
                                            <p className="text-sm font-medium text-foreground">SSE (Legacy)</p>
                                            <p className="text-xs text-muted-foreground mt-0.5">{"Server-Sent Events. Use this when the server only supports SSE transport (/sse endpoint)."}</p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </li>
                        <li className="flex gap-4">
                            <div className="flex-shrink-0 w-6 h-6 rounded-full bg-primary/10 border border-primary/20 flex items-center justify-center text-primary text-xs font-bold mt-0.5">4</div>
                            <div className="flex-1">
                                <p className="text-sm font-medium text-foreground mb-1">Add authentication (if required)</p>
                                <p className="text-sm text-muted-foreground leading-relaxed mb-3">
                                    {"If the server requires authentication, select the appropriate auth type and enter your credentials. Your API key or token is never sent to ProtoMCP's servers — it is only used to communicate directly with the MCP server."}
                                </p>
                            </div>
                        </li>
                        <li className="flex gap-4">
                            <div className="flex-shrink-0 w-6 h-6 rounded-full bg-primary/10 border border-primary/20 flex items-center justify-center text-primary text-xs font-bold mt-0.5">5</div>
                            <div className="flex-1">
                                <p className="text-sm font-medium text-foreground mb-1">Click Connect</p>
                                <p className="text-sm text-muted-foreground leading-relaxed">
                                    {"ProtoMCP will initialize the MCP session and discover all available tools, prompts, and resources. The server will appear in the sidebar with a green status dot once connected."}
                                </p>
                            </div>
                        </li>
                    </ol>
                </div>

                <div className="border-t border-border pt-8 mb-10">
                    <h2 className="text-lg font-semibold text-foreground mb-2 flex items-center gap-2">
                        <Shield size={16} className="text-primary"/>
                        Authentication options
                    </h2>
                    <p className="text-sm text-muted-foreground leading-relaxed mb-5">
                        {"ProtoMCP supports four authentication methods. Choose the one matching your server's requirements."}
                    </p>
                    <div className="flex flex-col gap-3">
                        <AuthCard
                            icon={<span className="text-xs font-bold">—</span>}
                            title="No Authentication"
                            desc="For open public servers that do not require any credentials."
                        />
                        <AuthCard
                            icon={<Key size={14}/>}
                            title="Bearer Token"
                            desc="Sends an Authorization: Bearer <token> header with every request. Most common for API-key-protected servers."
                            badge="Most common"
                        />
                        <AuthCard
                            icon={<Lock size={14}/>}
                            title="API Key (Custom Header)"
                            desc="Lets you specify a custom header name and value. Useful for servers that expect X-API-Key or similar non-standard headers. Also used to bypass the ngrok browser warning (set ngrok-skip-browser-warning: true)."
                        />
                        <AuthCard
                            icon={<User size={14}/>}
                            title="Basic Auth"
                            desc="Encodes username:password as a Base64 Authorization header. Used for servers behind HTTP basic authentication."
                        />
                    </div>
                </div>

                <div className="border-t border-border pt-8 mb-8">
                    <h2 className="text-lg font-semibold text-foreground mb-4 flex items-center gap-2">
                        <CheckCircle2 size={16} className="text-primary"/>
                        After connecting
                    </h2>
                    <ul className="space-y-2 text-sm text-muted-foreground">
                        <li className="flex items-start gap-2">
                            <CheckCircle2 size={13} className="text-primary mt-0.5 flex-shrink-0"/>
                            The server appears in the Playground sidebar with its name, URL, and transport type
                        </li>
                        <li className="flex items-start gap-2">
                            <CheckCircle2 size={13} className="text-primary mt-0.5 flex-shrink-0"/>
                            ProtoMCP automatically discovers all tools, prompts, and resources
                        </li>
                        <li className="flex items-start gap-2">
                            <CheckCircle2 size={13} className="text-primary mt-0.5 flex-shrink-0"/>
                            Use Explore Mode to test capabilities manually
                        </li>
                        <li className="flex items-start gap-2">
                            <CheckCircle2 size={13} className="text-primary mt-0.5 flex-shrink-0"/>
                            Switch to Agent Mode to have an AI drive tool calls automatically
                        </li>
                        <li className="flex items-start gap-2">
                            <CheckCircle2 size={13} className="text-primary mt-0.5 flex-shrink-0"/>
                            Your connection is saved for the session — it restores automatically on page refresh
                        </li>
                    </ul>
                </div>

                <div className="rounded-xl border border-border bg-muted/30 p-5">
                    <p className="text-sm font-semibold text-foreground mb-3">Next steps</p>
                    <div className="flex flex-col gap-2">
                        <Link
                            to="/docs/connect_mcp/local"
                            className="group flex items-center justify-between px-4 py-3 rounded-lg border border-border bg-card hover:border-primary/30 transition-all"
                        >
                            <div>
                                <p className="text-sm font-medium text-foreground group-hover:text-primary transition-colors">Local MCP</p>
                                <p className="text-xs text-muted-foreground mt-0.5">Expose a local server with ngrok</p>
                            </div>
                            <ArrowRight size={14} className="text-muted-foreground group-hover:text-primary transition-colors"/>
                        </Link>
                        <Link
                            to="/docs/explore_mode"
                            className="group flex items-center justify-between px-4 py-3 rounded-lg border border-border bg-card hover:border-primary/30 transition-all"
                        >
                            <div>
                                <p className="text-sm font-medium text-foreground group-hover:text-primary transition-colors">Explore Mode</p>
                                <p className="text-xs text-muted-foreground mt-0.5">Browse and test your server's capabilities</p>
                            </div>
                            <ArrowRight size={14} className="text-muted-foreground group-hover:text-primary transition-colors"/>
                        </Link>
                    </div>
                </div>
            </div>
        </DocsLayout>;
    }
}
