defmodule ExLiteLLM.Providers.Mistral do
  @moduledoc "Mistral — OpenAI-compatible."
  use ExLiteLLM.Providers.OpenAICompatible,
    base_url: "https://api.mistral.ai/v1",
    api_key_env: "MISTRAL_API_KEY"
end
