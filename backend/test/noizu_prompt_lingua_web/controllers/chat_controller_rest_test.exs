defmodule NoizuPromptLinguaWeb.ChatRestControllerTest do
  @moduledoc """
  Chat REST endpoints the message/reaction suites don't reach: room index /
  create / show, the message-list query params, and every handle_error branch
  (unknown org 404, non-member 403, insufficient role 403, foreign project 422).
  Project validation rides the TRP stub (Projects.get_project scans the stub
  inventory), so the REST-created org's id is mirrored into the stub.
  """
  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.Domains.Chat
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

    slug = "chat-rest-org-#{System.unique_integer([:positive])}"

    created =
      post(conn, "/api/v1/organizations", %{organization: %{slug: slug, name: "Chat REST Org"}})

    org_id = json_response(created, 201)["organization"]["id"]

    # mirror the REST-created org into the TRP stub so project validation scans
    # (Projects.get_project walks the stub org inventory) can see its projects.
    TestStub.seed_org(org_id, slug)

    {:ok, room} = Chat.create_room(%{organization_id: org_id, name: "REST Room"})

    {:ok, conn: conn, org_id: org_id, room: room}
  end

  # hammer keys org-creation rate limits on client IP; give each test its own
  defp unique_ip(conn) do
    uniq = System.unique_integer([:positive])

    put_req_header(
      conn,
      "x-forwarded-for",
      "10.7.#{rem(uniq, 250)}.#{rem(uniq, 251)}"
    )
  end

  defp seed_project(org_id) do
    TestStub.seed_project(org_id, %{
      slug: "rest-proj-#{System.unique_integer([:positive])}",
      name: "REST Project"
    })
  end

  # ── GET /chat/rooms (index) ───────────────────────────────────

  test "index lists the org's rooms", %{conn: conn, org_id: org_id, room: room} do
    body = json_response(get(conn, "/api/v1/organizations/#{org_id}/chat/rooms"), 200)
    assert [%{"id" => id}] = body["rooms"]
    assert id == room.id
  end

  test "index filters by project_id and session_id", %{conn: conn, org_id: org_id} do
    project_id = Ecto.UUID.generate()
    session_id = Ecto.UUID.generate()

    {:ok, proj} =
      Chat.create_room(%{organization_id: org_id, project_id: project_id, name: "P"})

    {:ok, sess} =
      Chat.create_room(%{organization_id: org_id, session_id: session_id, name: "S"})

    base = "/api/v1/organizations/#{org_id}/chat/rooms"

    assert [%{"id" => id}] =
             json_response(get(conn, base <> "?project_id=#{project_id}"), 200)["rooms"]

    assert id == proj.id

    assert [%{"id" => sid}] =
             json_response(get(conn, base <> "?session_id=#{session_id}"), 200)["rooms"]

    assert sid == sess.id
  end

  test "index errors: unknown org -> 404, non-member -> 403, viewer-below-member -> 403", %{
    conn: base_conn,
    org_id: org_id
  } do
    # an unresolvable org SLUG fails resolution -> 404
    assert %{"error" => "Organization not found"} =
             json_response(
               get(base_conn, "/api/v1/organizations/definitely-not-a-real-org-slug/chat/rooms"),
               404
             )

    # a user with no membership at all
    %{access_token: token} = setup_user_and_token()

    assert %{"error" => "Not a member of this organization"} =
             json_response(
               get(
                 authenticated_conn(base_conn, token),
                 "/api/v1/organizations/#{org_id}/chat/rooms"
               ),
               403
             )

    # a member whose org role (viewer) is below the member bar POST requires
    %{access_token: vtoken, user: viewer} = setup_user_and_token()
    {:ok, _} = ScopedMemberships.add_member("organization", org_id, viewer.id, "viewer")

    assert %{"error" => "Insufficient permissions"} =
             json_response(
               post(
                 authenticated_conn(base_conn, vtoken),
                 "/api/v1/organizations/#{org_id}/chat/rooms",
                 %{
                   room: %{name: "Nope"}
                 }
               ),
               403
             )
  end

  # ── POST /chat/rooms (create) ─────────────────────────────────

  test "create makes a room with a derived slug", %{conn: conn, org_id: org_id} do
    body =
      json_response(
        post(conn, "/api/v1/organizations/#{org_id}/chat/rooms", %{room: %{name: "Created Room"}}),
        201
      )["room"]

    assert body["name"] == "Created Room"
    assert body["slug"] == "created-room"
    assert body["organization_id"] == org_id
  end

  test "create validates the project belongs to the org", %{conn: conn, org_id: org_id} do
    project = seed_project(org_id)

    body =
      json_response(
        post(conn, "/api/v1/organizations/#{org_id}/chat/rooms", %{
          room: %{name: "With Project", project_id: project.id}
        }),
        201
      )["room"]

    assert body["project_id"] == project.id

    # a project owned by a DIFFERENT stub org -> 422
    other_org_id =
      TestStub.seed_org(
        Ecto.UUID.generate(),
        "chat-rest-other-#{System.unique_integer([:positive])}"
      )

    foreign = TestStub.seed_project(other_org_id, %{slug: "foreign-proj", name: "Foreign"})

    assert %{"error" => "Project does not belong to this organization"} =
             json_response(
               post(conn, "/api/v1/organizations/#{org_id}/chat/rooms", %{
                 room: %{name: "x", project_id: foreign.id}
               }),
               422
             )

    # an unknown project id resolves to nothing -> same 422
    assert %{"error" => "Project does not belong to this organization"} =
             json_response(
               post(conn, "/api/v1/organizations/#{org_id}/chat/rooms", %{
                 room: %{name: "x", project_id: Ecto.UUID.generate()}
               }),
               422
             )
  end

  test "create with a blank name is a 422 changeset error", %{conn: conn, org_id: org_id} do
    assert %{"errors" => %{"name" => _}} =
             json_response(
               post(conn, "/api/v1/organizations/#{org_id}/chat/rooms", %{room: %{name: ""}}),
               422
             )
  end

  # ── GET /chat/rooms/:id (show) ────────────────────────────────

  test "show resolves by UUID and by slug", %{conn: conn, org_id: org_id, room: room} do
    by_id = json_response(get(conn, "/api/v1/organizations/#{org_id}/chat/rooms/#{room.id}"), 200)
    assert by_id["room"]["id"] == room.id
    assert by_id["room"]["slug"] == room.slug

    by_slug =
      json_response(get(conn, "/api/v1/organizations/#{org_id}/chat/rooms/#{room.slug}"), 200)

    assert by_slug["room"]["id"] == room.id
  end

  test "show 404s for unknown rooms and rooms of other orgs", %{conn: conn, org_id: org_id} do
    assert json_response(
             get(conn, "/api/v1/organizations/#{org_id}/chat/rooms/#{Ecto.UUID.generate()}"),
             404
           )

    {:ok, other} = Chat.create_room(%{organization_id: Ecto.UUID.generate(), name: "Elsewhere"})

    assert json_response(
             get(conn, "/api/v1/organizations/#{org_id}/chat/rooms/#{other.id}"),
             404
           )
  end

  # ── message list params ───────────────────────────────────────

  test "index_messages accepts limit/before/after and survives a bad limit", %{
    conn: conn,
    org_id: org_id,
    room: room
  } do
    {:ok, m1} = Chat.send_message(%{room_id: room.id, content: "one", sender: "a"})
    {:ok, _} = Chat.send_message(%{room_id: room.id, content: "two", sender: "a"})
    base = "/api/v1/organizations/#{org_id}/chat/rooms/#{room.id}/messages"

    assert length(json_response(get(conn, base <> "?limit=1"), 200)["messages"]) == 1

    # unparseable limit is ignored (parse_limit :error -> nil)
    assert length(json_response(get(conn, base <> "?limit=abc"), 200)["messages"]) == 2

    after_first = DateTime.add(m1.inserted_at, 1, :microsecond) |> DateTime.to_iso8601()

    msgs =
      json_response(get(conn, base <> "?after=#{URI.encode_www_form(after_first)}"), 200)[
        "messages"
      ]

    refute Enum.any?(msgs, &(&1["content"] == "one"))

    # include_replies=true opts out of the top-level channel view
    {:ok, _} =
      Chat.send_message(%{room_id: room.id, content: "r", sender: "b", parent_message_id: m1.id})

    top_level = json_response(get(conn, base), 200)["messages"]
    refute Enum.any?(top_level, &(&1["content"] == "r"))

    flat = json_response(get(conn, base <> "?include_replies=true"), 200)["messages"]
    assert Enum.any?(flat, &(&1["content"] == "r"))
  end

  test "index_replies 404s when the message lives in another room", %{
    conn: conn,
    org_id: org_id,
    room: room
  } do
    {:ok, other_room} = Chat.create_room(%{organization_id: org_id, name: "Other"})
    {:ok, msg} = Chat.send_message(%{room_id: other_room.id, content: "elsewhere", sender: "a"})

    assert json_response(
             get(
               conn,
               "/api/v1/organizations/#{org_id}/chat/rooms/#{room.id}/messages/#{msg.id}/replies"
             ),
             404
           )
  end
end
