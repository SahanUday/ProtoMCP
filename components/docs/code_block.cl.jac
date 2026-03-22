"""Shared CodeBlock component with header bar and copy button."""

cl import from "react" { useState }
cl import from "lucide-react" { Copy, Check, Code2 }

cl {
    def:pub CodeBlock(props: Any) -> JsxElement {
        code = props.code;
        lang = props.lang or "Bash";
        has copied: bool = False;

        def handleCopy -> None {
            navigator.clipboard.writeText(code);
            copied = True;
            setTimeout(lambda -> None { copied = False; }, 2000);
        }

        return <div className="rounded-xl border border-border overflow-hidden my-1">
            <div className="flex items-center justify-between px-4 py-2 bg-muted/80 border-b border-border">
                <div className="flex items-center gap-2 text-xs text-muted-foreground font-medium">
                    <Code2 size={13} className="text-primary/70"/>
                    {lang}
                </div>
                <button
                    onClick={handleCopy}
                    className="flex items-center gap-1.5 text-xs text-muted-foreground hover:text-foreground transition-colors cursor-pointer"
                    title="Copy to clipboard"
                >
                    {copied
                        and <Check size={13} className="text-success"/>
                        or <Copy size={13}/>}
                    {copied and "Copied!" or "Copy"}
                </button>
            </div>
            <pre className="bg-[#1e1e2e] px-4 py-3 text-xs font-mono text-[#cdd6f4] overflow-x-auto leading-relaxed m-0">
                <code>{code}</code>
            </pre>
        </div>;
    }
}
