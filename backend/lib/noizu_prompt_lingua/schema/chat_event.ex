defmodule NoizuPromptLingua.Schema.ChatEvent do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @event_types ~w(action todo milestone decision)

  schema "chat_events" do
    belongs_to :room, NoizuPromptLingua.Schema.ChatRoom
    field :event_type, :string
    field :content, :string
    field :sender, :string
    field :metadata, :map

    timestamps(type: :utc_datetime)
  end

  def changeset(event, attrs) do
    event
    |> cast(attrs, [:room_id, :event_type, :content, :sender, :metadata])
    |> validate_required([:room_id, :event_type, :content, :sender])
    |> validate_inclusion(:event_type, @event_types)
    |> foreign_key_constraint(:room_id)
  end

  def event_types, do: @event_types
end
