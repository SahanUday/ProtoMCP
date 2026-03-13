"""Launches the jac-mcp server in a background thread on import.

Uses direct Python import instead of subprocess to avoid venv PATH issues
in Kubernetes deployments (jac install puts jac-mcp in .jac/venv/ which
the system jac binary can't access as a CLI plugin).
"""

import threading;
import time;
import urllib.request;

def _start_mcp_server() -> Any;

glob _mcp_process: Any = _start_mcp_server();
