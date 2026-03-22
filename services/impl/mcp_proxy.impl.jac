"""MCP Proxy – implementation."""

impl mcp_proxy(
    url: str,
    body: dict = {},
    headers: dict = {},
    transport: str = "streamable-http"
) -> dict {
    # Resolve builtin sentinel URLs to avoid WAF blocking internal IPs in the body
    if url == "builtin://jac-mcp" {
        url = "http://127.0.0.1:3002/mcp/";
    } elif url == "builtin://jasketch" {
        url = "http://127.0.0.1:3010/mcp/";
    }

    request_headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120 Safari/537.36",
        "Content-Type": "application/json",
        "Accept": "application/json, text/event-stream"
    };
    for key in headers {
        request_headers[key] = headers[key];
    }

    # =========================================================================
    # SSE TRANSPORT
    # Maintains one persistent GET /sse connection per server URL.
    # The daemon reader thread dispatches each inbound JSON-RPC response to the
    # correct caller via a per-request Event keyed by request id.
    # =========================================================================
    if transport == "sse" {
        sep: str = "://";
        scheme: str = url.split(sep)[0] if sep in url else "https";
        netloc: str = url.split(sep)[1].split("/")[0] if sep in url else url;

        sse_headers: dict = {
            "Accept": "text/event-stream",
            "Cache-Control": "no-cache",
            "User-Agent": request_headers["User-Agent"]
        };
        for key in headers {
            sse_headers[key] = headers[key];
        }

        # GIL makes setdefault atomic — safe lazy-init of the per-process mutex
        init_lock = _sse_cache.setdefault("_lock", threading.Lock());

        method: str = str(body.get("method", ""));
        req_id: str  = str(body.get("id", ""));

        # initialize must always open a fresh session
        if method == "initialize" {
            with init_lock {
                _sse_cache.pop(url, None);
            }
        }

        # Connect if no live session exists (double-checked locking)
        cached = _sse_cache.get(url);
        if cached is None or not cached["thread"].is_alive() {
            with init_lock {
                cached = _sse_cache.get(url);
                if cached is None or not cached["thread"].is_alive() {

                    ep_holder: list  = [""];
                    err_holder: list = [""];
                    ep_ready         = threading.Event();
                    pending: dict    = {};
                    p_lock           = threading.Lock();

                    def _read_sse_loop() {
                        # Local imports avoid Jac's backward-capture type-checker bug
                        import urllib.request as _ur;
                        import urllib.error  as _ue;
                        import json          as _js;
                        try {
                            get_req = _ur.Request(str(url), method="GET");
                            get_req.add_header("Accept",        "text/event-stream");
                            get_req.add_header("Cache-Control", "no-cache");
                            for k in sse_headers {
                                get_req.add_header(str(k), str(sse_headers[k]));
                            }
                            with _ur.urlopen(get_req, timeout=None) as conn {
                                ev_type: str = "";
                                for _ in range(100000000) {
                                    raw = conn.readline();
                                    if not raw { break; }
                                    line: str = raw.decode("utf-8", errors="replace").rstrip("\r\n");
                                    if line.startswith("event:") {
                                        ev_type = line[6:].strip();
                                    } elif line.startswith("data:") {
                                        data: str = line[5:].strip();
                                        if ev_type == "endpoint" and data {
                                            ep_holder[0] = data if data.startswith("http") else f"{scheme}://{netloc}{data}";
                                            ep_ready.set();
                                        } elif data and data != "[DONE]" {
                                            try {
                                                msg = _js.loads(str(data));
                                                mid: str = str(msg.get("id", ""));
                                                with p_lock {
                                                    waiter = pending.get(mid);
                                                }
                                                if waiter {
                                                    waiter["response"] = msg;
                                                    waiter["event"].set();
                                                }
                                            } except ValueError {}
                                        }
                                    } elif line == "" {
                                        ev_type = "";
                                    }
                                }
                            }
                        } except _ue.HTTPError as e {
                            code = e.code;
                            if code == 410 {
                                err_holder[0] = "SSE endpoint returned 410 Gone — try streamable-http transport instead.";
                            } elif code == 404 {
                                err_holder[0] = "SSE endpoint not found (404). Check the URL or try a different transport.";
                            } else {
                                err_holder[0] = f"HTTP {code} on SSE stream: {str(e)}";
                            }
                            ep_ready.set();
                            with p_lock {
                                for wid in list(pending.keys()) {
                                    pending[wid]["error"] = err_holder[0];
                                    pending[wid]["event"].set();
                                }
                            }
                        } except Exception as e {
                            err_holder[0] = str(e);
                            ep_ready.set();
                            with p_lock {
                                for wid in list(pending.keys()) {
                                    pending[wid]["error"] = str(e);
                                    pending[wid]["event"].set();
                                }
                            }
                        }
                    }

                    t = threading.Thread(target=_read_sse_loop, daemon=True);
                    t.start();

                    if not ep_ready.wait(timeout=15) {
                        return {"ok": False, "status": 0, "error": "SSE timeout: server did not send an endpoint event within 15s.", "body": ""};
                    }
                    if err_holder[0] {
                        return {"ok": False, "status": 0, "error": f"SSE connection failed: {err_holder[0]}", "body": ""};
                    }
                    if not ep_holder[0] {
                        return {"ok": False, "status": 0, "error": "SSE server did not provide an endpoint URL.", "body": ""};
                    }

                    conn_entry: dict = {
                        "session_url":  ep_holder[0],
                        "thread":       t,
                        "pending":      pending,
                        "pending_lock": p_lock
                    };
                    _sse_cache[url] = conn_entry;
                    cached = conn_entry;
                }
            }
        }

        post_url: str = str(cached["session_url"]);
        pending: dict = cached["pending"];
        p_lock        = cached["pending_lock"];

        waiter: dict = {"event": threading.Event(), "response": None, "error": ""};
        with p_lock {
            pending[req_id] = waiter;
        }

        req_body = json.dumps(body).encode("utf-8");
        try {
            post_req = urllib.request.Request(post_url, data=req_body, method="POST");
            for k in request_headers {
                post_req.add_header(str(k), str(request_headers[k]));
            }
            _ = urllib.request.urlopen(post_req, timeout=10);
        } except urllib.error.HTTPError as e {
            with p_lock { pending.pop(req_id, None); }
            err_body = e.read().decode("utf-8") if e.fp else "";
            return {"ok": False, "status": e.code, "error": f"POST to SSE endpoint failed: {str(e)}", "body": err_body};
        } except urllib.error.URLError as e {
            with p_lock { pending.pop(req_id, None); }
            return {"ok": False, "status": 0, "error": f"POST to SSE endpoint failed: {str(e.reason)}", "body": ""};
        }

        if not waiter["event"].wait(timeout=30) {
            with p_lock { pending.pop(req_id, None); }
            return {"ok": False, "status": 0, "error": "SSE response timeout: no event received within 30s.", "body": ""};
        }
        with p_lock { pending.pop(req_id, None); }

        if waiter["error"] {
            return {"ok": False, "status": 0, "error": f"SSE connection died: {waiter['error']}", "body": ""};
        }
        return {"ok": True, "streaming": True, "events": [waiter["response"]], "sessionId": ""};
    }

    # =========================================================================
    # STREAMABLE-HTTP TRANSPORT
    # Single POST per JSON-RPC call. Server may respond with JSON or an
    # SSE stream (content-type: text/event-stream); both are handled below.
    # =========================================================================
    req_body = json.dumps(body).encode("utf-8");
    req = urllib.request.Request(url, data=req_body, headers=request_headers, method="POST");

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
