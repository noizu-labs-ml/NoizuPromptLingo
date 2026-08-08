defmodule Noizu.PM.Schema.Clients.Client do
  @moduledoc """
  Org-scoped client (customer / billing party). Distinct from Organization
  (tenant). Projects may optionally reference a client via `client_id`.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "clients" do
    belongs_to :organization, Noizu.PM.Schema.Organizations.Organization, type: Ecto.UUID
    field :name, :string
    field :slug, :string
    field :status, :string, default: "active"
    field :notes, :string, default: ""
    field :default_hourly_rate_cents, :integer
    field :currency, :string, default: "USD"
    field :external_ids, :map, default: %{}
    field :settings, :map, default: %{}

    belongs_to :created_by_user, Noizu.PM.Schema.Users.User,
      type: Ecto.UUID,
      foreign_key: :created_by

    field :archived_at, :utc_datetime_usec
    field :lock_version, :integer, default: 0

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(client, attrs) do
    client
    |> cast(attrs, [
      :organization_id,
      :name,
      :slug,
      :status,
      :notes,
      :default_hourly_rate_cents,
      :currency,
      :external_ids,
      :settings,
      :created_by,
      :archived_at,
      :lock_version
    ])
    |> validate_required([:organization_id, :name, :slug])
    |> validate_format(:slug, ~r/^[a-z0-9][a-z0-9-]*[a-z0-9]$|^[a-z0-9]$/,
      message: "must be lowercase alphanumeric with hyphens, no leading/trailing hyphens"
    )
    |> validate_inclusion(:status, ["active", "archived", "deleted"])
    |> validate_number(:default_hourly_rate_cents, greater_than_or_equal_to: 0)
    |> unique_constraint([:organization_id, :slug])
    |> optimistic_lock(:lock_version)
  end
end
