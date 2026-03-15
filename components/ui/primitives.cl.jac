"""Shared UI primitives – Badge, Button, StatusDot, TabBar, Spinner."""

cl import from "lucide-react" { Loader2 }
cl import from "clsx" { clsx }
cl import from "tailwind-merge" { twMerge }

def cn(args: Any) -> Any {
    return twMerge(clsx(args));
}

def:pub Badge(props: Any) -> JsxElement {
    variant = props.variant or "default";
    text = props.text or "";
    extraClass = props.className or "";

    variantMap = {
        "default": "bg-muted text-muted-foreground",
        "success": "bg-success/15 text-success border border-success/25",
        "error": "bg-destructive/15 text-destructive border border-destructive/25",
        "warning": "bg-warning/15 text-warning border border-warning/25",
        "info": "bg-info/15 text-info border border-info/25",
        "primary": "bg-primary/15 text-primary border border-primary/25",
        "violet": "bg-info/15 text-info border border-info/25"
    };

    variantCls2 = variantMap[variant] if variant in variantMap else variantMap.default;
    cls = cn(["inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium", variantCls2, extraClass]);
    return <span className={cls}>{text}</span>;
}

def:pub StatusDot(props: Any) -> JsxElement {
    status = props.status or "disconnected";

    colorMap = {
        "connected": "bg-success",
        "connecting": "bg-warning animate-pulse-dot",
        "error": "bg-destructive",
        "disconnected": "bg-muted-foreground/40"
    };

    dotCls = colorMap[status] if status in colorMap else colorMap.disconnected;
    cls = cn(["w-2 h-2 rounded-full flex-shrink-0", dotCls]);
    return <span className={cls}/>;
}

def:pub Btn(props: Any) -> JsxElement {
    variant = props.variant or "default";
    size = props.size or "md";
    disabled = props.disabled or False;
    loading = props.loading or False;
    onClick = props.onClick;
    children = props.children;
    extraClass = props.className or "";

    variantCls = {
        "default": "bg-secondary hover:bg-secondary/80 text-secondary-foreground border border-border",
        "primary": "bg-primary hover:bg-primary/90 text-primary-foreground border border-primary/50",
        "success": "bg-success hover:bg-success/90 text-success-foreground border border-success/50",
        "danger": "bg-destructive hover:bg-destructive/90 text-destructive-foreground border border-destructive/50",
        "ghost": "hover:bg-accent text-accent-foreground border border-transparent"
    };

    sizeCls = {
        "sm": "px-2.5 py-1 text-xs",
        "md": "px-3.5 py-1.5 text-sm",
        "lg": "px-5 py-2 text-base"
    };

    btnVariantCls = variantCls[variant] if variant in variantCls else variantCls.default;
    btnSizeCls = sizeCls[size] if size in sizeCls else sizeCls.md;
    cls = cn([
        "inline-flex items-center gap-1.5 rounded-lg font-medium transition-colors cursor-pointer select-none",
        "disabled:opacity-50 disabled:cursor-not-allowed",
        btnVariantCls,
        btnSizeCls,
        extraClass
    ]);

    return <button
        className={cls}
        onClick={onClick}
        disabled={Boolean(disabled or loading)}
    >
        {loading and <Loader2 size={14} className="animate-spin"/>}
        {children}
    </button>;
}

def:pub Spinner(props: Any) -> JsxElement {
    size = props.size or 20;
    return <Loader2 size={size} className="animate-spin text-primary"/>;
}

def:pub Input(props: Any) -> JsxElement {
    label = props.label;
    value = props.value or "";
    onChange = props.onChange;
    placeholder = props.placeholder or "";
    inputType = props.type or "text";
    extraClass = props.className or "";
    required = props.required or False;

    cls = cn(["w-full bg-background border border-input rounded-lg px-3 py-1.5 text-sm text-foreground",
              "placeholder-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring/50 focus:border-ring transition-colors",
              extraClass]);

    return <div className="flex flex-col gap-1">
        {label and <label className="text-xs font-medium text-muted-foreground">{label}{required and <span className="text-destructive ml-0.5">*</span>}</label>}
        <input
            type={inputType}
            value={value}
            onChange={onChange}
            placeholder={placeholder}
            className={cls}
        />
    </div>;
}

def:pub Select(props: Any) -> JsxElement {
    label = props.label;
    value = props.value or "";
    onChange = props.onChange;
    options = props.options or [];
    extraClass = props.className or "";

    cls = cn(["w-full bg-background border border-input rounded-lg px-3 py-1.5 text-sm text-foreground",
              "focus:outline-none focus:ring-2 focus:ring-ring/50 focus:border-ring cursor-pointer transition-colors",
              extraClass]);

    return <div className="flex flex-col gap-1">
        {label and <label className="text-xs font-medium text-muted-foreground">{label}</label>}
        <select value={value} onChange={onChange} className={cls}>
            {options.map(lambda(opt: Any) -> Any {
                return <option key={opt.value} value={opt.value}>{opt.label}</option>;
            })}
        </select>
    </div>;
}

def:pub Textarea(props: Any) -> JsxElement {
    label = props.label;
    value = props.value or "";
    onChange = props.onChange;
    placeholder = props.placeholder or "";
    rows = props.rows or 3;
    extraClass = props.className or "";

    cls = cn(["w-full bg-background border border-input rounded-lg px-3 py-1.5 text-sm text-foreground",
              "placeholder-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring/50 focus:border-ring resize-none transition-colors",
              extraClass]);

    return <div className="flex flex-col gap-1">
        {label and <label className="text-xs font-medium text-muted-foreground">{label}</label>}
        <textarea rows={rows} value={value} onChange={onChange} placeholder={placeholder} className={cls}/>
    </div>;
}

