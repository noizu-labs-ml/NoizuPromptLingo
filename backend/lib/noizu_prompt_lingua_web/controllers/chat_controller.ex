defmodule NoizuPromptLinguaWeb.ChatController do
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Domains.Chat
  alias NoizuPromptLingua.Authz

  # GET /api/v1/organizations/:org_id/chat/rooms
  def index(conn, %{"org_id" => org_id} = params) do
    user_id = get_user_id(conn)

    with {:ok, resolved_org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_id),
         {:ok, _} <- Authz.authorize(user_id, "organization", resolved_org_id, "viewer") do
      opts =
        [organization_id: resolved_org_id]
        |> maybe_opt(:project_id, params["project_id"])
        |> maybe_opt(:session_id, params["session_id"])

      rooms = Chat.list_rooms(opts)
      json(conn, %{rooms: Enum.map(rooms, &room_to_json/1)})
    else
      err -> handle_error(conn, err)
    end
  end

  # POST /api/v1/organizations/:org_id/chat/rooms
  def create(conn, %{"org_id" => org_id, "room" => room_params}) do
    user_id = get_user_id(conn)

    with {:ok, resolved_org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_id),
         {:ok, _} <- Authz.authorize(user_id, "organization", resolved_org_id, "member"),
         {:ok, project_id} <- validate_project(room_params["project_id"], resolved_org_id) do
      attrs = %{
        organization_id: resolved_org_id,
        project_id: project_id,
        name: room_params["name"],
        description: room_params["description"],
        session_id: room_params["session_id"]
      }

      case Chat.create_room(attrs) do
        {:ok, room} -> conn |> put_status(:created) |> json(%{room: room_to_json(room)})
        {:error, changeset} -> conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
      end
    else
      err -> handle_error(conn, err)
    end
  end

  # GET /api/v1/organizations/:org_id/chat/rooms/:id
  def show(conn, %{"org_id" => org_id, "id" => id}) do
    user_id = get_user_id(conn)

    with {:ok, resolved_org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_id),
         {:ok, _} <- Authz.authorize(user_id, "organization", resolved_org_id, "viewer"),
         room when not is_nil(room) <- Chat.get_room(id),
         true <- room.organization_id == resolved_org_id do
      json(conn, %{room: room_to_json(room)})
    else
      nil -> conn |> put_status(:not_found) |> json(%{error: "Room not found"})
      false -> conn |> put_status(:not_found) |> json(%{error: "Room not found"})
      err -> handle_error(conn, err)
    end
  end

  defp room_to_json(room) do
    %{
      id: room.id,
      organization_id: room.organization_id,
      project_id: room.project_id,
      session_id: room.session_id,
      name: room.name,
      description: room.description,
      inserted_at: room.inserted_at,
      updated_at: room.updated_at
    }
  end

  defp validate_project(nil, _org_id), do: {:ok, nil}
  defp validate_project("", _org_id), do: {:ok, nil}
  defp validate_project(project_id, org_id) do
    case NoizuPromptLingua.Projects.get_project(project_id) do
      nil -> {:error, :project_not_in_org}
      %{organization_id: ^org_id} -> {:ok, project_id}
      _ -> {:error, :project_not_in_org}
    end
  end

  defp handle_error(conn, err) do
    case err do
      {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "Organization not found"})
      {:error, :not_a_member} -> conn |> put_status(:forbidden) |> json(%{error: "Not a member of this organization"})
      {:error, :project_not_in_org} -> conn |> put_status(:unprocessable_entity) |> json(%{error: "Project does not belong to this organization"})
      _ -> conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})
    end
  end

  defp maybe_opt(opts, _key, nil), do: opts
  defp maybe_opt(opts, _key, ""), do: opts
  defp maybe_opt(opts, key, val), do: Keyword.put(opts, key, val)

  defp get_user_id(conn) do
    case NoizuPromptLingua.Guardian.Plug.current_resource(conn) do
      %NoizuPromptLingua.Users.Sessions.UserSession{user: {:ref, _, id}} -> id
      %NoizuPromptLingua.Users.Sessions.UserSession{user: %{id: id}} -> id
      _ -> nil
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
