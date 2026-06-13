defmodule TheRobotWarsWeb.OrganizationController do
  use TheRobotWarsWeb, :controller

  alias TheRobotWars.Guardian
  alias TheRobotWars.Organizations

  def index(conn, _params) do
    session = Guardian.Plug.current_resource(conn)
    user = resolve_user(session)
    orgs = Organizations.list_user_organizations(user.id)

    conn |> put_status(:ok) |> json(%{organizations: orgs})
  end

  def create(conn, %{"organization" => org_params}) do
    session = Guardian.Plug.current_resource(conn)
    user = resolve_user(session)

    case Organizations.create_organization_with_owner(
           %{slug: org_params["slug"], name: org_params["name"]},
           user.id
         ) do
      {:ok, org} ->
        conn
        |> put_status(:created)
        |> json(%{organization: %{id: org.id, slug: org.slug, name: org.name}})

      {:error, changeset} when is_struct(changeset, Ecto.Changeset) ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: to_string(reason)})
    end
  end

  def show(conn, %{"id" => id}) do
    session = Guardian.Plug.current_resource(conn)
    user = resolve_user(session)

    case TheRobotWars.Authz.authorize(user.id, "organization", id, "viewer") do
      {:ok, _membership} ->
        case Organizations.get_organization(id, Noizu.Context.system()) do
          {:ok, org} ->
            conn |> put_status(:ok) |> json(%{organization: %{id: org.id, slug: org.slug, name: org.name}})

          _ ->
            conn |> put_status(:not_found) |> json(%{error: "Organization not found"})
        end

      {:error, :not_a_member} ->
        conn |> put_status(:forbidden) |> json(%{error: "Not a member of this organization"})

      {:error, :insufficient_role} ->
        conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})
    end
  end

  defp resolve_user(%TheRobotWars.Users.Sessions.UserSession{} = session) do
    case session.user do
      {:ref, _, id} ->
        {:ok, user} = TheRobotWars.Users.get_user(id, Noizu.Context.system())
        user
      %TheRobotWars.Users.User{} = user -> user
    end
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
