defmodule Noizu.PM.Authz.ScopedMemberships do
  alias Noizu.PM.Authz.ScopedMemberships.ScopedMembership, as: Entity
  alias Noizu.PM.Schema.Authz.ScopedMembership, as: Schema

  use Noizu.Repo
  def_repo(entity: Entity)
end
