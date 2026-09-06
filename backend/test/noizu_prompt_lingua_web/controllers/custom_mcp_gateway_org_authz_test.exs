defmodule NoizuPromptLinguaWeb.CustomMCPGatewayOrgAuthzTest do
  @moduledoc """
  Security regression: the org-addressed custom-MCP gateway
  (`POST /org/:org_slug/custom/:slug/mcp`) must gate on ORG MEMBERSHIP, not on
  slug knowledge. Before the fix any valid MCP key could `initialize` against
  any org's scope by guessing the URL slugs — cross-org tool exposure.

  Mirrors `MCPSetGatewayController`'s audience gate: key owner / OAuth `sub`
  must hold an ACTIVE membership in the resolved org, else 404 (shared body —
  no existence leak). A missing/garbage bearer still defers to the transport
  plug's 401 challenge (leaks nothing), and the legacy `/custom/:slug/mcp`
  alias plus the `/user/:slug/mcp` account path keep their existing semantics.
  """

  use NoizuPromptLinguaWeb.ConnCase, async: false

  alias NoizuPromptLingua.Authz.ScopedMemberships
  alias NoizuPromptLingua.MCPCustomScopes
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.McpApiKey
  alias NoizuPromptLingua.Schema.Organizations.Organization
  alias NoizuPromptLingua.Schema.Users.User
  alias NoizuPromptLingua.Token
  alias NoizuPromptLingua.TRP.Cache
  alias NoizuPromptLingua.TRP.TestStub

  @not_found %{"error" => "Custom MCP scope not found"}

  setup do
    # Org-slug resolution reads the TRP shared-key plane on this branch —
    # point it at the stub (same pattern as custom_mcp_gateway_slug_urls_test).
    prev_cfg = Application.get_env(:noizu_prompt_lingua, :trp)
    prev_transport = Application.get_env(:noizu_prompt_lingua, :trp_transport)

    Application.put_env(:noizu_prompt_lingua, :trp,
      base_url: "http://trp.test",
      shared_key: "trp_sk_test"
    )

    Application.put_env(:noizu_prompt_lingua, :trp_transport, NoizuPromptLingua.TRP.TestStub)
    Cache.clear()
    TestStub.reset()

    on_exit(fn ->
      if prev_cfg, do: Application.put_env(:noizu_prompt_lingua, :trp, prev_cfg)

      if prev_transport,
        do: Application.put_env(:noizu_prompt_lingua, :trp_transport, prev_transport)
    end)

    uniq = System.unique_integer([:positive])
    org = create_org("sec-org-#{uniq}", uniq)
    scope = create_scope("sec-scope-#{uniq}", org.id)

    %{org: org, scope: scope, uniq: uniq}
  end

  describe "org-addressed gateway: membership gate" do
    test "member (API-key owner in the org) reaches MCP serving — not 404", %{
      org: org,
      scope: scope
    } do
      %{token: token} = key_caller(org, member?: true)

      conn =
        authenticated_conn(token)
        |> post("/org/#{org.slug}/custom/#{scope.slug}/mcp", initialize_body())

      refute conn.status in [403, 404]
      assert conn.status == 200
    end

    test "member via OAuth sub identity reaches MCP serving", %{org: org, scope: scope} do
      %{token: token} = oauth_caller(org, member?: true)

      conn =
        authenticated_conn(token)
        |> post("/org/#{org.slug}/custom/#{scope.slug}/mcp", initialize_body())

      refute conn.status in [403, 404]
      assert conn.status == 200
    end

    test "non-member with a valid key ⇒ 404, shared body (no existence leak)", %{
      org: org,
      scope: scope
    } do
      %{token: token} = key_caller(org, member?: false)

      conn =
        authenticated_conn(token)
        |> post("/org/#{org.slug}/custom/#{scope.slug}/mcp", initialize_body())

      assert conn.status == 404
      assert json_response(conn, 404) == @not_found
    end

    test "cross-org probe: member of ANOTHER org ⇒ 404 (was: full initialize success)", %{
      org: org,
      scope: scope,
      uniq: uniq
    } do
      other_org = create_org("sec-other-org-#{uniq}", uniq)
      %{token: token} = key_caller(other_org, member?: true)

      conn =
        authenticated_conn(token)
        |> post("/org/#{org.slug}/custom/#{scope.slug}/mcp", initialize_body())

      assert conn.status == 404
      assert json_response(conn, 404) == @not_found
    end

    test "UUID-path parity: member in org reaches serving via /org/<org-uuid>/…", %{
      org: org,
      scope: scope
    } do
      %{token: token} = key_caller(org, member?: true)

      conn =
        authenticated_conn(token)
        |> post("/org/#{org.id}/custom/#{scope.slug}/mcp", initialize_body())

      refute conn.status in [403, 404]
      assert conn.status == 200
    end

    test "UUID-path parity: non-member via /org/<org-uuid>/… ⇒ 404", %{org: org, scope: scope} do
      %{token: token} = key_caller(org, member?: false)

      conn =
        authenticated_conn(token)
        |> post("/org/#{org.id}/custom/#{scope.slug}/mcp", initialize_body())

      assert conn.status == 404
      assert json_response(conn, 404) == @not_found
    end
  end

  describe "unchanged semantics on the ungated surfaces" do
    test "anonymous POST still defers to the plug's 401 challenge (not 404)", %{
      org: org,
      scope: scope
    } do
      conn =
        build_conn()
        |> post("/org/#{org.slug}/custom/#{scope.slug}/mcp", initialize_body())

      assert conn.status == 401
    end

    test "garbage bearer defers to the 401 challenge (not 404)", %{org: org, scope: scope} do
      conn =
        build_conn()
        |> Plug.Conn.put_req_header("authorization", "Bearer not-a-real-token")
        |> post("/org/#{org.slug}/custom/#{scope.slug}/mcp", initialize_body())

      assert conn.status == 401
    end

    test "legacy /custom/:slug/mcp alias still serves in place (no membership gate)", %{
      scope: scope
    } do
      %{token: token} = key_caller(nil, member?: false)

      conn =
        authenticated_conn(token)
        |> post("/custom/#{scope.slug}/mcp", initialize_body())

      # The legacy alias keeps its pre-fix semantics: any valid key is served
      # in place (200), regardless of org membership — never a gate 404.
      assert conn.status == 200
      refute json_response(conn, 200)["error"] == "Custom MCP scope not found"
    end

    test "account-visibility scope stays open to its owner on /user/:slug/mcp", %{uniq: uniq} do
      account_scope = create_scope("sec-account-#{uniq}", nil, "account")
      %{token: token} = key_caller(nil, member?: false)

      conn =
        authenticated_conn(token)
        |> post("/user/#{account_scope.slug}/mcp", initialize_body())

      # Owner-authenticated account scopes are not member-gated on this path.
      refute conn.status in [403, 404]
    end
  end

  # ── fixtures ───────────────────────────────────────────────────────────────

  defp create_org(slug, uniq) do
    org =
      %Organization{}
      |> Ecto.Changeset.change(%{slug: slug, name: "Sec Org #{uniq}"})
      |> Repo.insert()
      |> then(fn
        {:ok, org} -> org
        {:error, _} -> Repo.get_by!(Organization, slug: slug)
      end)

    TestStub.seed_org(org.id, slug)
    Cache.bust_prefix([:orgs, :list])
    org
  end

  defp create_scope(slug, org_id, visibility \\ "org") do
    attrs =
      %{
        "slug" => slug,
        "name" => "Sec Scope #{slug}",
        "visibility" => visibility,
        "config" => %{"groups" => %{}}
      }
      |> then(fn a -> if org_id, do: Map.put(a, "organization_id", org_id), else: a end)

    {:ok, scope} = MCPCustomScopes.create(attrs)
    scope
  end

  defp create_user do
    n = System.unique_integer([:positive])

    Repo.insert!(%User{
      id: Ecto.UUID.generate(),
      email: "secgw-#{n}@example.com",
      user_name: "secgwu#{n}",
      handle: "secgwh#{n}",
      status: :active,
      verified: false,
      flagged: false
    })
  end

  defp create_api_key(user_id) do
    Repo.insert!(%McpApiKey{
      id: Ecto.UUID.generate(),
      user_id: user_id,
      key_prefix: "mcp_t",
      key_hash: Ecto.UUID.generate(),
      status: "active"
    })
  end

  # API-key identity: bearer token binds the key; the key's OWNER is the
  # membership identity (never a client claim).
  defp key_caller(org, opts) do
    user = create_user()
    key = create_api_key(user.id)

    if opts[:member?] and org, do: add_member!(org, user.id)

    {:ok, token, _exp} =
      Token.mint(%{id: user.id, email: user.email, name: user.user_name}, %{id: key.id},
        alg: :hs256
      )

    %{user: user, key: key, token: token}
  end

  # OAuth identity: RS256 bearer minted the way OAuth.TokenService.mint_tokens
  # does — "user:"-prefixed sub, no api_key_id — exercising the verifier's
  # asymmetric path and the gate's sub-identity branch.
  defp oauth_caller(org, opts) do
    user = create_user()

    if opts[:member?], do: add_member!(org, user.id)

    now = System.system_time(:second)
    entry = NoizuPromptLingua.OAuth.Jwks.signing_entry()

    claims = %{
      "sub" => "user:#{user.id}",
      "user_id" => user.id,
      "email" => user.email,
      "name" => user.user_name,
      "iss" => NoizuPromptLingua.OAuth.AuthorizationServer.issuer_url(),
      "iat" => now,
      "exp" => now + 3600,
      "client_id" => "authz-regression-client",
      "scope" => "mcp",
      "token_version" => 2,
      "token_use" => "access"
    }

    {_, token} =
      JOSE.JWT.sign(entry.jwk, %{"alg" => entry.alg, "kid" => entry.kid, "typ" => "JWT"}, claims)
      |> JOSE.JWS.compact()

    %{user: user, token: token}
  end

  defp add_member!(org, user_id) do
    {:ok, _} = ScopedMemberships.add_member("organization", org.id, user_id, "member")
    :ok
  end

  defp authenticated_conn(token) do
    build_conn()
    |> Plug.Conn.put_req_header("authorization", "Bearer " <> token)
    |> Plug.Conn.put_req_header("accept", "application/json, text/event-stream")
  end

  defp initialize_body do
    %{
      "jsonrpc" => "2.0",
      "id" => 1,
      "method" => "initialize",
      "params" => %{
        "protocolVersion" => "2024-11-05",
        "capabilities" => %{},
        "clientInfo" => %{"name" => "authz-regression", "version" => "1.0"}
      }
    }
  end
end
