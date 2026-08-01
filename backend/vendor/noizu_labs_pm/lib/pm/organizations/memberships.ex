defmodule Noizu.PM.Organizations.Memberships do
  alias Noizu.PM.Organizations.Membership, as: Entity
  alias Noizu.PM.Schema.Organizations.Membership, as: Schema

  use Noizu.Repo
  def_repo(entity: Entity)
end
