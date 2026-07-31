defmodule NoizuPromptLingua.Domains.Chat.Tools.DM do
  use Noizu.MCP.Server.Tool,
    name: "Chat.DM",
    description:
      "Open (or reuse) a direct-message room between 2+ personas and optionally post to it.",
    hidden: true,
    category: "Chat"

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
    field :members, {:array, :string}, required: true, description: "Persona slugs in the DM (2+)"
    field :project, :string, description: "Optional project slug or UUID to scope the DM to"
    field :content, :string, description: "Optional message to post to the DM"

    field :sender, :string,
      description: "Persona slug posting the message (required if content given)"
  end

  alias NoizuPromptLingua.Domains.Chat
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    org_ref = Args.get(args, :organization)
    project_ref = Args.get(args, :project)
    members = Args.get(args, :members) || []
    content = Args.get(args, :content)
    sender = Args.get(args, :sender)

    with {:org, org_id} when not is_nil(org_id) <- {:org, Resolve.organization_id(org_ref)},
         {:ok, project_id} <- Resolve.project_in_org(project_ref, org_id),
         {:members, true} <- {:members, length(members) >= 2},
         {:ok, room} <- Chat.create_dm(org_id, project_id, members) do
      posted =
        if content && sender do
          case Chat.send_message(%{room_id: room.id, content: content, sender: sender}) do
            {:ok, msg} -> %{message_id: msg.id}
            _ -> %{message_id: nil}
          end
        else
          %{}
        end

      {:ok,
       Map.merge(%{room_id: room.id, name: room.name, kind: room.kind, members: members}, posted)}
    else
      {:org, nil} ->
        {:error, "Organization '#{org_ref}' not found"}

      {:members, false} ->
        {:error, "A DM requires at least 2 members"}

      {:error, :project_not_found} ->
        {:error, "Project '#{project_ref}' not found"}

      {:error, :project_not_in_org} ->
        {:error, "Project '#{project_ref}' does not belong to this organization"}

      {:error, cs} ->
        {:error, "Failed: #{inspect(cs)}"}
    end
  end
end
