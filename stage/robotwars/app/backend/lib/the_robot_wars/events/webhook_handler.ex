defmodule TheRobotWars.Events.WebhookHandler do
  use GenServer
  require Logger

  alias TheRobotWars.Schema.Events.Webhook, as: WebhookSchema
  import Ecto.Query

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    TheRobotWars.Events.subscribe()
    {:ok, state}
  end

  @impl true
  def handle_info({event_type, payload}, state) do
    event_name = Atom.to_string(event_type)
    org_id = Map.get(payload, :org_id)

    webhooks = list_matching_webhooks(event_name, org_id)

    Enum.each(webhooks, fn webhook ->
      Task.start(fn -> deliver(webhook, event_type, payload) end)
    end)

    {:noreply, state}
  end

  defp list_matching_webhooks(event_name, org_id) do
    query =
      from w in WebhookSchema,
        where: w.active == true,
        where: ^event_name in w.events or "all" in w.events

    query =
      if org_id do
        from w in query, where: w.organization_id == ^org_id or is_nil(w.organization_id)
      else
        from w in query, where: is_nil(w.organization_id)
      end

    TheRobotWars.Repo.all(query)
  rescue
    _ -> []
  end

  defp deliver(webhook, event_type, payload) do
    body = Jason.encode!(%{
      event: event_type,
      payload: payload,
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    })

    signature = :crypto.mac(:hmac, :sha256, webhook.secret || "", body) |> Base.encode16(case: :lower)

    headers = [
      {"content-type", "application/json"},
      {"x-webhook-signature", signature}
    ]

    case Req.post(webhook.url, body: body, headers: headers, receive_timeout: 10_000) do
      {:ok, %{status: status}} when status in 200..299 ->
        Logger.info("Webhook delivered to #{webhook.url}: #{status}")

      {:ok, %{status: status}} ->
        Logger.warning("Webhook failed for #{webhook.url}: #{status}")

      {:error, reason} ->
        Logger.warning("Webhook error for #{webhook.url}: #{inspect(reason)}")
    end
  end
end
