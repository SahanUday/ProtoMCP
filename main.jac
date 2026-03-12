"""MCP Playground Backend + Frontend entry point."""

import urllib.request;
import urllib.parse;
import json;
import urllib.error;

import from mcp_server_launcher { _mcp_process }

# ──────────────────────────────────────────────
# Backend: CORS proxy walker for MCP requests
# Forwards JSON-RPC calls to any MCP server URL
# ──────────────────────────────────────────────

walker:pub mcp_proxy {
    has url: str,
        body: dict = {},
        headers: dict = {},
        transport: str = "streamable-http";

    can proxy with Root entry {

        request_headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120 Safari/537.36",
            "Content-Type": "application/json",
            "Accept": "application/json, text/event-stream"
        };

        for key in self.headers {
            request_headers[key] = self.headers[key];
        }

        print(f"[mcp_proxy] method={self.body.get('method','?')} transport={self.transport}");

        # Use explicit transport mode instead of URL auto-detection
        parsed_url = urllib.parse.urlparse(self.url);
        is_sse = self.transport == "sse";

        post_url = self.url;
        sse_error = None;

        if is_sse {
            # SSE Transport: GET the /sse endpoint first to receive the session POST URL
            try {
                sse_headers = {
                    "Accept": "text/event-stream",
                    "Cache-Control": "no-cache",
                    "User-Agent": request_headers["User-Agent"]
                };
                for key in self.headers {
                    sse_headers[key] = self.headers[key];
                }
                get_req = urllib.request.Request(self.url, headers=sse_headers, method="GET");
                endpoint_url = None;
                with urllib.request.urlopen(get_req, timeout=10) as sse_conn {
                    event_type = "";
                    for _ in range(200) {
                        raw_line = sse_conn.readline();
                        if not raw_line { break; }
                        line = raw_line.decode("utf-8", errors="replace").rstrip("\r\n");
                        if line.startswith("event:") {
                            event_type = line[6:].strip();
                        } elif line.startswith("data:") and event_type == "endpoint" {
                            path = line[5:].strip();
                            if path {
                                endpoint_url = path if path.startswith("http") else f"{parsed_url.scheme}://{parsed_url.netloc}{path}";
                                break;
                            }
                        } elif line == "" {
                            event_type = "";
                        }
                    }
                }
                if endpoint_url {
                    post_url = endpoint_url;
                } else {
                    sse_error = "SSE server did not send an endpoint URL. Try the /mcp endpoint instead.";
                }
            } except Exception as e {
                sse_error = f"SSE session setup failed: {str(e)}. Try the /mcp endpoint instead.";
            }
        }

        if sse_error {
            report {"ok": False, "status": 0, "error": sse_error, "body": ""};
        } else {
            req_body = json.dumps(self.body).encode("utf-8");
            req = urllib.request.Request(post_url, data=req_body, headers=request_headers, method="POST");

            try {
                with urllib.request.urlopen(req, timeout=30) as resp {
                    content_type = resp.headers.get("Content-Type", "");

                    # Capture session ID from response headers (MCP Streamable HTTP transport)
                    session_id = resp.headers.get("mcp-session-id", "");

                    if "text/event-stream" in content_type {
                        # Read SSE line-by-line; stop after first complete event (blank line)
                        events = [];
                        try {
                            for _ in range(1000) {
                                raw_line = resp.readline();
                                if not raw_line { break; }
                                line = raw_line.decode("utf-8", errors="replace").rstrip("\r\n");
                                if line.startswith("data:") {
                                    data_str = line[5:].strip();
                                    if data_str and data_str != "[DONE]" {
                                        try {
                                            events.append(json.loads(data_str));
                                        } except Exception {
                                            events.append({"raw": data_str});
                                        }
                                    }
                                }
                                # SSE event separator — stop once we have data
                                if events and line == "" {
                                    break;
                                }
                            }
                        } except Exception as loop_e {
                            print(f"[mcp_proxy] readline loop exception: {loop_e}");
                        }

                        if events {
                            report {"ok": True, "streaming": True, "events": events, "sessionId": session_id};
                        } else {
                            report {"ok": False, "status": 0, "error": "SSE stream returned no events.", "body": ""};
                        }
                    } else {
                        raw = resp.read().decode("utf-8");
                        if raw.strip() {
                            try {
                                report {"ok": True, "streaming": False, "data": json.loads(raw), "sessionId": session_id};
                            } except Exception {
                                report {"ok": True, "streaming": False, "data": {"raw": raw}, "sessionId": session_id};
                            }
                        } else {
                            report {"ok": False, "status": 0, "error": "Server returned empty body.", "body": ""};
                        }
                    }
                }
            } except urllib.error.HTTPError as e {
                if e.code in (301, 302, 307, 308) {
                    redirect_url = e.headers.get("Location", "");
                    hint = f" Try: {redirect_url}" if redirect_url else " Try adding a trailing slash to the URL.";
                    report {"ok": False, "status": e.code, "error": f"Server redirected the request.{hint}", "body": ""};
                } else {
                    err_body = e.read().decode("utf-8") if e.fp else "";
                    report {"ok": False, "status": e.code, "error": str(e), "body": err_body};
                }
            } except urllib.error.URLError as e {
                report {"ok": False, "status": 0, "error": str(e.reason), "body": ""};
            } except Exception as e {
                report {"ok": False, "status": 0, "error": str(e), "body": ""};
            }
        }
    }
}

# ──────────────────────────────────────────────
# Frontend entry: file-based routing via pages/
# ──────────────────────────────────────────────

cl import ".styles/globals.css";
cl import from "react" { useEffect }

cl {
    def:pub app(children: Any = None) -> Any {
        # Apply dark mode by default
        useEffect(lambda -> Any {
            if not document.documentElement.classList.contains("dark") and not document.documentElement.classList.contains("light") {
                document.documentElement.classList.add("dark");
            }
            return lambda -> None {};
        }, []);

        return <div className="min-h-screen bg-background text-foreground">{children}</div>;
    }
}
