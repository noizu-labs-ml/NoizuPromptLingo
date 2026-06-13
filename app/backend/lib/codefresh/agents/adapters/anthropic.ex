defmodule Codefresh.Agents.Adapters.Anthropic do
  @moduledoc """
  Anthropic adapter (US-061). Same config-validation discipline as OpenAI;
  no API call is made here.

  Required config:
    * `:model` — e.g. `"claude-sonnet-4-5"`
    * `:auth_ref` — `%{"type" => "secret_ref", "ref" => "<path>"}`
  """

  @behaviour Codefresh.Agents.Adapters.Behaviour

  alias Codefresh.Agents.Adapters.OpenAI

  # Shape is identical to OpenAI for Stage 4 — delegate. When Anthropic gains
  # provider-specific knobs (e.g. anthropic-version header, system prompt
  # handling) they'll move here.
  @impl true
  def validate_config(config), do: OpenAI.validate_config(config)

  @impl true
  def health_check(config) do
    case validate_config(config) do
      :ok -> {:ok, :config_valid}
      {:error, _} = e -> e
    end
  end

  @impl true
  def invoke(config, request),
    do: Codefresh.Agents.Adapters.Stub.invoke("anthropic", config, request)
end
