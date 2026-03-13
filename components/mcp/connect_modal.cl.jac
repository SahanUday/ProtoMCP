"""ConnectModal – popup to connect to an MCP server. Reuses testmcp form logic."""

cl import from "@jac/runtime" { useNavigate }
cl import from "lucide-react" {
    X, Radio, Wifi, Shield, Server, Loader2, AlertCircle, ChevronRight
}
cl import from ...store.mcp_store { useMcpStore }
cl import from ...hooks.useMcpClient { useMcpClient }

def:pub ConnectModal(props: Any) -> JsxElement {
    onClose = props.onClose;
    navigate = useNavigate();
    addConnection = useMcpStore(lambda(s: Any) -> Any { return s.addConnection; });
    setActiveConnection = useMcpStore(lambda(s: Any) -> Any { return s.setActiveConnection; });
    client = useMcpClient();

    has transport: str = "streamable-http";
    has name: str = "";
    has url: str = "";
    has authType: str = "none";
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
        if not (url.startsWith("http://") or url.startsWith("https://")) {
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

        connId = f"conn_{Date.now()}_{Math.random().toString(36).substr(2,5)}";
        conn = {
            "id": connId,
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
        setActiveConnection(connId);

        ok = await client.initialize(conn);
        if ok {
            await client.discoverCapabilities(conn);
            onClose();
            navigate(f"/playground/{connId}");
        } else {
            connectionError = "Failed to connect. Check the URL and transport mode.";
            connecting = False;
        }
    }

    return <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm" onClick={lambda(e: Any) -> None { if e.target == e.currentTarget { onClose(); } }}>
        <div className="bg-card border border-border rounded-2xl w-full max-w-lg shadow-2xl shadow-black/30 max-h-[90vh] overflow-hidden flex flex-col" onClick={lambda(e: Any) -> None { e.stopPropagation(); }}>
            <div className="flex items-center justify-between px-6 py-4 border-b border-border">
                <div className="flex items-center gap-2.5">
                    <div className="w-8 h-8 rounded-lg bg-primary/10 border border-primary/20 flex items-center justify-center">
                        <Server size={16} className="text-primary"/>
                    </div>
                    <h2 className="text-base font-semibold text-foreground">Connect MCP Server</h2>
                </div>
                <button onClick={onClose} className="p-1.5 rounded-lg text-muted-foreground hover:text-foreground hover:bg-muted transition-colors cursor-pointer">
                    <X size={16}/>
                </button>
            </div>

            <div className="flex-1 overflow-y-auto p-6 flex flex-col gap-5">
                <div>
                    <label className="text-sm font-medium text-foreground mb-2.5 block">Transport Protocol</label>
                    <div className="grid grid-cols-2 gap-3">
                        <button
                            onClick={lambda -> None { transport = "streamable-http"; }}
                            className={f"flex items-start gap-3 p-3.5 rounded-xl border-2 transition-all text-left cursor-pointer {
                                'border-primary bg-primary/5 shadow-sm shadow-primary/10' if transport == 'streamable-http' else 'border-border hover:border-primary/30'
                            }"}
                        >
                            <Wifi size={18} className={f"mt-0.5 flex-shrink-0 {'text-primary' if transport == 'streamable-http' else 'text-muted-foreground'}"}/>
                            <div>
                                <p className={f"text-sm font-semibold {'text-foreground' if transport == 'streamable-http' else 'text-muted-foreground'}"}>Streamable HTTP</p>
                                <p className="text-xs text-muted-foreground mt-0.5">Recommended</p>
                            </div>
                        </button>
                        <button
                            onClick={lambda -> None { transport = "sse"; }}
                            className={f"flex items-start gap-3 p-3.5 rounded-xl border-2 transition-all text-left cursor-pointer {
                                'border-primary bg-primary/5 shadow-sm shadow-primary/10' if transport == 'sse' else 'border-border hover:border-primary/30'
                            }"}
                        >
                            <Radio size={18} className={f"mt-0.5 flex-shrink-0 {'text-primary' if transport == 'sse' else 'text-muted-foreground'}"}/>
                            <div>
                                <p className={f"text-sm font-semibold {'text-foreground' if transport == 'sse' else 'text-muted-foreground'}"}>SSE (Legacy)</p>
                                <p className="text-xs text-muted-foreground mt-0.5">Older servers</p>
                            </div>
                        </button>
                    </div>
                </div>

                <div className="flex flex-col gap-1.5">
                    <label className="text-sm font-medium text-foreground">Server URL <span className="text-destructive">*</span></label>
                    <input
                        type="text"
                        value={url}
                        onChange={lambda(e: Any) -> None { url = e.target.value; urlError = ""; connectionError = ""; }}
                        placeholder={f"{'https://example.com/mcp/' if transport == 'streamable-http' else 'https://example.com/sse'}"}
                        className="w-full bg-background border border-input rounded-lg px-4 py-2.5 text-sm text-foreground placeholder-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring/50 transition-colors"
                    />
                    {urlError and <p className="text-xs text-destructive mt-1">{urlError}</p>}
                </div>

                <div className="flex flex-col gap-1.5">
                    <label className="text-sm font-medium text-foreground">Server Name <span className="text-muted-foreground text-xs font-normal">(optional)</span></label>
                    <input
                        type="text"
                        value={name}
                        onChange={lambda(e: Any) -> None { name = e.target.value; }}
                        placeholder="My MCP Server"
                        className="w-full bg-background border border-input rounded-lg px-4 py-2.5 text-sm text-foreground placeholder-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring/50 transition-colors"
                    />
                </div>

                <div className="flex flex-col gap-1.5">
                    <label className="text-sm font-medium text-foreground">Authentication</label>
                    <select
                        value={authType}
                        onChange={lambda(e: Any) -> None { authType = e.target.value; }}
                        className="w-full bg-background border border-input rounded-lg px-4 py-2.5 text-sm text-foreground focus:outline-none focus:ring-2 focus:ring-ring/50 cursor-pointer transition-colors"
                    >
                        <option value="none">No Authentication</option>
                        <option value="bearer">Bearer Token</option>
                        <option value="apikey">API Key (Custom Header)</option>
                        <option value="basic">Basic Auth (Base64)</option>
                    </select>
                </div>

                {authType != "none" and <div className="flex flex-col gap-3 p-4 bg-muted/30 rounded-xl border border-border">
                    <div className="flex items-center gap-2 text-xs text-muted-foreground">
                        <Shield size={12}/>
                        <span className="font-medium">Credentials</span>
                    </div>
                    {authType == "apikey" and <input
                        type="text"
                        value={authHeaderName}
                        onChange={lambda(e: Any) -> None { authHeaderName = e.target.value; }}
                        placeholder="X-API-Key"
                        className="w-full bg-background border border-input rounded-lg px-3 py-2 text-sm text-foreground placeholder-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring/50 transition-colors"
                    />}
                    <input
                        type="password"
                        value={authValue}
                        onChange={lambda(e: Any) -> None { authValue = e.target.value; }}
                        placeholder={"Token..." if authType == "bearer" else "Key value..." if authType == "apikey" else "base64 credentials..."}
                        className="w-full bg-background border border-input rounded-lg px-3 py-2 text-sm text-foreground placeholder-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring/50 transition-colors"
                    />
                </div>}

                {connectionError and <div className="flex items-start gap-2.5 p-3 bg-destructive/10 border border-destructive/20 rounded-xl">
                    <AlertCircle size={14} className="text-destructive flex-shrink-0 mt-0.5"/>
                    <p className="text-xs text-destructive leading-relaxed">{connectionError}</p>
                </div>}
            </div>

            <div className="flex items-center justify-end gap-3 px-6 py-4 border-t border-border bg-muted/10">
                <button onClick={onClose} className="px-4 py-2 text-sm text-muted-foreground hover:text-foreground rounded-lg hover:bg-muted transition-colors cursor-pointer">Cancel</button>
                <button
                    onClick={handleConnect}
                    disabled={Boolean(connecting)}
                    className="flex items-center gap-2 bg-primary hover:bg-primary/90 text-primary-foreground font-semibold px-5 py-2 rounded-xl transition-colors disabled:opacity-50 cursor-pointer shadow-sm shadow-primary/20"
                >
                    {connecting and <Loader2 size={14} className="animate-spin"/>}
                    {not connecting and <Server size={14}/>}
                    {connecting and "Connecting..." or "Connect Server"}
                </button>
            </div>
        </div>
    </div>;
}
