defmodule NoizuPromptLingua.Schema.ReviewOverlay do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "review_overlays" do
    belongs_to :review, NoizuPromptLingua.Schema.Review
    field :x, :integer
    field :y, :integer
    field :width, :integer
    field :height, :integer
    field :comment, :string
    field :persona, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(overlay, attrs) do
    overlay
    |> cast(attrs, [:review_id, :x, :y, :width, :height, :comment, :persona])
    |> validate_required([:review_id, :x, :y, :comment, :persona])
    |> foreign_key_constraint(:review_id)
  end
end
