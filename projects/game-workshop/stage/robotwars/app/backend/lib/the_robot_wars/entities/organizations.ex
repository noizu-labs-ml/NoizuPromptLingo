defmodule TheRobotWars.Organizations do
  @moduledoc """
  Context for TheRobotWars.Organizations
  """
  alias TheRobotWars.Organizations.Organization, as: Entity
  alias TheRobotWars.Schema.Organizations.Organization, as: Schema
  alias TheRobotWars.Schema.Organizations.InviteToken, as: InviteTokenSchema
  alias TheRobotWars.Schema.Authz.ScopedMembership, as: ScopedMembershipSchema
  use Noizu.Repo
  def_repo(entity: Entity)
  import Ecto.Query

  def list(context, options \\ []) do
    settings = Noizu.Entity.Meta.persistence(Entity) |> hd

    TheRobotWars.Repo.all(Schema)
    |> Enum.map(fn record ->
      {:ok, entity} = Entity.from_record(record, settings, context, options)
      {:ok, entity} = __after_get__(entity, context, options)
      entity
    end)
  end

  def get_organization(id, context, options \\ []), do: get(id, context, options)

  def create_organization_with_owner(attrs, user_id) do
    TheRobotWars.Repo.transaction(fn ->
      with {:ok, org} <- %Schema{} |> Schema.changeset(attrs) |> TheRobotWars.Repo.insert(),
           {:ok, _membership} <- TheRobotWars.Authz.ScopedMemberships.add_member("organization", org.id, user_id, "owner") do
        org
      else
        {:error, reason} -> TheRobotWars.Repo.rollback(reason)
      end
    end)
  end

  def list_user_organizations(user_id) do
    from(sm in ScopedMembershipSchema,
      join: o in Schema, on: o.id == sm.resource_id,
      join: g in TheRobotWars.Schema.Authz.Group, on: g.id == sm.group_id,
      where: sm.member_type == "user" and sm.member_id == ^user_id and sm.resource_type == "organization",
      where: is_nil(sm.expires_at) or sm.expires_at > ^DateTime.utc_now(),
      select: %{id: o.id, slug: o.slug, name: o.name, role: g.name}
    )
    |> TheRobotWars.Repo.all()
  end

  def authorize(user_id, organization_id, required_role) do
    TheRobotWars.Authz.authorize(user_id, "organization", organization_id, required_role)
  end

  def list_members(organization_id) do
    TheRobotWars.Authz.ScopedMemberships.list_for_resource("organization", organization_id)
  end

  def create_invite_token(attrs) do
    raw_token = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
    key_prefix = String.slice(raw_token, 0, 8)
    token_hash = Bcrypt.hash_pwd_salt(raw_token)

    result =
      %InviteTokenSchema{}
      |> InviteTokenSchema.changeset(Map.merge(attrs, %{
        token_hash: token_hash,
        key_prefix: key_prefix
      }))
      |> TheRobotWars.Repo.insert()

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
    |> TheRobotWars.Repo.all()
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
    |> TheRobotWars.Repo.update_all(inc: [uses: 1])
  end
end
