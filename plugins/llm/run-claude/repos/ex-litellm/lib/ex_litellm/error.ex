defmodule ExLiteLLM.Error do
  @moduledoc """
  OpenAI-compatible error representation.

  Serializes to the `{"error": {"message", "type", "code", "param"}}` envelope
  that OpenAI/litellm clients expect, so error responses are wire-compatible.
  Mirrors litellm's exception → HTTP mapping.
  """

  @derive {Jason.Encoder, only: [:message, :type, :code, :param]}
  defstruct message: "unknown error",
            type: "api_error",
            code: nil,
            param: nil,
            status: 500,
            provider: nil

  @type t :: %__MODULE__{
          message: String.t(),
          type: String.t(),
          code: term(),
          param: term(),
          status: non_neg_integer(),
          provider: atom() | nil
        }

  @doc "Build an error with an HTTP status + OpenAI type."
  @spec new(non_neg_integer(), String.t(), keyword()) :: t()
  def new(status, message, opts \\ []) do
    %__MODULE__{
      status: status,
      message: message,
      type: opts[:type] || type_for_status(status),
      code: opts[:code] || status,
      param: opts[:param],
      provider: opts[:provider]
    }
  end

  @doc "The JSON body an OpenAI client expects: `%{error: %{...}}`."
  @spec to_body(t()) :: map()
  def to_body(%__MODULE__{} = e), do: %{error: e}

  defp type_for_status(400), do: "invalid_request_error"
  defp type_for_status(401), do: "authentication_error"
  defp type_for_status(403), do: "permission_error"
  defp type_for_status(404), do: "not_found_error"
  defp type_for_status(422), do: "invalid_request_error"
  defp type_for_status(429), do: "rate_limit_error"
  defp type_for_status(status) when status in 500..599, do: "api_error"
  defp type_for_status(_), do: "api_error"
end
