"""JsonViewer – collapsible JSON viewer powered by @uiw/react-json-view."""

cl import from "@uiw/react-json-view" { default as JsonView }
cl import from "react" { useState }
cl import from .primitives { Btn }

# Theme object for @uiw/react-json-view (works in both light/dark via CSS vars)
glob jsonDarkTheme: Any = {
    "--w-rjv-font-family": "JetBrains Mono, Fira Code, monospace",
    "--w-rjv-color": "oklch(0.709 0.01 56.259)",
    "--w-rjv-key-string": "oklch(0.705 0.213 47.604)",
    "--w-rjv-background-color": "transparent",
    "--w-rjv-line-color": "oklch(1 0 0 / 8%)",
    "--w-rjv-arrow-color": "oklch(0.709 0.01 56.259)",
    "--w-rjv-edit-color": "oklch(0.709 0.01 56.259)",
    "--w-rjv-info-color": "oklch(0.709 0.01 56.259)",
    "--w-rjv-update-color": "oklch(0.705 0.213 47.604)",
    "--w-rjv-copied-color": "oklch(0.648 0.2 163.15)",
    "--w-rjv-copied-success-color": "oklch(0.648 0.2 163.15)",
    "--w-rjv-curlybraces-color": "oklch(0.709 0.01 56.259)",
    "--w-rjv-colon-color": "oklch(0.709 0.01 56.259)",
    "--w-rjv-brackets-color": "oklch(0.709 0.01 56.259)",
    "--w-rjv-ellipsis-color": "oklch(0.553 0.013 58.071)",
    "--w-rjv-type-string-color": "oklch(0.648 0.2 163.15)",
    "--w-rjv-type-int-color": "oklch(0.82 0.174 84.429)",
    "--w-rjv-type-float-color": "oklch(0.82 0.174 84.429)",
    "--w-rjv-type-bigint-color": "oklch(0.82 0.174 84.429)",
    "--w-rjv-type-boolean-color": "oklch(0.623 0.214 259.815)",
    "--w-rjv-type-date-color": "oklch(0.623 0.214 259.815)",
    "--w-rjv-type-url-color": "oklch(0.705 0.213 47.604)",
    "--w-rjv-type-null-color": "oklch(0.704 0.191 22.216)",
    "--w-rjv-type-nan-color": "oklch(0.704 0.191 22.216)",
    "--w-rjv-type-undefined-color": "oklch(0.553 0.013 58.071)"
};

def:pub JsonViewer(props: Any) -> JsxElement {
    data = props.data;
    collapsed = props.collapsed or 2;
    title = props.title;
    maxHeight = props.maxHeight or "400px";

    has copied: bool = False;

    def handleCopy -> None {
        try {
            navigator.clipboard.writeText(JSON.stringify(data, None, 2));
            copied = True;
            setTimeout(lambda -> None { copied = False; }, 1500);
        } except Exception as e {
            copied = False;
        }
    }

    if not data {
        return <div className="text-muted-foreground text-xs italic p-2">No data</div>;
    }

    return <div className="rounded-lg border border-border overflow-hidden">
        {title and <div className="flex items-center justify-between px-3 py-1.5 bg-card border-b border-border">
            <span className="text-xs font-medium text-muted-foreground">{title}</span>
            <button
                onClick={handleCopy}
                className="text-xs text-muted-foreground hover:text-foreground transition-colors cursor-pointer"
            >
                { "Copied!" if copied else "Copy"}
            </button>
        </div>}
        <div
            className="overflow-auto p-3 bg-background"
            style={{"maxHeight": maxHeight}}
        >
            <JsonView
                value={data}
                style={jsonDarkTheme}
                collapsed={collapsed}
                enableClipboard={False}
            />
        </div>
    </div>;
}

def:pub ContentViewer(props: Any) -> JsxElement {
    content = props.content;
    mimeType = props.mimeType or "text";

    if not content {
        return <div className="text-muted-foreground text-xs italic p-2">Empty content</div>;
    }

    # Try parse JSON for any JSON-like mime or string content
    if mimeType == "application/json" {
        try {
            parsed = JSON.parse(JSON.stringify(content));
            return <JsonViewer data={parsed}/>;
        } except Exception as e {
            return <JsonViewer data={content}/>;
        }
    }

    # Plain object or array (already parsed) — render directly
    if content != None and not (content == content + "") {
        return <JsonViewer data={content}/>;
    }

    # String that looks like JSON — try to parse
    if content and content.trim and content.trim().startsWith("{") or (content and content.trim and content.trim().startsWith("[")) {
        try {
            parsed = JSON.parse(content);
            return <JsonViewer data={parsed}/>;
        } except Exception as e {
            None;
        }
    }

    return <pre className="text-xs text-foreground/80 bg-background rounded-lg p-3 overflow-auto max-h-64 whitespace-pre-wrap font-mono border border-border">{content}</pre>;
}
