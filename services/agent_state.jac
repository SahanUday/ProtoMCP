import threading;
import time;

# ── Session store ─────────────────────────────────────────────────────────────
glob _sessions: dict = {};
glob MAX_COMPLETED_SESSIONS: int = 5;

# ── Eviction ──────────────────────────────────────────────────────────────────
def _evict_oldest_completed() -> None {
    completed = [];
    for sid in list(_sessions.keys()) {
        s = _sessions[sid];
        if not s["running"] {
            completed.append({"id": sid, "created_at": s["created_at"]});
        }
    }
    if len(completed) > MAX_COMPLETED_SESSIONS {
        completed.sort(key=lambda x : x["created_at"]);
        to_remove = completed[:len(completed) - MAX_COMPLETED_SESSIONS];
        for item in to_remove {
            _sessions.pop(item["id"], None);
        }
    }
}

# ── Lifecycle ─────────────────────────────────────────────────────────────────
def init_session(session_id: str, title: str = "") -> None {
    _sessions[session_id] = {
        "events": [],
        "running": True,
        "pending_confirmation": None,
        "confirm_event": threading.Event(),
        "confirm_result": False,
        "title": title,
        "created_at": int(time.time() * 1000)
    };
}

def mark_complete(session_id: str) -> None {
    if session_id in _sessions {
        _sessions[session_id]["running"] = False;
        _evict_oldest_completed();
    }
}

def:pub delete_session(session_id: str) -> dict {
    _sessions.pop(session_id, None);
    return {"ok": True};
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
        return {"events": [], "running": False, "pending_confirmation": None};
    }
    s = _sessions[session_id];
    return {
        "events": s["events"][since_index:],
        "running": s["running"],
        "pending_confirmation": s["pending_confirmation"]
    };
}

# ── Confirmation gate ─────────────────────────────────────────────────────────

# Write a pending confirmation record; background thread blocks until resolved.
def set_pending_confirmation(session_id: str, tool_name: str, arguments: dict) -> None {
    if session_id in _sessions {
        s = _sessions[session_id];
        s["pending_confirmation"] = {"tool_name": tool_name, "arguments": arguments};
        s["confirm_event"].clear();
    }
}

# Block the calling thread until confirm_tool_call resolves it (or timeout).
def wait_for_confirmation(session_id: str, timeout: int = 120) -> bool {
    if session_id not in _sessions {
        return False;
    }
    s = _sessions[session_id];
    s["confirm_event"].wait(timeout=timeout);
    return s.get("confirm_result", False);
}

# Frontend calls this after the user clicks Approve or Deny.
def:pub confirm_tool_call(session_id: str, approved: str = "False") -> dict {
    if session_id in _sessions {
        s = _sessions[session_id];
        s["confirm_result"] = approved == "True";
        s["pending_confirmation"] = None;
        s["confirm_event"].set();
    }
    return {"ok": True};
}
