"""404 Not Found page."""

cl import from "@jac/runtime" { Link }
cl import from "lucide-react" { Zap, ArrowLeft }

cl {
    def:pub page -> JsxElement {
        return <div className="flex flex-col items-center justify-center min-h-[calc(100vh-3.5rem)] gap-6 text-muted-foreground">
            <div className="w-14 h-14 rounded-xl bg-primary/10 border border-primary/20 flex items-center justify-center">
                <Zap size={24} className="text-primary"/>
            </div>
            <h1 className="text-7xl font-bold text-muted-foreground/20">404</h1>
            <p className="text-lg text-muted-foreground">Page not found</p>
            <Link to="/" className="inline-flex items-center gap-2 text-primary hover:text-primary/80 text-sm transition-colors">
                <ArrowLeft size={14}/>
                Back to Home
            </Link>
        </div>;
    }
}
