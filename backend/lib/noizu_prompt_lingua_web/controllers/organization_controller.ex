defmodule NoizuPromptLinguaWeb.OrganizationController do
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Guardian
  alias NoizuPromptLingua.Organizations

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
           %{slug: org_params["slug"], name: org_params["name"], key_prefix: org_params["key_prefix"]},
           user.id
         ) do
      {:ok, org} ->
        conn
        |> put_status(:created)
        |> json(%{organization: %{id: org.id, slug: org.slug, name: org.name, key_prefix: org.key_prefix}})

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

    with {:ok, org_id} <- Organizations.resolve_org_id(id),
         {:ok, _membership} <- NoizuPromptLingua.Authz.authorize(user.id, "organization", org_id, "viewer"),
         {:ok, org} <- Organizations.get_organization(org_id, Noizu.Context.system()) do
      conn |> put_status(:ok) |> json(%{organization: %{id: org.id, slug: org.slug, name: org.name, key_prefix: org.key_prefix}})
    else
      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Organization not found"})

      {:error, :not_a_member} ->
        conn |> put_status(:forbidden) |> json(%{error: "Not a member of this organization"})

      {:error, :insufficient_role} ->
        conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})
    end
  end

  def update(conn, %{"id" => id, "organization" => org_params}) do
    session = Guardian.Plug.current_resource(conn)
    user = resolve_user(session)

    with {:ok, org_id} <- Organizations.resolve_org_id(id),
         {:ok, _membership} <- Organizations.authorize(user.id, org_id, "admin") do
      attrs = Map.take(org_params, ["slug", "name", "settings", "key_prefix"])

      case Organizations.update_organization(org_id, attrs) do
        {:ok, org} ->
          conn |> put_status(:ok) |> json(%{organization: %{id: org.id, slug: org.slug, name: org.name, key_prefix: org.key_prefix}})

        {:error, :not_found} ->
          conn |> put_status(:not_found) |> json(%{error: "Organization not found"})

        {:error, changeset} when is_struct(changeset, Ecto.Changeset) ->
          conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})

        {:error, reason} ->
          conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
      end
    else
      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Organization not found"})

      {:error, :not_a_member} ->
        conn |> put_status(:forbidden) |> json(%{error: "Not a member of this organization"})

      {:error, :insufficient_role} ->
        conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})
    end
  end

  def delete(conn, %{"id" => id}) do
    session = Guardian.Plug.current_resource(conn)
    user = resolve_user(session)

    with {:ok, org_id} <- Organizations.resolve_org_id(id),
         {:ok, _membership} <- Organizations.authorize(user.id, org_id, "owner") do
      case Organizations.delete_organization(org_id) do
        {:ok, _deleted} ->
          conn |> put_status(:ok) |> json(%{message: "Organization deleted"})

        {:error, :not_found} ->
          conn |> put_status(:not_found) |> json(%{error: "Organization not found"})

        {:error, reason} ->
          conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
      end
    else
      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Organization not found"})

      {:error, :not_a_member} ->
        conn |> put_status(:forbidden) |> json(%{error: "Not a member of this organization"})

      {:error, :insufficient_role} ->
        conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})
    end
  end

  defp resolve_user(%NoizuPromptLingua.Users.Sessions.UserSession{} = session) do
    case session.user do
      {:ref, _, id} ->
        {:ok, user} = NoizuPromptLingua.Users.get_user(id, Noizu.Context.system())
        user
      %NoizuPromptLingua.Users.User{} = user -> user
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
