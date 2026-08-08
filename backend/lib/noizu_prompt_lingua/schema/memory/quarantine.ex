defmodule NoizuPromptLingua.Schema.Memory.Quarantine do
  @moduledoc "A memory the Guardian flagged at ingest, held for review."
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "memory_quarantine" do
    field :memory_id, Ecto.UUID
    field :organization_id, Ecto.UUID
    field :scope_type, Ecto.Enum, values: [:persona, :weego, :team_member]
    field :scope_id, Ecto.UUID
    field :reason, :string
    field :payload, :map, default: %{}
    field :resolved, :boolean, default: false

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(q, attrs) do
    q
    |> cast(attrs, ~w(memory_id organization_id scope_type scope_id reason payload resolved)a)
    |> validate_required([:organization_id, :scope_type, :scope_id, :reason])
  end
end
