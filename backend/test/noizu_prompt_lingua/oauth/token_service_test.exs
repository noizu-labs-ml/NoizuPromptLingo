defmodule NoizuPromptLingua.OAuth.TokenServiceTest do
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.OAuth.{Clients, Grants, TokenService, Pkce}
  alias NoizuPromptLingua.MCP.DualTokenVerifier
  alias NoizuPromptLingua.OAuth.Jwks

  setup do
    Jwks.reset!()
    NoizuPromptLingua.OAuthTestSchema.ensure!()

    uniq = System.unique_integer([:positive])

    user =
      %NoizuPromptLingua.Schema.Users.User{
        id: Ecto.UUID.generate(),
        email: "oauth-#{uniq}@example.com",
        user_name: "oauth#{uniq}",
        handle: "oauth#{uniq}",
        status: :active,
        verified: true,
        flagged: false
      }
      |> NoizuPromptLingua.Repo.insert!()

    {:ok, reg} =
      Clients.register(%{
        "client_name" => "test-cli",
        "redirect_uris" => ["http://127.0.0.1:9876/callback"],
        "token_endpoint_auth_method" => "none"
      })

    client = Clients.get_active(reg["client_id"])
    %{user: user, client: client, reg: reg}
  end

  test "authorization_code + PKCE → access + refresh; refresh rotates", %{
    user: user,
    client: client
  } do
    resource = "https://tobor.locker/mcp"
    grant = Grants.approve!(user.id, client.client_id, resource, "mcp")

    verifier = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
    challenge = :crypto.hash(:sha256, verifier) |> Base.url_encode64(padding: false)

    code =
      TokenService.issue_code!(%{
        client_id: client.client_id,
        user_id: user.id,
        redirect_uri: "http://127.0.0.1:9876/callback",
        resource: resource,
        scope: "mcp",
        code_challenge: challenge,
        grant_id: grant.grant_id
      })

    assert {:ok, tokens} =
             TokenService.exchange_code(%{
               "grant_type" => "authorization_code",
               "code" => code,
               "redirect_uri" => "http://127.0.0.1:9876/callback",
               "client_id" => client.client_id,
               "code_verifier" => verifier
             })

    assert is_binary(tokens.access_token)
    assert is_binary(tokens.refresh_token)
    assert tokens.token_type == "Bearer"
    assert tokens.expires_in > 0

    # Access token verifies via DualTokenVerifier (no api_key_id)
    assert {:ok, claims} =
             DualTokenVerifier.verify(
               tokens.access_token,
               %{method: "POST", peer: nil, headers: [{"host", "tobor.locker"}]},
               secret: fn -> "unused" end,
               issuer: NoizuPromptLingua.OAuth.AuthorizationServer.jwt_issuers(),
               validate_api_key: fn _ -> true end,
               require_aud: true,
               public_scheme: "https"
             )

    assert claims["aud"] == resource
    assert claims["grant_id"] == grant.grant_id
    assert String.starts_with?(claims["sub"], "user:")

    # Code is single-use
    assert {:error, :invalid_grant} =
             TokenService.exchange_code(%{
               "grant_type" => "authorization_code",
               "code" => code,
               "redirect_uri" => "http://127.0.0.1:9876/callback",
               "client_id" => client.client_id,
               "code_verifier" => verifier
             })

    assert {:ok, tokens2} =
             TokenService.refresh(%{
               "grant_type" => "refresh_token",
               "refresh_token" => tokens.refresh_token,
               "client_id" => client.client_id
             })

    assert tokens2.refresh_token != tokens.refresh_token

    # Old refresh revoked
    assert {:error, :invalid_grant} =
             TokenService.refresh(%{
               "grant_type" => "refresh_token",
               "refresh_token" => tokens.refresh_token,
               "client_id" => client.client_id
             })
  end

  test "PKCE mismatch fails", %{user: user, client: client} do
    grant = Grants.approve!(user.id, client.client_id, "https://tobor.locker/mcp")
    verifier = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
    challenge = :crypto.hash(:sha256, verifier) |> Base.url_encode64(padding: false)

    code =
      TokenService.issue_code!(%{
        client_id: client.client_id,
        user_id: user.id,
        redirect_uri: "http://127.0.0.1:9876/callback",
        resource: "https://tobor.locker/mcp",
        scope: "mcp",
        code_challenge: challenge,
        grant_id: grant.grant_id
      })

    assert {:error, :invalid_grant} =
             TokenService.exchange_code(%{
               "code" => code,
               "redirect_uri" => "http://127.0.0.1:9876/callback",
               "client_id" => client.client_id,
               "code_verifier" => "wrong-verifier-value-that-is-long-enough"
             })
  end

  test "DCR rejects disallowed redirect", %{} do
    assert {:error, :invalid_redirect_uri} =
             Clients.register(%{
               "client_name" => "evil",
               "redirect_uris" => ["https://evil.example/cb"]
             })
  end
end
