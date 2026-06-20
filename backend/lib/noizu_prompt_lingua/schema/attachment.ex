defmodule NoizuPromptLingua.Schema.Attachment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @artifact_types ~w(artifact url git_branch file)

  schema "npl_attachments" do
    field :entity_type, :string
    field :entity_id, :binary_id
    field :artifact_type, :string
    field :url, :string
    field :git_branch, :string
    field :description, :string
    field :created_by, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(attachment, attrs) do
    attachment
    |> cast(attrs, [:entity_type, :entity_id, :artifact_type, :url, :git_branch, :description, :created_by])
    |> validate_required([:entity_type, :entity_id, :artifact_type])
    |> validate_inclusion(:artifact_type, @artifact_types)
  end
end
