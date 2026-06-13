defmodule Codefresh.Webhooks.WebhookDelivery do
  @moduledoc """
  Audit row for one outbound webhook POST attempt (US-095).

  A delivery is inserted in the `pending` state (nil `sent_at`, nil
  `http_status`) when a webhook is enqueued. The `Codefresh.Webhooks.Worker`
  Oban job updates it with the upstream response — or schedules `next_retry_at`
  on non-2xx / transport error (US-146).

  Exponential backoff schedule (seconds since insert): 10, 60, 300, 1800, 7200.
  After `@max_retries` failures the row is parked with `sent_at` left nil and
  `next_retry_at` cleared (dead-letter state).
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @max_retries 5
  @backoff_schedule_seconds [10, 60, 300, 1_800, 7_200]

  schema "webhook_deliveries" do
    field :event_type, :string
    field :event_payload, :map, default: %{}
    field :http_status, :integer
    field :error_message, :string
    field :retry_count, :integer, default: 0
    field :next_retry_at, :utc_datetime
    field :sent_at, :utc_datetime
    field :inserted_at, :utc_datetime

    belongs_to :webhook, Codefresh.Webhooks.Webhook
    belongs_to :organization, Codefresh.Organizations.Organization
  end

  def max_retries, do: @max_retries
  def backoff_schedule_seconds, do: @backoff_schedule_seconds

  def create_changeset(delivery, attrs) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    delivery
    |> cast(attrs, [
      :webhook_id,
      :organization_id,
      :event_type,
      :event_payload,
      :http_status,
      :error_message,
      :retry_count,
      :next_retry_at,
      :sent_at,
      :inserted_at
    ])
    |> put_change_if_missing(:inserted_at, now)
    |> validate_required([:webhook_id, :organization_id, :event_type, :inserted_at])
    |> foreign_key_constraint(:webhook_id)
    |> foreign_key_constraint(:organization_id)
  end

  @doc "Mark this delivery successfully sent (US-146)."
  def success_changeset(delivery, http_status) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    delivery
    |> change(http_status: http_status, sent_at: now, next_retry_at: nil, error_message: nil)
  end

  @doc """
  Record a failed attempt. Picks the next backoff from the schedule — when
  retries are exhausted we clear `next_retry_at` so it drops out of the retry
  query (dead-letter).
  """
  def failure_changeset(delivery, http_status, error_message) do
    next_count = (delivery.retry_count || 0) + 1

    next_retry_at =
      case Enum.at(@backoff_schedule_seconds, next_count - 1) do
        nil ->
          nil

        seconds ->
          DateTime.utc_now() |> DateTime.add(seconds, :second) |> DateTime.truncate(:second)
      end

    delivery
    |> change(
      http_status: http_status,
      error_message: truncate_error(error_message),
      retry_count: next_count,
      next_retry_at: next_retry_at
    )
  end

  @doc "Predicate: are retries exhausted?"
  def dead_lettered?(%__MODULE__{retry_count: r, sent_at: nil}) when r >= @max_retries, do: true
  def dead_lettered?(%__MODULE__{}), do: false

  defp put_change_if_missing(changeset, field, value) do
    case get_field(changeset, field) do
      nil -> put_change(changeset, field, value)
      _ -> changeset
    end
  end

  defp truncate_error(nil), do: nil
  defp truncate_error(s) when is_binary(s) and byte_size(s) <= 2_000, do: s
  defp truncate_error(s) when is_binary(s), do: binary_part(s, 0, 2_000)
  defp truncate_error(other), do: inspect(other) |> truncate_error()
end
