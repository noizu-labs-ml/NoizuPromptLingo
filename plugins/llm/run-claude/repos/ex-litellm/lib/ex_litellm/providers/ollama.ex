defmodule ExLiteLLM.Providers.Ollama do
  @moduledoc """
  Ollama (local) — OpenAI-compatible endpoint at `/v1`. No API key required;
  a deployment's `api_base` typically points at `http://localhost:11434/v1`.
  """
  use ExLiteLLM.Providers.OpenAICompatible,
    base_url: "http://localhost:11434/v1",
    api_key_env: nil

  alias ExLiteLLM.Providers.Adapter.Request

  # Ollama needs no auth — never fail on a missing key; just set content-type.
  @impl true
  def validate_environment(%Request{litellm_params: lp}, headers) do
    headers =
      headers
      |> Map.put("content-type", "application/json")
      |> maybe_put_key(lp["api_key"])

    {:ok, headers}
  end

  defp maybe_put_key(headers, key) when is_binary(key) and key != "",
    do: Map.put(headers, "authorization", "Bearer " <> key)

  defp maybe_put_key(headers, _), do: headers
end
