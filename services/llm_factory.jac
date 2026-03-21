import from byllm.lib { Model }

def create_llm(
    provider: str,
    model: str,
    api_key: str,
    temperature: float = 0.7,
    max_tokens: int = 4096
) -> Model {
    call_params: dict = {"temperature": temperature, "max_tokens": max_tokens};

    if provider == "openai" {
        # OpenAI: model names need no prefix  (gpt-4o, gpt-4o-mini, o3-mini …)
        return Model(model_name=model, api_key=api_key, call_params=call_params);
    } elif provider == "anthropic" {
        # Anthropic: LiteLLM resolves claude-* without a prefix
        return Model(model_name=model, api_key=api_key, call_params=call_params);
    } elif provider == "google" {
        # Google Gemini: requires "gemini/" prefix
        model_name = model if model.startswith("gemini/") else f"gemini/{model}";
        return Model(model_name=model_name, api_key=api_key, call_params=call_params);
    } elif provider == "groq" {
        # Groq: requires "groq/" prefix
        model_name = model if model.startswith("groq/") else f"groq/{model}";
        return Model(model_name=model_name, api_key=api_key, call_params=call_params);
    } elif provider == "together" {
        # Together AI: requires "together_ai/" prefix
        model_name = model
            if model.startswith("together_ai/")
            else f"together_ai/{model}";
        return Model(model_name=model_name, api_key=api_key, call_params=call_params);
    }

    # Fallback: pass model name as-is (covers custom / self-hosted endpoints)
    return Model(model_name=model, api_key=api_key, call_params=call_params);
}
