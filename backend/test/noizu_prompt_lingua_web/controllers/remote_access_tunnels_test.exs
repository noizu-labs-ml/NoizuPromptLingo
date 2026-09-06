defmodule NoizuPromptLinguaWeb.RemoteAccessTunnelsTest do
  @moduledoc """
  Coverage for the user-facing CRUD half of `RemoteAccessController` (the frps
  admission gate has its own suite: `remote_access_frp_auth_test.exs`).

  Tunnel CRUD is MCP-JWT authenticated (HS256 token over a real `MCPApiKey`
  row, same recipe as the tool-set gateway suite) and gated on org membership
  (`with_editor/3`). Both fail-closed paths are exercised: missing/invalid
  bearer → 401, non-member → 403, unknown org → 404, unknown tunnel → 404.

  Each test carries a unique `x-forwarded-for`: the scope sits behind
  `:rate_limited_auth` (10/60s per IP) and the suite must not share a bucket.
  """

  use NoizuPromptLinguaWeb.ConnCase, async: false

  alias NoizuPromptLingua.Domains.RemoteAccess
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.McpApiKey
  alias NoizuPromptLingua.Schema.Organizations.Organization
  alias NoizuPromptLingua.Schema.Users.User
  alias NoizuPromptLingua.Token
  alias NoizuPromptLingua.Authz.ScopedMemberships

  @base "/api/v1/remote-access/tunnels"

  setup _context do
    n = System.unique_integer([:positive])

    fwd = "ra-tunnels-#{n}"

    conn =
      build_conn()
      |> Plug.Conn.put_req_header("x-forwarded-for", fwd)

    %{org: org} = seed_org(n)
    %{token: token, user: user} = mcp_caller(org)

    {:ok, conn: conn, user: user, org: org, token: token, fwd: fwd}
  end

  defp mcp_conn(conn, token),
    do: Plug.Conn.put_req_header(conn, "authorization", "Bearer " <> token)

  # ── POST /tunnels ─────────────────────────────────────────────────────────

  test "create: editor claims a tunnel (201, token shown once, url + defaults)", %{
    conn: conn,
    org: org,
    token: token
  } do
    name = "tunnel-create-#{uniq()}"

    resp =
      conn
      |> mcp_conn(token)
      |> post(@base, %{"name" => name, "organization" => org.slug})
      |> json_response(201)

    assert resp["tunnel_token"]
    assert resp["url"] == "https://#{name}.remote-access.noizu.com"
    assert resp["proxy_type"] == "http"
    assert resp["expires_at"]
  end

  test "create: proxy_type opt is honored", %{conn: conn, org: org, token: token} do
    resp =
      conn
      |> mcp_conn(token)
      |> post(@base, %{
        "name" => "tunnel-tcp-#{uniq()}",
        "organization" => org.slug,
        "proxy_type" => "tcp"
      })
      |> json_response(201)

    assert resp["proxy_type"] == "tcp"
  end

  test "create: re-claiming your own name rotates the token (201)", %{
    conn: conn,
    org: org,
    token: token
  } do
    name = "tunnel-reclaim-#{uniq()}"
    c = conn |> mcp_conn(token)

    first = post(c, @base, %{"name" => name, "organization" => org.slug}) |> json_response(201)

    second =
      post(c, @base, %{"name" => name, "organization" => org.slug}) |> json_response(201)

    assert second["tunnel_token"] != first["tunnel_token"]
  end

  test "create: name held by someone else -> 409", %{conn: conn, org: org, token: token} do
    %{token: other_token} = mcp_caller(org)
    name = "tunnel-clash-#{uniq()}"

    conn |> mcp_conn(other_token) |> post(@base, %{"name" => name, "organization" => org.slug})

    resp =
      conn
      |> mcp_conn(token)
      |> post(@base, %{"name" => name, "organization" => org.slug})

    assert resp.status == 409
    assert json_response(resp, 409)["error"] =~ "already claimed"
  end

  test "create: invalid name (not a DNS label) is rejected, not admitted", %{
    conn: conn,
    org: org,
    token: token
  } do
    # KNOWN WART (not queued for this wave): claim_tunnel/4 maps ANY :name
    # changeset error — a format violation included — to `:name_taken`, so a
    # DNS-label-invalid name answers 409 "already claimed" instead of 422.
    # Pinned here so the conflation can't silently regress either direction.
    resp =
      conn
      |> mcp_conn(token)
      |> post(@base, %{"name" => "Not_A_DNS_Label!", "organization" => org.slug})

    assert resp.status == 409
    assert json_response(resp, 409)["error"] =~ "already claimed"
  end

  test "create: missing name/org -> 400 fallback", %{conn: conn, token: token} do
    conn = conn |> mcp_conn(token) |> post(@base, %{})

    assert conn.status == 400
    assert json_response(conn, 400)["error"] =~ "required"
  end

  test "create: unknown organization -> 404", %{conn: conn, token: token} do
    conn =
      conn
      |> mcp_conn(token)
      |> post(@base, %{"name" => "tunnel-x-#{uniq()}", "organization" => "no-such-org"})

    assert conn.status == 404
    assert json_response(conn, 404)["error"] =~ "not found"
  end

  test "create: non-member -> 403 editor gate", %{conn: conn} do
    %{org: org} = seed_org(uniq())
    # caller's user holds no membership in this org.
    %{token: token2} = mcp_caller()

    conn =
      conn
      |> mcp_conn(token2)
      |> post(@base, %{"name" => "tunnel-nm-#{uniq()}", "organization" => org.slug})

    assert conn.status == 403
    assert json_response(conn, 403)["error"] =~ "editor role required"
  end

  test "create: viewer -> 403 (gate floors at member, was any-membership)", %{
    conn: conn
  } do
    %{org: org} = seed_org(uniq())
    %{token: token} = mcp_caller(org, "viewer")

    conn =
      conn
      |> mcp_conn(token)
      |> post(@base, %{"name" => "tunnel-viewer-#{uniq()}", "organization" => org.slug})

    assert conn.status == 403
    assert json_response(conn, 403)["error"] =~ "editor role required"
  end

  test "create: plain member passes the gate (201)", %{conn: conn} do
    %{org: org} = seed_org(uniq())
    %{token: token} = mcp_caller(org, "member")

    resp =
      conn
      |> mcp_conn(token)
      |> post(@base, %{"name" => "tunnel-member-#{uniq()}", "organization" => org.slug})
      |> json_response(201)

    assert resp["tunnel_token"]
  end

  test "create: no bearer -> 401", %{conn: conn, org: org} do
    conn = post(conn, @base, %{"name" => "tunnel-anon", "organization" => org.slug})

    assert conn.status == 401
    assert json_response(conn, 401)["error"] =~ "missing Bearer"
  end

  test "create: garbage bearer -> 401 invalid MCP token", %{conn: conn, org: org} do
    conn =
      conn
      |> mcp_conn("not.a.jwt")
      |> post(@base, %{"name" => "tunnel-bad-#{uniq()}", "organization" => org.slug})

    assert conn.status == 401
    assert json_response(conn, 401)["error"] == "invalid MCP token"
  end

  # ── GET /tunnels ──────────────────────────────────────────────────────────

  test "index: lists the caller's tunnels with derived fields", %{
    conn: conn,
    org: org,
    token: token,
    user: user
  } do
    {:ok, tunnel, _raw} =
      RemoteAccess.claim_tunnel(user.id, org.id, "tunnel-list-#{uniq()}")

    resp =
      conn
      |> mcp_conn(token)
      |> get(@base <> "?organization=#{org.slug}")
      |> json_response(200)

    listed = Enum.find(resp["tunnels"], &(&1["name"] == tunnel.name))
    assert listed
    assert listed["url"] == "https://#{tunnel.name}.remote-access.noizu.com"
    assert listed["status"] == "active"
    assert listed["connected"] == false
  end

  test "index: missing organization param -> 400", %{conn: conn, token: token} do
    conn = conn |> mcp_conn(token) |> get(@base)

    assert conn.status == 400
    assert json_response(conn, 400)["error"] =~ "organization is required"
  end

  test "index: unknown organization -> 404", %{conn: conn, token: token} do
    conn = conn |> mcp_conn(token) |> get(@base <> "?organization=no-such-org")

    assert conn.status == 404
  end

  test "index: non-member -> 403", %{conn: conn} do
    %{org: org} = seed_org(uniq())
    %{token: token} = mcp_caller()

    conn = conn |> mcp_conn(token) |> get(@base <> "?organization=#{org.slug}")

    assert conn.status == 403
  end

  # ── DELETE /tunnels/:name ─────────────────────────────────────────────────

  test "delete: owner revokes the claim (200, tombstoned)", %{
    conn: conn,
    org: org,
    token: token,
    user: user
  } do
    name = "tunnel-del-#{uniq()}"

    {:ok, _tunnel, _raw} = RemoteAccess.claim_tunnel(user.id, org.id, name)

    conn =
      conn
      |> mcp_conn(token)
      |> delete(@base <> "/#{name}")

    assert conn.status == 200
    assert json_response(conn, 200) == %{"name" => name, "status" => "revoked"}
  end

  test "delete: not the owner -> 403", %{conn: conn, org: org, token: token} do
    %{token: other_token, user: other} = mcp_caller(org)
    # the tunnel belongs to `other`; `token`'s user is a member but not the owner

    name = "tunnel-foreign-#{uniq()}"

    {:ok, _t, _raw} = RemoteAccess.claim_tunnel(other.id, org.id, name)

    conn = conn |> mcp_conn(token) |> delete(@base <> "/#{name}")

    assert conn.status == 403
    assert json_response(conn, 403)["error"] =~ "do not own"
  end

  test "delete: unknown name -> 404", %{conn: conn, token: token} do
    conn = conn |> mcp_conn(token) |> delete(@base <> "/no-such-tunnel")

    assert conn.status == 404
    assert json_response(conn, 404)["error"] =~ "no active claim"
  end

  test "delete: no bearer -> 401", %{conn: conn} do
    conn = delete(conn, @base <> "/whatever")

    assert conn.status == 401
  end

  # ── fixtures ──────────────────────────────────────────────────────────────

  defp uniq, do: Integer.to_string(System.unique_integer([:positive]))

  defp seed_org(_n) do
    # UUID-suffixed slug: the slug→id resolver positives-cache (1h) is
    # persistent across test VMs, and unique_integer slugs collide between
    # runs (cf. tool_set_gateway_test's identical precaution).
    slug = "ra-org-" <> Ecto.UUID.generate()
    org = Repo.insert!(%Organization{name: "RA Org", slug: slug})
    %{org: org}
  end

  # HS256 MCP JWT over a REAL active MCPApiKey row — the identity the tunnel
  # CRUD gates trust (same recipe as the tool-set gateway suite).
  defp mcp_caller(org \\ nil, role \\ "member") do
    n = uniq()

    user =
      Repo.insert!(%User{
        id: Ecto.UUID.generate(),
        email: "ra-#{n}@example.com",
        user_name: "rau#{n}",
        handle: "rah#{n}",
        status: :active,
        verified: false,
        flagged: false
      })

    key =
      Repo.insert!(%McpApiKey{
        id: Ecto.UUID.generate(),
        user_id: user.id,
        key_prefix: "mcp_t",
        key_hash: Ecto.UUID.generate(),
        status: "active"
      })

    if org, do: member!(org, user.id, role)

    {:ok, token, _exp} =
      Token.mint(%{id: user.id, email: user.email, name: user.user_name}, %{id: key.id},
        alg: :hs256
      )

    %{token: token, user: user}
  end

  # The `with_editor/3` gate floors at "member" on the ordinal Authz ladder
  # (the scoped-membership world has no "editor" rung — authorizing "editor"
  # ranked the required role at 99 and cleared ANY membership, viewers
  # included; ticket 1bd065df). A non-member still fails closed with 403.
  defp member!(org, user_id, role) do
    {:ok, _} = ScopedMemberships.add_member("organization", org.id, user_id, role)
    :ok
  end
end
