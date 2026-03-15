"""Tool detail page – view tool info, execute with form, see results."""

cl import from "@jac/runtime" { useParams, useNavigate }
cl import from "lucide-react" { ArrowLeft, Wrench, Zap, Copy, Check }
cl import from ....store.mcp_store { useMcpStore }
cl import from ....hooks.useMcpClient { useMcpClient }
cl import from ....components.ui.schema_form { SchemaForm }
cl import from ....components.ui.json_viewer { ContentViewer, JsonViewer }

cl {
    def:pub page -> JsxElement {
        params = useParams();
        navigate = useNavigate();
        toolName = decodeURIComponent(params.name or "");

        connections = useMcpStore(lambda(s: Any) -> Any { return s.connections; });
        activeConnectionId = useMcpStore(lambda(s: Any) -> Any { return s.activeConnectionId; });
        selectedTool = useMcpStore(lambda(s: Any) -> Any { return s.selectedTool; });
        client = useMcpClient();

        has loading: bool = False;
        has result: Any = None;
        has resultError: Any = None;
        has copied: bool = False;

        activeConnection = connections.find(lambda(c: Any) -> Any { return c.id == activeConnectionId; }) or None;

        backPath = f"/playground/{activeConnectionId}" if activeConnectionId else "/playground";

        tool = selectedTool;
        if activeConnection and activeConnection.status == "connected" and activeConnection.capabilities {
            tools = activeConnection.capabilities.tools or [];
            found = tools.find(lambda(t: Any) -> Any { return t.name == toolName; });
            if found { tool = found; }
        }

        if not tool {
            return <div className="flex flex-col items-center justify-center h-full gap-4 text-muted-foreground">
                <Wrench size={32} className="text-muted-foreground/20"/>
                <p className="text-sm">Tool not found</p>
                <button onClick={lambda -> None { navigate(backPath); }} className="text-primary hover:text-primary/80 text-sm cursor-pointer">← Back to explorer</button>
            </div>;
        }

        async def handleExecute(formValues: Any) -> None {
            if not activeConnection { return; }
            loading = True;
            result = None;
            resultError = None;
            try {
                resp = await client.callTool(activeConnection, tool.name, formValues);
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

        paramCount = 0;
        requiredParams = [];
        if tool.inputSchema and tool.inputSchema.properties {
            paramCount = Object.keys(tool.inputSchema.properties).length;
            requiredParams = tool.inputSchema.required or [];
        }

        return <div className="flex flex-col h-full overflow-hidden">
            <div className="flex items-center gap-3 px-5 py-3 border-b border-border bg-card/80 flex-shrink-0">
                <button
                    onClick={lambda -> None { navigate(backPath); }}
                    className="flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground transition-colors cursor-pointer"
                >
                    <ArrowLeft size={15}/>
                    Tools
                </button>
                <span className="text-muted-foreground/30">/</span>
                <span className="text-sm font-semibold text-foreground font-mono">{tool.name}</span>
            </div>

            <div className="flex-1 overflow-y-auto">
                <div className="max-w-3xl mx-auto px-6 py-8">
                    <div className="flex items-start gap-4 mb-8">
                        <div className="w-12 h-12 rounded-xl bg-primary/10 border border-primary/20 flex items-center justify-center flex-shrink-0">
                            <Wrench size={22} className="text-primary"/>
                        </div>
                        <div className="flex-1">
                            <h1 className="text-xl font-bold text-foreground font-mono">{tool.name}</h1>
                            {tool.description and <p className="text-sm text-muted-foreground mt-1.5 leading-relaxed">{tool.description}</p>}
                            <div className="flex items-center gap-3 mt-3">
                                {paramCount > 0 and <span className="text-xs bg-muted text-muted-foreground px-2.5 py-1 rounded-full">{paramCount} parameter{"s" if paramCount != 1 else ""}</span>}
                                {len(requiredParams) > 0 and <span className="text-xs bg-destructive/10 text-destructive px-2.5 py-1 rounded-full">{len(requiredParams)} required</span>}
                            </div>
                        </div>
                    </div>

                    <div className="bg-card border border-border rounded-xl overflow-hidden mb-6">
                        <div className="px-5 py-3 border-b border-border bg-muted/30">
                            <h2 className="text-sm font-semibold text-foreground">Parameters</h2>
                        </div>
                        <div className="p-5">
                            <SchemaForm
                                schema={tool.inputSchema or {}}
                                onSubmit={handleExecute}
                                submitLabel="Execute Tool"
                                loading={loading}
                            />
                        </div>
                    </div>

                    {resultError and <div className="bg-destructive/10 border border-destructive/20 rounded-xl p-5 mb-6">
                        <div className="flex items-center justify-between mb-2">
                            <h3 className="text-sm font-semibold text-destructive">Error</h3>
                            <button onClick={handleCopy} className="text-muted-foreground hover:text-foreground transition-colors">
                                {copied and <Check size={14} className="text-success"/> or <Copy size={14}/>}
                            </button>
                        </div>
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
                            <ContentViewer content={result}/>
                        </div>
                    </div>}
                </div>
            </div>
        </div>;
    }
}
