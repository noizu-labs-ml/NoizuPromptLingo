defmodule NoizuPromptLingua.Schema.Wiki.Reaction do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  # Polymorphic over wiki pages and comments. `target_type` is "page" | "comment"
  # and `target_id` references the corresponding row (no DB FK).
  @target_types ~w(page comment)

  schema "wiki_reactions" do
    field :target_type, :string
    field :target_id, :binary_id
    field :emoji, :string
    field :actor, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(reaction, attrs) do
    reaction
    |> cast(attrs, [:target_type, :target_id, :emoji, :actor])
    |> validate_required([:target_type, :target_id, :emoji, :actor])
    |> validate_inclusion(:target_type, @target_types)
    |> unique_constraint([:target_type, :target_id, :emoji, :actor],
      name: :idx_wiki_reactions_unique
    )
  end

  def target_types, do: @target_types
end
