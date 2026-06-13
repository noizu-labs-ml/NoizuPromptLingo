defmodule Codefresh.Rubrics.Rubric do
  @moduledoc """
  Head entity for a scoring rubric. Body (judge prompt + model + scale + criteria)
  lives on `RubricVersion`. Published when at least one version exists.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "rubrics" do
    field :slug, :string
    field :name, :string
    field :description, :string
    field :archived_at, :utc_datetime

    belongs_to :organization, Codefresh.Organizations.Organization
    belongs_to :current_version, Codefresh.Rubrics.RubricVersion, foreign_key: :current_version_id
    belongs_to :created_by, Codefresh.Accounts.User, foreign_key: :created_by_user_id

    has_many :versions, Codefresh.Rubrics.RubricVersion

    timestamps(type: :utc_datetime)
  end

  def create_changeset(rubric, attrs) do
    rubric
    |> cast(attrs, [:slug, :name, :description, :organization_id, :created_by_user_id])
    |> validate_required([:name, :organization_id])
    |> validate_length(:name, min: 1, max: 200)
    |> validate_length(:description, max: 4_000)
    |> maybe_derive_slug()
    |> validate_format(:slug, ~r/^[a-z0-9][a-z0-9-]*$/,
      message: "must be lowercase alphanumeric with dashes"
    )
    |> validate_length(:slug, min: 1, max: 120)
    |> unique_constraint(:slug, name: :rubrics_organization_id_slug_index)
    |> foreign_key_constraint(:organization_id)
  end

  def update_changeset(rubric, attrs) do
    rubric
    |> cast(attrs, [:name, :description, :slug])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 200)
    |> validate_length(:description, max: 4_000)
    |> validate_format(:slug, ~r/^[a-z0-9][a-z0-9-]*$/,
      message: "must be lowercase alphanumeric with dashes"
    )
    |> unique_constraint(:slug, name: :rubrics_organization_id_slug_index)
  end

  def advance_current_version_changeset(rubric, version_id) do
    change(rubric, current_version_id: version_id)
  end

  def archive_changeset(rubric) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    change(rubric, archived_at: now)
  end

  def unarchive_changeset(rubric), do: change(rubric, archived_at: nil)

  defp maybe_derive_slug(changeset) do
    case {get_change(changeset, :slug), get_field(changeset, :slug), get_change(changeset, :name)} do
      {nil, nil, name} when is_binary(name) -> put_change(changeset, :slug, derive_slug(name))
      _ -> changeset
    end
  end

  def derive_slug(name) do
    name
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, "-")
    |> String.trim("-")
  end
end
