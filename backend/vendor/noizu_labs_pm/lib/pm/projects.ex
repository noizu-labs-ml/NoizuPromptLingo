defmodule Noizu.PM.Projects do
  alias Noizu.PM.Projects.Project, as: Entity
  alias Noizu.PM.Schema.Projects.Project, as: Schema

  use Noizu.Repo
  def_repo(entity: Entity)
end
