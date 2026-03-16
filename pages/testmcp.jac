"""Connect to MCP Server – transport selection, URL, auth, and connect."""

cl import from "@jac/runtime" { useNavigate, Link }
cl import from "lucide-react" {
    Radio, Wifi, Server, Shield, ChevronRight,
    Loader2, AlertCircle
}
cl import from ..store.mcp_store { useMcpStore }
cl import from ..hooks.useMcpClient { useMcpClient }

cl {
    def:pub page -> JsxElement {
        navigate = useNavigate();
        addConnection = useMcpStore(lambda(s: Any) -> Any { return s.addConnection; });
        setActiveConnection = useMcpStore(lambda(s: Any) -> Any { return s.setActiveConnection; });
        client = useMcpClient();

        _qp = Reflect.construct(URLSearchParams, [window.location.search]);
        has transport: str = _qp.get("transport") or "streamable-http";
        has name: str = _qp.get("name") or "";
        has url: str = _qp.get("url") or "";
        has authType: str = _qp.get("auth") or "none";
        has authValue: str = "";
        has authHeaderName: str = "X-API-Key";
        has urlError: str = "";
        has connecting: bool = False;
        has connectionError: str = "";

        def validate -> bool {
            if not url.trim() {
                urlError = "Server URL is required";
                return False;
            }
            if not (url.startsWith("http://") or url.startsWith("https://") or url.startsWith("builtin://")) {
                urlError = "URL must start with http:// or https://";
                return False;
            }
            urlError = "";
            return True;
        }

        async def handleConnect -> None {
            if not validate() { return; }
            connecting = True;
            connectionError = "";

            conn = {
                "id": f"conn_{Date.now()}_{Math.random().toString(36).substr(2,5)}",
                "name": name.trim() or url.trim(),
                "url": url.trim(),
                "transport": transport,
                "auth": {
                    "type": authType,
                    "value": authValue,
                    "headerName": authHeaderName
                },
                "status": "disconnected",
                "serverInfo": None,
                "capabilities": None
            };

            addConnection(conn);
            setActiveConnection(conn.id);

            ok = await client.initialize(conn);
            if ok {
                await client.discoverCapabilities(conn);
                navigate(f"/playground/{conn.id}");
            } else {
                connectionError = "Failed to connect. Check the URL and transport mode.";
                connecting = False;
            }
        }

        return <div className="min-h-[calc(100vh-3.5rem)] bg-background relative overflow-hidden">
            <div className="absolute inset-0 bg-grid-pattern opacity-20"/>
            <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-primary/5 rounded-full blur-[120px] animate-glow"/>

            <div className="relative max-w-2xl mx-auto px-6 py-12">
                <div className="text-center mb-10">
                    <h1 className="text-3xl font-bold text-foreground mb-3">Connect to an MCP Server</h1>
                    <p className="text-muted-foreground">Enter your server details and choose the transport protocol</p>
                </div>

                <div className="bg-card border border-border rounded-xl overflow-hidden shadow-sm">
                    <div className="p-6 border-b border-border">
                        <label className="text-sm font-medium text-foreground mb-3 block">Transport Protocol</label>
                        <div className="grid grid-cols-2 gap-3">
                            <button
                                onClick={lambda -> None { transport = "streamable-http"; }}
                                className={f"flex items-start gap-3 p-4 rounded-lg border-2 transition-all text-left cursor-pointer {
                                    'border-primary bg-primary/5 shadow-sm shadow-primary/10' if transport == 'streamable-http' else 'border-border hover:border-primary/30 hover:bg-muted/50'
                                }"}
                            >
                                <Wifi size={20} className={f"mt-0.5 flex-shrink-0 {'text-primary' if transport == 'streamable-http' else 'text-muted-foreground'}"}/>
                                <div>
                                    <p className={f"text-sm font-semibold {'text-foreground' if transport == 'streamable-http' else 'text-muted-foreground'}"}>Streamable HTTP</p>
                                    <p className="text-xs text-muted-foreground mt-1">Standard HTTP POST transport. Recommended for most servers.</p>
                                </div>
                            </button>
                            <button
                                onClick={lambda -> None { transport = "sse"; }}
                                className={f"flex items-start gap-3 p-4 rounded-lg border-2 transition-all text-left cursor-pointer {
                                    'border-primary bg-primary/5 shadow-sm shadow-primary/10' if transport == 'sse' else 'border-border hover:border-primary/30 hover:bg-muted/50'
                                }"}
                            >
                                <Radio size={20} className={f"mt-0.5 flex-shrink-0 {'text-primary' if transport == 'sse' else 'text-muted-foreground'}"}/>
                                <div>
                                    <p className={f"text-sm font-semibold {'text-foreground' if transport == 'sse' else 'text-muted-foreground'}"}>SSE (Legacy)</p>
                                    <p className="text-xs text-muted-foreground mt-1">Server-Sent Events transport. For older MCP servers.</p>
                                </div>
                            </button>
                        </div>
                    </div>

                    <div className="p-6 flex flex-col gap-5">
                        <div className="flex flex-col gap-1.5">
                            <label className="text-sm font-medium text-foreground">Server URL <span className="text-destructive">*</span></label>
                            <input
                                type="text"
                                value={url}
                                onChange={lambda(e: Any) -> None { url = e.target.value; urlError = ""; connectionError = ""; }}
                                placeholder={f"{'https://example.com/mcp/' if transport == 'streamable-http' else 'https://example.com/sse'}"}
                                className="w-full bg-background border border-input rounded-lg px-4 py-2.5 text-sm text-foreground placeholder-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring/50 focus:border-ring transition-colors"
                            />
                            {urlError and <p className="text-xs text-destructive mt-1">{urlError}</p>}
                            {(url.includes("localhost") or url.includes("127.0.0.1")) and not url.startsWith("builtin://") and window.location.hostname != "localhost" and window.location.hostname != "127.0.0.1" and
                                <div className="p-3 bg-warning/10 border border-warning/20 rounded-lg mt-1">
                                    <p className="text-xs text-warning font-medium">⚠ Local server detected</p>
                                    <p className="text-xs text-muted-foreground mt-1">
                                        {"This app is remote and can't reach localhost. Run locally: "}
                                        <code className="font-mono bg-muted px-1.5 py-0.5 rounded text-foreground text-xs">jac serve</code>
                                    </p>
                                </div>
                            }
                        </div>

                        <div className="flex flex-col gap-1.5">
                            <label className="text-sm font-medium text-foreground">Server Name <span className="text-muted-foreground text-xs font-normal">(optional)</span></label>
                            <input
                                type="text"
                                value={name}
                                onChange={lambda(e: Any) -> None { name = e.target.value; }}
                                placeholder="My MCP Server"
                                className="w-full bg-background border border-input rounded-lg px-4 py-2.5 text-sm text-foreground placeholder-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring/50 focus:border-ring transition-colors"
                            />
                        </div>

                        <div className="flex flex-col gap-1.5">
                            <label className="text-sm font-medium text-foreground">Authentication</label>
                            <select
                                value={authType}
                                onChange={lambda(e: Any) -> None { authType = e.target.value; }}
                                className="w-full bg-background border border-input rounded-lg px-4 py-2.5 text-sm text-foreground focus:outline-none focus:ring-2 focus:ring-ring/50 focus:border-ring transition-colors cursor-pointer"
                            >
                                <option value="none">No Authentication</option>
                                <option value="bearer">Bearer Token</option>
                                <option value="apikey">API Key (Custom Header)</option>
                                <option value="basic">Basic Auth (Base64)</option>
                            </select>
                        </div>

                        {authType != "none" and <div className="flex flex-col gap-3 p-4 bg-muted/50 rounded-lg border border-border">
                            <div className="flex items-center gap-2 text-sm text-muted-foreground">
                                <Shield size={14}/>
                                <span className="font-medium">Authentication Details</span>
                            </div>
                            {authType == "apikey" and <div className="flex flex-col gap-1.5">
                                <label className="text-xs font-medium text-muted-foreground">Header Name</label>
                                <input
                                    type="text"
                                    value={authHeaderName}
                                    onChange={lambda(e: Any) -> None { authHeaderName = e.target.value; }}
                                    placeholder="X-API-Key"
                                    className="w-full bg-background border border-input rounded-lg px-3 py-2 text-sm text-foreground placeholder-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring/50 focus:border-ring transition-colors"
                                />
                            </div>}
                            <div className="flex flex-col gap-1.5">
                                <label className="text-xs font-medium text-muted-foreground">
                                    {"Token" if authType == "bearer" else "API Key Value" if authType == "apikey" else "Base64 Credentials"}
                                </label>
                                <input
                                    type="password"
                                    value={authValue}
                                    onChange={lambda(e: Any) -> None { authValue = e.target.value; }}
                                    placeholder={"eyJhbGciO..." if authType == "bearer" else "sk-..." if authType == "apikey" else "dXNlcjpwYXNz"}
                                    className="w-full bg-background border border-input rounded-lg px-3 py-2 text-sm text-foreground placeholder-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring/50 focus:border-ring transition-colors"
                                />
                            </div>
                        </div>}

                        {connectionError and <div className="flex items-center gap-2 p-3 bg-destructive/10 border border-destructive/20 rounded-lg">
                            <AlertCircle size={16} className="text-destructive flex-shrink-0"/>
                            <p className="text-sm text-destructive">{connectionError}</p>
                        </div>}
                    </div>

                    <div className="p-6 border-t border-border bg-muted/20 flex flex-col items-center gap-3">
                        <button
                            onClick={handleConnect}
                            disabled={Boolean(connecting)}
                            className="w-full flex items-center justify-center gap-2 bg-primary hover:bg-primary/90 text-primary-foreground font-semibold px-6 py-3 rounded-xl transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed shadow-lg shadow-primary/20 hover:shadow-primary/30 cursor-pointer"
                        >
                            {connecting and <Loader2 size={16} className="animate-spin"/>}
                            {not connecting and <Server size={16}/>}
                            {connecting and "Connecting..." or "Connect to Server"}
                            {not connecting and <ChevronRight size={16}/>}
                        </button>
                        <Link to="/mcpregistry" className="text-sm text-muted-foreground hover:text-primary transition-colors underline underline-offset-4">
                            Connect to a registered MCP server
                        </Link>
                    </div>
                </div>
            </div>
        </div>;
    }
}
