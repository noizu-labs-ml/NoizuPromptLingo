defmodule ExLiteLLM.Core.Completion do
  @moduledoc """
  Chat-completion orchestration — ex-litellm's `litellm.completion`.

  Resolves the model to a provider + adapter, resolves the deployment's
  `litellm_params` from the loaded `model_list`, computes optional params
  (honoring `drop_params`), builds the request context, and dispatches through
  the HTTP handler. The router (deployment selection + fallbacks) slots in front
  of this in a later phase; for now a model resolves to the first matching
  deployment (or a bare passthrough when none is configured).
  """

  alias ExLiteLLM.Core.{HTTPHandler, ModelResponse, Params, Provider}
  alias ExLiteLLM.Deployments
  alias ExLiteLLM.Error
  alias ExLiteLLM.Providers.Adapter.Request

  @doc """
  Run a non-streaming chat completion from a decoded OpenAI request body.
  Returns `{:ok, %ModelResponse{}}` or `{:error, %Error{}}`.
  """
  @spec run(map()) :: {:ok, ModelResponse.t()} | {:error, Error.t()}
  def run(params) do
    with {:ok, adapter, req} <- prepare(params) do
      HTTPHandler.completion(adapter, req)
    end
  end

  @doc """
  Build the resolved `{adapter, %Request{}}` for a request without executing it.
  Used by the streaming path, which needs the adapter + request body to drive
  the SSE loop itself.
  """
  @spec prepare(map()) :: {:ok, module(), Request.t()} | {:error, Error.t()}
  def prepare(%{"model" => requested_model} = params) when is_binary(requested_model) do
    deployment = Deployments.lookup(requested_model)
    litellm_params = deployment_params(deployment, requested_model)
    underlying_model = litellm_params["model"] || requested_model

    with {:ok, provider, bare_model, adapter} <- Provider.resolve(underlying_model, litellm_params) do
      drop? = litellm_params["drop_params"] == true or ExLiteLLM.Config.drop_params?()
      mapped = Params.optional(params, adapter, bare_model, drop?)
      mapped = apply_deployment_tunables(mapped, litellm_params)

      req = %Request{
        model: bare_model,
        provider: provider,
        messages: params["messages"] || [],
        params: Map.drop(mapped, ["model"]) |> Map.put("model", bare_model),
        litellm_params: litellm_params,
        stream: params["stream"] == true,
        call_type: :chat
      }

      {:ok, adapter, req}
    end
  end

  def prepare(_),
    do: {:error, Error.new(400, "missing required field: model", type: "invalid_request_error")}

  # A deployment's `litellm_params` (from model_list), or a minimal default that
  # routes the requested model straight through (bare passthrough).
  defp deployment_params(nil, requested_model), do: %{"model" => requested_model}

  defp deployment_params(%{"litellm_params" => lp}, _requested) when is_map(lp), do: lp
  defp deployment_params(_deployment, requested_model), do: %{"model" => requested_model}

  # YAML tunables (reasoning_effort, include_reasoning, …) never used to reach
  # Groq on the /v1/messages path. Merge them now; additional_drop_params still
  # wins so models that cannot take reasoning_effort keep dropping it.
  @deployment_tunables ~w(reasoning_effort include_reasoning temperature max_tokens max_completion_tokens)

  defp apply_deployment_tunables(params, lp) when is_map(lp) do
    extras = Map.take(lp, @deployment_tunables)

    params
    |> Map.merge(extras)
    |> Map.drop(List.wrap(lp["additional_drop_params"]))
  end

  defp apply_deployment_tunables(params, _), do: params
end
