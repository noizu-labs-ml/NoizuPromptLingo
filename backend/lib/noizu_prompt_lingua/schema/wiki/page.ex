defmodule NoizuPromptLingua.Schema.Wiki.Page do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "wiki_pages" do
    field :space_id, :binary_id
    field :parent_id, :binary_id
    field :slug, :string
    field :title, :string
    field :content, :string
    field :position, :integer, default: 0

    has_many :comments, NoizuPromptLingua.Schema.Wiki.Comment
    has_many :attachments, NoizuPromptLingua.Schema.Wiki.Attachment

    timestamps(type: :utc_datetime)
  end

  def changeset(page, attrs) do
    page
    |> cast(attrs, [:space_id, :parent_id, :slug, :title, :content, :position])
    |> validate_required([:space_id, :slug, :title])
    |> validate_format(:slug, ~r/^[a-z0-9-]+$/,
      message: "must be lowercase letters, numbers, and hyphens"
    )
    |> unique_constraint([:space_id, :slug], name: :idx_wiki_pages_space_slug)
    |> foreign_key_constraint(:space_id)
    |> foreign_key_constraint(:parent_id)
  end
end
