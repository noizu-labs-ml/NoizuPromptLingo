defmodule NoizuPromptLinguaWeb.ChatMessageControllerTest do
  @moduledoc """
  Hardening review of the chat messages REST endpoints (ticket e3e84c76, authored by
  marcus-dev). Focused on the Sofia-G2 runtime gaps a 'done' endpoint usually misses —
  blank/whitespace reject, max-length cap, missing-body 422-not-500, list ordering —
  not a duplicate of QA's acceptance suite (bc10f471).
  """
  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.Domains.Chat
  alias NoizuPromptLingua.Repo

  setup %{conn: conn} do
    %{access_token: token, user: user} = setup_user_and_token()
    auth_conn = authenticated_conn(conn, token)

    slug = "msg-org-#{System.unique_integer([:positive])}"
    created = post(auth_conn, "/api/v1/organizations", %{organization: %{slug: slug, name: "Msg Org"}})
    org_id = json_response(created, 201)["organization"]["id"]

    {:ok, room} = Chat.create_room(%{organization_id: org_id, name: "Messages #{System.unique_integer([:positive])}"})
    base = "/api/v1/organizations/#{org_id}/chat/rooms/#{room.id}/messages"
    {:ok, conn: auth_conn, base: base, user: user, org_id: org_id, room: room}
  end

  describe "POST message — happy path" do
    test "creates a message and defaults sender to the actor", %{conn: conn, base: base, user: user} do
      resp = json_response(post(conn, base, %{message: %{content: "ship it"}}), 201)["message"]
      assert resp["content"] == "ship it"
      assert resp["sender"] == user.id
    end
  end

  describe "POST message — input hardening (Sofia G2)" do
    test "empty content -> 422", %{conn: conn, base: base} do
      assert json_response(post(conn, base, %{message: %{content: ""}}), 422)["errors"]["content"]
    end

    test "whitespace-only content -> 422", %{conn: conn, base: base} do
      assert json_response(post(conn, base, %{message: %{content: "   \n\t "}}), 422)["errors"]["content"]
    end

    test "over-length content (>10k) -> 422", %{conn: conn, base: base} do
      assert json_response(post(conn, base, %{message: %{content: String.duplicate("a", 10_001)}}), 422)["errors"]["content"]
    end

    test "missing message body -> 422, not 500", %{conn: conn, base: base} do
      assert json_response(post(conn, base, %{}), 422)["errors"]["message"]
    end

    test "content with markup is stored verbatim (XSS is a render-layer concern)", %{conn: conn, base: base} do
      payload = "<script>alert(1)</script>"
      resp = json_response(post(conn, base, %{message: %{content: payload}}), 201)["message"]
      # BE stores raw; the FE renders markdown inert. We assert no server-side mangling
      # so the FE's sanitizer is the single, auditable escaping point.
      assert resp["content"] == payload
    end
  end

  describe "GET messages" do
    test "returns messages oldest-first with embedded reaction summaries", %{conn: conn, base: base} do
      post(conn, base, %{message: %{content: "first"}})
      post(conn, base, %{message: %{content: "second"}})

      messages = json_response(get(conn, base), 200)["messages"]
      assert Enum.map(messages, & &1["content"]) == ["first", "second"]
      assert Enum.all?(messages, &is_list(&1["reactions"]))
    end
  end

  describe "threaded replies (ffa2d2f6)" do
    setup %{conn: conn, base: base} do
      parent = json_response(post(conn, base, %{message: %{content: "root"}}), 201)["message"]
      {:ok, parent_id: parent["id"]}
    end

    # a reply is a message with parent_message_id (reuse POST .../messages, no /replies POST).
    test "POST a message with parent_message_id creates a reply", %{conn: conn, base: base, parent_id: pid} do
      reply = json_response(post(conn, base, %{message: %{content: "re", parent_message_id: pid}}), 201)["message"]
      assert reply["parent_message_id"] == pid
      assert reply["content"] == "re"
    end

    test "GET .../messages/:id/replies returns replies chronologically with reactions", %{conn: conn, base: base, parent_id: pid} do
      post(conn, base, %{message: %{content: "r1", parent_message_id: pid}})
      post(conn, base, %{message: %{content: "r2", parent_message_id: pid}})

      replies = json_response(get(conn, "#{base}/#{pid}/replies"), 200)["messages"]
      assert Enum.map(replies, & &1["content"]) == ["r1", "r2"]
      assert Enum.all?(replies, &is_list(&1["reactions"]))
    end

    test "channel list is top-level only + embeds reply_count/last_reply_at; ?include_replies=true is flat", %{conn: conn, base: base, parent_id: pid} do
      post(conn, base, %{message: %{content: "buried", parent_message_id: pid}})

      default = json_response(get(conn, base), 200)["messages"]
      assert Enum.map(default, & &1["content"]) == ["root"]
      root = Enum.find(default, &(&1["id"] == pid))
      assert root["reply_count"] == 1
      assert root["last_reply_at"]

      flat = json_response(get(conn, "#{base}?include_replies=true"), 200)["messages"]
      assert "buried" in Enum.map(flat, & &1["content"])
    end

    test "reply-to-a-reply is rejected (one-level threads) -> 422", %{conn: conn, base: base, parent_id: pid} do
      reply = json_response(post(conn, base, %{message: %{content: "r", parent_message_id: pid}}), 201)["message"]
      resp = json_response(post(conn, base, %{message: %{content: "deep", parent_message_id: reply["id"]}}), 422)
      assert resp["error"] =~ "one level"
    end

    test "parent in another room is rejected -> 422", %{conn: conn, base: base, org_id: org_id} do
      {:ok, other_room} = Chat.create_room(%{organization_id: org_id, name: "Other #{System.unique_integer([:positive])}"})
      {:ok, foreign} = Chat.send_message(%{room_id: other_room.id, content: "elsewhere", sender: "x"})

      resp = json_response(post(conn, base, %{message: %{content: "r", parent_message_id: foreign.id}}), 422)
      assert resp["error"] =~ "another room"
    end

    test "unknown parent -> 422", %{conn: conn, base: base} do
      assert json_response(post(conn, base, %{message: %{content: "r", parent_message_id: Ecto.UUID.generate()}}), 422)["error"]
    end

    test "deleting the parent DETACHES replies to root (ON DELETE SET NULL), never deletes them", %{conn: conn, base: base, parent_id: pid} do
      reply = json_response(post(conn, base, %{message: %{content: "survivor", parent_message_id: pid}}), 201)["message"]

      Repo.delete!(Chat.get_message(pid))

      detached = Chat.get_message(reply["id"])
      assert detached != nil
      assert detached.parent_message_id == nil
    end
  end
end
