defmodule NoizuPromptLingua.Domains.Notifications.DispatchTest do
  @moduledoc """
  Stream F (tests): `Notifications.Dispatch` fan-out from chat events.

    * `chat_message` — `@everyone`/`@handle` → immediate `mention`; ordinary
      traffic → coalesced `chat_digest` with a ~5min `deliver_after`; muted
      members get nothing; `mute_unless_mentioned` members get only mentions.
    * `reaction` / `comment` — notify the entity owner + its watchers
      (`Services.Watch`), excluding the actor.

  Dispatch hooks are best-effort (`safe/1` always returns `:ok`); we assert on
  the inbox rows they write rather than the return value.
  """
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.{Chat, Notifications}
  alias NoizuPromptLingua.Domains.Notifications.Dispatch
  alias NoizuPromptLingua.Services.Watch
  alias NoizuPromptLingua.Schema.Notification

  defp insert_org do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["disporg-#{System.unique_integer([:positive])}", "Dispatch Test Org"]
      )

    Ecto.UUID.load!(raw)
  end

  setup do
    org_id = insert_org()

    {:ok, room} =
      Chat.create_room(%{
        organization_id: org_id,
        name: "Room #{System.unique_integer([:positive])}"
      })

    for p <- ~w(alice bob carol) do
      Chat.add_member(%{room_id: room.id, persona: p})
    end

    {:ok, org_id: org_id, room: room}
  end

  # An in-memory chat message; Dispatch reads via Map.get, so a plain map is fine.
  defp msg(room, fields) do
    Map.merge(
      %{
        id: Ecto.UUID.generate(),
        room_id: room.id,
        content: "",
        sender: "alice",
        parent_message_id: nil
      },
      Map.new(fields)
    )
  end

  defp rows_for(org_id, recipient) do
    Repo.all(
      from(n in Notification, where: n.organization_id == ^org_id and n.recipient == ^recipient)
    )
  end

  defp kinds_for(org_id, recipient),
    do: rows_for(org_id, recipient) |> Enum.map(& &1.kind) |> Enum.sort()

  # ── mentions ──────────────────────────────────────────────────

  test "@handle mention produces an immediate `mention` row for the mentioned member", %{
    org_id: org_id,
    room: room
  } do
    :ok =
      Dispatch.chat_message(msg(room, content: "hey @bob look at this", sender: "alice"), room)

    bob = rows_for(org_id, "bob")
    assert [%{kind: "mention", deliver_after: nil}] = bob
    # carol was not mentioned and gets a (future) digest instead — not a mention
    refute "mention" in kinds_for(org_id, "carol")
  end

  test "@everyone mentions every member except the sender", %{org_id: org_id, room: room} do
    :ok = Dispatch.chat_message(msg(room, content: "@everyone standup", sender: "alice"), room)

    assert "mention" in kinds_for(org_id, "bob")
    assert "mention" in kinds_for(org_id, "carol")
    # sender never notifies self
    assert rows_for(org_id, "alice") == []
  end

  # ── digest ────────────────────────────────────────────────────

  test "ordinary message coalesces into a chat_digest with a ~5min deliver_after", %{
    org_id: org_id,
    room: room
  } do
    :ok = Dispatch.chat_message(msg(room, content: "just chatting", sender: "alice"), room)

    [digest] = rows_for(org_id, "bob")
    assert digest.kind == "chat_digest"
    assert digest.dedup_key == "chat_digest:#{room.id}"
    refute is_nil(digest.deliver_after)

    delay_s = DateTime.diff(digest.deliver_after, DateTime.utc_now())
    assert delay_s > 240 and delay_s <= 300, "digest should land ~5min out, got #{delay_s}s"
  end

  test "a second ordinary message coalesces onto the same digest row", %{
    org_id: org_id,
    room: room
  } do
    :ok = Dispatch.chat_message(msg(room, content: "one", sender: "alice"), room)
    :ok = Dispatch.chat_message(msg(room, content: "two", sender: "alice"), room)

    digests = rows_for(org_id, "bob") |> Enum.filter(&(&1.kind == "chat_digest"))
    assert length(digests) == 1
    assert hd(digests).payload["count"] == 2
  end

  # ── mute semantics ────────────────────────────────────────────

  test "a fully muted member receives neither mentions nor digests", %{org_id: org_id, room: room} do
    {:ok, _} = Chat.mute_room(room.id, "bob", muted: true)

    :ok = Dispatch.chat_message(msg(room, content: "@bob ping", sender: "alice"), room)
    :ok = Dispatch.chat_message(msg(room, content: "ordinary", sender: "alice"), room)

    assert rows_for(org_id, "bob") == []
  end

  test "mute_unless_mentioned suppresses digests but still delivers mentions", %{
    org_id: org_id,
    room: room
  } do
    {:ok, _} = Chat.mute_room(room.id, "carol", mute_unless_mentioned: true)

    # ordinary traffic → carol gets nothing
    :ok = Dispatch.chat_message(msg(room, content: "ambient noise", sender: "alice"), room)
    assert rows_for(org_id, "carol") == []

    # explicit mention → carol gets the mention
    :ok = Dispatch.chat_message(msg(room, content: "@carol urgent", sender: "alice"), room)
    assert "mention" in kinds_for(org_id, "carol")
  end

  # ── reaction / comment watchers ───────────────────────────────

  test "reaction notifies the message owner and its watchers (not the actor)", %{
    org_id: org_id,
    room: room
  } do
    {:ok, message} = Chat.send_message(%{room_id: room.id, sender: "alice", content: "reactable"})
    {:ok, _} = Watch.watch("chat_message", message.id, "bob")

    :ok =
      Dispatch.reaction(%{
        entity_type: "chat_message",
        entity_id: message.id,
        persona: "carol",
        emoji: "🚀"
      })

    # owner alice + watcher bob each get a `reaction` row; actor carol does not
    assert "reaction" in kinds_for(org_id, "alice")
    assert "reaction" in kinds_for(org_id, "bob")
    refute "reaction" in kinds_for(org_id, "carol")
  end

  test "comment notifies the message owner and its watchers", %{org_id: org_id, room: room} do
    {:ok, message} =
      Chat.send_message(%{room_id: room.id, sender: "alice", content: "commentable"})

    {:ok, _} = Watch.watch("chat_message", message.id, "bob")

    :ok =
      Dispatch.comment(%{
        entity_type: "chat_message",
        entity_id: message.id,
        persona: "carol",
        content: "nice"
      })

    assert "comment" in kinds_for(org_id, "alice")
    assert "comment" in kinds_for(org_id, "bob")
  end
end
