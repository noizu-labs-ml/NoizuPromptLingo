defmodule NoizuPromptLinguaWeb.Plugs.RequireRole do
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
        case resolve_org_id(org_id) do
          {:ok, uuid} ->
            # Normalize the route param to the resolved UUID so every downstream
            # controller and Authz call transparently receives a UUID, regardless
            # of whether the URL carried a slug or a UUID.
            conn =
              conn
              |> Map.update!(:params, &maybe_replace_org_id(&1, uuid))
              |> Map.update!(:path_params, &Map.put(&1, "org_id", uuid))

            case NoizuPromptLingua.Organizations.authorize(user_id, uuid, required_role) do
              {:ok, membership} ->
                conn |> assign(:current_membership, membership)

              {:error, :not_a_member} ->
                conn |> send_json(403, %{error: "Not a member of this organization"}) |> halt()

              {:error, :insufficient_role} ->
                conn |> send_json(403, %{error: "Insufficient permissions"}) |> halt()
            end

          {:error, :not_found} ->
            conn |> send_json(404, %{error: "Organization not found"}) |> halt()
        end
    end
  end

  defp resolve_org_id(org_id), do: NoizuPromptLingua.Organizations.resolve_org_id(org_id)

  # Replace any org_id-shaped key present in params with the resolved UUID.
  defp maybe_replace_org_id(params, uuid) do
    params
    |> maybe_put("org_id", uuid)
    |> maybe_put("organization_id", uuid)
  end

  defp maybe_put(params, key, value) do
    if Map.has_key?(params, key), do: Map.put(params, key, value), else: params
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
