defmodule NPLWeb.TokenController do
  use NPLWeb, :controller

  def create(conn, %{"key_id" => key_id, "user_id" => user_id, "email" => user_email} = params) do
    user_name = params["name"]

    case NoizuPromptLingua.Auth.get_active_key(key_id, user_id) do
      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> json(%{error: "key not found or not owned by user"})

      %{} = api_key ->
        user = %{id: user_id, email: user_email, name: user_name}
        {:ok, token, expires_at} = NoizuPromptLingua.Token.mint(user, api_key)
        json(conn, %{token: token, expires_at: DateTime.to_iso8601(expires_at)})
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(400)
    |> json(%{error: "key_id, user_id, and email required"})
  end
end
