defmodule NoizuPromptLingua.Authz.ScopedMemberships do
  @moduledoc """
  Scoped memberships — LOCAL app-DB implementation (spec gap).

  TRP v1 exposes no membership endpoints, so the former pm_core stored-proc
  writes (add/update/remove) are re-homed as direct app-DB changesets over the
  `scoped_memberships` mirror table (same shape the persona path already used).
  Sole-owner protection is enforced in-code (last owner cannot be demoted or
  removed) to approximate the `remove_scoped_member_safe` proc.

  Single switch point: when TRP grows an authz surface, this facade re-homes.
  """

  alias NoizuPromptLingua.Authz.ScopedMemberships.ScopedMembership, as: Entity
  alias NoizuPromptLingua.Schema.Authz.ScopedMembership, as: Schema

  use Noizu.Repo
  def_repo(entity: Entity)

  import Ecto.Query

  # role_name_enum values (013 + 053 'lead'); guards persona role lookups so a non-enum
  # string returns :invalid_role instead of raising on the enum cast.
  @member_roles ~w(owner admin lead member viewer)

  # ── User membership writes (was: pm_core stored procs) ─────────

  def add_member(resource_type, resource_id, user_id, role_name, added_by \\ nil) do
    case role_group(role_name) do
      {:error, :invalid_role} = err ->
        err

      {:ok, group} ->
        if membership_exists?(resource_type, resource_id, "user", user_id) do
          {:error, :already_member}
        else
          %Schema{}
          |> Schema.changeset(%{
            group_id: group.id,
            resource_type: resource_type,
            resource_id: resource_id,
            member_type: "user",
            member_id: user_id,
            added_by: added_by
          })
          |> NoizuPromptLingua.Repo.insert()
          |> case do
            {:ok, row} -> {:ok, row}
            error -> error
          end
        end
    end
  end

  def update_role(resource_type, resource_id, user_id, new_role_name) do
    with {:ok, group} <- role_group(new_role_name),
         {:ok, membership} <- fetch_membership(resource_type, resource_id, "user", user_id),
         :ok <- sole_owner_guard(membership, new_role_name) do
      membership
      |> Ecto.Changeset.change(%{group_id: group.id})
      |> NoizuPromptLingua.Repo.update()
    end
  end

  def remove_member(resource_type, resource_id, user_id) do
    with {:ok, membership} <- fetch_membership(resource_type, resource_id, "user", user_id),
         :ok <- sole_owner_guard(membership, nil) do
      NoizuPromptLingua.Repo.delete(membership)
    end
  end

  # ── Reads (was: pm ∪ app UNION) ─────────────────────────────────

  # PBAC members over scoped_memberships: USER and PERSONA members, with
  # org/project SCOPE (resource_type/id), member_type, canonical role_name_enum
  # role, and an optional role facet (scalar or list). All rows are app-DB now;
  # select shape unchanged so the FE stays member_type-agnostic.
  def list_for_resource(resource_type, resource_id, opts \\ []) do
    user_rows =
      app_rows_query(resource_type, resource_id, "user")
      |> maybe_role_filter(opts[:role])
      |> NoizuPromptLingua.Repo.all()

    persona_rows =
      app_rows_query(resource_type, resource_id, "persona")
      |> maybe_role_filter(opts[:role])
      |> NoizuPromptLingua.Repo.all()

    user_rows ++ persona_rows
  end

  # Single membership by id (getMember), same shape as a list row. nil if absent.
  def get_membership(id) do
    from(sm in Schema,
      join: g in NoizuPromptLingua.Schema.Authz.Group,
      on: g.id == sm.group_id,
      left_join: u in NoizuPromptLingua.Schema.Users.User,
      on: sm.member_type == "user" and u.id == sm.member_id,
      left_join: p in NoizuPromptLingua.Schema.Persona,
      on: sm.member_type == "persona" and p.id == sm.member_id,
      where: sm.id == ^id and sm.member_type in ["user", "persona"],
      select: %{
        id: sm.id,
        member_type: sm.member_type,
        member_id: sm.member_id,
        user_id: u.id,
        email: u.email,
        user_name: u.user_name,
        persona_id: p.id,
        persona_slug: p.slug,
        avatar: p.avatar,
        display_name: fragment("coalesce(?, ?, ?)", u.user_name, p.name, u.email),
        role: g.name,
        resource_type: sm.resource_type,
        resource_id: sm.resource_id,
        joined_at: sm.created_at,
        expires_at: sm.expires_at
      }
    )
    |> NoizuPromptLingua.Repo.one()
  end

  # ── Persona members (unchanged — already app-DB) ────────────────

  # Add a PERSONA as a resource member (ccaf5684 / ADR-017). Personas use a direct
  # changeset insert (sole-owner stored procs stay user-only by design, ADR-017 D3).
  # Idempotent via on_conflict on the (resource,member) unique key. v1 = data+display;
  # persona-as-authz-actor is deferred (ADR-015 system-principal).
  def add_persona_member(resource_type, resource_id, persona_id, role_name, added_by \\ nil) do
    # Guard the role against the enum BEFORE the group lookup: a non-enum value can't be
    # cast to role_name_enum and would raise on the WHERE rather than return nil.
    case role_name in @member_roles &&
           NoizuPromptLingua.Repo.get_by(NoizuPromptLingua.Schema.Authz.Group, name: role_name) do
      g when g in [false, nil] ->
        {:error, :invalid_role}

      group ->
        %Schema{}
        |> Schema.changeset(%{
          group_id: group.id,
          resource_type: resource_type,
          resource_id: resource_id,
          member_type: "persona",
          member_id: persona_id,
          added_by: added_by
        })
        |> NoizuPromptLingua.Repo.insert(
          on_conflict: :nothing,
          conflict_target: [:resource_type, :resource_id, :member_type, :member_id]
        )
        |> case do
          {:ok, _} ->
            {:ok,
             NoizuPromptLingua.Repo.get_by(Schema,
               resource_type: resource_type,
               resource_id: resource_id,
               member_type: "persona",
               member_id: persona_id
             )}

          error ->
            error
        end
    end
  end

  # Reassign a persona member's role (ccaf5684).
  def update_persona_role(resource_type, resource_id, persona_id, role_name) do
    case role_name in @member_roles &&
           NoizuPromptLingua.Repo.get_by(NoizuPromptLingua.Schema.Authz.Group, name: role_name) do
      g when g in [false, nil] ->
        {:error, :invalid_role}

      group ->
        case NoizuPromptLingua.Repo.get_by(Schema,
               resource_type: resource_type,
               resource_id: resource_id,
               member_type: "persona",
               member_id: persona_id
             ) do
          nil ->
            {:error, :not_found}

          membership ->
            membership
            |> Ecto.Changeset.change(%{group_id: group.id})
            |> NoizuPromptLingua.Repo.update()
        end
    end
  end

  # ── Per-user membership listing ─────────────────────────────────

  def list_for_user(user_id) do
    from(sm in Schema,
      join: g in NoizuPromptLingua.Schema.Authz.Group,
      on: g.id == sm.group_id,
      where: sm.member_type == "user" and sm.member_id == ^user_id,
      where: is_nil(sm.expires_at) or sm.expires_at > ^DateTime.utc_now(),
      select: %{
        id: sm.id,
        resource_type: sm.resource_type,
        resource_id: sm.resource_id,
        role: g.name,
        joined_at: sm.created_at,
        expires_at: sm.expires_at
      }
    )
    |> NoizuPromptLingua.Repo.all()
  end

  # ── Active-membership probe (PRD-N3 §4.6 / FR-3-8) ──────────────

  @doc """
  True iff the user (or persona) holds an ACTIVE membership — `expires_at` nil
  or in the future — on the resource. `ref` is `%{type: :user | :persona, id:
  uuid}` (or a bare user id). `opts[:group_id]` additionally binds the
  membership's role group (the group-set audience gate: the caller's
  membership must carry the set's group).

  Read-only boolean probe for the tool-set gateway's 404-no-leak audience
  gate; absent rows ⇒ false.
  """
  def active_member?(resource_type, resource_id, ref, opts \\ [])

  def active_member?(resource_type, resource_id, %{type: type, id: member_id}, opts)
      when type in [:user, :persona] and is_binary(member_id) do
    query =
      from(sm in Schema,
        where: sm.resource_type == ^resource_type,
        where: sm.resource_id == ^resource_id,
        where: sm.member_type == ^Atom.to_string(type),
        where: sm.member_id == ^member_id,
        where: is_nil(sm.expires_at) or sm.expires_at > ^DateTime.utc_now()
      )

    query =
      case Keyword.get(opts, :group_id) do
        nil -> query
        group_id -> from(sm in query, where: sm.group_id == ^group_id)
      end

    NoizuPromptLingua.Repo.exists?(query)
  end

  def active_member?(resource_type, resource_id, member_id, opts) when is_binary(member_id) do
    active_member?(resource_type, resource_id, %{type: :user, id: member_id}, opts)
  end

  def active_member?(_, _, _, _), do: false

  # ── Internals ─────────────────────────────────────────────────

  defp role_group(role) when role in @member_roles do
    case NoizuPromptLingua.Repo.get_by(NoizuPromptLingua.Schema.Authz.Group, name: role) do
      nil -> {:error, :invalid_role}
      group -> {:ok, group}
    end
  end

  defp role_group(_), do: {:error, :invalid_role}

  defp membership_exists?(resource_type, resource_id, member_type, member_id) do
    NoizuPromptLingua.Repo.exists?(
      from(sm in Schema,
        where:
          sm.resource_type == ^resource_type and sm.resource_id == ^resource_id and
            sm.member_type == ^member_type and sm.member_id == ^member_id
      )
    )
  end

  defp fetch_membership(resource_type, resource_id, member_type, member_id) do
    case NoizuPromptLingua.Repo.get_by(Schema,
           resource_type: resource_type,
           resource_id: resource_id,
           member_type: member_type,
           member_id: member_id
         ) do
      nil -> {:error, :not_found}
      membership -> {:ok, membership}
    end
  end

  # Approximates remove_scoped_member_safe's sole-owner invariant: the last
  # owner of a resource cannot be demoted to a lower role or removed.
  defp sole_owner_guard(membership, new_role_name) do
    if current_role(membership) == "owner" and new_role_name != "owner" do
      owner_count =
        from(sm in Schema,
          join: g in NoizuPromptLingua.Schema.Authz.Group,
          on: g.id == sm.group_id,
          where:
            sm.resource_type == ^membership.resource_type and
              sm.resource_id == ^membership.resource_id and
              sm.member_type == ^membership.member_type and g.name == "owner",
          select: count(sm.id)
        )
        |> NoizuPromptLingua.Repo.one() || 0

      if owner_count <= 1, do: {:error, :last_owner}, else: :ok
    else
      :ok
    end
  end

  defp current_role(membership) do
    case NoizuPromptLingua.Repo.get(NoizuPromptLingua.Schema.Authz.Group, membership.group_id) do
      nil -> nil
      group -> group.name
    end
  end

  # role facet: scalar -> ==, list -> in (= ANY); nil/[] no-op (3c2d6bbe convention).
  defp maybe_role_filter(query, nil), do: query
  defp maybe_role_filter(query, []), do: query

  defp maybe_role_filter(query, roles) when is_list(roles),
    do: where(query, [sm, g, u], g.name in ^roles)

  defp maybe_role_filter(query, role), do: where(query, [sm, g, u], g.name == ^role)

  # App-DB select shape (USER + PERSONA rows; unified display_name; persona-
  # specific fields nil for users and vice-versa). Same as the former UNION's
  # app side so the FE stays member_type-agnostic.
  defp app_rows_query(resource_type, resource_id, member_type) do
    from(sm in Schema,
      join: g in NoizuPromptLingua.Schema.Authz.Group,
      on: g.id == sm.group_id,
      left_join: u in NoizuPromptLingua.Schema.Users.User,
      on: sm.member_type == "user" and u.id == sm.member_id,
      left_join: p in NoizuPromptLingua.Schema.Persona,
      on: sm.member_type == "persona" and p.id == sm.member_id,
      where: sm.resource_type == ^resource_type and sm.resource_id == ^resource_id,
      where: sm.member_type == ^member_type,
      where: is_nil(sm.expires_at) or sm.expires_at > ^DateTime.utc_now(),
      select: %{
        id: sm.id,
        member_type: sm.member_type,
        member_id: sm.member_id,
        user_id: u.id,
        email: u.email,
        user_name: u.user_name,
        persona_id: p.id,
        persona_slug: p.slug,
        avatar: p.avatar,
        display_name: fragment("coalesce(?, ?, ?)", u.user_name, p.name, u.email),
        role: g.name,
        resource_type: sm.resource_type,
        resource_id: sm.resource_id,
        joined_at: sm.created_at,
        expires_at: sm.expires_at
      }
    )
  end
end
