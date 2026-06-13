defmodule Starter.Organizations.InviteTokens do
  @moduledoc """
  Repo for Starter.Organizations.InviteToken
  """
  alias Starter.Organizations.InviteToken, as: Entity
  use Noizu.Repo
  def_repo(entity: Entity)
end
