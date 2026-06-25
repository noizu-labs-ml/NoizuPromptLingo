defmodule NoizuPromptLinguaWeb.ChatRoomControllerTest do
  @moduledoc """
  Chat room PUT update (ticket 0c93ddd4, console epic). Editable = name + description
  only; slug is immutable (ADR-013) — a rename must never re-slug. Mirrors the chat
  controller test pattern.
  """
  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.Domains.Chat

  setup %{conn: conn} do
    %{access_token: token} = setup_user_and_token()
    auth_conn = authenticated_conn(conn, token)

    slug = "room-upd-org-#{System.unique_integer([:positive])}"
    created = post(auth_conn, "/api/v1/organizations", %{organization: %{slug: slug, name: "Room Upd Org"}})
    org_id = json_response(created, 201)["organization"]["id"]

    {:ok, room} = Chat.create_room(%{organization_id: org_id, name: "Original Name", description: "first"})
    base = "/api/v1/organizations/#{org_id}/chat/rooms/#{room.id}"
    {:ok, conn: auth_conn, org_id: org_id, room: room, base: base}
  end

  describe "PUT room" do
    test "updates name + description and returns the room", %{conn: conn, base: base} do
      body = json_response(put(conn, base, %{room: %{name: "New Name", description: "second"}}), 200)["room"]
      assert body["name"] == "New Name"
      assert body["description"] == "second"
    end

    test "slug is IMMUTABLE — a rename does not re-slug, and a client-sent slug is ignored", %{conn: conn, base: base, room: room} do
      original_slug = room.slug
      assert original_slug not in [nil, ""]

      body = json_response(put(conn, base, %{room: %{name: "Totally Different Name", slug: "hacked-slug"}}), 200)["room"]
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

    test "404 for a room in another org (org-scoped, no cross-org edit)", %{conn: conn, org_id: org_id} do
      other_slug = "room-upd-org2-#{System.unique_integer([:positive])}"
      other = post(conn, "/api/v1/organizations", %{organization: %{slug: other_slug, name: "Other"}})
      other_org_id = json_response(other, 201)["organization"]["id"]
      {:ok, other_room} = Chat.create_room(%{organization_id: other_org_id, name: "Theirs"})

      # PUT the other-org room under THIS org's path -> org mismatch -> 404
      assert json_response(put(conn, "/api/v1/organizations/#{org_id}/chat/rooms/#{other_room.id}", %{room: %{name: "x"}}), 404)
    end
  end
end
