defmodule NoizuPromptLingua.MCP.Args do
  @moduledoc """
  Helpers for MCP tool argument extraction. MCP arguments may arrive with
  either atom or string keys, so every lookup checks both.
  """

  @doc "Fetch a single argument by atom key, tolerating string keys."
  def get(args, key) when is_atom(key) do
    Map.get(args, key) || Map.get(args, Atom.to_string(key))
  end

  @doc "Build an attrs map from the given keys, skipping absent values."
  def take(args, keys) do
    Enum.reduce(keys, %{}, fn k, acc ->
      case get(args, k) do
        nil -> acc
        val -> Map.put(acc, k, val)
      end
    end)
  end

  @doc "Reduce the given keys into a keyword list of options, skipping nils."
  def opts(args, keys) do
    Enum.reduce(keys, [], fn k, acc ->
      case get(args, k) do
        nil -> acc
        val -> [{k, val} | acc]
      end
    end)
  end
end
