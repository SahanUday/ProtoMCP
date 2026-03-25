"""Google Analytics gtag utility - tracks pageviews and events."""

glob GA_MEASUREMENT_ID: str = "G-GZBGYX1V5F";

def:pub pageview(url: str) -> None {
    if GA_MEASUREMENT_ID == "" {
        return;
    }
    if "gtag" in window {
        window.gtag("config", GA_MEASUREMENT_ID, {
            "page_path": url,
        });
    }
}

def:pub event(action: str, category: str, label: str = "", value: int = 0) -> None {
    if GA_MEASUREMENT_ID == "" {
        return;
    }
    if "gtag" in window {
        window.gtag("event", action, {
            "event_category": category,
            "event_label": label,
            "value": value,
        });
    }
}