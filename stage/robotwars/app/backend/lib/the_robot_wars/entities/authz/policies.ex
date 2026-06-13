defmodule TheRobotWars.Authz.Policies do
  alias TheRobotWars.Authz.Policies.Policy, as: Entity
  alias TheRobotWars.Schema.Authz.Policy, as: Schema
  alias TheRobotWars.Schema.Authz.UserPolicy, as: UserPolicySchema

  use Noizu.Repo
  def_repo(entity: Entity)

  import Ecto.Query

  def list_active(opts \\ []) do
    query = from(p in Schema, where: p.is_active == true, order_by: p.name)

    query =
      if Keyword.get(opts, :system_only, false) do
        from(p in query, where: p.is_system == true)
      else
        query
      end

    TheRobotWars.Repo.all(query)
  end

  def get_by_name(name) do
    TheRobotWars.Repo.one(from p in Schema, where: p.name == ^name and p.is_active == true)
  end

  def create_policy(attrs) do
    %Schema{}
    |> Schema.changeset(attrs)
    |> TheRobotWars.Repo.insert()
  end

  def update_policy(id, attrs) do
    case TheRobotWars.Repo.get(Schema, id) do
      nil -> {:error, :not_found}
      policy ->
        if policy.is_system do
          {:error, :cannot_modify_system_policy}
        else
          policy |> Schema.changeset(attrs) |> TheRobotWars.Repo.update()
        end
    end
  end

  def delete_policy(id) do
    case TheRobotWars.Repo.get(Schema, id) do
      nil -> {:error, :not_found}
      policy ->
        if policy.is_system do
          {:error, :cannot_delete_system_policy}
        else
          TheRobotWars.Repo.delete(policy)
        end
    end
  end

  def list_user_policies(user_id) do
    from(up in UserPolicySchema,
      join: p in Schema, on: p.id == up.policy_id,
      where: up.user_id == ^user_id,
      order_by: up.priority,
      select: %{
        id: up.id,
        policy_id: p.id,
        policy_name: p.name,
        resource_type: up.resource_type,
        resource_id: up.resource_id,
        priority: up.priority
      }
    )
    |> TheRobotWars.Repo.all()
  end

  def attach_to_user(user_id, policy_id, opts \\ []) do
    %UserPolicySchema{}
    |> UserPolicySchema.changeset(%{
      user_id: user_id,
      policy_id: policy_id,
      resource_type: Keyword.get(opts, :resource_type),
      resource_id: Keyword.get(opts, :resource_id),
      priority: Keyword.get(opts, :priority, 0)
    })
    |> TheRobotWars.Repo.insert()
  end

  def detach_from_user(user_id, policy_id) do
    case TheRobotWars.Repo.one(
      from up in UserPolicySchema,
        where: up.user_id == ^user_id and up.policy_id == ^policy_id
    ) do
      nil -> {:error, :not_found}
      user_policy -> TheRobotWars.Repo.delete(user_policy)
    end
  end
end
