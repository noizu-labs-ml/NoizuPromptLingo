defmodule Noizu.PM.Versioned.Descriptions do
  alias Noizu.PM.Versioned.Descriptions.Description, as: Entity
  alias Noizu.PM.Schema.Versioned.Descriptions.Description, as: Schema

  use Noizu.Repo
  def_repo(entity: Entity)
end
