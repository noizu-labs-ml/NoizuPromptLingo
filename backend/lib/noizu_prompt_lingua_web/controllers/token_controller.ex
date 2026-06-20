defmodule NoizuPromptLinguaWeb.TokenController do
  use NoizuPromptLinguaWeb, :controller

  @moduledoc """
  Mints a short-lived MCP JWT from a valid API key.

  The caller must present the **raw** API key (the secret shown once at
  creation). We bcrypt-verify it against the stored hash, and the token's
  identity (user, email) is taken from the verified key's owner row — never
  from request-supplied ids. Knowing a key's UUID is not enough; possession
  of the secret is required.
  """

  alias NoizuPromptLingua.MCPApiKeys

  def create(conn, %{"key" => raw_key}) when is_binary(raw_key) and raw_key != "" do
    case MCPApiKeys.verify_api_key(raw_key) do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "invalid or expired API key"})

      api_key ->
        user = %{id: api_key.user_id, email: api_key.user.email, name: api_key.user.user_name}
        {:ok, token, expires_at} = NoizuPromptLingua.Token.mint(user, api_key)
        json(conn, %{token: token, expires_at: DateTime.to_iso8601(expires_at)})
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "key required"})
  end
end
