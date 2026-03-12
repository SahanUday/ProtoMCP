"""Launches the jac-mcp server as a background subprocess on import."""

import from subprocess { Popen }
import shutil;
import atexit;
import os;

def _start_mcp_server() -> Any {
    if shutil.which("jac") {
        try {
            devnull = open(os.devnull, "w");
            proc = Popen(
                ["jac", "mcp", "--transport", "streamable-http", "--port", "3002", "--host", "127.0.0.1"],
                stdout=devnull,
                stderr=devnull
            );
            def _cleanup() -> None {
                if proc and proc.poll() is None {
                    proc.terminate();
                }
                devnull.close();
            }
            atexit.register(_cleanup);
            print("[jac-mcp] Started built-in MCP server on http://127.0.0.1:3002/mcp/");
            return proc;
        } except Exception as e {
            print(f"[jac-mcp] Failed to start built-in MCP server: {e}");
        }
    }
    return None;
}

glob _mcp_process: Any = _start_mcp_server();
