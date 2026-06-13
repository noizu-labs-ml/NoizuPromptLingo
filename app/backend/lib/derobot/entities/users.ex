defmodule Derobot.Users do
  alias Derobot.Users.User, as: Entity
  alias Derobot.Schema.Users.User, as: Schema
  use Noizu.Repo

  def_repo(entity: Derobot.Users.User)

  def list(context, options \\ []) do
    settings = Noizu.Entity.Meta.persistence(Entity) |> hd

    Derobot.Repo.all(Schema)
    |> Enum.map(fn record ->
      {:ok, entity} = Entity.from_record(record, settings, context, options)
      {:ok, entity} = __after_get__(entity, context, options)
      entity
    end)
  end

  def get_user(id, context, options \\ []), do: get(id, context, options)

  def by_email(email, context, options \\ []) do
    with record = %Schema{} <- Derobot.Repo.get_by(Schema, %{email: email}) do
      settings = Noizu.Entity.Meta.persistence(Entity) |> hd
      {:ok, entity} = Entity.from_record(record, settings, context, options)
      __after_get__(entity, context, options)
    end
  end

  def by_handle(handle, context, options \\ []) do
    with record = %Schema{} <- Derobot.Repo.get_by(Schema, %{handle: handle}) do
      settings = Noizu.Entity.Meta.persistence(Entity) |> hd
      {:ok, entity} = Entity.from_record(record, settings, context, options)
      __after_get__(entity, context, options)
    end
  end

  def authenticate({:login, {email, password}}, context, options \\ nil) do
    with {:ok, session} <- Derobot.Users.Credentials.authenticate({:login, {email, password}}, context, options) do
      {:ok, session}
    end
  end
end
