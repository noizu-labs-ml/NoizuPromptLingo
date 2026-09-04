defmodule NoizuPromptLinguaWeb.MembershipController do
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Authz.ScopedMemberships

  def index(conn, %{"org_id" => org_id} = params) do
    # ADR-015 affordance echo (16dc3df2): each member row also carries the CALLER's
    # effective_role in this org (constant per org, one lookup — no N+1), so the FE can
    # gate per-row actions (lead/admin moderation) against caller-rank vs the row's
    # target role. Advisory only; the RBAC guard stays the deny-closed boundary.
    # Row shape is PBAC scoped_memberships (4a9aa9d9): scope + member_type + canonical role.
    caller_role = NoizuPromptLingua.Authz.get_user_role(get_user_id(conn), "organization", org_id)

    members =
      "organization"
      |> ScopedMemberships.list_for_resource(org_id, role: params["role"])
      |> Enum.map(&Map.put(&1, :effective_role, caller_role))

    conn |> put_status(:ok) |> json(%{members: members})
  end

  # GET /api/v1/organizations/:org_id/members/:id — single membership (getMember, 4a9aa9d9).
  def show(conn, %{"org_id" => org_id, "id" => id}) do
    case ScopedMemberships.get_membership(id) do
      %{resource_type: "organization", resource_id: ^org_id} = member ->
        caller_role =
          NoizuPromptLingua.Authz.get_user_role(get_user_id(conn), "organization", org_id)

        conn |> put_status(:ok) |> json(%{member: Map.put(member, :effective_role, caller_role)})

      _ ->
        conn |> put_status(:not_found) |> json(%{error: "Member not found"})
    end
  end

  def create(conn, %{"org_id" => org_id, "email" => email} = params) do
    role = Map.get(params, "role", "viewer")
    user_id = find_user_id_by_email(email)
    inviter_id = get_user_id(conn)

    case user_id do
      nil ->
        conn |> put_status(:not_found) |> json(%{error: "User not found"})

      uid ->
        case ScopedMemberships.add_member("organization", org_id, uid, role, inviter_id) do
          {:ok, _membership} ->
            members = ScopedMemberships.list_for_resource("organization", org_id)
            conn |> put_status(:created) |> json(%{members: members})

          {:error, :already_member} ->
            conn |> put_status(:conflict) |> json(%{error: "User is already a member"})

          {:error, :invalid_role} ->
            conn |> put_status(:bad_request) |> json(%{error: "Invalid role"})

          {:error, reason} ->
            conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
        end
    end
  end

  def update(conn, %{"org_id" => org_id, "id" => member_user_id, "role" => role}) do
    case ScopedMemberships.update_role("organization", org_id, member_user_id, role) do
      {:ok, _membership} ->
        members = ScopedMemberships.list_for_resource("organization", org_id)
        conn |> put_status(:ok) |> json(%{members: members})

      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Member not found"})

      {:error, reason} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
    end
  end

  def delete(conn, %{"org_id" => org_id, "id" => member_user_id}) do
    case ScopedMemberships.remove_member("organization", org_id, member_user_id) do
      {:ok, _} ->
        conn |> put_status(:ok) |> json(%{message: "Member removed"})

      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Member not found"})

      # ScopedMemberships flags the final owner as :last_owner; both spellings
      # mean the same guard (cov-w5a bugfix: :last_owner fell through to a
      # CaseClauseError 500 instead of the owner-protection 403).
      {:error, reason} when reason in [:sole_owner, :last_owner] ->
        conn |> put_status(:forbidden) |> json(%{error: "Cannot remove the owner"})
    end
  end

  defp get_user_id(conn) do
    case NoizuPromptLingua.Guardian.Plug.current_resource(conn) do
      %NoizuPromptLingua.Users.Sessions.UserSession{user: {:ref, _, id}} -> id
      %NoizuPromptLingua.Users.Sessions.UserSession{user: %{id: id}} -> id
      _ -> nil
    end
  end

  defp find_user_id_by_email(email) do
    import Ecto.Query
    alias NoizuPromptLingua.Schema.Users.User, as: UserSchema

    case NoizuPromptLingua.Repo.one(from u in UserSchema, where: u.email == ^email, select: u.id) do
      nil -> nil
      id -> id
    end
  end
end
