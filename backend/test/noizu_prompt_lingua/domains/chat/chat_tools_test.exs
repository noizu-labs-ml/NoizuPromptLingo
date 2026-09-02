defmodule NoizuPromptLingua.Domains.Chat.ToolsTest do
  @moduledoc """
  Chat MCP tool surface: every Chat.* tool's happy path plus its error
  branches, driven through `Tool.call(args, %{})` against the house TRP stub.
  Org/project resolution rides the stub inventory (Resolve helpers); rooms,
  messages, events, members and notifications are local app-DB rows.
  """
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.Chat
  alias NoizuPromptLingua.Services.Attach
  alias NoizuPromptLingua.TRP.{Cache, TestStub}

  setup do
    # The TRP ETS cache may hold org inventory from an earlier test; bust it so
    # resolution sees this test's stub state (TestStub.reset does not bust it).
    Cache.clear()
    TestStub.reset()

    {org_id, org_slug} = insert_org()
    {:ok, room} = Chat.create_room(%{organization_id: org_id, name: "Tools Room"})

    {:ok, org_id: org_id, org_slug: org_slug, room: room}
  end

  # ── fixtures ──────────────────────────────────────────────────
  # Org resolution is TRP-backed, so the stub inventory must carry the same
  # id/slug pair the app-DB organizations row does (house pattern).

  defp insert_org do
    uuid = Ecto.UUID.generate()
    slug = "chat-tools-#{System.unique_integer([:positive])}"
    TestStub.seed_org(uuid, slug)

    Repo.query!(
      "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
        "VALUES ($1, $2, $3, now(), now())",
      [Ecto.UUID.dump!(uuid), slug, "Chat Tools Org"]
    )

    {uuid, slug}
  end

  defp insert_project(org_id) do
    slug = "chat-proj-#{System.unique_integer([:positive])}"
    TestStub.seed_project(org_id, %{slug: slug, name: "Chat Tools Project"})
    slug
  end

  defp other_org_with_room do
    {org_id, _slug} = insert_org()
    {:ok, room} = Chat.create_room(%{organization_id: org_id, name: "Other Org Room"})
    {org_id, room}
  end

  # ── Overview ──────────────────────────────────────────────────

  test "Chat.Overview reports the room count and tool catalog" do
    assert {:ok, %{domain: "Chat", room_count: n, tools: %{rooms: [first | _]}}} =
             Chat.Tools.Overview.call(%{}, %{})

    assert n >= 1
    assert first == "Chat.CreateRoom"
  end

  # ── CreateRoom ────────────────────────────────────────────────

  test "Chat.CreateRoom creates a room and derives the slug", %{org_slug: org_slug} do
    assert {:ok, %{id: id, slug: "derived-name", chatroom_url: url}} =
             Chat.Tools.CreateRoom.call(
               %{organization: org_slug, name: "Derived Name", description: "d"},
               %{}
             )

    assert is_binary(id)
    assert url =~ "/chat/"
  end

  test "Chat.CreateRoom scopes to a project when given", %{org_id: org_id, org_slug: org_slug} do
    project_slug = insert_project(org_id)

    assert {:ok, %{project_id: pid}} =
             Chat.Tools.CreateRoom.call(
               %{organization: org_slug, name: "In Project", project: project_slug},
               %{}
             )

    assert pid != nil
  end

  test "Chat.CreateRoom errors: unknown org, unknown project, foreign project, invalid attrs", %{
    org_id: org_id,
    org_slug: org_slug
  } do
    assert {:error, "Organization 'ghost-org' not found"} =
             Chat.Tools.CreateRoom.call(%{organization: "ghost-org", name: "x"}, %{})

    assert {:error, "Project 'nope' not found"} =
             Chat.Tools.CreateRoom.call(
               %{organization: org_slug, name: "x", project: "nope"},
               %{}
             )

    # a project scoped to a DIFFERENT org is invisible from this org's listing
    {other_org_id, _} = other_org_with_room()
    foreign = insert_project(other_org_id)

    assert {:error, err} =
             Chat.Tools.CreateRoom.call(
               %{organization: org_slug, name: "x", project: foreign},
               %{}
             )

    assert err =~ "not found"

    # a blank name fails the room changeset (invalid-attrs branch)
    assert {:error, "Failed: " <> _} =
             Chat.Tools.CreateRoom.call(%{organization: org_slug, name: ""}, %{})
  end

  # ── GetRoom / DeleteRoom / ListRooms ──────────────────────────

  test "Chat.GetRoom returns members + attachments by UUID", %{room: room} do
    {:ok, _} = Chat.add_member(%{room_id: room.id, persona: "alice"})

    {:ok, _} =
      Attach.add("chat_room", room.id, %{
        artifact_type: "wiki",
        url: "https://wiki/x",
        created_by: "alice"
      })

    assert {:ok, %{member_count: 1, attachments: [%{url: "https://wiki/x"}]}} =
             Chat.Tools.GetRoom.call(%{room_id: room.id}, %{})
  end

  test "Chat.GetRoom resolves by slug with org; errors without org or for unknown ids", %{
    org_id: org_id,
    org_slug: org_slug,
    room: room
  } do
    assert {:ok, %{id: id}} =
             Chat.Tools.GetRoom.call(%{room_id: room.slug, organization: org_slug}, %{})

    assert id == room.id

    assert {:error, "organization is required when the room is addressed by slug"} =
             Chat.Tools.GetRoom.call(%{room_id: room.slug}, %{})

    assert {:error, "Room not found"} =
             Chat.Tools.GetRoom.call(%{room_id: Ecto.UUID.generate()}, %{})

    assert {:error, "Organization 'ghost' not found"} =
             Chat.Tools.GetRoom.call(%{room_id: room.slug, organization: "ghost"}, %{})
  end

  test "Chat.DeleteRoom deletes via the binary-id path and reports missing rooms", %{
    org_id: org_id,
    org_slug: org_slug
  } do
    {:ok, doomed} = Chat.create_room(%{organization_id: org_id, name: "Doomed"})

    assert {:ok, %{deleted: true, id: id}} =
             Chat.Tools.DeleteRoom.call(%{room_id: doomed.id}, %{})

    assert id == doomed.id
    assert Chat.get_room(doomed.id) == nil

    assert {:error, "Room not found"} =
             Chat.Tools.DeleteRoom.call(%{room_id: Ecto.UUID.generate()}, %{})
  end

  test "Chat.ListRooms lists org rooms with filters and errors on unknown org", %{
    org_id: org_id,
    org_slug: org_slug,
    room: room
  } do
    {:ok, dm} = Chat.create_room(%{organization_id: org_id, kind: "dm", name: "DM"})

    assert {:ok, %{count: 2}} = Chat.Tools.ListRooms.call(%{organization: org_slug}, %{})

    assert {:ok, %{count: 1, rooms: [%{id: id}]}} =
             Chat.Tools.ListRooms.call(%{organization: org_slug, limit: 1, offset: 0}, %{}),
           "windows the page"

    assert {:ok, %{rooms: rooms}} =
             Chat.Tools.ListRooms.call(%{organization: org_slug}, %{})

    assert Enum.any?(rooms, &(&1.id == room.id))
    assert Enum.any?(rooms, &(&1.id == dm.id))

    assert {:error, "Organization 'ghost' not found"} =
             Chat.Tools.ListRooms.call(%{organization: "ghost"}, %{})
  end

  # ── SendMessage / ListMessages ────────────────────────────────

  test "Chat.SendMessage posts and serializes; parent_id threads", %{room: room} do
    {:ok, parent} =
      Chat.Tools.SendMessage.call(
        %{room_id: room.id, content: "root", sender: "alice"},
        %{}
      )

    assert %{id: _, content: "root", pinned: false} = parent

    assert {:ok, %{parent_id: parent_id}} =
             Chat.Tools.SendMessage.call(
               %{room_id: room.id, content: "reply", sender: "bob", parent_id: parent.id},
               %{}
             )

    assert parent_id == parent.id
  end

  test "Chat.SendMessage error branches: bad room, org required, invalid content", %{room: room} do
    assert {:error, "Room not found"} =
             Chat.Tools.SendMessage.call(
               %{room_id: Ecto.UUID.generate(), content: "x", sender: "a"},
               %{}
             )

    assert {:error, "organization is required when the room is addressed by slug"} =
             Chat.Tools.SendMessage.call(%{room_id: "some-slug", content: "x", sender: "a"}, %{})

    assert {:error, "Organization 'ghost' not found"} =
             Chat.Tools.SendMessage.call(
               %{room_id: room.slug, organization: "ghost", content: "x", sender: "a"},
               %{}
             )

    assert {:error, "Failed: " <> _} =
             Chat.Tools.SendMessage.call(%{room_id: room.id, content: "", sender: "a"}, %{})
  end

  test "Chat.ListMessages honors limit/before/after", %{room: room} do
    {:ok, m1} = Chat.Tools.SendMessage.call(%{room_id: room.id, content: "a", sender: "x"}, %{})
    {:ok, _} = Chat.Tools.SendMessage.call(%{room_id: room.id, content: "b", sender: "x"}, %{})

    assert {:ok, %{count: 2}} = Chat.Tools.ListMessages.call(%{room_id: room.id}, %{})

    assert {:ok, %{count: 1, messages: [%{content: "b"}]}} =
             Chat.Tools.ListMessages.call(
               %{
                 room_id: room.id,
                 after: DateTime.to_iso8601(DateTime.add(m1.created_at, 1, :microsecond))
               },
               %{}
             )

    assert {:ok, %{count: 1}} =
             Chat.Tools.ListMessages.call(%{room_id: room.id, limit: 1}, %{})
  end

  # ── Events ────────────────────────────────────────────────────

  test "Chat.CreateEvent + Chat.ListEvents + Chat.React round-trip", %{room: room} do
    assert {:ok, %{id: event_id, event_type: "decision"}} =
             Chat.Tools.CreateEvent.call(
               %{
                 "room_id" => room.id,
                 "event_type" => "decision",
                 "content" => "ship it",
                 "sender" => "alice"
               },
               %{}
             )

    assert {:error, "Failed: " <> _} =
             Chat.Tools.CreateEvent.call(%{"room_id" => room.id, "event_type" => "todo"}, %{})

    assert {:ok, %{count: 1, events: [%{id: ^event_id}]}} =
             Chat.Tools.ListEvents.call(%{room_id: room.id, event_type: "decision"}, %{})

    {:ok, _} =
      Chat.Tools.CreateEvent.call(
        %{"room_id" => room.id, "event_type" => "todo", "content" => "t", "sender" => "s"},
        %{}
      )

    assert {:ok, %{count: 2}} = Chat.Tools.ListEvents.call(%{room_id: room.id, limit: 2}, %{})

    assert {:ok, %{id: _, persona: "bob", emoji: "🎯"}} =
             Chat.Tools.ChatReact.call(
               %{event_id: event_id, persona: "bob", emoji: "🎯"},
               %{}
             )

    assert {:error, "Failed: " <> _} =
             Chat.Tools.ChatReact.call(%{event_id: event_id, persona: "bob"}, %{})
  end

  # ── Members ───────────────────────────────────────────────────

  test "Chat.AddMember + ListMembers", %{room: room} do
    assert {:ok, %{persona: "alice", role: "member"}} =
             Chat.Tools.AddMember.call(%{room_id: room.id, persona: "alice"}, %{})

    assert {:ok, %{persona: "bob", role: "admin"}} =
             Chat.Tools.AddMember.call(%{room_id: room.id, persona: "bob", role: "admin"}, %{})

    assert {:ok, %{count: 2}} = Chat.Tools.ListMembers.call(%{room_id: room.id}, %{})

    assert {:error, "Failed: " <> _} =
             Chat.Tools.AddMember.call(%{room_id: room.id}, %{})
  end

  test "Chat.JoinRoom returns the recent backlog; LeaveRoom errors for non-members", %{
    room: room
  } do
    {:ok, _} = Chat.send_message(%{room_id: room.id, content: "backlog", sender: "a"})

    assert {:ok, %{persona: "new", count: 1, backlog_minutes: 5}} =
             Chat.Tools.JoinRoom.call(%{room_id: room.id, persona: "new"}, %{})

    assert {:ok, %{persona: "new"}} =
             Chat.Tools.LeaveRoom.call(%{room_id: room.id, persona: "new"}, %{})

    assert {:error, "Persona is not a member of this room"} =
             Chat.Tools.LeaveRoom.call(%{room_id: room.id, persona: "stranger"}, %{})
  end

  test "Chat.MuteRoom sets flags via the tool wrapper", %{room: room} do
    assert {:ok, %{muted: true, mute_unless_mentioned: false}} =
             Chat.Tools.MuteRoom.call(
               %{room_id: room.id, persona: "quiet", muted: true},
               %{}
             )
  end

  # ── DM ────────────────────────────────────────────────────────

  test "Chat.DM creates then reuses a DM; posts optional content; validates members", %{
    org_slug: org_slug
  } do
    assert {:ok, %{room_id: room_id, kind: "dm"}} =
             Chat.Tools.DM.call(%{organization: org_slug, members: ["a", "b"]}, %{})

    assert {:ok, %{room_id: ^room_id}} =
             Chat.Tools.DM.call(%{organization: org_slug, members: ["b", "a"]}, %{})

    assert {:ok, %{message_id: msg_id}} =
             Chat.Tools.DM.call(
               %{organization: org_slug, members: ["a", "b"], content: "hello", sender: "a"},
               %{}
             )

    assert is_binary(msg_id)

    assert {:error, "A DM requires at least 2 members"} =
             Chat.Tools.DM.call(%{organization: org_slug, members: ["solo"]}, %{})

    assert {:error, "Organization 'ghost' not found"} =
             Chat.Tools.DM.call(%{organization: "ghost", members: ["a", "b"]}, %{})
  end

  # ── Attach / AttachWiki / Pin / Highlight ─────────────────────

  test "Chat.Attach shares an artifact as an event + attachment", %{room: room} do
    assert {:ok, %{event_id: eid, attachment_id: aid}} =
             Chat.Tools.ChatAttach.call(
               %{room_id: room.id, artifact_id: Ecto.UUID.generate(), sender: "alice"},
               %{}
             )

    assert is_binary(eid) and is_binary(aid)

    # an unknown room fails the event FK -> error branch
    assert {:error, "Failed: " <> _} =
             Chat.Tools.ChatAttach.call(
               %{room_id: Ecto.UUID.generate(), artifact_id: Ecto.UUID.generate(), sender: "a"},
               %{}
             )
  end

  test "Chat.AttachWiki records a room attachment; unknown room errors", %{room: room} do
    assert {:ok, %{attachment_id: _, artifact_type: "url", url: "https://x"}} =
             Chat.Tools.AttachWiki.call(
               %{room_id: room.id, url: "https://x", sender: "a", artifact_type: "url"},
               %{}
             )

    assert {:error, "Room not found"} =
             Chat.Tools.AttachWiki.call(
               %{room_id: Ecto.UUID.generate(), url: "https://x", sender: "a"},
               %{}
             )
  end

  test "Chat.PinMessage and Chat.HighlightMessage toggle and report missing messages", %{
    room: room
  } do
    {:ok, msg} = Chat.send_message(%{room_id: room.id, content: "pin", sender: "a"})

    assert {:ok, %{pinned: true}} = Chat.Tools.PinMessage.call(%{message_id: msg.id}, %{})

    assert {:ok, %{pinned: false}} =
             Chat.Tools.PinMessage.call(%{message_id: msg.id, pinned: false}, %{})

    assert {:error, "Message not found"} =
             Chat.Tools.PinMessage.call(%{message_id: Ecto.UUID.generate()}, %{})

    assert {:ok, %{important: true, highlighted: true}} =
             Chat.Tools.HighlightMessage.call(%{message_id: msg.id, highlighted: true}, %{})

    assert {:error, "Message not found"} =
             Chat.Tools.HighlightMessage.call(%{message_id: Ecto.UUID.generate()}, %{})
  end

  # ── ScheduleMessage / ForwardReplies ──────────────────────────

  test "Chat.ScheduleMessage validates the when clause", %{room: room} do
    future = DateTime.add(DateTime.utc_now(), 3600, :second) |> DateTime.to_iso8601()

    assert {:ok, %{id: _}} =
             Chat.Tools.ScheduleMessage.call(
               %{room_id: room.id, content: "later", sender: "a", scheduled_for: future},
               %{}
             )

    assert {:ok, %{id: _}} =
             Chat.Tools.ScheduleMessage.call(
               %{room_id: room.id, content: "daily", sender: "a", time_of_day: "23:59"},
               %{}
             )

    assert {:error, "Provide scheduled_for (ISO8601) or time_of_day (HH:MM)"} =
             Chat.Tools.ScheduleMessage.call(%{room_id: room.id, content: "x", sender: "a"}, %{})

    assert {:error, "Invalid scheduled_for; expected ISO8601"} =
             Chat.Tools.ScheduleMessage.call(
               %{room_id: room.id, content: "x", sender: "a", scheduled_for: "not-a-date"},
               %{}
             )

    assert {:error, "Invalid time_of_day; expected HH:MM"} =
             Chat.Tools.ScheduleMessage.call(
               %{room_id: room.id, content: "x", sender: "a", time_of_day: "25:99"},
               %{}
             )
  end

  test "Chat.ForwardReplies copies a thread into another room", %{org_id: org_id, room: room} do
    {:ok, target} = Chat.create_room(%{organization_id: org_id, name: "Forward Target"})
    {:ok, parent} = Chat.send_message(%{room_id: room.id, content: "root", sender: "a"})

    {:ok, r1} =
      Chat.send_message(%{
        room_id: room.id,
        content: "r1",
        sender: "b",
        parent_message_id: parent.id
      })

    {:ok, _r2} =
      Chat.send_message(%{
        room_id: room.id,
        content: "r2",
        sender: "b",
        parent_message_id: parent.id
      })

    assert {:ok, %{forwarded_count: 2, thread_parent_id: header_id, forwarded_ids: ids}} =
             Chat.Tools.ForwardReplies.call(
               %{parent_message_id: parent.id, target_room_id: target.id, sender: "mover"},
               %{}
             )

    assert length(ids) == 2
    header = Chat.get_message(header_id)
    assert header.parent_message_id == nil
    assert header.content =~ "Forwarded thread"

    replies = Chat.list_replies(header_id)
    assert Enum.map(replies, & &1.content) == ["r1", "r2"]

    # existing target parent is reused when given
    {:ok, existing} = Chat.send_message(%{room_id: target.id, content: "anchor", sender: "m"})
    existing_id = existing.id

    assert {:ok, %{thread_parent_id: ^existing_id}} =
             Chat.Tools.ForwardReplies.call(
               %{
                 parent_message_id: parent.id,
                 target_room_id: target.id,
                 sender: "mover",
                 target_parent_id: existing.id
               },
               %{}
             ),
           "reuse branch"

    # a parent with no replies is an error
    {:ok, childless} = Chat.send_message(%{room_id: room.id, content: "none", sender: "a"})

    assert {:error, "No replies to forward under that message"} =
             Chat.Tools.ForwardReplies.call(
               %{parent_message_id: childless.id, target_room_id: target.id, sender: "m"},
               %{}
             )
  end

  # ── Notifications ─────────────────────────────────────────────

  test "Chat.Notifications + Chat.Notification.Clear", %{room: room} do
    alias NoizuPromptLingua.Schema.ChatNotification

    {:ok, n1} =
      %ChatNotification{}
      |> ChatNotification.changeset(%{room_id: room.id, persona: "pat", message: "one"})
      |> Repo.insert()

    {:ok, _} =
      %ChatNotification{}
      |> ChatNotification.changeset(%{room_id: room.id, persona: "pat", message: "two"})
      |> Repo.insert()

    assert {:ok, %{count: 2, notifications: [_ | _]}} =
             Chat.Tools.Notifications.call(%{persona: "pat"}, %{})

    assert {:ok, %{count: 0}} = Chat.Tools.Notifications.call(%{persona: "pat", limit: 0}, %{})

    assert {:ok, %{cleared: 1}} =
             Chat.Tools.NotificationClear.call(
               %{persona: "pat", notification_id: n1.id},
               %{}
             )

    assert {:error, "Notification not found"} =
             Chat.Tools.NotificationClear.call(
               %{persona: "pat", notification_id: Ecto.UUID.generate()},
               %{}
             )

    assert {:ok, %{cleared: 1}} = Chat.Tools.NotificationClear.call(%{persona: "pat"}, %{})
  end
end
