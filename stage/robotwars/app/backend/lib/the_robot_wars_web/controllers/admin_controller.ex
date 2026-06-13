defmodule TheRobotWarsWeb.AdminController do
  use TheRobotWarsWeb, :controller

  alias TheRobotWars.Schema.Users.User, as: UserSchema
  alias TheRobotWars.Schema.Organizations.Organization, as: OrgSchema
  import Ecto.Query

  def list_users(conn, params) do
    page = String.to_integer(Map.get(params, "page", "1"))
    per_page = String.to_integer(Map.get(params, "per_page", "50"))
    offset = (page - 1) * per_page

    users =
      from(u in UserSchema,
        order_by: [desc: u.inserted_at],
        limit: ^per_page,
        offset: ^offset,
        select: %{
          id: u.id,
          email: u.email,
          user_name: u.user_name,
          status: u.status,
          verified: u.verified,
          admin: u.admin,
          created_at: u.inserted_at
        }
      )
      |> TheRobotWars.Repo.all()

    total = TheRobotWars.Repo.aggregate(UserSchema, :count, :id)

    conn |> put_status(:ok) |> json(%{users: users, total: total, page: page, per_page: per_page})
  end

  def show_user(conn, %{"id" => id}) do
    case TheRobotWars.Repo.get(UserSchema, id) do
      nil ->
        conn |> put_status(:not_found) |> json(%{error: "User not found"})

      user ->
        conn |> put_status(:ok) |> json(%{user: %{
          id: user.id,
          email: user.email,
          user_name: user.user_name,
          handle: user.handle,
          status: user.status,
          verified: user.verified,
          admin: user.admin,
          created_at: user.inserted_at
        }})
    end
  end

  def list_organizations(conn, params) do
    page = String.to_integer(Map.get(params, "page", "1"))
    per_page = String.to_integer(Map.get(params, "per_page", "50"))
    offset = (page - 1) * per_page

    orgs =
      from(o in OrgSchema,
        order_by: [desc: o.inserted_at],
        limit: ^per_page,
        offset: ^offset,
        select: %{
          id: o.id,
          slug: o.slug,
          name: o.name,
          created_at: o.inserted_at
        }
      )
      |> TheRobotWars.Repo.all()

    total = TheRobotWars.Repo.aggregate(OrgSchema, :count, :id)

    conn |> put_status(:ok) |> json(%{organizations: orgs, total: total, page: page, per_page: per_page})
  end

  def show_organization(conn, %{"id" => id}) do
    case TheRobotWars.Repo.get(OrgSchema, id) do
      nil ->
        conn |> put_status(:not_found) |> json(%{error: "Organization not found"})

      org ->
        members = TheRobotWars.Organizations.list_members(org.id)
        conn |> put_status(:ok) |> json(%{organization: %{
          id: org.id,
          slug: org.slug,
          name: org.name,
          created_at: org.inserted_at
        }, members: members})
    end
  end
end
