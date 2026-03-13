"""Capability list items – ToolItem, PromptItem, ResourceItem."""

cl import from "@jac/runtime" { useNavigate }
cl import from "lucide-react" { Wrench, MessageSquare, FolderOpen, ChevronRight }
cl import from ...store.mcp_store { useMcpStore }

def:pub ToolItem(props: Any) -> JsxElement {
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

def:pub PromptItem(props: Any) -> JsxElement {
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

def:pub ResourceItem(props: Any) -> JsxElement {
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
