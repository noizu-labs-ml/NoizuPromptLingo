defmodule NoizuPromptLinguaWeb.AuthzMembershipController do
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Authz.ScopedMemberships

  def my_memberships(conn, _params) do
    user_id = get_user_id(conn)
    memberships = ScopedMemberships.list_for_user(user_id)
    json(conn, %{memberships: memberships})
  end

  # Canonical members READ (viewer-gated PBAC path the FE consolidates onto — marcus
  # seq637). Rows carry scope + member_type + canonical role (list_for_resource, 4a9aa9d9)
  # + an optional role facet (?role[]=) + the caller's effective_role per row (16dc3df2,
  # one lookup — no N+1) for the FE's advisory per-row gates.
  def org_members(conn, %{"org_id" => org_id} = params) do
    user_id = get_user_id(conn)

    case NoizuPromptLingua.Authz.authorize(user_id, "organization", org_id, "viewer") do
      {:ok, _} ->
        caller_role = NoizuPromptLingua.Authz.get_user_role(user_id, "organization", org_id)

        members =
          "organization"
          |> ScopedMemberships.list_for_resource(org_id, role: params["role"])
          |> Enum.map(&Map.put(&1, :effective_role, caller_role))

        json(conn, %{members: members})

      {:error, :not_a_member} ->
        conn |> put_status(:forbidden) |> json(%{error: "Not a member of this organization"})

      {:error, _} ->
        conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})
    end
  end

  # getMember (4a9aa9d9): a single org membership by id, same shape + effective_role.
  def org_member(conn, %{"org_id" => org_id, "id" => id}) do
    user_id = get_user_id(conn)

    case NoizuPromptLingua.Authz.authorize(user_id, "organization", org_id, "viewer") do
      {:ok, _} ->
        case ScopedMemberships.get_membership(id) do
          %{resource_type: "organization", resource_id: ^org_id} = member ->
            caller_role = NoizuPromptLingua.Authz.get_user_role(user_id, "organization", org_id)
            json(conn, %{member: Map.put(member, :effective_role, caller_role)})

          _ ->
            conn |> put_status(:not_found) |> json(%{error: "Member not found"})
        end

      _ ->
        conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})
    end
  end

  def project_members(conn, %{"project_id" => project_id} = params) do
    user_id = get_user_id(conn)

    if NoizuPromptLingua.Authz.check_permission(user_id, "project", project_id, "project:view") do
      caller_role = NoizuPromptLingua.Authz.get_user_role(user_id, "project", project_id)

      members =
        "project"
        |> ScopedMemberships.list_for_resource(project_id, role: params["role"])
        |> Enum.map(&Map.put(&1, :effective_role, caller_role))

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
