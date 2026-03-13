"""EmptyState – placeholder for empty capability lists."""

def:pub EmptyState(props: Any) -> JsxElement {
    icon = props.icon;
    title = props.title;
    sub = props.sub;

    return <div className="flex flex-col items-center justify-center py-16 gap-3 text-muted-foreground">
        <div className="w-12 h-12 rounded-xl bg-muted/50 flex items-center justify-center">{icon}</div>
        <p className="text-sm font-medium">{title}</p>
        {sub and <p className="text-xs text-muted-foreground/70">{sub}</p>}
    </div>;
}
