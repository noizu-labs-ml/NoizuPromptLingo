defmodule Codefresh.Datasets.DatasetEntry do
  @moduledoc """
  A single row inside a dataset version. `(dataset_version_id, entry_key)` is
  unique — supports re-import idempotency (US-104).

  For `request_response` datasets the contract enforces a non-empty `input` and
  a present `expected_output`. For `conversation` datasets `expected_output` may
  be omitted (Wave 3+ semantics).
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "dataset_entries" do
    field :entry_key, :string
    field :input, :map, default: %{}
    field :expected_output, :map
    field :tags, {:array, :string}, default: []
    field :notes, :string

    belongs_to :dataset_version, Codefresh.Datasets.DatasetVersion
    belongs_to :organization, Codefresh.Organizations.Organization

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def create_changeset(entry, attrs) do
    entry
    |> cast(attrs, [
      :dataset_version_id,
      :organization_id,
      :entry_key,
      :input,
      :expected_output,
      :tags,
      :notes
    ])
    |> validate_required([:dataset_version_id, :organization_id, :entry_key, :input])
    |> validate_length(:entry_key, min: 1, max: 200)
    |> validate_input_present()
    |> unique_constraint([:dataset_version_id, :entry_key])
    |> foreign_key_constraint(:dataset_version_id)
    |> foreign_key_constraint(:organization_id)
  end

  defp validate_input_present(changeset) do
    case get_field(changeset, :input) do
      nil -> add_error(changeset, :input, "can't be blank")
      m when is_map(m) and map_size(m) == 0 -> add_error(changeset, :input, "can't be empty")
      _ -> changeset
    end
  end
end
