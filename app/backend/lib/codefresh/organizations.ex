defmodule Codefresh.Organizations do
  @moduledoc """
  Context for organization CRUD and membership queries. Memberships live in
  `Codefresh.Accounts` since they straddle auth + tenancy; this module handles
  the org entity lifecycle and the cross-cutting `create_organization_with_owner`.
  """

  import Ecto.Query, only: [from: 2]
  alias Ecto.Multi
  alias Codefresh.Repo
  alias Codefresh.Organizations.Organization
  alias Codefresh.Accounts.{Membership, User}

  # Role rank for authorization checks. Higher = more privileged.
  @role_rank %{"owner" => 4, "admin" => 3, "editor" => 2, "viewer" => 1, "ci" => 0}

  def create_organization(attrs) do
    %Organization{}
    |> Organization.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Atomically create an organization and grant the creating user the `owner`
  membership. Returns `{:ok, %{organization: org, membership: m}}` on success.
  """
  def create_organization_with_owner(attrs, %User{} = user) do
    Multi.new()
    |> Multi.insert(:organization, Organization.changeset(%Organization{}, attrs))
    |> Multi.insert(:membership, fn %{organization: org} ->
      Membership.changeset(%Membership{}, %{
        organization_id: org.id,
        user_id: user.id,
        role: "owner"
      })
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{organization: org, membership: m}} -> {:ok, %{organization: org, membership: m}}
      {:error, :organization, cs, _} -> {:error, cs}
      {:error, :membership, cs, _} -> {:error, cs}
    end
  end

  def get_organization!(id), do: Repo.get!(Organization, id)
  def get_organization(id), do: Repo.get(Organization, id)

  def get_organization_by_slug(slug) when is_binary(slug) do
    Repo.get_by(Organization, slug: String.downcase(slug))
  end

  def list_organizations, do: Repo.all(Organization)

  @doc """
  Organizations the given user belongs to, each annotated with the user's role.
  """
  def list_user_organizations(%User{id: user_id}) do
    Repo.all(
      from o in Organization,
        join: m in Membership,
        on: m.organization_id == o.id,
        where: m.user_id == ^user_id,
        order_by: [asc: o.name],
        select: %{organization: o, role: m.role}
    )
  end

  @doc """
  Returns the user's role string in the org, or nil if not a member.
  """
  def user_role_in_org(%User{id: user_id}, organization_id) do
    Repo.one(
      from m in Membership,
        where: m.user_id == ^user_id and m.organization_id == ^organization_id,
        select: m.role
    )
  end

  @doc """
  Authorization check: does the user hold at least `required_role` in the org?
  """
  def authorize(%User{} = user, organization_id, required_role) when is_binary(required_role) do
    needed = Map.get(@role_rank, required_role, 99)

    case user_role_in_org(user, organization_id) do
      nil ->
        {:error, :not_a_member}

      role ->
        if Map.get(@role_rank, role, -1) >= needed do
          {:ok, role}
        else
          {:error, :forbidden}
        end
    end
  end
end
