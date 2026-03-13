"""MCP Proxy – forwards JSON-RPC calls to any MCP server URL.

Uses @restspec with custom path to avoid ALB blocking /function/* and /walker/* routes.
"""

import urllib.request;
import urllib.parse;
import json;
import urllib.error;
import from http { HTTPMethod }

@restspec(method=HTTPMethod.POST, path="/mcp-proxy")
def:pub mcp_proxy(
    url: str,
    body: dict = {},
    headers: dict = {},
    transport: str = "streamable-http"
) -> dict;
