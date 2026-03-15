"""MCP Store – React Context, no external state library."""

cl import from "react" { createContext, useContext }

glob McpCtx: Any = createContext(None);
glob MAX_HISTORY: int = 200;

def:pub McpProvider(props: Any) -> JsxElement {
    has connections: Any = [];
    has activeConnectionId: Any = None;
    has history: Any = [];
    has activeTab: Any = "tools";
    has selectedTool: Any = None;
    has selectedPrompt: Any = None;
    has selectedResource: Any = None;
    has logsPanelOpen: bool = True;
    has sidebarOpen: bool = True;
    has addModalOpen: bool = False;

    def addConnection(conn: Any) -> None {
        connections = lambda(prev: Any) -> Any { return prev.concat([conn]); };
    }
    def removeConnection(id: Any) -> None {
        connections = lambda(prev: Any) -> Any { return prev.filter(lambda(c: Any) -> Any { return c.id != id; }); };
        activeConnectionId = lambda(prev: Any) -> Any {
            if prev == id { return None; }
            return prev;
        };
    }
    def updateConnection(id: Any, patch: Any) -> None {
        connections = lambda(prev: Any) -> Any {
            return prev.map(lambda(c: Any) -> Any {
                if c.id == id { return Object.assign({}, c, patch); }
                return c;
            });
        };
    }
    def addHistoryEntry(hist_entry: Any) -> None {
        history = lambda(prev: Any) -> Any { return [hist_entry].concat(prev).slice(0, MAX_HISTORY); };
    }
    def updateHistoryEntry(id: Any, patch: Any) -> None {
        history = lambda(prev: Any) -> Any {
            return prev.map(lambda(e: Any) -> Any {
                if e.id == id { return Object.assign({}, e, patch); }
                return e;
            });
        };
    }
    def clearHistory -> None { history = []; }
    def toggleLogsPanel -> None { logsPanelOpen = lambda(prev: Any) -> Any { return not prev; }; }
    def toggleSidebar -> None { sidebarOpen = lambda(prev: Any) -> Any { return not prev; }; }
    def openAddModal -> None { addModalOpen = True; }
    def closeAddModal -> None { addModalOpen = False; }

    store = {
        "connections": connections,
        "activeConnectionId": activeConnectionId,
        "addConnection": addConnection,
        "removeConnection": removeConnection,
        "updateConnection": updateConnection,
        "setActiveConnection": lambda(id: Any) -> None { activeConnectionId = id; },
        "history": history,
        "addHistoryEntry": addHistoryEntry,
        "updateHistoryEntry": updateHistoryEntry,
        "clearHistory": clearHistory,
        "activeTab": activeTab,
        "setActiveTab": lambda(tab: Any) -> None { activeTab = tab; },
        "selectedTool": selectedTool,
        "setSelectedTool": lambda(t: Any) -> None { selectedTool = t; },
        "selectedPrompt": selectedPrompt,
        "setSelectedPrompt": lambda(p: Any) -> None { selectedPrompt = p; },
        "selectedResource": selectedResource,
        "setSelectedResource": lambda(r: Any) -> None { selectedResource = r; },
        "logsPanelOpen": logsPanelOpen,
        "toggleLogsPanel": toggleLogsPanel,
        "sidebarOpen": sidebarOpen,
        "toggleSidebar": toggleSidebar,
        "addModalOpen": addModalOpen,
        "openAddModal": openAddModal,
        "closeAddModal": closeAddModal
    };

    return <McpCtx.Provider value={store}>{props.children}</McpCtx.Provider>;
}

def:pub useMcpStore(selector: Any = None) -> Any {
    ctx = useContext(McpCtx);
    if selector { return selector(ctx); }
    return ctx;
}
