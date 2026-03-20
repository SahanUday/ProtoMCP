"""Agent State – per-session event log and confirmation gate.

Every agent_run walker writes events here from its background thread.
The frontend polls get_agent_events (exposed as /function/get_agent_events)
and calls confirm_tool_call (exposed as /function/confirm_tool_call) to
drive the confirmation gate that pauses tool execution until the user
approves or denies.

Thread safety:
  - list.append and dict reads/writes are GIL-protected in CPython.
  - threading.Event handles the blocking confirmation handshake safely.
"""

import threading;


# ── Session store ─────────────────────────────────────────────────────────────
# { session_id: { events, running, pending_confirmation,
#                 confirm_event, confirm_result } }
glob _sessions: dict = {};


# ── Lifecycle ─────────────────────────────────────────────────────────────────

def init_session(session_id: str) -> None {
    _sessions[session_id] = {
        "events":               [],
        "running":              True,
        "pending_confirmation": None,
        "confirm_event":        threading.Event(),
        "confirm_result":       False
    };
}

def mark_complete(session_id: str) -> None {
    if session_id in _sessions {
        _sessions[session_id]["running"] = False;
    }
}

def cleanup_session(session_id: str) -> None {
    _sessions.pop(session_id, None);
}


# ── Event log ─────────────────────────────────────────────────────────────────

def append_event(session_id: str, event: dict) -> None {
    if session_id in _sessions {
        _sessions[session_id]["events"].append(event);
    }
}


# ── Polling endpoint (frontend calls every ~500 ms) ──────────────────────────

def:pub get_agent_events(session_id: str, since_index: int = 0) -> dict {
    if session_id not in _sessions {
        return {
            "events":               [],
            "running":              False,
            "pending_confirmation": None
        };
    }
    s = _sessions[session_id];
    return {
        "events":               s["events"][since_index:],
        "running":              s["running"],
        "pending_confirmation": s["pending_confirmation"]
    };
}


# ── Confirmation gate ─────────────────────────────────────────────────────────

def set_pending_confirmation(session_id: str, tool_name: str, arguments: dict) -> None {
    # Write a pending confirmation record; background thread blocks until resolved.
    if session_id in _sessions {
        s = _sessions[session_id];
        s["pending_confirmation"] = {
            "tool_name": tool_name,
            "arguments": arguments
        };
        s["confirm_event"].clear();
    }
}

def wait_for_confirmation(session_id: str, timeout: int = 120) -> bool {
    # Block the calling thread until confirm_tool_call resolves it (or timeout).
    if session_id not in _sessions { return False; }
    s = _sessions[session_id];
    s["confirm_event"].wait(timeout=timeout);
    return s.get("confirm_result", False);
}

def:pub confirm_tool_call(session_id: str, approved: int = 0) -> dict {
    # Frontend calls this after the user clicks Approve or Deny.
    # approved: 1 = approved, 0 = denied  (bool causes Jaseci 422)
    if session_id in _sessions {
        s = _sessions[session_id];
        s["confirm_result"]       = approved != 0;
        s["pending_confirmation"] = None;
        s["confirm_event"].set();
    }
    return {"ok": True};
}
