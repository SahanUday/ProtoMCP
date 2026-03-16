"""ProtoMCP – Landing Page."""

cl import from "@jac/runtime" { Link }
cl import from "lucide-react" {
    Zap, Wrench, MessageSquare, FolderOpen, Shield, Radio,
    ScrollText, Server, ArrowRight, Sparkles, Cable
}

cl {
    def FeatureCard(props: Any) -> JsxElement {
        icon = props.icon;
        title = props.title;
        description = props.description;

        return <div className="group relative bg-card border border-border rounded-xl p-6 hover:border-primary/30 transition-all duration-300 hover:shadow-lg hover:shadow-primary/5">
            <div className="flex items-start gap-4">
                <div className="flex-shrink-0 w-10 h-10 rounded-lg bg-primary/10 border border-primary/20 flex items-center justify-center text-primary group-hover:bg-primary/15 transition-colors">
                    {icon}
                </div>
                <div>
                    <h3 className="text-sm font-semibold text-foreground mb-1">{title}</h3>
                    <p className="text-sm text-muted-foreground leading-relaxed">{description}</p>
                </div>
            </div>
        </div>;
    }

    def ProtocolFlow() -> JsxElement {
        return <div className="flex items-center justify-center gap-3 sm:gap-6 py-10">
            <div className="flex flex-col items-center gap-2">
                <div className="w-14 h-14 sm:w-16 sm:h-16 rounded-xl bg-primary/10 border border-primary/20 flex items-center justify-center animate-float">
                    <Sparkles size={22} className="text-primary"/>
                </div>
                <span className="text-xs text-muted-foreground font-medium">Client</span>
            </div>
            <div className="flex items-center gap-1">
                <div className="w-6 sm:w-10 h-px bg-gradient-to-r from-primary/60 to-primary/20"/>
                <Cable size={16} className="text-primary/50 animate-glow"/>
                <div className="w-6 sm:w-10 h-px bg-gradient-to-l from-primary/60 to-primary/20"/>
            </div>
            <div className="flex flex-col items-center gap-2">
                <div className="w-14 h-14 sm:w-16 sm:h-16 rounded-xl bg-primary/10 border border-primary/20 flex items-center justify-center animate-float" style={{"animationDelay": "0.5s"}}>
                    <Server size={22} className="text-primary"/>
                </div>
                <span className="text-xs text-muted-foreground font-medium">MCP Server</span>
            </div>
            <div className="flex items-center gap-1">
                <div className="w-6 sm:w-10 h-px bg-gradient-to-r from-primary/60 to-primary/20"/>
                <Cable size={16} className="text-primary/50 animate-glow"/>
                <div className="w-6 sm:w-10 h-px bg-gradient-to-l from-primary/60 to-primary/20"/>
            </div>
            <div className="flex flex-col items-center gap-2">
                <div className="flex gap-1.5 sm:gap-2">
                    <div className="w-10 h-10 sm:w-12 sm:h-12 rounded-lg bg-primary/10 border border-primary/20 flex items-center justify-center animate-float" style={{"animationDelay": "1s"}}>
                        <Wrench size={22} className="text-primary"/>
                    </div>
                    <div className="w-10 h-10 sm:w-12 sm:h-12 rounded-lg bg-primary/10 border border-primary/20 flex items-center justify-center animate-float" style={{"animationDelay": "1.3s"}}>
                        <MessageSquare size={22} className="text-primary"/>
                    </div>
                    <div className="w-10 h-10 sm:w-12 sm:h-12 rounded-lg bg-primary/10 border border-primary/20 flex items-center justify-center animate-float" style={{"animationDelay": "1.6s"}}>
                        <FolderOpen size={22} className="text-primary"/>
                    </div>
                </div>
                <span className="text-xs text-muted-foreground font-medium">Capabilities</span>
            </div>
        </div>;
    }

    def:pub page -> JsxElement {
        return <div className="bg-background">
            <section className="relative overflow-hidden">
                <div className="absolute inset-0 bg-grid-pattern opacity-30"/>
                <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[500px] h-[500px] bg-primary/8 rounded-full blur-[100px] animate-glow"/>

                <div className="relative max-w-4xl mx-auto px-6 pt-20 pb-8 text-center">
                    <div className="inline-flex items-center gap-2 bg-primary/10 border border-primary/20 rounded-full px-4 py-1.5 mb-8">
                        <Zap size={14} className="text-primary"/>
                        <span className="text-sm font-medium text-primary">Model Context Protocol</span>
                    </div>

                    <h1 className="text-4xl sm:text-5xl lg:text-6xl font-bold tracking-tight text-foreground mb-6 leading-tight">
                        {"Explore, Test & Debug "}
                        <span className="text-primary">MCP Servers</span>
                    </h1>

                    <p className="text-lg text-muted-foreground max-w-2xl mx-auto mb-10 leading-relaxed">
                        {"The interactive lab for Model Context Protocol. Connect to any MCP server, "}
                        {"execute tools, invoke prompts, and browse resources — all from your browser."}
                    </p>

                    <div className="flex items-center justify-center gap-4 flex-wrap">
                        <Link to="/testmcp" className="inline-flex items-center gap-2 bg-primary hover:bg-primary/90 text-primary-foreground font-semibold px-7 py-3 rounded-xl transition-all duration-200 shadow-lg shadow-primary/25 hover:shadow-primary/40 hover:scale-[1.02]">
                            <Zap size={16}/>
                            Launch Playground
                            <ArrowRight size={16}/>
                        </Link>
                    </div>

                    <ProtocolFlow/>
                </div>
            </section>

            <section className="max-w-5xl mx-auto px-6 pb-24">
                <div className="text-center mb-12">
                    <h2 className="text-2xl font-bold text-foreground mb-3">Everything you need to test MCP</h2>
                    <p className="text-muted-foreground">A complete toolkit for exploring Model Context Protocol servers</p>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                    <FeatureCard
                        icon={<Wrench size={18}/>}
                        title="Execute Tools"
                        description="Run server tools with auto-generated forms from JSON Schema. See results instantly."
                    />
                    <FeatureCard
                        icon={<MessageSquare size={18}/>}
                        title="Invoke Prompts"
                        description="Invoke contextual prompts with arguments and preview generated messages."
                    />
                    <FeatureCard
                        icon={<FolderOpen size={18}/>}
                        title="Browse Resources"
                        description="Browse exposed resources with content preview and MIME type detection."
                    />
                    <FeatureCard
                        icon={<Shield size={18}/>}
                        title="Multiple Auth Methods"
                        description="Support for Bearer tokens, API keys with custom headers, and Basic authentication."
                    />
                    <FeatureCard
                        icon={<Radio size={18}/>}
                        title="Multiple Transports"
                        description="Connect via Streamable HTTP or SSE (Legacy) transport protocols."
                    />
                    <FeatureCard
                        icon={<ScrollText size={18}/>}
                        title="Real-time Logs"
                        description="Watch every JSON-RPC request and response in real-time with timing data."
                    />
                </div>
            </section>

            <footer className="border-t border-border py-8">
                <div className="max-w-6xl mx-auto px-6 flex items-center justify-between text-sm text-muted-foreground">
                    <div className="flex items-center gap-2.5">
                        <img src="static/assets/logo.png" alt="Jaseci" className="h-5 opacity-70"/>
                        <span>{"Built with "}<a href="https://jaseci.org" target="_blank" rel="noopener noreferrer" className="text-foreground hover:text-primary transition-colors font-medium">Jac</a>{" by Jaseci Labs"}</span>
                    </div>
                    <span className="hidden sm:block">ProtoMCP</span>
                </div>
            </footer>
        </div>;
    }
}
