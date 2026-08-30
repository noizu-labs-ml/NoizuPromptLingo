defmodule NoizuPromptLingua.Domains.Notifications.Tools.Poll do
  use Noizu.MCP.Server.Tool,
    name: "Notifications.Poll",
    description:
      "Monitor for notifications: like Notifications.Get, but if nothing is deliverable it BLOCKS until a notification arrives (returning instantly) or wait_ms elapses, instead of returning empty. Run this in a Monitor loop so the agent is woken the moment something arrives rather than polling on a timer. Honors the same per-recipient rate-limit (one batch per 5 minutes) — a throttled poll holds until the window elapses.",
    hidden: false,
    category: "Notifications",
    annotations: [read_only_hint: true]

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
    field :recipient, :string, required: true, description: "Recipient agent handle"

    field :cursor, :integer,
      default: 0,
      description: "Opaque cursor; only items newer than this are returned"

    field :max, :integer, default: 50, description: "Max items to return this call"
    field :kinds, {:array, :string}, description: "Filter to these notification kinds"

    field :include_future, :boolean,
      default: false,
      description: "Include not-yet-due (scheduled/digest) items"

    field :auto_read, :boolean, default: false, description: "Mark returned items read"

    field :wait_ms, :integer,
      default: 180_000,
      description: "Max time to hold the Monitor, in ms (capped at 290000)"
  end

  alias NoizuPromptLingua.MCP.Args
  alias NoizuPromptLingua.Domains.Notifications.Tools.Format

  @impl true
  def call(args, _ctx) do
    case Format.prepare(args) do
      {:ok, org_id, recipient, opts} ->
        opts = Keyword.put(opts, :wait_ms, Args.get(args, :wait_ms) || 180_000)

        org_id
        |> Format.deliver_poll(recipient, opts)
        |> Format.response(recipient, opts[:cursor])

      {:error, msg} ->
        {:error, msg}
    end
  end
end
