defmodule ExLiteLLM.Providers.Cerebras do
  @moduledoc """
  Cerebras — OpenAI-compatible, also "strict". Like Groq it rejects a handful of
  OpenAI params; narrow the allowlist so `drop_params` strips them.
  """
  use ExLiteLLM.Providers.OpenAICompatible,
    base_url: "https://api.cerebras.ai/v1",
    api_key_env: "CEREBRAS_API_KEY"

  alias ExLiteLLM.Providers.OpenAICompatible.Shared

  @unsupported ~w(logit_bias logprobs top_logprobs frequency_penalty presence_penalty)

  @impl true
  def get_supported_openai_params(_model) do
    Shared.default_supported_params() -- @unsupported
  end
end
