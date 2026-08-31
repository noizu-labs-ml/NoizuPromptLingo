defmodule ExLiteLLM.Providers.Adapter do
  @moduledoc """
  The provider behaviour — ex-litellm's equivalent of litellm's `BaseConfig`
  (`litellm/llms/base_llm/chat/transformation.py`).

  A provider is a module implementing this behaviour. The generic HTTP handler
  (`ExLiteLLM.Core.HTTPHandler`) drives the pipeline:

      validate_environment → get_complete_url → transform_request
        → HTTP POST → transform_response
      (streaming) → chunk_parser per SSE event

  Most OpenAI-compatible providers don't implement this directly; they
  `use ExLiteLLM.Providers.OpenAICompatible` and override only URL/auth/params,
  inheriting OpenAI's request/response/stream transforms.

  ## The request context

  A `%Request{}` carries everything an adapter needs: the resolved model (with
  the `provider/` prefix stripped), the OpenAI-shaped params from the caller,
  the deployment's `litellm_params` (api_key/api_base/etc.), and whether this is
  a streaming call.
  """

  alias ExLiteLLM.Core.ModelResponse
  alias ExLiteLLM.Providers.Adapter.Request

  @typedoc "Normalized streaming chunk — litellm's GenericStreamingChunk."
  @type stream_chunk :: %{
          text: String.t(),
          reasoning: String.t() | nil,
          is_finished: boolean(),
          finish_reason: String.t() | nil,
          usage: map() | nil,
          tool_use: map() | list() | nil,
          index: non_neg_integer(),
          raw: map() | nil
        }

  @doc "OpenAI params this provider accepts (the allowlist for drop_params)."
  @callback get_supported_openai_params(model :: String.t()) :: [String.t()]

  @doc """
  Translate OpenAI param names → provider param names. Receives the caller's
  non-default params and the accumulator; returns the provider-mapped params.
  `drop?` mirrors `litellm.drop_params`.
  """
  @callback map_openai_params(
              non_default :: map(),
              optional :: map(),
              model :: String.t(),
              drop? :: boolean()
            ) :: map()

  @doc """
  Resolve credentials + build auth/base headers. Returns `{:ok, headers}` or
  `{:error, reason}` (e.g. missing api_key). Mirrors `validate_environment`.
  """
  @callback validate_environment(req :: Request.t(), headers :: map()) ::
              {:ok, map()} | {:error, term()}

  @doc "Build the full endpoint URL for this call. Mirrors `get_complete_url`."
  @callback get_complete_url(req :: Request.t()) :: String.t()

  @doc "OpenAI request → provider request body (a JSON-encodable map)."
  @callback transform_request(req :: Request.t()) :: map()

  @doc "Provider JSON response + request context → normalized ModelResponse."
  @callback transform_response(raw :: map(), req :: Request.t()) :: ModelResponse.t()

  @doc "Map a provider error (status + body) to an ExLiteLLM error struct."
  @callback get_error_class(status :: non_neg_integer(), body :: term(), headers :: map()) ::
              ExLiteLLM.Error.t()

  @doc """
  Parse one provider SSE event (already JSON-decoded) into a normalized
  `stream_chunk`. Return `:done` for the terminal event. Mirrors
  `BaseModelResponseIterator.chunk_parser`.
  """
  @callback chunk_parser(event :: map() | :done) :: stream_chunk() | :done

  @optional_callbacks chunk_parser: 1

  defmodule Request do
    @moduledoc "Per-call request context passed to every adapter callback."

    @type t :: %__MODULE__{
            model: String.t(),
            provider: atom(),
            messages: list(),
            params: map(),
            litellm_params: map(),
            stream: boolean(),
            call_type: :chat | :embedding | :completion
          }

    defstruct model: nil,
              provider: nil,
              messages: [],
              params: %{},
              litellm_params: %{},
              stream: false,
              call_type: :chat
  end
end
