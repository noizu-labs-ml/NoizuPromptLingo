defmodule TheRobotWars.Versioned.Descriptions do
  alias TheRobotWars.Versioned.Descriptions.Description, as: Entity
  alias TheRobotWars.Schema.Versioned.Descriptions.Description, as: Schema
  use Noizu.Repo
  def_repo(entity: Entity)

  def list(context, options \\ []) do
    settings = Noizu.Entity.Meta.persistence(Entity) |> hd
    TheRobotWars.Repo.all(Schema)
    |> Enum.map(fn record ->
      {:ok, entity} = Entity.from_record(record, settings, context, options)
      {:ok, entity} = __after_get__(entity, context, options)
      entity
    end)
  end

  def get_versioned_description(id, context, options \\ []), do: get(id, context, options)

  def create(description, context, options \\ []) do
    %Entity{}
    |> change(description)
    |> create(context, options)
  end

  def update(%Entity{} = description, attrs, context, options \\ []) do
    description
    |> change(attrs)
    |> update(context, options)
  end

  def delete(%Entity{} = description, context, options \\ []) do
    delete(description, context, options)
  end

  def change(%Entity{} = description, attrs \\ %{}) do
    attrs =
      Enum.map(attrs, fn
        {"title", value} -> {:title, value}
        {"body", value} -> {:body, value}
        {"id", value} -> {:id, value}
        {k, v} when is_atom(k) -> {k, v}
        _ -> nil
      end)
      |> Enum.reject(&is_nil/1)

    Ecto.Changeset.change({description, Noizu.Entity.Meta.meta(Entity)[:changeset_fields]}, attrs)
  end
end
