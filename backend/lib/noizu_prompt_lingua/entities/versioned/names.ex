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

  # `super`, not `create` — a self-call lands back in this same clause and
  # change/2's `Enum.map(attrs, ...)` crashes on the non-enumerable it is
  # handed (Protocol.UndefinedError). A pre-built entity or changeset — what
  # `EntityRepo.create/2` dispatches here — skips change/2 entirely.
  def create(name, context, options \\ [])

  def create(%Entity{} = name, context, options), do: super(name, context, options)

  def create(%Ecto.Changeset{} = changeset, context, options),
    do: super(changeset, context, options)

  def create(attrs, context, options) do
    %Entity{}
    |> change(attrs)
    |> super(context, options)
  end

  # Arity 4 only — an `options \\ []` default would also define update/3 and
  # shadow the def_repo-generated update/3 that this body calls.
  def update(%Entity{} = name, attrs, context, options) do
    name
    |> change(attrs)
    |> update(context, options)
  end

  def delete(%Entity{} = name, context, options \\ []) do
    # A bare `delete(name, context, options)` is this very clause — unbounded
    # recursion. `super` reaches the def_repo-generated delete/3.
    super(name, context, options)
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
