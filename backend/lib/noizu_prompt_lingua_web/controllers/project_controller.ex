defmodule NoizuPromptLinguaWeb.ProjectController do
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Projects
  alias NoizuPromptLingua.Authz
  alias NoizuPromptLingua.Authz.ScopedMemberships

  def index(conn, %{"org_id" => org_id}) do
    user_id = get_user_id(conn)

    with {:ok, resolved_org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_id) do
      case Authz.authorize(user_id, "organization", resolved_org_id, "viewer") do
        {:ok, _} ->
          projects = Projects.list_for_user(user_id, resolved_org_id)
          json(conn, %{projects: projects})

        {:error, :not_a_member} ->
          conn |> put_status(:forbidden) |> json(%{error: "Not a member of this organization"})

        {:error, _} ->
          conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})
      end
    else
      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Organization not found"})
    end
  end

  def create(conn, %{"org_id" => org_id, "project" => project_params}) do
    user_id = get_user_id(conn)

    with {:ok, resolved_org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_id) do
      if Authz.check_permission(user_id, "organization", resolved_org_id, "project:create") do
        attrs = %{
          organization_id: resolved_org_id,
          name: project_params["name"],
          slug: project_params["slug"],
          description: project_params["description"],
          settings: project_params["settings"] || %{}
        }

        case Projects.create_with_owner(attrs, user_id) do
          {:ok, project} ->
            conn
            |> put_status(:created)
            |> json(%{project: %{id: project.id, name: project.name, slug: project.slug, organization_id: project.organization_id}})

          {:error, changeset} when is_struct(changeset, Ecto.Changeset) ->
            conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})

          {:error, reason} ->
            conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
        end
      else
        conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})
      end
    else
      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Organization not found"})
    end
  end

  def show(conn, %{"org_id" => _org_id, "id" => project_id}) do
    user_id = get_user_id(conn)

    if Authz.check_permission(user_id, "project", project_id, "project:view") do
      case Projects.get_project(project_id) do
        nil -> conn |> put_status(:not_found) |> json(%{error: "Project not found"})
        project -> json(conn, %{project: project_to_json(project)})
      end
    else
      conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})
    end
  end

  def update(conn, %{"org_id" => _org_id, "id" => project_id, "project" => attrs}) do
    user_id = get_user_id(conn)

    if Authz.check_permission(user_id, "project", project_id, "project:update") do
      case Projects.update_project(project_id, attrs) do
        {:ok, project} -> json(conn, %{project: project_to_json(project)})
        {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "Project not found"})
        {:error, changeset} -> conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
      end
    else
      conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})
    end
  end

  def delete(conn, %{"org_id" => _org_id, "id" => project_id}) do
    user_id = get_user_id(conn)

    if Authz.check_permission(user_id, "project", project_id, "project:delete") do
      case Projects.delete_project(project_id) do
        {:ok, _} -> json(conn, %{message: "Project deleted"})
        {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "Project not found"})
      end
    else
      conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})
    end
  end

  def archive(conn, %{"project_id" => project_id}) do
    user_id = get_user_id(conn)

    if Authz.check_permission(user_id, "project", project_id, "project:archive") do
      case Projects.archive(project_id) do
        {:ok, project} -> json(conn, %{project: project_to_json(project)})
        {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "Project not found"})
      end
    else
      conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})
    end
  end

  def unarchive(conn, %{"project_id" => project_id}) do
    user_id = get_user_id(conn)

    if Authz.check_permission(user_id, "project", project_id, "project:archive") do
      case Projects.unarchive(project_id) do
        {:ok, project} -> json(conn, %{project: project_to_json(project)})
        {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "Project not found"})
      end
    else
      conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})
    end
  end

  def members(conn, %{"project_id" => project_id}) do
    user_id = get_user_id(conn)

    if Authz.check_permission(user_id, "project", project_id, "project:view") do
      members = Projects.list_members(project_id)
      json(conn, %{members: members})
    else
      conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})
    end
  end

  def add_member(conn, %{"project_id" => project_id, "user_id" => member_user_id} = params) do
    user_id = get_user_id(conn)
    role = Map.get(params, "role", "member")

    if Authz.check_permission(user_id, "project", project_id, "project:manage_members") do
      case ScopedMemberships.add_member("project", project_id, member_user_id, role, user_id) do
        {:ok, _} ->
          members = Projects.list_members(project_id)
          conn |> put_status(:created) |> json(%{members: members})

        {:error, :already_member} ->
          conn |> put_status(:conflict) |> json(%{error: "User is already a member"})

        {:error, :invalid_role} ->
          conn |> put_status(:bad_request) |> json(%{error: "Invalid role"})

        {:error, reason} ->
          conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
      end
    else
      conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})
    end
  end

  def update_member(conn, %{"project_id" => project_id, "member_user_id" => member_user_id, "role" => role}) do
    user_id = get_user_id(conn)

    if Authz.check_permission(user_id, "project", project_id, "project:manage_members") do
      if user_id == member_user_id do
        conn |> put_status(:bad_request) |> json(%{error: "Cannot change your own role"})
      else
        case ScopedMemberships.update_role("project", project_id, member_user_id, role) do
          {:ok, result} -> json(conn, %{membership: result})
          {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "Member not found"})
          {:error, reason} -> conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
        end
      end
    else
      conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})
    end
  end

  def remove_member(conn, %{"project_id" => project_id, "member_user_id" => member_user_id}) do
    user_id = get_user_id(conn)

    if Authz.check_permission(user_id, "project", project_id, "project:manage_members") do
      case ScopedMemberships.remove_member("project", project_id, member_user_id) do
        {:ok, _} -> json(conn, %{message: "Member removed"})
        {:error, :sole_owner} -> conn |> put_status(:bad_request) |> json(%{error: "Cannot remove the sole owner"})
        {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "Member not found"})
      end
    else
      conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})
    end
  end

  def leave(conn, %{"project_id" => project_id}) do
    user_id = get_user_id(conn)

    case ScopedMemberships.remove_member("project", project_id, user_id) do
      {:ok, _} -> json(conn, %{message: "Left project"})
      {:error, :sole_owner} -> conn |> put_status(:bad_request) |> json(%{error: "Cannot leave as sole owner. Transfer ownership first."})
      {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "Not a member"})
    end
  end

  defp get_user_id(conn) do
    case NoizuPromptLingua.Guardian.Plug.current_resource(conn) do
      %NoizuPromptLingua.Users.Sessions.UserSession{user: {:ref, _, id}} -> id
      %NoizuPromptLingua.Users.Sessions.UserSession{user: %{id: id}} -> id
      _ -> nil
    end
  end

  defp project_to_json(project) do
    %{
      id: project.id,
      organization_id: project.organization_id,
      name: project.name,
      slug: project.slug,
      description: project.description,
      settings: project.settings,
      status: project.status,
      archived_at: project.archived_at,
      inserted_at: project.inserted_at,
      updated_at: project.updated_at
    }
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
