defmodule NoizuPromptLingua.Domains.Notifications.PollTest do
  @moduledoc """
  Stream F (tests): the Monitor/long-poll variant `Notifications.poll/3`.

  A held poll subscribes to `notifications:<org>` and blocks until a `notify/1`
  broadcasts a wake (or `:wait_ms` elapses). We spawn a task that notifies ~300ms
  in, and assert the poll returns the row well under the 5s backstop cadence.

  `async: false` — the spawned task must share the sandbox connection (shared
  ownership mode), and the Phoenix.PubSub broadcast crosses processes.
  """
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.Notifications

  defp insert_org do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["pollorg-#{System.unique_integer([:positive])}", "Poll Test Org"]
      )

    Ecto.UUID.load!(raw)
  end

  setup do
    {:ok, org_id: insert_org()}
  end

  test "poll wakes in well under 5s when a notify is published mid-wait", %{org_id: org_id} do
    rcpt = "poll-#{System.unique_integer([:positive])}"

    parent = self()

    spawn(fn ->
      # Let the parent enter its poll/wait_loop first.
      Process.sleep(300)

      {:ok, _rows} =
        Notifications.notify(%{
          organization_id: org_id,
          kind: "dm",
          recipient: rcpt,
          body: "ping"
        })

      send(parent, :notified)
    end)

    {elapsed_us, result} =
      :timer.tc(fn -> Notifications.poll(org_id, rcpt, wait_ms: 4_000) end)

    assert {:ok, [row]} = result
    assert row.recipient == rcpt
    assert row.kind == "dm"

    # Woke via the PubSub broadcast, not the 5s backstop / 4s wait ceiling.
    assert elapsed_us < 4_000_000, "poll should wake on publish, took #{div(elapsed_us, 1000)}ms"

    assert_received :notified
  end

  test "poll with wait_ms <= 0 degrades to an immediate get", %{org_id: org_id} do
    rcpt = "imm-#{System.unique_integer([:positive])}"

    {:ok, _} =
      Notifications.notify(%{
        organization_id: org_id,
        kind: "share",
        recipient: rcpt,
        body: "now"
      })

    assert {:ok, [row]} = Notifications.poll(org_id, rcpt, wait_ms: 0)
    assert row.recipient == rcpt
  end
end
