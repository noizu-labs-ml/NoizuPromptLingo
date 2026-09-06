defmodule NoizuPromptLingua.MCP.ToolsetProvider do
  @moduledoc """
  `Noizu.MCP.Persistence` over NPL's OWN tables (PRD-N2 §4.2, PERMANENT
  disposition — Decision 2): the lib's `noizu_mcp_toolset*` tables get zero
  rows, ever. Selected per server via
  `providers: [persistence: NoizuPromptLingua.MCP.ToolsetProvider, ...]`.

  Store mapping:

    * `"toolsets"` — slug-addressable `%Noizu.MCP.Toolset.Custom{}` records.
      READS project NPL's existing write paths (PRD-5 §4.1 contract: the
      provider is the lib's VIEW, it does not duplicate set authoring):
      the 5 virtual profiles (`Toolsets.Profiles.custom/1`) and
      `mcp_tool_sets` rows via `ToolSets.assemble_custom/2` (org-addressed
      through `opts[:organization_id]`). Host/lib-authored records (the
      conformance battery, future embedding paths) persist to the provider
      record store. `put`/`delete` never touch a profile (immutable, R1).
    * `"toolset_grants"` — per-caller weight-200 layers. `put/get/delete`
      persist real records to the provider store; `list` UNIONS them with
      the LEGACY GRANT PROJECTION: a filter carrying
      `%{toolset_slug: s, authenticator: a, subject: subj}` reads the
      subject's `toolset_config` once (`mcp_api_keys` by row id for
      `:api_key`, `oauth_clients` by public `client_id` for `:oauth`) and
      projects it onto the requested slug as an `:allow` grant —
      `enabled: false` ⇒ `:set_visible`/`:set_callable` false,
      `visible: false` ⇒ `:set_visible` false, `name_override`/
      `description_override` ⇒ `:set_name`/`:set_description`, window
      fields ⇒ grant `expires_at` via `MCP.Window`. Inverted-default
      preservation (Decision 7 / grants-never-hide): an absent row projects
      nothing; a present row with no narrowing projects an EMPTY-ops grant
      (base surface).
    * `"toolset_negotiations"` — consent records. Real storage in the
      provider store; the WRITER is `ToolsetNegotiations` (consent path,
      elevation metadata). No legacy projection source exists yet
      (`required_scopes` arrives with the consent rework).

  ## Provider record store

  The store table `npl_mcp_toolset_store` is NPL-owned (created by
  `ProviderStoreTestSchema` in tests; the production DDL ships with the flip
  train alongside provider activation — FR-2B-7). When the table is absent
  (development/prod before the flip) every store op degrades per lib D5:
  `put` errors, reads return the projections alone, `version` falls back to
  the source-table fingerprint — nothing crashes.

  ## version/2

  Integer-string fingerprint per store:
  `vsn_offset * 10^21 + unix_watermark * 10^7 + write_counter` — the
  counter bumps on every provider write (put AND delete) and on
  source-table DRIFT (max(updated_at)/row-count change, synced on read, so
  admin-path set edits rotate the fingerprint without a provider write);
  the vsn offset mixes `Application.spec(:noizu_prompt_lingua, :vsn)` per
  PRD-5 §4.1. Monotonic per store, stable across identical states.

  Note: DateTime fields survive the shared codec's JSON round-trip because
  a `Jason.Encoder` impl for DateTime ships in the core dep — the same
  guarantee the lib's own Memory/Ecto providers stand on.
  """

  @behaviour Noizu.MCP.Persistence

  alias Noizu.MCP.Persistence
  alias Noizu.MCP.Permission.Grant
  alias Noizu.MCP.Toolset.Override
  alias NoizuPromptLingua.MCP.ToolSets
  alias NoizuPromptLingua.MCP.Toolsets.Profiles
  alias NoizuPromptLingua.MCP.Window
  alias NoizuPromptLingua.Repo

  require Logger

  @store_table "npl_mcp_toolset_store"
  @counter_id "__counter__"
  @version_vsn_place 1_000_000_000_000_000_000_000
  @version_wm_place 10_000_000

  @uuid_regex ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

  # ── put ───────────────────────────────────────────────────────────────────

  @impl true
  def put(store_key, id, record, opts) when is_binary(id) do
    with :ok <- Persistence.guard_store_key(store_key),
         :ok <- guard_profile(store_key, id),
         {:ok, json, _fields, meta} <- Persistence.encode_record(store_key, record) do
      with_store(opts, fn repo ->
        repo.query!(
          """
          INSERT INTO #{@store_table} (store_key, record_id, record, expires_at, inserted_at)
          VALUES ($1, $2, $3::jsonb, $4, $5)
          ON CONFLICT (store_key, record_id) DO UPDATE SET
            record = EXCLUDED.record, expires_at = EXCLUDED.expires_at,
            inserted_at = EXCLUDED.inserted_at, updated_at = now()
          """,
          [store_key, id, json, meta.expires_at, meta.inserted_at]
        )

        bump_counter(store_key, repo)
        :ok
      end)
    end
  end

  def put(_store_key, _id, _record, _opts), do: {:error, {:invalid_id, "id must be a string"}}

  # Profiles are code-defined and immutable (R1); the store never shadows them.
  defp guard_profile("toolsets", id) do
    if id in Profiles.slugs(), do: {:error, :immutable_record}, else: :ok
  end

  defp guard_profile(_, _), do: :ok

  # ── get ───────────────────────────────────────────────────────────────────

  @impl true
  def get(store_key, id, opts) when is_binary(id) do
    with :ok <- Persistence.guard_store_key(store_key) do
      case stored_record(store_key, id, opts) do
        {:ok, record} -> {:ok, record}
        # Missing store table (pre-flip) or absent record: fall through to
        # the projections — production reads never need the store table.
        :miss -> project_record(store_key, id, opts)
        {:error, :store_unavailable} -> project_record(store_key, id, opts)
        {:error, _} = error -> error
      end
    end
  end

  def get(_store_key, _id, _opts), do: {:error, {:invalid_id, "id must be a string"}}

  # Stored record, expiry-excluded (the store invariant — every row's
  # expires_at mirrors the record's).
  defp stored_record(store_key, id, opts) do
    with_store(opts, fn repo ->
      case repo.query!(
             """
             SELECT record FROM #{@store_table}
             WHERE store_key = $1 AND record_id = $2
               AND (expires_at IS NULL OR expires_at > $3)
             """,
             [store_key, id, DateTime.utc_now()]
           ) do
        %{rows: [[record]]} -> Persistence.revive_record(store_key, jsonb(record))
        %{rows: []} -> :miss
      end
    end)
  end

  # Production projections (PRD-5 §4.1 row 1): profiles first (reserved
  # slugs — no set row can shadow them), then set rows via the request-path
  # lookup, org-addressed only (a provider get without org context never
  # scans across orgs).
  defp project_record("toolsets", id, opts) do
    cond do
      profile = Profiles.get(id) ->
        {:ok, Profiles.custom(profile)}

      slug = set_slug(id) ->
        project_set(opts[:organization_id], slug)

      org = opts[:organization_id] ->
        project_set(org, id)

      true ->
        :error
    end
  end

  defp project_record(_, _, _), do: :error

  # "set:deploy-tools" (the assemble_custom slug form) → "deploy-tools".
  defp set_slug("set:" <> slug), do: slug
  defp set_slug(_), do: nil

  defp project_set(_org, nil), do: :error

  defp project_set(org, slug) when is_binary(org) do
    case ToolSets.get_for_request(org, slug) do
      nil -> :error
      tool_set -> {:ok, ToolSets.assemble_custom(tool_set)}
    end
  end

  defp project_set(_, _), do: :error

  # ── list ──────────────────────────────────────────────────────────────────

  @impl true
  def list(store_key, filter, opts) do
    with :ok <- Persistence.guard_store_key(store_key) do
      filter = filter || %{}
      at = Map.get(filter, :at) || DateTime.utc_now()

      stored = list_stored(store_key, filter, at, opts)
      projected = list_projected(store_key, filter, at, opts)

      {:ok,
       Enum.sort(stored ++ projected, fn a, b ->
         to_unix(inserted_at(a)) > to_unix(inserted_at(b))
       end)}
    end
  end

  defp inserted_at(%{inserted_at: dt}), do: dt
  defp inserted_at(_), do: nil

  defp to_unix(%DateTime{} = dt), do: DateTime.to_unix(dt)
  defp to_unix(nil), do: 0

  defp list_stored(store_key, filter, at, opts) do
    case with_store(opts, fn repo ->
           repo.query!(
             """
             SELECT record FROM #{@store_table}
             WHERE store_key = $1 AND record_id <> '#{@counter_id}'
               AND (expires_at IS NULL OR expires_at > $2)
             ORDER BY inserted_at DESC
             """,
             [store_key, at]
           )
           |> Map.get(:rows, [])
           |> Enum.flat_map(fn [record] ->
             case Persistence.revive_record(store_key, jsonb(record)) do
               {:ok, rec} ->
                 [rec]

               {:error, reason} ->
                 # A corrupted row degrades ITSELF, not the store (D5).
                 Logger.warning("ToolsetProvider: dropping unreadable row: #{inspect(reason)}")
                 []
             end
           end)
           |> Enum.filter(&Persistence.match_filter?(&1, filter))
         end) do
      records when is_list(records) -> records
      # Missing store table ⇒ no stored rows (projections still serve).
      _other -> []
    end
  end

  # Legacy grant projection: only for the exact read shape the lib context
  # pass issues (and the PRD's rule) — subject AND authenticator in the
  # filter. Every other filter shape sees stored records only, so the
  # conformance battery's storage semantics are never diluted.
  defp list_projected("toolset_grants", filter, at, opts) do
    with subject when is_binary(subject) <- filter[:subject],
         authenticator when not is_nil(authenticator) <- filter[:authenticator] do
      project_legacy_grant(authenticator, subject, filter[:toolset_slug], at, opts)
      |> Enum.filter(&Persistence.match_filter?(&1, filter))
    else
      _ -> []
    end
  end

  defp list_projected(_store_key, _filter, _at, _opts), do: []

  # THE legacy projection rule (PRD-5 §5 row 2 / FR-2B-2): read the
  # subject's config ONCE, project onto the requested slug as a single
  # :allow grant. Absent row ⇒ no grant (an absent config is not a denial —
  # grants-never-hide); present-but-empty config ⇒ empty-ops grant (base
  # surface).
  defp project_legacy_grant(authenticator, subject, toolset_slug, at, _opts) do
    case subject_config(authenticator, subject) do
      nil ->
        []

      %{config: config, updated_at: updated_at} ->
        [
          %Grant{
            id: legacy_grant_id(authenticator, subject, toolset_slug),
            toolset_slug: toolset_slug || "*",
            authenticator: authenticator,
            subject: subject,
            effect: :allow,
            scopes: [],
            tool_overrides: grant_ops(config, at),
            expires_at: grant_expiry(config, at),
            inserted_at: updated_at,
            metadata: %{"source" => "legacy_toolset_config"}
          }
        ]
    end
  end

  defp legacy_grant_id(authenticator, subject, toolset_slug) do
    "legacy:#{authenticator}:#{subject}" <>
      if(toolset_slug, do: ":#{toolset_slug}", else: "")
  end

  # `:api_key` matches on the key row's uuid id (the principal subject per
  # PrincipalMapper); `:oauth` on the public client_id. A non-uuid api-key
  # subject can never be a row — skip the lookup instead of casting (an
  # Ecto cast error would degrade the whole listing, D5).
  defp subject_config(authenticator, subject) do
    normalized = authenticator && to_string(authenticator)

    cond do
      normalized == "api_key" and uuid?(subject) ->
        row = Repo.get(NoizuPromptLingua.Schema.McpApiKey, subject)
        row && %{config: row.toolset_config, updated_at: row.updated_at}

      normalized == "oauth" and is_binary(subject) and subject != "" ->
        row = Repo.get_by(NoizuPromptLingua.Schema.OAuthClient, client_id: subject)
        row && %{config: row.toolset_config, updated_at: row.updated_at}

      true ->
        nil
    end
  end

  defp uuid?(subject), do: is_binary(subject) and Regex.match?(@uuid_regex, subject)

  # toolset_config → %{tool_key => [%Override{}]} (PRD-5 §5). Reads BOTH
  # vocabularies: the W8 legacy flags (`enabled`/`visible`/`name_override`/
  # `description_override`) and the N2a closed vocabulary (`enabled`/`name`/
  # `description` via `ToolSets.to_overrides/1`). Arg-level ops are set-
  # static-layer material — grants adjust tools. One op per (tool, op) slot:
  # duplicate opinions would collide at the merge fold (equal-weight
  # conflict). Tool keys are preserved AS WRITTEN — the base spec names are
  # the registration-era spellings (dotted until the N5 canonicalization
  # flip), and the lib compose matches op targets against those names
  # exactly.
  defp grant_ops(config, at) when is_map(config) do
    (legacy_ops(config, at) ++ new_vocab_ops(config))
    |> Enum.group_by(& &1.tool)
    |> Map.new(fn {tool, ops} -> {tool, Enum.uniq_by(ops, & &1.op)} end)
  end

  defp grant_ops(_config, _at), do: %{}

  defp legacy_ops(config, at) do
    config
    |> Map.get("groups", %{})
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.flat_map(fn {_group_id, group_cfg} ->
      group_cfg
      |> Map.get("tools", %{})
      |> Enum.sort_by(&elem(&1, 0))
      |> Enum.flat_map(fn {tool_name, tool_cfg} ->
        tool = to_string(tool_name)

        tool_cfg
        |> flags(at)
        |> Enum.map(&with_tool(&1, tool))
      end)
    end)
  end

  # Legacy flag vocabulary (W8 blocked entries + PRD FR-2B-2 mapping):
  # `enabled: false` ⇒ visible+callable off; `visible: false` ⇒ visible off
  # only; a future `hide_until` window hides until it lifts (an
  # `enable_for_hours` window LIFTS static flags while live (F3) — it never
  # produces ops).
  defp flags(tool_cfg, at) when is_map(tool_cfg) do
    disabled? = Map.get(tool_cfg, "enabled") == false or Map.get(tool_cfg, "disabled") == true
    hidden? = Map.get(tool_cfg, "visible") == false or Map.get(tool_cfg, "hidden") == true

    [] ++
      if_ops(disabled? or windowed_hidden?(tool_cfg, at), :set_visible, false) ++
      if_ops(disabled?, :set_callable, false) ++
      if_ops(hidden?, :set_visible, false) ++
      override_ops(Map.get(tool_cfg, "name_override"), :set_name) ++
      override_ops(Map.get(tool_cfg, "description_override"), :set_description) ++
      override_ops(Map.get(tool_cfg, "name"), :set_name) ++
      override_ops(Map.get(tool_cfg, "description"), :set_description)
  end

  defp flags(_tool_cfg, _at), do: []

  defp windowed_hidden?(tool_cfg, at) do
    case Window.state(tool_cfg, at) do
      {false, _expires, false} -> true
      _ -> false
    end
  end

  defp if_ops(true, op, value), do: [%Override{op: op, target: nil, value: value}]
  defp if_ops(false, _op, _value), do: []

  defp override_ops(nil, _op), do: []

  defp override_ops(value, op) when is_binary(value) and value != "",
    do: [%Override{op: op, target: nil, value: value}]

  defp override_ops(_, _), do: []

  defp with_tool(%Override{} = op, tool), do: %Override{op | target: tool, tool: tool}

  # N2a closed-vocabulary configs ride the pure translator (tool-level ops
  # only; arg ops would need the catalog's cast plan, which is static-layer
  # material). Tool keys preserved as-written (see grant_ops/2).
  defp new_vocab_ops(config) do
    config
    |> ToolSets.to_overrides()
    |> Enum.flat_map(fn
      %{op: op, target: target, value: value}
      when op in [:set_visible, :set_callable, :set_name, :set_description] and is_map(target) ->
        tool = to_string(target.tool)
        [%Override{op: op, target: tool, tool: tool, value: value}]

      _op ->
        []
    end)
  end

  # Grant expiry = the earliest window close across the configured tools
  # (the subject's grant ends when its first window closes); entries
  # without windows contribute nothing (PRD-5 §5: `expires_at` via
  # `MCP.Window`).
  defp grant_expiry(config, at) when is_map(config) do
    config
    |> Map.get("groups", %{})
    |> Enum.flat_map(fn {_group_id, group_cfg} ->
      group_cfg
      |> Map.get("tools", %{})
      |> Enum.map(fn {_tool, tool_cfg} ->
        case Window.evaluate(tool_cfg, at) do
          {_visible, %DateTime{} = expires} -> expires
          _ -> nil
        end
      end)
    end)
    |> Enum.reject(&is_nil/1)
    |> case do
      [] -> nil
      expiries -> Enum.min(expiries, DateTime)
    end
  end

  defp grant_expiry(_config, _at), do: nil

  # ── delete ────────────────────────────────────────────────────────────────

  @impl true
  def delete(store_key, id, opts) when is_binary(id) do
    with :ok <- Persistence.guard_store_key(store_key),
         :ok <- guard_profile(store_key, id) do
      with_store(opts, fn repo ->
        repo.query!(
          "DELETE FROM #{@store_table} WHERE store_key = $1 AND record_id = $2",
          [store_key, id]
        )

        maybe_deactivate_set(store_key, id, opts)
        bump_counter(store_key, repo)
        :ok
      end)
    end
  end

  def delete(_store_key, _id, _opts), do: {:error, {:invalid_id, "id must be a string"}}

  # Deleting a set-addressed toolset soft-kills the SET row (R8) — the
  # provider is the lib's view of NPL's existing write paths. Only when the
  # caller gave us the org coordinate to do it safely.
  defp maybe_deactivate_set("toolsets", id, opts) do
    with slug when is_binary(slug) <- set_slug(id) || id,
         org when is_binary(org) <- opts[:organization_id],
         %NoizuPromptLingua.Schema.MCPToolSet{} = tool_set <-
           ToolSets.get_by_org_and_slug(org, slug) do
      ToolSets.deactivate(tool_set)
      :ok
    else
      _ -> :ok
    end
  end

  defp maybe_deactivate_set(_, _, _), do: :ok

  # ── version ───────────────────────────────────────────────────────────────

  @impl true
  def version(store_key, opts) do
    with :ok <- Persistence.guard_store_key(store_key) do
      do_version(store_key, opts)
    end
  end

  defp do_version(store_key, opts) do
    fp = fingerprint_string_tuple(source_fingerprint(store_key))

    case counter_row(store_key, opts) do
      {:error, :store_unavailable} ->
        # No provider store (pre-flip): fingerprint-only rotation.
        {:ok, version_string(0, fingerprint_unix(source_fingerprint(store_key)))}

      nil ->
        # First read: seed from the current state (no spurious rotation for
        # a store that never changed).
        counter = 1
        wm = max(unix_now(), fingerprint_unix(source_fingerprint(store_key)))
        write_counter_row(store_key, counter, wm, fp, opts)
        {:ok, version_string(counter, wm)}

      {counter, wm, stored_fp} ->
        if fp == stored_fp do
          {:ok, version_string(counter, wm)}
        else
          # Source-table drift (admin-path writes outside the provider) —
          # rotate on read, which is exactly when the lib cache consults it.
          counter = counter + 1
          wm = max(wm, fingerprint_unix(source_fingerprint(store_key)))

          write_counter_row(store_key, counter, wm, fp, opts)
          {:ok, version_string(counter, wm)}
        end
    end
  end

  # vsn_offset * 10^21 + unix_wm * 10^7 + counter — integer-parseable and
  # monotonic (the watermark never decreases; the counter only bumps), and
  # it MIXES the app vsn per PRD-5 §4.1 (a vsn change rotates every store).
  defp version_string(counter, wm) do
    Integer.to_string(
      vsn_offset() * @version_vsn_place + wm * @version_wm_place + rem(counter, @version_wm_place)
    )
  end

  defp vsn_offset do
    vsn =
      case Application.spec(:noizu_prompt_lingua, :vsn) do
        vsn when is_list(vsn) -> List.to_string(vsn)
        vsn when is_binary(vsn) -> vsn
        _ -> "0"
      end

    abs(:erlang.phash2(vsn))
  end

  # The bump on every provider write (put AND delete) — the lib's
  # monotonic-per-store contract. Two queries (read then write): a lost
  # race can only skip a bump, never regress the watermark.
  defp bump_counter(store_key, repo) do
    fp = fingerprint_string_tuple(source_fingerprint(store_key))
    wm = max(unix_now(), fingerprint_unix(source_fingerprint(store_key)))

    case read_counter_row(store_key, repo) do
      nil ->
        write_counter_row_repo(repo, store_key, 1, wm, fp)

      {counter, prev_wm, _prev_fp} ->
        write_counter_row_repo(repo, store_key, counter + 1, max(wm, prev_wm), fp)
    end
  end

  defp counter_row(store_key, opts) do
    with_store(opts, fn repo -> read_counter_row(store_key, repo) end)
  end

  # Counter row: record_id "__counter__", record %{"counter" => n,
  # "wm" => unix, "fp" => fingerprint}.
  defp read_counter_row(store_key, repo) do
    case repo.query!(
           """
           SELECT record FROM #{@store_table}
           WHERE store_key = $1 AND record_id = $2
           """,
           [store_key, @counter_id]
         ) do
      %{rows: [[record]]} ->
        record = jsonb(record)
        {Map.get(record, "counter", 0), Map.get(record, "wm", 0), Map.get(record, "fp")}

      %{rows: []} ->
        nil
    end
  end

  # jsonb columns arrive DECODED when postgrex runs with a json library, and
  # as raw JSON binaries otherwise — decode defensively so the provider
  # behaves identically either way (no per-host forks; same posture as the
  # lib Ecto provider).
  defp jsonb(bin) when is_binary(bin), do: Jason.decode!(bin)
  defp jsonb(other), do: other

  defp write_counter_row(store_key, counter, wm, fp, opts) do
    with_store(opts, fn repo -> write_counter_row_repo(repo, store_key, counter, wm, fp) end)
  end

  defp write_counter_row_repo(repo, store_key, counter, wm, fp) do
    repo.query!(
      """
      INSERT INTO #{@store_table} (store_key, record_id, record)
      VALUES ($1, $2, $3::jsonb)
      ON CONFLICT (store_key, record_id) DO UPDATE SET
        record = EXCLUDED.record, updated_at = now()
      """,
      [store_key, @counter_id, Jason.encode!(%{"counter" => counter, "wm" => wm, "fp" => fp})]
    )

    :ok
  end

  # ── source fingerprints ───────────────────────────────────────────────────

  # {row_count, max(updated_at) | nil} over the store's projected source
  # tables (PRD-5 §4.1 fingerprint inputs). Negotiations have no legacy
  # source (provider-store writes rotate via the counter).
  defp source_fingerprint("toolsets"), do: repo_stats("mcp_tool_sets")

  defp source_fingerprint("toolset_grants") do
    {c1, m1} = repo_stats("mcp_api_keys")
    {c2, m2} = repo_stats("oauth_clients")
    {c1 + c2, later(m1, m2)}
  end

  defp source_fingerprint("toolset_negotiations"), do: {0, nil}

  defp repo_stats(table) do
    case Repo.query("SELECT count(*)::bigint, max(updated_at) FROM #{table}", []) do
      {:ok, %{rows: [[count, max_at]]}} -> {count, max_at}
      _ -> {0, nil}
    end
  end

  defp later(nil, b), do: b
  defp later(a, nil), do: a
  defp later(a, b), do: if(DateTime.compare(a, b) == :gt, do: a, else: b)

  defp fingerprint_string_tuple({count, max_at}),
    do: "#{count}:#{if(max_at, do: DateTime.to_iso8601(max_at), else: "0")}"

  defp fingerprint_unix({count, max_at}), do: max(unix_now(), to_unix(max_at) + count)

  defp unix_now, do: System.system_time(:second)

  # ── store availability ────────────────────────────────────────────────────

  # Run `fun` against the provider store; a missing table (pre-flip dev/prod)
  # degrades instead of crashing (lib D5). `put` reports the outage; reads
  # fall back to projections/fingerprints only.
  defp with_store(opts, fun) do
    repo = Keyword.get(opts, :repo) || Repo
    fun.(repo)
  rescue
    e in [Postgrex.Error] ->
      if store_missing?(e) do
        {:error, :store_unavailable}
      else
        reraise e, __STACKTRACE__
      end
  end

  defp store_missing?(%Postgrex.Error{postgres: %{code: :undefined_table}}), do: true
  defp store_missing?(_), do: false
end
