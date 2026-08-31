defmodule ExLiteLLM.Providers.DeepSeek do
  @moduledoc "DeepSeek — OpenAI-compatible."
  use ExLiteLLM.Providers.OpenAICompatible,
    base_url: "https://api.deepseek.com/v1",
    api_key_env: "DEEPSEEK_API_KEY"
end
