defmodule NoizuPromptLinguaWeb.AuthzMembershipController do
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Authz.ScopedMemberships

  def my_memberships(conn, _params) do
    user_id = get_user_id(conn)
    memberships = ScopedMemberships.list_for_user(user_id)
    json(conn, %{memberships: memberships})
  end

  def org_members(conn, %{"org_id" => org_id}) do
    user_id = get_user_id(conn)

    case NoizuPromptLingua.Authz.authorize(user_id, "organization", org_id, "viewer") do
      {:ok, _} ->
        members = ScopedMemberships.list_for_resource("organization", org_id)
        json(conn, %{members: members})

      {:error, :not_a_member} ->
        conn |> put_status(:forbidden) |> json(%{error: "Not a member of this organization"})

      {:error, _} ->
        conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})
    end
  end

  def project_members(conn, %{"project_id" => project_id}) do
    user_id = get_user_id(conn)

    if NoizuPromptLingua.Authz.check_permission(user_id, "project", project_id, "project:view") do
      members = ScopedMemberships.list_for_resource("project", project_id)
      json(conn, %{members: members})
    else
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
