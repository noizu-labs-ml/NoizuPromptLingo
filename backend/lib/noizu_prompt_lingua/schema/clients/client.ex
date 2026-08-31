defmodule NoizuPromptLingua.Schema.Clients.Client do
  @moduledoc """
  Org-scoped client (customer / billing party) — LOCAL app-DB mirror of the
  former pm_core `clients` table (spec gap: TRP v1 has no clients endpoints).

  Column-for-column parity with the old `Noizu.PM.Schema.Clients.Client` so
  `NoizuPromptLingua.Clients` keeps returning the same shape.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "clients" do
    field :organization_id, Ecto.UUID
    field :name, :string
    field :slug, :string
    field :status, :string, default: "active"
    field :notes, :string, default: ""
    field :default_hourly_rate_cents, :integer
    field :currency, :string, default: "USD"
    field :external_ids, :map, default: %{}
    field :settings, :map, default: %{}
    field :created_by, Ecto.UUID
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
