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
  #
  # pm_core cutover split: USER memberships are written via Noizu.PM.Authz.ScopedMemberships
  # (pm_core DB) while PERSONA memberships (add_persona_member below) stay on the app DB —
  # so reads must UNION the two sources or post-cutover owners never appear in members lists.
  def list_for_resource(resource_type, resource_id, opts \\ []) do
    user_rows =
      NoizuPromptLingua.PMCore.with_pm(fn ->
        Noizu.PM.Authz.ScopedMemberships.list_for_resource(resource_type, resource_id, opts)
      end)
      |> Enum.map(&Map.merge(%{persona_id: nil, persona_slug: nil, avatar: nil}, &1))

    app_user_rows =
      app_rows_query(resource_type, resource_id, "user")
      |> maybe_role_filter(opts[:role])
      |> NoizuPromptLingua.Repo.all()

    persona_rows =
      app_rows_query(resource_type, resource_id, "persona")
      |> maybe_role_filter(opts[:role])
      |> NoizuPromptLingua.Repo.all()

    # pm rows win: drop app-DB USER rows a pm row already covers. Match on
    # member_id first; for ETL-collapsed users the pm member_id is a different
    # uuid, so also match on normalized email (same person, two ids).
    pm_member_ids = MapSet.new(user_rows, & &1.member_id)
    pm_emails = MapSet.new(user_rows, &normalize_email(&1.email))

    app_user_rows =
      Enum.reject(app_user_rows, fn row ->
        row.member_id in pm_member_ids or
          (is_binary(row.email) and normalize_email(row.email) in pm_emails)
      end)

    user_rows ++ app_user_rows ++ persona_rows
  end

  defp normalize_email(email) when is_binary(email), do: String.downcase(email, :ascii)
  defp normalize_email(_), do: nil

  # App-DB side of the union (USER + PERSONA rows; pm_core only guarantees
  # POST-cutover user rows — pre-cutover / ETL-remapped user memberships exist
  # solely here). Same select shape as the pm user rows so the FE stays
  # member_type-agnostic.
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

  # Single membership by id (getMember), same shape as a list row. nil if absent.
  # User membership ids are pm_core ids; persona membership ids are app-DB ids — resolve
  # both, pm (users) first.
  def get_membership(id) do
    pm_user_membership(id) || persona_membership(id)
  end

  defp pm_user_membership(id) do
    NoizuPromptLingua.PMCore.with_pm(fn ->
      from(sm in Noizu.PM.Schema.Authz.ScopedMembership,
        join: g in Noizu.PM.Schema.Authz.Group,
        on: g.id == sm.group_id,
        left_join: u in Noizu.PM.Schema.Users.User,
        on: sm.member_type == "user" and u.id == sm.member_id,
        where: sm.id == ^id and sm.member_type == "user",
        select: %{
          id: sm.id,
          member_type: sm.member_type,
          member_id: sm.member_id,
          user_id: u.id,
          email: u.email,
          user_name: u.user_name,
          persona_id: nil,
          persona_slug: nil,
          avatar: nil,
          display_name: fragment("coalesce(?, ?)", u.user_name, u.email),
          role: g.name,
          resource_type: sm.resource_type,
          resource_id: sm.resource_id,
          joined_at: sm.created_at,
          expires_at: sm.expires_at
        }
      )
      |> Noizu.PM.Repo.one()
    end)
  end

  # App-DB fallback of get_membership: persona rows primarily, but keep matching
  # app-DB USER rows too (pre-cutover memberships + ETL-collapsed users whose pm
  # member_id differs — same class the list_for_user union surfaces).
  defp persona_membership(id) do
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
    # pm_core cutover: post-cutover user memberships live on Noizu.PM.Repo (add_member path).
    # UNION the app-DB rows too — pre-cutover memberships were never re-written to pm, and
    # the staging ETL remapped member_id for "collapsed" users (email-matched pm uuid ≠ app
    # user id), so the pm read alone drops them from /memberships/me. Dedupe by resource,
    # pm rows first (post-cutover rows are authoritative).
    pm_rows =
      NoizuPromptLingua.PMCore.with_pm(fn ->
        from(sm in Noizu.PM.Schema.Authz.ScopedMembership,
          join: g in Noizu.PM.Schema.Authz.Group,
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
        |> Noizu.PM.Repo.all()
      end)

    app_rows =
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

    Enum.uniq_by(pm_rows ++ app_rows, &{&1.resource_type, &1.resource_id})
  end
end
