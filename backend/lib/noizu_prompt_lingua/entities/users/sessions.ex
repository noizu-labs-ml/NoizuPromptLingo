defmodule NoizuPromptLingua.Users.Sessions do
  @moduledoc """
  Context for NoizuPromptLingua.Users.Sessions
  """
  alias NoizuPromptLingua.Users.Sessions.UserSession, as: Entity
  alias NoizuPromptLingua.Schema.Users.Sessions.UserSession, as: Schema
  use Noizu.Repo
  def_repo(entity: NoizuPromptLingua.Users.Sessions.UserSession)

  def list(context, options \\ []) do
    settings = Noizu.Entity.Meta.persistence(Entity) |> hd

    NoizuPromptLingua.Repo.all(Schema)
    |> Enum.map(fn record ->
      {:ok, entity} = Entity.from_record(record, settings, context, options)
      {:ok, entity} = __after_get__(entity, context, options)
      entity
    end)
  end

  def get_session(id, context, options \\ []), do: get(id, context, options)

  def create(session, context, options \\ []) do
    %Entity{}
    |> change(session)
    |> super(context, options)
  end

  def delete(session, context, options \\ []) do
    super(session, context, options)
  end

  def change(%Entity{} = session, attrs \\ %{}) do
    attrs =
      Enum.map(
        attrs,
        fn
          {"user", value} -> {:user, value}
          {"credential", value} -> {:credential, value}
          {"status", value} -> {:status, String.to_existing_atom(value)}
          {"details", value} -> {:details, value}
          {"id", value} -> {:id, value}
          {x, value} when is_atom(x) -> {x, value}
          _ -> nil
        end
      )
      |> Enum.reject(&is_nil/1)

    Ecto.Changeset.change(
      {session, Noizu.Entity.Meta.meta(Entity)[:changeset_fields]},
      attrs
    )
  end
end
