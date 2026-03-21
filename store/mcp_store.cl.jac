"""MCP Store – React Context for MCP connection state only."""

cl import from "react" { createContext, useContext, useEffect }

glob McpCtx: Any = createContext(None);
glob MAX_HISTORY: int = 200;
glob CONN_STORAGE_KEY: str = "mcp_saved_connections";

def:pub McpProvider(props: Any) -> JsxElement {
    # ── MCP Connection State ──
    has connections: list = [];
    has activeConnectionId: Any = None;
    has history: list = [];
    has activeTab: str = "tools";
    has selectedTool: Any = None;
    has selectedPrompt: Any = None;
    has selectedResource: Any = None;

    # Load saved connection configs from sessionStorage on mount.
    # fromStorage flag lets McpReconnector distinguish these from newly added connections.
    useEffect(
        lambda -> Any { try {
            raw = sessionStorage.getItem(CONN_STORAGE_KEY);
            if raw {
                saved = JSON.parse(raw);
                if saved and saved.length > 0 {
                    connections = saved.map(
                        lambda (c: Any) -> Any { return {
                            "id": c.id,
                            "name": c.name,
                            "url": c.url,
                            "transport": c.transport,
                            "auth": c.auth,
                            "status": "disconnected",
                            "serverInfo": None,
                            "capabilities": None,
                            "fromStorage": True
                        }; }
                    );
                }
            }
        } except Exception as e { }return lambda -> None { }; },
        []
    );

    # ── MCP Connection Mutations ──
    def addConnection(conn: Any) -> None {
        connections = lambda (prev: Any) -> Any { newConns = prev.concat([conn]);configs = newConns.map(
            lambda (c: Any) -> Any { return {
                "id": c.id,
                "name": c.name,
                "url": c.url,
                "transport": c.transport,
                "auth": c.auth
            }; }
        );sessionStorage.setItem(CONN_STORAGE_KEY, JSON.stringify(configs));return newConns; };
    }
    def removeConnection(id: Any) -> None {
        connections = lambda (prev: Any) -> Any { newConns = prev.filter(
            lambda (c: Any) -> Any { return c.id != id; }
        );configs = newConns.map(
            lambda (c: Any) -> Any { return {
                "id": c.id,
                "name": c.name,
                "url": c.url,
                "transport": c.transport,
                "auth": c.auth
            }; }
        );sessionStorage.setItem(CONN_STORAGE_KEY, JSON.stringify(configs));return newConns; };
        activeConnectionId = lambda (prev: Any) -> Any { if prev == id {
            return None;
        }return prev; };
    }
    def updateConnection(id: Any, patch: Any) -> None {
        connections = lambda (prev: Any) -> Any { return prev.map(
            lambda (c: Any) -> Any { if c.id == id {
                return Object.assign({}, c, patch);
            }return c; }
        ); };
    }
    def addHistoryEntry(hist_entry: Any) -> None {
        history = lambda (prev: Any) -> Any { return [hist_entry].concat(prev).slice(
            0, MAX_HISTORY
        ); };
    }
    def updateHistoryEntry(id: Any, patch: Any) -> None {
        history = lambda (prev: Any) -> Any { return prev.map(
            lambda (e: Any) -> Any { if e.id == id {
                return Object.assign({}, e, patch);
            }return e; }
        ); };
    }
    def clearHistory -> None {
        history = [];
    }

    store = {
        "connections": connections,
        "activeConnectionId": activeConnectionId,
        "addConnection": addConnection,
        "removeConnection": removeConnection,
        "updateConnection": updateConnection,
        "setActiveConnection": lambda (id: Any) -> None { activeConnectionId = id;},
        "history": history,
        "addHistoryEntry": addHistoryEntry,
        "updateHistoryEntry": updateHistoryEntry,
        "clearHistory": clearHistory,
        "activeTab": activeTab,
        "setActiveTab": lambda (tab: Any) -> None { activeTab = tab;},
        "selectedTool": selectedTool,
        "setSelectedTool": lambda (t: Any) -> None { selectedTool = t;},
        "selectedPrompt": selectedPrompt,
        "setSelectedPrompt": lambda (p: Any) -> None { selectedPrompt = p;},
        "selectedResource": selectedResource,
        "setSelectedResource": lambda (r: Any) -> None { selectedResource = r;}
    };

    return
        <McpCtx.Provider value={store}>
            {props.children}
        </McpCtx.Provider>;
}

def:pub useMcpStore(selector: Any = None) -> Any {
    ctx = useContext(McpCtx);
    if selector {
        return selector(ctx);
    }
    return ctx;
}
