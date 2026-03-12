"""SchemaForm – auto-generate form inputs from a JSON Schema (MCP inputSchema).

Handles: string, number, integer, boolean, array (simple), object (nested keys).
"""

cl import from "react" { useState }
cl import from .primitives { Input, Btn, Textarea, Select }

cl {
    def RenderFieldForSchema(schema: Any, path: Any, value: Any, onChange: Any) -> Any {
        safeSchema = schema or {};
        schemaType = safeSchema.type or "string";
        description = safeSchema.description or "";
        enumValues = safeSchema.enum;

        if enumValues and len(enumValues) > 0 {
            opts = enumValues.map(lambda(v: Any) -> Any { return {"value": v, "label": String(v)}; });
            return <Select
                value={value or ""}
                onChange={lambda(e: Any) -> None { onChange(path, e.target.value); }}
                options={opts}
            />;
        }

        if schemaType == "boolean" {
            return <label className="flex items-center gap-2 cursor-pointer">
                <input
                    type="checkbox"
                    checked={Boolean(value)}
                    onChange={lambda(e: Any) -> None { onChange(path, e.target.checked); }}
                    className="w-4 h-4 rounded border-border bg-card text-primary focus:ring-primary accent-primary"
                />
                <span className="text-sm text-foreground">{description or path}</span>
            </label>;
        }

        if schemaType == "number" or schemaType == "integer" {
            return <Input
                inputType="number"
                value={value or ""}
                onChange={lambda(e: Any) -> None {
                    onChange(path, Number(e.target.value));
                }}
                placeholder={description or f"Enter {path}"}
            />;
        }

        if schemaType == "object" {
            subProps = safeSchema.properties or {};
            return <div className="pl-3 border-l border-border flex flex-col gap-3">
                {Object.keys(subProps).map(lambda(key: Any) -> Any {
                    subSchema = subProps[key] or {};
                    subValue = (value or {})[key];                    return <div key={key}>
                        <label className="block text-xs font-medium text-muted-foreground mb-1">{key}</label>
                        <RenderFieldForSchema schema={subSchema} path={f"{path}.{key}"} value={subValue} onChange={onChange}/>
                    </div>;
                })}
            </div>;
        }

        if schemaType == "array" {
            arrValue = value or [];
            itemSchema = safeSchema.items or {"type": "string"};

            def addItem -> None {
                newArr = arrValue.concat([""]);
                onChange(path, newArr);
            }

            def removeItem(idx: Any) -> None {
                newArr = arrValue.filter(lambda(_, i: Any) -> Any { return i != idx; });
                onChange(path, newArr);
            }

            def updateItem(idx: Any, val: Any) -> None {
                newArr = arrValue.map(lambda(item: Any, i: Any) -> Any {
                    if i == idx { return val; }
                    return item;
                });
                onChange(path, newArr);
            }

            return <div className="flex flex-col gap-2">
                {arrValue.map(lambda(item: Any, i: Any) -> Any {
                    return <div key={i} className="flex items-center gap-2">
                        <div className="flex-1">
                            <RenderFieldForSchema schema={itemSchema} path={f"{path}[{i}]"} value={item} onChange={lambda(_, v: Any) -> None { updateItem(i, v); }}/>
                        </div>
                        <button
                            onClick={lambda -> None { removeItem(i); }}
                            className="text-destructive hover:text-destructive/80 text-xs px-1"
                        >✕</button>
                    </div>;
                })}
                <button
                    onClick={addItem}
                    className="text-xs text-primary hover:text-primary/80 text-left cursor-pointer"
                >+ Add item</button>
            </div>;
        }

        # Default: string (use textarea for long strings)
        if safeSchema.format == "textarea" or (description and len(description) > 50) {
            return <Textarea
                value={value or ""}
                onChange={lambda(e: Any) -> None { onChange(path, e.target.value); }}
                placeholder={description or f"Enter {path}"}
                rows={3}
            />;
        }

        return <Input
            inputType="text"
            value={value or ""}
            onChange={lambda(e: Any) -> None { onChange(path, e.target.value); }}
            placeholder={description or f"Enter {path}"}
        />;
    }

    # ── Deep set helper ───────────────────────────────────────────────────────
    # Simple flat-key path setter (supports "key" and "key.subkey" paths)

    def setNestedValue(`obj: Any, path: Any, value: Any) -> Any {
        parts = path.split(".");
        result = {**`obj};
        current = result;
        i = 0;
        while i < len(parts) - 1 {
            part = parts[i];
            if not current[part] {
                current[part] = {};
            }
            current = current[part];
            i = i + 1;
        }
        current[parts[len(parts) - 1]] = value;
        return result;
    }

    # ── SchemaForm ────────────────────────────────────────────────────────────

    def:pub SchemaForm(props: Any) -> JsxElement {
        schema = props.schema or {};
        onSubmit = props.onSubmit;
        submitLabel = props.submitLabel or "Execute";
        loading = props.loading or False;

        has formValues: Any = {};

        properties = schema.properties or {};
        required = schema.required or [];
        propKeys = Object.keys(properties);

        def handleFieldChange(path: Any, value: Any) -> None {
            formValues = setNestedValue(formValues, path, value);
        }

        def handleSubmit -> None {
            if onSubmit {
                onSubmit(formValues);
            }
        }

        if len(propKeys) == 0 {
            return <div className="flex flex-col gap-3">
                <p className="text-xs text-muted-foreground italic">This tool takes no arguments.</p>
                <Btn variant="primary" onClick={handleSubmit} loading={loading}>
                    {submitLabel}
                </Btn>
            </div>;
        }

        return <div className="flex flex-col gap-4">
            {propKeys.map(lambda(key: Any) -> Any {
                fieldSchema = properties[key] or {};
                isRequired = required.includes(key);
                return <div key={key} className="flex flex-col gap-1">
                    <div className="flex items-center gap-1">
                        <label className="text-sm font-medium text-foreground">{key}</label>
                        {isRequired and <span className="text-destructive text-xs">*</span>}
                        {fieldSchema.description and
                            <span className="text-xs text-muted-foreground ml-1">– {fieldSchema.description}</span>
                        }
                    </div>
                    <RenderFieldForSchema schema={fieldSchema} path={key} value={formValues[key]} onChange={handleFieldChange}/>
                </div>;
            })}
            <div className="pt-2 border-t border-border">
                <Btn variant="primary" onClick={handleSubmit} loading={loading}>
                    {submitLabel}
                </Btn>
            </div>
        </div>;
    }
}
