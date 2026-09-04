defmodule NoizuPromptLingua.Domains.Chat.DomainGapsTest do
  @moduledoc """
  Coverage for Chat domain branches the message/thread/reaction suites don't
  reach: room deletion via the binary-id clause + event-reaction sweep,
  backfill_slugs, list_rooms filters, events, notifications, attachments,
  join/rejoin, and the flag-toggle not_found paths.
  """
  use NoizuPromptLingua.DataCase, async: true

  alias NoizuPromptLingua.Domains.Chat
  alias NoizuPromptLingua.Schema.ChatNotification
  alias NoizuPromptLingua.Services.Attach

  setup do
    org_id = Ecto.UUID.generate()
    {:ok, room} = Chat.create_room(%{organization_id: org_id, name: "Gap Suite"})
    {:ok, org_id: org_id, room: room}
  end

  # ── delete_room (binary clause + event sweep) ─────────────────

  test "delete_room/1 on a binary id deletes and sweeps event reactions too", %{room: room} do
    {:ok, event} =
      Chat.create_event(%{
        room_id: room.id,
        event_type: "action",
        content: "did a thing",
        sender: "alice"
      })

    {:ok, _} =
      Chat.add_reaction(%{
        entity_type: "chat_event",
        entity_id: event.id,
        persona: "bob",
        emoji: "🎉"
      })

    assert {:ok, deleted} = Chat.delete_room(room.id)
    assert deleted.id == room.id
    assert Chat.get_room(room.id) == nil
    assert Chat.get_message(event.id) == nil
    assert Chat.list_reactions("chat_event", event.id) == []
  end

  test "delete_room/1 with an unknown binary id is :not_found" do
    assert {:error, :not_found} = Chat.delete_room(Ecto.UUID.generate())
  end

  # ── backfill_slugs ────────────────────────────────────────────

  test "backfill_slugs/1 fills NULL slugs with suffix ordering and is idempotent", %{
    org_id: org_id,
    room: room
  } do
    # 052 ships slug NOT NULL (post-backfill state); the backfill targets the
    # pre-052 deployment. DDL is transactional in Postgres, so relax it inside
    # this test's sandbox transaction only.
    Repo.query!("ALTER TABLE chat_rooms ALTER COLUMN slug DROP NOT NULL")

    {:ok, twin} = Chat.create_room(%{organization_id: org_id, name: "Gap Suite"})
    base = room.slug

    Repo.query!("UPDATE chat_rooms SET slug = NULL WHERE id IN ($1, $2)", [
      Ecto.UUID.dump!(room.id),
      Ecto.UUID.dump!(twin.id)
    ])

    assert Chat.backfill_slugs() >= 2

    slug_a = Chat.get_room(room.id).slug
    slug_b = Chat.get_room(twin.id).slug
    assert slug_a not in [nil, ""]
    assert slug_b not in [nil, ""]
    assert slug_a != slug_b
    # first room backfilled keeps the bare base; the twin gets the -2 ordinal
    assert Enum.sort([slug_a, slug_b]) == Enum.sort([base, base <> "-2"])

    # second run fills nothing
    assert Chat.backfill_slugs() == 0
  end

  # ── list_rooms filters + room_count ───────────────────────────

  test "list_rooms/1 filters by org, project, session, kind and windows", %{org_id: org_id} do
    project_id = Ecto.UUID.generate()
    session_id = Ecto.UUID.generate()

    {:ok, proj_room} =
      Chat.create_room(%{organization_id: org_id, project_id: project_id, name: "Proj Room"})

    {:ok, dm} = Chat.create_room(%{organization_id: org_id, kind: "dm", name: "DM Room"})

    {:ok, session_room} =
      Chat.create_room(%{organization_id: org_id, session_id: session_id, name: "S"})

    assert Enum.any?(Chat.list_rooms(organization_id: org_id), &(&1.id == proj_room.id))

    assert Enum.map(Chat.list_rooms(organization_id: org_id, project_id: project_id), & &1.id) ==
             [proj_room.id]

    assert Enum.map(Chat.list_rooms(organization_id: org_id, session_id: session_id), & &1.id) ==
             [session_room.id]

    assert Enum.map(Chat.list_rooms(organization_id: org_id, kind: "dm"), & &1.id) == [dm.id]

    assert length(Chat.list_rooms(organization_id: org_id, limit: 2)) == 2
    assert length(Chat.list_rooms(organization_id: org_id, limit: 1, offset: 1)) == 1
    # other orgs are invisible
    assert Chat.list_rooms(organization_id: Ecto.UUID.generate()) == []

    assert Chat.room_count() == 4
  end

  # ── messages: recent + list filters ───────────────────────────

  test "recent_messages/3 returns only messages inside the window, oldest first", %{room: room} do
    {:ok, _} = Chat.send_message(%{room_id: room.id, content: "one", sender: "a"})
    {:ok, _} = Chat.send_message(%{room_id: room.id, content: "two", sender: "a"})

    recent = Chat.recent_messages(room.id, 5)
    assert Enum.map(recent, & &1.content) == ["one", "two"]
    assert length(Chat.recent_messages(room.id, 0, limit: 1)) <= 1
  end

  test "list_messages/2 honors before/after/top_level/limit", %{room: room} do
    {:ok, first} = Chat.send_message(%{room_id: room.id, content: "first", sender: "a"})
    {:ok, _} = Chat.send_message(%{room_id: room.id, content: "second", sender: "a"})

    {:ok, _} =
      Chat.send_message(%{
        room_id: room.id,
        content: "reply",
        sender: "b",
        parent_message_id: first.id
      })

    cutoff = DateTime.add(first.inserted_at, 1, :microsecond) |> DateTime.to_iso8601()

    after_first = Chat.list_messages(room.id, after: cutoff)
    assert Enum.any?(after_first, &(&1.content == "second"))
    refute Enum.any?(after_first, &(&1.content == "first"))

    before_second = Chat.list_messages(room.id, before: cutoff)
    assert Enum.any?(before_second, &(&1.content == "first"))
    refute Enum.any?(before_second, &(&1.content == "second"))

    assert length(Chat.list_messages(room.id, top_level: true)) == 2
    assert length(Chat.list_messages(room.id, limit: 1)) == 1
  end

  test "pin_message/highlight_message on an unknown message are :not_found", %{room: room} do
    {:ok, msg} = Chat.send_message(%{room_id: room.id, content: "pin me", sender: "a"})
    assert {:error, :not_found} = Chat.pin_message(Ecto.UUID.generate())
    assert {:error, :not_found} = Chat.highlight_message(Ecto.UUID.generate(), true)

    # explicit-set branch on an existing message (toggle covered elsewhere)
    assert {:ok, %{highlighted: true}} = Chat.highlight_message(msg.id, true)
    assert {:ok, %{highlighted: false}} = Chat.highlight_message(msg.id, false)
  end

  # ── events ────────────────────────────────────────────────────

  test "create_event rejects a missing sender; list_events filters by type + since", %{
    room: room
  } do
    assert {:error, %Ecto.Changeset{}} =
             Chat.create_event(%{room_id: room.id, event_type: "todo", content: "x"})

    {:ok, action} =
      Chat.create_event(%{room_id: room.id, event_type: "action", content: "a", sender: "s"})

    {:ok, _todo} =
      Chat.create_event(%{room_id: room.id, event_type: "todo", content: "t", sender: "s"})

    assert Enum.map(Chat.list_events(room.id, event_type: "action"), & &1.id) == [action.id]

    after_action =
      Chat.list_events(room.id,
        since: DateTime.to_iso8601(DateTime.add(action.inserted_at, 1, :millisecond))
      )

    refute Enum.any?(after_action, &(&1.id == action.id))
    assert length(Chat.list_events(room.id, limit: 1)) == 1
  end

  # ── membership ────────────────────────────────────────────────

  test "join_room inserts the membership and clears left_at on rejoin", %{room: room} do
    assert {:ok, member} = Chat.join_room(room.id, "newcomer")
    assert member.left_at == nil
    assert Chat.get_member(room.id, "newcomer").id == member.id

    {:ok, _} = Chat.leave_room(room.id, "newcomer")
    assert Chat.get_member(room.id, "newcomer").left_at != nil

    assert {:ok, rejoined} = Chat.join_room(room.id, "newcomer")
    assert rejoined.left_at == nil
  end

  # ── reactions: error + summary branches ───────────────────────

  test "add_reaction without an emoji is a changeset error", %{room: room} do
    {:ok, msg} = Chat.send_message(%{room_id: room.id, content: "x", sender: "a"})

    assert {:error, %Ecto.Changeset{}} =
             Chat.add_reaction(%{
               entity_type: "chat_message",
               entity_id: msg.id,
               persona: "a"
             })
  end

  # ── notifications ─────────────────────────────────────────────

  test "notifications: list unread, clear one (ownership enforced), clear all", %{room: room} do
    {:ok, n1} =
      %ChatNotification{}
      |> ChatNotification.changeset(%{room_id: room.id, persona: "carol", message: "ping"})
      |> Repo.insert()

    {:ok, _n2} =
      %ChatNotification{}
      |> ChatNotification.changeset(%{room_id: room.id, persona: "carol", message: "pong"})
      |> Repo.insert()

    {:ok, other} =
      %ChatNotification{}
      |> ChatNotification.changeset(%{room_id: room.id, persona: "dave", message: "hi"})
      |> Repo.insert()

    unread = Chat.list_notifications("carol")
    assert length(unread) == 2
    assert hd(unread).room.id == room.id
    assert Chat.list_notifications("nobody") == []
    assert length(Chat.list_notifications("carol", limit: 1)) == 1

    # another persona cannot clear carol's notification
    assert {:error, :not_found} = Chat.clear_notification("dave", n1.id)
    assert {:error, :not_found} = Chat.clear_notification("carol", Ecto.UUID.generate())

    assert {:ok, _} = Chat.clear_notification("carol", n1.id)
    assert length(Chat.list_notifications("carol")) == 1

    assert {:ok, 1} = Chat.clear_all_notifications("carol")
    assert Chat.list_notifications("carol") == []
    # dave's notification is untouched by carol's clear-all
    refute Repo.get!(ChatNotification, other.id).read
  end

  # ── attachments ───────────────────────────────────────────────

  test "room_attachments lists attachments recorded against the room", %{room: room} do
    assert Chat.room_attachments(room.id) == []

    {:ok, att} =
      Attach.add("chat_room", room.id, %{
        artifact_type: "wiki",
        url: "https://wiki.example/pg",
        created_by: "alice"
      })

    assert [%{id: id}] = Chat.room_attachments(room.id)
    assert id == att.id
  end

  # ── slug bucket lookup (project bucket predicate) ─────────────

  test "get_room_by_slug/3 resolves in the project bucket separately", %{org_id: org_id} do
    project_id = Ecto.UUID.generate()

    {:ok, room} =
      Chat.create_room(%{
        organization_id: org_id,
        project_id: project_id,
        name: "Bucket Probe"
      })

    assert Chat.get_room_by_slug(org_id, project_id, room.slug).id == room.id
    # the org-level (NULL-project) bucket does not see the project room
    assert Chat.get_room_by_slug(org_id, nil, room.slug) == nil
  end
end
