"""useMcpClient – hook that performs JSON-RPC calls against an MCP server.

Routes all calls through the backend /api/mcp-proxy endpoint which handles CORS.
"""

cl import from ..store.mcp_store { useMcpStore }

# Module-level session cache — updated synchronously, bypasses React state timing.
glob sessions: Any = {};

glob MCP_PROXY_ENDPOINT: str = "/function/mcp_proxy";

def buildRpcRequest(method: Any, params: Any = None) -> Any {
    req = {
        "jsonrpc": "2.0",
        "id": Math.random().toString(36).substr(2, 9),
        "method": method
    };
    if params != None {
        req.params = params;
    }
    return req;
}

def buildAuthHeaders(auth: Any) -> Any {
    headers = {};
    auth_type = auth.type;
    auth_value = auth.value or "";
    if auth_type == "bearer" and auth_value {
        headers.Authorization = "Bearer " + auth_value;
    } elif auth_type == "apikey" and auth_value {
        key_name = auth.headerName or "X-API-Key";
        headers[key_name] = auth_value;
    } elif auth_type == "basic" and auth_value {
        headers.Authorization = "Basic " + auth_value;
    }
    return headers;
}

def:pub useMcpClient -> Any {
    updateConnection = useMcpStore(lambda(s: Any) -> Any { return s.updateConnection; });
    addHistoryEntry = useMcpStore(lambda(s: Any) -> Any { return s.addHistoryEntry; });
    updateHistoryEntry = useMcpStore(lambda(s: Any) -> Any { return s.updateHistoryEntry; });

    # Core send function — routes through backend proxy function
    def sendRpc(connection: Any, method: Any, params: Any = None) -> Any {
        async def _exec -> Any {
            rpcReq = buildRpcRequest(method, params);
            authHeaders = buildAuthHeaders(connection.auth);

            # Attach session ID from synchronous cache (not React state)
            sid = sessions[connection.id];
            if sid {
                authHeaders["mcp-session-id"] = sid;
            }

            histId = f"hist_{Date.now()}_{Math.random().toString(36).substr(2,5)}";
            startMs = Date.now();

            histEntry = {
                "id": histId,
                "connectionId": connection.id,
                "serverName": connection.name,
                "method": method,
                "request": rpcReq,
                "status": "pending",
                "timestamp": Reflect.construct(Date, []).toISOString()
            };
            addHistoryEntry(histEntry);

            try {
                base_url = globalThis.__JAC_API_BASE_URL__;
                server_path = (base_url + MCP_PROXY_ENDPOINT) if base_url else MCP_PROXY_ENDPOINT;
                fetchResp = await fetch(server_path, {
                    "method": "POST",
                    "headers": {"Content-Type": "application/json"},
                    "body": JSON.stringify({
                        "url": connection.url,
                        "body": rpcReq,
                        "headers": authHeaders,
                        "transport": connection.transport or "streamable-http"
                    })
                });
                rawJson = await fetchResp.json();
                # @restspec wraps in TransportResponse: {status, data: {result: ...}}
                resp = rawJson.data.result if rawJson and rawJson.data and rawJson.data.result else None;
                durationMs = Date.now() - startMs;

                if not resp or not resp.ok {
                    errMsg = resp.error if resp else "No response";
                    updateHistoryEntry(histId, {
                        "status": "error",
                        "response": {"error": errMsg},
                        "durationMs": durationMs
                    });
                    return {"error": errMsg};
                }

                rpcResp = None;
                if resp.streaming and resp.events and len(resp.events) > 0 {
                    rpcResp = resp.events[0];
                } else {
                    rpcResp = resp.data;
                }

                # Save session ID synchronously in module-level cache
                if resp.sessionId {
                    sessions[connection.id] = resp.sessionId;
                    updateConnection(connection.id, {"sessionId": resp.sessionId});
                }

                updateHistoryEntry(histId, {
                    "status": "success",
                    "response": rpcResp,
                    "durationMs": durationMs
                });

                return rpcResp;
            } except Exception as e {
                durationMs = Date.now() - startMs;
                updateHistoryEntry(histId, {
                    "status": "error",
                    "response": {"error": String(e)},
                    "durationMs": durationMs
                });
                return {"error": String(e)};
            }
        }
        return _exec();
    }

    async def initialize(connection: Any) -> Any {
        # Clear stale session synchronously before connecting
        sessions[connection.id] = None;
        updateConnection(connection.id, {"status": "connecting", "sessionId": None});

        resp = await sendRpc(connection, "initialize", {
            "protocolVersion": "2024-11-05",
            "capabilities": {},
            "clientInfo": {"name": "mcp-protolab", "version": "1.0.0"}
        });
        if resp and not resp.error and resp.result {
            serverInfo = resp.result.serverInfo or {};
            capabs = resp.result.capabilities or {};
            updateConnection(connection.id, {
                "status": "connected",
                "serverInfo": serverInfo,
                "rawCapabilities": capabs
            });
            return True;
        } else {
            updateConnection(connection.id, {"status": "error"});
            return False;
        }
    }

    async def discoverCapabilities(connection: Any) -> Any {
        [toolsResp, promptsResp, resourcesResp] = await Promise.all([
            sendRpc(connection, "tools/list"),
            sendRpc(connection, "prompts/list"),
            sendRpc(connection, "resources/list")
        ]);

        tools = toolsResp.result.tools if toolsResp and toolsResp.result and toolsResp.result.tools else [];
        prompts = promptsResp.result.prompts if promptsResp and promptsResp.result and promptsResp.result.prompts else [];
        resources = resourcesResp.result.resources if resourcesResp and resourcesResp.result and resourcesResp.result.resources else [];

        updateConnection(connection.id, {
            "capabilities": {
                "tools": tools,
                "prompts": prompts,
                "resources": resources
            }
        });
        return {"tools": tools, "prompts": prompts, "resources": resources};
    }

    async def callTool(connection: Any, name: Any, args: Any) -> Any {
        resp = await sendRpc(connection, "tools/call", {
            "name": name,
            "arguments": args
        });
        return resp;
    }

    async def getPrompt(connection: Any, name: Any, args: Any) -> Any {
        resp = await sendRpc(connection, "prompts/get", {
            "name": name,
            "arguments": args
        });
        return resp;
    }

    async def readResource(connection: Any, uri: Any) -> Any {
        resp = await sendRpc(connection, "resources/read", {"uri": uri});
        return resp;
    }

    return {
        "sendRpc": sendRpc,
        "initialize": initialize,
        "discoverCapabilities": discoverCapabilities,
        "callTool": callTool,
        "getPrompt": getPrompt,
        "readResource": readResource
    };
}
