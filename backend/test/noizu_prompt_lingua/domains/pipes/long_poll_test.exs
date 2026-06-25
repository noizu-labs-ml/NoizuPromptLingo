defmodule NoizuPromptLingua.Domains.Pipes.LongPollTest do
  @moduledoc """
  Pipe.Input long-poll (ticket 51378fb6): a caller with no new messages blocks
  until a matching entry is published (woken instantly via PubSub) or the
  timeout elapses, and existing immediate-return callers are unaffected.

  async: false + shared-mode sandbox so the spawned waiter processes can use the
  test's DB connection.
  """
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.Pipes
  alias NoizuPromptLingua.Domains.Pipes.Tools.Input

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})

    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["lporg-#{System.unique_integer([:positive])}", "LongPoll Test Org"]
      )

    org_id = Ecto.UUID.load!(raw)
    {:ok, org_id: org_id, me: "soren-#{System.unique_integer([:positive])}"}
  end

  defp push(org_id, name, attrs) do
    {:ok, e} =
      Pipes.push(
        Map.merge(
          %{organization_id: org_id, sender_handle: "lead", message_name: name, body: ~s({"k":"v"})},
          attrs
        )
      )

    e
  end

  test "wait_ms <= 0 falls through to an immediate pull", ctx do
    push(ctx.org_id, "x", %{target_agent_handle: ctx.me})
    assert [%{message_name: "x"}] = Pipes.pull_wait(ctx.org_id, ctx.me, wait_ms: 0)
  end

  test "returns immediately when data is already present, even with a long wait", ctx do
    push(ctx.org_id, "x", %{target_agent_handle: ctx.me})
    t0 = System.monotonic_time(:millisecond)
    assert [%{message_name: "x"}] = Pipes.pull_wait(ctx.org_id, ctx.me, wait_ms: 180_000)
    assert System.monotonic_time(:millisecond) - t0 < 1_000, "must not block when data exists"
  end

  test "blocks then returns empty on timeout when nothing arrives", ctx do
    t0 = System.monotonic_time(:millisecond)
    assert [] = Pipes.pull_wait(ctx.org_id, ctx.me, cursor: 0, wait_ms: 400)
    elapsed = System.monotonic_time(:millisecond) - t0
    assert elapsed >= 350, "should have held ~400ms, held #{elapsed}ms"
    assert elapsed < 3_000
  end

  test "a long-poller wakes immediately when a matching message is published", ctx do
    parent = self()

    spawn(fn ->
      t = System.monotonic_time(:millisecond)
      res = Pipes.pull_wait(ctx.org_id, ctx.me, cursor: 0, wait_ms: 30_000)
      send(parent, {:woke, res, System.monotonic_time(:millisecond) - t})
    end)

    Process.sleep(200)
    entry = push(ctx.org_id, "ding", %{target_agent_handle: ctx.me})

    assert_receive {:woke, res, dt}, 10_000
    assert [%{message_name: "ding", seq: seq}] = res
    assert seq == entry.seq
    assert dt < 5_000, "should wake via PubSub well under the 5s backstop, took #{dt}ms"
  end

  test "a publish addressed to a different agent does NOT return; the caller's own does", ctx do
    parent = self()

    spawn(fn ->
      res = Pipes.pull_wait(ctx.org_id, ctx.me, cursor: 0, wait_ms: 30_000, scope: :direct)
      send(parent, {:woke, res})
    end)

    Process.sleep(200)
    push(ctx.org_id, "not-for-me", %{target_agent_handle: "someone-else"})
    refute_receive {:woke, _}, 800, "must not return on a publish addressed to another agent"

    mine = push(ctx.org_id, "for-me", %{target_agent_handle: ctx.me})
    assert_receive {:woke, res}, 10_000
    assert [%{message_name: "for-me", seq: seq}] = res
    assert seq == mine.seq
  end

  test "Input tool threads wait/wait_ms and tags scope", ctx do
    push(ctx.org_id, "toolmsg", %{target_agent_handle: ctx.me})

    {:ok, res} =
      Input.call(%{organization: ctx.org_id, agent: ctx.me, wait: true, wait_ms: 30_000}, %{})

    assert res.count == 1
    assert [%{message_name: "toolmsg", scope: :direct}] = res.messages
  end

  test "Input tool without wait keeps the immediate-return behavior", ctx do
    # nothing published; immediate empty, no block
    t0 = System.monotonic_time(:millisecond)
    {:ok, res} = Input.call(%{organization: ctx.org_id, agent: ctx.me}, %{})
    assert res.count == 0
    assert System.monotonic_time(:millisecond) - t0 < 1_000
  end
end
