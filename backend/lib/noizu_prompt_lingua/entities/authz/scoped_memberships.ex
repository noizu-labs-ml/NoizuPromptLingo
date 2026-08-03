defmodule NoizuPromptLingua.Authz.ScopedMemberships do
  alias NoizuPromptLingua.Authz.ScopedMemberships.ScopedMembership, as: Entity
  alias NoizuPromptLingua.Schema.Authz.ScopedMembership, as: Schema

  use Noizu.Repo
  def_repo(entity: Entity)

  import Ecto.Query

  # role_name_enum values (013 + 053 'lead'); guards persona role lookups so a non-enum
  # string returns :invalid_role instead of raising on the enum cast.
  @member_roles ~w(owner admin lead member viewer)

  def add_member(resource_type, resource_id, user_id, role_name, added_by \\ nil) do
    NoizuPromptLingua.PMCore.with_pm(fn ->
      Noizu.PM.Authz.ScopedMemberships.add_member(
        resource_type,
        resource_id,
        user_id,
        role_name,
        added_by
      )
    end)
  end

  def update_role(resource_type, resource_id, user_id, new_role_name) do
    NoizuPromptLingua.PMCore.with_pm(fn ->
      Noizu.PM.Authz.ScopedMemberships.update_role(
        resource_type,
        resource_id,
        user_id,
        new_role_name
      )
    end)
  end

  def remove_member(resource_type, resource_id, user_id) do
    NoizuPromptLingua.PMCore.with_pm(fn ->
      Noizu.PM.Authz.ScopedMemberships.remove_member(resource_type, resource_id, user_id)
    end)
  end

  # PBAC members over scoped_memberships (4a9aa9d9 + ccaf5684): USER and PERSONA members,
  # with org/project SCOPE (resource_type/id), member_type, canonical role_name_enum role,
  # and an optional role facet (scalar or list). LEFT joins both users + personas, keyed by
  # member_type, with a unified display_name; persona-specific fields (persona_slug/avatar)
  # are nil for users and vice-versa. member_type-agnostic for the FE.
  def list_for_resource(resource_type, resource_id, opts \\ []) do
    from(sm in Schema,
      join: g in NoizuPromptLingua.Schema.Authz.Group,
      on: g.id == sm.group_id,
      left_join: u in NoizuPromptLingua.Schema.Users.User,
      on: sm.member_type == "user" and u.id == sm.member_id,
      left_join: p in NoizuPromptLingua.Schema.Persona,
      on: sm.member_type == "persona" and p.id == sm.member_id,
      where: sm.resource_type == ^resource_type and sm.resource_id == ^resource_id,
      where: sm.member_type in ["user", "persona"],
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
    |> maybe_role_filter(opts[:role])
    |> NoizuPromptLingua.Repo.all()
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

  # Add a PERSONA as a resource member (ccaf5684 / ADR-017). Parallel to add_member (the
  # user STORED-PROC path) — personas use a direct changeset insert because the user-scoped
  # sole-owner/count stored procs stay user-only by design (ADR-017 D3). Idempotent via
  # on_conflict on the (resource,member) unique key. v1 = data+display; persona-as-authz-
  # actor is deferred (ADR-015 system-principal).
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

  # Reassign a persona member's role (ccaf5684). User assign-role stays on the stored proc.
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

  # role facet: scalar -> ==, list -> in (= ANY); nil/[] no-op (3c2d6bbe convention).
  defp maybe_role_filter(query, nil), do: query
  defp maybe_role_filter(query, []), do: query

  defp maybe_role_filter(query, roles) when is_list(roles),
    do: where(query, [sm, g, u], g.name in ^roles)

  defp maybe_role_filter(query, role), do: where(query, [sm, g, u], g.name == ^role)

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

end
