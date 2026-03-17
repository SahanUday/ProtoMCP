"""Built-in MCP server launcher – implementation.

Each built-in server has a dedicated _start_<name>_server() function that
returns a handle (thread or process) or None if unavailable. Adding a new
built-in server = add one function + one call in _start_builtin_servers().
"""

impl _start_builtin_servers() -> dict {
    servers = {};

    jac_mcp_handle = _start_jac_mcp_server();
    if jac_mcp_handle is not None {
        servers["jac-mcp"] = jac_mcp_handle;
    }

    jasketch_handle = _start_jasketch_server();
    if jasketch_handle is not None {
        servers["jasketch"] = jasketch_handle;
    }

    return servers;
}


def _start_jac_mcp_server() -> Any {
    try {
        import from jac_mcp.server { JacMcpServer }
    } except ImportError as e {
        print(f"[jac-mcp] jac-mcp not installed, skipping: {e}");
        return None;
    }

    print("[jac-mcp] Starting built-in MCP server...");

    try {
        server = JacMcpServer(transport="streamable-http", port=3002, host="127.0.0.1");

        thread = threading.Thread(target=server.start, daemon=True);
        thread.start();

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
                None;
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


def _start_jasketch_server() -> Any {
    # Guard: skip gracefully if jasketch-mcp-server is not installed.
    # In production (Kubernetes), this package is not yet on PyPI so it won't
    # be present — the server simply won't start. Once jasketch-mcp-server is
    # released to PyPI and added to jac.toml + deploy.yml, this will work
    # everywhere automatically, identical to jac-mcp above.
    try {
        import jasketch_mcp;
    } except ImportError {
        print("[jasketch-mcp] jasketch-mcp-server not installed, skipping.");
        return None;
    }

    print("[jasketch-mcp] Starting built-in jasketch MCP server...");

    try {
        env = {**os.environ,
               "JASKETCH_MCP_TRANSPORT": "streamable-http",
               "JASKETCH_MCP_PORT": "3003"};

        process = subprocess.Popen(
            [sys.executable, "-m", "jasketch_mcp"],
            env=env
        );

        ready = False;
        for i in range(20) {
            time.sleep(1);
            try {
                req = urllib.request.Request(
                    "http://127.0.0.1:3003/mcp/",
                    data=b'{"jsonrpc":"2.0","id":"ping","method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"healthcheck","version":"0.1"}}}',
                    headers={"Content-Type": "application/json", "Accept": "application/json, text/event-stream"},
                    method="POST"
                );
                with urllib.request.urlopen(req, timeout=2) as resp {
                    print(f"[jasketch-mcp] Server is ready on http://127.0.0.1:3003/mcp/ (took {i+1}s)");
                    ready = True;
                    break;
                }
            } except Exception {
                None;
            }
        }

        if not ready {
            print("[jasketch-mcp] Server started but not responding on port 3003 after 20s.");
        }

        return process;
    } except Exception as e {
        print(f"[jasketch-mcp] Failed to start jasketch MCP server: {e}");
    }
    return None;
}
