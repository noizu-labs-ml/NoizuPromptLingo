defmodule Noizu.PM.Users do
  alias Noizu.PM.Users.User, as: Entity
  alias Noizu.PM.Schema.Users.User, as: Schema

  use Noizu.Repo
  def_repo(entity: Entity)
end
