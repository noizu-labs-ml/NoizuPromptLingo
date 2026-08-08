defmodule NoizuPromptLingua.Domains.Notifications.Tools.Format do
  @moduledoc "Shared serialization for notification rows returned by Get/Poll."

  alias NoizuPromptLingua.Domains.Notifications

  @doc """
  Format a `deliver` result (`{:ok, rows}` | `{:throttled, ms}`) into the tool
  response map. `recipient`/`cursor` echo the request for the Monitor loop.
  """
  def response({:throttled, ms}, recipient, cursor) do
    {:ok,
     %{
       recipient: recipient,
       throttled: true,
       retry_after_ms: ms,
       count: 0,
       next_cursor: cursor,
       notifications: []
     }}
  end

  def response({:ok, rows}, recipient, cursor) do
    notifications = Enum.map(rows, &row/1)
    next_cursor = if rows == [], do: cursor, else: List.last(rows).seq

    {:ok,
     %{
       recipient: recipient,
       throttled: false,
       count: length(notifications),
       next_cursor: next_cursor,
       notifications: notifications
     }}
  end

  defp row(n) do
    %{
      id: n.id,
      seq: n.seq,
      kind: n.kind,
      sender: n.sender,
      subject_type: n.subject_type,
      subject_id: n.subject_id,
      body: n.body,
      payload: n.payload,
      seen: n.seen,
      read: n.read,
      inserted_at: n.inserted_at
    }
  end

  @doc "Resolve org ref + load opts shared by Get/Poll. Returns {:ok, org_id, recipient, opts} | {:error, msg}."
  def prepare(args) do
    alias NoizuPromptLingua.MCP.{Args, Resolve}
    org_ref = Args.get(args, :organization)
    recipient = Args.get(args, :recipient)

    case Resolve.organization_id(org_ref) do
      nil ->
        {:error, "Organization '#{org_ref}' not found"}

      org_id ->
        opts = [
          cursor: Args.get(args, :cursor) || 0,
          max: Args.get(args, :max) || 50,
          kinds: Args.get(args, :kinds),
          include_future: Args.get(args, :include_future) == true,
          auto_read: Args.get(args, :auto_read) == true
        ]

        {:ok, org_id, recipient, opts}
    end
  end

  @doc "Public re-export so tools needn't alias the context directly."
  def deliver_get(org_id, recipient, opts), do: Notifications.get(org_id, recipient, opts)
  def deliver_poll(org_id, recipient, opts), do: Notifications.poll(org_id, recipient, opts)
end
