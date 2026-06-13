defmodule Codefresh.Webhooks do
  @moduledoc """
  Context for outbound webhook subscriptions.

  Scope:
    * US-144 — webhook CRUD (list / create / update / delete) with HMAC secret
    * US-145 — fire webhooks on run events (stub — logs "would POST …" via
      `Logger.info` and inserts a pending `webhook_deliveries` row; actual HTTP
      is still pending until Stage 11.5 wires `Req`)
    * US-146 — retry failed deliveries with exponential backoff; dead-letters
      after `WebhookDelivery.max_retries/0` attempts
    * US-095 — delivery audit is the `webhook_deliveries` table, queryable via
      `list_deliveries/2`

  ## OTel bridge note (US-094)

  The SDK-side OTel bridge helper described in US-094 is deliberately NOT
  surfaced here — it's an SDK concern (emitting spans for SDK HTTP calls). The
  backend only guarantees that `event_payload` includes `trace_id` /
  `span_id` when OpenTelemetry has an active context, so downstream consumers
  can correlate backend-emitted events with their own spans. See
  `build_payload/3` below.
  """

  require Logger
  import Ecto.Query, only: [from: 2]
  alias Ecto.Multi
  alias Codefresh.Repo
  alias Codefresh.Webhooks.{Webhook, WebhookDelivery}

  # ──────────────────────────────────────────────────────────────────────────
  # Webhook CRUD (US-144)
  # ──────────────────────────────────────────────────────────────────────────

  def list_webhooks(organization_id) do
    Repo.all(
      from w in Webhook,
        where: w.organization_id == ^organization_id,
        order_by: [desc: w.inserted_at]
    )
  end

  def get_webhook!(id), do: Repo.get!(Webhook, id)

  def get_org_webhook(organization_id, id) do
    case Repo.get(Webhook, id) do
      %Webhook{organization_id: ^organization_id} = w -> w
      _ -> nil
    end
  rescue
    Ecto.Query.CastError -> nil
  end

  @doc """
  Create a webhook. The secret is auto-generated when not supplied; callers
  should surface it to the user once (UI pattern identical to API tokens).
  """
  def create_webhook(attrs) when is_map(attrs) do
    %Webhook{}
    |> Webhook.create_changeset(attrs)
    |> Repo.insert()
  end

  def update_webhook(%Webhook{} = webhook, attrs) do
    webhook
    |> Webhook.update_changeset(attrs)
    |> Repo.update()
  end

  def delete_webhook(%Webhook{} = webhook), do: Repo.delete(webhook)

  # ──────────────────────────────────────────────────────────────────────────
  # Delivery query helpers (US-095)
  # ──────────────────────────────────────────────────────────────────────────

  def list_deliveries(organization_id, opts \\ []) do
    limit = Keyword.get(opts, :limit, 100)
    webhook_id = Keyword.get(opts, :webhook_id)

    q =
      from d in WebhookDelivery,
        where: d.organization_id == ^organization_id,
        order_by: [desc: d.inserted_at],
        limit: ^limit

    q =
      if webhook_id do
        from d in q, where: d.webhook_id == ^webhook_id
      else
        q
      end

    Repo.all(q)
  end

  def get_delivery!(id), do: Repo.get!(WebhookDelivery, id)

  # ──────────────────────────────────────────────────────────────────────────
  # Event dispatch (US-145) — called from Runs / Review / Freeball contexts
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Enqueue deliveries for `event_type` to every matching active webhook in the
  given org. Returns `{:ok, [delivery]}` — deliveries start in `pending`
  state (nil `sent_at`) and the Oban worker takes it from there.

  This is intentionally a no-op-safe fan-out: if no webhooks match the event
  filter, it returns `{:ok, []}` without raising or logging at warn level.
  """
  def fire_event(organization_id, event_type, payload_data)
      when is_binary(organization_id) and is_binary(event_type) and is_map(payload_data) do
    webhooks = list_active_matching(organization_id, event_type)

    deliveries =
      Enum.map(webhooks, fn webhook ->
        {:ok, delivery} = enqueue_delivery(webhook, event_type, payload_data)
        delivery
      end)

    {:ok, deliveries}
  end

  defp list_active_matching(organization_id, event_type) do
    Repo.all(
      from w in Webhook,
        where: w.organization_id == ^organization_id and w.active == true,
        where: fragment("? = ANY(?)", ^event_type, w.event_filters)
    )
  end

  defp enqueue_delivery(%Webhook{} = webhook, event_type, payload_data) do
    payload = build_payload(webhook, event_type, payload_data)

    Multi.new()
    |> Multi.insert(
      :delivery,
      WebhookDelivery.create_changeset(%WebhookDelivery{}, %{
        webhook_id: webhook.id,
        organization_id: webhook.organization_id,
        event_type: event_type,
        event_payload: payload
      })
    )
    |> Multi.run(:job, fn _repo, %{delivery: delivery} ->
      Codefresh.Webhooks.Worker.new(%{"delivery_id" => delivery.id})
      |> Oban.insert()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{delivery: d}} -> {:ok, d}
      {:error, _op, reason, _} -> {:error, reason}
    end
  end

  @doc """
  Construct the JSON-serializable envelope. OTel trace ids are attached when
  an active OTel context exists so downstream consumers can correlate events
  with the originating backend span (US-094).
  """
  def build_payload(%Webhook{} = webhook, event_type, data) do
    envelope = %{
      "event_type" => event_type,
      "webhook_id" => webhook.id,
      "organization_id" => webhook.organization_id,
      "emitted_at" => DateTime.utc_now() |> DateTime.to_iso8601(),
      "data" => data
    }

    case current_trace_context() do
      nil -> envelope
      ctx -> Map.put(envelope, "trace", ctx)
    end
  end

  # Safe read of the active OpenTelemetry span context. Returns nil when no
  # context is active or OTel isn't loaded (e.g. inside :test).
  defp current_trace_context do
    try do
      span_ctx = :otel_tracer.current_span_ctx()

      if span_ctx == :undefined do
        nil
      else
        {:span_ctx, trace_id, span_id, _, _, _, _, _, _, _, _} = span_ctx

        %{
          "trace_id" => trace_id |> Integer.to_string(16) |> String.downcase(),
          "span_id" => span_id |> Integer.to_string(16) |> String.downcase()
        }
      end
    rescue
      _ -> nil
    catch
      _, _ -> nil
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # HMAC signing — exposed so SDK helpers can mirror the algorithm (US-144)
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Compute the `X-Codefresh-Signature` header value for a given raw body and
  webhook secret. Format: `sha256=<hex>`.
  """
  def sign_payload(secret, body) when is_binary(secret) and is_binary(body) do
    mac = :crypto.mac(:hmac, :sha256, secret, body) |> Base.encode16(case: :lower)
    "sha256=" <> mac
  end
end

defmodule Codefresh.Webhooks.Worker do
  @moduledoc """
  Oban worker that delivers a single `webhook_deliveries` row.

  **Stage 11 note:** this is the stub implementation. We DO NOT perform real
  HTTP yet — we log the intended POST via `Logger.info` and mark the delivery
  as successfully sent with `http_status: 204`. This preserves the retry
  scaffolding (US-146) and the audit contract (US-095) while keeping the
  Stage-11 surface narrow. A follow-up swaps the log for `Req.post/2` without
  changing the caller contract.
  """

  use Oban.Worker, queue: :webhook, max_attempts: 6

  require Logger
  alias Codefresh.Repo
  alias Codefresh.Webhooks
  alias Codefresh.Webhooks.{Webhook, WebhookDelivery}

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"delivery_id" => delivery_id}}) do
    deliver(delivery_id)
  end

  @doc """
  Attempt delivery. Returns `{:ok, delivery}` | `{:error, reason, delivery}`.
  Safe to call directly from tests.
  """
  def deliver(delivery_id) when is_binary(delivery_id) do
    case Repo.get(WebhookDelivery, delivery_id) do
      nil ->
        {:error, :not_found}

      %WebhookDelivery{sent_at: %DateTime{}} = d ->
        # Idempotent — already delivered.
        {:ok, d}

      %WebhookDelivery{} = delivery ->
        webhook = Repo.get!(Webhook, delivery.webhook_id)
        attempt_post(delivery, webhook)
    end
  end

  defp attempt_post(%WebhookDelivery{} = delivery, %Webhook{active: false}) do
    # Webhook was disabled after enqueue — park the delivery without retrying.
    cs =
      WebhookDelivery.failure_changeset(delivery, 0, "webhook disabled before delivery")
      |> Ecto.Changeset.put_change(:retry_count, WebhookDelivery.max_retries())
      |> Ecto.Changeset.put_change(:next_retry_at, nil)

    {:ok, Repo.update!(cs)}
  end

  defp attempt_post(%WebhookDelivery{} = delivery, %Webhook{} = webhook) do
    body = Jason.encode!(delivery.event_payload)
    signature = Webhooks.sign_payload(webhook.secret, body)

    Logger.info(
      "[webhook] would POST #{webhook.endpoint_url} event=#{delivery.event_type} " <>
        "delivery_id=#{delivery.id} signature=#{signature} bytes=#{byte_size(body)}"
    )

    # Stage-11 stub: mark success immediately. When real HTTP lands, replace
    # this with `Req.post(url, headers: [...], body: body)` and branch on the
    # response status — 2xx → success_changeset, otherwise failure_changeset.
    updated =
      delivery
      |> WebhookDelivery.success_changeset(204)
      |> Repo.update!()

    {:ok, updated}
  end

  @doc """
  Enqueue retries for deliveries whose `next_retry_at` has elapsed. Called
  from a cron/periodic sweeper once Stage 11.5 wires Oban.Cron.
  """
  def sweep_retries(now \\ DateTime.utc_now()) do
    import Ecto.Query, only: [from: 2]

    overdue =
      Repo.all(
        from d in WebhookDelivery,
          where: is_nil(d.sent_at) and not is_nil(d.next_retry_at) and d.next_retry_at <= ^now,
          limit: 500
      )

    Enum.each(overdue, fn d ->
      __MODULE__.new(%{"delivery_id" => d.id}) |> Oban.insert()
    end)

    {:ok, length(overdue)}
  end
end
