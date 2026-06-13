defmodule Starter.Schema.Media.Variant do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "media_variants" do
    belongs_to :media, Starter.Schema.Media.Asset, type: Ecto.UUID
    field :variant_key, :string
    field :params, :string
    field :file_size, :integer
    field :content_type, :string

    timestamps(type: :utc_datetime_usec, inserted_at: :created_at, updated_at: false)
  end

  def changeset(variant, attrs) do
    variant
    |> cast(attrs, [:media_id, :variant_key, :params, :file_size, :content_type])
    |> validate_required([:media_id, :variant_key, :params])
    |> unique_constraint([:media_id, :params])
  end
end
