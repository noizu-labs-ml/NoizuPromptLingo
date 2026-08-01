defmodule Noizu.PM.Schema.Items.ItemEntityLink do
  @moduledoc """
  A polymorphic link between an item and a non-item entity (an OKR/key result,
  etc.). There is intentionally no DB FK on `entity_id` (it spans domains); the
  calling layer validates the target exists. Item↔item links live in `ItemLink`.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @link_types ~w(relates_to targets derived_from addresses blocks references)

  schema "item_entity_links" do
    field :item_id, :binary_id
    field :entity_type, :string
    field :entity_id, :binary_id
    field :link_type, :string, default: "relates_to"
    field :metadata, :map, default: %{}

    timestamps(type: :utc_datetime)
  end

  def changeset(link, attrs) do
    link
    |> cast(attrs, [:item_id, :entity_type, :entity_id, :link_type, :metadata])
    |> validate_required([:item_id, :entity_type, :entity_id, :link_type])
    |> validate_inclusion(:link_type, @link_types)
    |> foreign_key_constraint(:item_id)
    |> unique_constraint([:item_id, :entity_type, :entity_id, :link_type],
      name: :idx_item_entity_links_uniq
    )
  end

  def link_types, do: @link_types
end
