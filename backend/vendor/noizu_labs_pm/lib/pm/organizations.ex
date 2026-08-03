defmodule Noizu.PM.Organizations do
  @moduledoc """
  Shared organization store + minimal orchestration on `Noizu.PM.Repo`.
  Host apps dual-path create/get when pm_core is enabled so project FKs resolve.
  """
  alias Noizu.PM.Organizations.Organization, as: Entity
  alias Noizu.PM.Schema.Organizations.Organization, as: Schema

  use Noizu.Repo
  def_repo(entity: Entity)

  import Ecto.Query

  def get_organization(id), do: Noizu.PM.Repo.get(Schema, id)

  def get_id_by_slug(slug) when is_binary(slug) do
    from(o in Schema, where: o.slug == ^slug, select: o.id)
    |> Noizu.PM.Repo.one()
  end

  @doc """
  Ensure an organization row exists on pm_core (same UUID). Idempotent.
  Required before project create when org was only on the app-local DB.
  """
  def ensure(attrs) when is_map(attrs) do
    id = fetch(attrs, :id)

    cond do
      is_nil(id) or id == "" ->
        {:error, :missing_id}

      true ->
        case Noizu.PM.Repo.get(Schema, id) do
          %Schema{} = org ->
            {:ok, org}

          nil ->
            params = %{
              slug: fetch(attrs, :slug) || "org-#{String.slice(to_string(id), 0, 8)}",
              name: fetch(attrs, :name) || "Organization",
              settings: fetch(attrs, :settings) || %{},
              key_prefix: fetch(attrs, :key_prefix)
            }

            %Schema{id: id}
            |> Schema.changeset(params)
            |> Noizu.PM.Repo.insert()
        end
    end
  end

  def create_with_owner(attrs, user_id) do
    Noizu.PM.Repo.transaction(fn ->
      with {:ok, org} <-
             %Schema{}
             |> Schema.changeset(attrs)
             |> Noizu.PM.Repo.insert(),
           {:ok, _membership} <-
             Noizu.PM.Authz.ScopedMemberships.add_member(
               "organization",
               org.id,
               user_id,
               "owner"
             ) do
        org
      else
        {:error, reason} -> Noizu.PM.Repo.rollback(reason)
      end
    end)
  end

  def list_all do
    Noizu.PM.Repo.all(Schema)
  end

  @doc """
  Organizations a user belongs to, via their scoped memberships, newest-role
  first columns dropped in favor of a flat `%{id, slug, name, role}` map — the
  shape host-app callers (session/me/invite-redeem responses) already expect.
  """
  def list_for_user(user_id) do
    from(sm in Noizu.PM.Schema.Authz.ScopedMembership,
      join: o in Schema,
      on: o.id == sm.resource_id,
      join: g in Noizu.PM.Schema.Authz.Group,
      on: g.id == sm.group_id,
      where:
        sm.member_type == "user" and sm.member_id == ^user_id and
          sm.resource_type == "organization",
      where: is_nil(sm.expires_at) or sm.expires_at > ^DateTime.utc_now(),
      select: %{id: o.id, slug: o.slug, name: o.name, role: g.name}
    )
    |> Noizu.PM.Repo.all()
  end

  defp fetch(map, key) when is_atom(key) do
    Map.get(map, key) || Map.get(map, Atom.to_string(key))
  end
end
