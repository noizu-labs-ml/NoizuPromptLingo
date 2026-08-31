defmodule NoizuPromptLingua.Acl.ResolverTest do
  @moduledoc """
  Pure (no-DB) tests for the ACL resolver semantics and the ERPRef Ecto type.
  """

  use ExUnit.Case, async: true

  alias NoizuPromptLingua.Acl.ERPRef
  alias NoizuPromptLingua.Acl.Resolver

  require Noizu.EntityReference.Records
  alias Noizu.EntityReference.Records, as: R

  @uid Ecto.UUID.generate()
  @wid Ecto.UUID.generate()
  @other_wid Ecto.UUID.generate()

  @user R.ref(module: NoizuPromptLingua.Users.User, id: @uid)
  @wiki R.ref(module: NoizuPromptLingua.Projects.Project, id: @wid)
  @other_wiki R.ref(module: NoizuPromptLingua.Projects.Project, id: @other_wid)
  @group_a R.ref(module: NoizuPromptLingua.Acl.Group, id: Ecto.UUID.generate())
  @group_b R.ref(module: NoizuPromptLingua.Acl.Group, id: Ecto.UUID.generate())

  defp rule(overrides) do
    Map.merge(
      %{
        subject_ref: @user,
        resource_ref: @wiki,
        action: "project.read",
        effect: "allow",
        scope: nil,
        priority: 0,
        status: "active"
      },
      Map.new(overrides, fn {k, v} -> {k, v} end)
    )
  end

  # ── ERPRef type ─────────────────────────────────────────────────────

  describe "ERPRef type" do
    test "casts a ref record" do
      assert {:ok, @user} = ERPRef.cast(@user)
    end

    test "casts an entity struct through the ERP protocol" do
      assert {:ok, ref} = ERPRef.cast(%NoizuPromptLingua.Users.User{id: @uid})
      assert ref == R.ref(module: NoizuPromptLingua.Users.User, id: @uid)
    end

    test "rejects junk" do
      assert :error = ERPRef.cast("not-a-ref")
      assert :error = ERPRef.cast(42)
      assert {:ok, nil} = ERPRef.cast(nil)
    end

    test "dump/load round-trips" do
      {:ok, dumped} = ERPRef.dump(@user)
      assert dumped == %{"type" => "NoizuPromptLingua.Users.User", "id" => @uid}
      assert {:ok, @user} = ERPRef.load(dumped)
    end

    test "wildcard kind and id round-trip" do
      global = R.ref(module: :any, id: :any)
      {:ok, dumped} = ERPRef.dump(global)
      assert dumped == %{"type" => "any", "id" => "any"}
      assert {:ok, ^global} = ERPRef.load(dumped)

      kind_wild = R.ref(module: NoizuPromptLingua.Projects.Project, id: :any)
      {:ok, dumped} = ERPRef.dump(kind_wild)
      assert {:ok, ^kind_wild} = ERPRef.load(dumped)
    end

    test "unknown module strings do not load" do
      assert :error = ERPRef.load(%{"type" => "Never.Loaded.Module", "id" => "x"})
    end
  end

  # ── Resolver semantics ──────────────────────────────────────────────

  describe "resolver" do
    test "direct grant" do
      rules = [rule([])]
      assert {:allow, _} = Resolver.evaluate(rules, [@user], "project.read", @wiki)
      assert Resolver.allowed?(rules, [@user], "project.read", @wiki)
    end

    test "no match defaults to deny" do
      assert {:deny, :default} = Resolver.evaluate([], [@user], "project.read", @wiki)
      refute Resolver.allowed?([], [@user], "project.read", @wiki)
    end

    test "default can be flipped to allow" do
      assert {:allow, :default} =
               Resolver.evaluate([], [@user], "project.read", @wiki, default: :allow)
    end

    test "direct deny wins over allow" do
      rules = [
        rule(effect: "allow"),
        rule(effect: "deny", priority: -5)
      ]

      assert {:deny, matched} = Resolver.evaluate(rules, [@user], "project.read", @wiki)
      assert matched.effect == "deny"
    end

    test "deny wins regardless of priority" do
      rules = [
        rule(effect: "deny", priority: 0),
        rule(effect: "allow", priority: 100)
      ]

      assert {:deny, _} = Resolver.evaluate(rules, [@user], "project.read", @wiki)
    end

    test "action must match exactly unless wildcard" do
      rules = [rule([])]
      assert {:deny, :default} = Resolver.evaluate(rules, [@user], "project.write", @wiki)

      wild = [rule(action: "*")]
      assert {:allow, _} = Resolver.evaluate(wild, [@user], "project.write", @wiki)
    end

    test "group grants apply via subject candidates" do
      rules = [rule(subject_ref: @group_a)]
      assert {:allow, _} = Resolver.evaluate(rules, [@user, @group_a], "project.read", @wiki)
      assert {:deny, :default} = Resolver.evaluate(rules, [@user], "project.read", @wiki)
    end

    test "multi-group union" do
      rules = [
        rule(subject_ref: @group_a, action: "project.read"),
        rule(subject_ref: @group_b, action: "project.write")
      ]

      subjects = [@user, @group_a, @group_b]
      assert Resolver.allowed?(rules, subjects, "project.read", @wiki)
      assert Resolver.allowed?(rules, subjects, "project.write", @wiki)
      assert {:deny, :default} = Resolver.evaluate(rules, subjects, "project.delete", @wiki)
    end

    test "group deny wins over direct allow" do
      rules = [
        rule(subject_ref: @user, effect: "allow"),
        rule(subject_ref: @group_a, effect: "deny")
      ]

      subjects = [@user, @group_a]
      assert {:deny, _} = Resolver.evaluate(rules, subjects, "project.read", @wiki)
    end

    test "resource kind wildcard matches any id of the kind" do
      rules = [rule(resource_ref: R.ref(module: NoizuPromptLingua.Projects.Project, id: :any))]
      assert Resolver.allowed?(rules, [@user], "project.read", @wiki)
      assert Resolver.allowed?(rules, [@user], "project.read", @other_wiki)

      assert {:deny, :default} =
               Resolver.evaluate(rules, [@user], "project.read", R.ref(module: NoizuPromptLingua.Organizations.Organization, id: @wid))
    end

    test "global wildcard rule matches every resource" do
      rules = [rule(resource_ref: R.ref(module: :any, id: :any), action: "*")]
      assert Resolver.allowed?(rules, [@user], "anything.atall", @wiki)
      assert Resolver.allowed?(rules, [@user], "whatever", @other_wiki)
    end

    test "exact resource does not leak to other ids" do
      rules = [rule([])]
      assert {:deny, :default} = Resolver.evaluate(rules, [@user], "project.read", @other_wiki)
    end

    test "scope filtering" do
      rules = [rule(scope: "mcp")]
      assert Resolver.allowed?(rules, [@user], "project.read", @wiki, scope: "mcp")
      assert {:deny, :default} = Resolver.evaluate(rules, [@user], "project.read", @wiki, scope: "wiki")
      # nil-scope requests see only nil-scope rules
      assert {:deny, :default} = Resolver.evaluate(rules, [@user], "project.read", @wiki)
      global = [rule(scope: nil)]
      assert Resolver.allowed?(global, [@user], "project.read", @wiki)
      assert Resolver.allowed?(global, [@user], "project.read", @wiki, scope: "mcp")
    end

    test "archived rules are ignored" do
      rules = [rule(status: "archived")]
      assert {:deny, :default} = Resolver.evaluate(rules, [@user], "project.read", @wiki)
    end

    test "top-priority rule is reported among winning effect" do
      rules = [
        rule(effect: "allow", priority: 1),
        rule(effect: "allow", priority: 50)
      ]

      assert {:allow, matched} = Resolver.evaluate(rules, [@user], "project.read", @wiki)
      assert matched.priority == 50
    end

    test "explain reports all matches" do
      rules = [
        rule(effect: "allow", priority: 1),
        rule(effect: "allow", priority: 50),
        rule(effect: "deny", subject_ref: @group_a)
      ]

      subjects = [@user, @group_a]
      explanation = Resolver.explain(rules, subjects, "project.read", @wiki)

      assert explanation.verdict == :deny
      assert explanation.matched.deny != []
      assert length(explanation.matched.allow) == 2
    end
  end
end
