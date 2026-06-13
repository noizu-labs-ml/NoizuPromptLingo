defmodule NoizuPromptLingua.Schema.AssetEntry do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @asset_types ~w(image video music voice component html diagram document svg style_guide)
  @statuses ~w(draft generating review published archived)
  @qualities ~w(low medium high)

  schema "asset_entries" do
    field :slug, :string
    field :title, :string
    field :asset_type, :string
    field :status, :string, default: "draft"
    field :quality, :string
    field :prompt_yaml, :string
    field :tags, {:array, :string}, default: []
    field :product_targets, {:array, :string}, default: []
    field :project_id, :binary_id
    field :active_output_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:slug, :title, :asset_type, :status, :quality, :prompt_yaml,
                     :tags, :product_targets, :project_id, :active_output_id])
    |> validate_required([:slug, :title, :asset_type, :prompt_yaml, :project_id])
    |> validate_inclusion(:asset_type, @asset_types)
    |> validate_inclusion(:status, @statuses)
    |> validate_inclusion(:quality, @qualities ++ [nil])
    |> unique_constraint([:project_id, :slug])
  end

  def asset_types, do: @asset_types
end
