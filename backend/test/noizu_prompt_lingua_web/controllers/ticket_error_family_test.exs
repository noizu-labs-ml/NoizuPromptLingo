defmodule NoizuPromptLinguaWeb.TicketErrorFamilyTest do
  @moduledoc """
  Regression tests for the 500-family sweep (fix/error-family, stage-probe
  c6293/c6304/c6168): TRP-backed ticket + definition endpoints previously
  crashed with raw 500s (Enumerable Protocol.FunctionClauseError) or answered a
  misleading 403 when the PM backend was down/unconfigured. Ruling: dependency
  down degrades to 503 "PM backend not configured / unavailable"; TRP-side
  validation (422) and 404s pass through with their real status.
  """

  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.TRP

  setup %{conn: conn} do
    %{access_token: token} = setup_user_and_token()
    auth = authenticated_conn(conn, token)

    slug = "errfam-org-#{System.unique_integer([:positive])}"

    created =
      post(auth, "/api/v1/organizations", %{organization: %{slug: slug, name: "ErrFam Org"}})

    org_id = json_response(created, 201)["organization"]["id"]

    TRP.Cache.clear()
    TRP.TestStub.reset()
    TRP.TestStub.seed_org(org_id, slug)

    {:ok, conn: auth, org_id: org_id, base: "/api/v1/organizations/#{org_id}/tickets"}
  end

  # ── B1: ticket endpoints ────────────────────────────────────────────────

  test "GET tickets renders 503 (not Enumerable-tuple 500) when TRP is unreachable", %{
    conn: conn,
    base: base
  } do
    TRP.Cache.clear()
    TRP.TestStub.queue_response({:transport, :econnrefused})

    conn = get(conn, base)
    assert json_response(conn, 503)["error"] == "PM backend unavailable"
  end

  test "POST tickets renders 503 when TRP is unreachable", %{conn: conn, base: base} do
    TRP.TestStub.queue_response({:transport, :econnrefused})

    conn = post(conn, base, %{ticket: %{title: "X", ticket_type: "task"}})
    assert json_response(conn, 503)["error"] == "PM backend unavailable"
  end

  test "GET ticket renders 503 'not configured' when the TRP config is absent", %{
    conn: conn,
    org_id: org_id,
    base: base
  } do
    ticket = TRP.TestStub.seed_item(org_id, %{title: "Down"})

    original = Application.get_env(:noizu_prompt_lingua, :trp)

    Application.put_env(:noizu_prompt_lingua, :trp, base_url: nil, shared_key: nil)
    TRP.Cache.clear()

    on_exit(fn -> Application.put_env(:noizu_prompt_lingua, :trp, original) end)

    conn = get(conn, "#{base}/#{ticket.id}")
    assert json_response(conn, 503)["error"] == "PM backend not configured"
  end

  test "PATCH ticket answers 404 when TRP 404s every org (facade nil) — never a CaseClauseError 500",
       %{
         conn: conn,
         org_id: org_id,
         base: base
       } do
    ticket = TRP.TestStub.seed_item(org_id, %{title: "Gone"})

    # Warm the org-list + item caches so the queued 404 lands on update_item;
    # PMBridge then exhausts its org scan and returns nil (= not found).
    assert %{"ticket" => _} = json_response(get(conn, "#{base}/#{ticket.id}"), 200)
    TRP.TestStub.queue_response({404, %{"error" => "Resource not found"}})

    conn = patch(conn, "#{base}/#{ticket.id}", %{ticket: %{title: "Nope"}})
    assert json_response(conn, 404)["error"] == "Ticket not found"
  end

  test "PATCH ticket with a cold cache + TRP 404 fail-soft answers 503, not a CaseClauseError 500",
       %{
         conn: conn,
         org_id: org_id,
         base: base
       } do
    ticket = TRP.TestStub.seed_item(org_id, %{title: "Cold"})
    TRP.Cache.clear()
    TRP.TestStub.queue_response({404, %{"error" => "Resource not found"}})

    conn = patch(conn, "#{base}/#{ticket.id}", %{ticket: %{title: "Nope"}})
    assert json_response(conn, 503)["error"] == "PM backend not configured"
  end

  test "ticket endpoints still serve normally when TRP is up", %{
    conn: conn,
    org_id: org_id,
    base: base
  } do
    TRP.TestStub.seed_item(org_id, %{title: "Live", item_type: "task"})

    tickets = json_response(get(conn, base), 200)["tickets"]
    assert Enum.any?(tickets, &(&1["title"] == "Live"))
  end

  # ── B2: type/field definition endpoints ─────────────────────────────────

  test "POST ticket-type-definitions renders 503 when TRP is unreachable", %{
    conn: conn,
    base: base
  } do
    TRP.Cache.clear()
    TRP.TestStub.queue_response({:transport, :econnrefused})

    conn =
      post(conn, String.replace_suffix(base, "/tickets", "") <> "/ticket-type-definitions", %{
        type_definition: %{slug: "bug", name: "Bug"}
      })

    assert json_response(conn, 503)["error"] == "PM backend unavailable"
  end

  test "POST ticket-field-definitions passes TRP 422 field errors through as 422", %{
    conn: conn,
    base: base
  } do
    TRP.Cache.clear()

    TRP.TestStub.queue_response({422, %{"errors" => %{"slug" => ["has already been taken"]}}})

    conn =
      post(conn, String.replace_suffix(base, "/tickets", "") <> "/ticket-field-definitions", %{
        field_definition: %{slug: "severity", label: "Severity", field_type: "text"}
      })

    body = json_response(conn, 422)
    assert body["errors"]["slug"] == ["has already been taken"]
  end

  test "GET ticket-field-definitions/:id renders 503 when TRP is unreachable", %{
    conn: conn,
    base: base
  } do
    TRP.Cache.clear()
    TRP.TestStub.queue_response({:transport, :econnrefused})

    conn =
      get(conn, String.replace_suffix(base, "/tickets", "") <> "/ticket-field-definitions/abc")

    assert json_response(conn, 503)["error"] == "PM backend unavailable"
  end
end
