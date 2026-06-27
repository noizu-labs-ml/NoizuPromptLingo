defmodule NoizuPromptLingua.Schema.Notification do
  @moduledoc """
  A single notification addressed to one concrete recipient (persona handle).

  Replaces the agent pipe entry. Carries a monotonic `seq` (from
  `npl_notifications_seq`, DB default on insert, bumped on dedup upsert) used as
  the Monitor's opaque polling cursor. `seen`/`read`/`acked` track lifecycle;
  `deliver_after` hides scheduled/digest/follow-up rows until due; `dedup_key`
  coalesces repeating items (channel digest, pubsub availability) into one
  still-unread row.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @kinds ~w(dm mention chat_digest reaction comment ticket_assigned ticket_update
            watch_update presence follow_up ping pong share pubsub_available)

  # Kinds whose body is a human-facing short DM and is hard-capped at 128 chars.
  @short_kinds ~w(dm ping pong)

  schema "npl_notifications" do
    field :organization_id, :binary_id
    field :project_id, :binary_id
    field :recipient, :string
    field :sender, :string
    field :kind, :string
    field :subject_type, :string
    field :subject_id, :string
    field :body, :string
    field :payload, :map, default: %{}
    # Opaque ordering cursor; never cast from user input.
    field :seq, :integer, read_after_writes: true
    field :seen, :boolean, default: false
    field :seen_at, :utc_datetime
    field :read, :boolean, default: false
    field :read_at, :utc_datetime
    field :acked, :boolean, default: false
    field :acked_at, :utc_datetime
    field :deliver_after, :utc_datetime
    field :dedup_key, :string

    timestamps(type: :utc_datetime)
  end

  def kinds, do: @kinds
  def short_kinds, do: @short_kinds

  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [
      :organization_id,
      :project_id,
      :recipient,
      :sender,
      :kind,
      :subject_type,
      :subject_id,
      :body,
      :payload,
      :seen,
      :seen_at,
      :read,
      :read_at,
      :acked,
      :acked_at,
      :deliver_after,
      :dedup_key
    ])
    |> validate_required([:organization_id, :recipient, :kind])
    |> validate_inclusion(:kind, @kinds)
    |> validate_body_length()
    |> foreign_key_constraint(:organization_id)
  end

  defp validate_body_length(changeset) do
    if get_field(changeset, :kind) in @short_kinds do
      validate_length(changeset, :body, max: 128)
    else
      changeset
    end
  end
end
