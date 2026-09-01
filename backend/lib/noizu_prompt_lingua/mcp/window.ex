defmodule NoizuPromptLingua.MCP.Window do
  @moduledoc """
  F3 temporal windows: time-boxed visibility for tools in scope-config jsonb.

  Fields on a tool entry (see `TOBOR-CONTRACTS.md` §3):

      %{"hide_until" => iso8601_utc | nil,          # hidden until this instant
        "enable_for_hours" => pos_integer | nil}    # visible for N hours from anchor

  The two are **mutually exclusive** — a tool entry may carry one or neither,
  never both. Absent fields mean "no window" (tool visibility is governed by the
  static `hidden`/`disabled` flags per the inverted default-visible semantics).

  Anchoring: `enable_for_hours` needs a start instant. Every WRITE that
  normalizes a window entry stamps `set_at` (UTC ISO8601, `DateTime.utc_now()`)
  and the window anchors to it — so re-setting or extending an
  `enable_for_hours` window resets its anchor (contract §3 as ratified).
  `set_at` is stamped on `hide_until` writes too, as an AUDIT stamp only (no
  read path consumes a `hide_until` entry's `set_at`; only the
  `enable_for_hours` branch anchors to it).

  Legacy entries anchored via `enabled_at` (the pre-set_at field) still
  evaluate: `set_at` is preferred, `enabled_at` is the fallback. Hand-edited
  jsonb with a malformed anchor is INERT — normalization re-anchors it on
  write and evaluation treats the window as a no-op; it never raises.

  READ-path normalization (`preserve_anchors: true`, threaded from
  `EffectiveToolset.scope_config/1` → `MCPCustomScopes.normalize_config/3` →
  `normalize_entry/3`) must NEVER re-stamp an anchor: re-stamping would
  re-anchor the window to "now" on every read, so a live window would never
  expire (a permanent fail-open lift of `disabled`/`hidden`). With the option,
  a valid stored `set_at` (or legacy `enabled_at`) is carried verbatim and an
  unanchored/malformed anchor stays unanchored (inert) — fresh stamps happen
  on writes only.

  Naive-vs-UTC: naive datetime inputs (strings without an offset,
  `NaiveDateTime` structs) are interpreted as **UTC** — the repo-wide split
  precedent (cf. `chat_message.ex` microsecond/UTC notes,
  `dashboard.ex` Z-suffixed serialization).

  Evaluation is consumed by `NoizuPromptLingua.MCP.EffectiveToolset` (F2) via
  the combined `state/2` (one parse yields visibility, expiry, and the flag
  lift in one pass); `evaluate/2` and `lifting?/2` remain for focused callers:

      {visible, expires_at} = Window.evaluate(entry, at)

    * `hide_until` in the future → `{false, hide_until}` (hidden; state expires
      when the hide lifts).
    * `hide_until` past → `{true, nil}` (window over).
    * `enable_for_hours` live → `{true, expires_at}` (visible; expires when the
      window closes).
    * `enable_for_hours` elapsed → `{true, nil}` (window inert; the entry's
      static flags govern again — windows expire out, they never permanently
      flip state).

  A LIVE `enable_for_hours` window additionally LIFTS both static flags
  (disabled + hidden) while active — enforcement wiring is in
  `EffectiveToolset.build_state/2` via `lifting?/2`. Expired windows are
  no-ops for the lift too.
  """

  @until_field "hide_until"
  @hours_field "enable_for_hours"
  @anchor_field "enabled_at"
  @set_at_field "set_at"

  # Windows whose effect ended more than this long ago are dropped on write —
  # expired-but-recent windows are kept (they are inert at evaluation, but the
  # audit trail is fresh).
  @prune_after_days 7

  @type window :: %{
          hide_until: DateTime.t() | nil,
          enable_for_hours: pos_integer() | nil
        }

  @doc "Field names as stored in scope-config jsonb."
  def fields,
    do: %{
      until: @until_field,
      hours: @hours_field,
      anchor: @set_at_field,
      legacy_anchor: @anchor_field
    }

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
    with {:ok, hide_until} <- parse_until(raw(entry, @until_field), @until_field),
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

    * valid `hide_until` → stored as ISO8601 UTC string — unless the window
      expired more than #{@prune_after_days} days ago, in which case it is
      pruned (retention: expired windows are not kept forever).
    * valid `enable_for_hours` → stored as integer with a fresh `set_at`
      anchor (stamped now) — every write re-anchors, so re-setting/extending
      resets the window.
    * `set_at` is stamped on every write that keeps a window (audit stamp for
      `hide_until` entries; the ANCHOR for `enable_for_hours` entries).
    * invalid values (unparseable datetime — including a malformed anchor,
      which must be INERT, never a raise — zero/negative/non-integer hours,
      mutually-exclusive pair) are dropped — same silent-drop policy as the
      boolean flag normalizers; strict rejection happens at the changeset.

  `opts`:
    * `:preserve_anchors` — READ-path mode (see the moduledoc): carry a valid
      stored `set_at`/`enabled_at` verbatim instead of stamping fresh, and
      never mint an anchor that the stored entry did not have. Defaults to
      `false` (write semantics: stamp fresh).
  """
  def normalize_entry(base, config, opts \\ [])

  def normalize_entry(base, config, opts) when is_map(base) and is_map(config) do
    now = DateTime.utc_now()
    preserve? = Keyword.get(opts, :preserve_anchors, false) == true

    case parse(config) do
      {:ok, %{hide_until: %DateTime{} = until}} ->
        if prune?(until, now) do
          base
        else
          base
          |> Map.put(@until_field, DateTime.to_iso8601(until))
          |> put_stamp(now, preserve?)
        end

      {:ok, %{enable_for_hours: hours}} when is_integer(hours) ->
        cond do
          # set_at-era entry. WRITE contract: every write re-stamps, so a
          # re-set/extend slides the anchor to now. READ path (preserve?): the
          # stored anchor is carried verbatim so the window can expire.
          anchored_by_set_at?(config) ->
            base
            |> Map.put(@hours_field, hours)
            |> put_anchor(@set_at_field, raw(config, @set_at_field), now, preserve?)

          # Legacy (pre-set_at) jsonb anchored via enabled_at: PRESERVE the
          # anchor — it is the anchor on both paths (there is nothing to
          # re-stamp against); an explicit admin write merges its own window
          # map on top and (absent a valid set_at) re-anchors deliberately.
          legacy_anchor?(config) ->
            base
            |> Map.put(@hours_field, hours)
            # carry the legacy anchor verbatim so evaluation (which reads the
            # NORMALIZED entry) still finds it
            |> Map.put(@anchor_field, raw(config, @anchor_field))

          # Fresh window — stamp the anchor now (WRITE path only). The read
          # path must not mint an anchor the stored entry never had: an
          # unanchored window stays inert (never a permanent lift).
          true ->
            base
            |> Map.put(@hours_field, hours)
            |> put_stamp(now, preserve?)
        end

      _ ->
        base
    end
  end

  def normalize_entry(base, _, _), do: base

  ## ------------------------------------------------------------------
  ## Evaluation
  ## ------------------------------------------------------------------

  @doc """
  Combined evaluation — ONE parse of the entry yields everything
  `EffectiveToolset.build_state/2` needs (no double parse via evaluate/2 +
  lifting?/2):

      Window.state(entry, at) ::
        {window_visible :: boolean, expires_at :: DateTime.t() | nil, lifted? :: boolean}

    * `hide_until` future → `{false, hide_until, false}`.
    * `hide_until` past → `{true, nil, false}`.
    * `enable_for_hours` LIVE → `{true, expires_at, true}` (lifts both static
      flags while active).
    * `enable_for_hours` elapsed / unanchored / malformed → `{true, nil, false}`
      (window inert; static flags govern again — windows expire out, they never
      permanently flip state).
    * no window → `{true, nil, false}` (inverted default-visible semantics).
  """
  def state(entry, %DateTime{} = at) when is_map(entry) do
    case parse(entry) do
      {:ok, %{hide_until: %DateTime{} = until}} ->
        hidden? = DateTime.compare(at, until) == :lt
        {not hidden?, if(hidden?, do: until, else: nil), false}

      {:ok, %{enable_for_hours: hours}} when is_integer(hours) ->
        case enable_expires_at(entry, hours) do
          {:ok, expires} ->
            if DateTime.compare(at, expires) == :lt do
              {true, expires, true}
            else
              {true, nil, false}
            end

          :none ->
            # Unanchored (or malformed-anchor) window is inert — cannot have
            # elapsed, cannot govern. Never raises on hand-edited jsonb.
            {true, nil, false}
        end

      _ ->
        {true, nil, false}
    end
  end

  # Naive `at` is treated as UTC (repo naive-vs-UTC precedent).
  def state(entry, %NaiveDateTime{} = at), do: state(entry, DateTime.from_naive!(at, "Etc/UTC"))

  def state(_, _), do: {true, nil, false}

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
  def evaluate(entry, at) do
    {visible, expires_at, _lifted?} = state(entry, at)
    {visible, expires_at}
  end

  @doc "Lift check at now (convenience)."
  def lifting?(entry), do: lifting?(entry, DateTime.utc_now())

  @doc """
  True when the entry carries a LIVE `enable_for_hours` window at `at` —
  while active it LIFTS BOTH static flags (`disabled` and `hidden`); elapsed,
  unanchored, malformed, or absent windows are no-ops (`false`).
  """
  def lifting?(entry, at) do
    {_visible, _expires_at, lifted?} = state(entry, at)
    lifted?
  end

  ## ------------------------------------------------------------------
  ## Internals
  ## ------------------------------------------------------------------

  defp raw(entry, key) when is_binary(key) do
    Map.get(entry, key) || Map.get(entry, String.to_atom(key))
  end

  # Shared expiry math for `enable_for_hours` windows (evaluate/lifting? via
  # state/2): anchored → {:ok, expires_at}; unanchored/malformed → :none.
  defp enable_expires_at(entry, hours) do
    case anchor(entry) do
      {:ok, %DateTime{} = anchored_at} -> {:ok, DateTime.add(anchored_at, hours * 3600, :second)}
      _ -> :none
    end
  end

  # Anchor write-back. preserve? (READ path): carry the stored anchor verbatim
  # — re-stamping here would re-anchor the window to "now" on every read, so a
  # live window would never expire (fail-open lift). Write path: stamp now.
  defp put_anchor(base, field, value, _now, true), do: Map.put(base, field, value)

  defp put_anchor(base, _field, _value, now, false),
    do: Map.put(base, @set_at_field, DateTime.to_iso8601(now))

  # Audit stamp (hide_until entries; unanchored fresh windows). Write path only
  # — the read path never mints a `set_at` the stored entry did not carry.
  defp put_stamp(base, _now, true), do: base
  defp put_stamp(base, now, false), do: Map.put(base, @set_at_field, DateTime.to_iso8601(now))

  # Window anchor: `set_at` (stamped on every write) with legacy `enabled_at`
  # as fallback. A malformed value falls through to the fallback and then to
  # the inert no-op — never a raise.
  defp anchor(entry) do
    case parse_until(raw(entry, @set_at_field), @set_at_field) do
      {:ok, %DateTime{} = dt} -> {:ok, dt}
      _ -> parse_until(raw(entry, @anchor_field), @anchor_field)
    end
  end

  # Entry carries a VALID set_at anchor (the set_at-era write contract case).
  defp anchored_by_set_at?(entry) do
    case raw(entry, @set_at_field) do
      nil -> false
      value -> match?({:ok, %DateTime{}}, parse_until(value, @set_at_field))
    end
  end

  # Entry carries a VALID legacy enabled_at anchor (pre-set_at jsonb).
  defp legacy_anchor?(entry) do
    case raw(entry, @anchor_field) do
      nil -> false
      value -> match?({:ok, %DateTime{}}, parse_until(value, @anchor_field))
    end
  end

  defp prune?(expiry, now),
    do: DateTime.compare(expiry, DateTime.add(now, -@prune_after_days, :day)) == :lt

  # `field` names the key the value was read from, so error tuples report the
  # actual field ("hide_until", "set_at", "enabled_at") rather than a hardcoded
  # one — surfaced verbatim by validate_entry/1.
  defp parse_until(nil, _field), do: {:ok, nil}

  defp parse_until(%DateTime{} = dt, _field), do: {:ok, dt}

  defp parse_until(%NaiveDateTime{} = ndt, _field),
    do: {:ok, DateTime.from_naive!(ndt, "Etc/UTC")}

  defp parse_until(bin, field) when is_binary(bin) do
    case DateTime.from_iso8601(bin) do
      {:ok, dt, _offset} ->
        {:ok, dt}

      {:error, _} ->
        # No offset → naive ISO8601; assume UTC per repo precedent.
        case NaiveDateTime.from_iso8601(bin) do
          {:ok, ndt} -> {:ok, DateTime.from_naive!(ndt, "Etc/UTC")}
          {:error, _} -> {:error, {:invalid_datetime, field}}
        end
    end
  end

  defp parse_until(_, field), do: {:error, {:invalid_datetime, field}}

  defp parse_hours(nil), do: {:ok, nil}
  defp parse_hours(h) when is_integer(h) and h > 0, do: {:ok, h}
  defp parse_hours(0), do: {:error, {:invalid_hours, "must be a positive integer (got 0)"}}

  defp parse_hours(h) when is_integer(h),
    do: {:error, {:invalid_hours, "must be a positive integer (got #{h})"}}

  defp parse_hours(_),
    do: {:error, {:invalid_hours, "must be a positive integer"}}
end
