defmodule NoizuPromptLingua.Schema.Memory.Compartment do
  @moduledoc "An access-control partition for memories owned by a scope."
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "memory_compartments" do
    field :organization_id, Ecto.UUID
    field :scope_type, Ecto.Enum, values: [:persona, :weego, :team_member]
    field :scope_id, Ecto.UUID
    field :slug, :string
    field :classification, Ecto.Enum, values: [:open, :restricted, :sealed], default: :open
    field :settings, :map, default: %{}

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(compartment, attrs) do
    compartment
    |> cast(attrs, ~w(organization_id scope_type scope_id slug classification settings)a)
    |> validate_required([:organization_id, :scope_type, :scope_id, :slug])
    |> unique_constraint([:organization_id, :scope_type, :scope_id, :slug], name: :uq_compartment)
  end
end
