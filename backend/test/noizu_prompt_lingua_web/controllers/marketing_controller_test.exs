defmodule NoizuPromptLinguaWeb.MarketingControllerTest do
  @moduledoc """
  Public marketing endpoints (landing email capture) + admin settings.

  Covers: status shape, cap enforcement (promo stops being awarded exactly at
  the cap; beta flips to waitlisted at the cap), email hygiene, closed
  signups, and admin authz on the settings endpoints.

  NOTE: the POST signup route is per-IP rate limited (10/min, Hammer ETS is
  shared across the suite) — keep the total number of signup POSTs in this
  file under that limit.
  """
  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.Domains.Marketing.Signups
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Users.User

  setup do
    # Sandbox isolation rolls these away per-test; reset the singleton row to
    # defaults so each test starts from a known state.
    Signups.get_settings!()
    |> Ecto.Changeset.change(beta_signup_cap: nil, promo_cap: nil, signups_open: true, promo_active: true)
    |> Repo.update!()

    :ok
  end

  describe "GET /api/v1/public/marketing/status" do
    test "exposes caps, switches, and the plan price without auth", %{conn: conn} do
      body = conn |> get("/api/v1/public/marketing/status") |> json_response(200)

      assert body["signups_open"] == true
      assert body["promo_active"] == true
      # NULL caps mean unlimited → remaining is null
      assert body["beta_cap"] == nil
      assert body["beta_remaining"] == nil
      assert body["promo_cap"] == nil
      assert body["promo_remaining"] == nil
      assert body["price_cents"] == 495
    end

    test "counts remaining slots against the caps", %{conn: conn} do
      Signups.update_settings(%{promo_cap: 2, beta_signup_cap: 3})
      Signups.register_signup("capcount@example.com")

      body = conn |> get("/api/v1/public/marketing/status") |> json_response(200)

      assert body["beta_cap"] == 3
      assert body["beta_remaining"] == 2
      assert body["promo_cap"] == 2
      assert body["promo_remaining"] == 1
    end
  end

  describe "POST /api/v1/public/marketing/signup" do
    test "accepts an email and awards the founding promo while slots remain", %{conn: conn} do
      body =
        conn
        |> post("/api/v1/public/marketing/signup", %{email: "  Founding@Example.COM ", source: "landing"})
        |> json_response(201)

      assert body["accepted"] == true
      assert body["waitlisted"] == false
      assert body["promo_awarded"] == true

      # Email is trimmed + lowercased before insert.
      row = Repo.get_by(NoizuPromptLingua.Schema.MarketingSignup, email: "founding@example.com")
      assert row.promo_awarded
      refute row.waitlisted
      assert row.source == "landing"
    end

    test "promo stops being awarded exactly at the cap", %{conn: conn} do
      Signups.update_settings(%{promo_cap: 1})

      first =
        conn |> post("/api/v1/public/marketing/signup", %{email: "promo-one@example.com"}) |> json_response(201)

      assert first["promo_awarded"] == true
      assert first["promo_remaining"] == 0

      second =
        conn |> post("/api/v1/public/marketing/signup", %{email: "promo-two@example.com"}) |> json_response(201)

      # Still accepted (beta has no cap) but no promo.
      assert second["promo_awarded"] == false
      assert second["promo_remaining"] == 0
    end

    test "beta cap exhaustion waitlists instead of rejecting", %{conn: conn} do
      Signups.update_settings(%{beta_signup_cap: 1})

      conn |> post("/api/v1/public/marketing/signup", %{email: "beta-one@example.com"}) |> json_response(201)

      body =
        conn
        |> post("/api/v1/public/marketing/signup", %{email: "beta-two@example.com"})
        |> json_response(202)

      assert body["accepted"] == true
      assert body["waitlisted"] == true
      assert body["promo_awarded"] == false

      row = Repo.get_by(NoizuPromptLingua.Schema.MarketingSignup, email: "beta-two@example.com")
      assert row.waitlisted
      assert row.source == "waitlist"
    end

    test "closed signups still capture the email on the waitlist", %{conn: conn} do
      Signups.update_settings(%{signups_open: false})

      body =
        conn
        |> post("/api/v1/public/marketing/signup", %{email: "closed@example.com"})
        |> json_response(202)

      assert body["waitlisted"] == true
    end

    test "rejects malformed emails with 422", %{conn: conn} do
      conn |> post("/api/v1/public/marketing/signup", %{email: "not-an-email"}) |> json_response(422)
      conn |> post("/api/v1/public/marketing/signup", %{email: ""}) |> json_response(422)
    end
  end

  describe "admin settings" do
    setup %{conn: conn} do
      %{user: user, access_token: token} = setup_user_and_token()
      %{user: user, token: token, conn: authenticated_conn(conn, token)}
    end

    test "non-admin gets 403", %{token: token} do
      conn = Phoenix.ConnTest.build_conn() |> Plug.Conn.put_req_header("authorization", "Bearer #{token}")
      assert conn |> get("/api/v1/admin/marketing/settings") |> json_response(403)
    end

    test "admin reads and updates caps + switches", %{conn: conn, user: user} do
      Repo.get!(User, user.id) |> Ecto.Changeset.change(role: :admin) |> Repo.update!()

      initial = conn |> get("/api/v1/admin/marketing/settings") |> json_response(200)
      assert initial["settings"]["signups_open"] == true
      assert initial["counts"]["signups"] == 0

      updated =
        conn
        |> put("/api/v1/admin/marketing/settings", %{settings: %{beta_signup_cap: 25, promo_cap: "", signups_open: false}})
        |> json_response(200)

      # Empty string clears an optional cap (NULL = unlimited).
      assert updated["settings"]["beta_signup_cap"] == 25
      assert updated["settings"]["promo_cap"] == nil
      assert updated["settings"]["signups_open"] == false
    end

    test "admin lists signups with filters", %{conn: conn, user: user} do
      Repo.get!(User, user.id) |> Ecto.Changeset.change(role: :admin) |> Repo.update!()
      Signups.update_settings(%{beta_signup_cap: 1})
      Signups.register_signup("listed-a@example.com")
      Signups.register_signup("listed-b@example.com")

      body = conn |> get("/api/v1/admin/marketing/signups") |> json_response(200)
      assert body["total"] == 2
      assert length(body["signups"]) == 2

      waitlisted =
        conn |> get("/api/v1/admin/marketing/signups", %{waitlisted: "true"}) |> json_response(200)

      assert waitlisted["total"] == 1
      assert hd(waitlisted["signups"])["email"] == "listed-b@example.com"
      assert hd(waitlisted["signups"])["waitlisted"] == true
    end
  end
end
