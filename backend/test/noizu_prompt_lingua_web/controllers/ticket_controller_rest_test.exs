defmodule NoizuPromptLinguaWeb.TicketRestControllerTest do
  @moduledoc """
  Ticket REST endpoints beyond the human-key suite: the index filter params,
  create with project validation, the PATCH update action, org-scoped 404s, and
  every handle_error branch. Project validation rides the TRP stub inventory,
  so the REST-created org's id is mirrored into the stub.
  """
  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.Authz.ScopedMemberships
  alias NoizuPromptLingua.TRP.{Cache, TestStub}

  setup %{conn: conn} do
    Cache.clear()
    TestStub.reset()

    %{access_token: token} = setup_user_and_token()

    conn =
      conn
      |> authenticated_conn(token)
      |> unique_ip()

    slug = "ticket-rest-org-#{System.unique_integer([:positive])}"

    created =
      post(conn, "/api/v1/organizations", %{organization: %{slug: slug, name: "Ticket REST Org"}})

    org_id = json_response(created, 201)["organization"]["id"]

    # mirror into the stub so Projects.get_project scans resolve
    TestStub.seed_org(org_id, slug)
    project = TestStub.seed_project(org_id, %{slug: "tk-rest-proj", name: "TK REST Project"})

    {:ok, conn: conn, org_id: org_id, project: project}
  end

  defp unique_ip(conn) do
    uniq = System.unique_integer([:positive])

    put_req_header(conn, "x-forwarded-for", "10.7.#{rem(uniq, 250)}.#{rem(uniq, 251)}")
  end

  defp create_ticket(conn, org_id, overrides \\ %{}) do
    post(conn, "/api/v1/organizations/#{org_id}/tickets", %{
      ticket: Map.merge(%{"title" => "REST Ticket", "ticket_type" => "task"}, overrides)
    })
  end

  # ── index ─────────────────────────────────────────────────────

  test "index lists tickets and threads filter params through", %{conn: conn, org_id: org_id} do
    create_ticket(conn, org_id, %{"title" => "Indexed", "status" => "open"})

    body = json_response(get(conn, "/api/v1/organizations/#{org_id}/tickets"), 200)
    assert [%{"title" => "Indexed"}] = body["tickets"]

    # every filter param is accepted (scalar passthrough to TRP)
    filtered =
      get(
        conn,
        "/api/v1/organizations/#{org_id}/tickets" <>
          "?status=open&ticket_type=task&priority=high&assignee=alice&queue_id=&parent_id=&stage_id=&iteration_id=&project_id="
      )

    assert %{"tickets" => _} = json_response(filtered, 200)
  end

  test "index errors: unknown org -> 404, non-member -> 403", %{conn: base_conn, org_id: org_id} do
    assert %{"error" => "Organization not found"} =
             json_response(
               get(base_conn, "/api/v1/organizations/definitely-not-a-real-org/tickets"),
               404
             )

    %{access_token: token} = setup_user_and_token()

    assert %{"error" => "Not a member of this organization"} =
             json_response(
               get(
                 authenticated_conn(base_conn, token),
                 "/api/v1/organizations/#{org_id}/tickets"
               ),
               403
             )
  end

  # ── create ────────────────────────────────────────────────────

  test "create returns 201 with the TRP-minted key", %{conn: conn, org_id: org_id} do
    body = json_response(create_ticket(conn, org_id), 201)["ticket"]

    assert body["title"] == "REST Ticket"
    assert body["key"] != nil
    assert body["organization_id"] == org_id
    assert body["ticket_type"] == "task"
  end

  test "create validates project ownership -> 422", %{
    conn: conn,
    org_id: org_id,
    project: project
  } do
    body =
      json_response(create_ticket(conn, org_id, %{"project_id" => project.id}), 201)["ticket"]

    assert body["project_id"] == project.id

    other_org =
      TestStub.seed_org(
        Ecto.UUID.generate(),
        "tk-other-org-#{System.unique_integer([:positive])}"
      )

    foreign = TestStub.seed_project(other_org, %{slug: "foreign", name: "Foreign"})

    assert %{"error" => "Project does not belong to this organization"} =
             json_response(create_ticket(conn, org_id, %{"project_id" => foreign.id}), 422)

    assert %{"error" => "Project does not belong to this organization"} =
             json_response(
               create_ticket(conn, org_id, %{"project_id" => Ecto.UUID.generate()}),
               422
             )
  end

  test "create by a viewer-role member -> 403 insufficient permissions", %{
    conn: base_conn,
    org_id: org_id
  } do
    %{access_token: token, user: viewer} = setup_user_and_token()
    {:ok, _} = ScopedMemberships.add_member("organization", org_id, viewer.id, "viewer")

    conn = authenticated_conn(base_conn, token) |> unique_ip()

    assert %{"error" => "Insufficient permissions"} =
             json_response(create_ticket(conn, org_id), 403)
  end

  # ── update (PATCH/PUT) ────────────────────────────────────────

  test "update applies the whitelisted fields", %{conn: conn, org_id: org_id} do
    %{"ticket" => %{"id" => id}} = json_response(create_ticket(conn, org_id), 201)
    base = "/api/v1/organizations/#{org_id}/tickets/#{id}"

    body =
      json_response(
        put(conn, base, %{
          "ticket" => %{"title" => "Updated", "status" => "done", "rogue_field" => "ignored"}
        }),
        200
      )["ticket"]

    assert body["title"] == "Updated"
    assert body["status"] == "done"
  end

  test "update 404s for unknown tickets and foreign-org tickets", %{conn: conn, org_id: org_id} do
    assert json_response(
             put(conn, "/api/v1/organizations/#{org_id}/tickets/#{Ecto.UUID.generate()}", %{
               "ticket" => %{"title" => "x"}
             }),
             404
           )

    # a ticket living under a DIFFERENT stub org is invisible from this org path
    other_org =
      TestStub.seed_org(
        Ecto.UUID.generate(),
        "tk-upd-other-#{System.unique_integer([:positive])}"
      )

    foreign = TestStub.seed_item(other_org, %{title: "Foreign", key: "TSK-80001"})

    assert json_response(
             put(conn, "/api/v1/organizations/#{org_id}/tickets/#{foreign.id}", %{
               "ticket" => %{"title" => "x"}
             }),
             404
           )
  end

  # ── show ──────────────────────────────────────────────────────

  test "show by UUID returns the ticket with empty link lists", %{conn: conn, org_id: org_id} do
    %{"ticket" => %{"id" => id}} = json_response(create_ticket(conn, org_id), 201)

    body = json_response(get(conn, "/api/v1/organizations/#{org_id}/tickets/#{id}"), 200)

    assert body["ticket"]["id"] == id
    assert body["links"] == %{"outgoing" => [], "incoming" => []}
  end

  test "show 404s for an unknown ticket", %{conn: conn, org_id: org_id} do
    assert json_response(
             get(conn, "/api/v1/organizations/#{org_id}/tickets/#{Ecto.UUID.generate()}"),
             404
           )
  end
end
