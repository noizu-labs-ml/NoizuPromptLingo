defmodule NoizuPromptLingua.Schema.Keyword do
  @moduledoc """
  A keyword-research row: a term with optional SEO metrics (search volume,
  difficulty, CPC). Metrics are manually or LLM-populated (no external API in
  this pass). Org-scoped (required) with an optional project; slug unique within
  the organization and the term unique within a scope.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @intents ~w(informational commercial transactional navigational)

  schema "keywords" do
    field :organization_id, :binary_id
    field :project_id, :binary_id
    field :competitor_id, :binary_id
    field :slug, :string
    field :term, :string
    field :intent, :string
    field :volume, :integer
    field :difficulty, :integer
    field :cpc, :decimal
    field :competition, :decimal
    field :source, :string
    field :metadata, :map, default: %{}
    field :tags, {:array, :string}, default: []

    timestamps(type: :utc_datetime)
  end

  @castable ~w(organization_id project_id competitor_id slug term intent volume
               difficulty cpc competition source metadata tags)a

  def changeset(keyword, attrs) do
    keyword
    |> cast(attrs, @castable)
    |> validate_required([:organization_id, :slug, :term])
    |> validate_inclusion(:intent, @intents)
    |> validate_number(:difficulty, greater_than_or_equal_to: 0, less_than_or_equal_to: 100)
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:competitor_id)
    |> unique_constraint([:organization_id, :slug], name: :idx_keywords_org_slug)
    |> unique_constraint([:organization_id, :project_id, :term], name: :idx_keywords_proj_term)
    |> unique_constraint([:organization_id, :term], name: :idx_keywords_org_term)
  end

  def intents, do: @intents
end
