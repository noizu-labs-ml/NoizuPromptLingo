defmodule NoizuPromptLingua.Schema.Campaign do
  @moduledoc """
  A marketing campaign (SEO / PPC / email / social / content / display).
  Org-scoped (required) with an optional project; slug unique within the org.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @channels ~w(seo ppc email social content display)
  @statuses ~w(draft active paused completed archived)

  schema "campaigns" do
    field :organization_id, :binary_id
    field :project_id, :binary_id
    field :segment_id, :binary_id
    field :slug, :string
    field :name, :string
    field :channel, :string
    field :objective, :string
    field :status, :string, default: "draft"
    field :budget_cents, :integer
    field :currency, :string, default: "USD"
    field :start_date, :date
    field :end_date, :date
    field :targeting, :map, default: %{}
    field :metadata, :map, default: %{}
    field :tags, {:array, :string}, default: []

    timestamps(type: :utc_datetime)
  end

  @castable ~w(organization_id project_id segment_id slug name channel objective
               status budget_cents currency start_date end_date targeting metadata tags)a

  def changeset(campaign, attrs) do
    campaign
    |> cast(attrs, @castable)
    |> validate_required([:organization_id, :slug, :name, :channel])
    |> validate_inclusion(:channel, @channels)
    |> validate_inclusion(:status, @statuses)
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:project_id)
    |> unique_constraint([:organization_id, :slug], name: :idx_campaigns_org_slug)
  end

  def channels, do: @channels
  def statuses, do: @statuses
end
