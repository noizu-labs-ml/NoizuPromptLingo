defmodule NoizuPromptLinguaWeb.ChatMessageControllerTest do
  @moduledoc """
  Hardening review of the chat messages REST endpoints (ticket e3e84c76, authored by
  marcus-dev). Focused on the Sofia-G2 runtime gaps a 'done' endpoint usually misses —
  blank/whitespace reject, max-length cap, missing-body 422-not-500, list ordering —
  not a duplicate of QA's acceptance suite (bc10f471).
  """
  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.Domains.Chat

  setup %{conn: conn} do
    %{access_token: token, user: user} = setup_user_and_token()
    auth_conn = authenticated_conn(conn, token)

    slug = "msg-org-#{System.unique_integer([:positive])}"
    created = post(auth_conn, "/api/v1/organizations", %{organization: %{slug: slug, name: "Msg Org"}})
    org_id = json_response(created, 201)["organization"]["id"]

    {:ok, room} = Chat.create_room(%{organization_id: org_id, name: "Messages #{System.unique_integer([:positive])}"})
    base = "/api/v1/organizations/#{org_id}/chat/rooms/#{room.id}/messages"
    {:ok, conn: auth_conn, base: base, user: user}
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
end
