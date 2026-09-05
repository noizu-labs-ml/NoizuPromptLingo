defmodule NoizuPromptLingua.MCP.VFS.Principal do
  @moduledoc """
  Per-connection principal resolution for the VFS plane (Wave 0 substrate).

  Binds the connection's `auth_claims` (same `DualTokenVerifier` pipeline the
  MCP surface uses) to the **effective group set** via the existing
  `EffectiveToolset` cascade (scope config → client `toolset_config` → per-user
  ACL), and gates VFS visibility on it per MCP-VFS-GROUP-MOUNTS.md §1.3:

  | Principal state | VFS behavior |
  |---|---|
  | group in effective set, tools visible | subtree served |
  | group included but tools disabled | node listed, `writable: false`; mutating ops `:eacces` |
  | group excluded / hidden | `:enoent` for the entire subtree (no existence leak) |
  | user-level ACL deny | tool gated (`:eacces` on `/etc/dev` invocation) |
  | `vfs_readonly: true` server kill-switch | every write `:erofs` (lib `Control` behavior) |

  ## Memoization

  The resolved gate map is memoized **per connection** through the shared
  `ToolsetCache` (key `{:vfs_principal, session_key}`), so it inherits both of
  its lifecycle properties: a 45s TTL backstop and generation invalidation by
  `NoizuPromptLingua.MCP.Server.notify_toolset_changed/0` (which bumps the
  cache after every toolset-affecting write). Test envs disable the cache, so
  suites stay hermetic.

  ## Identity-blind cache note (P1)

  The lib's `Noizu.MCP.VFS.Cache` keys entries `{backend, kind, path}` with no
  identity component, so per-principal read results could cross-contaminate
  within its TTL. NPL disables the VFS read cache outright for now
  (`config :noizu_mcp, vfs_cache_enabled: false`) — the meta plane is tiny and
  the clean fix (`__mcp_vfs__(:cacheable)` opt-out / per-identity keys) is a
  lib ask (design §6 P1), not Wave 0 app work.
  """

  alias Noizu.MCP.Server.Features.Tools
  alias NoizuPromptLingua.MCP.{EffectiveToolset, ToolNames, ToolsetCache}
  alias NoizuPromptLingua.{MCPServers, TRP}

  @typedoc "Per-group gate state derived from the cascade."
  @type group_gate :: %{included: boolean(), visible: boolean(), writable: boolean()}

  @typedoc "Per-connection principal view."
  @type view :: %{
          groups: %{String.t() => group_gate()},
          tools: %{String.t() => :ok | :denied},
          orgs: [String.t()],
          claims: map()
        }

  @doc """
  The per-connection view (memoized): group gates, per-tool invocation gates,
  the org slugs visible to this principal, and the resolved claims.

  Fails closed: a principal with no resolvable client/scope sees NO group
  subtrees (only the `_meta` plane of visible orgs, and org visibility still
  applies).
  """
  @spec view(Noizu.MCP.Ctx.t()) :: view()
  def view(ctx) do
    claims = ctx_assigns(ctx, :auth_claims) || %{}

    ToolsetCache.fetch(:vfs_principal, session_key(ctx), fn ->
      resolve_view(ctx, claims)
    end)
  end

  @doc "Convenience: the per-group gate map for a connection."
  @spec groups(Noizu.MCP.Ctx.t()) :: %{String.t() => group_gate()}
  def groups(ctx), do: view(ctx).groups

  @doc """
  True when `slug` names an organization this principal can see (the TRP key
  scope is the org inventory for the key — the same source the
  `Organization.List` MCP tool mirrors; TRP unavailable ⇒ empty).

  `/tobor` readdir = this list, so a mount only ever sees gated orgs.
  """
  @spec org_visible?(Noizu.MCP.Ctx.t(), String.t()) :: boolean()
  def org_visible?(ctx, slug) when is_binary(slug), do: slug in view(ctx).orgs

  @doc """
  Group subtree gate. Returns `:ok` when the group is included AND visible;
  `:enoent` otherwise (excluded and hidden are indistinguishable from absent —
  mirroring `visible: false` on the MCP surface).

  Disabled-but-included groups pass this gate (the subtree lists; content
  nodes render `writable: false` and mutations are refused at the backend
  layer, which for Wave 0 is ":enosys everywhere").
  """
  @spec group_gate(Noizu.MCP.Ctx.t(), String.t()) :: :ok | {:error, :enoent}
  def group_gate(ctx, group_id) do
    case groups(ctx)[group_id] do
      %{visible: true} -> :ok
      _ -> {:error, :enoent}
    end
  end

  @doc """
  `/etc/dev` tool-invocation gate (the `tool_gate:` hook on
  `Noizu.MCP.VFS.Control`). Verdict is final: `:ok` only when the tool is in
  the principal's effective set, visible, and enabled (Discovery/NPL tools are
  the ungated browsing plane, mirroring `EffectiveToolset.apply_to_specs/3`).
  Unknown tools fail closed.
  """
  @spec tool_gate(String.t(), map(), Noizu.MCP.Ctx.t()) :: :ok | {:error, :eacces}
  def tool_gate(tool_name, _args, ctx) do
    case view(ctx).tools[ToolNames.canonical(tool_name)] do
      :ok -> :ok
      _ -> {:error, :eacces}
    end
  end

  @doc """
  `context:` assign hook for the `VFSWS` transport — currently a no-op (the
  claims ride the connection as `auth_claims` already); kept as the documented
  insertion point for per-connection eager resolution if Wave 1 needs it.
  """
  def context_assigns(_claims), do: %{}

  # ── resolution ────────────────────────────────────────────────────────────

  defp resolve_view(ctx, claims) do
    client = EffectiveToolset.client_for_ctx(ctx)
    scope = EffectiveToolset.scope_from_ctx(ctx)
    user = EffectiveToolset.user_for_ctx(ctx)

    states = EffectiveToolset.resolve(scope, client, user)

    tools =
      Map.new(states, fn {name, st} ->
        {name, if(st.visible and st.enabled, do: :ok, else: :denied)}
      end)

    groups =
      Map.new(catalog_groups(), fn {gid, _desc} ->
        {gid, group_gate_state(gid, states)}
      end)

    %{groups: groups, tools: tools, orgs: org_slugs(), claims: sanitize_claims(ctx, claims)}
  end

  # Catalog groups are included iff the cascade emitted ANY of their registered
  # tools (`EffectiveToolset.resolve/4` only emits tools of include-set groups;
  # root is the aggregator plane, not a `/tobor` subtree, and is skipped).
  defp group_gate_state(group_id, states) do
    tool_states = group_tool_states(group_id, states)

    %{
      included: tool_states != [],
      visible: tool_states != [] and Enum.any?(tool_states, & &1.visible),
      writable: tool_states != [] and Enum.any?(tool_states, & &1.enabled)
    }
  end

  defp group_tool_states(group_id, states) do
    case MCPServers.server_module(group_id) do
      nil ->
        []

      module ->
        module.__mcp__(:tools)
        |> Tools.expand()
        |> Enum.flat_map(fn spec ->
          name =
            spec.definition && spec.definition.name && ToolNames.canonical(spec.definition.name)

          case name && Map.get(states, name) do
            nil -> []
            st -> [st]
          end
        end)
    end
  end

  # The mount namespace covers the customizable group catalog under each org.
  defp catalog_groups do
    MCPServers.all()
    |> Enum.reject(&(&1.id == "root"))
    |> Map.new(&{&1.id, &1})
  end

  # TRP key scope IS the org inventory (spec 4.1, mirrored by Organization.List);
  # a failed read counts as empty rather than failing the listing.
  defp org_slugs do
    case TRP.list_organizations() do
      orgs when is_list(orgs) -> orgs |> Enum.map(& &1.slug) |> Enum.uniq() |> Enum.sort()
      _ -> []
    end
  end

  # `whoami` material only — stable identity fields, never the full claim set.
  defp sanitize_claims(_ctx, claims) when is_map(claims) do
    claims
    |> Map.take(["api_key_id", "client_id", "user_id", "sub", "iss", "scope"])
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end

  defp sanitize_claims(_ctx, _), do: %{}

  # Mirrors Noizu.MCP.VFS.Control's per-connection keying: stable session id
  # first, connection pid as fallback, :default last.
  defp session_key(%Noizu.MCP.Ctx{session_id: id}) when is_binary(id), do: {:sid, id}
  defp session_key(%Noizu.MCP.Ctx{session: pid}) when is_pid(pid), do: {:pid, pid}
  defp session_key(_), do: :default

  defp ctx_assigns(ctx, key) do
    case ctx do
      %{assigns: assigns} when is_map(assigns) -> Map.get(assigns, key)
      _ -> nil
    end
  end
end
