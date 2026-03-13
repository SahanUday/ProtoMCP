"""MCP Proxy – forwards JSON-RPC calls to any MCP server URL."""

import urllib.request;
import urllib.parse;
import json;
import urllib.error;

def:pub mcp_proxy(
    url: str,
    body: dict = {},
    headers: dict = {},
    transport: str = "streamable-http"
) -> dict;
