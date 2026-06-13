defmodule DirenvConfig.Merge do
  @moduledoc """
  Deep merge for YAML configuration layers with tombstone support.
  """

  @spec deep_merge(term(), term()) :: term()
  def deep_merge(base, overlay) when is_map(base) and is_map(overlay) do
    Map.merge(base, overlay, fn _key, base_val, overlay_val ->
      deep_merge(base_val, overlay_val)
    end)
  end

  def deep_merge(_base, overlay), do: overlay

  @spec deep_merge_multi([term()]) :: term() | nil
  def deep_merge_multi([]), do: nil

  def deep_merge_multi([single]) do
    strip_tombstones(single)
  end

  def deep_merge_multi(layers) do
    layers
    |> Enum.reduce(fn overlay, acc -> deep_merge(acc, overlay) end)
    |> strip_tombstones()
  end

  @spec strip_tombstones(term()) :: term()
  def strip_tombstones(%{"_dc_pruned" => true}), do: nil

  def strip_tombstones(val) when is_map(val) do
    val
    |> Enum.reduce(%{}, fn {k, v}, acc ->
      stripped = strip_tombstones(v)

      if stripped == nil and is_map(v) and Map.has_key?(v, "_dc_pruned") do
        acc
      else
        Map.put(acc, k, stripped)
      end
    end)
  end

  def strip_tombstones(val) when is_list(val) do
    Enum.map(val, &strip_tombstones/1)
  end

  def strip_tombstones(val), do: val
end
