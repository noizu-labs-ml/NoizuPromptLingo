defmodule NoizuPromptLinguaWeb.DashboardController do
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Authz
  alias NoizuPromptLingua.Domains.Dashboard

  # GET /api/v1/organizations/:org_id/dashboard/stats?range=7|14|30
  def stats(conn, %{"org_id" => org_id} = params) do
    user_id = get_user_id(conn)

    with {:ok, resolved_org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_id),
         {:ok, _} <- Authz.authorize(user_id, "organization", resolved_org_id, "viewer") do
      stats = Dashboard.stats(resolved_org_id, range: params["range"])
      json(conn, %{stats: stats})
    else
      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Organization not found"})

      {:error, :not_a_member} ->
        conn |> put_status(:forbidden) |> json(%{error: "Not a member of this organization"})

      {:error, _} ->
        conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})
    end
  end

  defp get_user_id(conn) do
    case NoizuPromptLingua.Guardian.Plug.current_resource(conn) do
      %NoizuPromptLingua.Users.Sessions.UserSession{user: {:ref, _, id}} -> id
      %NoizuPromptLingua.Users.Sessions.UserSession{user: %{id: id}} -> id
      _ -> nil
    end
  end
end
