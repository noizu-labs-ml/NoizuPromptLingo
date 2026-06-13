defmodule Codefresh.Datasets.DatasetVersion do
  @moduledoc """
  Immutable version of a dataset. Checksum is computed over the normalized JSON
  of all dataset entries sorted by `entry_key`, plus an optional default rubric
  pin (US-110).

  `default_rubric_version_id` attaches a pinned rubric_version as the default
  scorer for dataset-eval runs (US-105). Cross-org rubric pins are rejected.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "dataset_versions" do
    field :version_number, :integer
    field :yaml_source, :string
    field :checksum, :binary

    belongs_to :dataset, Codefresh.Datasets.Dataset
    belongs_to :organization, Codefresh.Organizations.Organization

    belongs_to :parent_version, Codefresh.Datasets.DatasetVersion,
      foreign_key: :parent_version_id

    belongs_to :default_rubric_version, Codefresh.Rubrics.RubricVersion,
      foreign_key: :default_rubric_version_id

    belongs_to :published_by, Codefresh.Accounts.User, foreign_key: :published_by_user_id

    has_many :entries, Codefresh.Datasets.DatasetEntry

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def create_changeset(dv, attrs) do
    dv
    |> cast(attrs, [
      :dataset_id,
      :organization_id,
      :version_number,
      :yaml_source,
      :parent_version_id,
      :default_rubric_version_id,
      :checksum,
      :published_by_user_id
    ])
    |> validate_required([:dataset_id, :organization_id, :version_number, :checksum])
    |> validate_number(:version_number, greater_than: 0)
    |> unique_constraint([:dataset_id, :version_number])
    |> unique_constraint([:dataset_id, :checksum])
    |> foreign_key_constraint(:dataset_id)
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:default_rubric_version_id)
  end

  @doc """
  Checksum over normalized dataset entries + default rubric pin. Entries are
  sorted by `entry_key` and each is reduced to its canonical tuple so reordered
  inserts produce the same checksum.
  """
  def compute_checksum(entries, default_rubric_version_id \\ nil) do
    normalized =
      entries
      |> Enum.map(&normalize_entry/1)
      |> Enum.sort_by(& &1.entry_key)
      |> Enum.map(&inspect(&1, limit: :infinity))
      |> Enum.join("\n---\n")

    canonical =
      [
        "rubric=#{to_string(default_rubric_version_id)}",
        "entries=",
        normalized
      ]
      |> Enum.join("\n")

    :crypto.hash(:sha256, canonical)
  end

  defp normalize_entry(%{} = e) do
    %{
      entry_key: to_string(get(e, :entry_key, "")),
      input: get(e, :input, %{}) || %{},
      expected_output: get(e, :expected_output, nil),
      tags: get(e, :tags, []) || [],
      notes: get(e, :notes, nil)
    }
  end

  defp get(%_{} = struct, key, default), do: Map.get(struct, key, default)

  defp get(m, key, default) when is_map(m) do
    Map.get(m, key, Map.get(m, to_string(key), default))
  end
end
