defmodule Noizu.PM.Auth.Providers do
  alias Noizu.PM.Auth.Providers.Provider, as: Entity
  alias Noizu.PM.Schema.Auth.Providers.Provider, as: Schema

  use Noizu.Repo
  def_repo(entity: Entity)
end
