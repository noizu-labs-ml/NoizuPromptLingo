defmodule Noizu.PM.Organizations do
  @moduledoc """
  Repo binding for the Organization entity. The app-specific orchestration
  (slug cache, invite hashing, PBAC wiring) lives in the host applications;
  this module only exposes the `def_repo` store surface the entity macro
  requires.
  """
  alias Noizu.PM.Organizations.Organization, as: Entity
  alias Noizu.PM.Schema.Organizations.Organization, as: Schema

  use Noizu.Repo
  def_repo(entity: Entity)
end
