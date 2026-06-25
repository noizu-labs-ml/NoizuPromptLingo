defmodule NoizuPromptLingua.Domains.Pipes.ChatBridgeTest do
  @moduledoc """
  Chat→pipe bridge + cursor-based Pipe.Input. Proves a chat message fans out into
  each room member's pipe, that the entries are pullable with a monotonic cursor,
  and that re-polling with the returned next_cursor returns only newer entries.
  """
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.{Chat, Pipes}

  # ── fixtures (raw SQL; the bridge/cursor work doesn't depend on the MCP layer) ──

  defp insert_org do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["pipeorg-#{System.unique_integer([:positive])}", "Pipe Bridge Test Org"]
      )

    Ecto.UUID.load!(raw)
  end

  defp insert_room(org_id) do
    {:ok, room} =
      Chat.create_room(%{organization_id: org_id, name: "Project Coordination #{System.unique_integer([:positive])}"})

    room
  end

  defp add_member(room_id, persona) do
    {:ok, _} = Chat.add_member(%{room_id: room_id, persona: persona, role: "member"})
    persona
  end

  setup do
    org_id = insert_org()
    room = insert_room(org_id)
    n = add_member(room.id, "member-n-#{System.unique_integer([:positive])}")
    m = add_member(room.id, "member-m-#{System.unique_integer([:positive])}")
    sender = add_member(room.id, "sender-#{System.unique_integer([:positive])}")
    {:ok, org_id: org_id, room: room, n: n, m: m, sender: sender}
  end

  test "a chat message fans out to every member except the sender", ctx do
    {:ok, _msg} =
      Chat.send_message(%{room_id: ctx.room.id, sender: ctx.sender, content: "kickoff — what are we shipping?"})

    n_entries = Pipes.pull(ctx.org_id, ctx.n, cursor: 0)
    m_entries = Pipes.pull(ctx.org_id, ctx.m, cursor: 0)
    sender_entries = Pipes.pull(ctx.org_id, ctx.sender, cursor: 0)

    assert length(n_entries) == 1, "member N should receive the message"
    assert length(m_entries) == 1, "member M should receive the message"
    assert sender_entries == [], "the sender should NOT receive their own message"

    body = Jason.decode!(hd(n_entries).body)
    assert body["type"] == "chat.message"
    assert body["sender"] == ctx.sender
    assert body["content"] == "kickoff — what are we shipping?"
    assert body["room_id"] == ctx.room.id
    assert body["message_id"]
  end

  test "cursor round-trips: second pull with next_cursor returns only newer entries", ctx do
    # First message → first pull from cursor 0.
    {:ok, _} = Chat.send_message(%{room_id: ctx.room.id, sender: ctx.sender, content: "first"})

    first = Pipes.pull(ctx.org_id, ctx.n, cursor: 0)
    assert length(first) == 1
    cursor1 = List.last(first).seq
    assert is_integer(cursor1) and cursor1 > 0

    # Re-poll at the high-water mark — nothing new yet.
    assert Pipes.pull(ctx.org_id, ctx.n, cursor: cursor1) == []

    # Second + third messages.
    {:ok, _} = Chat.send_message(%{room_id: ctx.room.id, sender: ctx.sender, content: "second"})
    {:ok, _} = Chat.send_message(%{room_id: ctx.room.id, sender: ctx.sender, content: "third"})

    newer = Pipes.pull(ctx.org_id, ctx.n, cursor: cursor1)
    assert length(newer) == 2, "only the two messages after cursor1 should return"

    seqs = Enum.map(newer, & &1.seq)
    assert seqs == Enum.sort(seqs), "entries come back in monotonic seq ASC order"
    assert Enum.all?(seqs, &(&1 > cursor1)), "every returned entry is strictly newer than the cursor"

    contents = Enum.map(newer, fn e -> Jason.decode!(e.body)["content"] end)
    assert contents == ["second", "third"]
  end

  test "an updated entry (same message_name) resurfaces past the reader's cursor", ctx do
    # Bridge uses a unique message_name per row, so chat traffic never collapses.
    # This exercises the resurface-on-conflict invariant directly at the push layer.
    name = "manual.note:#{System.unique_integer([:positive])}"

    {:ok, _} =
      Pipes.push(%{
        organization_id: ctx.org_id,
        sender_handle: ctx.sender,
        message_name: name,
        target_agent_handle: ctx.n,
        body: ~s({"v":1})
      })

    [e1] = Pipes.pull(ctx.org_id, ctx.n, cursor: 0)
    cursor = e1.seq

    # Nothing newer at the high-water mark...
    assert Pipes.pull(ctx.org_id, ctx.n, cursor: cursor) == []

    # ...until the same (sender, message_name, target) is re-pushed: it must
    # float back into the feed with a fresh seq > cursor.
    {:ok, _} =
      Pipes.push(%{
        organization_id: ctx.org_id,
        sender_handle: ctx.sender,
        message_name: name,
        target_agent_handle: ctx.n,
        body: ~s({"v":2})
      })

    resurfaced = Pipes.pull(ctx.org_id, ctx.n, cursor: cursor)
    assert length(resurfaced) == 1
    assert hd(resurfaced).seq > cursor
    assert Jason.decode!(hd(resurfaced).body)["v"] == 2
  end

  test "Pipe.Input tool returns next_cursor and per-message seq", ctx do
    {:ok, _} = Chat.send_message(%{room_id: ctx.room.id, sender: ctx.sender, content: "hello N"})

    {:ok, res} =
      NoizuPromptLingua.Domains.Pipes.Tools.Input.call(
        %{organization: ctx.org_id, agent: ctx.n, cursor: 0},
        %{}
      )

    assert res.count == 1
    assert is_integer(res.next_cursor) and res.next_cursor > 0
    [msg] = res.messages
    assert msg.seq == res.next_cursor
    assert msg.message_name =~ "chat.message:"

    # Re-poll at next_cursor → empty, cursor echoed back unchanged.
    {:ok, res2} =
      NoizuPromptLingua.Domains.Pipes.Tools.Input.call(
        %{organization: ctx.org_id, agent: ctx.n, cursor: res.next_cursor},
        %{}
      )

    assert res2.count == 0
    assert res2.next_cursor == res.next_cursor
  end
end
