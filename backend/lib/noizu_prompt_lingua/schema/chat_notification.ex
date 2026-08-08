defmodule NoizuPromptLingua.Schema.ChatNotification do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "chat_notifications" do
    belongs_to :room, NoizuPromptLingua.Schema.ChatRoom
    field :persona, :string
    field :message, :string
    field :read, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  def changeset(notif, attrs) do
    notif
    |> cast(attrs, [:room_id, :persona, :message, :read])
    |> validate_required([:room_id, :persona, :message])
    |> foreign_key_constraint(:room_id)
  end
end
