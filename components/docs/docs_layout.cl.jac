"""Shared layout for all /docs pages — sidebar + content area."""

cl import from "@jac/runtime" { Link, useLocation }
cl import from "lucide-react" {
    BookOpen, Zap, Plug, Monitor, Rss, Globe, Laptop,
    Search, Bot, ChevronDown, ChevronRight
}

cl {
    glob NAV_ITEMS: list = [
        {
            "label": "Overview",
            "to": "/docs",
            "icon": "BookOpen",
            "exact": True
        },
        {
            "label": "Quickstart",
            "to": "/docs/quickstart",
            "icon": "Zap"
        },
        {
            "label": "Connect MCP",
            "icon": "Plug",
            "children": [
                {"label": "Remote MCP", "to": "/docs/connect_mcp/remote", "icon": "Globe"},
                {"label": "Local MCP", "to": "/docs/connect_mcp/local", "icon": "Laptop"}
            ]
        },
        {
            "label": "Explore Mode",
            "to": "/docs/explore_mode",
            "icon": "Search"
        },
        {
            "label": "Agent Mode",
            "to": "/docs/agent_mode",
            "icon": "Bot"
        },
        {
            "label": "Desktop App",
            "to": "/docs/desktop_app",
            "icon": "Monitor"
        },
        {
            "label": "Blog",
            "to": "/docs/blog",
            "icon": "Rss"
        }
    ];

    def DocsSidebar(props: Any) -> JsxElement {
        location = useLocation();
        pathname = location.pathname;
        has connectOpen: bool = (pathname.startsWith("/docs/connect_mcp"));

        def NavIcon(iconName: str, sz: int = 15) -> JsxElement {
            if iconName == "BookOpen" { return <BookOpen size={sz}/>; }
            if iconName == "Zap" { return <Zap size={sz}/>; }
            if iconName == "Plug" { return <Plug size={sz}/>; }
            if iconName == "Globe" { return <Globe size={sz}/>; }
            if iconName == "Laptop" { return <Laptop size={sz}/>; }
            if iconName == "Search" { return <Search size={sz}/>; }
            if iconName == "Bot" { return <Bot size={sz}/>; }
            if iconName == "Monitor" { return <Monitor size={sz}/>; }
            if iconName == "Rss" { return <Rss size={sz}/>; }
            return <span/>;
        }

        return <aside className="w-60 flex-shrink-0 border-r border-border bg-background h-[calc(100vh-3.5rem)] sticky top-14 overflow-y-auto">
            <div className="px-3 py-5">
                <p className="px-3 mb-3 text-xs font-semibold text-muted-foreground uppercase tracking-wider">
                    Documentation
                </p>
                <nav className="flex flex-col gap-0.5">
                    {NAV_ITEMS.map(lambda (item: Any) -> JsxElement {
                        if item.children {
                            return <div key={item.label}>
                                <button
                                    onClick={lambda -> None { connectOpen = not connectOpen; }}
                                    className="w-full flex items-center justify-between gap-2.5 px-3 py-2 rounded-lg text-sm font-medium text-muted-foreground hover:text-foreground hover:bg-muted/60 transition-colors cursor-pointer"
                                >
                                    <span className="flex items-center gap-2.5">
                                        <span className="text-muted-foreground">
                                            {NavIcon(item.icon)}
                                        </span>
                                        {item.label}
                                    </span>
                                    {connectOpen
                                        and <ChevronDown size={13} className="opacity-50"/>
                                        or <ChevronRight size={13} className="opacity-50"/>}
                                </button>
                                {connectOpen and <div className="ml-3 mt-0.5 flex flex-col gap-0.5 border-l border-border pl-3">
                                    {item.children.map(lambda (child: Any) -> JsxElement {
                                        childPath = child["to"];
                                        active = (pathname == childPath);
                                        return <Link
                                            key={childPath}
                                            to={childPath}
                                            className={
                                                "flex items-center gap-2 px-3 py-1.5 rounded-lg text-sm transition-colors "
                                                + (active
                                                    and "bg-primary/10 text-primary font-medium"
                                                    or "text-muted-foreground hover:text-foreground hover:bg-muted/60")
                                            }
                                        >
                                            <span className={active and "text-primary" or "text-muted-foreground"}>
                                                {NavIcon(child.icon, 13)}
                                            </span>
                                            {child.label}
                                        </Link>;
                                    })}
                                </div>}
                            </div>;
                        }
                        itemPath = item["to"];
                        active = (pathname == itemPath);
                        return <Link
                            key={itemPath}
                            to={itemPath}
                            className={
                                "flex items-center gap-2.5 px-3 py-2 rounded-lg text-sm font-medium transition-colors "
                                + (active
                                    and "bg-primary/10 text-primary"
                                    or "text-muted-foreground hover:text-foreground hover:bg-muted/60")
                            }
                        >
                            <span className={active and "text-primary" or "text-muted-foreground"}>
                                {NavIcon(item.icon)}
                            </span>
                            {item.label}
                        </Link>;
                    })}
                </nav>
            </div>
        </aside>;
    }

    def:pub DocsLayout(props: Any) -> JsxElement {
        children = props.children;
        return <div className="flex min-h-[calc(100vh-3.5rem)]">
            <DocsSidebar/>
            <main className="flex-1 overflow-y-auto">
                <div className="max-w-3xl mx-auto px-8 py-10">
                    {children}
                </div>
            </main>
        </div>;
    }
}
