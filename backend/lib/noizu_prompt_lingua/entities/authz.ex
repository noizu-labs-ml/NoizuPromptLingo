defmodule NoizuPromptLingua.Authz do
  @moduledoc """
  Authz facade — LOCAL app-DB implementation (spec gap).

  TRP v1 exposes no authz/membership endpoints (W0 spec covers orgs/projects/
  items/definitions only), so the former pm_core stored-proc calls are re-homed
  on NPL's own `scoped_memberships` / `groups` / `policies` tables, which mirror
  the pm_core schema and are DB-independent. This is a deliberate local shim
  reported to Loom: when TRP grows an authz surface, this facade is the single
  switch point.

  Ordinal role ladder (lower = higher privilege). 'lead' sits between admin and
  member (ADR-015). MUST stay in sync with the role_name_enum DB values — see
  role_ranks/0 + the authz_role_ranks_test sync guard.
  """

  import Ecto.Query
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Authz.{Group, GroupPolicy, Policy, ScopedMembership}

  @role_ranks %{"owner" => 0, "admin" => 1, "lead" => 2, "member" => 3, "viewer" => 4}

  @doc "The ordinal role ladder map (role name => rank; lower = higher privilege)."
  def role_ranks, do: @role_ranks

  # permission-suffix → role floor for check_permission/4 (approximates the old
  # pm_core `check_user_permission` proc; documented in the W4 cutover report).
  @permission_floors [
    {{:ends_with, "view"}, "viewer"},
    {{:ends_with, "read"}, "viewer"},
    {{:ends_with, "list"}, "viewer"},
    {{:ends_with, "create"}, "member"},
    {{:ends_with, "update"}, "member"},
    {{:ends_with, "edit"}, "member"},
    {{:ends_with, "assign"}, "lead"},
    {{:ends_with, "delete"}, "admin"},
    {{:ends_with, "archive"}, "admin"},
    {{:ends_with, "manage"}, "admin"},
    {{:contains, "manage_members"}, "admin"}
  ]

  @doc """
  Rank-gated permission check with a narrow policy overlay (ticket 72048c5d):
  an EXPLICIT DENY in an effective policy document blocks regardless of the
  role ladder (deny wins); an IMPLICIT policy deny (no statement matched)
  defers to the ladder, and explicit allow remains ladder-governed (a separate
  reviewed change) — so this stays consistent with `explain_permission/4`.
  The policy documents are consulted only when the ladder already allows, so
  the deny path adds a query only where it can change the verdict.
  """
  def check_permission(user_id, resource_type, resource_id, action) do
    case get_user_role(user_id, resource_type, resource_id) do
      nil ->
        false

      role ->
        ladder_allowed? = rank(role) <= rank(required_role_for(action))

        if ladder_allowed? and
             explicit_policy_deny?(
               user_id,
               resource_type,
               resource_id,
               action,
               role
             ) do
          false
        else
          ladder_allowed?
        end
    end
  end

  # Deny-wins consult (ticket 72048c5d): evaluate the caller's effective policy
  # documents and report whether an explicit DENY statement matched. Only the
  # matched-deny verdict counts — implicit denies defer to the ladder. Same
  # string-key envelope re-keying as explain_permission/4 (PolicyEvaluator
  # reads "policy_document" => %{"statements" => ...}).
  defp explicit_policy_deny?(user_id, resource_type, resource_id, action, role) do
    documents =
      get_effective_policies(user_id, resource_type, resource_id)
      |> Enum.map(fn p -> %{"policy_document" => p.policy_document} end)

    # the evaluator's action matching is string-shaped; check_permission/4
    # accepts atom actions (e.g. :org_view)
    action = to_string(action)

    case NoizuPromptLingua.Authz.PolicyEvaluator.evaluate(
           documents,
           action,
           resource_type,
           resource_id,
           role,
           %{user_id: user_id}
         ) do
      %{reason: :explicit_deny} -> true
      _ -> false
    end
  end

  @doc "Caller's canonical role in a resource, or nil. App-DB only."
  def get_user_role(user_id, resource_type, resource_id) do
    from(sm in ScopedMembership,
      join: g in Group,
      on: g.id == sm.group_id,
      where:
        sm.member_type == "user" and sm.member_id == ^user_id and
          sm.resource_type == ^to_string(resource_type) and sm.resource_id == ^resource_id,
      where: is_nil(sm.expires_at) or sm.expires_at > ^DateTime.utc_now(),
      select: g.name
    )
    |> Repo.one()
  end

  @doc "Rank-gated authorize: `{:ok, map}` | `{:error, :not_a_member | :insufficient_role}`."
  def authorize(user_id, resource_type, resource_id, required_role) do
    case get_user_role(user_id, resource_type, resource_id) do
      nil ->
        {:error, :not_a_member}

      role ->
        if rank(role) <= rank(normalize_role(required_role)) do
          {:ok,
           %{
             role: role,
             resource_type: resource_type,
             resource_id: resource_id
           }}
        else
          {:error, :insufficient_role}
        end
    end
  end

  @doc """
  Explain a permission decision. Policy documents OVERLAY the role ladder:
  an explicit policy allow/deny wins, but an IMPLICIT policy deny (no statement
  matched) defers to the role ladder — the same engine `check_permission/4`
  uses — so the two endpoints can never diverge (fix/error-family ruling for
  the check:true / explain:implicit_deny probe split). When the ladder allows,
  the reason is `:role_allow`.
  """
  def explain_permission(user_id, resource_type, resource_id, action) do
    role = get_user_role(user_id, resource_type, resource_id)

    if is_nil(role) do
      %{allowed: false, reason: :not_a_member, matching_statements: []}
    else
      policies = get_effective_policies(user_id, resource_type, resource_id)

      # PolicyEvaluator reads `get_in(policy, ["policy_document", "statements"])`
      # — string keys — while the select above yields atom-keyed rows, so every
      # statement used to be invisible (permanent implicit_deny; probe row 344).
      # Re-key the envelope before evaluating.
      documents = Enum.map(policies, fn p -> %{"policy_document" => p.policy_document} end)

      result =
        NoizuPromptLingua.Authz.PolicyEvaluator.evaluate(
          documents,
          action,
          resource_type,
          resource_id,
          role,
          %{user_id: user_id}
        )

      case result do
        %{reason: :implicit_deny} ->
          allowed = check_permission(user_id, resource_type, resource_id, action)
          reason = if allowed, do: :role_allow, else: :implicit_deny
          %{result | allowed: allowed, reason: reason}

        other ->
          other
      end
    end
  end

  # Policy join for explain — app-DB mirrors of pm_core's group_policies/policies.
  defp get_effective_policies(user_id, resource_type, resource_id) do
    from(sm in ScopedMembership,
      join: gp in GroupPolicy,
      on: gp.group_id == sm.group_id,
      join: p in Policy,
      on: p.id == gp.policy_id and p.is_active == true,
      where:
        sm.member_type == "user" and sm.member_id == ^user_id and
          sm.resource_type == ^to_string(resource_type) and sm.resource_id == ^resource_id,
      where: is_nil(sm.expires_at) or sm.expires_at > ^DateTime.utc_now(),
      order_by: [asc: gp.priority],
      select: %{
        id: p.id,
        name: p.name,
        description: p.description,
        policy_document: p.policy_document,
        is_system: p.is_system,
        priority: gp.priority
      }
    )
    |> Repo.all()
  end

  defp required_role_for(action) when is_binary(action) do
    Enum.find_value(@permission_floors, "member", fn
      {{:ends_with, suffix}, role} ->
        if String.ends_with?(action, suffix), do: role

      {{:contains, part}, role} ->
        if String.contains?(action, part), do: role

      _ ->
        nil
    end)
  end

  defp required_role_for(action), do: required_role_for(to_string(action))

  defp normalize_role(role) when is_atom(role), do: Atom.to_string(role)
  defp normalize_role(role), do: role

  defp rank(role), do: Map.get(@role_ranks, to_string(role), 99)
end
