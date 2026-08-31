defmodule ExLiteLLM.Core.Embeddings do
  @moduledoc """
  Embedding orchestration — ex-litellm's `litellm.embedding`.

  Same resolution + dispatch flow as `ExLiteLLM.Core.Completion`, but the call
  type is `:embedding` (so the adapter targets the `/embeddings` path) and the
  raw provider response is returned as-is (already OpenAI embedding-shaped).
  """

  alias ExLiteLLM.Core.{HTTPHandler, Provider}
  alias ExLiteLLM.Deployments
  alias ExLiteLLM.Error
  alias ExLiteLLM.Providers.Adapter.Request

  @doc """
  Run an embedding request from a decoded OpenAI body (`model` + `input`).
  Returns `{:ok, map}` (the OpenAI embedding response) or `{:error, %Error{}}`.
  """
  @spec run(map()) :: {:ok, map()} | {:error, Error.t()}
  def run(%{"model" => requested_model, "input" => _} = params) when is_binary(requested_model) do
    deployment = Deployments.lookup(requested_model)
    litellm_params = deployment_params(deployment, requested_model)
    underlying_model = litellm_params["model"] || requested_model

    with {:ok, provider, bare_model, adapter} <- Provider.resolve(underlying_model, litellm_params) do
      req = %Request{
        model: bare_model,
        provider: provider,
        params: Map.put(params, "model", bare_model),
        litellm_params: litellm_params,
        stream: false,
        call_type: :embedding
      }

      # Embedding responses are already OpenAI-shaped — return the provider body
      # verbatim via the handler's raw path (no chat normalization).
      HTTPHandler.raw(adapter, req)
    end
  end

  def run(_),
    do: {:error, Error.new(400, "missing required field: model or input", type: "invalid_request_error")}

  defp deployment_params(nil, requested_model), do: %{"model" => requested_model}
  defp deployment_params(%{"litellm_params" => lp}, _requested) when is_map(lp), do: lp
  defp deployment_params(_deployment, requested_model), do: %{"model" => requested_model}
end
