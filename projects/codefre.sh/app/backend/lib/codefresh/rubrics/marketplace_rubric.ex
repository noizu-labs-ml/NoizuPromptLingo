defmodule Codefresh.Rubrics.MarketplaceRubric do
  @moduledoc """
  Cross-org catalog entry pointing to a published `RubricVersion` that a curator
  has promoted as importable. Imports deep-copy the underlying rubric_version
  into the importing org (see `Codefresh.Rubrics.Marketplace.import/2`).
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @curation_statuses ~w(pending curated featured deprecated)

  schema "marketplace_rubrics" do
    field :title, :string
    field :description, :string
    field :domain, :string
    field :published_at, :utc_datetime
    field :download_count, :integer, default: 0
    field :average_rating, :decimal
    field :curation_status, :string, default: "pending"

    belongs_to :rubric_version, Codefresh.Rubrics.RubricVersion
    belongs_to :author_organization, Codefresh.Organizations.Organization

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def curation_statuses, do: @curation_statuses

  def create_changeset(entry, attrs) do
    entry
    |> cast(attrs, [
      :rubric_version_id,
      :author_organization_id,
      :title,
      :description,
      :domain,
      :curation_status,
      :published_at
    ])
    |> validate_required([
      :rubric_version_id,
      :author_organization_id,
      :title,
      :domain,
      :published_at
    ])
    |> validate_inclusion(:curation_status, @curation_statuses)
    |> validate_length(:title, min: 1, max: 200)
    |> validate_length(:domain, min: 1, max: 80)
    |> foreign_key_constraint(:rubric_version_id)
    |> foreign_key_constraint(:author_organization_id)
  end

  def increment_download_changeset(entry) do
    change(entry, download_count: (entry.download_count || 0) + 1)
  end
end
