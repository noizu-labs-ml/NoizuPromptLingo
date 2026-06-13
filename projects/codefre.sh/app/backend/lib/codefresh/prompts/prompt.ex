defmodule Codefresh.Prompts.Prompt do
  @moduledoc """
  Head entity for a reusable prompt. Immutable bodies live on `PromptVersion`.
  A prompt is unpublished until at least one `PromptVersion` exists and
  `current_version_id` is set.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "prompts" do
    field :slug, :string
    field :name, :string
    field :description, :string
    field :archived_at, :utc_datetime

    belongs_to :organization, Codefresh.Organizations.Organization
    belongs_to :current_version, Codefresh.Prompts.PromptVersion, foreign_key: :current_version_id
    belongs_to :created_by, Codefresh.Accounts.User, foreign_key: :created_by_user_id

    has_many :versions, Codefresh.Prompts.PromptVersion

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset for creating a new prompt head. Accepts `name`, `description?`,
  `slug?` (auto-derived from name when missing), `organization_id`,
  `created_by_user_id?`.
  """
  def create_changeset(prompt, attrs) do
    prompt
    |> cast(attrs, [:slug, :name, :description, :organization_id, :created_by_user_id])
    |> validate_required([:name, :organization_id])
    |> validate_length(:name, min: 1, max: 200)
    |> validate_length(:description, max: 4_000)
    |> maybe_derive_slug()
    |> validate_format(:slug, ~r/^[a-z0-9][a-z0-9-]*$/,
      message: "must be lowercase alphanumeric with dashes"
    )
    |> validate_length(:slug, min: 1, max: 120)
    |> unique_constraint(:slug, name: :prompts_organization_id_slug_index)
    |> foreign_key_constraint(:organization_id)
  end

  @doc """
  Changeset for updating head metadata (name / description / slug). Body and
  template variables are never mutated through the head — they live on versions.
  """
  def update_changeset(prompt, attrs) do
    prompt
    |> cast(attrs, [:name, :description, :slug])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 200)
    |> validate_length(:description, max: 4_000)
    |> validate_format(:slug, ~r/^[a-z0-9][a-z0-9-]*$/,
      message: "must be lowercase alphanumeric with dashes"
    )
    |> unique_constraint(:slug, name: :prompts_organization_id_slug_index)
  end

  @doc "Internal — used after a new version is inserted to advance `current_version_id`."
  def advance_current_version_changeset(prompt, version_id) do
    change(prompt, current_version_id: version_id)
  end

  @doc "Soft-archive changeset."
  def archive_changeset(prompt) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    change(prompt, archived_at: now)
  end

  def unarchive_changeset(prompt), do: change(prompt, archived_at: nil)

  defp maybe_derive_slug(changeset) do
    case {get_change(changeset, :slug), get_field(changeset, :slug), get_change(changeset, :name)} do
      {nil, nil, name} when is_binary(name) -> put_change(changeset, :slug, derive_slug(name))
      _ -> changeset
    end
  end

  @doc false
  def derive_slug(name) do
    name
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, "-")
    |> String.trim("-")
  end
end
