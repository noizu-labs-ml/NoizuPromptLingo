defmodule Derobot.Users.Sessions do
  alias Derobot.Users.Sessions.UserSession, as: Entity
  alias Derobot.Schema.Users.Sessions.UserSession, as: Schema
  use Noizu.Repo

  def_repo(entity: Derobot.Users.Sessions.UserSession)

  def list(context, options \\ []) do
    settings = Noizu.Entity.Meta.persistence(Entity) |> hd

    Derobot.Repo.all(Schema)
    |> Enum.map(fn record ->
      {:ok, entity} = Entity.from_record(record, settings, context, options)
      {:ok, entity} = __after_get__(entity, context, options)
      entity
    end)
  end

  def get_session(id, context, options \\ []), do: get(id, context, options)
end
