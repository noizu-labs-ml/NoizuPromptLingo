defmodule NoizuPromptLingua.Domains.Pipes.Tools.Output do
  use Noizu.MCP.Server.Tool,
    name: "Pipe.Output",
    description:
      "Publish a payload under a message name to a target. Provide target_agent (a handle) and/or target_group; leave both blank to broadcast. Re-publishing the same (sender, message_name, target) replaces the previous payload (upsert).",
    hidden: true,
    category: "Pipes",
    annotations: [idempotent_hint: true]

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
    field :sender, :string, required: true, description: "Sender agent handle"
    field :message_name, :string, required: true, description: "Message name (key)"
    field :data, :string, required: true, description: "Payload body (YAML or JSON text)"
    field :target_agent, :string, description: "Target agent handle (optional)"
    field :target_group, :string, description: "Target group name (optional)"
  end

  alias NoizuPromptLingua.Domains.Pipes
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    org_ref = Args.get(args, :organization)

    case Resolve.organization_id(org_ref) do
      nil ->
        {:error, "Organization '#{org_ref}' not found"}

      org_id ->
        attrs = %{
          organization_id: org_id,
          sender_handle: Args.get(args, :sender),
          message_name: Args.get(args, :message_name),
          body: Args.get(args, :data),
          target_agent_handle: Args.get(args, :target_agent) || "",
          target_group: Args.get(args, :target_group) || ""
        }

        case Pipes.push(attrs) do
          {:ok, entry} ->
            {:ok, %{
              id: entry.id,
              sender: entry.sender_handle,
              message_name: entry.message_name,
              target_agent: blank_to_nil(entry.target_agent_handle),
              target_group: blank_to_nil(entry.target_group),
              updated_at: entry.updated_at
            }}

          {:error, changeset} ->
            {:error, "Failed: #{inspect(changeset.errors)}"}
        end
    end
  end

  defp blank_to_nil(""), do: nil
  defp blank_to_nil(v), do: v
end
