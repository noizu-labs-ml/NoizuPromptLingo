defmodule NoizuTest.EntityRepo do
  @moduledoc false
  def create(entity, context, options \\ nil)

  def create(%Ecto.Changeset{data: entity} = cs, context, options) do
    r = entity.__struct__.__noizu_meta__()[:repo]
    apply(r, :create, [cs, context, options])
  end

  def create(entity, context, options) do
    r = entity.__struct__.__noizu_meta__()[:repo]
    apply(r, :create, [entity, context, options])
  end

  def update(entity, context, options \\ nil)

  def update(%Ecto.Changeset{data: entity} = cs, context, options) do
    r = entity.__struct__.__noizu_meta__()[:repo]
    apply(r, :update, [cs, context, options])
  end

  def update(entity, context, options) do
    r = entity.__struct__.__noizu_meta__()[:repo]
    apply(r, :update, [entity, context, options])
  end

  def delete(entity, context, options \\ nil) do
    r = entity.__struct__.__noizu_meta__()[:repo]
    apply(r, :delete, [entity, context, options])
  end
end
