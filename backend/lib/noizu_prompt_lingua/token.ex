defmodule NoizuPromptLingua.Token do
  @moduledoc """
  Mints short-lived MCP JWTs from a user + API key.

  Ported from the legacy project. The token binds the user (sub/email/name) and
  the API key that authorized it (api_key_id), signed HS256 with the shared
  MCP/Guardian secret, valid for 30 days. Verification is performed by the MCP
  gateway's CompoundJWTVerifier (not here).
  """

  @thirty_days 30 * 24 * 3600
  @issuer "tobor-locker"

  defp jwk, do: JOSE.JWK.from_oct(NoizuPromptLingua.MCPAuth.secret())

  def mint(%{id: user_id, email: email, name: name}, %{id: api_key_id}) do
    now = System.system_time(:second)

    claims = %{
      "sub" => to_string(user_id),
      "email" => email,
      "name" => name,
      "api_key_id" => to_string(api_key_id),
      "iss" => @issuer,
      "iat" => now,
      "exp" => now + @thirty_days
    }

    {_, token} = JOSE.JWT.sign(jwk(), %{"alg" => "HS256"}, claims) |> JOSE.JWS.compact()
    {:ok, token, DateTime.from_unix!(now + @thirty_days)}
  end

  def issuer, do: @issuer
end
