defmodule NoizuPromptLingua.Domains.Notifications.Tools.Get do
  use Noizu.MCP.Server.Tool,
    name: "Notifications.Get",
    description:
      "Immediate cursor pull of new notifications for a recipient. Pass the prior call's next_cursor (start at 0) to receive only newer items; returns an updated next_cursor. `max` caps items per call; `auto_read` marks returned items read. A per-recipient rate-limit delivers at most one non-empty batch per 5 minutes — while throttled the response is empty with throttled:true and retry_after_ms set.",
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
  end

  alias NoizuPromptLingua.Domains.Notifications.Tools.Format

  @impl true
  def call(args, _ctx) do
    case Format.prepare(args) do
      {:ok, org_id, recipient, opts} ->
        org_id
        |> Format.deliver_get(recipient, opts)
        |> Format.response(recipient, opts[:cursor])

      {:error, msg} ->
        {:error, msg}
    end
  end
end
