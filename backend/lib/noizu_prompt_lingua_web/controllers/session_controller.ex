defmodule NoizuPromptLinguaWeb.SessionController do
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Sessions
  alias NoizuPromptLingua.Authz

  # GET /api/v1/organizations/:org_id/sessions
  def index(conn, %{"org_id" => org_id} = params) do
    user_id = get_user_id(conn)

    with {:ok, resolved_org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_id),
         {:ok, _} <- Authz.authorize(user_id, "organization", resolved_org_id, "viewer") do
      opts =
        []
        |> maybe_opt(:status, params["status"])
        |> maybe_opt(:project_id, params["project_id"])

      sessions = Sessions.list_for_org(resolved_org_id, opts)
      json(conn, %{sessions: Enum.map(sessions, &session_to_json/1)})
    else
      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Organization not found"})

      {:error, :not_a_member} ->
        conn |> put_status(:forbidden) |> json(%{error: "Not a member of this organization"})

      {:error, _} ->
        conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})
    end
  end

  # POST /api/v1/organizations/:org_id/sessions
  def create(conn, %{"org_id" => org_id, "session" => session_params}) do
    user_id = get_user_id(conn)

    with {:ok, resolved_org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_id),
         {:ok, _} <- Authz.authorize(user_id, "organization", resolved_org_id, "member"),
         {:ok, project_id} <- validate_project(session_params["project_id"], resolved_org_id) do
      attrs = %{
        organization_id: resolved_org_id,
        project_id: project_id,
        title: session_params["title"],
        description: session_params["description"],
        status: session_params["status"] || "active"
      }

      case Sessions.create(attrs, user_id) do
        {:ok, session} ->
          conn |> put_status(:created) |> json(%{session: session_to_json(session)})

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

      {:error, :project_not_in_org} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Project does not belong to this organization"})

      {:error, _} ->
        conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})
    end
  end

  # GET /api/v1/organizations/:org_id/sessions/:id
  def show(conn, %{"org_id" => org_id, "id" => id}) do
    with_org_session(conn, org_id, id, "viewer", fn session ->
      json(conn, %{session: session_to_json(session)})
    end)
  end

  # PATCH/PUT /api/v1/organizations/:org_id/sessions/:id
  def update(conn, %{"org_id" => org_id, "id" => id, "session" => attrs}) do
    user_id = get_user_id(conn)

    with {:ok, resolved_org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_id),
         {:ok, _} <- Authz.authorize(user_id, "organization", resolved_org_id, "member"),
         session when not is_nil(session) <- Sessions.get_session(id),
         true <- session.organization_id == resolved_org_id || :wrong_org,
         {:ok, project_id} <- validate_project(Map.get(attrs, "project_id"), resolved_org_id) do
      # Normalize to atom keys: Sessions.update_session stamps
      # :last_activity_at (atom) onto this map, and Ecto.cast raises
      # Ecto.CastError on maps with mixed key types.
      patch =
        attrs
        |> Map.take(["title", "description", "status"])
        |> Map.new(fn {k, v} -> {String.to_existing_atom(k), v} end)
        |> maybe_put(:project_id, Map.has_key?(attrs, "project_id"), project_id)

      case Sessions.update_session(id, patch) do
        {:ok, session} ->
          json(conn, %{session: session_to_json(session)})

        {:error, :not_found} ->
          conn |> put_status(:not_found) |> json(%{error: "Session not found"})

        {:error, changeset} ->
          conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
      end
    else
      nil ->
        conn |> put_status(:not_found) |> json(%{error: "Session not found"})

      :wrong_org ->
        conn |> put_status(:not_found) |> json(%{error: "Session not found"})

      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Organization not found"})

      {:error, :project_not_in_org} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Project does not belong to this organization"})

      {:error, _} ->
        conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})
    end
  end

  # POST /api/v1/organizations/:org_id/sessions/:session_id/archive
  def archive(conn, %{"org_id" => org_id, "session_id" => id}) do
    with_org_session(conn, org_id, id, "member", fn _session ->
      case Sessions.archive(id) do
        {:ok, session} ->
          json(conn, %{session: session_to_json(session)})

        {:error, :not_found} ->
          conn |> put_status(:not_found) |> json(%{error: "Session not found"})
      end
    end)
  end

  # POST /api/v1/organizations/:org_id/sessions/:session_id/unarchive
  def unarchive(conn, %{"org_id" => org_id, "session_id" => id}) do
    with_org_session(conn, org_id, id, "member", fn _session ->
      case Sessions.unarchive(id) do
        {:ok, session} ->
          json(conn, %{session: session_to_json(session)})

        {:error, :not_found} ->
          conn |> put_status(:not_found) |> json(%{error: "Session not found"})
      end
    end)
  end

  # DELETE /api/v1/organizations/:org_id/sessions/:id
  def delete(conn, %{"org_id" => org_id, "id" => id}) do
    with_org_session(conn, org_id, id, "member", fn _session ->
      case Sessions.delete_session(id) do
        {:ok, _} ->
          json(conn, %{message: "Session deleted"})

        {:error, :not_found} ->
          conn |> put_status(:not_found) |> json(%{error: "Session not found"})
      end
    end)
  end

  # Resolve org, authorize at the given role, load the session, and ensure it
  # belongs to the org before handing it to `fun`.
  defp with_org_session(conn, org_id, id, role, fun) do
    user_id = get_user_id(conn)

    with {:ok, resolved_org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_id),
         {:ok, _} <- Authz.authorize(user_id, "organization", resolved_org_id, role),
         session when not is_nil(session) <- Sessions.get_session(id),
         true <- session.organization_id == resolved_org_id do
      fun.(session)
    else
      nil ->
        conn |> put_status(:not_found) |> json(%{error: "Session not found"})

      false ->
        conn |> put_status(:not_found) |> json(%{error: "Session not found"})

      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Organization not found"})

      {:error, :not_a_member} ->
        conn |> put_status(:forbidden) |> json(%{error: "Not a member of this organization"})

      {:error, _} ->
        conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})
    end
  end

  # A session's project (when set) must live in the same organization.
  defp validate_project(nil, _org_id), do: {:ok, nil}
  defp validate_project("", _org_id), do: {:ok, nil}

  defp validate_project(project_id, org_id) do
    case NoizuPromptLingua.Projects.get_project(project_id) do
      nil -> {:error, :project_not_in_org}
      %{organization_id: ^org_id} -> {:ok, project_id}
      _ -> {:error, :project_not_in_org}
    end
  end

  defp maybe_opt(opts, _key, nil), do: opts
  defp maybe_opt(opts, _key, ""), do: opts
  defp maybe_opt(opts, key, val), do: Keyword.put(opts, key, val)

  defp maybe_put(map, _key, false, _val), do: map
  defp maybe_put(map, key, true, val), do: Map.put(map, key, val)

  defp get_user_id(conn) do
    case NoizuPromptLingua.Guardian.Plug.current_resource(conn) do
      %NoizuPromptLingua.Users.Sessions.UserSession{user: {:ref, _, id}} -> id
      %NoizuPromptLingua.Users.Sessions.UserSession{user: %{id: id}} -> id
      _ -> nil
    end
  end

  defp session_to_json(session) do
    %{
      id: session.id,
      organization_id: session.organization_id,
      project_id: session.project_id,
      title: session.title,
      description: session.description,
      status: session.status,
      archived_at: session.archived_at,
      inserted_at: session.inserted_at,
      updated_at: session.updated_at
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
