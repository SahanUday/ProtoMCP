"""LLM Store – React Context for LLM agent state only."""

cl import from "react" { createContext, useContext }

glob LlmCtx: Any = createContext(None);

def:pub LlmProvider(props: Any) -> JsxElement {
    # ── LLM Agentic Mode State ──
    has chatMessages: list = [];
    has agentRunning: bool = False;
    has agentSessionId: str = "";
    has agentTrace: list = [];
    has pendingConfirmation: Any = None;
    has llmConfig: dict = {
        "provider": "openai",
        "model": "gpt-4o-mini",
        "apiKey": "",
        "temperature": 0.7,
        "maxTokens": 4096,
        "systemPrompt": "You are a helpful assistant that can use tools to help answer questions. When using tools, always explain what you're doing and why.",
        "maxIterations": 10,
        "confirmMode": False,
        "enabledTools": None,
        "sessionKey": False
    };
    has totalTokenUsage: Any = {"prompt": 0, "completion": 0, "total": 0};

    # ── Session History State ──
    # Each entry: {id, title, createdAt, messages, trace, tokenUsage}
    # Max 5 entries; managed entirely by useAgentLoop hook.
    has sessionHistory: list = [];

    # ── LLM Agentic Mode Mutations ──
    def addChatMessage(msg: Any) -> None {
        chatMessages = lambda (prev: Any) -> Any { return prev.concat([msg]); };
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
    def updateAgentSessionId(sid: Any) -> None {
        agentSessionId = sid;
    }
    def addAgentTraceEvent(evt: Any) -> None {
        agentTrace = lambda (prev: Any) -> Any { return prev.concat([evt]); };
    }
    def clearAgentTrace -> None {
        agentTrace = [];
    }
    def updateLlmConfig(patch: Any) -> None {
        llmConfig = lambda (prev: Any) -> Any { return Object.assign({}, prev, patch); };
    }
    def addTokenUsage(usage: Any) -> None {
        totalTokenUsage = lambda (prev: Any) -> Any { return {
            "prompt": prev.prompt + (usage.prompt_tokens or 0),
            "completion": prev.completion + (usage.completion_tokens or 0),
            "total": prev.total + (usage.total_tokens or 0)
        }; };
    }
    def updatePendingConfirmation(conf: Any) -> None {
        pendingConfirmation = conf;
    }

    # ── Session History Mutations ──
    # Array logic (filter/concat/slice) lives in useAgentLoop where Any-typed
    # method chains work reliably; the store only holds and sets the value.
    def updateSessionHistory(hist: Any) -> None {
        sessionHistory = hist;
    }

    # Restore a saved session into the active chat view.
    def loadSession(msgs: Any, trace: Any, tokenUsage: Any, sessionId: str) -> None {
        chatMessages = msgs;
        agentTrace = trace;
        totalTokenUsage = tokenUsage;
        agentSessionId = sessionId;
    }

    store = {
        "chatMessages": chatMessages,
        "agentRunning": agentRunning,
        "agentSessionId": agentSessionId,
        "agentTrace": agentTrace,
        "pendingConfirmation": pendingConfirmation,
        "llmConfig": llmConfig,
        "totalTokenUsage": totalTokenUsage,
        "sessionHistory": sessionHistory,
        "addChatMessage": addChatMessage,
        "replaceChatMessages": replaceChatMessages,
        "clearChat": clearChat,
        "setAgentRunning": updateAgentRunning,
        "setAgentSessionId": updateAgentSessionId,
        "addAgentTraceEvent": addAgentTraceEvent,
        "clearAgentTrace": clearAgentTrace,
        "updateLlmConfig": updateLlmConfig,
        "addTokenUsage": addTokenUsage,
        "setPendingConfirmation": updatePendingConfirmation,
        "setSessionHistory": updateSessionHistory,
        "loadSession": loadSession
    };

    return
        <LlmCtx.Provider value={store}>
            {props.children}
        </LlmCtx.Provider>;
}

def:pub useLlmStore(selector: Any = None) -> Any {
    ctx = useContext(LlmCtx);
    if selector {
        return selector(ctx);
    }
    return ctx;
}
