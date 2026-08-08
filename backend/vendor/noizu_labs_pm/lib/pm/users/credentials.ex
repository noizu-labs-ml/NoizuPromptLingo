defmodule Noizu.PM.Users.Credentials do
  alias Noizu.PM.Users.Credentials.UserCredential, as: Entity
  alias Noizu.PM.Schema.Users.Credentials.UserCredential, as: Schema

  use Noizu.Repo
  def_repo(entity: Entity)
end
