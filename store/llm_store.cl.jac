import from "react" { createContext, useContext }

glob McpCtx: Any = createContext(None);
def:pub McpProvider(props: Any) -> JsxElement {
    # ── LLM Agentic Mode State ──
    has chatMessages: Any = [];
    has agentRunning: bool = False;
    has agentTrace: Any = [];
    has pendingConfirmation: Any = None;
    has llmConfig: Any = {
        "provider": "openai",
        "model": "gpt-4o-mini",
        "apiKey": "",
        "temperature": 0.7,
        "maxTokens": 4096,
        "systemPrompt": "You are a helpful assistant that can use tools to help answer questions. When using tools, always explain what you're doing and why.",
        "maxIterations": 10,
        "agentMode": "perTurn",
        "confirmMode": False,
        "enabledTools": None,
        "sessionKey": False
    };
    has totalTokenUsage: Any = {"prompt": 0, "completion": 0, "total": 0};

    # ── LLM Agentic Mode Mutations ──
    def addChatMessage(msg: Any) -> None {
        chatMessages = lambda(prev: Any) -> Any { return prev.concat([msg]); };
    }
    def replaceChatMessages(msgs: Any) -> None {
        chatMessages = msgs;
    }
    def clearChat -> None {
        chatMessages = [];
        agentTrace = [];
        totalTokenUsage = {"prompt": 0, "completion": 0, "total": 0};
    }
    def updateAgentRunning(val: Any) -> None {
        agentRunning = val;
    }
    def addAgentTraceEvent(evt: Any) -> None {
        agentTrace = lambda(prev: Any) -> Any { return prev.concat([evt]); };
    }
    def clearAgentTrace -> None {
        agentTrace = [];
    }
    def updateLlmConfig(patch: Any) -> None {
        llmConfig = lambda(prev: Any) -> Any { return Object.assign({}, prev, patch); };
    }
    def addTokenUsage(usage: Any) -> None {
        totalTokenUsage = lambda(prev: Any) -> Any {
            return {
                "prompt": prev.prompt + (usage.prompt_tokens or 0),
                "completion": prev.completion + (usage.completion_tokens or 0),
                "total": prev.total + (usage.total_tokens or 0)
            };
        };
    }
    def updatePendingConfirmation(conf: Any) -> None {
        pendingConfirmation = conf;
    }

    store = {
        "closeAddModal": closeAddModal,
        "chatMessages": chatMessages,
        "agentRunning": agentRunning,
        "agentTrace": agentTrace,
        "pendingConfirmation": pendingConfirmation,
        "llmConfig": llmConfig,
        "totalTokenUsage": totalTokenUsage,
        "addChatMessage": addChatMessage,
        "replaceChatMessages": replaceChatMessages,
        "clearChat": clearChat,
        "setAgentRunning": updateAgentRunning,
        "addAgentTraceEvent": addAgentTraceEvent,
        "clearAgentTrace": clearAgentTrace,
        "updateLlmConfig": updateLlmConfig,
        "addTokenUsage": addTokenUsage,
        "setPendingConfirmation": updatePendingConfirmation
    };
    return <McpCtx.Provider value={store}>{props.children}</McpCtx.Provider>;
}

def:pub useMcpStore(selector: Any = None) -> Any {
    ctx = useContext(McpCtx);
    if selector { return selector(ctx); }
    return ctx;
}