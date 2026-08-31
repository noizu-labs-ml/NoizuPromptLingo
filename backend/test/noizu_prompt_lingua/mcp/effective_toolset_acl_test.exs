defmodule NoizuPromptLingua.MCP.EffectiveToolsetAclTest do
  @moduledoc """
  Debt D2 — the ACL override layer on EffectiveToolset (`mcp.tool` rules as a
  FINAL pass over the config cascade). Guarantees under test:

    * no user_ref => byte-identical legacy behavior
    * user with NO rules => unchanged (the critical compat invariant)
    * explicit deny beats config allow
    * explicit allow never overrides config disabled
    * group-based deny (via transitive membership expansion)
    * tool kind-wildcard + scope-wide denies
    * state/6 hot path + KeyToolsets.state ctx seam
  """

  use NoizuPromptLingua.DataCase, async: true

  require Noizu.EntityReference.Records
  alias Noizu.EntityReference.Records, as: R

  alias Noizu.MCP.Ctx
  alias NoizuPromptLingua.Acl
  alias NoizuPromptLingua.MCP.EffectiveToolset
  alias NoizuPromptLingua.MCP.KeyToolsets
  alias NoizuPromptLingua.MCPCustomScopes
  alias NoizuPromptLingua.Schema.MCPCustomScope
  alias NoizuPromptLingua.Schema.McpTool

  @tool "Ticket.List"
  @tool_canonical "Ticket_List"
  @group "tickets"
  @action "mcp.tool"

  defp uid, do: Ecto.UUID.generate()
  defp user_ref, do: R.ref(module: NoizuPromptLingua.Users.User, id: uid())

  defp tool_ref(name \\ @tool_canonical), do: R.ref(module: McpTool, id: name)

  defp scope_config(groups) when is_map(groups), do: %{"groups" => groups}

  defp create_scope(slug, config) do
    {:ok, scope} =
      MCPCustomScopes.create(%{
        "slug" => slug,
        "name" => slug,
        "kind" => "custom",
        "config" => config
      })

    scope
  end

  defp rule!(subject_ref, resource_ref, effect) do
    {:ok, _} =
      Acl.create_rule(%{
        subject_ref: subject_ref,
        resource_ref: resource_ref,
        action: @action,
        effect: effect
      })
  end

  defp group_with_member!(member) do
    {:ok, group} =
      Acl.create_group(%{
        name: "acl-d2-" <> Ecto.UUID.generate(),
        ref: R.ref(module: NoizuPromptLingua.Projects.Project, id: Ecto.UUID.generate())
      })

    {:ok, _} = Acl.add_member(group, member)
    group
  end

  defp lookup(scope, client, user),
    do: EffectiveToolset.lookup(EffectiveToolset.resolve(scope, client, user), @tool)

  # ── compat invariants ───────────────────────────────────────────────────────

  describe "compat (no ACL rules in play)" do
    test "nil user_ref ignores ACL rules entirely (legacy behavior)" do
      scope = create_scope("acme", scope_config(%{@group => %{"tools" => %{@tool => %{}}}}))
      rule!(user_ref(), tool_ref(), "deny")

      state = lookup(scope, nil, nil)
      assert state == EffectiveToolset.default_state()
    end

    test "user with NO rules is a no-op (critical invariant)" do
      scope = create_scope("acme", scope_config(%{@group => %{"tools" => %{@tool => %{"hidden" => true}}}}))
      state = lookup(scope, nil, user_ref())

      refute state.visible
      assert state.enabled
    end

    test "user with no rules + cascade flags keeps cascade state verbatim" do
      scope = create_scope("acme", scope_config(%{@group => %{"disabled" => true}}))

      for spec <-
            NoizuPromptLingua.Domains.Tickets.MCP.__mcp__(:tools)
            |> Noizu.MCP.Server.Features.Tools.expand()
            |> Enum.reject(&EffectiveToolset.ungated_category?(&1)) do
        refute EffectiveToolset.lookup(EffectiveToolset.resolve(scope, nil, user_ref()), spec.definition.name).enabled
      end
    end
  end

  # ── precedence vs the config cascade ────────────────────────────────────────

  describe "ACL vs config cascade" do
    test "explicit deny wins over config allow (hides + disables)" do
      scope =
        create_scope(
          "acme",
          scope_config(%{@group => %{"tools" => %{@tool => %{"disabled" => false, "hidden" => false}}}})
        )

      denied_user = user_ref()
      rule!(denied_user, tool_ref(), "deny")

      state = lookup(scope, nil, denied_user)
      refute state.enabled
      refute state.visible

      # per-user: everyone else keeps the config state
      assert lookup(scope, nil, user_ref()).enabled
    end

    test "explicit allow does NOT override config disabled" do
      scope = create_scope("acme", scope_config(%{@group => %{"tools" => %{@tool => %{"disabled" => true}}}}))
      rule!(user_ref(), tool_ref(), "allow")

      state = lookup(scope, nil, user_ref())
      refute state.enabled
    end

    test "deny is per-tool (other tools unaffected)" do
      scope = create_scope("acme", scope_config(%{@group => %{"tools" => %{}}}))
      user = user_ref()
      rule!(user, tool_ref(), "deny")

      states = EffectiveToolset.resolve(scope, nil, user)
      refute EffectiveToolset.lookup(states, @tool).enabled

      other = Enum.find(states, fn {name, _} -> name != @tool_canonical end)
      assert other
      assert elem(other, 1).enabled
    end
  end

  # ── wildcards + scope knob ──────────────────────────────────────────────────

  describe "wildcards + scope-wide deny" do
    test "tool kind wildcard (:any) denies every tool" do
      scope = create_scope("acme", scope_config(%{@group => %{"tools" => %{}}}))
      user = user_ref()
      rule!(user, R.ref(module: McpTool, id: :any), "deny")

      states = EffectiveToolset.resolve(scope, nil, user)
      assert states != %{}
      assert Enum.all?(Map.values(states), fn st -> not st.enabled end)
    end

    test "scope resource deny disables every tool the scope serves" do
      scope = create_scope("acme", scope_config(%{@group => %{"tools" => %{}}}))
      user = user_ref()
      rule!(user, R.ref(module: MCPCustomScope, id: scope.id), "deny")

      states = EffectiveToolset.resolve(scope, nil, user)
      assert states != %{}
      assert Enum.all?(Map.values(states), fn st -> not st.enabled and not st.visible end)
    end
  end

  # ── group membership ────────────────────────────────────────────────────────

  describe "group-based denies (W6 permission groups)" do
    test "deny rule on the group ref denies its members" do
      scope = create_scope("acme", scope_config(%{@group => %{"tools" => %{}}}))
      user = user_ref()
      group = group_with_member!(user)
      rule!(group.ref, tool_ref(), "deny")

      state = lookup(scope, nil, user)
      refute state.enabled
      refute state.visible

      # non-members keep the config state
      assert lookup(scope, nil, user_ref()).enabled
    end

    test "nested group membership expands transitively" do
      scope = create_scope("acme", scope_config(%{@group => %{"tools" => %{}}}))
      user = user_ref()
      inner = group_with_member!(user)
      outer = group_with_member!(inner.ref)

      # deny on the OUTER group only — inner membership pulls it in.
      rule!(outer.ref, tool_ref(), "deny")

      refute lookup(scope, nil, user).enabled
    end
  end

  # ── hot path + ctx seam ─────────────────────────────────────────────────────

  describe "state/6 hot path + ctx seams" do
    test "state/6 applies the deny; state/5 (no user) does not" do
      scope = create_scope("acme", scope_config(%{@group => %{"tools" => %{}}}))

      id = uid()
      user = R.ref(module: NoizuPromptLingua.Users.User, id: id)
      rule!(user, tool_ref(), "deny")

      at = DateTime.utc_now()
      refute EffectiveToolset.state(@group, @tool, scope, nil, user, at).enabled
      assert EffectiveToolset.state(@group, @tool, scope, nil, at).enabled
      # bare binary user id normalizes to a Users.User ref
      refute EffectiveToolset.state(@group, @tool, scope, nil, id, at).enabled
    end

    test "KeyToolsets.state/3 (ToolGuard seam) enforces the deny via ctx claims" do
      scope = create_scope("acme", scope_config(%{@group => %{"tools" => %{}}}))
      id = uid()
      rule!(R.ref(module: NoizuPromptLingua.Users.User, id: id), tool_ref(), "deny")

      ctx = %Ctx{
        server: NoizuPromptLingua.MCP,
        assigns: %{custom_scope_slug: "acme", auth_claims: %{"sub" => id}}
      }

      assert KeyToolsets.state(@group, @tool, ctx).disabled

      ctx_no_user = %Ctx{
        server: NoizuPromptLingua.MCP,
        assigns: %{custom_scope_slug: "acme", auth_claims: %{}}
      }

      refute KeyToolsets.state(@group, @tool, ctx_no_user).disabled
    end

    test "service principals (svc:/client: subs) get no ACL pass" do
      create_scope("acme", scope_config(%{@group => %{"tools" => %{}}}))
      rule!(user_ref(), tool_ref(), "deny")

      ctx = %Ctx{
        server: NoizuPromptLingua.MCP,
        assigns: %{custom_scope_slug: "acme", auth_claims: %{"sub" => "client:abc"}}
      }

      refute KeyToolsets.state(@group, @tool, ctx).disabled
    end
  end
end
