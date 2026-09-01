defmodule NoizuPromptLingua.MCP.ToolsetConfig do
  @moduledoc """
  Shared §2.7 override-cap policy for toolset-config tool/group entries
  (F2/W9). Single source of truth for BOTH sides of the config lifecycle:

    * WRITE path — `MCPCustomScopes` carries overrides into persisted jsonb.
    * READ path — `EffectiveToolset.overlay/2` applies them across layers.

  The rule: name/description overrides are string-only, empty string = absent,
  capped (name ≤ 128, description ≤ 1024). Keeping one implementation stops the
  two caps from drifting.
  """

  @name_override_max 128
  @description_override_max 1024

  @override_keys ["name_override", "description_override"]

  @doc "The §2.7 caps: `%{name_override: 128, description_override: 1024}`."
  def caps,
    do: %{name_override: @name_override_max, description_override: @description_override_max}

  @doc "Cap for an override key (any other key gets the name cap)."
  def cap("description_override"), do: @description_override_max
  def cap(_), do: @name_override_max

  @doc """
  Carry `key` = `value` onto `acc` under the §2.7 policy: only for override
  keys (`#{@override_keys |> Enum.join(", ")}`), only when `value` is a
  non-empty string, truncated to the key's cap. Otherwise `acc` unchanged.
  """
  def carry_override(acc, key, value)

  def carry_override(acc, key, value)
      when key in @override_keys and is_binary(value) and value != "",
      do: Map.put(acc, key, String.slice(value, 0, cap(key)))

  def carry_override(acc, _key, _value), do: acc
end
