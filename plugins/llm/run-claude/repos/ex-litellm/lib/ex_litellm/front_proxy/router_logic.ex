defmodule ExLiteLLM.FrontProxy.RouterLogic do
  @moduledoc """
  Front-proxy routing decision — the `_route(path, body)` equivalent from
  `front_proxy.py`.

  Given a request path and (decoded) body, walk the ordered rule list and return
  the first matching `{target_base_url, auth_mode}`. Mirrors the Python contract:

    * OpenAI paths → the LiteLLM tier, swapping auth to the master key.
    * `/v1/messages` (non `/count_tokens`) → LiteLLM if the model does NOT start
      with `claude-`, else Anthropic passthrough (keep the caller's OAuth).
    * everything else → Anthropic passthrough.
  """

  alias ExLiteLLM.FrontProxy.Rules
  alias ExLiteLLM.Runtime

  @anthropic_api "https://api.anthropic.com"

  @doc """
  Resolve `{target_base_url, auth_mode}` for a request.

  `auth_mode` is `:master_key` (strip client auth, inject the LiteLLM master
  key) or `:passthrough` (forward original headers untouched).
  """
  @spec route(String.t(), map()) :: {String.t(), :master_key | :passthrough}
  def route(path, body) do
    rule = Enum.find(Rules.list(), &matches?(&1, path, body))
    to_target(rule)
  end

  # --- matching ---

  defp matches?(%Rules.Rule{match: {:path_in, paths}}, path, _body) do
    Enum.any?(paths, fn p -> path == p or String.starts_with?(path, p <> "/") end)
  end

  defp matches?(%Rules.Rule{match: {:messages_model, prefix}}, path, body) do
    messages_path?(path) and model_matches_prefix?(body, prefix)
  end

  defp matches?(%Rules.Rule{match: {:messages_not_model, prefix}}, path, body) do
    messages_path?(path) and not model_matches_prefix?(body, prefix)
  end

  defp matches?(%Rules.Rule{match: :any}, _path, _body), do: true

  defp messages_path?(path) do
    String.starts_with?(path, "/v1/messages") and not String.ends_with?(path, "/count_tokens")
  end

  defp model_matches_prefix?(body, prefix) do
    model = extract_model(body)
    is_binary(model) and String.starts_with?(model, prefix)
  end

  # --- target resolution ---

  defp to_target(nil), do: {@anthropic_api, :passthrough}

  defp to_target(%Rules.Rule{target: target, auth: auth}) do
    {base_url(target), auth}
  end

  defp base_url(:litellm), do: litellm_url()
  defp base_url(:anthropic), do: @anthropic_api
  defp base_url({:url, url}), do: url

  # In the unified gateway the LiteLLM tier is in-process, so a `:litellm` target
  # points back at the gateway's own listener (only reached by custom rules; the
  # native OpenAI paths are served directly and never hit forwarding).
  defp litellm_url do
    settings = Runtime.get()
    "http://#{settings.host}:#{settings.port}"
  end

  @doc "Extract the `model` field from a decoded request body (empty string if absent)."
  @spec extract_model(map() | nil) :: String.t()
  def extract_model(%{"model" => model}) when is_binary(model), do: model
  def extract_model(_), do: ""

  @doc "Is this a routable /v1/messages request (not count_tokens)?"
  @spec messages_request?(String.t()) :: boolean()
  def messages_request?(path), do: messages_path?(path)
end
