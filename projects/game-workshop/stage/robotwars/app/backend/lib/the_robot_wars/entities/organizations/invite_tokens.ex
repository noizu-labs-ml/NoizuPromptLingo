defmodule TheRobotWars.Organizations.InviteTokens do
  @moduledoc """
  Repo for TheRobotWars.Organizations.InviteToken
  """
  alias TheRobotWars.Organizations.InviteToken, as: Entity
  use Noizu.Repo
  def_repo(entity: Entity)
end
