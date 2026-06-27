defmodule NoizuPromptLingua.Schema.PubSubFollow do
  @moduledoc """
  A persona's follow of a pubsub channel. Unique per `(channel_id, persona)`.
  `last_acked_seq` tracks how far the follower has acknowledged (drives clearing
  of the `pubsub_available` notification pointer); `last_viewed_seq` tracks how
  far they have viewed.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "npl_pubsub_follows" do
    field :channel_id, :binary_id
    field :persona, :string
    field :last_acked_seq, :integer, default: 0
    field :last_viewed_seq, :integer, default: 0

    timestamps(type: :utc_datetime)
  end

  def changeset(follow, attrs) do
    follow
    |> cast(attrs, [:channel_id, :persona, :last_acked_seq, :last_viewed_seq])
    |> validate_required([:channel_id, :persona])
    |> unique_constraint([:channel_id, :persona], name: :idx_pubsub_follows_channel_persona)
    |> foreign_key_constraint(:channel_id)
  end
end
