defmodule Noizu.PM.Authz.Groups do
  alias Noizu.PM.Authz.Groups.Group, as: Entity
  alias Noizu.PM.Schema.Authz.Group, as: Schema

  use Noizu.Repo
  def_repo(entity: Entity)
end
