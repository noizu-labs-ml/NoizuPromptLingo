defmodule NoizuPromptLingua.Domains.NotificationsTest do
  @moduledoc """
  Stream F (tests): per-recipient notification inbox — `Domains.Notifications`.

  Covers notify fan-out (recipient / recipients / group→room members), the
  128-char body cap on the short kinds (dm/ping/pong), the cursor pull
  (`seq > cursor`, next-cursor semantics), deliver_after future hiding (and
  `include_future`), the read/seen/ack/clear lifecycle, unread count, and
  dedup_key coalescing.

  Redis-backed rate-limit behaviour is exercised in the `@tag :redis` block —
  when Redis (`:6379`) is unavailable, `rate_limit_remaining/2` rescues to 0 so
  every other test here runs without it.
  """
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.{Notifications, Chat}
  alias NoizuPromptLingua.Schema.Notification

  # ── fixtures (raw SQL org; real chat rooms for group resolution) ──

  defp insert_org do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["notiforg-#{System.unique_integer([:positive])}", "Notif Test Org"]
      )

    Ecto.UUID.load!(raw)
  end

  setup do
    {:ok, org_id: insert_org()}
  end

  defp uniq(prefix), do: "#{prefix}-#{System.unique_integer([:positive])}"

  # ── notify fan-out ─────────────────────────────────────────────

  test "notify to a single recipient inserts one row", %{org_id: org_id} do
    rcpt = uniq("alice")

    {:ok, [row]} =
      Notifications.notify(%{organization_id: org_id, kind: "dm", recipient: rcpt, body: "hi"})

    assert row.recipient == rcpt
    assert row.kind == "dm"
    assert is_integer(row.seq)
  end

  test "notify to :recipients fans out one row per recipient", %{org_id: org_id} do
    a = uniq("a")
    b = uniq("b")

    {:ok, rows} =
      Notifications.notify(%{
        organization_id: org_id,
        kind: "share",
        recipients: [a, b],
        body: "team"
      })

    assert length(rows) == 2
    assert rows |> Enum.map(& &1.recipient) |> Enum.sort() == Enum.sort([a, b])
  end

  test "notify to a :group resolves to the chat room's members", %{org_id: org_id} do
    {:ok, room} =
      Chat.create_room(%{
        organization_id: org_id,
        name: "Group #{System.unique_integer([:positive])}"
      })

    members = [uniq("m1"), uniq("m2"), uniq("m3")]
    Enum.each(members, fn p -> Chat.add_member(%{room_id: room.id, persona: p}) end)

    {:ok, rows} =
      Notifications.notify(%{
        organization_id: org_id,
        kind: "share",
        group: room.slug,
        body: "all"
      })

    assert rows |> Enum.map(& &1.recipient) |> Enum.sort() == Enum.sort(members)
  end

  test "notify requires an org and at least one recipient" do
    assert {:error, :organization_required} = Notifications.notify(%{kind: "dm", recipient: "x"})
  end

  test "notify with no resolvable recipient returns :no_recipients", %{org_id: org_id} do
    assert {:error, :no_recipients} =
             Notifications.notify(%{organization_id: org_id, kind: "dm", recipients: []})
  end

  # ── 128-char body validation on short kinds ────────────────────

  test "body over 128 chars is rejected for dm/ping/pong, allowed for others", %{org_id: org_id} do
    long = String.duplicate("x", 129)

    # short kinds: insert fails the changeset → flat_map drops it → no rows
    for kind <- ~w(dm ping pong) do
      assert {:ok, []} =
               Notifications.notify(%{
                 organization_id: org_id,
                 kind: kind,
                 recipient: uniq("r"),
                 body: long
               })
    end

    # a non-short kind accepts a long body
    {:ok, [row]} =
      Notifications.notify(%{
        organization_id: org_id,
        kind: "watch_update",
        recipient: uniq("r"),
        body: long
      })

    assert String.length(row.body) == 129
  end

  test "a 128-char dm body is accepted (boundary)", %{org_id: org_id} do
    body = String.duplicate("y", 128)

    {:ok, [row]} =
      Notifications.notify(%{
        organization_id: org_id,
        kind: "dm",
        recipient: uniq("r"),
        body: body
      })

    assert String.length(row.body) == 128
  end

  # ── cursor pull ────────────────────────────────────────────────

  test "get returns rows with seq > cursor, ordered asc; cursor at head returns []", %{
    org_id: org_id
  } do
    rcpt = uniq("reader")

    {:ok, [r1]} =
      Notifications.notify(%{organization_id: org_id, kind: "share", recipient: rcpt, body: "1"})

    {:ok, [r2]} =
      Notifications.notify(%{organization_id: org_id, kind: "share", recipient: rcpt, body: "2"})

    {:ok, rows} = Notifications.get(org_id, rcpt, cursor: 0)
    assert Enum.map(rows, & &1.id) == [r1.id, r2.id]
    assert r1.seq < r2.seq

    # next_cursor == the last delivered seq; re-pulling past it yields nothing.
    next_cursor = rows |> List.last() |> Map.fetch!(:seq)
    assert {:ok, []} = Notifications.get(org_id, rcpt, cursor: next_cursor)

    # an intermediate cursor returns only the tail
    {:ok, tail} = Notifications.get(org_id, rcpt, cursor: r1.seq)
    assert Enum.map(tail, & &1.id) == [r2.id]
  end

  test "get can filter by :kinds", %{org_id: org_id} do
    rcpt = uniq("reader")

    {:ok, _} =
      Notifications.notify(%{
        organization_id: org_id,
        kind: "mention",
        recipient: rcpt,
        body: "m"
      })

    {:ok, _} =
      Notifications.notify(%{organization_id: org_id, kind: "share", recipient: rcpt, body: "s"})

    {:ok, rows} = Notifications.get(org_id, rcpt, kinds: ["mention"])
    assert Enum.map(rows, & &1.kind) == ["mention"]
  end

  # ── deliver_after future hiding ────────────────────────────────

  test "future deliver_after rows are hidden unless include_future", %{org_id: org_id} do
    rcpt = uniq("future")
    future = DateTime.utc_now() |> DateTime.add(3600, :second) |> DateTime.truncate(:second)

    {:ok, [row]} =
      Notifications.notify(%{
        organization_id: org_id,
        kind: "follow_up",
        recipient: rcpt,
        body: "later",
        deliver_after: future
      })

    # hidden by default
    assert {:ok, []} = Notifications.get(org_id, rcpt)

    # surfaced with include_future
    {:ok, [found]} = Notifications.get(org_id, rcpt, include_future: true)
    assert found.id == row.id
  end

  # ── lifecycle: read / seen / ack / clear ───────────────────────

  test "mark_read / mark_seen set flags; count reflects unread, due rows", %{org_id: org_id} do
    rcpt = uniq("lc")

    {:ok, [r1]} =
      Notifications.notify(%{organization_id: org_id, kind: "share", recipient: rcpt, body: "1"})

    {:ok, [_r2]} =
      Notifications.notify(%{organization_id: org_id, kind: "share", recipient: rcpt, body: "2"})

    assert Notifications.count(org_id, rcpt) == 2

    {:ok, 1} = Notifications.mark_read(org_id, rcpt, [r1.id])
    assert Repo.get(Notification, r1.id).read == true
    assert Notifications.count(org_id, rcpt) == 1

    {:ok, 1} = Notifications.mark_seen(org_id, rcpt, [r1.id])
    assert Repo.get(Notification, r1.id).seen == true
  end

  test "ack removes a row from future get deliveries", %{org_id: org_id} do
    rcpt = uniq("ack")

    {:ok, [r1]} =
      Notifications.notify(%{organization_id: org_id, kind: "share", recipient: rcpt, body: "1"})

    {:ok, [r2]} =
      Notifications.notify(%{organization_id: org_id, kind: "share", recipient: rcpt, body: "2"})

    {:ok, 1} = Notifications.ack(org_id, rcpt, [r1.id])
    {:ok, rows} = Notifications.get(org_id, rcpt)
    assert Enum.map(rows, & &1.id) == [r2.id]
  end

  test "clear marks all rows read", %{org_id: org_id} do
    rcpt = uniq("clear")

    {:ok, _} =
      Notifications.notify(%{organization_id: org_id, kind: "share", recipient: rcpt, body: "1"})

    {:ok, _} =
      Notifications.notify(%{organization_id: org_id, kind: "share", recipient: rcpt, body: "2"})

    {:ok, 2} = Notifications.clear(org_id, rcpt)
    assert Notifications.count(org_id, rcpt) == 0
  end

  # ── dedup_key coalescing ───────────────────────────────────────

  test "two notifies with the same dedup_key coalesce into one unread row", %{org_id: org_id} do
    rcpt = uniq("dedup")
    key = "digest:#{rcpt}"

    {:ok, [first]} =
      Notifications.notify(%{
        organization_id: org_id,
        kind: "chat_digest",
        recipient: rcpt,
        dedup_key: key,
        body: "a"
      })

    {:ok, [second]} =
      Notifications.notify(%{
        organization_id: org_id,
        kind: "chat_digest",
        recipient: rcpt,
        dedup_key: key,
        body: "b"
      })

    # same physical row, seq bumped, payload.count incremented to 2
    assert second.id == first.id
    assert second.seq > first.seq
    assert second.payload["count"] == 2

    rows =
      Repo.all(
        from(n in Notification, where: n.organization_id == ^org_id and n.recipient == ^rcpt)
      )

    assert length(rows) == 1
  end

  test "ids_for_dedup / ack_dedup target the coalesced row", %{org_id: org_id} do
    rcpt = uniq("dd")
    key = "k:#{rcpt}"

    {:ok, [row]} =
      Notifications.notify(%{
        organization_id: org_id,
        kind: "pubsub_available",
        recipient: rcpt,
        dedup_key: key,
        body: "x"
      })

    assert Notifications.ids_for_dedup(org_id, rcpt, key) == [row.id]
    assert {:ok, 1} = Notifications.ack_dedup(org_id, rcpt, key)
    assert Notifications.ids_for_dedup(org_id, rcpt, key) == []
  end

  # ── rate-limit (needs Redis on :6379) ──────────────────────────

  describe "delivery rate-limit (Redis)" do
    @describetag :redis

    test "a second get within the window is throttled", %{org_id: org_id} do
      rcpt = uniq("rl")

      {:ok, _} =
        Notifications.notify(%{
          organization_id: org_id,
          kind: "share",
          recipient: rcpt,
          body: "1"
        })

      # first non-empty delivery stamps the window
      assert {:ok, [_]} = Notifications.get(org_id, rcpt, cursor: 0)
      # second call within @rate_limit_ms is throttled
      assert {:throttled, ms} = Notifications.get(org_id, rcpt, cursor: 0)
      assert is_integer(ms) and ms > 0
    end
  end
end
