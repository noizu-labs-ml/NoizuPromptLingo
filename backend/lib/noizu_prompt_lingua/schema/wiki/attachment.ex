defmodule NoizuPromptLingua.Schema.Wiki.Attachment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "wiki_attachments" do
    field :page_id, :binary_id
    field :filename, :string
    field :mime_type, :string
    field :url, :string
    field :byte_size, :integer

    timestamps(type: :utc_datetime)
  end

  def changeset(attachment, attrs) do
    attachment
    |> cast(attrs, [:page_id, :filename, :mime_type, :url, :byte_size])
    |> validate_required([:page_id, :filename])
    |> foreign_key_constraint(:page_id)
  end
end
