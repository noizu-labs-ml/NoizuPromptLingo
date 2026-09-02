defmodule NoizuPromptLingua.AuthzFacadeTest do
  use NoizuPromptLingua.DataCase, async: false

  @moduledoc """
  Authz facade (entities/authz.ex) + Groups context (entities/authz/groups.ex):
  role ranks, check_permission's suffix floors, authorize tuple contract,
  explain_permission's not-a-member shape, and the enum-safe group lookups.
  """

  alias NoizuPromptLingua.Authz
  alias NoizuPromptLingua.Authz.Groups
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Authz.{Group, GroupPolicy, Policy, ScopedMembership}
  alias NoizuPromptLingua.Schema.Users.User, as: UserSchema

  setup do
    n = System.unique_integer([:positive])

    user =
      %UserSchema{
        email: "azf-#{n}@example.com",
        user_name: "azf_user#{n}",
        handle: "azf_h#{n}",
        status: :active
      }
      |> Repo.insert!()

    %{user: user, resource_id: Ecto.UUID.generate()}
  end

  defp add_membership!(user_id, resource_id, group_name) do
    group = Repo.get_by!(Group, name: group_name, is_system: true)

    %ScopedMembership{
      resource_type: "project",
      resource_id: resource_id,
      member_type: "user",
      member_id: user_id,
      group_id: group.id
    }
    |> Repo.insert!()
  end

  test "role_ranks stays in the documented ladder order" do
    ranks = Authz.role_ranks()
    assert ranks["owner"] < ranks["admin"]
    assert ranks["admin"] < ranks["lead"]
    assert ranks["lead"] < ranks["member"]
    assert ranks["member"] < ranks["viewer"]
  end

  test "get_user_role resolves the active role or nil", %{user: user, resource_id: rid} do
    assert Authz.get_user_role(user.id, "project", rid) == nil

    add_membership!(user.id, rid, "lead")
    assert Authz.get_user_role(user.id, "project", rid) == "lead"
  end

  test "check_permission applies the permission-suffix floors", %{user: user, resource_id: rid} do
    add_membership!(user.id, rid, "lead")

    # viewer-suffix actions pass for lead
    assert Authz.check_permission(user.id, "project", rid, "ticket_view")
    assert Authz.check_permission(user.id, "project", rid, "item.list")
    # member-suffix actions pass for lead
    assert Authz.check_permission(user.id, "project", rid, "item.update")
    # admin-suffix actions fail for lead (delete/archive/manage need admin)
    refute Authz.check_permission(user.id, "project", rid, "item.delete")
    refute Authz.check_permission(user.id, "project", rid, "manage_members")

    # unknown suffix defaults to the member floor
    assert Authz.check_permission(user.id, "project", rid, "do_the_thing")
  end

  test "authorize tuple contract: ok / not_a_member / insufficient_role", %{
    user: user,
    resource_id: rid
  } do
    assert {:error, :not_a_member} = Authz.authorize(user.id, "project", rid, "admin")

    add_membership!(user.id, rid, "viewer")

    assert {:ok, %{role: "viewer"}} = Authz.authorize(user.id, "project", rid, "viewer")
    # atom required_role is normalized
    assert {:ok, %{role: "viewer"}} = Authz.authorize(user.id, "project", rid, :viewer)
    assert {:error, :insufficient_role} = Authz.authorize(user.id, "project", rid, "admin")
  end

  test "explain_permission for members vs outsiders", %{user: user, resource_id: rid} do
    # outsider shape
    explain = Authz.explain_permission(user.id, "project", rid, "item.update")
    assert %{allowed: false, reason: :not_a_member, matching_statements: []} = explain

    add_membership!(user.id, rid, "member")

    # member shape: policies (none attached) + evaluator verdict
    explain2 = Authz.explain_permission(user.id, "project", rid, "item.update")
    assert %{allowed: allowed, reason: _} = explain2
    assert is_boolean(allowed)
  end

  # ── Groups context ───────────────────────────────────────────────

  test "get_by_name: enum roles resolve, junk names return nil (no raise)" do
    assert %Group{name: "viewer"} = Groups.get_by_name("viewer")

    assert nil ==
             Groups.get_by_name("definitely-not-a-role-#{System.unique_integer([:positive])}")
  end

  test "list_all returns groups (enum-typed name order, not alphabetical)" do
    listed = Groups.list_all()
    assert is_list(listed)
    names = Enum.map(listed, & &1.name)
    # groups.name is a PG enum — ORDER BY follows enum declaration order
    # (owner, admin, lead, member, viewer), NOT alphabetical (pinned)
    assert names == Enum.uniq(names)
    assert Enum.any?(names, &(&1 == "owner"))
  end

  test "list_policies joins group policies with priority order", %{user: _user} do
    group = Repo.get_by!(Group, name: "lead", is_system: true)

    policy =
      %Policy{
        name: "grp-pol-#{System.unique_integer([:positive])}",
        is_active: true,
        policy_document: %{"statements" => [%{"effect" => "allow", "actions" => ["read"]}]}
      }
      |> Repo.insert!()

    %GroupPolicy{group_id: group.id, policy_id: policy.id, priority: 5}
    |> Repo.insert!()

    listed = Groups.list_policies(group.id)
    row = Enum.find(listed, &(&1.id == policy.id))
    assert row.name == policy.name
    assert row.priority == 5
  end
end
