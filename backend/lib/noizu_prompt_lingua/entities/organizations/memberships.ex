defmodule NoizuPromptLingua.Organizations.Memberships do
  @moduledoc """
  Repo for NoizuPromptLingua.Organizations.Membership
  """
  alias NoizuPromptLingua.Organizations.Membership, as: Entity
  alias NoizuPromptLingua.Schema.Organizations.Membership, as: Schema
  use Noizu.Repo
  def_repo(entity: Entity)

  def list_for_org(org_id, context, options \\ []) do
    import Ecto.Query
    settings = Noizu.Entity.Meta.persistence(Entity) |> hd

    NoizuPromptLingua.Repo.all(from m in Schema, where: m.organization_id == ^org_id)
    |> Enum.map(fn record ->
      {:ok, entity} = Entity.from_record(record, settings, context, options)
      {:ok, entity} = __after_get__(entity, context, options)
      entity
    end)
  end
end
