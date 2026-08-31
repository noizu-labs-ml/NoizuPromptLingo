defmodule ExLiteLLM.Core.ModelResponse do
  @moduledoc """
  The normalized, OpenAI-shaped chat completion response — litellm's
  `ModelResponse` (`litellm/types/utils.py`).

  Every provider adapter's `transform_response/2` returns one of these. It
  serializes (via `to_map/1`) to the exact JSON an OpenAI `/v1/chat/completions`
  client expects, so ex-litellm is wire-compatible regardless of the upstream
  provider.
  """

  @derive Jason.Encoder
  defstruct id: nil,
            object: "chat.completion",
            created: nil,
            model: nil,
            choices: [],
            usage: nil,
            system_fingerprint: nil

  @type choice :: %{
          index: non_neg_integer(),
          message: map(),
          finish_reason: String.t() | nil
        }

  @type t :: %__MODULE__{
          id: String.t() | nil,
          object: String.t(),
          created: integer() | nil,
          model: String.t() | nil,
          choices: [choice()],
          usage: map() | nil,
          system_fingerprint: String.t() | nil
        }

  @doc "Build a response, filling id/created defaults when the provider omits them."
  @spec new(map()) :: t()
  def new(fields) when is_map(fields) do
    struct(__MODULE__, fields)
    |> ensure_id()
    |> ensure_created()
  end

  defp ensure_id(%__MODULE__{id: nil} = r), do: %{r | id: "chatcmpl-" <> gen_id()}
  defp ensure_id(r), do: r

  defp ensure_created(%__MODULE__{created: nil} = r),
    do: %{r | created: System.system_time(:second)}

  defp ensure_created(r), do: r

  defp gen_id, do: 16 |> :crypto.strong_rand_bytes() |> Base.url_encode64(padding: false)
end
