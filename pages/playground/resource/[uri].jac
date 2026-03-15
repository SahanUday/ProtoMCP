"""Resource detail page – view resource info, read content."""

cl import from "@jac/runtime" { useParams, useNavigate }
cl import from "lucide-react" { ArrowLeft, FolderOpen, FileText, Download, Copy, Check }
cl import from ....store.mcp_store { useMcpStore }
cl import from ....hooks.useMcpClient { useMcpClient }
cl import from ....components.ui.json_viewer { ContentViewer, JsonViewer }

cl {
    def:pub page -> JsxElement {
        params = useParams();
        navigate = useNavigate();
        resourceUri = decodeURIComponent(params.uri or "");

        connections = useMcpStore(lambda(s: Any) -> Any { return s.connections; });
        activeConnectionId = useMcpStore(lambda(s: Any) -> Any { return s.activeConnectionId; });
        selectedResource = useMcpStore(lambda(s: Any) -> Any { return s.selectedResource; });
        client = useMcpClient();

        has loading: bool = False;
        has content: Any = None;
        has mimeType: str = "text/plain";
        has error: Any = None;
        has copied: bool = False;

        activeConnection = connections.find(lambda(c: Any) -> Any { return c.id == activeConnectionId; }) or None;

        backPath = f"/playground/{activeConnectionId}" if activeConnectionId else "/playground";

        resource = selectedResource;
        if activeConnection and activeConnection.status == "connected" and activeConnection.capabilities {
            resources = activeConnection.capabilities.resources or [];
            found = resources.find(lambda(r: Any) -> Any { return r.uri == resourceUri; });
            if found { resource = found; }
        }

        if not resource {
            return <div className="flex flex-col items-center justify-center h-full gap-4 text-muted-foreground">
                <FolderOpen size={32} className="text-muted-foreground/20"/>
                <p className="text-sm">Resource not found</p>
                <button onClick={lambda -> None { navigate("/playground"); }} className="text-primary hover:text-primary/80 text-sm cursor-pointer">← Back to explorer</button>
            </div>;
        }

        async def handleRead -> None {
            if not activeConnection { return; }
            loading = True;
            error = None;
            content = None;
            try {
                resp = await client.readResource(activeConnection, resource.uri);
                if resp and resp.error {
                    error = resp.error;
                } elif resp and resp.result {
                    res = resp.result;
                    contents = res.contents or [];
                    if len(contents) > 0 {
                        firstContent = contents[0];
                        mimeType = firstContent.mimeType or "text/plain";
                        content = firstContent.text or firstContent.blob or firstContent;
                    } else {
                        content = res;
                    }
                } else {
                    content = resp;
                }
            } except Exception as e {
                error = String(e);
            }
            loading = False;
        }

        def handleCopy -> None {
            try {
                data = content or "";
                text = data if typeof(data) == "string" else JSON.stringify(data, None, 2);
                navigator.clipboard.writeText(text);
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
                    Resources
                </button>
                <span className="text-muted-foreground/30">/</span>
                <span className="text-sm font-semibold text-foreground truncate">{resource.name or resource.uri}</span>
            </div>

            <div className="flex-1 overflow-y-auto">
                <div className="max-w-3xl mx-auto px-6 py-8">
                    <div className="flex items-start gap-4 mb-8">
                        <div className="w-12 h-12 rounded-xl bg-warning/10 border border-warning/20 flex items-center justify-center flex-shrink-0">
                            <FileText size={22} className="text-warning"/>
                        </div>
                        <div className="flex-1 min-w-0">
                            <h1 className="text-xl font-bold text-foreground">{resource.name or resource.uri}</h1>
                            <p className="text-sm text-muted-foreground font-mono mt-1.5 break-all">{resource.uri}</p>
                            <div className="flex items-center gap-3 mt-3">
                                {resource.mimeType and <span className="text-xs bg-warning/10 text-warning px-2.5 py-1 rounded-full border border-warning/20">{resource.mimeType}</span>}
                                {resource.description and <span className="text-xs text-muted-foreground">{resource.description}</span>}
                            </div>
                        </div>
                    </div>

                    {not content and not error and <div className="bg-card border border-border rounded-xl p-6 text-center">
                        <button
                            onClick={handleRead}
                            disabled={Boolean(loading)}
                            className="inline-flex items-center gap-2 bg-primary hover:bg-primary/90 text-primary-foreground font-medium px-6 py-2.5 rounded-xl transition-colors disabled:opacity-50 cursor-pointer"
                        >
                            {loading and <span className="w-4 h-4 border-2 border-primary-foreground/30 border-t-primary-foreground rounded-full animate-spin"/>}
                            <Download size={14}/>
                            Read Resource
                        </button>
                    </div>}

                    {error and <div className="bg-destructive/10 border border-destructive/20 rounded-xl p-5 mb-6">
                        <h3 className="text-sm font-semibold text-destructive mb-2">Error</h3>
                        <pre className="text-sm text-destructive/90 font-mono whitespace-pre-wrap break-words">{typeof(error) == "string" and error or JSON.stringify(error, None, 2)}</pre>
                        <button
                            onClick={handleRead}
                            className="mt-3 text-sm text-destructive hover:text-destructive/80 underline cursor-pointer"
                        >Retry</button>
                    </div>}

                    {content and not error and <div className="bg-card border border-border rounded-xl overflow-hidden">
                        <div className="flex items-center justify-between px-5 py-3 border-b border-border bg-muted/30">
                            <div className="flex items-center gap-2">
                                <h3 className="text-sm font-semibold text-foreground">Content</h3>
                                <span className="text-xs bg-muted text-muted-foreground px-2 py-0.5 rounded-full">{mimeType}</span>
                            </div>
                            <div className="flex items-center gap-2">
                                <button onClick={handleCopy} className="text-muted-foreground hover:text-foreground transition-colors cursor-pointer" title="Copy">
                                    {copied and <Check size={14} className="text-success"/> or <Copy size={14}/>}
                                </button>
                                <button onClick={handleRead} className="text-muted-foreground hover:text-foreground transition-colors cursor-pointer" title="Refresh">
                                    <Download size={14}/>
                                </button>
                            </div>
                        </div>
                        <div className="p-5">
                            <ContentViewer content={content} mimeType={mimeType}/>
                        </div>
                    </div>}
                </div>
            </div>
        </div>;
    }
}
