"""MCP Server Launcher – implementation."""

impl _start_mcp_server() -> Any {
    try {
        import from jac_mcp.server { JacMcpServer }
    } except ImportError as e {
        print(f"[jac-mcp] jac-mcp not installed, skipping: {e}");
        return None;
    }

    print("[jac-mcp] Starting built-in MCP server...");

    try {
        server = JacMcpServer(transport="streamable-http", port=3002, host="127.0.0.1");

        # Run server in a daemon thread so it doesn't block app startup
        thread = threading.Thread(target=server.start, daemon=True);
        thread.start();

        # Wait for server to be ready (up to 15 seconds)
        ready = False;
        for i in range(15) {
            time.sleep(1);
            try {
                req = urllib.request.Request(
                    "http://127.0.0.1:3002/mcp/",
                    data=b'{"jsonrpc":"2.0","id":"ping","method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"healthcheck","version":"0.1"}}}',
                    headers={"Content-Type": "application/json", "Accept": "application/json, text/event-stream"},
                    method="POST"
                );
                with urllib.request.urlopen(req, timeout=2) as resp {
                    print(f"[jac-mcp] Server is ready on http://127.0.0.1:3002/mcp/ (took {i+1}s)");
                    ready = True;
                    break;
                }
            } except Exception {
                0;
            }
        }

        if not ready {
            print("[jac-mcp] Server started but not responding on port 3002 after 15s.");
        }

        return thread;
    } except Exception as e {
        print(f"[jac-mcp] Failed to start built-in MCP server: {e}");
    }
    return None;
}
