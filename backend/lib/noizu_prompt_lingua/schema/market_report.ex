defmodule NoizuPromptLingua.Schema.MarketReport do
  @moduledoc """
  A market / competitor analysis report. The long-form body is LLM-generated and
  stored as an artifact (`artifact_id`); `summary` holds a short abstract.
  Org-scoped (required) with an optional project; slug unique within the org.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @report_types ~w(market_analysis competitor_analysis swot keyword_summary)
  @statuses ~w(draft generating ready archived)

  schema "market_reports" do
    field :organization_id, :binary_id
    field :project_id, :binary_id
    field :competitor_id, :binary_id
    field :segment_id, :binary_id
    field :slug, :string
    field :title, :string
    field :report_type, :string, default: "market_analysis"
    field :summary, :string
    field :artifact_id, :binary_id
    field :parameters, :map, default: %{}
    field :tags, {:array, :string}, default: []
    field :status, :string, default: "draft"

    timestamps(type: :utc_datetime)
  end

  @castable ~w(organization_id project_id competitor_id segment_id slug title
               report_type summary artifact_id parameters tags status)a

  def changeset(report, attrs) do
    report
    |> cast(attrs, @castable)
    |> validate_required([:organization_id, :slug, :title])
    |> validate_inclusion(:report_type, @report_types)
    |> validate_inclusion(:status, @statuses)
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:competitor_id)
    |> unique_constraint([:organization_id, :slug], name: :idx_market_reports_org_slug)
  end

  def report_types, do: @report_types
  def statuses, do: @statuses
end
