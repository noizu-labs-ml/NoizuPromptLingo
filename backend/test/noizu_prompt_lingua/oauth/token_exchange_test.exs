defmodule NoizuPromptLingua.OAuth.TokenExchangeTest do
  @moduledoc """
  RFC 8693 token exchange (`NoizuPromptLingua.OAuth.TokenExchange.exchange/1`).

  Branch map: client resolution + auth (public vs confidential), grant-type
  allow-list, subject_token presence/type, resource binding (`resource` /
  `audience`), subject-token verification (signature, expiry, issuer, user
  resolution via `user_id` / `user:`-prefixed / bare-UUID sub), grant
  resolution (claim grant_id, standing grant, auto-approve), `act` chain
  construction, and the minted delegated-token shape.

  Security posture (pinned, see coverage report):

    * F2 — a minted delegated (`token_use=mcp_access`) token can itself be
      exchanged for a fresh 5-minute delegated token, so a delegated token is
      indefinitely renewable by its holder (act chain nests, TTL restarts).
    * F3 — the subject token's `aud` is not bound to the requested
      `resource` at exchange time (`require_aud: false`, no expected_aud).
  """

  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.OAuth.{AuthorizationServer, Clients, Grants, TokenExchange}
  alias NoizuPromptLingua.OAuth.Jwks
  alias NoizuPromptLingua.MCP.DualTokenVerifier
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.McpPairingGrant
  alias NoizuPromptLingua.Schema.Users.User

  @grant_type "urn:ietf:params:oauth:grant-type:token-exchange"
  @access_token_type "urn:ietf:params:oauth:token-type:access_token"
  @resource "https://sessions.tobor.locker/mcp"

  setup do
    Jwks.reset!()
    NoizuPromptLingua.OAuthTestSchema.ensure!()

    uniq = System.unique_integer([:positive])

    user =
      %User{
        id: Ecto.UUID.generate(),
        email: "tex-#{uniq}@example.com",
        user_name: "tex#{uniq}",
        handle: "tex#{uniq}",
        status: :active,
        verified: true,
        flagged: false
      }
      |> Repo.insert!()

    {:ok, reg} =
      Clients.register(%{
        "client_name" => "exchange-cli",
        "redirect_uris" => ["http://127.0.0.1:9876/callback"],
        "token_endpoint_auth_method" => "none"
      })

    client = Clients.get_active(reg["client_id"])

    {:ok, user: user, client: client, client_id: reg["client_id"]}
  end

  # ── helpers ────────────────────────────────────────────────────────────────

  defp rs256_token(claims) do
    entry = Jwks.signing_entry()
    header = %{"alg" => entry.alg, "kid" => entry.kid, "typ" => "JWT"}
    {_, token} = JOSE.JWT.sign(entry.jwk, header, claims) |> JOSE.JWS.compact()
    token
  end

  defp subject_claims(user, extra \\ %{}) do
    now = System.system_time(:second)

    Map.merge(
      %{
        "iss" => hd(AuthorizationServer.jwt_issuers()),
        "sub" => "user:#{user.id}",
        "user_id" => user.id,
        "iat" => now,
        "exp" => now + 300,
        "scope" => "mcp"
      },
      extra
    )
  end

  defp subject(user, extra \\ %{}), do: rs256_token(subject_claims(user, extra))

  defp hs256_token(claims) do
    jwk = JOSE.JWK.from_oct(NoizuPromptLingua.MCPAuth.secret())
    {_, token} = JOSE.JWT.sign(jwk, %{"alg" => "HS256"}, claims) |> JOSE.JWS.compact()
    token
  end

  defp exchange(params), do: TokenExchange.exchange(params)

  defp exchange_ok(user, client_id, extra \\ %{}) do
    params =
      Map.merge(
        %{
          "client_id" => client_id,
          "subject_token" => subject(user),
          "resource" => @resource
        },
        extra
      )

    assert {:ok, result} = exchange(params)
    result
  end

  defp peek_claims(token) do
    %JOSE.JWT{fields: claims} = JOSE.JWT.peek_payload(token)
    claims
  end

  defp verifier_opts do
    [
      secret: {NoizuPromptLingua.MCPAuth, :secret},
      issuer: AuthorizationServer.jwt_issuers(),
      validate_api_key: fn _ -> true end,
      require_aud: false
    ]
  end

  # ── contract surface ──────────────────────────────────────────────────────

  test "grant_type/0 is the RFC 8693 URN" do
    assert TokenExchange.grant_type() == @grant_type
  end

  test "non-map params are invalid_request" do
    assert exchange("not-a-map") == {:error, :invalid_request}
    assert exchange(nil) == {:error, :invalid_request}
  end

  # ── client resolution + auth ──────────────────────────────────────────────

  test "missing client_id is invalid_client", %{user: user} do
    assert exchange(%{"subject_token" => subject(user), "resource" => @resource}) ==
             {:error, :invalid_client}
  end

  test "unknown client_id is invalid_client", %{user: user} do
    assert exchange(%{
             "client_id" => "dcr_missing",
             "subject_token" => subject(user),
             "resource" => @resource
           }) == {:error, :invalid_client}
  end

  test "non-binary client_id is invalid_client", %{user: user} do
    assert exchange(%{
             "client_id" => 42,
             "subject_token" => subject(user),
             "resource" => @resource
           }) == {:error, :invalid_client}
  end

  test "confidential client with wrong secret is invalid_client", %{user: user} do
    {:ok, reg} =
      Clients.register(%{
        "client_name" => "confidential",
        "redirect_uris" => ["http://127.0.0.1:9876/callback"],
        "token_endpoint_auth_method" => "client_secret_post"
      })

    assert is_binary(reg["client_secret"])

    assert exchange(%{
             "client_id" => reg["client_id"],
             "client_secret" => "wrong-secret",
             "subject_token" => subject(user),
             "resource" => @resource
           }) == {:error, :invalid_client}
  end

  test "confidential client with correct secret exchanges", %{user: user} do
    {:ok, reg} =
      Clients.register(%{
        "client_name" => "confidential",
        "redirect_uris" => ["http://127.0.0.1:9876/callback"],
        "token_endpoint_auth_method" => "client_secret_post"
      })

    assert {:ok, _} =
             exchange(%{
               "client_id" => reg["client_id"],
               "client_secret" => reg["client_secret"],
               "subject_token" => subject(user),
               "resource" => @resource
             })
  end

  test "client without exchange or authorization_code grant type is unauthorized_client", %{
    user: user
  } do
    client =
      Clients.create_first_party!(client_name: "no-exchange", grant_types: ["refresh_token"])

    assert exchange(%{
             "client_id" => client.client_id,
             "subject_token" => subject(user),
             "resource" => @resource
           }) == {:error, :unauthorized_client}
  end

  # ── subject_token presence + token_type ───────────────────────────────────

  test "missing subject_token is invalid_request", %{client_id: client_id} do
    assert exchange(%{"client_id" => client_id, "resource" => @resource}) ==
             {:error, :invalid_request}
  end

  test "non-binary subject_token is invalid_request", %{client_id: client_id} do
    assert exchange(%{
             "client_id" => client_id,
             "subject_token" => 42,
             "resource" => @resource
           }) == {:error, :invalid_request}
  end

  test "subject_token_type full URN and short form both accepted", %{user: user, client_id: cid} do
    assert {:ok, _} =
             exchange(%{
               "client_id" => cid,
               "subject_token" => subject(user),
               "subject_token_type" => @access_token_type,
               "resource" => @resource
             })

    assert {:ok, _} =
             exchange(%{
               "client_id" => cid,
               "subject_token" => subject(user),
               "subject_token_type" => "access_token",
               "resource" => @resource
             })
  end

  test "foreign subject_token_type is invalid_request", %{user: user, client_id: cid} do
    assert exchange(%{
             "client_id" => cid,
             "subject_token" => subject(user),
             "subject_token_type" => "urn:ietf:params:oauth:token-type:refresh_token",
             "resource" => @resource
           }) == {:error, :invalid_request}
  end

  # ── resource binding ──────────────────────────────────────────────────────

  test "missing resource and audience is invalid_request", %{user: user, client_id: cid} do
    assert exchange(%{"client_id" => cid, "subject_token" => subject(user)}) ==
             {:error, :invalid_request}
  end

  test "empty-string resource is invalid_request", %{user: user, client_id: cid} do
    assert exchange(%{
             "client_id" => cid,
             "subject_token" => subject(user),
             "resource" => ""
           }) == {:error, :invalid_request}
  end

  test "non-binary resource is invalid_request", %{user: user, client_id: cid} do
    assert exchange(%{
             "client_id" => cid,
             "subject_token" => subject(user),
             "resource" => 42
           }) == {:error, :invalid_request}
  end

  test "audience parameter satisfies the resource requirement and becomes aud", %{
    user: user,
    client_id: cid
  } do
    assert {:ok, result} =
             exchange(%{
               "client_id" => cid,
               "subject_token" => subject(user),
               "audience" => "https://aud.example/mcp"
             })

    assert peek_claims(result.access_token)["aud"] == "https://aud.example/mcp"
  end

  test "explicit resource wins over audience", %{user: user, client_id: cid} do
    assert {:ok, result} =
             exchange(%{
               "client_id" => cid,
               "subject_token" => subject(user),
               "resource" => @resource,
               "audience" => "https://aud.example/mcp"
             })

    assert peek_claims(result.access_token)["aud"] == @resource
  end

  # ── subject-token verification (adversarial) ──────────────────────────────

  test "garbage subject_token is invalid_grant", %{client_id: cid} do
    assert exchange(%{
             "client_id" => cid,
             "subject_token" => "garbage",
             "resource" => @resource
           }) == {:error, :invalid_grant}
  end

  test "expired subject_token is invalid_grant", %{user: user, client_id: cid} do
    expired =
      subject(user, %{"exp" => System.system_time(:second) - 10, "iat" => now() - 400})

    assert exchange(%{"client_id" => cid, "subject_token" => expired, "resource" => @resource}) ==
             {:error, :invalid_grant}
  end

  test "foreign issuer is invalid_grant", %{user: user, client_id: cid} do
    assert exchange(%{
             "client_id" => cid,
             "subject_token" => subject(user, %{"iss" => "https://evil.example"}),
             "resource" => @resource
           }) == {:error, :invalid_grant}
  end

  test "subject_token without iss is invalid_grant", %{user: user, client_id: cid} do
    claims = Map.delete(subject_claims(user), "iss")

    assert exchange(%{
             "client_id" => cid,
             "subject_token" => rs256_token(claims),
             "resource" => @resource
           }) == {:error, :invalid_grant}
  end

  test "subject_token signed by an unknown key is invalid_grant", %{user: user, client_id: cid} do
    rogue_jwk = JOSE.JWK.generate_key({:rsa, 2048})

    {_, rogue} =
      JOSE.JWT.sign(rogue_jwk, %{"alg" => "RS256"}, subject_claims(user))
      |> JOSE.JWS.compact()

    assert exchange(%{"client_id" => cid, "subject_token" => rogue, "resource" => @resource}) ==
             {:error, :invalid_grant}
  end

  test "subject_token for an unknown user is invalid_grant", %{client_id: cid} do
    ghost = %User{id: Ecto.UUID.generate(), email: nil, user_name: nil}

    assert exchange(%{
             "client_id" => cid,
             "subject_token" => subject(ghost),
             "resource" => @resource
           }) == {:error, :invalid_grant}
  end

  test "user: prefixed sub without a backing user is invalid_grant", %{client_id: cid} do
    claims =
      subject_claims(%User{id: Ecto.UUID.generate()})
      |> Map.delete("user_id")

    assert exchange(%{
             "client_id" => cid,
             "subject_token" => rs256_token(claims),
             "resource" => @resource
           }) == {:error, :invalid_grant}
  end

  # ── user resolution claim shapes ──────────────────────────────────────────

  test "user_id claim resolves the user", %{user: user, client_id: cid} do
    assert {:ok, _} =
             exchange(%{
               "client_id" => cid,
               "subject_token" => subject(user),
               "resource" => @resource
             })
  end

  test "user:-prefixed sub resolves without user_id claim", %{user: user, client_id: cid} do
    claims = subject_claims(user) |> Map.delete("user_id")

    assert {:ok, result} =
             exchange(%{
               "client_id" => cid,
               "subject_token" => rs256_token(claims),
               "resource" => @resource
             })

    assert peek_claims(result.access_token)["sub"] == "user:#{user.id}"
  end

  test "bare-UUID sub (legacy API-key shape) resolves without user_id claim", %{
    user: user,
    client_id: cid
  } do
    claims =
      subject_claims(user)
      |> Map.delete("user_id")
      |> Map.put("sub", to_string(user.id))

    assert {:ok, result} =
             exchange(%{
               "client_id" => cid,
               "subject_token" => rs256_token(claims),
               "resource" => @resource
             })

    assert peek_claims(result.access_token)["sub"] == "user:#{user.id}"
  end

  test "bare-UUID sub with no backing user is invalid_grant", %{client_id: cid} do
    claims =
      subject_claims(%User{id: Ecto.UUID.generate()})
      |> Map.delete("user_id")
      |> Map.put("sub", Ecto.UUID.generate())

    assert exchange(%{
             "client_id" => cid,
             "subject_token" => rs256_token(claims),
             "resource" => @resource
           }) == {:error, :invalid_grant}
  end

  test "no resolvable user claim is invalid_grant", %{client_id: cid} do
    claims =
      subject_claims(%User{id: Ecto.UUID.generate()})
      |> Map.delete("user_id")
      |> Map.delete("sub")

    assert exchange(%{
             "client_id" => cid,
             "subject_token" => rs256_token(claims),
             "resource" => @resource
           }) == {:error, :invalid_grant}
  end

  # Legacy HS256 API-key tokens verify through the CompoundJWTVerifier path
  # (issuer list is checked by DualTokenVerifier's list-aware check_issuer;
  # CompoundJWTVerifier sees no issuer opt). The bare-UUID `sub` clause is the
  # intended resolution shape for these tokens.
  test "legacy HS256 API-key subject token exchanges (bare-UUID sub)", %{
    user: user,
    client_id: cid
  } do
    legacy =
      hs256_token(%{
        "iss" => hd(AuthorizationServer.jwt_issuers()),
        "sub" => to_string(user.id),
        "api_key_id" => Ecto.UUID.generate(),
        "exp" => now() + 300
      })

    assert {:ok, result} =
             exchange(%{"client_id" => cid, "subject_token" => legacy, "resource" => @resource})

    assert peek_claims(result.access_token)["sub"] == "user:#{user.id}"
  end

  test "legacy HS256 token with a foreign issuer is invalid_grant", %{user: user, client_id: cid} do
    legacy =
      hs256_token(%{
        "iss" => "https://evil.example",
        "sub" => to_string(user.id),
        "api_key_id" => Ecto.UUID.generate(),
        "exp" => now() + 300
      })

    assert exchange(%{"client_id" => cid, "subject_token" => legacy, "resource" => @resource}) ==
             {:error, :invalid_grant}
  end

  # F3 (pinned): subject aud is not bound to the requested resource.
  test "F3 PIN: subject token aud need not match the requested resource", %{
    user: user,
    client_id: cid
  } do
    assert {:ok, result} =
             exchange(%{
               "client_id" => cid,
               "subject_token" => subject(user, %{"aud" => "https://other.example/mcp"}),
               "resource" => @resource
             })

    assert peek_claims(result.access_token)["aud"] == @resource
  end

  # ── grant resolution ──────────────────────────────────────────────────────

  test "first exchange auto-approves a standing grant; it is reused afterwards", %{
    user: user,
    client: client
  } do
    refute Grants.find_active(user.id, client.client_id, @resource)

    first = exchange_ok(user, client.client_id)
    grant = Grants.find_active(user.id, client.client_id, @resource)
    assert %McpPairingGrant{} = grant

    second = exchange_ok(user, client.client_id)
    assert peek_claims(first.access_token)["grant_id"] == grant.grant_id
    assert peek_claims(second.access_token)["grant_id"] == grant.grant_id
  end

  test "grant_id claim pointing at an active grant is honored", %{user: user, client_id: cid} do
    grant = Grants.approve!(user.id, cid, @resource, "mcp")

    assert {:ok, result} =
             exchange(%{
               "client_id" => cid,
               "subject_token" => subject(user, %{"grant_id" => grant.grant_id}),
               "resource" => @resource
             })

    assert peek_claims(result.access_token)["grant_id"] == grant.grant_id
  end

  test "revoked grant_id claim falls through to a fresh auto-approved grant", %{
    user: user,
    client_id: cid
  } do
    stale = Grants.approve!(user.id, cid, "https://old.example/mcp", "mcp")
    :ok = Grants.revoke!(stale.grant_id) |> elem(0)

    assert {:ok, result} =
             exchange(%{
               "client_id" => cid,
               "subject_token" => subject(user, %{"grant_id" => stale.grant_id}),
               "resource" => @resource
             })

    # A fresh standing grant is auto-created for the requested resource, but
    # the mint echoes the subject's grant_id claim verbatim — even though that
    # grant is revoked. Pinned quirk.
    fresh = Grants.find_active(user.id, cid, @resource)
    assert %McpPairingGrant{} = fresh
    assert fresh.grant_id != stale.grant_id
    assert peek_claims(result.access_token)["grant_id"] == stale.grant_id
  end

  test "empty-string grant_id claim is dropped from the minted token", %{
    user: user,
    client_id: cid
  } do
    assert {:ok, result} =
             exchange(%{
               "client_id" => cid,
               "subject_token" => subject(user, %{"grant_id" => ""}),
               "resource" => @resource
             })

    refute Map.has_key?(peek_claims(result.access_token), "grant_id")
  end

  # ── scope negotiation ─────────────────────────────────────────────────────

  test "requested scope overrides the subject token scope", %{user: user, client_id: cid} do
    result = exchange_ok(user, cid, %{"scope" => "mcp admin"})

    assert result.scope == "mcp admin"
    assert peek_claims(result.access_token)["scope"] == "mcp admin"
  end

  test "scope falls back to the subject token scope", %{user: user, client_id: cid} do
    assert {:ok, result} =
             exchange(%{
               "client_id" => cid,
               "subject_token" => subject(user, %{"scope" => "openid mcp"}),
               "resource" => @resource
             })

    assert result.scope == "openid mcp"
  end

  test "scope defaults to mcp when neither side names one", %{user: user, client_id: cid} do
    claims = Map.delete(subject_claims(user), "scope")

    assert {:ok, result} =
             exchange(%{
               "client_id" => cid,
               "subject_token" => rs256_token(claims),
               "resource" => @resource
             })

    assert result.scope == "mcp"
  end

  # ── act chain ─────────────────────────────────────────────────────────────

  test "act.sub is the exchanging client; actor_token names the agent", %{
    user: user,
    client: client
  } do
    result = exchange_ok(user, client.client_id, %{"actor_token" => "agent-abc"})
    act = peek_claims(result.access_token)["act"]
    assert act["sub"] == "client:#{client.client_id}"
    assert act["agent"] == "agent-abc"
  end

  test "agent param is used when actor_token is absent", %{user: user, client: client} do
    result = exchange_ok(user, client.client_id, %{"agent" => "agent-xyz"})
    assert peek_claims(result.access_token)["act"]["agent"] == "agent-xyz"
  end

  test "subject claims agent is the last fallback", %{user: user, client: client} do
    claims = subject_claims(user, %{"agent" => "claimed-agent"})
    claims = Map.delete(claims, "user_id")

    assert {:ok, result} =
             exchange(%{
               "client_id" => client.client_id,
               "subject_token" => rs256_token(claims),
               "resource" => @resource
             })

    assert peek_claims(result.access_token)["act"]["agent"] == "claimed-agent"
  end

  test "empty-string agent is omitted from act", %{user: user, client: client} do
    result = exchange_ok(user, client.client_id, %{"agent" => ""})
    act = peek_claims(result.access_token)["act"]
    assert act == %{"sub" => "client:#{client.client_id}"}
  end

  test "prior act chain is nested under act.act (RFC 8693)", %{user: user, client_id: cid} do
    prior = %{"sub" => "client:prior-client", "agent" => "first-hop"}

    assert {:ok, result} =
             exchange(%{
               "client_id" => cid,
               "subject_token" => subject(user, %{"act" => prior}),
               "resource" => @resource
             })

    act = peek_claims(result.access_token)["act"]
    assert act["act"] == prior
  end

  test "non-map act claim is ignored", %{user: user, client_id: cid} do
    assert {:ok, result} =
             exchange(%{
               "client_id" => cid,
               "subject_token" => subject(user, %{"act" => "not-a-map"}),
               "resource" => @resource
             })

    act = peek_claims(result.access_token)["act"]
    refute Map.has_key?(act, "act")
  end

  # F2 (pinned): delegated tokens re-exchange — TTL restarts, act nests.
  test "F2 PIN: a minted mcp_access token can be re-exchanged for a fresh delegated token", %{
    user: user,
    client: client
  } do
    first = exchange_ok(user, client.client_id)
    assert peek_claims(first.access_token)["token_use"] == "mcp_access"

    assert {:ok, second} =
             exchange(%{
               "client_id" => client.client_id,
               "subject_token" => first.access_token,
               "resource" => @resource
             })

    claims = peek_claims(second.access_token)
    assert claims["sub"] == "user:#{user.id}"
    assert claims["act"]["sub"] == "client:#{client.client_id}"
    assert claims["act"]["act"]["sub"] == "client:#{client.client_id}"
    # TTL restarted: the re-mint is valid ~300s from NOW, not from the original mint.
    assert claims["exp"] >= now() + 290
  end

  # ── minted token shape ────────────────────────────────────────────────────

  test "minted token verifies and carries the full delegated claim set", %{
    user: user,
    client: client
  } do
    result = exchange_ok(user, client.client_id)

    assert result.token_type == "Bearer"
    assert result.issued_token_type == @access_token_type
    assert result.expires_in == 300
    assert result.scope == "mcp"

    grant = Grants.find_active(user.id, client.client_id, @resource)

    assert {:ok, claims} =
             DualTokenVerifier.verify(
               result.access_token,
               %{method: "POST", peer: nil, headers: []},
               verifier_opts()
             )

    assert claims["sub"] == "user:#{user.id}"
    assert claims["email"] == user.email
    assert claims["name"] == user.user_name
    assert claims["iss"] in AuthorizationServer.jwt_issuers()
    assert claims["aud"] == @resource
    assert claims["client_id"] == client.client_id
    assert claims["token_version"] == 2
    assert claims["token_use"] == "mcp_access"
    assert claims["user_id"] == to_string(user.id)
    assert claims["grant_id"] == grant.grant_id
    assert claims["exp"] - claims["iat"] == 300
  end

  test "name falls back to email when user_name is nil", %{client_id: cid} do
    uniq = System.unique_integer([:positive])

    user =
      %User{
        id: Ecto.UUID.generate(),
        email: "noname-#{uniq}@example.com",
        user_name: nil,
        handle: nil,
        status: :active,
        verified: true,
        flagged: false
      }
      |> Repo.insert!()

    result = exchange_ok(user, cid)
    assert peek_claims(result.access_token)["name"] == user.email
  end

  test "delegated_access_ttl_seconds override shortens the mint", %{user: user, client_id: cid} do
    prev = Application.get_env(:noizu_prompt_lingua, :mcp_oauth)

    Application.put_env(
      :noizu_prompt_lingua,
      :mcp_oauth,
      Keyword.merge(prev || [], delegated_access_ttl_seconds: 60)
    )

    on_exit(fn ->
      if prev,
        do: Application.put_env(:noizu_prompt_lingua, :mcp_oauth, prev),
        else: Application.delete_env(:noizu_prompt_lingua, :mcp_oauth)
    end)

    result = exchange_ok(user, cid)
    assert result.expires_in == 60

    claims = peek_claims(result.access_token)
    assert claims["exp"] - claims["iat"] == 60
  end

  defp now, do: System.system_time(:second)
end
