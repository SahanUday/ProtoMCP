"""MarkdownRenderer – lightweight markdown renderer for LLM chat responses."""

cl import from "react" { useState }
cl import from "lucide-react" { Copy, Check }


def CodeBlock(props: Any) -> JsxElement {
    language = props.language or "";
    code = props.code or "";
    has copied: bool = False;

    def handleCopy -> None {
        navigator.clipboard.writeText(code).then(lambda -> Any {
            copied = True;
            setTimeout(lambda -> None { copied = False; }, 2000);
            return None;
        });
    }

    return <div className="my-3 rounded-lg border border-border overflow-hidden">
        <div className="flex items-center justify-between px-3 py-1.5 bg-muted/50 border-b border-border">
            <span className="text-xs font-mono text-muted-foreground/70">{language or "code"}</span>
            <button
                onClick={handleCopy}
                className="flex items-center gap-1 text-xs text-muted-foreground hover:text-foreground transition-colors cursor-pointer"
            >
                {copied and <Check size={11} className="text-success"/> or <Copy size={11}/>}
                <span className="ml-0.5">{copied and "Copied!" or "Copy"}</span>
            </button>
        </div>
        <pre className="px-4 py-3 overflow-x-auto bg-muted/20 m-0">
            <code className="text-xs font-mono text-foreground leading-relaxed">{code}</code>
        </pre>
    </div>;
}


# Convert inline markdown (**bold**, `code`) to HTML string
def mdInlineHtml(text: Any) -> Any {
    s = text;
    bParts = s.split("**");
    s = bParts.map(lambda(p: Any, i: Any) -> Any {
        return i % 2 == 1 and "<strong class='font-semibold text-foreground'>" + p + "</strong>" or p;
    }).join("");
    cParts = s.split("`");
    s = cParts.map(lambda(p: Any, i: Any) -> Any {
        return i % 2 == 1 and "<code style='font-family:monospace;font-size:0.8em;background:rgba(128,128,128,0.2);padding:0.1em 0.4em;border-radius:3px'>" + p + "</code>" or p;
    }).join("");
    return s;
}


# Parse a text segment (between code fences) into typed blocks
def mdTextToBlocks(text: Any) -> Any {
    blocks = [];
    listItems = [];
    listOrdered = False;

    for line in text.split(String.fromCharCode(10)) {
        s = line.trim();
        if s == "" {
            if listItems.length > 0 {
                blocks.push({"type": "list", "ordered": listOrdered, "items": listItems.slice(0)});
                listItems.length = 0;
            }
        } elif s.startsWith("### ") {
            if listItems.length > 0 { blocks.push({"type": "list", "ordered": listOrdered, "items": listItems.slice(0)}); listItems.length = 0; }
            blocks.push({"type": "h3", "text": s.substring(4)});
        } elif s.startsWith("## ") {
            if listItems.length > 0 { blocks.push({"type": "list", "ordered": listOrdered, "items": listItems.slice(0)}); listItems.length = 0; }
            blocks.push({"type": "h2", "text": s.substring(3)});
        } elif s.startsWith("# ") {
            if listItems.length > 0 { blocks.push({"type": "list", "ordered": listOrdered, "items": listItems.slice(0)}); listItems.length = 0; }
            blocks.push({"type": "h1", "text": s.substring(2)});
        } elif s.startsWith("- ") or s.startsWith("* ") {
            if listItems.length > 0 and listOrdered { blocks.push({"type": "list", "ordered": True, "items": listItems.slice(0)}); listItems.length = 0; }
            listOrdered = False;
            listItems.push(s.substring(2));
        } elif not isNaN(parseInt(s)) and s.indexOf(". ") > 0 {
            if listItems.length > 0 and not listOrdered { blocks.push({"type": "list", "ordered": False, "items": listItems.slice(0)}); listItems.length = 0; }
            listOrdered = True;
            dotIdx = s.indexOf(". ");
            listItems.push(s.substring(dotIdx + 2));
        } else {
            if listItems.length > 0 { blocks.push({"type": "list", "ordered": listOrdered, "items": listItems.slice(0)}); listItems.length = 0; }
            blocks.push({"type": "p", "text": s});
        }
    }
    if listItems.length > 0 {
        blocks.push({"type": "list", "ordered": listOrdered, "items": listItems.slice(0)});
    }
    return blocks;
}


def:pub MarkdownRenderer(props: Any) -> JsxElement {
    content = props.content or "";

    # Split on ``` fences → alternate text / code
    parts = content.split("```");
    rendered = [];
    segIdx = 0;

    for part in parts {
        if segIdx % 2 == 1 {
            lines = part.split(String.fromCharCode(10));
            lang = lines[0].trim();
            code = lines.slice(1).join(String.fromCharCode(10)).trimEnd();
            rendered.push(<CodeBlock key={segIdx} language={lang} code={code}/>);
        } else {
            for block in mdTextToBlocks(part) {
                blockKey = f"{segIdx}-{rendered.length}";
                if block.type == "h1" {
                    rendered.push(<h1 key={blockKey} className="text-base font-bold mt-3 mb-1 text-foreground" dangerouslySetInnerHTML={{"__html": mdInlineHtml(block.text)}}/>);
                } elif block.type == "h2" {
                    rendered.push(<h2 key={blockKey} className="text-sm font-bold mt-2.5 mb-1 text-foreground" dangerouslySetInnerHTML={{"__html": mdInlineHtml(block.text)}}/>);
                } elif block.type == "h3" {
                    rendered.push(<h3 key={blockKey} className="text-sm font-semibold mt-2 mb-0.5 text-foreground" dangerouslySetInnerHTML={{"__html": mdInlineHtml(block.text)}}/>);
                } elif block.type == "list" {
                    items = block.items.map(lambda(item: Any, ii: Any) -> Any {
                        return <li key={ii} className="leading-relaxed" dangerouslySetInnerHTML={{"__html": mdInlineHtml(item)}}/>;
                    });
                    if block.ordered {
                        rendered.push(<ol key={blockKey} className="text-sm list-decimal pl-5 my-1 space-y-0.5">{items}</ol>);
                    } else {
                        rendered.push(<ul key={blockKey} className="text-sm list-disc pl-5 my-1 space-y-0.5">{items}</ul>);
                    }
                } else {
                    rendered.push(<p key={blockKey} className="text-sm leading-relaxed" dangerouslySetInnerHTML={{"__html": mdInlineHtml(block.text)}}/>);
                }
            }
        }
        segIdx += 1;
    }

    return <div className="text-sm text-foreground space-y-1.5">{rendered}</div>;
}
