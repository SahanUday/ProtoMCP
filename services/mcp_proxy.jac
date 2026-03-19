"""MCP Proxy – forwards JSON-RPC calls to any MCP server URL."""

import urllib.request;
import urllib.parse;
import json;
import urllib.error;
import threading;
import queue;
# Persistent SSE connection cache.  Maps server URL to its live connection state
# so that all JSON-RPC calls after `initialize` reuse the same SSE session.
# The special key "_lock" stores the threading.Lock used to serialise first-connect.
glob _sse_cache: dict = {};

def:pub mcp_proxy(
    url: str,
    body: dict = {},
    headers: dict = {},
    transport: str = "streamable-http"
) -> dict;
