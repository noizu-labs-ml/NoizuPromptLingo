defmodule Noizu.PM.Authz.Policies do
  alias Noizu.PM.Authz.Policies.Policy, as: Entity
  alias Noizu.PM.Schema.Authz.Policy, as: Schema

  use Noizu.Repo
  def_repo(entity: Entity)
end
