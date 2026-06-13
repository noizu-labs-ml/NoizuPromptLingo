defmodule NoizuPromptLingua.Token do
  @thirty_days 30 * 24 * 3600

  defp jwk, do: JOSE.JWK.from_oct(NoizuPromptLingua.MCPAuth.secret())

  def mint(%{id: user_id, email: email, name: name}, %{id: api_key_id}) do
    now = System.system_time(:second)

    claims = %{
      "sub" => user_id,
      "email" => email,
      "name" => name,
      "api_key_id" => api_key_id,
      "iss" => "tobor-locker",
      "iat" => now,
      "exp" => now + @thirty_days
    }

    {_, token} = JOSE.JWT.sign(jwk(), %{"alg" => "HS256"}, claims) |> JOSE.JWS.compact()
    {:ok, token, DateTime.from_unix!(now + @thirty_days)}
  end
end
