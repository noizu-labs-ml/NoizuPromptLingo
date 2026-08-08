defmodule Noizu.PM.Users.Sessions do
  alias Noizu.PM.Users.Sessions.UserSession, as: Entity
  alias Noizu.PM.Schema.Users.Sessions.UserSession, as: Schema

  use Noizu.Repo
  def_repo(entity: Entity)
end
