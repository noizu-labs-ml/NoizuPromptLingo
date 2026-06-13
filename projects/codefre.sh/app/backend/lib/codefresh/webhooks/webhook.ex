defmodule Codefresh.Webhooks.Webhook do
  @moduledoc """
  Outbound webhook subscription owned by an organization (US-144).

  A webhook binds an `endpoint_url` to a list of `event_filters` (e.g.
  `"run.completed"`, `"freeball.promoted"`, `"review_item.created"`). Deliveries
  are HMAC-signed using `secret` and written to `webhook_deliveries` for audit
  (US-095).
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  # Canonical list of event types webhook subscriptions may filter on. Extend
  # cautiously — subscribers depend on these string keys. Additions are safe,
  # renames are a breaking change for existing subscribers.
  @known_events ~w(
    run.created
    run.started
    run.completed
    run.errored
    run.cancelled
    freeball.created
    freeball.promoted
    review_item.created
    review_item.resolved
  )

  @secret_bytes 32

  schema "webhooks" do
    field :name, :string
    field :endpoint_url, :string
    field :secret, :binary, redact: true
    field :event_filters, {:array, :string}, default: []
    field :active, :boolean, default: true

    belongs_to :organization, Codefresh.Organizations.Organization
    belongs_to :created_by, Codefresh.Accounts.User, foreign_key: :created_by_user_id

    has_many :deliveries, Codefresh.Webhooks.WebhookDelivery

    timestamps(type: :utc_datetime)
  end

  @doc "Known event type strings accepted by `event_filters`."
  def known_events, do: @known_events

  @doc """
  Generate a URL-safe, 32-byte random secret suitable for HMAC-SHA256 signing.
  Returned from `create_changeset/2` when the caller doesn't supply one.
  """
  def generate_secret do
    :crypto.strong_rand_bytes(@secret_bytes) |> Base.url_encode64(padding: false)
  end

  def create_changeset(webhook, attrs) do
    attrs = maybe_put_secret(attrs)

    webhook
    |> cast(attrs, [
      :organization_id,
      :name,
      :endpoint_url,
      :secret,
      :event_filters,
      :active,
      :created_by_user_id
    ])
    |> validate_required([:organization_id, :name, :endpoint_url, :secret])
    |> validate_length(:name, min: 1, max: 120)
    |> validate_length(:endpoint_url, max: 2_000)
    |> validate_endpoint_url()
    |> validate_event_filters()
    |> foreign_key_constraint(:organization_id)
  end

  def update_changeset(webhook, attrs) do
    webhook
    |> cast(attrs, [:name, :endpoint_url, :event_filters, :active])
    |> validate_length(:name, min: 1, max: 120)
    |> validate_length(:endpoint_url, max: 2_000)
    |> validate_endpoint_url()
    |> validate_event_filters()
  end

  defp maybe_put_secret(attrs) when is_map(attrs) do
    has_secret? =
      Map.has_key?(attrs, :secret) or Map.has_key?(attrs, "secret")

    if has_secret? do
      attrs
    else
      # Always store strings to keep the column content deterministic across
      # string-keyed / atom-keyed call sites.
      if Map.has_key?(attrs, :organization_id) or Map.has_key?(attrs, :name) do
        Map.put(attrs, :secret, generate_secret())
      else
        Map.put(attrs, "secret", generate_secret())
      end
    end
  end

  defp maybe_put_secret(attrs), do: attrs

  defp validate_endpoint_url(changeset) do
    validate_change(changeset, :endpoint_url, fn :endpoint_url, url ->
      case URI.parse(url) do
        %URI{scheme: s, host: h} when s in ["http", "https"] and is_binary(h) and h != "" ->
          []

        _ ->
          [endpoint_url: "must be a valid http(s) URL"]
      end
    end)
  end

  defp validate_event_filters(changeset) do
    validate_change(changeset, :event_filters, fn :event_filters, filters ->
      unknown = Enum.reject(filters || [], &(&1 in @known_events))

      if unknown == [] do
        []
      else
        [event_filters: "unknown event type(s): #{Enum.join(unknown, ", ")}"]
      end
    end)
  end
end
