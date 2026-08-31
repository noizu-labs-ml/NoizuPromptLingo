defmodule ExLiteLLM.Core.Params do
  @moduledoc """
  Optional-param processing — ex-litellm's `get_optional_params` (`litellm/utils.py`).

  Given the caller's request params and the resolved adapter, produce the
  provider-mapped param set, honoring `drop_params`. Non-inference control keys
  (`model`, `messages`, `stream`) are separated from tunable params so the
  allowlist only governs the tunables.
  """

  alias ExLiteLLM.Config

  # Keys that are structural, not tunable params subject to the allowlist.
  @structural ~w(model messages input)

  @doc """
  Compute the provider params for a call.

    * `params` — the full decoded request body (OpenAI-shaped).
    * `adapter` — the resolved provider adapter module.
    * `drop?` — override for `litellm.drop_params` (defaults to config).

  Returns the mapped param map (structural keys preserved, tunables allow-listed).
  """
  @spec optional(map(), module(), String.t(), boolean() | nil) :: map()
  def optional(params, adapter, model, drop? \\ nil) do
    drop? = if is_nil(drop?), do: Config.drop_params?(), else: drop?

    {structural, tunable} = Map.split(params, @structural)

    mapped = adapter.map_openai_params(tunable, %{}, model, drop?)

    Map.merge(structural, mapped)
  end
end
