defmodule StarterWeb.Plugs.RequireRole do
  @behaviour Plug
  import Plug.Conn

  @impl true
  def init(opts) do
    %{role: Keyword.fetch!(opts, :role)}
  end

  @impl true
  def call(conn, %{role: required_role}) do
    user_id = get_user_id(conn)
    org_id = conn.params["org_id"] || conn.params["organization_id"] || conn.path_params["org_id"]

    cond do
      is_nil(user_id) ->
        conn |> send_json(401, %{error: "Authentication required"}) |> halt()

      is_nil(org_id) ->
        conn |> send_json(400, %{error: "Organization ID required"}) |> halt()

      true ->
        case Starter.Organizations.authorize(user_id, org_id, required_role) do
          {:ok, membership} ->
            conn |> assign(:current_membership, membership)

          {:error, :not_a_member} ->
            conn |> send_json(403, %{error: "Not a member of this organization"}) |> halt()

          {:error, :insufficient_role} ->
            conn |> send_json(403, %{error: "Insufficient permissions"}) |> halt()
        end
    end
  end

  defp get_user_id(conn) do
    case Starter.Guardian.Plug.current_resource(conn) do
      %Starter.Users.Sessions.UserSession{user: {:ref, _, id}} -> id
      %Starter.Users.Sessions.UserSession{user: %{id: id}} -> id
      _ -> nil
    end
  end

  defp send_json(conn, status, body) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(body))
  end
end
