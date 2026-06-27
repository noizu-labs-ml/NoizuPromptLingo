defmodule NoizuPromptLingua.Schema.ChatMessage do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "chat_messages" do
    belongs_to :room, NoizuPromptLingua.Schema.ChatRoom
    field :content, :string
    field :sender, :string
    # Threaded replies (ffa2d2f6): nil = top-level; set = a reply to another message
    # in the same room. Nullable self-FK (054), ON DELETE CASCADE.
    field :parent_message_id, :binary_id
    # Pins/highlights (068): highlighted surfaces `important: true` in the payload.
    field :pinned, :boolean, default: false
    field :highlighted, :boolean, default: false
    # Scheduled send (068): future rows are hidden from list_messages until due.
    field :scheduled_for, :utc_datetime

    # Microsecond precision (the column is already timestamptz(6)): `:utc_datetime`
    # truncates writes to whole seconds, making same-second messages tie under the
    # inserted_at ordering in `list_messages/2` — non-deterministic list order AND
    # ambiguous pagination cursors (Sofia G2). usec restores send-order determinism.
    timestamps(type: :utc_datetime_usec)
  end

  # Max content length — a guard against unbounded payloads (Sofia G2: max-length cap).
  @content_max 10_000

  def changeset(msg, attrs) do
    msg
    |> cast(attrs, [:room_id, :content, :sender, :parent_message_id, :pinned, :highlighted, :scheduled_for])
    |> validate_required([:room_id, :content, :sender])
    |> validate_length(:content, max: @content_max)
    |> validate_not_blank(:content)
    |> foreign_key_constraint(:room_id)
    |> foreign_key_constraint(:parent_message_id)
  end

  # `validate_required` only rejects nil/"". A whitespace-only body ("   ", "\n")
  # passes it but is still empty to a reader (Sofia G2: empty/whitespace-only reject).
  # We reject it without mutating the stored content, so legitimate leading/trailing
  # whitespace inside real messages (e.g. code blocks) is preserved.
  defp validate_not_blank(changeset, field) do
    validate_change(changeset, field, fn ^field, value ->
      if String.trim(to_string(value)) == "", do: [{field, "can't be blank"}], else: []
    end)
  end
end
