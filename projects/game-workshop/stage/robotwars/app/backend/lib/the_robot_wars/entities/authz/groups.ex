defmodule TheRobotWars.Authz.Groups do
  alias TheRobotWars.Authz.Groups.Group, as: Entity
  alias TheRobotWars.Schema.Authz.Group, as: Schema
  alias TheRobotWars.Schema.Authz.GroupPolicy, as: GroupPolicySchema
  alias TheRobotWars.Schema.Authz.Policy, as: PolicySchema

  use Noizu.Repo
  def_repo(entity: Entity)

  import Ecto.Query

  def list_all do
    TheRobotWars.Repo.all(from g in Schema, order_by: g.name)
  end

  def get_by_name(name) when is_binary(name) do
    TheRobotWars.Repo.one(from g in Schema, where: g.name == ^name)
  end

  def list_policies(group_id) do
    from(gp in GroupPolicySchema,
      join: p in PolicySchema, on: p.id == gp.policy_id,
      where: gp.group_id == ^group_id,
      order_by: gp.priority,
      select: %{
        id: p.id,
        name: p.name,
        description: p.description,
        policy_document: p.policy_document,
        is_system: p.is_system,
        is_active: p.is_active,
        priority: gp.priority
      }
    )
    |> TheRobotWars.Repo.all()
  end
end
