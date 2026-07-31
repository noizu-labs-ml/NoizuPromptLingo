defmodule NoizuPromptLingua.Domains.ChatTest do
  @moduledoc """
  Chat domain (marcus-dev surface): emoji reactions over the polymorphic npl_reactions
  table (idempotent add, remove, list, counts) + batched message reaction summaries.

  NOTE: slug generation/uniqueness is owned by lucia-backend (ticket 0b2b1b46) with the
  canonical property-based slugify/collision suite owned by sofia-qa (bc10f471). Slug is
  intentionally NOT asserted here beyond create_room succeeding.
  """
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.Chat

  # ── fixtures (raw SQL; we only need real org/room rows) ──

  defp insert_org do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["chatorg-#{System.unique_integer([:positive])}", "Chat Test Org"]
      )

    Ecto.UUID.load!(raw)
  end

  setup do
    {:ok, org_id: insert_org()}
  end

  # ── reactions ─────────────────────────────────────────────────

  defp room_with_message(org_id) do
    {:ok, room} =
      Chat.create_room(%{
        organization_id: org_id,
        name: "Reactions #{System.unique_integer([:positive])}"
      })

    {:ok, msg} = Chat.send_message(%{room_id: room.id, sender: "alice", content: "ship it"})
    msg
  end

  test "add_reaction is idempotent on (entity, persona, emoji)", %{org_id: org_id} do
    msg = room_with_message(org_id)
    attrs = %{entity_type: "chat_message", entity_id: msg.id, persona: "bob", emoji: "👍"}

    {:ok, r1} = Chat.add_reaction(attrs)
    {:ok, r2} = Chat.add_reaction(attrs)

    assert r1.id == r2.id, "re-adding the same reaction returns the existing row"
    assert length(Chat.list_reactions("chat_message", msg.id)) == 1
  end

  test "distinct personas/emoji accumulate; counts group by emoji", %{org_id: org_id} do
    msg = room_with_message(org_id)

    {:ok, _} =
      Chat.add_reaction(%{
        entity_type: "chat_message",
        entity_id: msg.id,
        persona: "bob",
        emoji: "👍"
      })

    {:ok, _} =
      Chat.add_reaction(%{
        entity_type: "chat_message",
        entity_id: msg.id,
        persona: "carol",
        emoji: "👍"
      })

    {:ok, _} =
      Chat.add_reaction(%{
        entity_type: "chat_message",
        entity_id: msg.id,
        persona: "bob",
        emoji: "🚀"
      })

    assert length(Chat.list_reactions("chat_message", msg.id)) == 3
    assert Chat.reaction_counts("chat_message", msg.id) == %{"👍" => 2, "🚀" => 1}
  end

  test "remove_reaction deletes only the matching row, 404 when absent", %{org_id: org_id} do
    msg = room_with_message(org_id)

    {:ok, _} =
      Chat.add_reaction(%{
        entity_type: "chat_message",
        entity_id: msg.id,
        persona: "bob",
        emoji: "👍"
      })

    assert Chat.remove_reaction("chat_message", msg.id, "bob", "👍") == :ok
    assert Chat.list_reactions("chat_message", msg.id) == []
    assert Chat.remove_reaction("chat_message", msg.id, "bob", "👍") == {:error, :not_found}
  end

  test "message_reaction_summaries batches counts + per-caller me flag", %{org_id: org_id} do
    m1 = room_with_message(org_id)
    m2 = room_with_message(org_id)

    {:ok, _} =
      Chat.add_reaction(%{
        entity_type: "chat_message",
        entity_id: m1.id,
        persona: "bob",
        emoji: "👍"
      })

    {:ok, _} =
      Chat.add_reaction(%{
        entity_type: "chat_message",
        entity_id: m1.id,
        persona: "carol",
        emoji: "👍"
      })

    {:ok, _} =
      Chat.add_reaction(%{
        entity_type: "chat_message",
        entity_id: m1.id,
        persona: "bob",
        emoji: "🚀"
      })

    # m2 has no reactions → absent from the map

    summaries = Chat.message_reaction_summaries([m1.id, m2.id], "bob")

    assert Map.get(summaries, m2.id) == nil
    s1 = Enum.sort_by(Map.fetch!(summaries, m1.id), & &1.emoji)

    assert s1 == [
             %{emoji: "👍", count: 2, me: true},
             %{emoji: "🚀", count: 1, me: true}
           ]

    # carol reacted only with 👍 → me:false on 🚀
    s1_carol =
      Map.fetch!(Chat.message_reaction_summaries([m1.id], "carol"), m1.id)
      |> Enum.sort_by(& &1.emoji)

    assert s1_carol == [
             %{emoji: "👍", count: 2, me: true},
             %{emoji: "🚀", count: 1, me: false}
           ]
  end

  test "reactions are partitioned by entity_type so messages and events don't collide", %{
    org_id: org_id
  } do
    msg = room_with_message(org_id)

    {:ok, _} =
      Chat.add_reaction(%{
        entity_type: "chat_message",
        entity_id: msg.id,
        persona: "bob",
        emoji: "👍"
      })

    {:ok, _} =
      Chat.add_reaction(%{
        entity_type: "chat_event",
        entity_id: msg.id,
        persona: "bob",
        emoji: "👍"
      })

    assert length(Chat.list_reactions("chat_message", msg.id)) == 1
    assert length(Chat.list_reactions("chat_event", msg.id)) == 1
  end
end
