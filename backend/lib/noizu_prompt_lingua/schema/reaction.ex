defmodule NoizuPromptLingua.Schema.Reaction do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "npl_reactions" do
    field :entity_type, :string
    field :entity_id, :binary_id
    field :persona, :string
    field :emoji, :string

    timestamps(type: :utc_datetime)
  end

  # `emoji` accepts a unicode emoji OR a shortcode (e.g. ":+1:"), so we don't enforce
  # emoji-ness — but we cap length so an arbitrary multi-KB string can't be stored as
  # a "reaction" (Sofia G2: emoji validation, unicode vs arbitrary string). A complex
  # ZWJ/flag emoji is a handful of graphemes; 64 is generous headroom.
  def changeset(reaction, attrs) do
    reaction
    |> cast(attrs, [:entity_type, :entity_id, :persona, :emoji])
    |> validate_required([:entity_type, :entity_id, :persona, :emoji])
    |> validate_length(:emoji, max: 64)
    |> unique_constraint([:entity_type, :entity_id, :persona, :emoji])
  end
end
