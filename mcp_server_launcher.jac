"""Launches the jac-mcp server as a background subprocess on import."""

import from subprocess { Popen, PIPE, STDOUT }
import shutil;
import atexit;
import sys;
import time;
import urllib.request;

def _start_mcp_server() -> Any {
    jac_path = shutil.which("jac");
    if not jac_path {
        print("[jac-mcp] 'jac' command not found in PATH, skipping MCP server launch.");
        return None;
    }
    print(f"[jac-mcp] Found jac at: {jac_path}");

    try {
        proc = Popen(
            ["jac", "mcp", "--transport", "streamable-http", "--port", "3002", "--host", "127.0.0.1"],
            stdout=sys.stderr,
            stderr=STDOUT
        );

        # Wait briefly and check if process is still alive
        time.sleep(2);
        exit_code = proc.poll();
        if exit_code is not None {
            print(f"[jac-mcp] Server exited immediately with code {exit_code}.");
            return None;
        }

        # Wait for server to be ready (up to 15 seconds)
        ready = False;
        for i in range(15) {
            try {
                req = urllib.request.Request(
                    "http://127.0.0.1:3002/mcp/",
                    data=b'{"jsonrpc":"2.0","id":"ping","method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"healthcheck","version":"0.1"}}}',
                    headers={"Content-Type": "application/json", "Accept": "application/json, text/event-stream"},
                    method="POST"
                );
                with urllib.request.urlopen(req, timeout=2) as resp {
                    print(f"[jac-mcp] Server is ready on http://127.0.0.1:3002/mcp/ (took {i+2}s)");
                    ready = True;
                    break;
                }
            } except Exception {
                time.sleep(1);
            }
        }

        if not ready {
            print("[jac-mcp] Server started but not responding on port 3002 after 15s.");
        }

        def _cleanup() -> None {
            if proc and proc.poll() is None {
                proc.terminate();
            }
        }
        atexit.register(_cleanup);
        return proc;
    } except Exception as e {
        print(f"[jac-mcp] Failed to start built-in MCP server: {e}");
    }
    return None;
}

glob _mcp_process: Any = _start_mcp_server();
