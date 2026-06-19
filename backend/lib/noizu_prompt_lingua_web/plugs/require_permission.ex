defmodule NoizuPromptLinguaWeb.Plugs.RequirePermission do
  @behaviour Plug
  import Plug.Conn

  @impl true
  def init(opts) do
    %{
      permission: Keyword.fetch!(opts, :permission),
      resource_type: Keyword.get(opts, :resource_type, "organization"),
      resource_id_param: Keyword.get(opts, :resource_id_param, "org_id")
    }
  end

  @impl true
  def call(conn, %{permission: permission, resource_type: resource_type, resource_id_param: param}) do
    user_id = get_user_id(conn)
    resource_id = conn.params[param] || conn.path_params[param]

    cond do
      is_nil(user_id) ->
        conn |> send_json(401, %{error: "Authentication required"}) |> halt()

      is_nil(resource_id) ->
        conn |> send_json(400, %{error: "Resource ID required"}) |> halt()

      NoizuPromptLingua.Authz.check_permission(user_id, resource_type, resource_id, permission) ->
        conn |> assign(:permission_checked, permission)

      true ->
        conn |> send_json(403, %{error: "Insufficient permissions"}) |> halt()
    end
  end

  defp get_user_id(conn) do
    case NoizuPromptLingua.Guardian.Plug.current_resource(conn) do
      %NoizuPromptLingua.Users.Sessions.UserSession{user: {:ref, _, id}} -> id
      %NoizuPromptLingua.Users.Sessions.UserSession{user: %{id: id}} -> id
      _ -> nil
    end
  end

  defp send_json(conn, status, body) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(body))
  end
end
