defmodule NoizuPromptLingua.Domains.Pipes.ScopeFilterTest do
  @moduledoc """
  Direct/group/broadcast scope isolation on Pipe.Input (ticket 24a47be9).

  Proves a caller can pull ONLY its direct messages (or only group / only
  broadcast) instead of the inclusive direct+group+broadcast union, and that the
  Input tool tags every returned message with its resolved scope.
  """
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.Pipes
  alias NoizuPromptLingua.Domains.Pipes.Tools.Input

  defp insert_org do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["scopeorg-#{System.unique_integer([:positive])}", "Pipe Scope Test Org"]
      )

    Ecto.UUID.load!(raw)
  end

  defp push(org_id, attrs) do
    {:ok, _} =
      Pipes.push(
        Map.merge(
          %{organization_id: org_id, sender_handle: "lead", body: ~s({"k":"v"})},
          attrs
        )
      )
  end

  setup do
    org_id = insert_org()
    me = "soren-#{System.unique_integer([:positive])}"
    group = "work-group-#{System.unique_integer([:positive])}"

    # one of each addressing scope
    push(org_id, %{message_name: "dm", target_agent_handle: me})
    push(org_id, %{message_name: "grp", target_group: group})
    push(org_id, %{message_name: "bcast"})
    # a DM to someone else — must never reach `me`
    push(org_id, %{message_name: "other-dm", target_agent_handle: "not-me"})

    {:ok, org_id: org_id, me: me, group: group}
  end

  test "scope :all is the inclusive union (back-compat)", ctx do
    names =
      Pipes.pull(ctx.org_id, ctx.me, groups: [ctx.group], include_broadcast: true, scope: :all)
      |> Enum.map(& &1.message_name)
      |> Enum.sort()

    assert names == ["bcast", "dm", "grp"]
  end

  test "default (no scope opt) preserves legacy union", ctx do
    names =
      Pipes.pull(ctx.org_id, ctx.me, groups: [ctx.group], include_broadcast: true)
      |> Enum.map(& &1.message_name)
      |> Enum.sort()

    assert names == ["bcast", "dm", "grp"]
  end

  test "scope :direct returns ONLY the DM addressed to this agent", ctx do
    entries = Pipes.pull(ctx.org_id, ctx.me, groups: [ctx.group], include_broadcast: true, scope: :direct)
    assert Enum.map(entries, & &1.message_name) == ["dm"]
    # the DM addressed to someone else is excluded
    refute "other-dm" in Enum.map(entries, & &1.message_name)
  end

  test "scope :group returns ONLY group traffic for the agent's groups", ctx do
    entries = Pipes.pull(ctx.org_id, ctx.me, groups: [ctx.group], scope: :group)
    assert Enum.map(entries, & &1.message_name) == ["grp"]
  end

  test "scope :group with no groups returns nothing", ctx do
    assert Pipes.pull(ctx.org_id, ctx.me, groups: [], scope: :group) == []
  end

  test "scope :broadcast returns ONLY untargeted entries", ctx do
    entries = Pipes.pull(ctx.org_id, ctx.me, groups: [ctx.group], scope: :broadcast)
    assert Enum.map(entries, & &1.message_name) == ["bcast"]
  end

  test "scope_of/1 classifies each entry", ctx do
    by_name =
      Pipes.pull(ctx.org_id, ctx.me, groups: [ctx.group], include_broadcast: true)
      |> Map.new(fn e -> {e.message_name, Pipes.scope_of(e)} end)

    assert by_name["dm"] == :direct
    assert by_name["grp"] == :group
    assert by_name["bcast"] == :broadcast
  end

  test "Input tool honors scope string and tags messages with scope", ctx do
    {:ok, res} =
      Input.call(
        %{organization: ctx.org_id, agent: ctx.me, groups: [ctx.group], scope: "direct"},
        %{}
      )

    assert res.count == 1
    [msg] = res.messages
    assert msg.message_name == "dm"
    assert msg.scope == :direct
    assert msg.target_agent == ctx.me
  end

  test "Input tool default scope returns the union, each message scope-tagged", ctx do
    {:ok, res} =
      Input.call(
        %{organization: ctx.org_id, agent: ctx.me, groups: [ctx.group], include_broadcast: true},
        %{}
      )

    scopes = res.messages |> Enum.map(& &1.scope) |> Enum.sort()
    assert scopes == [:broadcast, :direct, :group]
  end
end
