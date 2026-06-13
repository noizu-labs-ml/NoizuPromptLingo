defmodule Codefresh.Agents.Adapters.OpenAI do
  @moduledoc """
  OpenAI adapter (US-012).

  Validates config shape; does NOT call the API. `health_check/1` is
  credentials-presence only — the actual LLM invocation lands in Stage 5's
  runner.

  Required config:
    * `:model` — e.g. `"gpt-4o"`, `"gpt-4-turbo"`
    * `:auth_ref` — `%{"type" => "secret_ref", "ref" => "<path>"}`

  Optional:
    * `:endpoint_url` — defaults to `https://api.openai.com/v1` (not stored if nil)
    * `:request_template.timeout_ms`
    * `:request_template.streaming` (US-065)
  """

  @behaviour Codefresh.Agents.Adapters.Behaviour

  @impl true
  def validate_config(config) do
    with :ok <- require_string(config, :model, "model is required"),
         :ok <- require_secret_ref(config, :auth_ref),
         :ok <- validate_timeout(config),
         :ok <- validate_streaming(config) do
      :ok
    end
  end

  @impl true
  def health_check(config) do
    case validate_config(config) do
      :ok -> {:ok, :config_valid}
      {:error, _} = e -> e
    end
  end

  @impl true
  def invoke(config, request),
    do: Codefresh.Agents.Adapters.Stub.invoke("openai", config, request)

  defp require_string(config, key, msg) do
    case fetch(config, key) do
      v when is_binary(v) and v != "" -> :ok
      _ -> {:error, msg}
    end
  end

  defp require_secret_ref(config, key) do
    case fetch(config, key) do
      %{} = m ->
        t = Map.get(m, "type") || Map.get(m, :type)
        r = Map.get(m, "ref") || Map.get(m, :ref)

        cond do
          t != "secret_ref" -> {:error, "auth_ref.type must be 'secret_ref'"}
          not is_binary(r) or r == "" -> {:error, "auth_ref.ref must be a non-empty string"}
          true -> :ok
        end

      _ ->
        {:error, "auth_ref is required (opaque secret reference)"}
    end
  end

  defp validate_timeout(config) do
    case get_in_template(config, "timeout_ms") do
      nil -> :ok
      n when is_integer(n) and n > 0 and n <= 600_000 -> :ok
      _ -> {:error, "request_template.timeout_ms must be 1..600000"}
    end
  end

  defp validate_streaming(config) do
    case get_in_template(config, "streaming") do
      nil -> :ok
      b when is_boolean(b) -> :ok
      _ -> {:error, "request_template.streaming must be boolean"}
    end
  end

  defp fetch(config, key) when is_atom(key),
    do: Map.get(config, key) || Map.get(config, to_string(key))

  defp get_in_template(config, k) do
    tmpl = fetch(config, :request_template) || %{}
    Map.get(tmpl, k) || Map.get(tmpl, String.to_atom(k))
  end
end
