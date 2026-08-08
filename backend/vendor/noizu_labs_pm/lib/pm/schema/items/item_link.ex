defmodule Noizu.PM.Schema.Items.ItemLink do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @link_types ~w(blocks blocked_by relates_to duplicates parent_of child_of)

  schema "item_links" do
    belongs_to :source_item, Noizu.PM.Schema.Items.Item
    belongs_to :target_item, Noizu.PM.Schema.Items.Item
    field :link_type, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(link, attrs) do
    link
    |> cast(attrs, [:source_item_id, :target_item_id, :link_type])
    |> validate_required([:source_item_id, :target_item_id, :link_type])
    |> validate_inclusion(:link_type, @link_types)
    |> unique_constraint([:source_item_id, :target_item_id, :link_type])
    |> foreign_key_constraint(:source_item_id)
    |> foreign_key_constraint(:target_item_id)
  end

  def link_types, do: @link_types
end
