defmodule NoizuPromptLingua.Versioned.Descriptions do
  alias NoizuPromptLingua.Versioned.Descriptions.Description, as: Entity
  alias NoizuPromptLingua.Schema.Versioned.Descriptions.Description, as: Schema
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

  def get_versioned_description(id, context, options \\ []), do: get(id, context, options)

  # `super`, not `create` — a self-call lands back in this same clause and
  # change/2's `Enum.map(attrs, ...)` crashes on the non-enumerable it is
  # handed (Protocol.UndefinedError). A pre-built entity or changeset — what
  # `EntityRepo.create/2` dispatches here — skips change/2 entirely.
  def create(description, context, options \\ [])

  def create(%Entity{} = description, context, options), do: super(description, context, options)

  def create(%Ecto.Changeset{} = changeset, context, options),
    do: super(changeset, context, options)

  def create(attrs, context, options) do
    %Entity{}
    |> change(attrs)
    |> super(context, options)
  end

  # Arity 4 only — an `options \\ []` default would also define update/3 and
  # shadow the def_repo-generated update/3 that this body calls.
  def update(%Entity{} = description, attrs, context, options) do
    description
    |> change(attrs)
    |> update(context, options)
  end

  def delete(%Entity{} = description, context, options \\ []) do
    # A bare `delete(description, context, options)` is this very clause — unbounded
    # recursion. `super` reaches the def_repo-generated delete/3.
    super(description, context, options)
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
