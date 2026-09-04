defmodule NoizuPromptLinguaWeb.ChatRoomControllerTest do
  @moduledoc """
  Chat room PUT update (ticket 0c93ddd4, console epic). Editable = name + description
  only; slug is immutable (ADR-013) — a rename must never re-slug. Mirrors the chat
  controller test pattern.
  """
  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.Domains.Chat
  alias NoizuPromptLingua.Authz.ScopedMemberships

  setup %{conn: conn} do
    %{access_token: token} = setup_user_and_token()
    auth_conn = authenticated_conn(conn, token)

    slug = "room-upd-org-#{System.unique_integer([:positive])}"

    created =
      post(auth_conn, "/api/v1/organizations", %{
        organization: %{slug: slug, name: "Room Upd Org"}
      })

    org_id = json_response(created, 201)["organization"]["id"]

    {:ok, room} =
      Chat.create_room(%{organization_id: org_id, name: "Original Name", description: "first"})

    base = "/api/v1/organizations/#{org_id}/chat/rooms/#{room.id}"
    {:ok, conn: auth_conn, org_id: org_id, room: room, base: base}
  end

  describe "PUT room" do
    test "updates name + description and returns the room", %{conn: conn, base: base} do
      body =
        json_response(put(conn, base, %{room: %{name: "New Name", description: "second"}}), 200)[
          "room"
        ]

      assert body["name"] == "New Name"
      assert body["description"] == "second"
    end

    test "slug is IMMUTABLE — a rename does not re-slug, and a client-sent slug is ignored", %{
      conn: conn,
      base: base,
      room: room
    } do
      original_slug = room.slug
      assert original_slug not in [nil, ""]

      body =
        json_response(
          put(conn, base, %{room: %{name: "Totally Different Name", slug: "hacked-slug"}}),
          200
        )["room"]

      assert body["name"] == "Totally Different Name"
      # slug unchanged by the rename AND not overridden by the client-supplied slug
      assert body["slug"] == original_slug
    end

    test "blank name -> 422", %{conn: conn, base: base} do
      assert json_response(put(conn, base, %{room: %{name: ""}}), 422)["errors"]["name"]
    end

    test "missing room body -> 422, not 500", %{conn: conn, base: base} do
      assert json_response(put(conn, base, %{}), 422)["errors"]["room"]
    end

    test "404 for a room in another org (org-scoped, no cross-org edit)", %{
      conn: conn,
      org_id: org_id
    } do
      other_slug = "room-upd-org2-#{System.unique_integer([:positive])}"

      other =
        post(conn, "/api/v1/organizations", %{organization: %{slug: other_slug, name: "Other"}})

      other_org_id = json_response(other, 201)["organization"]["id"]
      {:ok, other_room} = Chat.create_room(%{organization_id: other_org_id, name: "Theirs"})

      # PUT the other-org room under THIS org's path -> org mismatch -> 404
      assert json_response(
               put(conn, "/api/v1/organizations/#{org_id}/chat/rooms/#{other_room.id}", %{
                 room: %{name: "x"}
               }),
               404
             )
    end
  end

  describe "DELETE room (76338b44)" do
    test "deletes the room; cascades messages + sweeps reactions", %{
      conn: conn,
      org_id: org_id,
      room: room
    } do
      {:ok, msg} = Chat.send_message(%{room_id: room.id, content: "bye", sender: "alice"})

      {:ok, _} =
        Chat.add_reaction(%{
          entity_type: "chat_message",
          entity_id: msg.id,
          persona: "alice",
          emoji: "👍"
        })

      assert json_response(
               delete(conn, "/api/v1/organizations/#{org_id}/chat/rooms/#{room.id}"),
               200
             ) == %{"deleted" => true, "id" => room.id}

      # room gone, message cascaded, polymorphic reaction swept (no orphan)
      assert Chat.get_room(room.id) == nil
      assert Chat.get_message(msg.id) == nil
      assert Chat.list_reactions("chat_message", msg.id) == []
    end

    test "404 when the room does not exist", %{conn: conn, org_id: org_id} do
      assert json_response(
               delete(conn, "/api/v1/organizations/#{org_id}/chat/rooms/#{Ecto.UUID.generate()}"),
               404
             )
    end

    test "a plain member (below the lead bar) cannot delete -> 403, room survives", %{
      conn: base_conn,
      org_id: org_id,
      room: room
    } do
      # destructive + live-enforced -> requires lead+; a member is denied (marcus seq540)
      %{access_token: token, user: member} = setup_user_and_token()
      {:ok, _} = ScopedMemberships.add_member("organization", org_id, member.id, "member")
      member_conn = authenticated_conn(base_conn, token)

      assert json_response(
               delete(member_conn, "/api/v1/organizations/#{org_id}/chat/rooms/#{room.id}"),
               403
             )

      assert Chat.get_room(room.id)
    end

    test "404 for a room in another org (no cross-org delete)", %{conn: conn, org_id: org_id} do
      other_slug = "room-del-org2-#{System.unique_integer([:positive])}"

      other =
        post(conn, "/api/v1/organizations", %{organization: %{slug: other_slug, name: "Other"}})

      other_org_id = json_response(other, 201)["organization"]["id"]
      {:ok, other_room} = Chat.create_room(%{organization_id: other_org_id, name: "Theirs"})

      assert json_response(
               delete(conn, "/api/v1/organizations/#{org_id}/chat/rooms/#{other_room.id}"),
               404
             )

      assert Chat.get_room(other_room.id)
    end
  end
end

defmodule NoizuPromptLinguaWeb.ChatRoomDuplicateNameTest do
  @moduledoc """
  Pins the probe item-7 finding (fix/error-family B7): creating two rooms with
  the same name answers 201 BOTH times, and the slug auto-uniquifies with a
  `-N` suffix (Chat.insert_room_with_slug retry) — no duplicate slug is ever
  stored. Probe row 84 ("create-room-dupe" → 201) is this designed behavior,
  not a raw-slug bug; the rooms JSON exposes `slug` so the uniquified value is
  visible.
  """

  use NoizuPromptLinguaWeb.ConnCase

  setup %{conn: conn} do
    %{access_token: token} = setup_user_and_token()
    auth = authenticated_conn(conn, token)

    slug = "room-dupe-org-#{System.unique_integer([:positive])}"

    created =
      post(auth, "/api/v1/organizations", %{organization: %{slug: slug, name: "Room Dupe Org"}})

    org_id = json_response(created, 201)["organization"]["id"]
    base = "/api/v1/organizations/#{org_id}/chat/rooms"

    {:ok, conn: auth, base: base}
  end

  test "duplicate names yield distinct slugs — never a stored duplicate", %{
    conn: conn,
    base: base
  } do
    first = json_response(post(conn, base, %{room: %{name: "Probe Room"}}), 201)["room"]
    second = json_response(post(conn, base, %{room: %{name: "Probe Room"}}), 201)["room"]

    assert first["id"] != second["id"]
    assert first["slug"] == "probe-room"
    assert second["slug"] != first["slug"]
    assert second["slug"] =~ ~r/^probe-room(-\d+)?$/
  end

  # ── Missing-body fallbacks (regression: body-less POST /chat/rooms hit the
  #    FunctionClauseError → 500; missing required params are client errors
  #    → 422, matching the update/create_message fallbacks) ─────────────────

  describe "missing-body fallbacks" do
    test "POST rooms with no room body -> 422, not 500", %{conn: conn, base: base} do
      assert %{"errors" => %{"room" => ["can't be blank"]}} =
               post(conn, base, %{})
               |> json_response(422)
    end

    # The router only routes this action with org_id present (path segment), so
    # this exercises the defensive clause via direct dispatch.
    test "GET rooms without org_id -> 422, not 500", %{conn: conn} do
      conn = NoizuPromptLinguaWeb.ChatController.index(conn, %{})
      assert conn.status == 422
      assert %{"errors" => %{"org_id" => ["can't be blank"]}} = json_response(conn, 422)
    end
  end
end
