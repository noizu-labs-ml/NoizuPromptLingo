defmodule Noizu.PM.Versioned.Names do
  alias Noizu.PM.Versioned.Names.Name, as: Entity
  alias Noizu.PM.Schema.Versioned.Names.Name, as: Schema

  use Noizu.Repo
  def_repo(entity: Entity)
end
