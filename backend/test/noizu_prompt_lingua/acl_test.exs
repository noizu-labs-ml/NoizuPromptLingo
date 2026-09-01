defmodule NoizuPromptLingua.AclTest do
  @moduledoc """
  DB-backed tests for the ACL context: group/member/rule CRUD, group
  expansion (incl. nested + multi-group), and end-to-end `resolve/4` through
  the sandboxed repo.
  """

  use NoizuPromptLingua.DataCase, async: true

  require Noizu.EntityReference.Records
  alias Noizu.EntityReference.Records, as: R

  alias NoizuPromptLingua.Acl
  alias NoizuPromptLingua.Acl.ERPRef

  @user_kind NoizuPromptLingua.Users.User
  @project_kind NoizuPromptLingua.Projects.Project

  defp uid, do: Ecto.UUID.generate()
  defp user_ref, do: R.ref(module: @user_kind, id: uid())
  defp project_ref, do: R.ref(module: @project_kind, id: uid())

  # Groups need a ref so rules can target them; we point them at synthetic
  # Project-entity ids purely as opaque group identifiers.
  defp group!(name) do
    {:ok, group} =
      Acl.create_group(%{
        name: "acl-" <> name <> "-" <> Ecto.UUID.generate(),
        ref: R.ref(module: @project_kind, id: uid())
      })

    group
  end

  defp member!(group, ref, opts \\ []), do: {:ok, _} = Acl.add_member(group, ref, opts)

  defp rule!(subject_ref, resource_ref, action, effect, extra \\ []) do
    attrs =
      %{subject_ref: subject_ref, resource_ref: resource_ref, action: action, effect: effect}
      |> Map.merge(Map.new(extra))

    {:ok, rule} = Acl.create_rule(attrs)
    rule
  end

  describe "group + membership CRUD" do
    test "create/get/find by name" do
      ref = user_ref()
      {:ok, group} = Acl.create_group(%{name: "acl-test-owners", ref: ref})

      assert group.id == Acl.get_group(group.id).id
      assert group.id == Acl.get_group_by_name("acl-test-owners").id
      assert group.ref == ref
    end

    test "add/remove member + unique constraint" do
      group = group!("m")
      ref = user_ref()
      assert {:ok, _} = Acl.add_member(group, ref)
      assert {:error, _} = Acl.add_member(group, ref)
      assert [%{member_ref: ^ref}] = Acl.members(group)

      assert {:ok, 1} = Acl.remove_member(group, ref)
      assert [] = Acl.members(group)
    end

    test "groups_for finds direct memberships; archived groups excluded" do
      g = group!("a")
      ref = user_ref()
      member!(g, ref)
      assert [%{id: id}] = Acl.groups_for(ref)
      assert id == g.id

      Acl.archive_group(g)
      assert [] = Acl.groups_for(ref)
    end

    test "expired membership excluded from expansion" do
      g = group!("exp")
      ref = user_ref()
      member!(g, ref, expires_at: DateTime.add(DateTime.utc_now(), -3600))

      assert [] = Acl.groups_for(ref)
      assert [^ref] = Acl.subject_candidates(ref)
    end

    test "membership write paths accept raw sref strings" do
      group = group!("raw")
      id = uid()
      sref = "ref.#{@user_kind}.#{id}"
      expected = R.ref(module: @user_kind, id: id)

      assert {:ok, member} = Acl.add_member(group, sref)
      assert member.member_ref == expected

      assert {:ok, 1} = Acl.remove_member(group, sref)
    end

    test "unparseable member refs return symmetric errors" do
      group = group!("bad")

      assert {:error, :invalid_member_ref} = Acl.add_member(group, "not a ref")
      assert {:error, :not_found} = Acl.remove_member(group, "not a ref")
    end
  end

  describe "subject_candidates (group expansion)" do
    test "direct group ref joins the candidate set" do
      user = user_ref()
      g = group!("d")
      member!(g, user)

      candidates = Acl.subject_candidates(user)
      assert user in candidates
      assert g.ref in candidates
    end

    test "nested groups expand transitively; cycles are guarded" do
      user = user_ref()
      inner = group!("inner")
      outer = group!("outer")

      member!(inner, user)
      member!(outer, inner.ref)
      # cycle: inner ↔ outer
      member!(inner, outer.ref)

      candidates = Acl.subject_candidates(user)
      assert user in candidates
      assert inner.ref in candidates
      assert outer.ref in candidates
    end

    test "multi-group fan-out" do
      user = user_ref()
      g1 = group!("m1")
      g2 = group!("m2")
      member!(g1, user)
      member!(g2, user)

      candidates = Acl.subject_candidates(user)
      assert g1.ref in candidates and g2.ref in candidates
    end
  end

  describe "resolve (DB-backed)" do
    test "direct grant resolves; other actions default-deny" do
      user = user_ref()
      project = project_ref()
      rule!(user, project, "project.read", "allow")

      assert {:allow, _} = Acl.resolve(user, "project.read", project)
      assert Acl.allowed?(user, "project.read", project)
      assert {:deny, :default} = Acl.resolve(user, "project.write", project)
    end

    test "grant via group membership" do
      user = user_ref()
      project = project_ref()
      g = group!("grant")
      member!(g, user)
      rule!(g.ref, project, "project.read", "allow")

      assert Acl.allowed?(user, "project.read", project)
      # another user in no group stays denied
      refute Acl.allowed?(user_ref(), "project.read", project)
    end

    test "deny beats allow from different paths" do
      user = user_ref()
      project = project_ref()
      rule!(user, project, "project.read", "allow")

      g = group!("deny")
      member!(g, user)
      rule!(g.ref, project, "project.read", "deny")

      assert {:deny, _} = Acl.resolve(user, "project.read", project)
    end

    test "nested group grant" do
      user = user_ref()
      project = project_ref()

      inner = group!("inner")
      outer = group!("outer")
      member!(inner, user)
      member!(outer, inner.ref)
      rule!(outer.ref, project, "project.read", "allow")

      assert Acl.allowed?(user, "project.read", project)
    end

    test "kind wildcard rule + scope filtering end-to-end" do
      user = user_ref()
      project = project_ref()
      other_project = project_ref()

      rule!(user, R.ref(module: @project_kind, id: :any), "project.read", "allow", scope: "mcp")

      assert Acl.allowed?(user, "project.read", project, scope: "mcp")
      assert Acl.allowed?(user, "project.read", other_project, scope: "mcp")
      assert {:deny, :default} = Acl.resolve(user, "project.read", project, scope: "wiki")
    end

    test "archived rule stops resolving" do
      user = user_ref()
      project = project_ref()
      rule = rule!(user, project, "project.read", "allow")
      assert Acl.allowed?(user, "project.read", project)

      Acl.archive_rule(rule)
      assert {:deny, :default} = Acl.resolve(user, "project.read", project)
    end

    test "resource kind wildcard + action wildcard end-to-end" do
      user = user_ref()
      rule!(user, R.ref(module: @project_kind, id: :any), "*", "allow")
      assert Acl.allowed?(user, "anything.else", project_ref())
    end

    test "nil-resource request matches resource-agnostic rules only" do
      user = user_ref()

      # exact-resource rule must NOT match a resource-agnostic request
      rule!(user, project_ref(), "project.read", "allow")
      assert {:deny, :default} = Acl.resolve(user, "project.read", nil)

      # global wildcard rule (resource-agnostic grant) does match
      rule!(user, R.ref(module: :any, id: :any), "project.read", "allow")
      assert {:allow, _} = Acl.resolve(user, "project.read", nil)
      assert Acl.allowed?(user, "project.read", nil)
    end

    test "kind-wildcard rule deliberately does NOT match a nil-resource request" do
      user = user_ref()
      rule!(user, R.ref(module: @project_kind, id: :any), "project.read", "allow")

      # matches every project…
      assert Acl.allowed?(user, "project.read", project_ref())
      # …but a nil resource is resource-agnostic, and only NULL resource_ref
      # rules or the {"any","any"} global wildcard apply to it.
      assert {:deny, :default} = Acl.resolve(user, "project.read", nil)
    end

    test "two-group cycle terminates and resolves rules on either group" do
      user = user_ref()
      project = project_ref()

      a = group!("cyc-a")
      b = group!("cyc-b")

      member!(a, user)
      member!(b, a.ref)
      member!(a, b.ref)

      candidates = Acl.subject_candidates(user)
      assert user in candidates
      assert a.ref in candidates
      assert b.ref in candidates

      rule!(b.ref, project, "project.read", "allow")
      assert Acl.allowed?(user, "project.read", project)
      assert {:deny, :default} = Acl.resolve(user_ref(), "project.read", project)
    end

    test "rule write paths accept raw sref/map inputs" do
      id = uid()
      subject = R.ref(module: @user_kind, id: id)
      project = project_ref()

      # create_rule with raw sref strings
      assert {:ok, _rule} =
               Acl.create_rule(%{
                 subject_ref: "ref.#{@user_kind}.#{id}",
                 resource_ref: "ref.#{@project_kind}.#{elem(project, 2)}",
                 action: "project.read",
                 effect: "allow"
               })

      assert Acl.allowed?(subject, "project.read", project)
    end

    test "sref/map inputs normalize before queries" do
      id = uid()
      subject = R.ref(module: @user_kind, id: id)
      project = project_ref()

      rule!(subject, R.ref(module: @project_kind, id: :any), "project.read", "allow")

      # sref subject string (previously crashed at dump)
      assert {:allow, _} =
               Acl.resolve("ref." <> "#{@user_kind}.#{id}", "project.read", project)

      # sref resource string
      assert {:allow, _} =
               Acl.resolve(subject, "project.read", "ref.#{@project_kind}.#{elem(project, 2)}")

      # jsonb map subject
      assert {:allow, _} =
               Acl.resolve(%{"type" => "#{@user_kind}", "id" => id}, "project.read", project)

      # unparseable ref normalizes to nil → default deny, no crash
      assert {:deny, :default} = Acl.resolve("ref.not.a.real.kind.abc", "project.read", project)
    end
  end

  describe "normalize/1" do
    test "accepts refs, structs-shape tuples, maps, and sref strings" do
      id = uid()
      ref = R.ref(module: @user_kind, id: id)

      assert Acl.normalize(ref) == ref
      assert Acl.normalize({:ref, @user_kind, id}) == ref
      assert Acl.normalize("ref.#{@user_kind}.#{id}") == ref
      assert Acl.normalize("#{@user_kind}.#{id}") == ref
      assert Acl.normalize("ref.any.any") == R.ref(module: :any, id: :any)
      assert Acl.normalize(%{"type" => "#{@user_kind}", "id" => id}) == ref
      assert Acl.normalize(%{type: "#{@user_kind}", id: id}) == ref
      assert Acl.normalize(nil) == nil
      assert Acl.normalize("ref.unknown-kind.x") == nil
    end

    test "sref ids may contain dots (first module prefix is the type)" do
      assert Acl.normalize("ref.#{@project_kind}.abc.def") ==
               R.ref(module: @project_kind, id: "abc.def")

      assert Acl.normalize("ref.#{@user_kind}.a.b.c") ==
               R.ref(module: @user_kind, id: "a.b.c")
    end

    test "repeated ref. prefixes do not double-strip" do
      assert Acl.normalize("ref.ref.#{@user_kind}.abc") == nil
    end

    test "empty segments and missing ids are rejected" do
      assert Acl.normalize("") == nil
      assert Acl.normalize("ref.") == nil
      assert Acl.normalize("ref.#{@user_kind}") == nil
      assert Acl.normalize("ref.#{@user_kind}.") == nil
      assert Acl.normalize("ref..abc") == nil
      assert Acl.normalize("ref.#{@user_kind}..abc") == nil
    end

    test "ERPRef.cast accepts the same shapes" do
      id = uid()
      ref = R.ref(module: @user_kind, id: id)

      assert ERPRef.cast("ref.#{@user_kind}.#{id}") == {:ok, ref}
      assert ERPRef.cast(%{"type" => "#{@user_kind}", "id" => id}) == {:ok, ref}
      assert ERPRef.cast(%{type: "#{@user_kind}", id: id}) == {:ok, ref}
      assert ERPRef.cast("ref.any.any") == {:ok, R.ref(module: :any, id: :any)}
      assert ERPRef.cast("garbage") == :error
      assert ERPRef.cast("ref.nope.kind.x") == :error
      assert ERPRef.cast(nil) == {:ok, nil}
    end
  end

  describe "frontier cap (runaway-graph guard)" do
    test "over-limit frontier is trimmed, not discarded" do
      user = user_ref()
      cap = Acl.max_group_depth()

      # subject directly in > cap groups — old code discarded the entire
      # frontier (candidates = subject only); capped expansion keeps cap-1
      # of the newest group refs, so candidates = cap.
      groups = Enum.map(1..(cap + 4), fn i -> group!("cap-#{i}") end)
      Enum.each(groups, &member!(&1, user))

      candidates = Acl.subject_candidates(user)
      assert length(candidates) == cap
      assert user in candidates
      assert Enum.any?(candidates, &(&1 != user))
      # cycle guard still intact
      assert candidates == Enum.uniq(candidates)
    end
  end
end
