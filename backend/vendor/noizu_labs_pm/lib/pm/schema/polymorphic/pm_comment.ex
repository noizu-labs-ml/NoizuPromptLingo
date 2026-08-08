defmodule Noizu.PM.Schema.Polymorphic.PmComment do
  @moduledoc """
  Generic per-entity comment keyed by (entity_type, entity_id). Consolidates
  npl's `npl_comments` and trp's `trp_comments` into one polymorphic table
  (`pm_comments`). Items use entity_type = "item", wiki pages "wiki_page", etc.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "pm_comments" do
    field :entity_type, :string
    field :entity_id, :binary_id
    field :content, :string
    field :author, :string
    field :location, :string
    field :reply_to_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:entity_type, :entity_id, :content, :author, :location, :reply_to_id])
    |> validate_required([:entity_type, :entity_id, :content])
  end
end
