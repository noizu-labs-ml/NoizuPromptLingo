defmodule NoizuPromptLingua.Domains.Chat.EnhancementsTest do
  @moduledoc """
  Stream F (tests): chat enhancements layered on for the Notifications feature.

    * create_dm — kind "dm", member-set dedupe (same members reuse the room)
    * mute_room / leave_room
    * pin_message / highlight_message (highlighted → Serialize.message has
      `important: true`)
    * schedule_message — excluded from list_messages until `release_due_scheduled/0`
  """
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.Chat
  alias NoizuPromptLingua.Domains.Chat.Serialize
  alias NoizuPromptLingua.Schema.ChatMember

  defp insert_org do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["chatenh-#{System.unique_integer([:positive])}", "Chat Enh Org"]
      )

    Ecto.UUID.load!(raw)
  end

  setup do
    {:ok, org_id: insert_org()}
  end

  defp new_room(org_id) do
    {:ok, room} =
      Chat.create_room(%{
        organization_id: org_id,
        name: "Room #{System.unique_integer([:positive])}"
      })

    room
  end

  # ── DMs ───────────────────────────────────────────────────────

  test "create_dm makes a kind=dm room and dedupes on member set", %{org_id: org_id} do
    {:ok, dm1} = Chat.create_dm(org_id, nil, ["alice", "bob"])
    assert dm1.kind == "dm"

    members = Chat.list_members(dm1.id) |> Enum.map(& &1.persona) |> Enum.sort()
    assert members == ["alice", "bob"]

    # same member set (any order) reuses the existing DM
    {:ok, dm2} = Chat.create_dm(org_id, nil, ["bob", "alice"])
    assert dm2.id == dm1.id

    # a different member set is a distinct room
    {:ok, dm3} = Chat.create_dm(org_id, nil, ["alice", "carol"])
    assert dm3.id != dm1.id
  end

  # ── mute / leave ──────────────────────────────────────────────

  test "mute_room sets mute flags; leave_room stamps left_at", %{org_id: org_id} do
    room = new_room(org_id)
    {:ok, _} = Chat.add_member(%{room_id: room.id, persona: "bob"})

    {:ok, _} = Chat.mute_room(room.id, "bob", muted: true)
    assert Repo.get_by(ChatMember, room_id: room.id, persona: "bob").muted == true

    {:ok, _} = Chat.mute_room(room.id, "bob", mute_unless_mentioned: true)
    assert Repo.get_by(ChatMember, room_id: room.id, persona: "bob").mute_unless_mentioned == true

    {:ok, _} = Chat.leave_room(room.id, "bob")
    refute is_nil(Repo.get_by(ChatMember, room_id: room.id, persona: "bob").left_at)
  end

  test "leave_room on a non-member returns :not_found", %{org_id: org_id} do
    room = new_room(org_id)
    assert {:error, :not_found} = Chat.leave_room(room.id, "ghost")
  end

  # ── pin / highlight ───────────────────────────────────────────

  test "pin_message toggles and sets the pinned flag", %{org_id: org_id} do
    room = new_room(org_id)
    {:ok, msg} = Chat.send_message(%{room_id: room.id, sender: "alice", content: "pin me"})

    {:ok, pinned} = Chat.pin_message(msg.id, true)
    assert pinned.pinned == true

    {:ok, toggled} = Chat.pin_message(msg.id)
    assert toggled.pinned == false
  end

  test "highlight_message surfaces important: true in the serialized payload", %{org_id: org_id} do
    room = new_room(org_id)
    {:ok, msg} = Chat.send_message(%{room_id: room.id, sender: "alice", content: "look"})

    # not highlighted → no `important` key
    refute Map.has_key?(Serialize.message(msg), :important)

    {:ok, highlighted} = Chat.highlight_message(msg.id, true)
    assert highlighted.highlighted == true
    assert Serialize.message(highlighted)[:important] == true
  end

  # ── scheduled messages ────────────────────────────────────────

  test "a scheduled message is hidden from list_messages until release flips it due", %{
    org_id: org_id
  } do
    room = new_room(org_id)
    {:ok, _live} = Chat.send_message(%{room_id: room.id, sender: "alice", content: "now"})

    # schedule for the future → hidden from the channel view, no dispatch yet.
    future = DateTime.utc_now() |> DateTime.add(3600, :second) |> DateTime.truncate(:second)

    {:ok, scheduled} =
      Chat.schedule_message(%{
        room_id: room.id,
        sender: "alice",
        content: "later",
        scheduled_for: future
      })

    refute scheduled.id in (Chat.list_messages(room.id) |> Enum.map(& &1.id))

    # simulate the scheduled instant arriving, then release.
    past = DateTime.utc_now() |> DateTime.add(-60, :second) |> DateTime.truncate(:second)

    Repo.update_all(
      from(m in NoizuPromptLingua.Schema.ChatMessage, where: m.id == ^scheduled.id),
      set: [scheduled_for: past]
    )

    {:ok, released_count} = Chat.release_due_scheduled()
    assert released_count >= 1

    # released → scheduled_for cleared and the message now lists.
    assert is_nil(Chat.get_message(scheduled.id).scheduled_for)
    assert scheduled.id in (Chat.list_messages(room.id) |> Enum.map(& &1.id))
  end

  test "a future scheduled message stays hidden after release", %{org_id: org_id} do
    room = new_room(org_id)
    future = DateTime.utc_now() |> DateTime.add(3600, :second) |> DateTime.truncate(:second)

    {:ok, scheduled} =
      Chat.schedule_message(%{
        room_id: room.id,
        sender: "alice",
        content: "tomorrow",
        scheduled_for: future
      })

    {:ok, _} = Chat.release_due_scheduled()

    refute scheduled.id in (Chat.list_messages(room.id) |> Enum.map(& &1.id))
  end
end
