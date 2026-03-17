"""MCP Proxy – implementation."""

impl mcp_proxy(
    url: str,
    body: dict = {},
    headers: dict = {},
    transport: str = "streamable-http"
) -> dict {
    # Resolve sentinel values to avoid WAF blocking internal IPs in request body
    if url == "builtin://jac-mcp" {
        url = "http://127.0.0.1:3002/mcp/";
    } elif url == "builtin://jasketch" {
        url = "http://127.0.0.1:3003/mcp/";
    }

    request_headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120 Safari/537.36",
        "Content-Type": "application/json",
        "Accept": "application/json, text/event-stream"
    };
    for key in headers {
        request_headers[key] = headers[key];
    }

    parsed_url = urllib.parse.urlparse(url);
    is_sse = transport == "sse";
    post_url = url;
    sse_error = None;

    if is_sse {
        try {
            sse_headers = {
                "Accept": "text/event-stream",
                "Cache-Control": "no-cache",
                "User-Agent": request_headers["User-Agent"]
            };
            for key in headers {
                sse_headers[key] = headers[key];
            }
            get_req = urllib.request.Request(url, headers=sse_headers, method="GET");
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
        return {"ok": False, "status": 0, "error": sse_error, "body": ""};
    }

    req_body = json.dumps(body).encode("utf-8");
    req = urllib.request.Request(post_url, data=req_body, headers=request_headers, method="POST");

    try {
        with urllib.request.urlopen(req, timeout=30) as resp {
            content_type = resp.headers.get("Content-Type", "");
            session_id = resp.headers.get("mcp-session-id", "");

            if "text/event-stream" in content_type {
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
                        if events and line == "" {
                            break;
                        }
                    }
                } except Exception as loop_e {
                    print(f"[mcp_proxy] readline loop exception: {loop_e}");
                }

                if events {
                    return {"ok": True, "streaming": True, "events": events, "sessionId": session_id};
                } else {
                    return {"ok": False, "status": 0, "error": "SSE stream returned no events.", "body": ""};
                }
            } else {
                raw = resp.read().decode("utf-8");
                if raw.strip() {
                    try {
                        return {"ok": True, "streaming": False, "data": json.loads(raw), "sessionId": session_id};
                    } except Exception {
                        return {"ok": True, "streaming": False, "data": {"raw": raw}, "sessionId": session_id};
                    }
                } else {
                    return {"ok": False, "status": 0, "error": "Server returned empty body.", "body": ""};
                }
            }
        }
    } except urllib.error.HTTPError as e {
        if e.code in (301, 302, 307, 308) {
            redirect_url = e.headers.get("Location", "");
            hint = f" Try: {redirect_url}" if redirect_url else " Try adding a trailing slash to the URL.";
            return {"ok": False, "status": e.code, "error": f"Server redirected the request.{hint}", "body": ""};
        } else {
            err_body = e.read().decode("utf-8") if e.fp else "";
            return {"ok": False, "status": e.code, "error": str(e), "body": err_body};
        }
    } except urllib.error.URLError as e {
        return {"ok": False, "status": 0, "error": str(e.reason), "body": ""};
    } except Exception as e {
        return {"ok": False, "status": 0, "error": str(e), "body": ""};
    }
}
