defmodule NoizuPromptLingua.Authz.Groups do
  alias NoizuPromptLingua.Authz.Groups.Group, as: Entity
  alias NoizuPromptLingua.Schema.Authz.Group, as: Schema
  alias NoizuPromptLingua.Schema.Authz.GroupPolicy, as: GroupPolicySchema
  alias NoizuPromptLingua.Schema.Authz.Policy, as: PolicySchema

  use Noizu.Repo
  def_repo(entity: Entity)

  import Ecto.Query

  def list_all do
    NoizuPromptLingua.Repo.all(from g in Schema, order_by: g.name)
  end

  @doc """
  Look up a group by role name. `nil` when there is no such group.

  `groups.name` is the Postgres enum `role_name_enum`, so an unrecognised name
  cannot simply miss: `where: g.name == ^"nonexistent"` **raises**
  `invalid input value for enum role_name_enum`, which surfaces as a 500 on
  what is really a not-found. Screening against `Schema.role_names/0` keeps the
  contract this function's callers already assume — a group or `nil`.
  """
  def get_by_name(name) when is_binary(name) do
    if name in Schema.role_names() do
      NoizuPromptLingua.Repo.one(from g in Schema, where: g.name == ^name)
    else
      nil
    end
  end

  def list_policies(group_id) do
    from(gp in GroupPolicySchema,
      join: p in PolicySchema,
      on: p.id == gp.policy_id,
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
    |> NoizuPromptLingua.Repo.all()
  end
end
