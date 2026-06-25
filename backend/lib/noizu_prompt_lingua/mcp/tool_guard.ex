defmodule NoizuPromptLingua.MCP.ToolGuard do
  @moduledoc """
  RBAC enforcement seam for MCP tools (ADR-015, ticket f015c5bb).

  `noizu_mcp` stays role-model-agnostic: it carries an OPAQUE `authz` blob on each
  tool spec and invokes `before_call/3` before dispatching the tool. THIS module is
  the NPL policy — it interprets the blob and decides. The split (lib = seam, consumer
  = policy) is what lets another consumer plug a different model into the same hook.

  Policy:
    * identity is resolved SERVER-SIDE from `ctx.assigns.auth_claims["sub"]`
      (`MCP.Resolve.current_user_id/1`) — NEVER from a caller-supplied arg. This is
      the fix for the f015c5bb bug (tools resolving the actor from args = spoofable).
    * effective role is resolved against the resource the tool acts on (org, or
      org+project) and compared on the ordinal ladder owner>admin>lead>member>viewer.
      The ladder itself lives in `Authz` (`@role_ranks`); we DELEGATE to
      `Authz.authorize/4` so the `lead` rank (lucia's migration) is picked up for free.
    * DENY-CLOSED: no identity, unresolved resource, unknown/garbage required_role
      (defaults to the most-restrictive `owner`), or no membership => deny.
    * SYSTEM PRINCIPAL exemption for internal actors (pipe bridge / coordinator):
      an explicit `ctx.assigns[:system_principal] == true` or a configured system
      `sub` — never "no claims = allow" (that would re-open the hole).

  Rollout is SHADOW-FIRST (`:mcp_authz_mode`, default `:shadow`): every decision is
  logged but `:shadow` never blocks; flip to `:enforce` to actually deny once the
  log stream is validated against live traffic. Tools with NO `authz` metadata are
  unguarded passthrough, so enforcement rolls out opt-in per tool.

  ## Tool authz metadata (the opaque blob, map or keyword)

      authz: [action: "tickets:create", required_role: :member, resource: :organization]

    * `:required_role` — ordinal bar (`:viewer|:member|:lead|:admin|:owner`).
    * `:resource`      — scope to resolve the caller's role against:
                         `:organization` (default), `:project`, or `:global`
                         (authenticated-only, no role check).
    * `:action`        — string, for the shadow log / audit trail (not enforced).
  """
  require Logger

  alias NoizuPromptLingua.Authz
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @org_arg_keys [:organization, :org, :organization_id, :org_id]
  @project_arg_keys [:project, :project_id]

  @doc """
  Hook invoked by the `noizu_mcp` server before dispatching a tool.

  Returns `:ok` to allow dispatch or `{:error, map}` to deny. In `:shadow` mode it
  always returns `:ok` (the would-be denial is logged), so it is safe to wire ahead
  of validating the policy against real traffic.
  """
  @spec before_call(map(), map() | nil, map() | nil) :: :ok | {:error, map()}
  def before_call(spec, args, ctx) do
    case authz_meta(spec) do
      nil -> :ok
      authz -> authz |> decide(args, ctx) |> finalize(spec, authz)
    end
  end

  # ── decision (pure policy; deny-closed) ──────────────────────────────────────

  defp decide(authz, args, ctx) do
    cond do
      system_principal?(ctx) -> {:allow, :system_principal}
      true -> authenticated_decision(authz, args, ctx)
    end
  end

  defp authenticated_decision(authz, args, ctx) do
    case Resolve.current_user_id(ctx) do
      nil -> {:deny, :no_identity}
      user_id -> authorize_caller(user_id, authz, args)
    end
  end

  defp authorize_caller(user_id, authz, args) do
    case resource_scope(authz) do
      :global ->
        {:allow, :authenticated}

      _scoped ->
        case resolve_resource(authz, args) do
          {:error, reason} ->
            {:deny, reason}

          {:ok, rtype, rid} ->
            case Authz.authorize(user_id, rtype, rid, required_role(authz)) do
              {:ok, %{role: role}} -> {:allow, {role, rtype}}
              {:error, reason} -> {:deny, reason}
            end
        end
    end
  end

  # Resolve the resource the caller's role is evaluated against, from the tool args.
  # The org/project come from args (what the tool operates on); the caller must hold
  # the required role IN that resource — closing the "any token writes any org" hole.
  defp resolve_resource(authz, args) do
    org_ref = first_arg(args, @org_arg_keys)

    case resource_scope(authz) do
      :project ->
        proj_ref = first_arg(args, @project_arg_keys)

        case Resolve.organization_id(org_ref) do
          nil ->
            {:error, :resource_unresolved}

          org_id ->
            case Resolve.project_in_org(proj_ref, org_id) do
              # No project supplied -> authorize at ORG scope (ADR-013 / R-a (b)): a
              # :project tool that omits the project acts org-level, so the caller's
              # org membership governs. Still deny-closed (a real resource, never allow);
              # a tool that truly requires a project rejects the missing arg in-tool.
              {:ok, nil} -> {:ok, "organization", org_id}
              {:ok, project_id} -> {:ok, "project", project_id}
              # project supplied but not in this org -> deny.
              _ -> {:error, :resource_unresolved}
            end
        end

      _organization ->
        case Resolve.organization_id(org_ref) do
          nil -> {:error, :resource_unresolved}
          org_id -> {:ok, "organization", org_id}
        end
    end
  end

  # ── mode application (shadow vs enforce) ─────────────────────────────────────

  defp finalize({:allow, detail}, spec, authz) do
    log(:allow, detail, spec, authz)
    :ok
  end

  defp finalize({:deny, reason}, spec, authz) do
    log(:deny, reason, spec, authz)

    case mode() do
      :enforce -> {:error, %{code: :forbidden, reason: reason, action: action(authz)}}
      _shadow -> :ok
    end
  end

  # ── metadata + config readers ────────────────────────────────────────────────

  # Read the opaque authz blob wherever the Tool macro stows it: a top-level :authz,
  # or under the Tool struct's :meta. Tolerant of map/keyword + string keys.
  defp authz_meta(spec) do
    field(spec, :authz) ||
      case field(spec, :meta) do
        meta when is_map(meta) or is_list(meta) -> meta_get(meta, :authz)
        _ -> nil
      end
  end

  defp required_role(authz), do: authz |> meta_get(:required_role) |> to_role_string()

  # Deny-closed: a missing/garbage required_role defaults to the HIGHEST bar (owner).
  defp to_role_string(role) when is_atom(role) and not is_nil(role), do: Atom.to_string(role)
  defp to_role_string(role) when is_binary(role) and role != "", do: role
  defp to_role_string(_), do: "owner"

  defp resource_scope(authz) do
    case meta_get(authz, :resource) do
      r when is_atom(r) and not is_nil(r) -> r
      r when is_binary(r) and r != "" -> String.to_existing_atom(r)
      _ -> :organization
    end
  rescue
    ArgumentError -> :organization
  end

  defp action(authz), do: meta_get(authz, :action) || "?"

  defp system_principal?(ctx) do
    assigns = (is_map(ctx) && Map.get(ctx, :assigns)) || %{}
    Map.get(assigns, :system_principal) == true or Resolve.current_user_id(ctx) in system_subs()
  end

  defp system_subs, do: Application.get_env(:noizu_prompt_lingua, :mcp_system_principals, [])

  defp mode, do: Application.get_env(:noizu_prompt_lingua, :mcp_authz_mode, :shadow)

  defp log(decision, detail, spec, authz) do
    Logger.info(
      "[mcp-authz] mode=#{mode()} decision=#{decision} tool=#{field(spec, :name) || "?"} " <>
        "action=#{action(authz)} detail=#{inspect(detail)}"
    )
  end

  # ── small helpers ────────────────────────────────────────────────────────────

  defp first_arg(args, _keys) when not is_map(args), do: nil
  defp first_arg(args, keys), do: Enum.find_value(keys, fn k -> Args.get(args, k) end)

  defp field(m, key) when is_map(m), do: Map.get(m, key) || Map.get(m, to_string(key))
  defp field(_, _), do: nil

  defp meta_get(kw, key) when is_list(kw), do: Keyword.get(kw, key)
  defp meta_get(m, key) when is_map(m), do: Map.get(m, key) || Map.get(m, to_string(key))
  defp meta_get(_, _), do: nil
end
