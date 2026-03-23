"""Built-in MCP server launcher – implementation.

Each built-in server has a dedicated _start_<name>_server() function that
returns a handle (thread or process) or None if unavailable. Adding a new
built-in server = add one function + one call in _start_builtin_servers().
"""

import atexit;

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


impl _jasketch_mcp_is_ready() -> bool {
    import urllib.request;
    try {
        req = urllib.request.Request(
            "http://127.0.0.1:3010/mcp/",
            data=b'{"jsonrpc":"2.0","id":"ping","method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"healthcheck","version":"0.1"}}}',
            headers={"Content-Type": "application/json", "Accept": "application/json, text/event-stream"},
            method="POST"
        );
        with urllib.request.urlopen(req, timeout=2) as resp {
            return True;
        }
    } except OSError {
        return False;
    }
}


def _resolve_python_exe(mod: Any) -> str {
    # sys.executable may point to system Python when jac-scale activates the venv
    # via sys.path only. Derive the correct Python from the module's install location:
    # mod.__file__ = {venv}/lib/python3.x/site-packages/<pkg>/__init__.py
    pkg_dir = os.path.abspath(mod.__file__);
    venv_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(pkg_dir)))));
    venv_python = os.path.join(venv_root, "bin", "python");
    if os.path.exists(venv_python) {
        return venv_python;
    }
    return sys.executable;
}


def _start_jasketch_server() -> Any {
    try {
        import jasketch_mcp;
    } except ImportError as e {
        print(f"[jasketch-mcp] jasketch-mcp-server not installed, skipping: {e}");
        return None;
    }

    print("[jasketch-mcp] Starting built-in jasketch MCP server...");

    # If already running (stale process from a prior run), reuse it
    if _jasketch_mcp_is_ready() {
        print("[jasketch-mcp] Server already running on http://127.0.0.1:3010/mcp/ (reusing)");
        return threading.Thread(target=lambda: None, daemon=True);
    }

    try {
        python_exe = _resolve_python_exe(jasketch_mcp);
        print(f"[jasketch-mcp] Using Python: {python_exe}");

        env = os.environ.copy();
        env["JASKETCH_MCP_PORT"] = "3010";
        env["JASKETCH_MCP_HOST"] = "127.0.0.1";
        env["JASKETCH_MCP_TRANSPORT"] = "streamable-http";

        proc = subprocess.Popen(
            [python_exe, "-m", "jasketch_mcp", "http"],
            env=env,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT
        );

        threading.Thread(
            target=lambda: [print(f"[jasketch-mcp] {line.decode().rstrip()}") for line in iter(proc.stdout.readline, b"")],
            daemon=True
        ).start();
        atexit.register(proc.terminate);

        thread = threading.Thread(target=proc.wait, daemon=True);
        thread.start();

        ready = False;
        for i in range(20) {
            time.sleep(1);
            if _jasketch_mcp_is_ready() {
                print(f"[jasketch-mcp] Server is ready on http://127.0.0.1:3010/mcp/ (took {i+1}s)");
                ready = True;
                break;
            }
        }

        if not ready {
            print("[jasketch-mcp] Server started but not responding on port 3010 after 20s.");
        }

        return thread;
    } except Exception as e {
        print(f"[jasketch-mcp] Failed to start jasketch MCP server: {e}");
    }
    return None;
}
