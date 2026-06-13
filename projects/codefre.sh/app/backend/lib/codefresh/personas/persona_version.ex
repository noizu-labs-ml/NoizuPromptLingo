defmodule Codefresh.Personas.PersonaVersion do
  @moduledoc """
  Immutable version of a persona. Carries tone tag, description, optional
  system-prompt preamble (pinned prompt_version), and free-form metadata.

  Tone is a free-text tag but canonical starter values are surfaced by
  `StarterLibrary`: `broken-english`, `hostile`, `confused-novice`,
  `adversarial`, `over-specific`, `context-switch`.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "persona_versions" do
    field :version_number, :integer
    field :tone, :string
    field :description, :string
    field :metadata, :map, default: %{}
    field :checksum, :binary

    belongs_to :persona, Codefresh.Personas.Persona
    belongs_to :organization, Codefresh.Organizations.Organization

    belongs_to :system_prompt_version, Codefresh.Prompts.PromptVersion,
      foreign_key: :system_prompt_version_id

    belongs_to :published_by, Codefresh.Accounts.User, foreign_key: :published_by_user_id

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def create_changeset(pv, attrs) do
    pv
    |> cast(attrs, [
      :persona_id,
      :organization_id,
      :version_number,
      :tone,
      :description,
      :metadata,
      :system_prompt_version_id,
      :checksum,
      :published_by_user_id
    ])
    |> validate_required([:persona_id, :organization_id, :version_number, :checksum])
    |> validate_number(:version_number, greater_than: 0)
    |> validate_length(:tone, max: 60)
    |> validate_length(:description, max: 4_000)
    |> unique_constraint([:persona_id, :version_number])
    |> unique_constraint([:persona_id, :checksum])
    |> foreign_key_constraint(:persona_id)
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:system_prompt_version_id)
  end

  @doc """
  Checksum over the mutable body of a persona version. Any change to tone,
  description, metadata, or the pinned system prompt produces a new version.
  """
  def compute_checksum(tone, description, metadata, system_prompt_version_id) do
    canonical =
      [
        "tone=#{to_string(tone)}",
        "desc=#{to_string(description)}",
        "meta=#{inspect(metadata, limit: :infinity)}",
        "preamble=#{to_string(system_prompt_version_id)}"
      ]
      |> Enum.join("\n---\n")

    :crypto.hash(:sha256, canonical)
  end
end
