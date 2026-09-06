defmodule NoizuPromptLingua.MCP.AclProvider do
  @moduledoc """
  `Noizu.MCP.ACL.Provider` over `NoizuPromptLingua.Acl.resolve/4` (PRD-N2
  §4.2 / lib PRD-5 §4.2), preserving the legacy engine's documented
  semantics (`EffectiveToolset` moduledoc, "ACL layer"):

    * `check_all/5` OVERRIDES the default fan-out and **always answers for
      every offered tool** — each tool resolves through
      `Acl.resolve(subject, "mcp.tool", {:ref, Schema.McpTool, canonical},
      default: :allow)`, so the lib's fail-closed default-deny (PRD-2
      FR-2.10) never fires spuriously and NPL's default-allow posture is
      preserved exactly. A missing verdict would deny downstream, so the
      map is total by construction.
    * `:deny` ⇒ visible+callable false at weight 300 — the deny vocabulary
      itself (set_visible/set_callable false ops under `{:acl, provider}`)
      lives on `Noizu.MCP.Toolset.Context`; this provider only supplies
      verdicts. Wildcard (kind `:any`), global (`{:ref, :any, :any}`) and
      scope-wide (`{:ref, Schema.MCPCustomScope, scope_id}`) RULE shapes
      apply inside `Acl.resolve`'s rule matching; the scope verdict is
      resolved ONCE per batch (the legacy invariant) and denies every tool
      when present.
    * `allow` / no-match ⇒ `:allow` no-op (config-cascade state survives).
    * A subject with no resolvable user (anonymous, api-key principals
      without a membership identity) gets NO ACL pass — all `:allow`
      (legacy: `user_ref` absent ⇒ no pass).
    * `supported_kinds/0` = `[:tool, :toolset]` (PRD-2 §4.7).

  ToolGuard re-homing prep (PRD-N2 §N2b): deny verdicts invoke the
  negotiation/elevation prep (`ToolsetNegotiations.on_acl_denied/4`) — the
  RBAC/PDP step-up conversation moves here as the dispatch call site
  retires at N5. Best-effort and env-gated; verdicts are never affected.
  """

  @behaviour Noizu.MCP.ACL.Provider

  alias Noizu.MCP.ACL.Resource
  alias Noizu.MCP.Auth.Principal
  alias NoizuPromptLingua.Acl
  alias NoizuPromptLingua.MCP.EffectiveToolset
  alias NoizuPromptLingua.MCP.ToolNames
  alias NoizuPromptLingua.MCP.ToolsetNegotiations
  alias NoizuPromptLingua.Schema.McpTool

  require Noizu.EntityReference.Records
  alias Noizu.EntityReference.Records, as: R

  @impl true
  def supported_kinds, do: [:tool, :toolset]

  @impl true
  def check(subject, %Resource{kind: kind, id: id}, action, ctx, opts) do
    # The map is total for the shapes check_all governs; a Map.get miss on
    # an ungoverned id denies (normalized fail-closed downstream anyway).
    check_all(subject, [%Resource{kind: kind, id: id}], action, ctx, opts)
    |> Map.get(id, :deny)
  end

  @impl true
  def check_all(subject, resources, _action, _ctx, opts) when is_list(resources) do
    at = Keyword.get(opts, :at) || DateTime.utc_now()

    case acl_subject(subject) do
      nil ->
        # No ACL pass (legacy byte-parity) — but still ALWAYS answers, so
        # the lib's fail-closed default-deny never fires spuriously.
        Map.new(resources, &{&1.id, :allow})

      user ->
        scope = scope_verdict(user, subject, opts, at)

        Map.new(resources, fn
          %Resource{kind: :tool, id: name} ->
            {name, tool_verdict(user, name, scope, at, subject, opts)}

          %Resource{kind: :toolset, id: id} ->
            {id, kind_verdict(user, at)}
        end)
    end
  end

  def check_all(_subject, _resources, _action, _ctx, _opts), do: %{}

  # Per tool: the scope verdict (resolved once per batch) denies everything
  # it governs; otherwise the tool resource itself resolves. Deny verdicts
  # trigger the elevation/negotiation prep (best-effort, env-gated).
  defp tool_verdict(user, name, scope, at, subject, opts) do
    denied? =
      scope_denied?(scope) or
        match?(
          {:deny, _},
          Acl.resolve(
            user,
            EffectiveToolset.acl_action(),
            McpTool.ref(ToolNames.canonical(name)),
            default: :allow,
            at: at
          )
        )

    if denied? do
      ToolsetNegotiations.on_acl_denied(name, subject, opts)
      :deny
    else
      :allow
    end
  end

  # Kind-level (toolset) check: resolve against the wildcard tool resource
  # — a kind-wide deny rule hides the whole set surface.
  defp kind_verdict(user, at) do
    case Acl.resolve(user, EffectiveToolset.acl_action(), McpTool.ref(:any),
           default: :allow,
           at: at
         ) do
      {:deny, _} -> :deny
      _ -> :allow
    end
  end

  defp scope_denied?({:deny, _}), do: true
  defp scope_denied?(_), do: false

  # The scope-wide knob: `mcp.tool` on the scope's own ref denies every
  # tool the scope serves. Coordinates arrive per call (`opts[:scope_id]`
  # / `opts[:scope_ref]`) or as the legacy route claim
  # (`custom_scope_slug` on the principal metadata, resolved by slug).
  defp scope_verdict(user, subject, opts, at) do
    case scope_ref(subject, opts) do
      nil ->
        {:allow, :default}

      ref ->
        Acl.resolve(user, EffectiveToolset.acl_action(), ref, default: :allow, at: at)
    end
  end

  defp scope_ref(subject, opts) do
    cond do
      id = Keyword.get(opts, :scope_id) ->
        R.ref(module: NoizuPromptLingua.Schema.MCPCustomScope, id: id)

      ref = Keyword.get(opts, :scope_ref) ->
        ref

      slug = metadata_get(metadata(subject), :custom_scope_slug) ->
        case NoizuPromptLingua.MCPCustomScopes.get_by_slug(slug) do
          %{id: id} -> R.ref(module: NoizuPromptLingua.Schema.MCPCustomScope, id: id)
          _ -> nil
        end

      true ->
        nil
    end
  end

  # Subject normalization (EffectiveToolset `acl_subject` semantics): a
  # principal maps through its membership identity (`metadata["user_id"]`,
  # stashed by PrincipalMapper from the claims' `sub`); an ERP ref passes
  # through; an entity struct via the protocol; a bare binary is a
  # `Users.User` id; anything else (api-key-only/service principals,
  # anonymous) ⇒ nil — no ACL pass rather than a bogus subject.
  defp acl_subject(%Principal{} = principal),
    do: acl_subject(metadata_get(metadata(principal), "user_id"))

  defp acl_subject(R.ref() = ref), do: ref
  defp acl_subject(subject) when is_struct(subject), do: subject

  defp acl_subject(id) when is_binary(id) and id != "",
    do: R.ref(module: NoizuPromptLingua.Users.User, id: id)

  defp acl_subject(_), do: nil

  defp metadata(%Principal{metadata: metadata}) when is_map(metadata), do: metadata
  defp metadata(_), do: %{}

  # PrincipalMapper metadata mixes string keys (identity) and atom keys
  # (route claims) — probe both.
  defp metadata_get(metadata, key) when is_atom(key) do
    Map.get(metadata, key) || Map.get(metadata, Atom.to_string(key))
  end

  defp metadata_get(metadata, key) when is_binary(key) do
    Map.get(metadata, key) || metadata_get(metadata, String.to_existing_atom(key))
  rescue
    ArgumentError -> nil
  end
end
