defmodule NoizuPromptLingua.Domains.Pipes.Tools.Input do
  use Noizu.MCP.Server.Tool,
    name: "Pipe.Input",
    description:
      "Pull messages addressed to an agent handle within an organization, including direct, group-targeted, broadcast, and bridged chat traffic. Cursor-based: pass the `next_cursor` returned by the previous call (start at 0) to receive only newer entries; returns an updated `next_cursor`. Optionally filter by groups, specific message names, and addressing scope. Each returned message carries a `scope` (`direct`/`group`/`broadcast`) so direct messages can be distinguished from group/broadcast noise; pass `scope` to fetch only one kind.",
    hidden: true,
    category: "Pipes",
    annotations: [read_only_hint: true]

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
    field :agent, :string, required: true, description: "Agent handle to receive messages for"
    field :cursor, :integer,
      default: 0,
      description:
        "Opaque cursor; only entries newer than this are returned. Pass the prior call's next_cursor (start at 0)."

    field :groups, {:array, :string}, description: "Group names this agent belongs to"
    field :since, :string, description: "Only messages updated at/after this ISO-8601 timestamp (legacy)"
    field :message_names, {:array, :string}, description: "Filter to these message names"

    field :include_broadcast, :boolean,
      default: true,
      description: "Include broadcast messages (no specific target). Ignored unless scope is 'all'."

    field :scope, :string,
      default: "all",
      description:
        "Addressing scope: 'all' (default — direct + group + broadcast union), 'direct' (only messages addressed to this agent), 'group' (only this agent's group traffic), or 'broadcast' (only untargeted messages). Use 'direct' to isolate DMs from group/broadcast noise."
  end

  alias NoizuPromptLingua.Domains.Pipes
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    org_ref = Args.get(args, :organization)

    cursor = Args.get(args, :cursor) || 0

    with {:org, org_id} when not is_nil(org_id) <- {:org, Resolve.organization_id(org_ref)},
         {:ok, since} <- parse_since(Args.get(args, :since)) do
      opts = [
        cursor: cursor,
        groups: Args.get(args, :groups) || [],
        since: since,
        message_names: Args.get(args, :message_names),
        include_broadcast: Args.get(args, :include_broadcast) != false,
        scope: Args.get(args, :scope)
      ]

      entries = Pipes.pull(org_id, Args.get(args, :agent), opts)

      messages =
        Enum.map(entries, fn e ->
          %{
            seq: e.seq,
            sender: e.sender_handle,
            message_name: e.message_name,
            target_agent: blank_to_nil(e.target_agent_handle),
            target_group: blank_to_nil(e.target_group),
            scope: Pipes.scope_of(e),
            data: e.body,
            updated_at: e.updated_at
          }
        end)

      # Entries come back seq ASC; the last one is the new high-water mark.
      # Echo the input cursor when nothing newer arrived.
      next_cursor =
        case entries do
          [] -> cursor
          _ -> List.last(entries).seq
        end

      {:ok,
       %{
         agent: Args.get(args, :agent),
         count: length(messages),
         next_cursor: next_cursor,
         messages: messages
       }}
    else
      {:org, nil} -> {:error, "Organization '#{org_ref}' not found"}
      {:error, :bad_since} -> {:error, "Invalid 'since' timestamp; expected ISO-8601"}
    end
  end

  defp parse_since(nil), do: {:ok, nil}

  defp parse_since(str) do
    case DateTime.from_iso8601(str) do
      {:ok, dt, _offset} -> {:ok, dt}
      _ -> {:error, :bad_since}
    end
  end

  defp blank_to_nil(""), do: nil
  defp blank_to_nil(v), do: v
end
