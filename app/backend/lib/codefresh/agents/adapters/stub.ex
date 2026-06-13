defmodule Codefresh.Agents.Adapters.Stub do
  @moduledoc """
  Shared stub for `invoke/2` across all adapters. Stage 5 does not issue real
  LLM HTTP calls — see the Stage-4 expansion backlog. Keeping the stub
  centralized means the real-call rollout can be done adapter-by-adapter
  without rewriting the runner plumbing.

  Behavior:
    * Normal requests return `{:ok, "<stubbed …>", %{input_tokens: 0, output_tokens: 0, stub: true}}`.
    * If `request.metadata[:stub_response]` is set, that exact string is returned.
    * If `request.metadata[:stub_error]` is set, `{:error, <error_map>}` is
      returned — test hook for error-path coverage.

  The stub NEVER crashes; it always returns a well-formed tuple.
  """

  @spec invoke(String.t(), map(), map()) ::
          {:ok, binary(), map()} | {:error, map()}
  def invoke(adapter, config, request) when is_map(request) do
    metadata = Map.get(request, :metadata) || %{}

    case fetch(metadata, :stub_error) do
      nil ->
        response =
          fetch(metadata, :stub_response) ||
            default_response(adapter, config, request)

        {:ok, response,
         %{input_tokens: 0, output_tokens: 0, stub: true, adapter: adapter}}

      err when is_map(err) ->
        {:error,
         %{
           type: Map.get(err, :type) || Map.get(err, "type") || "other",
           message: Map.get(err, :message) || Map.get(err, "message") || "stub error",
           retryable: Map.get(err, :retryable) || Map.get(err, "retryable") || false
         }}

      err when is_binary(err) ->
        {:error, %{type: err, message: "stub error", retryable: false}}
    end
  end

  defp default_response(adapter, config, request) do
    model = Map.get(config, :model) || Map.get(config, "model") || "unknown"
    prompt = Map.get(request, :prompt) || ""
    preview = String.slice(prompt, 0, 60)
    "<stub:#{adapter}/#{model}> response to: #{preview}"
  end

  defp fetch(m, k) when is_atom(k), do: Map.get(m, k) || Map.get(m, to_string(k))
end
