defmodule NoizuPromptLingua.AuthzPoliciesTest do
  use NoizuPromptLingua.DataCase

  @moduledoc """
  Policies context (entities/authz/policies.ex): CRUD with system-policy
  guards, active/system filters, and the user-policy attach/detach/list flow.
  """

  alias NoizuPromptLingua.Authz.Policies
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Authz.Policy, as: PolicySchema
  alias NoizuPromptLingua.Schema.Users.User, as: UserSchema

  setup do
    n = System.unique_integer([:positive])

    user =
      %UserSchema{
        email: "pol-#{n}@example.com",
        user_name: "pol_user#{n}",
        handle: "pol_h#{n}",
        status: :active
      }
      |> Repo.insert!()

    %{user: user, n: n}
  end

  defp doc,
    do: %{"statements" => [%{"effect" => "allow", "actions" => ["*"], "resources" => ["*"]}]}

  defp create_policy!(attrs \\ %{}) do
    n = System.unique_integer([:positive])

    {:ok, policy} =
      Policies.create_policy(
        Map.merge(
          %{
            name: "policy-#{n}",
            description: "test policy",
            policy_document: doc()
          },
          attrs
        )
      )

    policy
  end

  test "create + get_by_name + list_active filters" do
    policy = create_policy!()
    assert Policies.get_by_name(policy.name).id == policy.id

    system =
      create_policy!(%{name: "system-#{System.unique_integer([:positive])}", is_system: true})

    inactive = create_policy!(%{is_active: false})

    active = Policies.list_active()
    assert Enum.any?(active, &(&1.id == policy.id))
    assert Enum.any?(active, &(&1.id == system.id))
    refute Enum.any?(active, &(&1.id == inactive.id))

    system_only = Policies.list_active(system_only: true)
    assert Enum.any?(system_only, &(&1.id == system.id))
    refute Enum.any?(system_only, &(&1.id == policy.id))
  end

  test "update_policy guards system rows and updates regular ones" do
    policy = create_policy!()
    system = create_policy!(%{is_system: true})

    assert {:ok, updated} = Policies.update_policy(policy.id, %{description: "rev"})
    assert updated.description == "rev"

    assert {:error, :cannot_modify_system_policy} =
             Policies.update_policy(system.id, %{description: "no"})

    assert {:error, :not_found} =
             Policies.update_policy(Ecto.UUID.generate(), %{description: "x"})
  end

  test "delete_policy guards system rows and deletes regular ones" do
    policy = create_policy!()
    system = create_policy!(%{is_system: true})

    assert {:error, :cannot_delete_system_policy} = Policies.delete_policy(system.id)
    assert {:ok, _} = Policies.delete_policy(policy.id)
    assert {:error, :not_found} = Policies.delete_policy(policy.id)
  end

  test "attach/list/detach user policies with priority ordering", %{user: user} do
    p1 = create_policy!()
    p2 = create_policy!()

    assert {:ok, _} = Policies.attach_to_user(user.id, p1.id, priority: 10)
    assert {:ok, _} = Policies.attach_to_user(user.id, p2.id, priority: 1)

    listed = Policies.list_user_policies(user.id)
    assert Enum.map(listed, & &1.policy_id) == [p2.id, p1.id]
    assert Enum.all?(listed, &(&1.resource_type == nil))

    assert {:ok, _} =
             Policies.attach_to_user(user.id, p1.id,
               resource_type: "project",
               resource_id: Ecto.UUID.generate(),
               priority: 0
             )

    assert length(Policies.list_user_policies(user.id)) == 3

    assert {:ok, _} = Policies.detach_from_user(user.id, p2.id)
    refute Enum.any?(Policies.list_user_policies(user.id), &(&1.policy_id == p2.id))
    assert {:error, :not_found} = Policies.detach_from_user(user.id, p2.id)
  end

  test "user_policy rows scoped to a specific resource list correctly", %{user: user} do
    policy = create_policy!()
    resource_id = Ecto.UUID.generate()

    assert {:ok, _} =
             Policies.attach_to_user(user.id, policy.id,
               resource_type: "organization",
               resource_id: resource_id
             )

    listed = Policies.list_user_policies(user.id)
    row = Enum.find(listed, &(&1.resource_id == resource_id))
    assert row.resource_type == "organization"
  end

  test "policies schema changeset persists through the Noizu schema directly" do
    n = System.unique_integer([:positive])

    assert {:ok, _} =
             %PolicySchema{}
             |> PolicySchema.changeset(%{
               name: "direct-#{n}",
               policy_document: %{
                 "statements" => [%{"effect" => "deny", "actions" => ["*"], "resources" => ["*"]}]
               }
             })
             |> Repo.insert()
  end
end
