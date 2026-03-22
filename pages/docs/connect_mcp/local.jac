"""Docs – Connect MCP / Local MCP."""

cl import from "@jac/runtime" { Link }
cl import from "lucide-react" {
    Laptop, Terminal, ExternalLink, ArrowRight, Info,
    CheckCircle2, Zap, Radio, Lock, Monitor, Package
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

    def TipBox(props: Any) -> JsxElement {
        children = props.children;
        return <div className="flex gap-3 rounded-lg border border-success/20 bg-success/5 px-4 py-3 text-sm text-muted-foreground leading-relaxed">
            <CheckCircle2 size={14} className="text-success flex-shrink-0 mt-0.5"/>
            <div>{children}</div>
        </div>;
    }

    def SectionHead(props: Any) -> JsxElement {
        icon = props.icon;
        title = props.title;
        return <h2 className="text-lg font-semibold text-foreground mb-4 flex items-center gap-2">
            <span className="text-primary">{icon}</span>
            {title}
        </h2>;
    }

    def:pub page -> JsxElement {
        has osTab: str = "linux";
        codeNgrokStep1 = "curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null";
        codeNgrokStep2 = "echo 'deb https://ngrok-agent.s3.amazonaws.com buster main' | sudo tee /etc/apt/sources.list.d/ngrok.list";
        codeNgrokStep3 = "sudo apt update && sudo apt install ngrok";
        codeMac = "brew install ngrok/ngrok/ngrok";
        codeWin = "choco install ngrok";
        codeAuthToken = "ngrok config add-authtoken YOUR_AUTHTOKEN_HERE";
        codePipInstall = "pip install jac-mcp";
        codeJacSse = "jac mcp --transport sse --port 3001";
        codeJacHttp = "jac mcp --transport streamable-http --port 3001";
        codeNgrokRun = "ngrok http 3001";
        codeNgrokOutput = "Forwarding   https://abcd1234.ngrok.io -> http://localhost:3001";
        return <DocsLayout>
            <div>
                <div className="mb-8">
                    <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-primary/10 border border-primary/20 text-primary text-xs font-medium mb-4">
                        <Laptop size={11}/>
                        Connect MCP
                    </div>
                    <h1 className="text-3xl font-bold text-foreground tracking-tight mb-3">
                        Local MCP
                    </h1>
                    <p className="text-base text-muted-foreground leading-relaxed">
                        {"Running an MCP server on your machine? Use ngrok to expose your local server with a public HTTPS URL and connect it to ProtoMCP from your browser."}
                    </p>
                </div>

                <div className="mb-10">
                    <SectionHead icon={<Terminal size={16}/>} title="Step 1 — Install ngrok"/>
                    <div className="flex gap-1 mb-3 border-b border-border">
                        <button
                            onClick={lambda -> None { osTab = "linux"; }}
                            className={f"px-4 py-2 text-sm font-medium transition-colors cursor-pointer border-b-2 -mb-px {'border-primary text-primary' if osTab == 'linux' else 'border-transparent text-muted-foreground hover:text-foreground'}"}
                        >
                            Linux
                        </button>
                        <button
                            onClick={lambda -> None { osTab = "mac"; }}
                            className={f"px-4 py-2 text-sm font-medium transition-colors cursor-pointer border-b-2 -mb-px {'border-primary text-primary' if osTab == 'mac' else 'border-transparent text-muted-foreground hover:text-foreground'}"}
                        >
                            macOS
                        </button>
                        <button
                            onClick={lambda -> None { osTab = "win"; }}
                            className={f"px-4 py-2 text-sm font-medium transition-colors cursor-pointer border-b-2 -mb-px {'border-primary text-primary' if osTab == 'win' else 'border-transparent text-muted-foreground hover:text-foreground'}"}
                        >
                            Windows
                        </button>
                    </div>
                    {osTab == "linux" and <div>
                        <p className="text-xs text-muted-foreground mb-2">Debian / Ubuntu</p>
                        <CodeBlock code={codeNgrokStep1}/>
                        <CodeBlock code={codeNgrokStep2}/>
                        <CodeBlock code={codeNgrokStep3}/>
                    </div>}
                    {osTab == "mac" and <div>
                        <p className="text-xs text-muted-foreground mb-2">Requires Homebrew</p>
                        <CodeBlock code={codeMac}/>
                    </div>}
                    {osTab == "win" and <div>
                        <p className="text-xs text-muted-foreground mb-2">Requires Chocolatey — or download the installer from ngrok.com/download</p>
                        <CodeBlock code={codeWin}/>
                    </div>}
                </div>

                <div className="border-t border-border pt-8 mb-10">
                    <SectionHead icon={<ExternalLink size={16}/>} title="Step 2 — Create a free ngrok account"/>
                    <p className="text-sm text-muted-foreground leading-relaxed mb-3">
                        {"Sign up for a free ngrok account to get your auth token:"}
                    </p>
                    <a
                        href="https://dashboard.ngrok.com/signup"
                        target="_blank"
                        rel="noopener noreferrer"
                        className="inline-flex items-center gap-2 text-sm font-medium text-primary hover:text-primary/80 transition-colors"
                    >
                        dashboard.ngrok.com/signup
                        <ExternalLink size={12}/>
                    </a>
                </div>

                <div className="border-t border-border pt-8 mb-10">
                    <SectionHead icon={<Lock size={16}/>} title="Step 3 — Add your auth token"/>
                    <p className="text-sm text-muted-foreground leading-relaxed mb-3">
                        {"After signing up, go to your dashboard to copy your auth token:"}
                    </p>
                    <a
                        href="https://dashboard.ngrok.com/get-started/your-authtoken"
                        target="_blank"
                        rel="noopener noreferrer"
                        className="inline-flex items-center gap-2 text-sm font-medium text-primary hover:text-primary/80 transition-colors mb-4"
                    >
                        dashboard.ngrok.com/get-started/your-authtoken
                        <ExternalLink size={12}/>
                    </a>
                    <p className="text-sm text-muted-foreground leading-relaxed mb-3">
                        {"Then run this command in your terminal to authenticate ngrok:"}
                    </p>
                    <CodeBlock code={codeAuthToken}/>
                </div>

                <div className="border-t border-border pt-8 mb-10">
                    <SectionHead icon={<Zap size={16}/>} title="Step 4 — Start your MCP server"/>
                    <p className="text-sm text-muted-foreground leading-relaxed mb-3">
                        {"Start your local MCP server first. Below is an example using "}
                        <span className="font-medium text-foreground">jac-mcp</span>
                        {", the Jaseci MCP server that exposes Jac language tools to AI clients."}
                    </p>

                    <div className="mb-5">
                        <p className="text-xs font-semibold text-muted-foreground uppercase tracking-wider mb-2">Install jac-mcp</p>
                        <CodeBlock code={codePipInstall}/>
                    </div>

                    <div className="mb-4">
                        <p className="text-xs font-semibold text-muted-foreground uppercase tracking-wider mb-2">Start with SSE transport</p>
                        <CodeBlock code={codeJacSse}/>
                    </div>
                    <div className="mb-4">
                        <p className="text-xs font-semibold text-muted-foreground uppercase tracking-wider mb-2">Or start with Streamable HTTP transport</p>
                        <CodeBlock code={codeJacHttp}/>
                    </div>

                    <InfoBox>
                        {"jac-mcp exposes Jac language grammar, documentation, code examples, and tools like validate_jac, format_jac, and py_to_jac — making it ideal for testing ProtoMCP with a feature-rich local server."}
                    </InfoBox>
                </div>

                <div className="border-t border-border pt-8 mb-10">
                    <SectionHead icon={<Terminal size={16}/>} title="Step 5 — Expose with ngrok"/>
                    <p className="text-sm text-muted-foreground leading-relaxed mb-3">
                        {"In a new terminal, run ngrok to create a public tunnel to your local server:"}
                    </p>
                    <CodeBlock code={codeNgrokRun}/>
                    <p className="text-sm text-muted-foreground leading-relaxed mt-3 mb-2">
                        {"ngrok will show output like this:"}
                    </p>
                    <CodeBlock code={codeNgrokOutput}/>
                    <p className="text-sm text-muted-foreground leading-relaxed mt-3">
                        {"Copy the "}
                        <span className="font-medium text-foreground">https://</span>
                        {" URL — you will use this in ProtoMCP."}
                    </p>
                </div>

                <div className="border-t border-border pt-8 mb-10">
                    <SectionHead icon={<Package size={16}/>} title="Step 6 — Connect in ProtoMCP"/>

                    <div className="mb-6">
                        <div className="flex items-center gap-2 mb-3">
                            <Zap size={14} className="text-primary"/>
                            <p className="text-sm font-semibold text-foreground">Streamable HTTP</p>
                            <span className="text-xs px-2 py-0.5 rounded-full bg-success/10 border border-success/20 text-success font-medium">Recommended</span>
                        </div>
                        <p className="text-sm text-muted-foreground leading-relaxed mb-3">
                            {"If you started jac-mcp with "}
                            <code className="text-xs bg-muted px-1.5 py-0.5 rounded font-mono">--transport streamable-http</code>
                            {", open the connection modal in ProtoMCP and:"}
                        </p>
                        <ol className="space-y-2 text-sm text-muted-foreground">
                            <li className="flex items-start gap-2">
                                <span className="flex-shrink-0 w-5 h-5 rounded-full bg-muted border border-border flex items-center justify-center text-xs font-bold mt-0.5">1</span>
                                Set the URL to your ngrok URL (e.g. <code className="text-xs bg-muted px-1 py-0.5 rounded font-mono">https://abcd1234.ngrok.io/mcp/</code>)
                            </li>
                            <li className="flex items-start gap-2">
                                <span className="flex-shrink-0 w-5 h-5 rounded-full bg-muted border border-border flex items-center justify-center text-xs font-bold mt-0.5">2</span>
                                Select <span className="font-medium text-foreground">Streamable HTTP</span> as the transport
                            </li>
                            <li className="flex items-start gap-2">
                                <span className="flex-shrink-0 w-5 h-5 rounded-full bg-muted border border-border flex items-center justify-center text-xs font-bold mt-0.5">3</span>
                                Click <span className="font-medium text-foreground">Connect</span>
                            </li>
                        </ol>
                    </div>

                    <div className="mb-4">
                        <div className="flex items-center gap-2 mb-3">
                            <Radio size={14} className="text-muted-foreground"/>
                            <p className="text-sm font-semibold text-foreground">SSE transport</p>
                        </div>
                        <p className="text-sm text-muted-foreground leading-relaxed mb-3">
                            {"If you started with "}
                            <code className="text-xs bg-muted px-1.5 py-0.5 rounded font-mono">--transport sse</code>
                            {", ngrok's free tier shows a browser warning page that blocks API clients. You need to bypass it using a custom header. In the connection modal:"}
                        </p>
                        <ol className="space-y-2 text-sm text-muted-foreground mb-3">
                            <li className="flex items-start gap-2">
                                <span className="flex-shrink-0 w-5 h-5 rounded-full bg-muted border border-border flex items-center justify-center text-xs font-bold mt-0.5">1</span>
                                Set the URL to your ngrok SSE URL (e.g. <code className="text-xs bg-muted px-1 py-0.5 rounded font-mono">https://abcd1234.ngrok.io/sse</code>)
                            </li>
                            <li className="flex items-start gap-2">
                                <span className="flex-shrink-0 w-5 h-5 rounded-full bg-muted border border-border flex items-center justify-center text-xs font-bold mt-0.5">2</span>
                                Select <span className="font-medium text-foreground">SSE (Legacy)</span> as the transport
                            </li>
                            <li className="flex items-start gap-2">
                                <span className="flex-shrink-0 w-5 h-5 rounded-full bg-muted border border-border flex items-center justify-center text-xs font-bold mt-0.5">3</span>
                                Under <span className="font-medium text-foreground">Authentication</span>, select <span className="font-medium text-foreground">API Key (Custom Header)</span>
                            </li>
                            <li className="flex items-start gap-2">
                                <span className="flex-shrink-0 w-5 h-5 rounded-full bg-muted border border-border flex items-center justify-center text-xs font-bold mt-0.5">4</span>
                                Set Header Name to <code className="text-xs bg-muted px-1 py-0.5 rounded font-mono">ngrok-skip-browser-warning</code>
                            </li>
                            <li className="flex items-start gap-2">
                                <span className="flex-shrink-0 w-5 h-5 rounded-full bg-muted border border-border flex items-center justify-center text-xs font-bold mt-0.5">5</span>
                                Set Value to <code className="text-xs bg-muted px-1 py-0.5 rounded font-mono">true</code>
                            </li>
                            <li className="flex items-start gap-2">
                                <span className="flex-shrink-0 w-5 h-5 rounded-full bg-muted border border-border flex items-center justify-center text-xs font-bold mt-0.5">6</span>
                                Click <span className="font-medium text-foreground">Connect</span>
                            </li>
                        </ol>
                        <TipBox>
                            {"The "}
                            <code className="text-xs bg-muted px-1 py-0.5 rounded font-mono">ngrok-skip-browser-warning</code>
                            {" header tells ngrok to skip the interstitial page and tunnel directly to your local server. Any non-empty value works."}
                        </TipBox>
                    </div>
                </div>

                <div className="border-t border-border pt-8 mb-10">
                    <div className="flex items-start gap-3 p-5 rounded-xl border border-primary/20 bg-primary/5">
                        <Monitor size={18} className="text-primary flex-shrink-0 mt-0.5"/>
                        <div>
                            <p className="text-sm font-semibold text-foreground mb-1">Skip ngrok with the Desktop App</p>
                            <p className="text-sm text-muted-foreground leading-relaxed mb-2">
                                {"The ProtoMCP Desktop App connects directly to "}
                                <code className="text-xs bg-muted px-1 py-0.5 rounded font-mono">localhost</code>
                                {" — no ngrok required. If you frequently work with local MCP servers, the desktop app offers a simpler, faster workflow."}
                            </p>
                            <Link
                                to="/docs/desktop_app"
                                className="inline-flex items-center gap-1.5 text-sm font-medium text-primary hover:text-primary/80 transition-colors"
                            >
                                Learn about the Desktop App
                                <ArrowRight size={12}/>
                            </Link>
                        </div>
                    </div>
                </div>

                <div className="rounded-xl border border-border bg-muted/30 p-5">
                    <p className="text-sm font-semibold text-foreground mb-3">Next steps</p>
                    <div className="flex flex-col gap-2">
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
                        <Link
                            to="/docs/agent_mode"
                            className="group flex items-center justify-between px-4 py-3 rounded-lg border border-border bg-card hover:border-primary/30 transition-all"
                        >
                            <div>
                                <p className="text-sm font-medium text-foreground group-hover:text-primary transition-colors">Agent Mode</p>
                                <p className="text-xs text-muted-foreground mt-0.5">Let an AI drive your MCP tools</p>
                            </div>
                            <ArrowRight size={14} className="text-muted-foreground group-hover:text-primary transition-colors"/>
                        </Link>
                    </div>
                </div>
            </div>
        </DocsLayout>;
    }
}
