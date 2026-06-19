defmodule NoizuPromptLinguaWeb.MembershipController do
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Authz.ScopedMemberships

  def index(conn, %{"org_id" => org_id}) do
    members = ScopedMemberships.list_for_resource("organization", org_id)
    conn |> put_status(:ok) |> json(%{members: members})
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

      {:error, :sole_owner} ->
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
