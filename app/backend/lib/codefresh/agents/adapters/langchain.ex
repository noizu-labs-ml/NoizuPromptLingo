defmodule Codefresh.Agents.Adapters.LangChain do
  @moduledoc """
  LangChain adapter (US-062). Stage-4 stub: validates presence of an
  entrypoint identifier in `request_template.entrypoint` but does NOT execute
  any Python runtime. `health_check/1` returns `{:ok, :not_implemented}`.

  Required config:
    * `:request_template.entrypoint` — dotted module path, e.g.
      `"my_module.chain_factory"`
  """

  @behaviour Codefresh.Agents.Adapters.Behaviour

  @impl true
  def validate_config(config) do
    tmpl = fetch(config, :request_template) || %{}
    entry = Map.get(tmpl, "entrypoint") || Map.get(tmpl, :entrypoint)

    cond do
      not is_binary(entry) or entry == "" ->
        {:error, "request_template.entrypoint is required (e.g. 'my_module.factory')"}

      not Regex.match?(~r/^[a-zA-Z_][\w.]*$/, entry) ->
        {:error, "request_template.entrypoint must be a dotted python identifier"}

      true ->
        :ok
    end
  end

  @impl true
  def health_check(_config), do: {:ok, :not_implemented}

  @impl true
  def invoke(config, request),
    do: Codefresh.Agents.Adapters.Stub.invoke("langchain", config, request)

  defp fetch(config, key) when is_atom(key),
    do: Map.get(config, key) || Map.get(config, to_string(key))
end
