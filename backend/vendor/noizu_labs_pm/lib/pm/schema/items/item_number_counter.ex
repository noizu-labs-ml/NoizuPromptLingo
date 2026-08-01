defmodule Noizu.PM.Schema.Items.ItemNumberCounter do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @moduledoc """
  Per-scope gap-free item number counter. The (organization_id, project_id) is
  the scope; project_id NULL is the org-level bucket. The two partial unique
  indexes idx_inc_proj / idx_inc_org are the ON CONFLICT targets for the atomic
  upsert that claims the next number inside the item's insert txn.
  """

  schema "item_number_counters" do
    field :organization_id, :binary_id
    field :project_id, :binary_id
    field :last_number, :integer, default: 0

    timestamps(type: :utc_datetime)
  end

  # Only used via raw SQL upsert (ON CONFLICT), so no validation changeset is
  # needed for the hot path; this exists for completeness/test seeding.
  def changeset(counter, attrs) do
    counter
    |> cast(attrs, [:organization_id, :project_id, :last_number])
    |> validate_required([:organization_id, :last_number])
  end
end
