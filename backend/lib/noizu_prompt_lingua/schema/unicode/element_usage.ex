defmodule NoizuPromptLingua.Schema.Unicode.ElementUsage do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "unicode_element_usages" do
    belongs_to :element, NoizuPromptLingua.Schema.Unicode.Element
    belongs_to :special_usage, NoizuPromptLingua.Schema.Unicode.SpecialUsage

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def changeset(link, attrs) do
    link
    |> cast(attrs, [:element_id, :special_usage_id])
    |> validate_required([:element_id, :special_usage_id])
    |> foreign_key_constraint(:element_id)
    |> foreign_key_constraint(:special_usage_id)
    |> unique_constraint([:element_id, :special_usage_id],
      name: :idx_unicode_element_usages_unique
    )
  end
end
