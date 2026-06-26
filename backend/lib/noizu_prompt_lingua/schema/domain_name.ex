defmodule NoizuPromptLingua.Schema.DomainName do
  @moduledoc """
  A domain-name candidate or registration, optionally tied to a campaign.
  Org-scoped (required) with an optional project; slug and FQDN unique within
  the organization.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @statuses ~w(candidate available registered in_use expired)

  schema "domain_names" do
    field :organization_id, :binary_id
    field :project_id, :binary_id
    field :campaign_id, :binary_id
    field :slug, :string
    field :name, :string
    field :status, :string, default: "candidate"
    field :registrar, :string
    field :registered_at, :date
    field :expires_at, :date
    field :metadata, :map, default: %{}
    field :tags, {:array, :string}, default: []

    timestamps(type: :utc_datetime)
  end

  @castable ~w(organization_id project_id campaign_id slug name status registrar
               registered_at expires_at metadata tags)a

  def changeset(domain, attrs) do
    domain
    |> cast(attrs, @castable)
    |> validate_required([:organization_id, :slug, :name])
    |> validate_inclusion(:status, @statuses)
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:campaign_id)
    |> unique_constraint([:organization_id, :slug], name: :idx_domain_names_org_slug)
    |> unique_constraint([:organization_id, :name], name: :idx_domain_names_org_name)
  end

  def statuses, do: @statuses
end
