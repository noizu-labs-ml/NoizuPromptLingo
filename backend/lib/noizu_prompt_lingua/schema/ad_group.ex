defmodule NoizuPromptLingua.Schema.AdGroup do
  @moduledoc """
  An ad group within a campaign. Org/project columns are denormalized from the
  parent campaign for filtering. Slug unique within the campaign.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @statuses ~w(active paused archived)

  schema "ad_groups" do
    field :organization_id, :binary_id
    field :project_id, :binary_id
    field :campaign_id, :binary_id
    field :slug, :string
    field :name, :string
    field :theme, :string
    field :keywords, {:array, :string}, default: []
    field :bid_cents, :integer
    field :status, :string, default: "active"
    field :metadata, :map, default: %{}

    timestamps(type: :utc_datetime)
  end

  @castable ~w(organization_id project_id campaign_id slug name theme keywords
               bid_cents status metadata)a

  def changeset(ad_group, attrs) do
    ad_group
    |> cast(attrs, @castable)
    |> validate_required([:organization_id, :campaign_id, :slug, :name])
    |> validate_inclusion(:status, @statuses)
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:campaign_id)
    |> unique_constraint([:campaign_id, :slug], name: :idx_ad_groups_campaign_slug)
  end

  def statuses, do: @statuses
end
