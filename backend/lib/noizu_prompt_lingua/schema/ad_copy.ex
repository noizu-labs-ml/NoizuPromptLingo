defmodule NoizuPromptLingua.Schema.AdCopy do
  @moduledoc """
  An ad-copy variant for a campaign (optionally an ad group). The full generated
  copy may be stored as an artifact (`artifact_id`); `headline`/`body`/`cta` hold
  the structured fields. Status mirrors the asset accept/reject lifecycle.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @statuses ~w(draft approved rejected)

  schema "ad_copies" do
    field :organization_id, :binary_id
    field :project_id, :binary_id
    field :campaign_id, :binary_id
    field :ad_group_id, :binary_id
    field :variant_number, :integer, default: 1
    field :headline, :string
    field :body, :string
    field :cta, :string
    field :format, :string
    field :artifact_id, :binary_id
    field :llm_generated, :boolean, default: false
    field :status, :string, default: "draft"
    field :metadata, :map, default: %{}

    timestamps(type: :utc_datetime)
  end

  @castable ~w(organization_id project_id campaign_id ad_group_id variant_number
               headline body cta format artifact_id llm_generated status metadata)a

  def changeset(ad_copy, attrs) do
    ad_copy
    |> cast(attrs, @castable)
    |> validate_required([:organization_id, :campaign_id])
    |> validate_inclusion(:status, @statuses)
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:campaign_id)
    |> foreign_key_constraint(:ad_group_id)
    |> unique_constraint([:ad_group_id, :variant_number], name: :idx_ad_copies_group_variant)
  end

  def statuses, do: @statuses
end
