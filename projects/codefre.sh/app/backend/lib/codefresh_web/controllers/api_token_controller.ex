defmodule CodefreshWeb.ApiTokenController do
  use CodefreshWeb, :controller

  alias Codefresh.{ApiTokens, Organizations}
  alias Codefresh.Guardian

  def index(conn, %{"organization_id" => org_id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "admin") do
      tokens = ApiTokens.list_tokens(org_id)
      json(conn, %{tokens: Enum.map(tokens, &render_token/1)})
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def create(conn, %{"organization_id" => org_id, "token" => token_params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "admin") do
      attrs =
        token_params
        |> Map.put("organization_id", org_id)
        |> Map.put("created_by_user_id", user.id)

      case ApiTokens.create_token(attrs) do
        {:ok, token, raw} ->
          conn
          |> put_status(:created)
          |> json(%{
            token: render_token(token),
            raw_token: raw,
            note: "raw_token shown once — store immediately; recovery is impossible"
          })

        {:error, cs} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: CodefreshWeb.ChangesetJSON.errors(cs)})
      end
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Expected {token: {name, role, expires_at?}}"})
  end

  def revoke(conn, %{"organization_id" => org_id, "id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "admin"),
         token when not is_nil(token) <- safe_get_token(id, org_id) do
      case ApiTokens.revoke_token(token) do
        {:ok, updated} -> json(conn, %{token: render_token(updated)})
        {:error, _} -> send_resp(conn, 422, "")
      end
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def rotate(conn, %{"organization_id" => org_id, "id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "admin"),
         old when not is_nil(old) <- safe_get_token(id, org_id) do
      case ApiTokens.rotate_token(old) do
        {:ok, new_token, raw} ->
          conn
          |> put_status(:created)
          |> json(%{
            token: render_token(new_token),
            raw_token: raw,
            note: "old token revoked; raw_token shown once"
          })

        {:error, cs} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: CodefreshWeb.ChangesetJSON.errors(cs)})
      end
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  defp render_token(t) do
    %{
      id: t.id,
      name: t.name,
      role: t.role,
      key_prefix: t.key_prefix,
      expires_at: t.expires_at,
      last_used_at: t.last_used_at,
      revoked_at: t.revoked_at,
      created_at: t.inserted_at
    }
  end

  defp safe_get_token(id, org_id) do
    case Codefresh.Repo.get(Codefresh.Accounts.ApiToken, id) do
      %Codefresh.Accounts.ApiToken{organization_id: ^org_id} = t -> t
      _ -> nil
    end
  rescue
    Ecto.Query.CastError -> nil
  end
end
