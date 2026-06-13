defmodule Starter.Authz.Groups do
  alias Starter.Authz.Groups.Group, as: Entity
  alias Starter.Schema.Authz.Group, as: Schema
  alias Starter.Schema.Authz.GroupPolicy, as: GroupPolicySchema
  alias Starter.Schema.Authz.Policy, as: PolicySchema

  use Noizu.Repo
  def_repo(entity: Entity)

  import Ecto.Query

  def list_all do
    Starter.Repo.all(from g in Schema, order_by: g.name)
  end

  def get_by_name(name) when is_binary(name) do
    Starter.Repo.one(from g in Schema, where: g.name == ^name)
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
    |> Starter.Repo.all()
  end
end
