defmodule NoizuPromptLinguaWeb.RemoteAccessFrpAuthTest do
  @moduledoc """
  Security regression: `POST /api/v1/remote-access/frp-auth` (the frps
  server-plugin admission gate) must FAIL CLOSED.

  Before the fix an unconfigured (nil/"") `REMOTE_ACCESS_FRP_SECRET` admitted
  every callback (200 `{"reject":false}`) and unknown ops were allowed through —
  an unconfigured secret admitted ANY tunnel. Now:

    * nil / "" secret ⇒ 403 `{"reject":true}` (secret is mandatory)
    * unknown / missing op ⇒ 403 `{"reject":true}`
    * configured secret + known op behave exactly as before (401 bad-secret
      path preserved; Login / NewProxy / CloseProxy semantics untouched)
  """

  use NoizuPromptLinguaWeb.ConnCase, async: false

  alias NoizuPromptLingua.Domains.RemoteAccess
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Organizations.Organization
  alias NoizuPromptLingua.Schema.Users.User

  @path "/api/v1/remote-access/frp-auth"
  @secret "frp-shared-secret-regression"

  setup do
    prev = System.get_env("REMOTE_ACCESS_FRP_SECRET")

    on_exit(fn ->
      case prev do
        nil -> System.delete_env("REMOTE_ACCESS_FRP_SECRET")
        val -> System.put_env("REMOTE_ACCESS_FRP_SECRET", val)
      end
    end)

    n = System.unique_integer([:positive])

    user =
      Repo.insert!(%User{
        id: Ecto.UUID.generate(),
        email: "frp-#{n}@example.com",
        user_name: "frpu#{n}",
        handle: "frph#{n}",
        status: :active,
        verified: false,
        flagged: false
      })

    org = Repo.insert!(%Organization{name: "Frp Org", slug: "frp-org-#{n}"})

    {:ok, tunnel, raw_token} = RemoteAccess.claim_tunnel(user.id, org.id, "frp-tunnel-#{n}")

    # Unique per-test rate-limit identity (the auth limiter keys on IP and the
    # default is 10/60s — don't share a bucket across the suite).
    [
      fwd: "frp-auth-test-#{n}",
      token: raw_token,
      tunnel_name: tunnel.name
    ]
  end

  defp frp_conn(ctx), do: build_conn() |> Plug.Conn.put_req_header("x-forwarded-for", ctx.fwd)

  defp with_secret, do: System.put_env("REMOTE_ACCESS_FRP_SECRET", @secret)
  defp no_secret, do: System.delete_env("REMOTE_ACCESS_FRP_SECRET")
  defp empty_secret, do: System.put_env("REMOTE_ACCESS_FRP_SECRET", "")

  # ── fail closed: unconfigured / empty secret ───────────────────────────────

  test "nil secret + empty body ⇒ 403 reject (was: 200 admit)", ctx do
    no_secret()

    conn = ctx |> frp_conn() |> post(@path)

    assert conn.status == 403
    assert json_response(conn, 403)["reject"] == true
  end

  test "nil secret + known op with a VALID tunnel token ⇒ 403 reject", ctx do
    no_secret()

    conn =
      ctx
      |> frp_conn()
      |> post(@path, login_body(ctx.token))

    assert conn.status == 403
    assert json_response(conn, 403)["reject"] == true
  end

  test "empty-string secret ⇒ 403 reject (misconfigured ≠ allow-all)", ctx do
    empty_secret()

    conn = ctx |> frp_conn() |> post(@path)

    assert conn.status == 403
    assert json_response(conn, 403)["reject"] == true
  end

  # ── configured secret: existing behavior preserved ─────────────────────────

  test "configured secret + bogus query secret ⇒ 401 reject", ctx do
    with_secret()

    conn =
      ctx
      |> frp_conn()
      |> post(@path <> "?secret=not-the-secret", login_body(ctx.token))

    assert conn.status == 401
    assert json_response(conn, 401)["reject"] == true
  end

  test "configured secret + missing secret ⇒ 401 reject", ctx do
    with_secret()

    conn = ctx |> frp_conn() |> post(@path, login_body(ctx.token))

    assert conn.status == 401
    assert json_response(conn, 401)["reject"] == true
  end

  test "configured secret + valid query secret + valid Login token ⇒ 200 admit + marks connected",
       ctx do
    with_secret()

    conn =
      ctx
      |> frp_conn()
      |> post(@path <> "?secret=#{@secret}", login_body(ctx.token))

    assert conn.status == 200
    assert json_response(conn, 200)["reject"] == false
    assert RemoteAccess.connected?(ctx.tunnel_name)
  end

  test "configured secret + valid header secret + valid NewProxy (own subdomain) ⇒ 200 admit",
       ctx do
    with_secret()

    conn =
      ctx
      |> frp_conn()
      |> Plug.Conn.put_req_header("x-frp-secret", @secret)
      |> post(@path, %{
        "op" => "NewProxy",
        "content" => %{
          "metas" => %{"token" => ctx.token},
          "subdomain" => ctx.tunnel_name
        }
      })

    assert conn.status == 200
    assert json_response(conn, 200)["reject"] == false
  end

  test "configured secret + valid secret + NewProxy (foreign subdomain) ⇒ 200 deny", ctx do
    with_secret()

    conn =
      ctx
      |> frp_conn()
      |> post(@path <> "?secret=#{@secret}", %{
        "op" => "NewProxy",
        "content" => %{
          "metas" => %{"token" => ctx.token},
          "subdomain" => "someone-elses-tunnel"
        }
      })

    assert conn.status == 200
    assert json_response(conn, 200)["reject"] == true
  end

  test "configured secret + valid secret + CloseProxy ⇒ 200 admit", ctx do
    with_secret()

    conn =
      ctx
      |> frp_conn()
      |> post(@path <> "?secret=#{@secret}", %{
        "op" => "CloseProxy",
        "content" => %{"metas" => %{"token" => ctx.token}}
      })

    assert conn.status == 200
    assert json_response(conn, 200)["reject"] == false
  end

  # ── fail closed: unknown / missing op (secret gate passed) ─────────────────

  test "configured secret + unknown op ⇒ 403 reject (was: 200 admit)", ctx do
    with_secret()

    conn =
      ctx
      |> frp_conn()
      |> post(@path <> "?secret=#{@secret}", %{"op" => "WeirdOp", "content" => %{}})

    assert conn.status == 403
    assert json_response(conn, 403)["reject"] == true
  end

  test "configured secret + no op (empty body) ⇒ 403 reject", ctx do
    with_secret()

    conn = ctx |> frp_conn() |> post(@path <> "?secret=#{@secret}")

    assert conn.status == 403
    assert json_response(conn, 403)["reject"] == true
  end

  # ── helpers ────────────────────────────────────────────────────────────────

  defp login_body(token), do: %{"op" => "Login", "content" => %{"metas" => %{"token" => token}}}
end
