defmodule NoizuPromptLinguaWeb.OAuthConnectionsController do
  use NoizuPromptLinguaWeb, :controller

  @moduledoc "List/revoke OAuth MCP pairing grants for the current user."

  alias NoizuPromptLingua.OAuth.Grants
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Users.User

  def index(conn, _params) do
    user = current_user!(conn)

    grants =
      Grants.list_for_user(user.id)
      |> Enum.map(fn g ->
        %{
          grant_id: g.grant_id,
          client_id: g.client_id,
          resource: g.resource,
          scope: g.scope,
          status: g.status,
          inserted_at: g.inserted_at,
          expires_at: g.expires_at
        }
      end)

    json(conn, %{connections: grants})
  end

  def revoke(conn, %{"grant_id" => grant_id}) do
    user = current_user!(conn)

    case Grants.get_active(grant_id) do
      nil ->
        conn |> put_status(:not_found) |> json(%{error: "not_found"})

      grant ->
        if grant.user_id == user.id do
          {:ok, _} = Grants.revoke!(grant_id)
          json(conn, %{ok: true, grant_id: grant_id, status: "revoked"})
        else
          conn |> put_status(:not_found) |> json(%{error: "not_found"})
        end
    end
  end

  defp current_user!(conn) do
    session = NoizuPromptLingua.Guardian.Plug.current_resource(conn)

    user_id =
      case session do
        %{user: {:ref, _, id}} -> id
        %{user: %{} = u} -> u.id
        _ -> nil
      end

    Repo.get!(User, user_id)
  end
end
