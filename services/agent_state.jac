import threading;
import queue;
import from typing { Any }

# ── Session object (single-user) ─────────────────────────────────────────────────────────────
obj _Session {
    has q: Queue;  # queue.Queue  – holds StreamEvent dicts + None sentinel
    has ev: Event;  # threading.Event – confirmation gate
    has cancel_ev: Event;  # threading.Event – abort/cancel signal for background thread
    has confirmed: bool = False;
}

# ── Session store (multi-users) ──────────────────────────────────────────────────────────────
glob _sessions: dict[str, _Session] = {};


# ── Lifecycle ─────────────────────────────────────────────────────────────────
def init_session(session_id: str) -> None {
    _sessions[session_id] = _Session(
        q=queue.Queue(), ev=threading.Event(), cancel_ev=threading.Event()
    );
}

def:pub end_session(session_id: str) -> dict {
    s: Any = _sessions.pop(session_id, None);
    if s {
        s.cancel_ev.set();
        s.ev.set();
        s.q.put(None);
    }
    return {"ok": True};
}


# ── Event queue ───────────────────────────────────────────────────────────────
def enqueue_event(session_id: str, event: dict) -> None {
    s: Any = _sessions.get(session_id);
    if s {
        s.q.put(event);
    }
}

def get_session_queue(session_id: str) -> Queue {
    return _sessions[session_id].q;
}

def mark_complete(session_id: str) -> None {
    # None sentinel signals the SSE generator to stop
    s: Any = _sessions.get(session_id);
    if s {
        s.q.put(None);
    }
}


# ── Cancellation ──────────────────────────────────────────────────────────────
# Returns the cancel_ev for the session so the background thread can hold a
def get_cancel_event(session_id: str) -> Any {
    s = _sessions.get(session_id);
    return s.cancel_ev if s else None;
}


# ── Confirmation gate ─────────────────────────────────────────────────────────
def set_pending_confirmation(session_id: str) -> None {
    s: Any = _sessions.get(session_id);
    if s {
        s.ev.clear();
        s.confirmed = False;
    }
}

# Block the calling (background) thread until confirm_tool_call resolves it.
def wait_for_confirmation(session_id: str, timeout: int = 120) -> bool {
    s: Any = _sessions.get(session_id);
    if not s {
        return False;
    }
    s.ev.wait(timeout=timeout);
    return s.confirmed;
}

# Frontend calls this after the user clicks Approve or Deny.
def:pub confirm_tool_call(session_id: str, approved: str = "False") -> dict {
    s: Any = _sessions.get(session_id);
    if s {
        s.confirmed = approved == "True";
        s.ev.set();
    }
    return {"ok": True};
}
