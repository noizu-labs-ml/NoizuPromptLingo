defmodule NoizuPromptLingua.Versioned.Names do
  alias NoizuPromptLingua.Versioned.Names.Name, as: Entity
  alias NoizuPromptLingua.Schema.Versioned.Names.Name, as: Schema
  use Noizu.Repo
  def_repo(entity: Entity)

  def list(context, options \\ []) do
    settings = Noizu.Entity.Meta.persistence(Entity) |> hd
    NoizuPromptLingua.Repo.all(Schema)
    |> Enum.map(fn record ->
      {:ok, entity} = Entity.from_record(record, settings, context, options)
      {:ok, entity} = __after_get__(entity, context, options)
      entity
    end)
  end

  def get_versioned_name(id, context, options \\ []), do: get(id, context, options)

  def create(name, context, options \\ []) do
    %Entity{}
    |> change(name)
    |> create(context, options)
  end

  def update(%Entity{} = name, attrs, context, options \\ []) do
    name
    |> change(attrs)
    |> update(context, options)
  end

  def delete(%Entity{} = name, context, options \\ []) do
    delete(name, context, options)
  end

  def change(%Entity{} = name, attrs \\ %{}) do
    attrs =
      Enum.map(attrs, fn
        {"first", value} -> {:first, value}
        {"middle", value} -> {:middle, value}
        {"last", value} -> {:last, value}
        {"id", value} -> {:id, value}
        {k, v} when is_atom(k) -> {k, v}
        _ -> nil
      end)
      |> Enum.reject(&is_nil/1)

    Ecto.Changeset.change({name, Noizu.Entity.Meta.meta(Entity)[:changeset_fields]}, attrs)
  end
end
