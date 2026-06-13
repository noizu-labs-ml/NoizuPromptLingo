defmodule Codefresh.Scripts.Script do
  @moduledoc """
  Head entity for a conversation test script. Each script has an editable draft
  `script_version` at all times (created on head insert) and an optional
  `current_version_id` pointing at the latest published version.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "scripts" do
    field :slug, :string
    field :name, :string
    field :description, :string
    field :archived_at, :utc_datetime

    belongs_to :organization, Codefresh.Organizations.Organization

    belongs_to :current_version, Codefresh.Scripts.ScriptVersion, foreign_key: :current_version_id

    belongs_to :created_by, Codefresh.Accounts.User, foreign_key: :created_by_user_id

    has_many :versions, Codefresh.Scripts.ScriptVersion

    timestamps(type: :utc_datetime)
  end

  def create_changeset(script, attrs) do
    script
    |> cast(attrs, [:slug, :name, :description, :organization_id, :created_by_user_id])
    |> validate_required([:name, :organization_id])
    |> validate_length(:name, min: 1, max: 200)
    |> validate_length(:description, max: 4_000)
    |> maybe_derive_slug()
    |> validate_format(:slug, ~r/^[a-z0-9][a-z0-9-]*$/,
      message: "must be lowercase alphanumeric with dashes"
    )
    |> validate_length(:slug, min: 1, max: 120)
    |> unique_constraint(:slug, name: :scripts_organization_id_slug_index)
    |> foreign_key_constraint(:organization_id)
  end

  def update_changeset(script, attrs) do
    script
    |> cast(attrs, [:name, :description, :slug])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 200)
    |> validate_length(:description, max: 4_000)
    |> validate_format(:slug, ~r/^[a-z0-9][a-z0-9-]*$/,
      message: "must be lowercase alphanumeric with dashes"
    )
    |> unique_constraint(:slug, name: :scripts_organization_id_slug_index)
  end

  def advance_current_version_changeset(script, version_id),
    do: change(script, current_version_id: version_id)

  def archive_changeset(script) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    change(script, archived_at: now)
  end

  defp maybe_derive_slug(cs) do
    case {get_change(cs, :slug), get_field(cs, :slug), get_change(cs, :name)} do
      {nil, nil, name} when is_binary(name) -> put_change(cs, :slug, derive_slug(name))
      _ -> cs
    end
  end

  def derive_slug(name) do
    name
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, "-")
    |> String.trim("-")
  end
end
