defmodule NoizuPromptLingua.Domains.Pipes.Tools.Input do
  use Noizu.MCP.Server.Tool,
    name: "Pipe.Input",
    description:
      "Pull messages addressed to an agent handle within an organization. Returns the latest payload per (sender, message_name), including group-targeted and broadcast messages. Optionally filter by groups, a since timestamp (ISO-8601), and specific message names.",
    hidden: true,
    category: "Pipes",
    annotations: [read_only_hint: true]

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
    field :agent, :string, required: true, description: "Agent handle to receive messages for"
    field :groups, {:array, :string}, description: "Group names this agent belongs to"
    field :since, :string, description: "Only messages updated at/after this ISO-8601 timestamp"
    field :message_names, {:array, :string}, description: "Filter to these message names"

    field :include_broadcast, :boolean,
      default: true,
      description: "Include broadcast messages (no specific target)"
  end

  alias NoizuPromptLingua.Domains.Pipes
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    org_ref = Args.get(args, :organization)

    with {:org, org_id} when not is_nil(org_id) <- {:org, Resolve.organization_id(org_ref)},
         {:ok, since} <- parse_since(Args.get(args, :since)) do
      opts = [
        groups: Args.get(args, :groups) || [],
        since: since,
        message_names: Args.get(args, :message_names),
        include_broadcast: Args.get(args, :include_broadcast) != false
      ]

      messages =
        Pipes.pull(org_id, Args.get(args, :agent), opts)
        |> Enum.map(fn e ->
          %{
            sender: e.sender_handle,
            message_name: e.message_name,
            target_agent: blank_to_nil(e.target_agent_handle),
            target_group: blank_to_nil(e.target_group),
            data: e.body,
            updated_at: e.updated_at
          }
        end)

      {:ok, %{agent: Args.get(args, :agent), count: length(messages), messages: messages}}
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
