defmodule NoizuPromptLingua.Schema.ArtifactRevision do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "artifact_revisions" do
    belongs_to :artifact, NoizuPromptLingua.Schema.Artifact
    field :content, :string
    field :note, :string
    field :revision_number, :integer

    timestamps(type: :utc_datetime)
  end

  def changeset(revision, attrs) do
    revision
    |> cast(attrs, [:artifact_id, :content, :note, :revision_number])
    |> validate_required([:artifact_id, :content, :revision_number])
    |> foreign_key_constraint(:artifact_id)
  end
end
