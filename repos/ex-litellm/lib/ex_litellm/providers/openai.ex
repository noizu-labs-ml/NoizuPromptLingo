defmodule ExLiteLLM.Providers.OpenAI do
  @moduledoc """
  The OpenAI provider — the reference/canonical adapter. Every other
  OpenAI-compatible provider is a thin specialization of this one.

  Uses the shared OpenAI-compatible transforms directly; only the default base
  URL and API-key env var are OpenAI-specific.
  """
  use ExLiteLLM.Providers.OpenAICompatible,
    base_url: "https://api.openai.com/v1",
    api_key_env: "OPENAI_API_KEY"
end
