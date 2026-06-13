defmodule NoizuPromptLingua.Schema.ChatMessage do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "chat_messages" do
    belongs_to :room, NoizuPromptLingua.Schema.ChatRoom
    field :content, :string
    field :sender, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(msg, attrs) do
    msg
    |> cast(attrs, [:room_id, :content, :sender])
    |> validate_required([:room_id, :content, :sender])
    |> foreign_key_constraint(:room_id)
  end
end
