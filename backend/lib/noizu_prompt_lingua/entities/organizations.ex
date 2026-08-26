defmodule NoizuPromptLingua.Organizations do
  @moduledoc """
  Context for NoizuPromptLingua.Organizations
  """
  alias NoizuPromptLingua.Organizations.Organization, as: Entity
  alias NoizuPromptLingua.Schema.Organizations.Organization, as: Schema
  alias NoizuPromptLingua.Schema.Organizations.InviteToken, as: InviteTokenSchema
  alias NoizuPromptLingua.Schema.Authz.ScopedMembership, as: ScopedMembershipSchema
  use Noizu.Repo
  def_repo(entity: Entity)
  import Ecto.Query

  def list(context, options \\ []) do
    settings = Noizu.Entity.Meta.persistence(Entity) |> hd

    NoizuPromptLingua.Repo.all(Schema)
    |> Enum.map(fn record ->
      {:ok, entity} = Entity.from_record(record, settings, context, options)
      {:ok, entity} = __after_get__(entity, context, options)
      entity
    end)
  end

  def get_organization(id, context, options \\ []), do: get(id, context, options)

  @doc """
  Resolves an org identifier from a URL — accepts either a UUID (passed
  through) or a slug (looked up via the Redis-backed slug cache). Used so the
  API can accept slugs in URLs while keeping the UUID-keyed data layer intact.
  Returns `{:ok, uuid}` or `{:error, :not_found}`.

  The UUID branch passes its input through *as the org id*, so a wrong
  classification here is not a failed lookup — it forwards a slug into every
  downstream `organization_id ==` filter and locks the tenant out of the whole
  API. Hence `NoizuPromptLingua.UUID.uuid?/1` rather than `Ecto.UUID.cast/1`,
  which also accepts a raw 16-byte binary and so claimed every 16-character
  slug. See that module.
  """
  def resolve_org_id(slug_or_uuid) do
    cond do
      is_nil(slug_or_uuid) ->
        {:error, :not_found}

      NoizuPromptLingua.UUID.uuid?(slug_or_uuid) ->
        {:ok, slug_or_uuid}

      is_binary(slug_or_uuid) ->
        NoizuPromptLingua.Cache.fetch(
          NoizuPromptLingua.Cache.slug_key(slug_or_uuid),
          fn ->
            case get_id_by_slug(slug_or_uuid) do
              nil -> {:error, :not_found}
              id -> {:ok, to_string(id)}
            end
          end
        )

      true ->
        {:error, :not_found}
    end
  end

  @doc "Looks up an org UUID by slug. `slug` is citext (case-insensitive)."
  def get_id_by_slug(slug) do
    NoizuPromptLingua.PMCore.with_pm(fn -> Noizu.PM.Organizations.get_id_by_slug(slug) end)
  end

  def update_organization(id, attrs) do
    case NoizuPromptLingua.Repo.get(Schema, id) do
      nil ->
        {:error, :not_found}

      org ->
        old_slug = org.slug
        result = org |> Schema.changeset(attrs) |> NoizuPromptLingua.Repo.update()

        # Slug may have changed — drop the cached entry for the previous slug
        # so stale slug → UUID lookups don't survive a rename.
        with {:ok, _} <- result,
             new_slug when new_slug != old_slug <- attrs["slug"] || attrs[:slug] do
          NoizuPromptLingua.Cache.invalidate(NoizuPromptLingua.Cache.slug_key(old_slug))
        end

        result
    end
  end

  @doc """
  Hard-deletes an organization along with the dependent rows that do not
  cascade at the database level (scoped memberships for the org and its
  projects, and invite tokens). Projects and custom roles are removed via
  `ON DELETE CASCADE`.
  """
  def delete_organization(id) do
    case NoizuPromptLingua.Repo.get(Schema, id) do
      nil ->
        {:error, :not_found}

      org ->
        NoizuPromptLingua.Repo.transaction(fn ->
          project_ids =
            from(p in NoizuPromptLingua.Schema.Projects.Project,
              where: p.organization_id == ^id,
              select: p.id
            )
            |> NoizuPromptLingua.Repo.all()

          from(sm in ScopedMembershipSchema,
            where:
              (sm.resource_type == "organization" and sm.resource_id == ^id) or
                (sm.resource_type == "project" and sm.resource_id in ^project_ids)
          )
          |> NoizuPromptLingua.Repo.delete_all()

          from(t in InviteTokenSchema, where: t.organization_id == ^id)
          |> NoizuPromptLingua.Repo.delete_all()

          case NoizuPromptLingua.Repo.delete(org) do
            {:ok, deleted} -> deleted
            {:error, reason} -> NoizuPromptLingua.Repo.rollback(reason)
          end
        end)
    end
  end

  def create_organization_with_owner(attrs, user_id) do
    NoizuPromptLingua.PMCore.with_pm(fn ->
      Noizu.PM.Organizations.create_with_owner(attrs, user_id)
    end)
  end

  def list_user_organizations(user_id) do
    # pm_core cutover: post-cutover org rows + user scoped memberships live on Noizu.PM.Repo
    # — same select shape as the app-DB source (ADR-015 effective_role echo + owner display).
    # UNION the app-DB rows too: pre-cutover memberships were never re-written to pm, and the
    # staging ETL remapped member_id for "collapsed" users (email-matched to a pm user whose
    # uuid differs from the app user id), so the pm read alone returns [] for those users —
    # emptying session/me + the org switcher and degrading every console route to the org
    # dashboard (nav hrefs fall back to /app/<section>, which the [orgId] route renders as
    # the dashboard). Dedupe by org id, pm rows first (post-cutover rows are authoritative).
    pm_rows =
      NoizuPromptLingua.PMCore.with_pm(fn ->
        from(sm in Noizu.PM.Schema.Authz.ScopedMembership,
          join: o in Noizu.PM.Schema.Organizations.Organization,
          on: o.id == sm.resource_id,
          join: g in Noizu.PM.Schema.Authz.Group,
          on: g.id == sm.group_id,
          left_join: og in Noizu.PM.Schema.Authz.Group,
          on: og.name == "owner",
          left_join: osm in Noizu.PM.Schema.Authz.ScopedMembership,
          on:
            osm.resource_id == o.id and osm.resource_type == "organization" and
              osm.member_type == "user" and osm.group_id == og.id,
          left_join: ou in Noizu.PM.Schema.Users.User,
          on: ou.id == osm.member_id,
          where:
            sm.member_type == "user" and sm.member_id == ^user_id and
              sm.resource_type == "organization",
          where: is_nil(sm.expires_at) or sm.expires_at > ^DateTime.utc_now(),
          group_by: [o.id, o.slug, o.name, g.name],
          select: %{
            id: o.id,
            slug: o.slug,
            name: o.name,
            role: g.name,
            effective_role: g.name,
            owner: fragment("max(coalesce(?, ?, ?))", ou.user_name, ou.handle, ou.email)
          }
        )
        |> Noizu.PM.Repo.all()
      end)

    app_rows =
      from(sm in ScopedMembershipSchema,
        join: o in Schema,
        on: o.id == sm.resource_id,
        join: g in NoizuPromptLingua.Schema.Authz.Group,
        on: g.id == sm.group_id,
        left_join: og in NoizuPromptLingua.Schema.Authz.Group,
        on: og.name == "owner",
        left_join: osm in ScopedMembershipSchema,
        on:
          osm.resource_id == o.id and osm.resource_type == "organization" and
            osm.member_type == "user" and osm.group_id == og.id,
        left_join: ou in NoizuPromptLingua.Schema.Users.User,
        on: ou.id == osm.member_id,
        where:
          sm.member_type == "user" and sm.member_id == ^user_id and
            sm.resource_type == "organization",
        where: is_nil(sm.expires_at) or sm.expires_at > ^DateTime.utc_now(),
        group_by: [o.id, o.slug, o.name, g.name],
        select: %{
          id: o.id,
          slug: o.slug,
          name: o.name,
          role: g.name,
          effective_role: g.name,
          owner: fragment("max(coalesce(?, ?, ?))", ou.user_name, ou.handle, ou.email)
        }
      )
      |> NoizuPromptLingua.Repo.all()

    Enum.uniq_by(pm_rows ++ app_rows, & &1.id)
  end

  def authorize(user_id, organization_id, required_role) do
    NoizuPromptLingua.Authz.authorize(user_id, "organization", organization_id, required_role)
  end

  def list_members(organization_id) do
    NoizuPromptLingua.Authz.ScopedMemberships.list_for_resource("organization", organization_id)
  end

  def create_invite_token(attrs) do
    raw_token = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
    key_prefix = String.slice(raw_token, 0, 8)
    token_hash = Bcrypt.hash_pwd_salt(raw_token)

    result =
      %InviteTokenSchema{}
      |> InviteTokenSchema.changeset(
        Map.merge(attrs, %{
          token_hash: token_hash,
          key_prefix: key_prefix
        })
      )
      |> NoizuPromptLingua.Repo.insert()

    case result do
      {:ok, invite} -> {:ok, invite, raw_token}
      error -> error
    end
  end

  def find_active_invite_by_raw_token(raw_token) when is_binary(raw_token) do
    key_prefix = String.slice(raw_token, 0, 8)
    now = DateTime.utc_now()

    from(t in InviteTokenSchema,
      where: t.key_prefix == ^key_prefix and t.revoked == false,
      where: is_nil(t.expires_at) or t.expires_at > ^now,
      where: is_nil(t.max_uses) or t.uses < t.max_uses
    )
    |> NoizuPromptLingua.Repo.all()
    |> Enum.find(fn token ->
      Bcrypt.verify_pass(raw_token, token.token_hash)
    end)
    |> case do
      nil -> {:error, :invalid_token}
      token -> {:ok, token}
    end
  end

  def increment_invite_uses(invite_token) do
    from(t in InviteTokenSchema, where: t.id == ^invite_token.id)
    |> NoizuPromptLingua.Repo.update_all(inc: [uses: 1])
  end
end
