defmodule CodefreshWeb.WebhookController do
  use CodefreshWeb, :controller

  alias Codefresh.{Organizations, Webhooks}
  alias Codefresh.Guardian

  # ──────────────────────────────────────────────────────────────────────────
  # US-144 — Webhook CRUD
  # ──────────────────────────────────────────────────────────────────────────

  def index(conn, %{"organization_id" => org_id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "admin") do
      hooks = Webhooks.list_webhooks(org_id)
      json(conn, %{webhooks: Enum.map(hooks, &render_webhook/1)})
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def create(conn, %{"organization_id" => org_id, "webhook" => params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "admin") do
      attrs =
        params
        |> Map.put("organization_id", org_id)
        |> Map.put("created_by_user_id", user.id)

      case Webhooks.create_webhook(attrs) do
        {:ok, webhook} ->
          conn
          |> put_status(:created)
          |> json(%{
            webhook: render_webhook(webhook),
            secret: webhook.secret,
            note: "secret shown once — store immediately; rotate by deleting + recreating"
          })

        {:error, cs} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: CodefreshWeb.ChangesetJSON.errors(cs)})
      end
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Expected {webhook: {name, endpoint_url, event_filters?, active?}}"})
  end

  def update(conn, %{"organization_id" => org_id, "id" => id, "webhook" => params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "admin"),
         webhook when not is_nil(webhook) <- Webhooks.get_org_webhook(org_id, id) do
      case Webhooks.update_webhook(webhook, params) do
        {:ok, updated} ->
          json(conn, %{webhook: render_webhook(updated)})

        {:error, cs} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: CodefreshWeb.ChangesetJSON.errors(cs)})
      end
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def delete(conn, %{"organization_id" => org_id, "id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "admin"),
         webhook when not is_nil(webhook) <- Webhooks.get_org_webhook(org_id, id) do
      case Webhooks.delete_webhook(webhook) do
        {:ok, _} -> send_resp(conn, 204, "")
        {:error, _} -> send_resp(conn, 422, "")
      end
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-095 — Delivery audit log
  # ──────────────────────────────────────────────────────────────────────────

  def deliveries(conn, %{"organization_id" => org_id} = params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "admin") do
      opts =
        []
        |> maybe_put(:webhook_id, params["webhook_id"])
        |> maybe_put(:limit, parse_limit(params["limit"]))

      deliveries = Webhooks.list_deliveries(org_id, opts)
      json(conn, %{deliveries: Enum.map(deliveries, &render_delivery/1)})
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-095 — Retry delivery
  # ──────────────────────────────────────────────────────────────────────────

  def retry_delivery(conn, %{"webhook_id" => wh_id, "delivery_id" => del_id}) do
    org = conn.assigns.organization
    with {:ok, delivery} <- Webhooks.retry_delivery(org.id, wh_id, del_id) do
      json(conn, %{delivery: render_delivery(delivery)})
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Rendering
  # ──────────────────────────────────────────────────────────────────────────

  defp render_webhook(w) do
    %{
      id: w.id,
      name: w.name,
      url: w.endpoint_url,
      events: w.event_filters,
      enabled: w.active,
      created_at: w.inserted_at,
      updated_at: w.updated_at
    }
  end

  defp render_delivery(d) do
    %{
      id: d.id,
      webhook_id: d.webhook_id,
      event: d.event_type,
      response_status: d.http_status,
      retry_count: d.retry_count,
      next_retry_at: d.next_retry_at,
      attempted_at: d.sent_at,
      error_message: d.error_message,
      inserted_at: d.inserted_at,
      status: cond do
        d.http_status != nil and d.http_status < 400 -> "delivered"
        d.next_retry_at == nil and d.retry_count > 0 -> "dead"
        true -> "failed"
      end
    }
  end

  defp maybe_put(opts, _k, nil), do: opts
  defp maybe_put(opts, k, v), do: Keyword.put(opts, k, v)

  defp parse_limit(nil), do: nil

  defp parse_limit(s) when is_binary(s) do
    case Integer.parse(s) do
      {n, ""} when n > 0 and n <= 1_000 -> n
      _ -> nil
    end
  end

  defp parse_limit(n) when is_integer(n) and n > 0 and n <= 1_000, do: n
  defp parse_limit(_), do: nil
end
