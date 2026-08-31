defmodule ExLiteLLM.Providers.XAI do
  @moduledoc "xAI (Grok) — OpenAI-compatible. Key env is GROK_API_KEY (run-claude convention)."
  use ExLiteLLM.Providers.OpenAICompatible,
    base_url: "https://api.x.ai/v1",
    api_key_env: "GROK_API_KEY"
end
