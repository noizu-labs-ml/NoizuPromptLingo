defmodule NoizuPromptLingua.Schema.ChatMember do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "chat_members" do
    belongs_to :room, NoizuPromptLingua.Schema.ChatRoom
    field :persona, :string
    field :role, :string, default: "member"

    timestamps(type: :utc_datetime)
  end

  def changeset(member, attrs) do
    member
    |> cast(attrs, [:room_id, :persona, :role])
    |> validate_required([:room_id, :persona])
    |> validate_inclusion(:role, ~w(member admin))
    |> unique_constraint([:room_id, :persona])
    |> foreign_key_constraint(:room_id)
  end
end
