"""MCP Server Playground – 3-panel: server sidebar | explorer | logs."""

cl import from "@jac/runtime" { useParams, useNavigate }
cl import from "lucide-react" {
    PanelLeftClose, PanelLeftOpen, ScrollText, Plus, Server, Trash2,
    Wrench, MessageSquare, FolderOpen, RefreshCw, ChevronRight,
    Loader2, Search, Wifi, Radio, AlertTriangle
}
cl import from ...store.mcp_store { useMcpStore }
cl import from ...hooks.useMcpClient { useMcpClient }
cl import from ...components.mcp.history_panel { HistoryPanel }
cl import from ...components.mcp.connect_modal { ConnectModal }

cl {
    # ── Sidebar Server Item ─────────────────────────────────────────────────

    def SidebarItem(props: Any) -> JsxElement {
        conn = props.conn;
        isActive = props.isActive or False;
        onSelect = props.onSelect;
        onRemove = props.onRemove;

        statusColors = {
            "connected": "bg-success",
            "connecting": "bg-warning animate-pulse",
            "error": "bg-destructive",
            "disconnected": "bg-muted-foreground/40"
        };

        dotCls = statusColors[conn.status] if conn.status in statusColors else statusColors.disconnected;
        transportLabel = "HTTP" if conn.transport == "streamable-http" else "SSE";

        caps = conn.capabilities or {};
        totalCaps = len(caps.tools or []) + len(caps.prompts or []) + len(caps.resources or []);

        return <div
            className={f"flex items-center gap-2.5 px-3 py-2.5 rounded-xl cursor-pointer transition-all group {
                'bg-primary/10 border border-primary/20 shadow-sm shadow-primary/5' if isActive else 'hover:bg-muted/60 border border-transparent'
            }"}
            onClick={onSelect}
        >
            <span className={f"w-2 h-2 rounded-full flex-shrink-0 {dotCls}"}/>
            <div className="flex-1 min-w-0">
                <p className="text-sm font-medium text-foreground truncate">{conn.name}</p>
                <p className="text-xs text-muted-foreground truncate mt-0.5">{conn.url}</p>
            </div>
            <div className="flex items-center gap-1.5 flex-shrink-0" onClick={lambda(e: Any) -> None { e.stopPropagation(); }}>
                <span className="text-xs text-muted-foreground bg-muted px-1.5 py-0.5 rounded">{transportLabel}</span>
                {conn.status == "connected" and totalCaps > 0 and <span className="text-xs text-primary bg-primary/10 px-1.5 py-0.5 rounded">{totalCaps}</span>}
                <button
                    onClick={onRemove}
                    className="text-muted-foreground/30 hover:text-destructive p-1 rounded-lg hover:bg-muted transition-colors opacity-0 group-hover:opacity-100 cursor-pointer"
                    title="Remove server"
                >
                    <Trash2 size={12}/>
                </button>
            </div>
        </div>;
    }

    # ── Tab Button ──────────────────────────────────────────────────────────

    def TabBtn(props: Any) -> JsxElement {
        label = props.label;
        icon = props.icon;
        count = props.count;
        active = props.active or False;
        onClick = props.onClick;

        return <button
            className={f"flex items-center gap-1.5 px-4 py-2.5 text-sm font-medium border-b-2 transition-all cursor-pointer {
                'border-primary text-primary' if active else 'border-transparent text-muted-foreground hover:text-foreground hover:border-muted-foreground/20'
            }"}
            onClick={onClick}
        >
            {icon}
            {label}
            {count != None and count >= 0 and <span className={f"ml-1 text-xs px-1.5 py-0.5 rounded-full font-medium {
                'bg-primary/15 text-primary' if active else 'bg-muted text-muted-foreground'
            }"}>{count}</span>}
        </button>;
    }

    # ── Capability Item Components ──────────────────────────────────────────

    def ToolItem(props: Any) -> JsxElement {
        tool = props.tool;
        navigate = useNavigate();
        setSelectedTool = useMcpStore(lambda(s: Any) -> Any { return s.setSelectedTool; });

        paramCount = 0;
        if tool.inputSchema and tool.inputSchema.properties {
            paramCount = Object.keys(tool.inputSchema.properties).length;
        }

        return <button
            className="w-full flex items-center gap-3 p-4 bg-card/40 border border-border rounded-xl hover:border-primary/30 hover:bg-card/80 hover:shadow-sm hover:shadow-primary/5 transition-all text-left cursor-pointer group"
            onClick={lambda -> None {
                setSelectedTool(tool);
                navigate(f"/playground/tool/{encodeURIComponent(tool.name)}");
            }}
        >
            <div className="flex-shrink-0 w-9 h-9 rounded-lg bg-primary/10 border border-primary/20 flex items-center justify-center group-hover:bg-primary/15 transition-colors">
                <Wrench size={15} className="text-primary"/>
            </div>
            <div className="flex-1 min-w-0">
                <p className="text-sm font-semibold text-foreground font-mono">{tool.name}</p>
                {tool.description and <p className="text-xs text-muted-foreground mt-1 line-clamp-2 leading-relaxed">{tool.description}</p>}
            </div>
            <div className="flex items-center gap-2 flex-shrink-0">
                {paramCount > 0 and <span className="text-xs text-muted-foreground bg-muted px-2 py-0.5 rounded-full">{paramCount} params</span>}
                <ChevronRight size={14} className="text-muted-foreground/30 group-hover:text-primary transition-colors"/>
            </div>
        </button>;
    }

    def PromptItem(props: Any) -> JsxElement {
        prompt = props.prompt;
        navigate = useNavigate();
        setSelectedPrompt = useMcpStore(lambda(s: Any) -> Any { return s.setSelectedPrompt; });
        args = prompt.arguments or [];

        return <button
            className="w-full flex items-center gap-3 p-4 bg-card/40 border border-border rounded-xl hover:border-info/30 hover:bg-card/80 hover:shadow-sm hover:shadow-info/5 transition-all text-left cursor-pointer group"
            onClick={lambda -> None {
                setSelectedPrompt(prompt);
                navigate(f"/playground/prompt/{encodeURIComponent(prompt.name)}");
            }}
        >
            <div className="flex-shrink-0 w-9 h-9 rounded-lg bg-info/10 border border-info/20 flex items-center justify-center group-hover:bg-info/15 transition-colors">
                <MessageSquare size={15} className="text-info"/>
            </div>
            <div className="flex-1 min-w-0">
                <p className="text-sm font-semibold text-foreground font-mono">{prompt.name}</p>
                {prompt.description and <p className="text-xs text-muted-foreground mt-1 line-clamp-2 leading-relaxed">{prompt.description}</p>}
            </div>
            <div className="flex items-center gap-2 flex-shrink-0">
                {len(args) > 0 and <span className="text-xs text-muted-foreground bg-muted px-2 py-0.5 rounded-full">{len(args)} args</span>}
                <ChevronRight size={14} className="text-muted-foreground/30 group-hover:text-info transition-colors"/>
            </div>
        </button>;
    }

    def ResourceItem(props: Any) -> JsxElement {
        resource = props.resource;
        navigate = useNavigate();
        setSelectedResource = useMcpStore(lambda(s: Any) -> Any { return s.setSelectedResource; });

        return <button
            className="w-full flex items-center gap-3 p-4 bg-card/40 border border-border rounded-xl hover:border-warning/30 hover:bg-card/80 hover:shadow-sm hover:shadow-warning/5 transition-all text-left cursor-pointer group"
            onClick={lambda -> None {
                setSelectedResource(resource);
                navigate(f"/playground/resource/{encodeURIComponent(resource.uri)}");
            }}
        >
            <div className="flex-shrink-0 w-9 h-9 rounded-lg bg-warning/10 border border-warning/20 flex items-center justify-center group-hover:bg-warning/15 transition-colors">
                <FolderOpen size={15} className="text-warning"/>
            </div>
            <div className="flex-1 min-w-0">
                <p className="text-sm font-semibold text-foreground">{resource.name or resource.uri}</p>
                <p className="text-xs text-muted-foreground font-mono mt-0.5 truncate">{resource.uri}</p>
            </div>
            <div className="flex items-center gap-2 flex-shrink-0">
                {resource.mimeType and <span className="text-xs text-muted-foreground bg-muted px-2 py-0.5 rounded-full">{resource.mimeType}</span>}
                <ChevronRight size={14} className="text-muted-foreground/30 group-hover:text-warning transition-colors"/>
            </div>
        </button>;
    }

    # ── Empty State ─────────────────────────────────────────────────────────

    def EmptyState(props: Any) -> JsxElement {
        icon = props.icon;
        title = props.title;
        sub = props.sub;

        return <div className="flex flex-col items-center justify-center py-16 gap-3 text-muted-foreground">
            <div className="w-12 h-12 rounded-xl bg-muted/50 flex items-center justify-center">{icon}</div>
            <p className="text-sm font-medium">{title}</p>
            {sub and <p className="text-xs text-muted-foreground/70">{sub}</p>}
        </div>;
    }

    # ── Main Page ───────────────────────────────────────────────────────────

    def:pub page -> JsxElement {
        params = useParams();
        navigate = useNavigate();
        connId = params.id or "";

        connections = useMcpStore(lambda(s: Any) -> Any { return s.connections; });
        setActiveConnection = useMcpStore(lambda(s: Any) -> Any { return s.setActiveConnection; });
        removeConnection = useMcpStore(lambda(s: Any) -> Any { return s.removeConnection; });
        activeTab = useMcpStore(lambda(s: Any) -> Any { return s.activeTab; });
        setActiveTab = useMcpStore(lambda(s: Any) -> Any { return s.setActiveTab; });
        history = useMcpStore(lambda(s: Any) -> Any { return s.history; });
        client = useMcpClient();

        has sidebarOpen: bool = True;
        has logsPanelOpen: bool = False;
        has showConnectModal: bool = False;
        has searchQuery: str = "";
        has refreshing: bool = False;

        # Set active connection from URL param
        setActiveConnection(connId);

        # Find the connection for this page
        connection = None;
        for conn in connections {
            if conn.id == connId {
                connection = conn;
            }
        }

        # Connection not found
        if not connection {
            return <div className="flex flex-col items-center justify-center h-[calc(100vh-3.5rem)] gap-6 text-muted-foreground">
                <div className="w-16 h-16 rounded-2xl bg-destructive/5 border border-destructive/10 flex items-center justify-center">
                    <AlertTriangle size={28} className="text-destructive/40"/>
                </div>
                <div className="text-center">
                    <p className="text-lg font-semibold text-foreground">Server not found</p>
                    <p className="text-sm text-muted-foreground mt-1.5">This connection may have been removed</p>
                </div>
                <button
                    onClick={lambda -> None { navigate("/playground"); }}
                    className="inline-flex items-center gap-2 text-primary hover:text-primary/80 text-sm font-medium cursor-pointer"
                >
                    ← Back to servers
                </button>
            </div>;
        }

        async def handleRefresh -> None {
            if not connection or connection.status != "connected" { return; }
            refreshing = True;
            try {
                await client.discoverCapabilities(connection);
            } except Exception as e {
                refreshing = False;
                return;
            }
            refreshing = False;
        }

        sidebarIcon = <PanelLeftClose size={16}/> if sidebarOpen else <PanelLeftOpen size={16}/>;

        # ── Capability data ──
        caps = connection.capabilities or {};
        tools = caps.tools or [];
        prompts = caps.prompts or [];
        resources = caps.resources or [];
        serverInfo = connection.serverInfo or {};
        transportLabel = "Streamable HTTP" if connection.transport == "streamable-http" else "SSE";
        transportIcon = <Wifi size={12}/> if connection.transport == "streamable-http" else <Radio size={12}/>;

        currentItems = tools if activeTab == "tools" else (prompts if activeTab == "prompts" else resources);
        filtered = currentItems;
        if searchQuery {
            q = searchQuery.toLowerCase();
            filtered = currentItems.filter(lambda(item: Any) -> Any {
                nameMatch = (item.name or "").toLowerCase().includes(q);
                descMatch = (item.description or "").toLowerCase().includes(q);
                uriMatch = (item.uri or "").toLowerCase().includes(q);
                return nameMatch or descMatch or uriMatch;
            });
        }

        # ── Connecting state ──
        if connection.status == "connecting" {
            return <div className="flex flex-col items-center justify-center h-[calc(100vh-3.5rem)] gap-6">
                <div className="w-16 h-16 rounded-full border-2 border-primary/20 flex items-center justify-center">
                    <Loader2 size={28} className="text-primary animate-spin"/>
                </div>
                <div className="text-center">
                    <p className="text-sm font-medium text-foreground">Connecting to server...</p>
                    <p className="text-xs text-muted-foreground mt-1">{connection.name}</p>
                </div>
            </div>;
        }

        # ── Error state ──
        if connection.status == "error" {
            return <div className="flex flex-col items-center justify-center h-[calc(100vh-3.5rem)] gap-6 text-muted-foreground">
                <div className="w-16 h-16 rounded-2xl bg-destructive/5 border border-destructive/10 flex items-center justify-center">
                    <AlertTriangle size={28} className="text-destructive/40"/>
                </div>
                <div className="text-center">
                    <p className="text-lg font-semibold text-foreground">Connection failed</p>
                    <p className="text-sm text-muted-foreground mt-1.5">{connection.name}</p>
                </div>
                <div className="flex items-center gap-3">
                    <button
                        onClick={lambda -> None { navigate("/playground"); }}
                        className="px-4 py-2 text-sm text-muted-foreground hover:text-foreground rounded-lg hover:bg-muted transition-colors cursor-pointer"
                    >
                        ← Back
                    </button>
                    <button
                        onClick={lambda -> None { navigate("/testmcp"); }}
                        className="inline-flex items-center gap-2 bg-primary hover:bg-primary/90 text-primary-foreground font-medium px-4 py-2 rounded-xl transition-colors cursor-pointer"
                    >
                        Try Again
                    </button>
                </div>
            </div>;
        }

        # ── 3-Panel Layout ──
        return <div className="flex flex-col h-[calc(100vh-3.5rem)] overflow-hidden bg-background">
            <div className="flex items-center justify-between px-3 py-1.5 border-b border-border bg-card/60 backdrop-blur-sm flex-shrink-0">
                <div className="flex items-center gap-2">
                    <button
                        onClick={lambda -> None { sidebarOpen = not sidebarOpen; }}
                        className="text-muted-foreground hover:text-foreground p-1.5 rounded-lg hover:bg-muted transition-colors cursor-pointer"
                        title={f"{'Hide' if sidebarOpen else 'Show'} sidebar"}
                    >
                        {sidebarIcon}
                    </button>
                    {connection.status == "connected" and <div className="flex items-center gap-2 ml-1 px-2.5 py-1 rounded-lg bg-success/5 border border-success/10">
                        <span className="w-1.5 h-1.5 rounded-full bg-success"/>
                        <span className="text-xs font-medium text-foreground truncate max-w-48">{connection.name}</span>
                    </div>}
                </div>
                <button
                    onClick={lambda -> None { logsPanelOpen = not logsPanelOpen; }}
                    className={f"flex items-center gap-1.5 text-xs font-medium px-3 py-1.5 rounded-lg transition-all cursor-pointer {
                        'bg-primary/10 text-primary border border-primary/20 shadow-sm shadow-primary/5' if logsPanelOpen else 'text-muted-foreground hover:text-foreground hover:bg-muted border border-transparent'
                    }"}
                >
                    <ScrollText size={14}/>
                    Logs
                    {len(history) > 0 and <span className={f"text-xs px-1.5 py-0.5 rounded-full ml-0.5 {
                        'bg-primary/20 text-primary' if logsPanelOpen else 'bg-muted text-muted-foreground'
                    }"}>{len(history)}</span>}
                </button>
            </div>

            <div className="flex flex-1 overflow-hidden">
                {sidebarOpen and <aside className="w-64 flex-shrink-0 border-r border-border bg-card/30 overflow-hidden flex flex-col">
                    <div className="flex items-center justify-between px-4 py-3 border-b border-border">
                        <div className="flex items-center gap-2">
                            <Server size={14} className="text-primary"/>
                            <span className="text-sm font-semibold text-foreground">Servers</span>
                            {len(connections) > 0 and <span className="text-xs bg-primary/10 text-primary px-1.5 py-0.5 rounded-full font-medium">{len(connections)}</span>}
                        </div>
                        <button
                            onClick={lambda -> None { showConnectModal = True; }}
                            className="flex items-center gap-1 text-xs text-primary hover:bg-primary/10 px-2.5 py-1.5 rounded-lg transition-colors cursor-pointer font-medium"
                        >
                            <Plus size={14}/> Add
                        </button>
                    </div>

                    <div className="flex-1 overflow-y-auto p-2 flex flex-col gap-0.5">
                        {connections.map(lambda(conn: Any) -> Any {
                            return <SidebarItem
                                key={conn.id}
                                conn={conn}
                                isActive={conn.id == connId}
                                onSelect={lambda -> None { navigate(f"/playground/{conn.id}"); }}
                                onRemove={lambda -> None {
                                    removeConnection(conn.id);
                                    if conn.id == connId { navigate("/playground"); }
                                }}
                            />;
                        })}
                    </div>
                </aside>}

                <main className="flex-1 overflow-hidden flex flex-col">
                    {connection.status == "connected" and <>
                        <div className="flex items-center gap-3 px-5 py-3.5 bg-gradient-to-r from-card via-card to-primary/5 border-b border-border flex-shrink-0">
                            <span className="w-2.5 h-2.5 rounded-full bg-success shadow-sm shadow-success/30 flex-shrink-0"/>
                            <div className="flex-1 min-w-0">
                                <div className="flex items-center gap-2">
                                    <span className="text-sm font-semibold text-foreground truncate">{connection.name}</span>
                                    {serverInfo.version and <span className="text-xs bg-muted text-muted-foreground px-2 py-0.5 rounded-full">v{serverInfo.version}</span>}
                                    <span className="inline-flex items-center gap-1 text-xs bg-primary/10 text-primary px-2 py-0.5 rounded-full">
                                        {transportIcon}
                                        {transportLabel}
                                    </span>
                                </div>
                                <p className="text-xs text-muted-foreground truncate mt-0.5">{connection.url}</p>
                            </div>
                            <div className="flex items-center gap-3 flex-shrink-0 text-xs text-muted-foreground">
                                <span className="flex items-center gap-1"><Wrench size={12} className="text-primary"/>{len(tools)}</span>
                                <span className="flex items-center gap-1"><MessageSquare size={12} className="text-info"/>{len(prompts)}</span>
                                <span className="flex items-center gap-1"><FolderOpen size={12} className="text-warning"/>{len(resources)}</span>
                                <button
                                    onClick={handleRefresh}
                                    disabled={Boolean(refreshing)}
                                    className="text-muted-foreground hover:text-primary p-1.5 rounded-lg hover:bg-muted transition-colors disabled:opacity-50 cursor-pointer"
                                    title="Refresh capabilities"
                                >
                                    {refreshing and <Loader2 size={14} className="animate-spin"/> or <RefreshCw size={14}/>}
                                </button>
                            </div>
                        </div>

                        <div className="flex items-center border-b border-border bg-card/30 px-2 flex-shrink-0">
                            <TabBtn label="Tools" icon={<Wrench size={14}/>} count={len(tools)} active={activeTab == "tools"} onClick={lambda -> None { setActiveTab("tools"); searchQuery = ""; }}/>
                            <TabBtn label="Prompts" icon={<MessageSquare size={14}/>} count={len(prompts)} active={activeTab == "prompts"} onClick={lambda -> None { setActiveTab("prompts"); searchQuery = ""; }}/>
                            <TabBtn label="Resources" icon={<FolderOpen size={14}/>} count={len(resources)} active={activeTab == "resources"} onClick={lambda -> None { setActiveTab("resources"); searchQuery = ""; }}/>
                        </div>

                        <div className="flex-1 overflow-y-auto p-4">
                            {len(currentItems) > 3 and <div className="mb-4">
                                <div className="relative">
                                    <Search size={14} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-muted-foreground/50"/>
                                    <input
                                        type="text"
                                        value={searchQuery}
                                        onChange={lambda(e: Any) -> None { searchQuery = e.target.value; }}
                                        placeholder={f"Search {activeTab}..."}
                                        className="w-full bg-card border border-border rounded-xl pl-10 pr-4 py-2.5 text-sm text-foreground placeholder-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring/50 focus:border-ring transition-colors"
                                    />
                                </div>
                            </div>}

                            {len(currentItems) == 0 and <EmptyState
                                icon={<Wrench size={20} className="text-muted-foreground/40"/> if activeTab == "tools" else (<MessageSquare size={20} className="text-muted-foreground/40"/> if activeTab == "prompts" else <FolderOpen size={20} className="text-muted-foreground/40"/>)}
                                title={f"No {activeTab} available"}
                                sub={f"This server doesn't expose any {activeTab}"}
                            />}

                            {len(currentItems) > 0 and len(filtered) == 0 and <EmptyState
                                icon={<Search size={20} className="text-muted-foreground/40"/>}
                                title="No results"
                                sub="Try a different search term"
                            />}

                            {len(filtered) > 0 and <div className="flex flex-col gap-2">
                                {activeTab == "tools" and filtered.map(lambda(tool: Any) -> Any {
                                    return <ToolItem key={tool.name} tool={tool}/>;
                                })}
                                {activeTab == "prompts" and filtered.map(lambda(p: Any) -> Any {
                                    return <PromptItem key={p.name} prompt={p}/>;
                                })}
                                {activeTab == "resources" and filtered.map(lambda(r: Any) -> Any {
                                    return <ResourceItem key={r.uri} resource={r}/>;
                                })}
                            </div>}
                        </div>
                    </>}

                    {connection.status == "disconnected" and <div className="flex flex-col items-center justify-center h-full gap-4 text-muted-foreground">
                        <Server size={40} className="text-muted-foreground/20"/>
                        <div className="text-center">
                            <p className="text-base font-medium text-foreground">{connection.name}</p>
                            <p className="text-sm mt-1">Server disconnected</p>
                        </div>
                    </div>}
                </main>

                {logsPanelOpen and <aside className="w-80 flex-shrink-0 border-l border-border bg-card/20 overflow-hidden flex flex-col">
                    <HistoryPanel/>
                </aside>}
            </div>

            {showConnectModal and <ConnectModal onClose={lambda -> None { showConnectModal = False; }}/>}
        </div>;
    }
}
