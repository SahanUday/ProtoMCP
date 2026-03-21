"""LlmConfigPanel – collapsible LLM configuration for agentic mode."""

cl import from "react" { useState, useEffect }
cl import from "lucide-react" {
    Settings,
    ChevronDown,
    ChevronRight,
    Eye,
    EyeOff,
    Wrench,
    Zap
}
cl import from ...store.mcp_store { useMcpStore }
cl import from ...store.llm_store { useLlmStore }

glob API_KEY_PLACEHOLDERS: Any = {
         "openai": "sk-...",
         "anthropic": "sk-ant-...",
         "google": "AIza...",
         "groq": "gsk_...",
         "together": "..."
     };

glob MODEL_SUGGESTIONS: Any = {
         "openai": ["gpt-4o", "gpt-4o-mini", "gpt-4-turbo", "o1-mini", "o3-mini"],
         "anthropic": [
             "claude-sonnet-4-20250514",
             "claude-haiku-4-20250414",
             "claude-opus-4-20250514"
         ],
         "google": [
             "gemini/gemini-2.5-pro-preview-05-06",
             "gemini/gemini-2.5-flash-preview-04-17",
             "gemini/gemini-2.0-flash",
             "gemini/gemini-2.0-flash-lite",
             "gemini/gemini-1.5-pro",
             "gemini/gemini-1.5-flash",
             "gemini/gemini-1.5-flash-8b"
         ],
         "groq": [
             "llama-3.1-70b-versatile",
             "llama-3.1-8b-instant",
             "mixtral-8x7b-32768"
         ],
         "together": [
             "meta-llama/Llama-3-70b-chat-hf",
             "mistralai/Mixtral-8x7B-Instruct-v0.1"
         ]
     };

# ── Tool Filter Section ──────────────────────────────────────────────────
def ToolFilterSection(props: Any) -> JsxElement {
    allTools = props.allTools;
    enabledTools = props.enabledTools;
    onToggle = props.onToggle;
    onSelectAll = props.onSelectAll;
    onClearAll = props.onClearAll;

    has open: bool = False;

    totalCount = len(allTools);
    enabledCount = enabledTools == None and totalCount or len(enabledTools or []);

    return
        <div className="border border-border rounded-lg overflow-hidden">
            <button
                onClick={lambda -> None { open = not open;}}
                className="w-full flex items-center gap-2 px-3 py-2 text-left hover:bg-muted/30 transition-colors cursor-pointer"
            >
                <Wrench size={12} className="text-primary flex-shrink-0"/>
                <span className="text-xs font-medium text-foreground flex-1">
                    Tool Access
                </span>
                <span className="text-xs text-muted-foreground">
                    {enabledCount}/{totalCount} enabled
                </span>
                {open
                and <ChevronDown size={12} className="text-muted-foreground"/>
                or <ChevronRight size={12} className="text-muted-foreground"/>}
            </button>
            {open
            and <div className="border-t border-border">
                <div className="flex items-center gap-2 px-3 py-1.5 bg-muted/20">
                    <button
                        onClick={onSelectAll}
                        className="text-xs text-primary hover:underline cursor-pointer"
                    >
                        All
                    </button>
                    <span className="text-muted-foreground/40">
                        ·
                    </span>
                    <button
                        onClick={onClearAll}
                        className="text-xs text-muted-foreground hover:text-foreground hover:underline cursor-pointer"
                    >
                        None
                    </button>
                </div>
                <div className="max-h-40 overflow-y-auto divide-y divide-border/50">
                    {allTools.map(
                        lambda (tool: Any) -> Any { isEnabled = enabledTools == None
                        or enabledTools.includes(tool.name);return
                            <label
                                key={tool.name}
                                className="flex items-center gap-2 px-3 py-1.5 hover:bg-muted/20 cursor-pointer"
                            >
                                <input
                                    type="checkbox"
                                    checked={Boolean(isEnabled)}
                                    onChange={lambda (e: Any) -> None { onToggle(
                                        tool.name, e.target.checked
                                    );}}
                                    className="accent-primary cursor-pointer"
                                />
                                <div className="flex-1 min-w-0">
                                    <p
                                        className="text-xs font-mono text-foreground truncate"
                                    >
                                        {tool.name}
                                    </p>
                                    {tool._serverName
                                    and <p
                                        className="text-xs text-muted-foreground/50 truncate"
                                    >
                                        {tool._serverName}
                                    </p>}
                                </div>
                            </label>; }
                    )}
                </div>
            </div>}
        </div>;
}

# ── Toggle Switch ────────────────────────────────────────────────────────
def ToggleSwitch(props: Any) -> JsxElement {
    checked = props.checked;
    onChange = props.onChange;
    label = props.label;
    description = props.description;

    return
        <label className="flex items-center gap-2.5 cursor-pointer group">
            <div
                className={f"relative w-8 h-4 rounded-full transition-colors flex-shrink-0 {'bg-primary'
                    if checked
                    else 'bg-muted-foreground/30'}"}
                onClick={lambda -> None { onChange(not checked);}}
            >
                <div
                    className={f"absolute top-0.5 w-3 h-3 rounded-full bg-white shadow-sm transition-transform {'translate-x-4'
                        if checked
                        else 'translate-x-0.5'}"}
                />
            </div>
            <div className="min-w-0">
                <p className="text-xs font-medium text-foreground leading-none">
                    {label}
                </p>
                {description
                and <p className="text-xs text-muted-foreground/60 mt-0.5">
                    {description}
                </p>}
            </div>
        </label>;
}

# ── Main Panel ───────────────────────────────────────────────────────────
def:pub LlmConfigPanel -> JsxElement {
    llmConfig = useLlmStore(lambda (s: Any) -> Any { return s.llmConfig; });
    updateLlmConfig = useLlmStore(lambda (s: Any) -> Any { return s.updateLlmConfig; });
    connections = useMcpStore(lambda (s: Any) -> Any { return s.connections; });

    has expanded: bool = False;
    has showKey: bool = False;

    # Local draft state – only written to the store when "Configure" is clicked
    has localProvider: str = "openai";
    has localModel: str = "gpt-4o-mini";
    has localApiKey: str = "";
    has localTemperature: float = 0.7;
    has localMaxTokens: int = 4096;
    has localSystemPrompt: str = "";
    has localMaxIterations: int = 10;
    has localConfirmMode: bool = False;
    has localEnabledTools: Any = None;
    has localSessionKey: bool = False;

    provider = llmConfig.provider or "openai";
    model = llmConfig.model or "gpt-4o-mini";
    localSuggestions = MODEL_SUGGESTIONS[localProvider] or [];

    # Collect all tools from all connected servers
    allTools = [];
    for conn in connections {
        if conn.status == "connected" {
            caps = conn.capabilities or {};
            for tool in (caps.tools or []) {
                if tool.name {
                    allTools.push(Object.assign({}, tool, {"_serverName": conn.name}));
                }
            }
        }
    }

    # Sync local draft from store whenever the dropdown opens
    useEffect(
        lambda -> Any { if expanded {
            localProvider = llmConfig.provider or "openai";
            localModel = llmConfig.model or "gpt-4o-mini";
            localApiKey = llmConfig.apiKey or "";
            localTemperature = llmConfig.temperature or 0.7;
            localMaxTokens = llmConfig.maxTokens or 4096;
            localSystemPrompt = llmConfig.systemPrompt or "";
            localMaxIterations = llmConfig.maxIterations or 10;
            localConfirmMode = Boolean(llmConfig.confirmMode);
            localEnabledTools = llmConfig.enabledTools;
            localSessionKey = Boolean(llmConfig.sessionKey);
        }return lambda -> None { }; },
        [expanded]
    );

    # Load API key from sessionStorage on mount
    useEffect(
        lambda -> Any { if llmConfig.sessionKey {
            saved = sessionStorage.getItem("mcp_llm_api_key");
            if saved and not llmConfig.apiKey {
                updateLlmConfig({"apiKey": saved});
            }
        }return lambda -> None { }; },
        []
    );

    def handleConfigure -> None {
        updateLlmConfig(
            {
                "provider": localProvider,
                "model": localModel,
                "apiKey": localApiKey,
                "temperature": localTemperature,
                "maxTokens": localMaxTokens,
                "systemPrompt": localSystemPrompt,
                "maxIterations": localMaxIterations,
                "confirmMode": localConfirmMode,
                "enabledTools": localEnabledTools,
                "sessionKey": localSessionKey
            }
        );
        if localSessionKey {
            if localApiKey {
                sessionStorage.setItem("mcp_llm_api_key", localApiKey);
            } else {
                sessionStorage.removeItem("mcp_llm_api_key");
            }
        } else {
            sessionStorage.removeItem("mcp_llm_api_key");
        }
        expanded = False;
    }

    def toggleLocalTool(toolName: str, checked: bool) -> None {
        current = localEnabledTools;
        allNames = allTools.map(lambda (t: Any) -> Any { return t.name; });
        if current == None {
            if not checked {
                localEnabledTools = allNames.filter(
                    lambda (n: Any) -> Any { return n != toolName; }
                );
            }
        } else {
            if checked {
                updated = current.concat([toolName]);
                if updated.length == allNames.length {
                    localEnabledTools = None;
                } else {
                    localEnabledTools = updated;
                }
            } else {
                localEnabledTools = current.filter(
                    lambda (n: Any) -> Any { return n != toolName; }
                );
            }
        }
    }

    return
        <div className="relative">
            <button
                onClick={lambda -> None { expanded = not expanded;}}
                className={f"flex items-center gap-1.5 text-xs px-2.5 py-1.5 rounded-lg transition-colors cursor-pointer {'bg-primary/10 border border-primary/20 text-primary'
                    if expanded
                    else 'hover:bg-muted/60 text-foreground border border-transparent'}"}
            >
                <Settings size={12} className="flex-shrink-0"/>
                <span className="font-medium">
                    {provider}
                </span>
                <span className="text-muted-foreground/50">
                    /
                </span>
                <span className="text-muted-foreground truncate max-w-28">
                    {model}
                </span>
                {llmConfig.apiKey
                and <span
                    className="w-1.5 h-1.5 rounded-full bg-success flex-shrink-0 ml-0.5"
                />}
                {not llmConfig.apiKey
                and <span className="text-warning font-medium ml-0.5">
                    No key
                </span>}
                <ChevronDown
                    size={11}
                    className={f"text-muted-foreground flex-shrink-0 transition-transform {'rotate-180'
                        if expanded
                        else ''}"}
                />
            </button>
            {expanded
            and <div
                className="fixed inset-0 z-40"
                onClick={lambda -> None { expanded = False;}}
            />}
            {expanded
            and <div
                className="absolute top-full left-0 mt-1.5 z-50 w-[380px] bg-card border border-border rounded-xl shadow-xl overflow-hidden"
            >
                <div className="px-4 py-4 space-y-3 max-h-[65vh] overflow-y-auto">
                    <div className="grid grid-cols-2 gap-3">
                        <div>
                            <label
                                className="block text-xs font-medium text-muted-foreground mb-1.5"
                            >
                                Provider
                            </label>
                            <select
                                value={localProvider}
                                onChange={lambda (e: Any) -> None { newProvider = e.target.value;newSuggestions = MODEL_SUGGESTIONS[
                                    newProvider
                                ]
                                or [];defaultModel = newSuggestions[0]
                                    if len(newSuggestions) > 0
                                    else "";localProvider = newProvider;localModel = defaultModel;}}
                                className="w-full bg-background border border-input rounded-lg px-3 py-2 text-sm text-foreground focus:outline-none focus:ring-2 focus:ring-ring/50 cursor-pointer"
                            >
                                <option value="openai">
                                    OpenAI
                                </option>
                                <option value="anthropic">
                                    Anthropic
                                </option>
                                <option value="google">
                                    Google Gemini
                                </option>
                                <option value="groq">
                                    Groq
                                </option>
                                <option value="together">
                                    Together AI
                                </option>
                            </select>
                        </div>
                        <div>
                            <label
                                className="block text-xs font-medium text-muted-foreground mb-1.5"
                            >
                                Model
                            </label>
                            <input
                                type="text"
                                list="model-suggestions-list"
                                value={localModel}
                                onChange={lambda (e: Any) -> None { localModel = e.target.value;}}
                                placeholder="Model name..."
                                className="w-full bg-background border border-input rounded-lg px-3 py-2 text-sm text-foreground placeholder-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring/50"
                            />
                            <datalist id="model-suggestions-list">
                                {localSuggestions.map(
                                    lambda (m: Any) -> Any { return
                                        <option key={m} value={m}/>; }
                                )}
                            </datalist>
                        </div>
                    </div>
                    <div>
                        <label
                            className="block text-xs font-medium text-muted-foreground mb-1.5"
                        >
                            API Key
                        </label>
                        <div className="relative">
                            <input
                                type={showKey and "text" or "password"}
                                value={localApiKey}
                                onChange={lambda (e: Any) -> None { localApiKey = e.target.value;}}
                                placeholder={API_KEY_PLACEHOLDERS[localProvider]
                                or "API key..."}
                                className="w-full bg-background border border-input rounded-lg px-3 py-2 pr-10 text-sm text-foreground font-mono placeholder-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring/50"
                            />
                            <button
                                onClick={lambda -> None { showKey = not showKey;}}
                                className="absolute right-2.5 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground cursor-pointer"
                            >
                                {showKey and <EyeOff size={14}/> or <Eye size={14}/>}
                            </button>
                        </div>
                        <div className="flex items-center justify-between mt-1.5">
                            <p className="text-xs text-muted-foreground/60">
                                Never sent to our servers.
                            </p>
                            <label className="flex items-center gap-1.5 cursor-pointer">
                                <input
                                    type="checkbox"
                                    checked={Boolean(localSessionKey)}
                                    onChange={lambda (e: Any) -> None { localSessionKey = e.target.checked;}}
                                    className="accent-primary cursor-pointer"
                                />
                                <span className="text-xs text-muted-foreground">
                                    Keep for session
                                </span>
                            </label>
                        </div>
                    </div>
                    <div>
                        <label
                            className="block text-xs font-medium text-muted-foreground mb-1.5"
                        >
                            System Prompt
                        </label>
                        <textarea
                            value={localSystemPrompt}
                            onChange={lambda (e: Any) -> None { localSystemPrompt = e.target.value;}}
                            rows={3}
                            className="w-full bg-background border border-input rounded-lg px-3 py-2 text-sm text-foreground placeholder-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring/50 resize-none"
                            placeholder="You are a helpful assistant..."
                        />
                    </div>
                    <div className="grid grid-cols-3 gap-3">
                        <div>
                            <label
                                className="block text-xs font-medium text-muted-foreground mb-1.5"
                            >
                                Temperature
                            </label>
                            <input
                                type="number"
                                min="0"
                                max="2"
                                step="0.1"
                                value={localTemperature}
                                onChange={lambda (e: Any) -> None { localTemperature = parseFloat(
                                    e.target.value
                                )
                                or 0.7;}}
                                className="w-full bg-background border border-input rounded-lg px-3 py-2 text-sm text-foreground focus:outline-none focus:ring-2 focus:ring-ring/50"
                            />
                        </div>
                        <div>
                            <label
                                className="block text-xs font-medium text-muted-foreground mb-1.5"
                            >
                                Max Tokens
                            </label>
                            <input
                                type="number"
                                min="100"
                                max="128000"
                                step="100"
                                value={localMaxTokens}
                                onChange={lambda (e: Any) -> None { localMaxTokens = parseInt(
                                    e.target.value
                                )
                                or 4096;}}
                                className="w-full bg-background border border-input rounded-lg px-3 py-2 text-sm text-foreground focus:outline-none focus:ring-2 focus:ring-ring/50"
                            />
                        </div>
                        <div>
                            <label
                                className="block text-xs font-medium text-muted-foreground mb-1.5"
                            >
                                Max Iters
                            </label>
                            <input
                                type="number"
                                min="1"
                                max="50"
                                step="1"
                                value={localMaxIterations}
                                onChange={lambda (e: Any) -> None { localMaxIterations = parseInt(
                                    e.target.value
                                )
                                or 10;}}
                                className="w-full bg-background border border-input rounded-lg px-3 py-2 text-sm text-foreground focus:outline-none focus:ring-2 focus:ring-ring/50"
                            />
                        </div>
                    </div>
                    <div className="pt-1 border-t border-border">
                        <ToggleSwitch
                            checked={Boolean(localConfirmMode)}
                            onChange={lambda (v: Any) -> None { localConfirmMode = v;}}
                            label="Tool Confirmation"
                            description="Approve each tool call before execution"
                        />
                    </div>
                    {len(allTools) > 0
                    and <ToolFilterSection
                        allTools={allTools}
                        enabledTools={localEnabledTools}
                        onToggle={toggleLocalTool}
                        onSelectAll={lambda -> None { localEnabledTools = None;}}
                        onClearAll={lambda -> None { localEnabledTools = [];}}
                    />}
                </div>
                <div className="px-4 py-3 border-t border-border bg-muted/20">
                    <button
                        onClick={handleConfigure}
                        className="w-full flex items-center justify-center gap-2 bg-primary hover:bg-primary/90 text-primary-foreground font-semibold text-sm px-4 py-2.5 rounded-lg transition-colors cursor-pointer"
                    >
                        <Zap size={14}/>
                        Configure
                    </button>
                </div>
            </div>}
        </div>;
}
