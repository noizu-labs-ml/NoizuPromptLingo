defmodule NoizuPromptLingua.Schema.AssetEntry do
  @moduledoc """
  A media-prompt asset entry: a saved `.media.prompt` (YAML) plus its asset type,
  status, and metadata. Bound to an organization (required); a project is
  optional. Generations produce `AssetOutput` rows backed by artifacts.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @asset_types ~w(image video music voice component html diagram document svg style_guide)
  @statuses ~w(draft generating review published archived)
  @qualities ~w(low medium high)

  schema "asset_entries" do
    field :organization_id, :binary_id
    field :project_id, :binary_id
    field :slug, :string
    field :title, :string
    field :asset_type, :string
    field :status, :string, default: "draft"
    field :quality, :string
    field :prompt_yaml, :string
    field :tags, {:array, :string}, default: []
    field :product_targets, {:array, :string}, default: []
    field :active_output_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [
      :organization_id,
      :project_id,
      :slug,
      :title,
      :asset_type,
      :status,
      :quality,
      :prompt_yaml,
      :tags,
      :product_targets,
      :active_output_id
    ])
    |> validate_required([:organization_id, :slug, :title, :asset_type, :prompt_yaml])
    |> validate_inclusion(:asset_type, @asset_types)
    |> validate_inclusion(:status, @statuses)
    |> validate_inclusion(:quality, @qualities ++ [nil])
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:project_id)
    |> unique_constraint([:organization_id, :slug], name: :idx_asset_entries_org_slug)
  end

  def asset_types, do: @asset_types
  def statuses, do: @statuses
  def qualities, do: @qualities
end
