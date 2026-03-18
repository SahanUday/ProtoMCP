# Takes messages + tools --> Calls an LLM via litellm --> Returns response + Returns a clean, structured response (including tool calls if any)
# llm_call was just “ask model → get answer”

walker:pub llm_call {
    has model: str = "gpt-4o-mini",
        api_key: str = "",
        provider: str = "openai",
        messages: list = [],
        tools: list = [],
        temperature: float = 0.7,
        max_tokens: int = 4096;

    can call_llm with Root entry {
        import json;

        # Convert MCP tool schemas to OpenAI function-calling format
        # MCP:    {name, description, inputSchema: {type, properties, required}}
        # OpenAI: {type: "function", function: {name, description, parameters: ...}}
        openai_tools = [];
        for mcp_tool in self.tools {
            openai_tools.append({
                "type": "function",
                "function": {
                    "name": mcp_tool.get("name", ""),
                    "description": mcp_tool.get("description", ""),
                    "parameters": mcp_tool.get("inputSchema", {"type": "object", "properties": {}})
                }
            });
        }

        try {
            import litellm;
            litellm.drop_params = True;

            # Build model string with provider prefix for litellm routing
            model_str = self.model;
            if self.provider == "anthropic" and not self.model.startswith("anthropic/") {
                model_str = f"anthropic/{self.model}";
            } elif self.provider == "groq" and not self.model.startswith("groq/") {
                model_str = f"groq/{self.model}";
            } elif self.provider == "together" and not self.model.startswith("together_ai/") {
                model_str = f"together_ai/{self.model}";
            }

            kwargs: dict = {
                "model": model_str,
                "messages": self.messages,
                "temperature": self.temperature,
                "max_tokens": self.max_tokens,
                "api_key": self.api_key
            };

            if len(openai_tools) > 0 {
                kwargs["tools"] = openai_tools;
                kwargs["tool_choice"] = "auto";
            }

            response = litellm.completion(**kwargs);

            # Extract response into serializable format
            choice = response.choices[0];
            message = choice.message;

            result: dict = {
                "role": "assistant",
                "content": message.content or "",
                "tool_calls": None,
                "finish_reason": choice.finish_reason,
                "usage": {
                    "prompt_tokens": response.usage.prompt_tokens if response.usage else 0,
                    "completion_tokens": response.usage.completion_tokens if response.usage else 0,
                    "total_tokens": response.usage.total_tokens if response.usage else 0
                },
                "model": response.model or self.model
            };

            # Extract tool calls if present
            if message.tool_calls and len(message.tool_calls) > 0 {
                tc_list = [];
                for tc in message.tool_calls {
                    args_str = tc.function.arguments if isinstance(tc.function.arguments, str) else json.dumps(tc.function.arguments);
                    tc_list.append({
                        "id": tc.id,
                        "type": "function",
                        "function": {
                            "name": tc.function.name,
                            "arguments": args_str
                        }
                    });
                }
                result["tool_calls"] = tc_list;
            }

            report {"ok": True, "data": result};

        } except Exception as e {
            import traceback;
            print(f"[llm_call] Error: {traceback.format_exc()}");
            report {"ok": False, "error": str(e)};
        }
    }
}
