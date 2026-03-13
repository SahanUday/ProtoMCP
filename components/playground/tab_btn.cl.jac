"""TabBtn – tab button for capability sections."""

def:pub TabBtn(props: Any) -> JsxElement {
    label = props.label;
    icon = props.icon;
    count = props.count;
    active = props.active or False;
    onClick = props.onClick;

    return <button
        className={f"flex items-center gap-1.5 px-4 py-2.5 text-sm font-medium border-b-2 transition-all cursor-pointer {
            'border-primary text-primary' if active else 'border-transparent text-muted-foreground hover:text-foreground hover:border-muted-foreground/20'
        }"}
        onClick={onClick}
    >
        {icon}
        {label}
        {count != None and count >= 0 and <span className={f"ml-1 text-xs px-1.5 py-0.5 rounded-full font-medium {
            'bg-primary/15 text-primary' if active else 'bg-muted text-muted-foreground'
        }"}>{count}</span>}
    </button>;
}
