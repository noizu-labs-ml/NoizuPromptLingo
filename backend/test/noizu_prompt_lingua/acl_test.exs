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
  end
end
