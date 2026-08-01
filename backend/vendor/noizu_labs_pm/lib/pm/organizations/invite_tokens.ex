defmodule Noizu.PM.Organizations.InviteTokens do
  alias Noizu.PM.Organizations.InviteToken, as: Entity
  alias Noizu.PM.Schema.Organizations.InviteToken, as: Schema

  use Noizu.Repo
  def_repo(entity: Entity)
end
