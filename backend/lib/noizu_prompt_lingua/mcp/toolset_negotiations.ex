defmodule NoizuPromptLingua.MCP.ToolsetNegotiations do
  @moduledoc """
  The consent-path WRITER for `toolset_negotiations` records (PRD-N2 §N2b
  ToolGuard re-homing prep): destructive-elevation metadata
  (`elevation_uri`) and consent outcomes are persisted as
  `%Noizu.MCP.Permission.Negotiation{}` records through
  `ToolsetProvider` (NPL's own provider store — never the lib tables).

  The lib consumes these at composition (weight-200 layer: unsatisfied ⇒
  tool visible-but-uncallable; satisfied+granted ⇒ `metadata_overrides`
  fold onto the tool's `_meta`, which is how elevation URIs ride to
  clients — PRD-5 §5). The legacy `dispatch.ex` call site dies at N5;
  this writer and `AclProvider`'s deny hook are the re-homed seams.

  Writers:

    * `record/2` — the general path (attrs → negotiation record).
    * `record_elevation/5` — a destructive tool needs step-up; mints the
      elevation URI via `OAuth.Elevation` when a user identity is
      available.
    * `record_consent/5` — the consent conversation concluded (granted).
    * `record_client_consent/2` — hook for the consent writer
      (`OAuth.Clients.update_toolset_config/2`): destructive tools named in
      a consent narrowing get a pending negotiation. Best-effort — a
      negotiation write can NEVER fail the consent write.
    * `on_acl_denied/3` — hook for `AclProvider` deny verdicts (env-gated
      via `:mcp_negotiations` `auto_record`, default off until N5 flips
      enforcement).
  """

  alias Noizu.MCP.Permission.Negotiation
  alias NoizuPromptLingua.MCP.ToolNames
  alias NoizuPromptLingua.MCP.ToolsetProvider

  require Logger

  # A set-agnostic negotiation slug for client-scoped consent records
  # (consent is about the CLIENT on a tool; the per-set conversation rides
  # `toolset_slug` when the caller knows it).
  @client_slug_prefix "_client:"

  @doc "Persist one negotiation record; returns the provider put result."
  def record(attrs, opts \\ []) when is_map(attrs) or is_list(attrs) do
    attrs = Map.new(attrs)

    id =
      Map.get(attrs, :id) || "neg-" <> Base.encode16(:crypto.strong_rand_bytes(8), case: :lower)

    # `subject` rides metadata (the lib record kind has no subject field —
    # negotiations gate a TOOL for an authenticator, not a subject row). The
    # elevation URI rides metadata_overrides (it FOLDS onto the tool's
    # effective _meta — how it reaches clients) and metadata (provenance).
    metadata =
      (attrs[:metadata] || %{})
      |> Map.new(fn {k, v} -> {to_string(k), v} end)
      |> Map.put_new("subject", attrs[:subject])
      |> Map.put_new("elevation_uri", attrs[:elevation_uri])
      |> Map.reject(fn {_k, v} -> is_nil(v) end)

    metadata_overrides =
      (attrs[:metadata_overrides] || %{})
      |> Map.new(fn {k, v} -> {to_string(k), v} end)
      |> Map.put_new("elevation_uri", attrs[:elevation_uri])
      |> Map.reject(fn {_k, v} -> is_nil(v) end)

    negotiation = %Negotiation{
      id: id,
      toolset_slug: attrs[:toolset_slug] || "_server",
      authenticator: attrs[:authenticator],
      tool: attrs[:tool] && ToolNames.canonical(attrs[:tool]),
      required_scopes: List.wrap(attrs[:required_scopes]),
      granted: !!attrs[:granted],
      metadata_overrides: metadata_overrides,
      expires_at: attrs[:expires_at],
      metadata: metadata
    }

    ToolsetProvider.put("toolset_negotiations", id, negotiation, opts)
  end

  @doc """
  A destructive tool needs step-up (the ToolGuard `sensitivity:
  :destructive` conversation): record an unsatisfied negotiation carrying
  the elevation URI. The URI is taken from `opts[:elevation_uri]` or minted
  via `OAuth.Elevation` when `opts[:user_id]` is available; without an
  identity the record still lands (the URI completes at the consent step).
  """
  def record_elevation(toolset_slug, authenticator, subject, tool, opts \\ []) do
    record(
      [
        toolset_slug: toolset_slug,
        authenticator: authenticator,
        subject: subject,
        tool: tool,
        granted: false,
        required_scopes: opts[:required_scopes] || [],
        elevation_uri: opts[:elevation_uri] || mint_elevation_uri(tool, opts),
        metadata: [via: "acl_deny"]
      ],
      opts
    )
  end

  @doc "The consent conversation concluded affirmatively for `tool`."
  def record_consent(toolset_slug, authenticator, subject, tool, opts \\ []) do
    record(
      [
        toolset_slug: toolset_slug,
        authenticator: authenticator,
        subject: subject,
        tool: tool,
        granted: true,
        required_scopes: opts[:required_scopes] || [],
        metadata: [via: "consent"]
      ],
      opts
    )
  end

  @doc """
  Consent-writer hook (`OAuth.Clients.update_toolset_config/2`): destructive
  tools named in the narrowing get a pending-elevation negotiation on the
  client slug. Best-effort and silent — never fails the consent write.
  """
  def record_client_consent(client, config) do
    if Application.get_env(:noizu_prompt_lingua, :mcp_negotiations, [])
       |> Keyword.get(:consent_writer, true) do
      config
      |> Map.get("groups", %{})
      |> Enum.flat_map(fn {_group, group_cfg} -> Map.keys(Map.get(group_cfg, "tools") || %{}) end)
      |> Enum.uniq_by(&ToolNames.canonical/1)
      |> Enum.filter(&destructive_tool?/1)
      |> Enum.each(fn tool ->
        record(
          [
            toolset_slug: "#{@client_slug_prefix}#{client.client_id}",
            authenticator: :oauth,
            subject: client.client_id,
            tool: tool,
            granted: false,
            metadata: [via: "consent_narrowing", pending_elevation: true]
          ],
          []
        )
      end)

      :ok
    else
      :disabled
    end
  rescue
    e ->
      # A negotiation write can never fail the consent write (D5 posture).
      Logger.warning("[ToolsetNegotiations] consent hook degraded: #{Exception.message(e)}")

      :degraded
  end

  @doc """
  `AclProvider.check_all/5` deny hook — the RBAC/PDP step-up conversation
  re-homed off the `dispatch.ex` call site (which retires at N5).
  Env-gated (`:mcp_negotiations` `auto_record`, default OFF until the flip
  turns enforcement on); never affects the verdict.
  """
  def on_acl_denied(tool, subject, opts) do
    if Application.get_env(:noizu_prompt_lingua, :mcp_negotiations, [])
       |> Keyword.get(:auto_record, false) do
      principal_attrs = principal_attrs(subject)

      record_elevation(
        opts[:toolset_slug] || "_server",
        principal_attrs.authenticator,
        principal_attrs.subject,
        tool,
        Keyword.take(opts, [:user_id, :elevation_uri, :required_scopes])
      )

      :ok
    else
      :disabled
    end
  rescue
    _ -> :degraded
  end

  # ── destructive-tool registry ─────────────────────────────────────────────

  @doc "True when the canonical tool's authz blob tags `sensitivity: :destructive`."
  def destructive_tool?(tool_name) do
    MapSet.member?(destructive_tools(), ToolNames.canonical(tool_name))
  end

  # Compile-time-static registry — computed once per node and cached. The
  # scan covers every customizable group's registered tools (the same
  # universe sets draw from); plane tools (discovery/NPL) are ungated by
  # policy.
  defp destructive_tools do
    case :persistent_term.get({__MODULE__, :destructive_tools}, nil) do
      %MapSet{} = cached ->
        cached

      nil ->
        computed =
          NoizuPromptLingua.MCPServers.customizable()
          |> NoizuPromptLingua.MCP.ToolSets.universe_for_groups()
          |> Map.get(:specs, %{})
          |> Enum.filter(fn {_name, spec} -> destructive_spec?(spec) end)
          |> Enum.map(fn {name, _spec} -> name end)
          |> MapSet.new()

        :persistent_term.put({__MODULE__, :destructive_tools}, computed)
        computed
    end
  end

  # Read the opaque authz blob wherever the Tool macro stows it (same
  # tolerant reading as ToolGuard: top-level :authz or under spec meta,
  # atom/string keys).
  defp destructive_spec?(spec) do
    case authz_of(spec) do
      nil ->
        false

      authz ->
        sensitivity = get_meta(authz, :sensitivity)
        sensitivity in [:destructive, "destructive"]
    end
  end

  defp authz_of(spec) do
    meta_of(spec, :authz) ||
      case meta_of(spec, :meta) do
        meta when is_map(meta) -> get_meta(meta, :authz)
        meta when is_list(meta) -> get_meta(meta, :authz)
        _ -> nil
      end
  end

  defp meta_of(spec, key) when is_map(spec), do: Map.get(spec, key)
  defp meta_of(_spec, _key), do: nil

  defp get_meta(kw, key) when is_list(kw), do: Keyword.get(kw, key) || string_lookup(kw, key)

  defp get_meta(map, key) when is_map(map),
    do: Map.get(map, key) || Map.get(map, to_string(key))

  defp get_meta(_, _), do: nil

  defp string_lookup(kw, key) when is_atom(key) do
    Enum.find_value(kw, fn
      {k, v} when is_atom(k) -> if to_string(k) == Atom.to_string(key), do: v
      {k, v} when is_binary(k) -> if k == Atom.to_string(key), do: v
      _ -> nil
    end)
  end

  # ── internals ─────────────────────────────────────────────────────────────

  defp principal_attrs(%Noizu.MCP.Auth.Principal{} = principal) do
    %{
      authenticator: principal.authenticator,
      subject: principal.subject,
      user_id:
        get_in(principal.metadata, ["user_id"]) || Map.get(principal.metadata || %{}, :user_id)
    }
  end

  defp principal_attrs(_), do: %{authenticator: nil, subject: nil, user_id: nil}

  # Mint the step-up URI through the existing Elevation flow (Phase 4);
  # without a user identity there is nothing to mint — the record lands
  # pending instead. Any failure degrades to a pending record.
  defp mint_elevation_uri(tool, opts) do
    case Keyword.get(opts, :user_id) do
      user_id when is_binary(user_id) and user_id != "" ->
        hash = NoizuPromptLingua.OAuth.Elevation.args_hash(%{})

        txn =
          NoizuPromptLingua.OAuth.Elevation.create_txn!(%{
            user_id: user_id,
            tool: ToolNames.canonical(tool),
            args_hash: hash
          })

        NoizuPromptLingua.OAuth.Elevation.elevation_uri(txn)

      _ ->
        nil
    end
  rescue
    _ -> nil
  end
end
