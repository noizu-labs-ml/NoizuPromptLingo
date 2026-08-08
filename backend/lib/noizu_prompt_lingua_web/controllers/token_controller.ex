defmodule NoizuPromptLinguaWeb.TokenController do
  use NoizuPromptLinguaWeb, :controller

  @moduledoc """
  Mints an MCP JWT from a valid API key.

  The caller must present the **raw** API key (the secret shown once at
  creation). We bcrypt-verify it against the stored hash, and the token's
  identity (user, email) is taken from the verified key's owner row — never
  from request-supplied ids. Knowing a key's UUID is not enough; possession
  of the secret is required.

  Optional body fields (Phase 0):
  - `resource` or `aud` — RFC 8707 audience binding (MCP resource URL)
  """

  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCP.LegacyKeys

  def create(conn, params) do
    if not LegacyKeys.mint_enabled?() do
      conn
      |> put_status(:gone)
      |> json(LegacyKeys.disabled_response())
    else
      do_create(conn, params)
    end
  end

  defp do_create(conn, params) do
    raw_key = params["key"]
    resource = params["resource"] || params["aud"]

    cond do
      not is_binary(raw_key) or raw_key == "" ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "key required"})

      true ->
        case MCPApiKeys.verify_api_key(raw_key) do
          nil ->
            conn
            |> put_status(:unauthorized)
            |> json(%{error: "invalid or expired API key"})

          api_key ->
            user = %{id: api_key.user_id, email: api_key.user.email, name: api_key.user.user_name}

            mint_opts =
              if is_binary(resource) and resource != "" do
                [resource: resource]
              else
                []
              end

            {:ok, token, expires_at} = NoizuPromptLingua.Token.mint(user, api_key, mint_opts)

            json(conn, %{
              token: token,
              expires_at: DateTime.to_iso8601(expires_at),
              token_type: "Bearer",
              expires_in: max(DateTime.diff(expires_at, DateTime.utc_now()), 0)
            })
        end
    end
  end
end
