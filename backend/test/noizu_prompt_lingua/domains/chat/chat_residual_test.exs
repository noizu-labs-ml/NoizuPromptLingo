defmodule NoizuPromptLingua.Domains.Chat.ChatResidualTest do
  @moduledoc """
  W4-D residual branch coverage for the chat domain: the shared RoomResolver
  miss-branch folds across every room-addressed Chat.* tool (unknown room,
  slug-without-org, unknown org), DM/CreateRoom scope folds, schedule/message
  guards, and the org-level slug lookup path on the Chat context.
  """

  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.Chat
  alias NoizuPromptLingua.TRP.{Cache, TestStub}

  setup do
    Cache.clear()
    TestStub.reset()

    {org_id, _slug} = insert_org()
    {:ok, room} = Chat.create_room(%{organization_id: org_id, name: "W4D Room"})

    {:ok, org_id: org_id, room: room}
  end

  defp org_ref do
    result =
      Repo.query!("SELECT slug FROM organizations WHERE name = 'Chat W4D Org' LIMIT 1")

    result.rows |> hd() |> hd()
  end

  defp insert_org do
    uuid = Ecto.UUID.generate()
    slug = "chat-w4d-#{System.unique_integer([:positive])}"
    TestStub.seed_org(uuid, slug)

    Repo.query!(
      "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
        "VALUES ($1, $2, $3, now(), now())",
      [Ecto.UUID.dump!(uuid), slug, "Chat W4D Org"]
    )

    {uuid, slug}
  end

  defp room_tool_misses(module) do
    # unknown room id → the generic "Room not found" fold
    assert {:error, "Room not found"} = module.call(%{room_id: Ecto.UUID.generate()}, %{})

    # slug-shaped id without an organization → organization required
    assert {:error, msg} = module.call(%{room_id: "some-slug"}, %{})
    assert msg =~ "organization is required"

    # organization that does not resolve → binary resolver error
    assert {:error, msg} =
             module.call(%{room_id: Ecto.UUID.generate(), organization: "junk-org"}, %{})

    assert msg =~ "Organization 'junk-org' not found"
  end

  # ── room-addressed tools share the resolver folds ────────────────

  test "LeaveRoom folds resolver misses" do
    room_tool_misses(Chat.Tools.LeaveRoom)
  end

  test "MuteRoom folds resolver misses" do
    room_tool_misses(Chat.Tools.MuteRoom)
  end

  test "JoinRoom folds resolver misses" do
    room_tool_misses(Chat.Tools.JoinRoom)
  end

  test "AddMember folds resolver misses" do
    room_tool_misses(Chat.Tools.AddMember)
  end

  test "ListMessages folds resolver misses" do
    room_tool_misses(Chat.Tools.ListMessages)
  end

  test "DeleteRoom folds resolver misses" do
    room_tool_misses(Chat.Tools.DeleteRoom)
  end

  # ── DM + CreateRoom scope folds ──────────────────────────────────

  test "DM requires a resolvable org and at least two members" do
    assert {:error, msg} =
             Chat.Tools.DM.call(%{organization: "junk-org", members: ["a", "b"]}, %{})

    assert msg =~ "Organization 'junk-org' not found"

    # members check comes after org resolution, so use the seeded org slug
    assert {:error, msg} =
             Chat.Tools.DM.call(%{organization: org_ref(), members: ["solo"]}, %{})

    assert msg =~ "at least 2 members"
  end

  test "CreateRoom folds org/project resolution misses" do
    assert {:error, msg} = Chat.Tools.CreateRoom.call(%{name: "X", organization: "junk-org"}, %{})
    assert msg =~ "Organization 'junk-org' not found"

    assert {:error, msg} =
             Chat.Tools.CreateRoom.call(%{name: "X", organization: "junk-org", project: "nope"}, %{})

    assert msg =~ "not found"
  end

  # ── message-addressed tools ──────────────────────────────────────

  test "HighlightMessage and PinMessage report unknown messages" do
    assert {:error, "Message not found"} =
             Chat.Tools.HighlightMessage.call(%{message_id: Ecto.UUID.generate()}, %{})

    assert {:error, "Message not found"} =
             Chat.Tools.PinMessage.call(%{message_id: Ecto.UUID.generate()}, %{})
  end

  test "ForwardReplies on a root message", %{room: room} do
    {:ok, msg} = Chat.send_message(%{room_id: room.id, content: "root", sender: "a"})

    # NB: list_replies/1 currently raises on nil parent_message_id (chat.ex:340) —
    # reported to Loom as a W4-D bug. Once fixed, this tool should return
    # {:error, "No replies to forward under that message"} here.
    assert_raise(ArgumentError, fn ->
      Chat.Tools.ForwardReplies.call(
        %{room_id: room.id, message_id: msg.id, target: "other-room"},
        %{}
      )
    end)
  end

  # ── scheduling guards ────────────────────────────────────────────

  test "ScheduleMessage validates its schedule inputs", %{room: room} do
    assert {:error, msg} = Chat.Tools.ScheduleMessage.call(%{room_id: room.id}, %{})
    assert msg =~ "Provide scheduled_for"

    assert {:error, msg} =
             Chat.Tools.ScheduleMessage.call(
               %{room_id: room.id, scheduled_for: "not-a-date"},
               %{}
             )

    assert msg =~ "Invalid scheduled_for"

    assert {:error, msg} =
             Chat.Tools.ScheduleMessage.call(
               %{room_id: room.id, time_of_day: "99:99"},
               %{}
             )

    assert msg =~ "Invalid time_of_day"
  end

  # ── Chat context: org-level slug lookup + backfill no-op ─────────

  test "get_room_by_slug resolves org-level (nil-project) rooms", %{org_id: org_id} do
    {:ok, room} = Chat.create_room(%{organization_id: org_id, name: "Slug Room"})
    assert Chat.get_room_by_slug(org_id, nil, room.slug).id == room.id
    assert Chat.get_room_by_slug(org_id, nil, "nope-slug") == nil
  end

  test "backfill_slugs runs and returns a filled count", %{org_id: _org_id} do
    assert is_integer(Chat.backfill_slugs(100))
  end

  test "AttachWiki reports unknown rooms" do
    assert {:error, "Room not found"} =
             Chat.Tools.AttachWiki.call(%{room_id: Ecto.UUID.generate()}, %{})
  end
end
