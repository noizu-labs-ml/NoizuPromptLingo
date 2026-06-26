defmodule NoizuPromptLingua.Schema.LandingPage do
  @moduledoc """
  A landing page, optionally tied to a campaign and/or a domain name. The page
  body is LLM-generated and stored as an artifact (`artifact_id`). Org-scoped
  (required) with an optional project; slug unique within the organization.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @statuses ~w(draft generating published archived)

  schema "landing_pages" do
    field :organization_id, :binary_id
    field :project_id, :binary_id
    field :campaign_id, :binary_id
    field :domain_name_id, :binary_id
    field :slug, :string
    field :title, :string
    field :path, :string
    field :headline, :string
    field :artifact_id, :binary_id
    field :status, :string, default: "draft"
    field :metadata, :map, default: %{}
    field :tags, {:array, :string}, default: []

    timestamps(type: :utc_datetime)
  end

  @castable ~w(organization_id project_id campaign_id domain_name_id slug title
               path headline artifact_id status metadata tags)a

  def changeset(page, attrs) do
    page
    |> cast(attrs, @castable)
    |> validate_required([:organization_id, :slug, :title])
    |> validate_inclusion(:status, @statuses)
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:campaign_id)
    |> foreign_key_constraint(:domain_name_id)
    |> unique_constraint([:organization_id, :slug], name: :idx_landing_pages_org_slug)
  end

  def statuses, do: @statuses
end
