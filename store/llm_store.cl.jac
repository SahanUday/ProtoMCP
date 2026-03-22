"""LLM Store – React Context for LLM agent state only."""
cl import from "react" { createContext, useContext, useEffect }

glob LlmCtx: Any = createContext(None);
glob SESSION_HISTORY_KEY: str = "mcp_agent_session_history";

def:pub LlmProvider(props: Any) -> JsxElement {
    # ── LLM Agentic Mode State ──
    has chatMessages: list = [];
    has agentRunning: bool = False;
    has agentStatus: str = "";
    has streamingContent: str = "";
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
    has sessionHistory: Any = [];

    useEffect(
        lambda -> Any { try {
            raw = sessionStorage.getItem(SESSION_HISTORY_KEY);
            if raw {
                saved = JSON.parse(raw);
                if saved and saved.length > 0 {
                    sessionHistory = saved.map(lambda (s: Any) -> Any { return s; });
                }
            }
        } except Exception { }return lambda -> None { }; },
        []
    );

    # ── LLM Agentic Mode Mutations ──
    def addChatMessage(msg: Any) -> None {
        chatMessages = lambda (prev: Any) -> Any { return prev.concat([msg]); };
    }
    def replaceChatMessages(msgs: Any) -> None {
        chatMessages = msgs;
    }
    def updateAgentStatus(status: str) -> None {
        agentStatus = status;
    }
    def appendStreamingContent(chunk: str) -> None {
        streamingContent = lambda (prev: Any) -> Any { return f"{prev}{chunk}"; };
    }
    def clearStreamingContent -> None {
        streamingContent = "";
    }
    def clearChat -> None {
        chatMessages = [];
        agentTrace = [];
        totalTokenUsage = {"prompt": 0, "completion": 0, "total": 0};
        agentStatus = "";
        streamingContent = "";
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
    def updateSessionHistory(hist: Any) -> None {
        sessionHistory = hist;
        try {
            sessionStorage.setItem(SESSION_HISTORY_KEY, JSON.stringify(hist));
        } except Exception { }
    }

    # Restore a saved session into the active chat view.
    def loadSession(msgs: Any, trace: Any, tokenUsage: Any, sessionId: str) -> None {
        chatMessages = msgs;
        agentTrace = trace;
        totalTokenUsage = tokenUsage;
        agentSessionId = sessionId;
        agentStatus = "";
        streamingContent = "";
    }

    store = {
        "chatMessages": chatMessages,
        "agentRunning": agentRunning,
        "agentStatus": agentStatus,
        "streamingContent": streamingContent,
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
        "setAgentStatus": updateAgentStatus,
        "appendStreamingContent": appendStreamingContent,
        "clearStreamingContent": clearStreamingContent,
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
