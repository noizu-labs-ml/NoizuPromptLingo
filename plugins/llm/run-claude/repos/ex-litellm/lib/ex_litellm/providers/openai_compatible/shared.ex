defmodule ExLiteLLM.Providers.OpenAICompatible.Shared do
  @moduledoc """
  The concrete OpenAI-compatible transform logic shared by every provider that
  `use`s `ExLiteLLM.Providers.OpenAICompatible`.

  Because the OpenAI Chat Completions schema *is* ex-litellm's internal
  representation, the request transform is nearly a pass-through: the caller's
  params are already in the target shape. The work is credential resolution,
  URL building, param allow-listing/`drop_params`, and normalizing the response
  back into a `ModelResponse`.
  """

  alias ExLiteLLM.Config.Secret
  alias ExLiteLLM.Core.ModelResponse
  alias ExLiteLLM.Error
  alias ExLiteLLM.Providers.Adapter.Request

  # The OpenAI Chat Completions param surface ex-litellm accepts by default.
  @supported ~w(
    model messages temperature top_p n stream stream_options stop max_tokens
    max_completion_tokens presence_penalty frequency_penalty logit_bias user
    response_format seed tools tool_choice parallel_tool_calls functions
    function_call logprobs top_logprobs reasoning_effort include_reasoning
    reasoning_format metadata
  )

  @doc "The default OpenAI param allowlist."
  @spec default_supported_params() :: [String.t()]
  def default_supported_params, do: @supported

  @doc """
  Allow-list the caller's params against the provider's supported set. Drops
  unsupported keys when `drop?`, else lets them through (the caller already
  validated at the endpoint boundary). Providers override to strip more.
  """
  @spec map_openai_params(map(), map(), String.t(), boolean(), module()) :: map()
  def map_openai_params(non_default, optional, _model, drop?, adapter) do
    supported = adapter.get_supported_openai_params(non_default["model"] || "")

    Enum.reduce(non_default, optional, fn {k, v}, acc ->
      cond do
        k in supported -> Map.put(acc, k, v)
        drop? -> acc
        true -> Map.put(acc, k, v)
      end
    end)
  end

  @doc """
  Resolve the API key (deployment `litellm_params.api_key` → env var) and build
  the auth header. Returns `{:ok, headers}` or `{:error, %Error{}}`.
  """
  @spec validate_environment(Request.t(), map(), String.t() | nil) ::
          {:ok, map()} | {:error, Error.t()}
  def validate_environment(%Request{litellm_params: lp}, headers, api_key_env) do
    case resolve_api_key(lp, api_key_env) do
      nil ->
        {:error,
         Error.new(401, "no API key found (checked litellm_params.api_key and #{api_key_env})",
           type: "authentication_error"
         )}

      key ->
        {:ok,
         headers
         |> Map.put("authorization", "Bearer " <> key)
         |> Map.put("content-type", "application/json")}
    end
  end

  @doc "Build the endpoint URL: deployment api_base (or default) + path."
  @spec complete_url(Request.t(), String.t(), String.t(), String.t()) :: String.t()
  def complete_url(%Request{litellm_params: lp, call_type: call_type}, default_base, chat, embed) do
    base = (lp["api_base"] || default_base) |> String.trim_trailing("/")
    path = if call_type == :embedding, do: embed, else: chat

    if String.ends_with?(base, path), do: base, else: base <> path
  end

  @doc """
  OpenAI request body. The bare model (prefix stripped) is used so the upstream
  sees its own model id; the caller's already-OpenAI-shaped params ride along.
  """
  @spec transform_request(Request.t()) :: map()
  def transform_request(%Request{model: model, params: params}) do
    params
    |> Map.put("model", model)
    |> drop_nil()
  end

  @doc "Provider response is already OpenAI-shaped — normalize into ModelResponse."
  @spec transform_response(map(), Request.t()) :: ModelResponse.t()
  def transform_response(raw, %Request{model: model}) when is_map(raw) do
    ModelResponse.new(%{
      id: raw["id"],
      object: raw["object"] || "chat.completion",
      created: raw["created"],
      model: raw["model"] || model,
      choices: raw["choices"] || [],
      usage: raw["usage"],
      system_fingerprint: raw["system_fingerprint"]
    })
  end

  @doc "Map an upstream error into an ExLiteLLM error."
  @spec get_error_class(non_neg_integer(), term(), map()) :: Error.t()
  def get_error_class(status, body, _headers) do
    message = extract_error_message(body)
    Error.new(status, message)
  end

  @doc """
  Parse one OpenAI SSE event into a normalized stream chunk. The event is the
  already-JSON-decoded `data:` payload; `:done` is the `[DONE]` sentinel.
  """
  @spec chunk_parser(map() | :done) :: map() | :done
  def chunk_parser(:done), do: :done

  def chunk_parser(event) when is_map(event) do
    choice = event |> Map.get("choices", []) |> List.first() || %{}
    delta = Map.get(choice, "delta", %{})

    %{
      text: Map.get(delta, "content") || "",
      reasoning: Map.get(delta, "reasoning") || Map.get(delta, "reasoning_content") || "",
      is_finished: not is_nil(Map.get(choice, "finish_reason")),
      finish_reason: Map.get(choice, "finish_reason"),
      usage: Map.get(event, "usage"),
      tool_use: Map.get(delta, "tool_calls"),
      index: Map.get(choice, "index", 0),
      raw: event
    }
  end

  # --- helpers ---

  defp resolve_api_key(lp, api_key_env) do
    cond do
      is_binary(lp["api_key"]) and lp["api_key"] != "" -> Secret.resolve(lp["api_key"])
      is_binary(api_key_env) -> System.get_env(api_key_env)
      true -> nil
    end
  end

  defp drop_nil(map) do
    map
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end

  defp extract_error_message(%{"error" => %{"message" => msg}}) when is_binary(msg), do: msg
  defp extract_error_message(%{"error" => msg}) when is_binary(msg), do: msg
  defp extract_error_message(%{"message" => msg}) when is_binary(msg), do: msg
  defp extract_error_message(body) when is_binary(body), do: body
  defp extract_error_message(_), do: "upstream provider error"
end
