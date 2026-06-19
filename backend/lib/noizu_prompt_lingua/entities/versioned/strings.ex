defmodule NoizuPromptLingua.Versioned.Strings do
  alias NoizuPromptLingua.Versioned.Strings.String, as: Entity
  alias NoizuPromptLingua.Schema.Versioned.Strings.String, as: Schema
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

  def get_versioned_string(id, context, options \\ []), do: get(id, context, options)

  def create(string, context, options \\ []) do
    %Entity{}
    |> change(string)
    |> create(context, options)
  end

  def update(%Entity{} = string, attrs, context, options \\ []) do
    string
    |> change(attrs)
    |> update(context, options)
  end

  def delete(%Entity{} = string, context, options \\ []) do
    delete(string, context, options)
  end

  def change(%Entity{} = string, attrs \\ %{}) do
    attrs =
      Enum.map(attrs, fn
        {"content", value} -> {:content, value}
        {"id", value} -> {:id, value}
        {k, v} when is_atom(k) -> {k, v}
        _ -> nil
      end)
      |> Enum.reject(&is_nil/1)
      |> Enum.into(%{})

    Ecto.Changeset.change({string, Noizu.Entity.Meta.meta(Entity)[:changeset_fields]}, attrs)
  end
end
