defmodule NoizuPromptLingua.Schema.Unicode.ElementRelation do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @relation_types ~w(same-topic same-special-usage confusable-with composes-with
                     decomposes-to variant-of control-related npl-related related-control)

  schema "unicode_element_relations" do
    belongs_to :source_element, NoizuPromptLingua.Schema.Unicode.Element
    belongs_to :target_element, NoizuPromptLingua.Schema.Unicode.Element
    field :relation_type, :string
    field :description, :string
    field :metadata, :map, default: %{}

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def changeset(relation, attrs) do
    relation
    |> cast(attrs, [
      :source_element_id,
      :target_element_id,
      :relation_type,
      :description,
      :metadata
    ])
    |> validate_required([:source_element_id, :target_element_id, :relation_type])
    |> validate_inclusion(:relation_type, @relation_types)
    |> foreign_key_constraint(:source_element_id)
    |> foreign_key_constraint(:target_element_id)
    |> unique_constraint([:source_element_id, :target_element_id, :relation_type],
      name: :idx_unicode_element_relations_unique
    )
  end

  def relation_types, do: @relation_types
end
