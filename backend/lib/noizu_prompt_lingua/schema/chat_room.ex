defmodule NoizuPromptLingua.Schema.ChatRoom do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "chat_rooms" do
    field :organization_id, :binary_id
    field :project_id, :binary_id
    field :name, :string
    field :description, :string
    field :session_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  def changeset(room, attrs) do
    room
    |> cast(attrs, [:organization_id, :project_id, :name, :description, :session_id])
    |> validate_required([:organization_id, :name])
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:project_id)
  end
end
