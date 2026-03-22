"""Docs – Blog (redirect to Jaseci blog)."""

cl import from "react" { useEffect }
cl import from "lucide-react" { Rss, ExternalLink, ArrowRight, BookOpen }
cl import from ...components.docs.docs_layout { DocsLayout }

cl {
    def:pub page -> JsxElement {
        useEffect(
            lambda -> Any {
                window.location.href = "https://blogs.jaseci.org/blog/2026/03/16/building-protomcp/";
                return lambda -> None {};
            },
            []
        );

        return <DocsLayout>
            <div>
                <div className="mb-8">
                    <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-primary/10 border border-primary/20 text-primary text-xs font-medium mb-4">
                        <Rss size={11}/>
                        Blog
                    </div>
                    <h1 className="text-3xl font-bold text-foreground tracking-tight mb-3">
                        Blog
                    </h1>
                    <p className="text-base text-muted-foreground leading-relaxed">
                        {"Redirecting you to the Jaseci blog..."}
                    </p>
                </div>

                <div className="border border-border rounded-xl overflow-hidden">
                    <div className="flex items-start gap-4 p-5">
                        <div className="flex-shrink-0 w-10 h-10 rounded-lg bg-primary/10 border border-primary/20 flex items-center justify-center text-primary">
                            <BookOpen size={16}/>
                        </div>
                        <div className="flex-1">
                            <p className="text-sm font-semibold text-foreground mb-1">
                                Building ProtoMCP
                            </p>
                            <p className="text-sm text-muted-foreground leading-relaxed mb-3">
                                {"A deep dive into how ProtoMCP was built — the architecture, design decisions, and the MCP protocol implementation behind it."}
                            </p>
                            <a
                                href="https://blogs.jaseci.org/blog/2026/03/16/building-protomcp/"
                                target="_blank"
                                rel="noopener noreferrer"
                                className="inline-flex items-center gap-2 text-sm font-medium text-primary hover:text-primary/80 transition-colors"
                            >
                                Read on Jaseci Blog
                                <ExternalLink size={12}/>
                            </a>
                        </div>
                    </div>
                </div>

                <div className="mt-6">
                    <p className="text-xs text-muted-foreground">
                        {"Not redirected? "}
                        <a
                            href="https://blogs.jaseci.org/blog/2026/03/16/building-protomcp/"
                            target="_blank"
                            rel="noopener noreferrer"
                            className="text-primary hover:underline"
                        >
                            Click here to open the blog post.
                        </a>
                    </p>
                </div>
            </div>
        </DocsLayout>;
    }
}
