defmodule NoizuPromptLingua.MCP.Window do
  @moduledoc """
  F3 temporal windows: time-boxed visibility for tools in scope-config jsonb.

  Fields on a tool entry (see `TOBOR-CONTRACTS.md` §3):

      %{"hide_until" => iso8601_utc | nil,          # hidden until this instant
        "enable_for_hours" => pos_integer | nil}    # visible for N hours from anchor

  The two are **mutually exclusive** — a tool entry may carry one or neither,
  never both. Absent fields mean "no window" (tool visibility is governed by the
  static `hidden`/`disabled` flags per the inverted default-visible semantics).

  Anchoring: `enable_for_hours` needs a start instant; it is stamped at
  normalize time (when the scope config is written) as `enabled_at` (UTC
  ISO8601), following the same stamp-on-write precedent as
  `disabled_confirmed_at` in `NoizuPromptLingua.MCPCustomScopes`. An entry with
  `enable_for_hours` but no `enabled_at` (hand-edited jsonb) evaluates as an
  inert window — write-side normalization re-anchors it.

  Naive-vs-UTC: naive datetime inputs (strings without an offset,
  `NaiveDateTime` structs) are interpreted as **UTC** — the repo-wide split
  precedent (cf. `chat_message.ex` microsecond/UTC notes,
  `dashboard.ex` Z-suffixed serialization).

  Evaluation is consumed by `NoizuPromptLingua.MCP.EffectiveToolset` (F2):

      {visible, expires_at} = Window.evaluate(entry, at)

    * `hide_until` in the future → `{false, hide_until}` (hidden; state expires
      when the hide lifts).
    * `hide_until` past → `{true, nil}` (window over).
    * `enable_for_hours` live → `{true, expires_at}` (visible; expires when the
      window closes).
    * `enable_for_hours` elapsed → `{true, nil}` (window inert; the entry's
      static flags govern again — windows expire out, they never permanently
      flip state).
  """

  @until_field "hide_until"
  @hours_field "enable_for_hours"
  @anchor_field "enabled_at"

  @type window :: %{
          hide_until: DateTime.t() | nil,
          enable_for_hours: pos_integer() | nil
        }

  @doc "Field names as stored in scope-config jsonb."
  def fields, do: %{until: @until_field, hours: @hours_field, anchor: @anchor_field}

  ## ------------------------------------------------------------------
  ## Parsing / validation
  ## ------------------------------------------------------------------

  @doc """
  Parse the window fields off a config entry (group or tool level).

      {:ok, %{hide_until: dt | nil, enable_for_hours: n | nil}}
      | {:error, :mutually_exclusive | {:invalid_datetime, field} | {:invalid_hours, msg} | :invalid_entry}

  Accepts atom or string keys; `hide_until` as `DateTime`, `NaiveDateTime`
  (assumed UTC), or ISO8601 string (naive strings assumed UTC);
  `enable_for_hours` as a positive integer (zero/negative rejected).
  """
  def parse(entry) when is_map(entry) do
    with {:ok, hide_until} <- parse_until(raw(entry, @until_field)),
         {:ok, hours} <- parse_hours(raw(entry, @hours_field)) do
      if hide_until && hours do
        {:error, :mutually_exclusive}
      else
        {:ok, %{hide_until: hide_until, enable_for_hours: hours}}
      end
    end
  end

  def parse(_), do: {:error, :invalid_entry}

  @doc """
  Changeset-style validation of an entry's window fields. Returns a list of
  error messages (empty = valid). Mirrors `parse/1` rejections so write paths
  can surface them per tool entry.
  """
  def validate_entry(entry) when is_map(entry) do
    case parse(entry) do
      {:ok, _} ->
        []

      {:error, :mutually_exclusive} ->
        ["hide_until and enable_for_hours are mutually exclusive"]

      {:error, {:invalid_datetime, field}} ->
        ["#{field}: invalid datetime (expected ISO8601 UTC)"]

      {:error, {:invalid_hours, msg}} ->
        ["enable_for_hours: #{msg}"]
    end
  end

  def validate_entry(_), do: ["entry must be an object"]

  @doc """
  Normalize an entry's window fields onto `base` (the normalized tool config
  being built by `MCPCustomScopes.normalize_tool_config/1`).

    * valid `hide_until` → stored as ISO8601 UTC string.
    * valid `enable_for_hours` → stored as integer, with `enabled_at` anchored
      to the existing anchor (re-parsed) or stamped `DateTime.utc_now()`.
    * invalid values (unparseable datetime, zero/negative/non-integer hours,
      mutually-exclusive pair) are dropped — same silent-drop policy as the
      boolean flag normalizers; strict rejection happens at the changeset.
  """
  def normalize_entry(base, config) when is_map(base) and is_map(config) do
    case parse(config) do
      {:ok, %{hide_until: %DateTime{} = until}} ->
        Map.put(base, @until_field, DateTime.to_iso8601(until))

      {:ok, %{enable_for_hours: hours}} when is_integer(hours) ->
        anchor = parse_until(raw(config, @anchor_field)) |> elem(1)
        anchor = anchor || DateTime.utc_now()

        base
        |> Map.put(@hours_field, hours)
        |> Map.put(@anchor_field, DateTime.to_iso8601(anchor))

      _ ->
        base
    end
  end

  def normalize_entry(base, _), do: base

  ## ------------------------------------------------------------------
  ## Evaluation
  ## ------------------------------------------------------------------

  @doc "Evaluate at now (convenience)."
  def evaluate(entry), do: evaluate(entry, DateTime.utc_now())

  @doc """
  Evaluate the window for a config entry at instant `at`.

      Window.evaluate(entry, at) :: {visible :: boolean, expires_at :: DateTime.t() | nil}

  `expires_at` is the instant the reported visibility stops holding (a
  re-evaluation hint for `EffectiveToolset`, not a hard flip). Entries without
  a window (or with an inert/unanchored one) evaluate `{true, nil}` — the
  inverted default-visible semantics.
  """
  def evaluate(entry, at)

  def evaluate(entry, %DateTime{} = at) when is_map(entry) do
    case parse(entry) do
      {:ok, %{hide_until: %DateTime{} = until}} ->
        hidden? = DateTime.compare(at, until) == :lt
        {not hidden?, if(hidden?, do: until, else: nil)}

      {:ok, %{enable_for_hours: hours}} when is_integer(hours) ->
        case parse_until(raw(entry, @anchor_field)) do
          {:ok, %DateTime{} = enabled_at} ->
            expires = DateTime.add(enabled_at, hours * 3600, :second)

            if DateTime.compare(at, expires) == :lt do
              {true, expires}
            else
              # Window elapsed → inert: static flags govern again.
              {true, nil}
            end

          _ ->
            # Unanchored window is inert — cannot have elapsed, cannot govern.
            {true, nil}
        end

      _ ->
        {true, nil}
    end
  end

  # Naive `at` is treated as UTC (repo naive-vs-UTC precedent).
  def evaluate(entry, %NaiveDateTime{} = at) do
    evaluate(entry, DateTime.from_naive!(at, "Etc/UTC"))
  end

  def evaluate(_, _), do: {true, nil}

  ## ------------------------------------------------------------------
  ## Internals
  ## ------------------------------------------------------------------

  defp raw(entry, key) when is_binary(key) do
    Map.get(entry, key) || Map.get(entry, String.to_atom(key))
  end

  defp parse_until(nil), do: {:ok, nil}

  defp parse_until(%DateTime{} = dt), do: {:ok, dt}

  defp parse_until(%NaiveDateTime{} = ndt),
    do: {:ok, DateTime.from_naive!(ndt, "Etc/UTC")}

  defp parse_until(bin) when is_binary(bin) do
    case DateTime.from_iso8601(bin) do
      {:ok, dt, _offset} ->
        {:ok, dt}

      {:error, _} ->
        # No offset → naive ISO8601; assume UTC per repo precedent.
        case NaiveDateTime.from_iso8601(bin) do
          {:ok, ndt} -> {:ok, DateTime.from_naive!(ndt, "Etc/UTC")}
          {:error, _} -> {:error, {:invalid_datetime, @until_field}}
        end
    end
  end

  defp parse_until(_), do: {:error, {:invalid_datetime, @until_field}}

  defp parse_hours(nil), do: {:ok, nil}
  defp parse_hours(h) when is_integer(h) and h > 0, do: {:ok, h}
  defp parse_hours(0), do: {:error, {:invalid_hours, "must be a positive integer (got 0)"}}

  defp parse_hours(h) when is_integer(h),
    do: {:error, {:invalid_hours, "must be a positive integer (got #{h})"}}

  defp parse_hours(_),
    do: {:error, {:invalid_hours, "must be a positive integer"}}
end
