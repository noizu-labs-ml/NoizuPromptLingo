defmodule NoizuPromptLingua.Schema.PubSubMessage do
  @moduledoc """
  A single message appended to a pubsub channel. `seq` is assigned server-side
  from the dedicated `npl_pubsub_messages_seq` sequence (Postgres
  `DEFAULT nextval(...)`), read back via `read_after_writes`, and gives a
  strictly increasing cursor followers track against.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "npl_pubsub_messages" do
    field :channel_id, :binary_id
    field :sender, :string
    field :body, :string
    field :seq, :integer, read_after_writes: true

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:channel_id, :sender, :body])
    |> validate_required([:channel_id, :sender, :body])
    |> foreign_key_constraint(:channel_id)
  end
end
