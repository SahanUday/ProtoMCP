"""Prompt detail page – view prompt info, invoke with args, see messages."""

cl import from "@jac/runtime" { useParams, useNavigate }
cl import from "lucide-react" { ArrowLeft, MessageSquare, Copy, Check }
cl import from ....store.mcp_store { useMcpStore }
cl import from ....hooks.useMcpClient { useMcpClient }
cl import from ....components.ui.json_viewer { ContentViewer, JsonViewer }

cl {
    def:pub page -> JsxElement {
        params = useParams();
        navigate = useNavigate();
        promptName = decodeURIComponent(params.name or "");

        connections = useMcpStore(lambda(s: Any) -> Any { return s.connections; });
        activeConnectionId = useMcpStore(lambda(s: Any) -> Any { return s.activeConnectionId; });
        selectedPrompt = useMcpStore(lambda(s: Any) -> Any { return s.selectedPrompt; });
        client = useMcpClient();

        has loading: bool = False;
        has result: Any = None;
        has resultError: Any = None;
        has argValues: Any = {};
        has copied: bool = False;

        activeConnection = connections.find(lambda(c: Any) -> Any { return c.id == activeConnectionId; }) or None;

        backPath = f"/playground/{activeConnectionId}" if activeConnectionId else "/playground";

        prompt = selectedPrompt;
        if activeConnection and activeConnection.status == "connected" and activeConnection.capabilities {
            prompts = activeConnection.capabilities.prompts or [];
            found = prompts.find(lambda(p: Any) -> Any { return p.name == promptName; });
            if found { prompt = found; }
        }

        if not prompt {
            return <div className="flex flex-col items-center justify-center h-full gap-4 text-muted-foreground">
                <MessageSquare size={32} className="text-muted-foreground/20"/>
                <p className="text-sm">Prompt not found</p>
                <button onClick={lambda -> None { navigate("/playground"); }} className="text-primary hover:text-primary/80 text-sm cursor-pointer">← Back to explorer</button>
            </div>;
        }

        args = prompt.arguments or [];

        async def handleGetPrompt -> None {
            if not activeConnection { return; }
            loading = True;
            result = None;
            resultError = None;
            try {
                resp = await client.getPrompt(activeConnection, prompt.name, argValues);
                if resp and resp.error {
                    resultError = resp.error;
                } elif resp and resp.result {
                    result = resp.result;
                } else {
                    result = resp;
                }
            } except Exception as e {
                resultError = String(e);
            }
            loading = False;
        }

        def handleCopy -> None {
            try {
                data = result or resultError or {};
                navigator.clipboard.writeText(JSON.stringify(data, None, 2));
                copied = True;
                setTimeout(lambda -> None { copied = False; }, 2000);
            } except Exception as e {
                copied = False;
            }
        }

        return <div className="flex flex-col h-full overflow-hidden">
            <div className="flex items-center gap-3 px-5 py-3 border-b border-border bg-card/80 flex-shrink-0">
                <button
                    onClick={lambda -> None { navigate(backPath); }}
                    className="flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground transition-colors cursor-pointer"
                >
                    <ArrowLeft size={15}/>
                    Prompts
                </button>
                <span className="text-muted-foreground/30">/</span>
                <span className="text-sm font-semibold text-foreground font-mono">{prompt.name}</span>
            </div>

            <div className="flex-1 overflow-y-auto">
                <div className="max-w-3xl mx-auto px-6 py-8">
                    <div className="flex items-start gap-4 mb-8">
                        <div className="w-12 h-12 rounded-xl bg-info/10 border border-info/20 flex items-center justify-center flex-shrink-0">
                            <MessageSquare size={22} className="text-info"/>
                        </div>
                        <div className="flex-1">
                            <h1 className="text-xl font-bold text-foreground font-mono">{prompt.name}</h1>
                            {prompt.description and <p className="text-sm text-muted-foreground mt-1.5 leading-relaxed">{prompt.description}</p>}
                            {len(args) > 0 and <span className="inline-block text-xs bg-muted text-muted-foreground px-2.5 py-1 rounded-full mt-3">{len(args)} argument{"s" if len(args) != 1 else ""}</span>}
                        </div>
                    </div>

                    <div className="bg-card border border-border rounded-xl overflow-hidden mb-6">
                        <div className="px-5 py-3 border-b border-border bg-muted/30">
                            <h2 className="text-sm font-semibold text-foreground">Arguments</h2>
                        </div>
                        <div className="p-5 flex flex-col gap-4">
                            {len(args) == 0 and <p className="text-sm text-muted-foreground">This prompt has no arguments</p>}
                            {len(args) > 0 and args.map(lambda(arg: Any) -> Any {
                                return <div key={arg.name} className="flex flex-col gap-1.5">
                                    <div className="flex items-center gap-2">
                                        <label className="text-sm font-medium text-foreground">{arg.name}</label>
                                        {arg.required and <span className="text-xs text-destructive">*required</span>}
                                    </div>
                                    {arg.description and <p className="text-xs text-muted-foreground">{arg.description}</p>}
                                    <input
                                        type="text"
                                        value={argValues[arg.name] or ""}
                                        onChange={lambda(e: Any) -> None {
                                            newVals = Object.assign({}, argValues);
                                            newVals[arg.name] = e.target.value;
                                            argValues = newVals;
                                        }}
                                        placeholder={arg.description or f"Enter {arg.name}"}
                                        className="w-full bg-background border border-input rounded-lg px-4 py-2.5 text-sm text-foreground placeholder-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring/50 focus:border-ring transition-colors"
                                    />
                                </div>;
                            })}

                            <button
                                onClick={handleGetPrompt}
                                disabled={Boolean(loading)}
                                className="flex items-center justify-center gap-2 bg-primary hover:bg-primary/90 text-primary-foreground font-medium px-5 py-2.5 rounded-xl transition-colors disabled:opacity-50 cursor-pointer mt-2 w-fit"
                            >
                                {loading and <span className="w-4 h-4 border-2 border-primary-foreground/30 border-t-primary-foreground rounded-full animate-spin"/>}
                                <MessageSquare size={14}/>
                                Get Prompt
                            </button>
                        </div>
                    </div>

                    {resultError and <div className="bg-destructive/10 border border-destructive/20 rounded-xl p-5 mb-6">
                        <h3 className="text-sm font-semibold text-destructive mb-2">Error</h3>
                        <pre className="text-sm text-destructive/90 font-mono whitespace-pre-wrap break-words">{typeof(resultError) == "string" and resultError or JSON.stringify(resultError, None, 2)}</pre>
                    </div>}

                    {result and not resultError and <div className="bg-card border border-border rounded-xl overflow-hidden">
                        <div className="flex items-center justify-between px-5 py-3 border-b border-border bg-muted/30">
                            <h3 className="text-sm font-semibold text-foreground">Result</h3>
                            <button onClick={handleCopy} className="text-muted-foreground hover:text-foreground transition-colors cursor-pointer">
                                {copied and <Check size={14} className="text-success"/> or <Copy size={14}/>}
                            </button>
                        </div>
                        <div className="p-5">
                            {result.messages and <div className="flex flex-col gap-3">
                                {result.messages.map(lambda(msg: Any, i: Any) -> Any {
                                    isUser = msg.role == "user";
                                    return <div key={i} className={f"p-4 rounded-lg border {'border-primary/20 bg-primary/5' if isUser else 'border-success/20 bg-success/5'}"}>
                                        <p className={f"text-xs font-semibold mb-2 uppercase tracking-wide {'text-primary' if isUser else 'text-success'}"}>{msg.role}</p>
                                        <ContentViewer content={msg.content} mimeType="text"/>
                                    </div>;
                                })}
                            </div>}
                            {not result.messages and <JsonViewer data={result} title="Raw Result"/>}
                        </div>
                    </div>}
                </div>
            </div>
        </div>;
    }
}
