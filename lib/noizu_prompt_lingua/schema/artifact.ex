defmodule NoizuPromptLingua.Schema.Artifact do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @kinds ~w(code document image wiki config binary)

  schema "artifacts" do
    field :kind, :string
    field :title, :string
    field :mime_type, :string
    field :project_id, :binary_id

    has_many :revisions, NoizuPromptLingua.Schema.ArtifactRevision

    timestamps(type: :utc_datetime)
  end

  def changeset(artifact, attrs) do
    artifact
    |> cast(attrs, [:kind, :title, :mime_type, :project_id])
    |> validate_required([:kind, :title])
    |> validate_inclusion(:kind, @kinds)
  end

  def kinds, do: @kinds
end
