"""Launches all built-in MCP servers on import.

- jac-mcp: started via direct Python import (available everywhere via PyPI).
- jasketch-mcp: started via subprocess with streamable-http transport
  (editable install only; gracefully skipped when not installed, e.g. in prod).
  Once jasketch-mcp-server is released to PyPI and added to jac.toml, it will
  work in all environments automatically — identical to jac-mcp.
"""

import threading;
import time;
import urllib.request;
import subprocess;
import os;
import sys;

def _start_builtin_servers() -> dict;

glob _builtin_servers: dict = _start_builtin_servers();
