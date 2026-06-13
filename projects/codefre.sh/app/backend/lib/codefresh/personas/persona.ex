defmodule Codefresh.Personas.Persona do
  @moduledoc """
  Head entity for a persona. Body (tone, system preamble, metadata) lives on
  `PersonaVersion`. Published when at least one version exists and
  `current_version_id` is set.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "personas" do
    field :slug, :string
    field :name, :string
    field :description, :string
    field :archived_at, :utc_datetime

    belongs_to :organization, Codefresh.Organizations.Organization

    belongs_to :current_version, Codefresh.Personas.PersonaVersion,
      foreign_key: :current_version_id

    belongs_to :created_by, Codefresh.Accounts.User, foreign_key: :created_by_user_id

    has_many :versions, Codefresh.Personas.PersonaVersion

    timestamps(type: :utc_datetime)
  end

  def create_changeset(persona, attrs) do
    persona
    |> cast(attrs, [:slug, :name, :description, :organization_id, :created_by_user_id])
    |> validate_required([:name, :organization_id])
    |> validate_length(:name, min: 1, max: 200)
    |> validate_length(:description, max: 4_000)
    |> maybe_derive_slug()
    |> validate_format(:slug, ~r/^[a-z0-9][a-z0-9-]*$/,
      message: "must be lowercase alphanumeric with dashes"
    )
    |> validate_length(:slug, min: 1, max: 120)
    |> unique_constraint(:slug, name: :personas_organization_id_slug_index)
    |> foreign_key_constraint(:organization_id)
  end

  def update_changeset(persona, attrs) do
    persona
    |> cast(attrs, [:name, :description, :slug])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 200)
    |> validate_length(:description, max: 4_000)
    |> validate_format(:slug, ~r/^[a-z0-9][a-z0-9-]*$/,
      message: "must be lowercase alphanumeric with dashes"
    )
    |> unique_constraint(:slug, name: :personas_organization_id_slug_index)
  end

  def advance_current_version_changeset(persona, version_id) do
    change(persona, current_version_id: version_id)
  end

  def archive_changeset(persona) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    change(persona, archived_at: now)
  end

  def unarchive_changeset(persona), do: change(persona, archived_at: nil)

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
