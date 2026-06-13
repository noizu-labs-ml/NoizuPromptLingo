defmodule CodefreshWeb.InviteController do
  use CodefreshWeb, :controller

  alias Codefresh.{Accounts, Organizations}
  alias Codefresh.Accounts.Membership
  alias Codefresh.Guardian

  @invitable_roles ~w(admin editor viewer ci)

  def index(conn, %{"organization_id" => org_id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "admin") do
      invites = Accounts.list_active_invites_for_org(org_id)

      json(conn, %{
        invites:
          Enum.map(invites, fn i ->
            %{
              id: i.id,
              email: i.email,
              role: i.role,
              expires_at: i.expires_at,
              max_uses: i.max_uses,
              use_count: i.use_count,
              key_prefix: i.key_prefix
            }
          end)
      })
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def create(conn, %{"organization_id" => org_id, "invite" => invite_params}) do
    user = Guardian.Plug.current_resource(conn)
    requested_role = invite_params["role"]

    with {:ok, granter_role} <- Organizations.authorize(user, org_id, "admin"),
         :ok <- validate_requested_role(requested_role, granter_role),
         email when is_binary(email) and email != "" <- invite_params["email"] do
      case Accounts.get_user_by_email(email) do
        nil ->
          issue_invite(conn, org_id, user.id, invite_params)

        existing_user ->
          create_membership_directly(conn, org_id, existing_user.id, requested_role)
      end
    else
      {:error, :forbidden} ->
        send_resp(conn, 403, "")

      {:error, :not_a_member} ->
        send_resp(conn, 404, "")

      {:error, :owner_requires_owner} ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "Only owners can grant the owner role"})

      {:error, :invalid_role} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          error:
            "role must be one of: #{Enum.join(@invitable_roles, ", ")} (or owner if granter is owner)"
        })

      _ ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "email is required"})
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Expected {invite: {email, role, expires_at?, max_uses?, metadata?}}"})
  end

  def revoke(conn, %{"organization_id" => org_id, "id" => invite_id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "admin"),
         invite when not is_nil(invite) <- safe_get_invite(invite_id, org_id) do
      case Accounts.revoke_invite_token(invite) do
        {:ok, _} -> send_resp(conn, 204, "")
        {:error, _} -> send_resp(conn, 422, "")
      end
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  defp issue_invite(conn, org_id, inviter_user_id, params) do
    expires_at =
      case params["expires_at"] do
        nil ->
          DateTime.utc_now()
          |> DateTime.add(14 * 24 * 3600, :second)
          |> DateTime.truncate(:second)

        %DateTime{} = dt ->
          dt

        str when is_binary(str) ->
          case DateTime.from_iso8601(str) do
            {:ok, dt, _} -> DateTime.truncate(dt, :second)
            _ -> nil
          end
      end

    attrs = %{
      organization_id: org_id,
      email: params["email"],
      role: params["role"],
      invited_by_user_id: inviter_user_id,
      max_uses: params["max_uses"] || 1,
      expires_at: expires_at,
      metadata: params["metadata"] || %{}
    }

    case Accounts.create_invite_token(attrs) do
      {:ok, invite, raw_token} ->
        conn
        |> put_status(:created)
        |> json(%{
          invite: %{
            id: invite.id,
            email: invite.email,
            role: invite.role,
            expires_at: invite.expires_at,
            max_uses: invite.max_uses,
            key_prefix: invite.key_prefix
          },
          raw_token: raw_token,
          note: "raw_token shown once — deliver to invitee out-of-band"
        })

      {:error, cs} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: CodefreshWeb.ChangesetJSON.errors(cs)})
    end
  end

  defp create_membership_directly(conn, org_id, user_id, role) do
    case Accounts.create_membership(%{
           organization_id: org_id,
           user_id: user_id,
           role: role
         }) do
      {:ok, m} ->
        conn
        |> put_status(:created)
        |> json(%{
          membership: %{
            id: m.id,
            organization_id: m.organization_id,
            user_id: m.user_id,
            role: m.role
          }
        })

      {:error, cs} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: CodefreshWeb.ChangesetJSON.errors(cs)})
    end
  end

  defp validate_requested_role("owner", "owner"), do: :ok
  defp validate_requested_role("owner", _), do: {:error, :owner_requires_owner}
  defp validate_requested_role(role, _) when role in @invitable_roles, do: :ok
  defp validate_requested_role(_, _), do: {:error, :invalid_role}

  defp safe_get_invite(id, org_id) do
    case Codefresh.Repo.get(Codefresh.Accounts.InviteToken, id) do
      %Codefresh.Accounts.InviteToken{organization_id: ^org_id} = invite -> invite
      _ -> nil
    end
  rescue
    Ecto.Query.CastError -> nil
  end

  # suppress unused-alias warning
  _ = Membership
end
