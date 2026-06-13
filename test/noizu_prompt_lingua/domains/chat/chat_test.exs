defmodule NoizuPromptLingua.Domains.ChatTest do
  use NoizuPromptLingua.DataCase, async: true

  alias NoizuPromptLingua.Domains.Chat

  defp create_room(attrs \\ %{}) do
    Chat.create_room(Map.merge(%{name: "Test Room"}, attrs))
  end

  describe "rooms" do
    test "create_room/1 creates a room" do
      assert {:ok, room} = create_room(%{name: "General", description: "Main room"})
      assert room.name == "General"
    end

    test "get_room/1 returns a room" do
      {:ok, room} = create_room()
      assert Chat.get_room(room.id).id == room.id
    end

    test "list_rooms/1 returns rooms" do
      {:ok, _} = create_room()
      assert length(Chat.list_rooms()) >= 1
    end

    test "list_rooms/1 filters by session_id" do
      sid = Ecto.UUID.generate()
      {:ok, _} = create_room(%{session_id: sid})
      {:ok, _} = create_room()
      rooms = Chat.list_rooms(session_id: sid)
      assert Enum.all?(rooms, &(&1.session_id == sid))
    end

    test "room_count/0 returns count" do
      {:ok, _} = create_room()
      assert Chat.room_count() >= 1
    end
  end

  describe "messages" do
    test "send_message/1 and list_messages/2" do
      {:ok, room} = create_room()
      {:ok, msg} = Chat.send_message(%{room_id: room.id, content: "Hello", sender: "alice"})
      assert msg.content == "Hello"

      msgs = Chat.list_messages(room.id)
      assert length(msgs) == 1
      assert hd(msgs).sender == "alice"
    end

    test "list_messages/2 respects limit" do
      {:ok, room} = create_room()
      for i <- 1..5, do: Chat.send_message(%{room_id: room.id, content: "Msg #{i}", sender: "bob"})
      assert length(Chat.list_messages(room.id, limit: 2)) == 2
    end
  end

  describe "events" do
    test "create_event/1 and list_events/2" do
      {:ok, room} = create_room()
      {:ok, ev} = Chat.create_event(%{room_id: room.id, event_type: "todo", content: "Fix bug", sender: "alice"})
      assert ev.event_type == "todo"

      events = Chat.list_events(room.id)
      assert length(events) == 1
    end

    test "list_events/2 filters by event_type" do
      {:ok, room} = create_room()
      Chat.create_event(%{room_id: room.id, event_type: "todo", content: "A", sender: "x"})
      Chat.create_event(%{room_id: room.id, event_type: "decision", content: "B", sender: "x"})

      todos = Chat.list_events(room.id, event_type: "todo")
      assert length(todos) == 1
      assert hd(todos).event_type == "todo"
    end
  end

  describe "members" do
    test "add_member/1 and list_members/1" do
      {:ok, room} = create_room()
      {:ok, _} = Chat.add_member(%{room_id: room.id, persona: "alice"})
      {:ok, _} = Chat.add_member(%{room_id: room.id, persona: "bob", role: "admin"})

      members = Chat.list_members(room.id)
      assert length(members) == 2
      personas = Enum.map(members, & &1.persona)
      assert "alice" in personas
      assert "bob" in personas
    end

    test "add_member/1 is idempotent" do
      {:ok, room} = create_room()
      Chat.add_member(%{room_id: room.id, persona: "alice"})
      Chat.add_member(%{room_id: room.id, persona: "alice"})
      assert length(Chat.list_members(room.id)) == 1
    end
  end

  describe "notifications" do
    test "list_notifications/2 and clear" do
      {:ok, room} = create_room()
      Repo.insert!(%NoizuPromptLingua.Schema.ChatNotification{room_id: room.id, persona: "alice", message: "New msg"})

      notifs = Chat.list_notifications("alice")
      assert length(notifs) == 1

      {:ok, count} = Chat.clear_all_notifications("alice")
      assert count == 1
      assert Chat.list_notifications("alice") == []
    end

    test "clear_notification/2 clears single" do
      {:ok, room} = create_room()
      n = Repo.insert!(%NoizuPromptLingua.Schema.ChatNotification{room_id: room.id, persona: "bob", message: "Ping"})

      assert {:ok, _} = Chat.clear_notification("bob", n.id)
      assert Chat.list_notifications("bob") == []
    end

    test "clear_notification/2 rejects wrong persona" do
      {:ok, room} = create_room()
      n = Repo.insert!(%NoizuPromptLingua.Schema.ChatNotification{room_id: room.id, persona: "alice", message: "X"})
      assert {:error, :not_found} = Chat.clear_notification("bob", n.id)
    end
  end
end
