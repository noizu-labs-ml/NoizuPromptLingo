defmodule NoizuPromptLingua.Schema.Session do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "sessions" do
    field :title, :string
    field :description, :string
    field :status, :string, default: "active"
    field :user_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  def changeset(session, attrs) do
    session
    |> cast(attrs, [:title, :description, :status, :user_id])
    |> validate_required([:title])
    |> validate_inclusion(:status, ["active", "archived", "completed"])
  end
end
