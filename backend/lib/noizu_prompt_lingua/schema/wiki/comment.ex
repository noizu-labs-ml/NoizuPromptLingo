defmodule NoizuPromptLingua.Schema.Wiki.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "wiki_comments" do
    field :page_id, :binary_id
    field :parent_id, :binary_id
    field :author, :string
    field :body, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:page_id, :parent_id, :author, :body])
    |> validate_required([:page_id, :body])
    |> foreign_key_constraint(:page_id)
    |> foreign_key_constraint(:parent_id)
  end
end
