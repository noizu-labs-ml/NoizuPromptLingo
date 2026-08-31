defmodule ExLiteLLM.Providers.Perplexity do
  @moduledoc "Perplexity — OpenAI-compatible."
  use ExLiteLLM.Providers.OpenAICompatible,
    base_url: "https://api.perplexity.ai",
    api_key_env: "PERPLEXITYAI_API_KEY"
end
