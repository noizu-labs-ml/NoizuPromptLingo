defmodule NoizuPromptLingua.Schema.Artifact do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @kinds ~w(code document image wiki config binary)

  schema "artifacts" do
    field :organization_id, :binary_id
    field :kind, :string
    field :title, :string
    field :mime_type, :string
    field :project_id, :binary_id

    has_many :revisions, NoizuPromptLingua.Schema.ArtifactRevision

    timestamps(type: :utc_datetime)
  end

  def changeset(artifact, attrs) do
    artifact
    |> cast(attrs, [:organization_id, :kind, :title, :mime_type, :project_id])
    |> validate_required([:organization_id, :kind, :title])
    |> validate_inclusion(:kind, @kinds)
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:project_id)
  end

  def kinds, do: @kinds
end
