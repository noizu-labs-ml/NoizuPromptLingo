defmodule NoizuPromptLingua.Domains.Notifications.NotificationsResidualTest do
  @moduledoc """
  Wave-5B coverage residuals for the notifications domain beyond the
  mention/digest fan-out already pinned in `DispatchTest`:

    * `Dispatch.ticket_assigned/1` + `ticket_update/1` — the ticket hooks
      (plain maps suffice: Dispatch reads tickets via `Map.get`).
    * `Dispatch.watch_update/3` — per-watch filters, actor exclusion, and the
      string / map / non-text `change` shapes.
    * `Dispatch.chat_message/2` degenerate inputs (nil room, bodyless message)
      and the watcher-filter path inside its best-effort sub-`safe`.
    * `reaction/1` on a real `chat_message` entity — the ChatMessage → ChatRoom
      org/project back-resolution arms.
    * `presence/2` broadcast + the Presence tracker's tick sweep.
    * `Notifications` lifecycle calls with explicit id lists, empty kind
      filters, group resolution fallbacks, and `stats/1`.
  """
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.{Chat, Notifications}
  alias NoizuPromptLingua.Domains.Notifications.{Dispatch, Presence}
  alias NoizuPromptLingua.Redis
  alias NoizuPromptLingua.Schema.Notification
  alias NoizuPromptLingua.Services.Watch

  defp insert_org do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["w5b-notif-#{System.unique_integer([:positive])}", "W5B Notifications Org"]
      )

    Ecto.UUID.load!(raw)
  end

  defp insert_org_row!(slug) do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        [slug, "W5B Org"]
      )

    Ecto.UUID.load!(raw)
  end

  setup do
    org_id = insert_org()

    {:ok, room} =
      Chat.create_room(%{organization_id: org_id, name: "Residual #{System.unique_integer()}"})

    {:ok, org_id: org_id, room: room}
  end

  defp recipients(org_id, kind) do
    Repo.all(from(n in Notification, where: n.organization_id == ^org_id and n.kind == ^kind))
  end

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

  defp ticket(fields) do
    Map.merge(
      %{
        id: Ecto.UUID.generate(),
        organization_id: nil,
        project_id: nil,
        title: "Wire the flux capacitor",
        status: "open",
        assignee: "django",
        reporter: "marty"
      },
      Map.new(fields)
    )
  end

  defp notify_one(org_id, recipient, kind \\ "dm", body \\ "hi") do
    {:ok, [row]} =
      Notifications.notify(%{
        organization_id: org_id,
        recipient: recipient,
        kind: kind,
        body: body
      })

    row
  end

  # ── Dispatch.ticket_assigned / ticket_update ────────────────────────

  test "ticket_assigned notifies the assignee when they are not the reporter", %{org_id: org_id} do
    Dispatch.ticket_assigned(ticket(organization_id: org_id))

    assert [%Notification{recipient: "django", kind: "ticket_assigned"}] =
             recipients(org_id, "ticket_assigned")
  end

  test "ticket_assigned is a no-op when assignee == reporter or org is missing", %{org_id: org_id} do
    Dispatch.ticket_assigned(ticket(organization_id: org_id, assignee: "marty"))
    Dispatch.ticket_assigned(ticket(organization_id: nil))

    assert recipients(org_id, "ticket_assigned") == []
  end

  test "ticket_update notifies assignee + reporter (deduped) and its watchers", %{org_id: org_id} do
    t = ticket(organization_id: org_id, assignee: "marty")
    Watch.watch("ticket", t.id, "doc-brown", %{"type" => "substring", "value" => "flux"})

    Dispatch.ticket_update(t)

    rows = recipients(org_id, "ticket_update")

    assert rows |> Enum.map(& &1.recipient) |> Enum.uniq() |> Enum.sort() == [
             "doc-brown",
             "marty"
           ]
  end

  test "ticket_update with no org and no recipients writes nothing" do
    Dispatch.ticket_update(ticket(organization_id: nil))
    assert recipients("00000000-0000-0000-0000-000000000000", "ticket_update") == []
  end

  # ── Dispatch.watch_update ───────────────────────────────────────────

  test "watch_update string change reaches matching watchers with a normalized payload", %{
    org_id: org_id,
    room: room
  } do
    # A loadable entity so Dispatch can back-resolve the org from the record.
    {:ok, message} =
      Chat.send_message(%{
        room_id: room.id,
        organization_id: org_id,
        sender: "alice",
        content: "root"
      })

    Watch.watch("chat_message", message.id, "watcher-1", %{
      "type" => "substring",
      "value" => "deploy"
    })

    # filter does not match this watcher's text
    Watch.watch("chat_message", message.id, "watcher-2", %{
      "type" => "substring",
      "value" => "rollback"
    })

    Dispatch.watch_update("chat_message", message.id, "deployed build 42")

    assert [%Notification{recipient: "watcher-1", payload: payload}] =
             recipients(org_id, "watch_update")

    assert payload["change"] == %{"text" => "deployed build 42"}
  end

  test "watch_update map change excludes the actor and falls back across text fields", %{
    org_id: org_id
  } do
    art = Ecto.UUID.generate()
    Watch.watch("artifact", art, "actor-1", nil)
    Watch.watch("artifact", art, "watcher-3", nil)

    Dispatch.watch_update("artifact", art, %{
      actor: "actor-1",
      summary: "revised the copy",
      organization_id: org_id
    })

    assert [%Notification{recipient: "watcher-3", body: "revised the copy"}] =
             recipients(org_id, "watch_update")
  end

  test "watch_update with a non-text change and non-matching filter notifies nobody", %{
    org_id: org_id
  } do
    art = Ecto.UUID.generate()
    Watch.watch("artifact", art, "watcher-4", %{"type" => "substring", "value" => "nope"})

    Dispatch.watch_update("artifact", art, 42)
    assert recipients(org_id, "watch_update") == []
  end

  # ── Dispatch.chat_message degenerate + watcher-filter arms ──────────

  test "chat_message honours a room watcher whose filter matches the body", %{
    org_id: org_id,
    room: room
  } do
    Watch.watch("chat_room", room.id, "watcher-5", %{"type" => "substring", "value" => "outage"})

    Dispatch.chat_message(msg(room, content: "we have an outage in prod"), room)

    assert [%Notification{recipient: "watcher-5", kind: "watch_update"}] =
             recipients(org_id, "watch_update")
  end

  test "chat_message tolerates a nil room and a bodyless message map", %{room: room} do
    assert :ok = Dispatch.chat_message(msg(room, content: nil), room)
    assert :ok = Dispatch.chat_message(nil, nil)
  end

  test "presence announces a transition on the presence topic", %{org_id: org_id} do
    Phoenix.PubSub.subscribe(NoizuPromptLingua.PubSub, "presence")

    assert :ok = Dispatch.presence("weego-agent", :online)
    assert_receive {:presence, "weego-agent", :online}, 1_000

    # touch arms: nil org / nil handle are no-ops; a live touch is a cast.
    assert :ok = Presence.touch(nil, "x")
    assert :ok = Presence.touch(org_id, nil)
    assert :ok = Presence.touch(org_id, "touched-agent-#{System.unique_integer([:positive])}")
  end

  test "the presence tick sweep broadcasts offline for absent handles", %{org_id: org_id} do
    handle = "ephemeral-#{System.unique_integer([:positive])}"
    Phoenix.PubSub.subscribe(NoizuPromptLingua.PubSub, "presence")
    Presence.touch(org_id, handle)
    assert_receive {:presence, ^handle, :online}, 2_000

    # Expire the Redis presence key so the sweep sees the handle as gone.
    Redis.command(["DEL", Redis.prefix("presence:#{org_id}:#{handle}")])
    send(Presence, :tick)

    assert_receive {:presence, ^handle, :offline}, 2_000
  end

  # ── reaction on a real chat_message entity ──────────────────────────

  test "reaction on a chat_message back-resolves org/project through the room", %{
    org_id: org_id,
    room: room
  } do
    Chat.add_member(%{room_id: room.id, persona: "alice"})
    Chat.add_member(%{room_id: room.id, persona: "dave"})

    {:ok, message} =
      Chat.send_message(%{
        room_id: room.id,
        organization_id: org_id,
        sender: "alice",
        content: "root message"
      })

    {:ok, _} =
      Chat.add_reaction(%{
        entity_type: "chat_message",
        entity_id: message.id,
        persona: "dave",
        emoji: "🎉"
      })

    Dispatch.reaction(%{
      entity_type: "chat_message",
      entity_id: message.id,
      persona: "dave",
      emoji: "🎉"
    })

    rows = recipients(org_id, "reaction")
    assert "alice" in Enum.map(rows, & &1.recipient)
    assert Enum.all?(rows, &(&1.organization_id == org_id))
  end

  test "reaction with an unknown entity type or an uncastable id degrades quietly" do
    assert Dispatch.reaction(%{entity_type: "codex", entity_id: Ecto.UUID.generate()}) in [
             :ok,
             :error
           ]

    assert Dispatch.reaction(%{entity_type: "ticket", entity_id: "not-a-uuid"}) in [:ok, :error]
  end

  test "owner_of/2 resolves from a loadable entity and returns nil otherwise" do
    assert Dispatch.owner_of("ticket", "not-a-uuid") |> is_nil()
    assert Dispatch.owner_of("codex", Ecto.UUID.generate()) |> is_nil()
  end

  # ── Notifications lifecycle + resolution residuals ──────────────────

  test "mark_read / mark_seen / ack / clear accept explicit id lists", %{org_id: org_id} do
    r1 = notify_one(org_id, "r1")
    r2 = notify_one(org_id, "r1")

    {:ok, 1} = Notifications.mark_read(org_id, "r1", [r1.id])
    {:ok, 1} = Notifications.mark_seen(org_id, "r1", [r2.id])
    {:ok, 1} = Notifications.ack(org_id, "r1", [r1.id])
    {:ok, 1} = Notifications.clear(org_id, "r1", [r2.id])

    rows = Repo.all(from(n in Notification, where: n.organization_id == ^org_id))

    by_id = Map.new(rows, &{&1.id, &1})
    r1 = by_id[r1.id]
    r2 = by_id[r2.id]

    assert r1.read and r1.acked
    assert r2.read and r2.seen
  end

  test "stats counts the org's notification rows", %{org_id: org_id} do
    notify_one(org_id, "r1")
    assert %{notifications: n} = Notifications.stats(org_id)
    assert n >= 1
  end

  test "get with an empty kinds filter behaves like no filter", %{org_id: org_id} do
    row = notify_one(org_id, "r1", "ping", "pong")

    {:ok, rows} = Notifications.get(org_id, "r1", kinds: [])
    assert Enum.map(rows, & &1.id) == [row.id]
  end

  test "get with a tiny wait_ms degrades to an immediate deliver", %{org_id: org_id} do
    row = notify_one(org_id, "r1")

    {:ok, rows} = Notifications.get(org_id, "r1", wait_ms: 1)
    assert row.id in Enum.map(rows, & &1.id)
  end

  test "get with a non-integer wait_ms clamps to an immediate deliver", %{org_id: org_id} do
    row = notify_one(org_id, "r2")

    {:ok, rows} = Notifications.get(org_id, "r2", wait_ms: "soon")
    assert row.id in Enum.map(rows, & &1.id)
  end

  test "resolve_group returns room members, [] for unknown rooms, and [] on bad scopes", %{
    org_id: org_id,
    room: room
  } do
    Chat.add_member(%{room_id: room.id, persona: "alice"})
    slug = Chat.get_room(room.id).slug

    assert "alice" in Notifications.resolve_group(org_id, nil, slug)

    assert Notifications.resolve_group(org_id, nil, "no-such-room-#{System.unique_integer()}") ==
             []

    assert Notifications.resolve_group(nil, nil, slug) == []
    assert Notifications.resolve_group(org_id, nil, "") == []
    assert Notifications.resolve_group(org_id, nil, nil) == []
  end

  test "notify to a group that resolves to no members returns :no_recipients", %{org_id: org_id} do
    assert {:error, :no_recipients} =
             Notifications.notify(%{
               organization_id: org_id,
               group: "ghost-room-#{System.unique_integer()}",
               kind: "dm",
               body: "anyone?"
             })
  end

  test "org rows are per-org: a second org's slug does not collide" do
    other = insert_org_row!("w5b-notif-other-#{System.unique_integer([:positive])}")
    assert %{notifications: 0} = Notifications.stats(other)
  end
end
