defmodule NoizuPromptLinguaWeb.ChatReactionControllerTest do
  @moduledoc """
  REST layer for chat message reactions (ticket 4c163a43). Proves the acceptance
  contract — list/add/remove via REST, idempotent add — and that all three
  endpoints speak the FE `ChatReactionSummary[]` shape (`%{"reactions" => [%{"emoji",
  "count", "me"}]}`), with POST/DELETE returning the regrouped state so the client
  reconciles an optimistic update in one round-trip.
  """
  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.Domains.Chat

  setup %{conn: conn} do
    %{access_token: token, user: user} = setup_user_and_token()
    auth_conn = authenticated_conn(conn, token)

    # Create the org via the API so the caller is a member (REST authz checks
    # organization membership), then a room + message via the domain.
    slug = "react-org-#{System.unique_integer([:positive])}"
    created = post(auth_conn, "/api/v1/organizations", %{organization: %{slug: slug, name: "React Org"}})
    org_id = json_response(created, 201)["organization"]["id"]

    {:ok, room} = Chat.create_room(%{organization_id: org_id, name: "Reactions #{System.unique_integer([:positive])}"})
    {:ok, msg} = Chat.send_message(%{room_id: room.id, content: "hi", sender: user.id})

    base = "/api/v1/organizations/#{org_id}/chat/rooms/#{room.id}/messages/#{msg.id}/reactions"
    {:ok, conn: auth_conn, base: base, msg: msg, user: user}
  end

  describe "GET reactions" do
    test "empty message returns []", %{conn: conn, base: base} do
      assert json_response(get(conn, base), 200) == %{"reactions" => []}
    end
  end

  describe "POST reaction" do
    test "adds and returns the regrouped summary with me=true for the caller", %{conn: conn, base: base} do
      resp = json_response(post(conn, base, %{emoji: "👍"}), 201)
      assert resp == %{"reactions" => [%{"emoji" => "👍", "count" => 1, "me" => true}]}
    end

    test "is idempotent — re-adding the same emoji keeps count at 1", %{conn: conn, base: base} do
      post(conn, base, %{emoji: "👍"})
      resp = json_response(post(conn, base, %{emoji: "👍"}), 201)
      assert resp == %{"reactions" => [%{"emoji" => "👍", "count" => 1, "me" => true}]}
    end

    test "another persona's reaction counts but is not 'me' for the viewer", %{conn: conn, base: base, msg: msg} do
      # caller reacts 👍 via REST; a DIFFERENT persona's reactions are seeded via the
      # domain (the REST path can't react as someone else — see the spoofing test).
      post(conn, base, %{emoji: "👍"})
      {:ok, _} = Chat.add_reaction(%{entity_type: "chat_message", entity_id: msg.id, persona: "someone-else", emoji: "👍"})
      {:ok, _} = Chat.add_reaction(%{entity_type: "chat_message", entity_id: msg.id, persona: "someone-else", emoji: "🚀"})

      reactions = json_response(get(conn, base), 200)["reactions"] |> Enum.sort_by(& &1["emoji"])

      assert reactions == [
               %{"emoji" => "👍", "count" => 2, "me" => true},
               %{"emoji" => "🚀", "count" => 1, "me" => false}
             ]
    end

    test "a client-supplied persona is ignored — caller cannot react as someone else", %{conn: conn, base: base, msg: msg, user: user} do
      # body carries a foreign persona; the row must be written as the authed actor.
      json_response(post(conn, base, %{emoji: "👍", persona: "someone-else"}), 201)

      personas = Chat.list_reactions("chat_message", msg.id) |> Enum.map(& &1.persona)
      assert personas == [user.id]
    end
  end

  describe "DELETE reaction" do
    test "removes and returns the regrouped summary", %{conn: conn, base: base} do
      post(conn, base, %{emoji: "👍"})
      post(conn, base, %{emoji: "🚀"})

      resp = json_response(delete(conn, base, %{emoji: "👍"}), 200)
      assert resp == %{"reactions" => [%{"emoji" => "🚀", "count" => 1, "me" => true}]}
    end

    test "404 when the reaction is absent", %{conn: conn, base: base} do
      assert json_response(delete(conn, base, %{emoji: "👍"}), 404) == %{"error" => "Reaction not found"}
    end

    test "cannot delete another persona's reaction via a client-supplied persona", %{conn: conn, base: base, msg: msg} do
      {:ok, _} = Chat.add_reaction(%{entity_type: "chat_message", entity_id: msg.id, persona: "someone-else", emoji: "👍"})

      # persona is ignored -> delete is scoped to the actor, who has no 👍 -> 404,
      # and someone-else's reaction survives.
      assert json_response(delete(conn, base, %{emoji: "👍", persona: "someone-else"}), 404)
      assert Chat.list_reactions("chat_message", msg.id) |> length() == 1
    end
  end

  describe "input hardening (Sofia G2)" do
    test "missing emoji -> 422, not 500", %{conn: conn, base: base} do
      assert json_response(post(conn, base, %{}), 422)["errors"]["emoji"]
      assert json_response(delete(conn, base, %{}), 422)["errors"]["emoji"]
    end

    test "blank emoji -> 422", %{conn: conn, base: base} do
      assert json_response(post(conn, base, %{emoji: ""}), 422)["errors"]
    end

    test "over-length emoji -> 422, not stored", %{conn: conn, base: base} do
      assert json_response(post(conn, base, %{emoji: String.duplicate("x", 65)}), 422)["errors"]
      assert json_response(get(conn, base), 200) == %{"reactions" => []}
    end
  end

  describe "scoping" do
    test "404 when the message does not belong to the room", %{conn: conn, base: base, msg: msg} do
      # swap the room segment for a bogus uuid
      bogus = String.replace(base, ~r|/rooms/[^/]+/|, "/rooms/#{Ecto.UUID.generate()}/")
      assert json_response(get(conn, bogus), 404)["error"] in ["Room not found", "Message not found"]
      _ = msg
    end
  end
end
