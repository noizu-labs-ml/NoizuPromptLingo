defmodule NoizuPromptLingua.MCP.Window do
  @moduledoc """
  Temporal visibility windows for MCP tool entries (contract §3, branch F3).

  F2 ships the contract seam + a conservative default implementation so the
  `expires_at` field of `NoizuPromptLingua.MCP.EffectiveToolset` is live from
  day one. F3 (feat/temporal-windows) owns the refined semantics and replaces
  this module's body at merge — the `evaluate/2` signature is the contract,
  keep it stable.

  Config keys (on a tool entry in scope config jsonb; mutually exclusive):

    * `hide_until` — ISO8601 datetime (or `%DateTime{}`). While in the future
      the tool is invisible; after it passes the entry's base flags govern.
    * `enable_for_hours` — non-neg integer hours. A temporary visibility grant
      anchored at `enable_from` (ISO8601, written by the editor): visible until
      `enable_from + hours`, with `expires_at` reporting that instant. After
      expiry the base flags govern again. Without an anchor the window is a
      no-op (`{true, nil}`) — the editor always writes an anchor.
  """

  @type eval :: {visible :: boolean | nil, expires_at :: DateTime.t() | nil}

  @doc """
  Evaluate the window on a tool entry at instant `at`.

  Returns `{visible, expires_at}` where `visible` is `nil` when the entry
  carries no window (or an expired one) and the caller falls back to the
  base `hidden` flag.
  """
  @spec evaluate(map(), DateTime.t()) :: eval()
  def evaluate(entry, at \\ DateTime.utc_now())

  def evaluate(entry, at) when is_map(entry) and is_struct(at, DateTime) do
    hide_until = parse_dt(get(entry, "hide_until"))
    hours = parse_hours(get(entry, "enable_for_hours"))

    cond do
      hide_until && DateTime.compare(hide_until, at) == :gt ->
        {false, nil}

      hide_until ->
        {nil, nil}

      hours && hours > 0 ->
        case parse_dt(get(entry, "enable_from") || get(entry, "enabled_at")) do
          nil ->
            {true, nil}

          anchor ->
            expires = DateTime.add(anchor, hours * 3600, :second)

            if DateTime.compare(expires, at) == :gt do
              {true, expires}
            else
              {nil, nil}
            end
        end

      true ->
        {nil, nil}
    end
  end

  def evaluate(_entry, _at), do: {nil, nil}

  # `hide_until` and `enable_for_hours` are mutually exclusive; when both are
  # present the future `hide_until` (hide) wins, else the enable window.

  defp get(entry, key) do
    Map.get(entry, key) ||
      try do
        Map.get(entry, String.to_existing_atom(key))
      rescue
        ArgumentError -> nil
      end
  end

  defp parse_dt(%DateTime{} = dt), do: dt

  defp parse_dt(bin) when is_binary(bin) do
    case DateTime.from_iso8601(bin) do
      {:ok, dt, _offset} -> dt
      _ -> nil
    end
  end

  defp parse_dt(_), do: nil

  defp parse_hours(h) when is_integer(h) and h >= 0, do: h
  defp parse_hours(bin) when is_binary(bin) do
    case Integer.parse(bin) do
      {h, ""} -> h
      _ -> nil
    end
  end
  defp parse_hours(_), do: nil
end
