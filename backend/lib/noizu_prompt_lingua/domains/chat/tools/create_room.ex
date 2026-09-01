defmodule NoizuPromptLingua.Domains.Chat.Tools.CreateRoom do
  use Noizu.MCP.Server.Tool,
    name: "Chat.CreateRoom",
    description: "Create a new chat room.",
    hidden: false,
    category: "Chat"

  input do
    field :organization, :string,
      required: true,
      description: "Organization slug or UUID (required)"

    field :name, :string, required: true, description: "Room name"
    field :description, :string, description: "Room description/topic"
    field :project, :string, description: "Optional project slug or UUID to scope this room to"
    field :session_id, :string, description: "Session UUID to associate with"
  end

  alias NoizuPromptLingua.Domains.Chat
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    org_ref = Args.get(args, :organization)
    project_ref = Args.get(args, :project)

    with {:org, org_id} when not is_nil(org_id) <- {:org, Resolve.organization_id(org_ref)},
         {:ok, project_id} <- Resolve.project_in_org(project_ref, org_id) do
      attrs = %{
        organization_id: org_id,
        project_id: project_id,
        name: Args.get(args, :name),
        description: Args.get(args, :description),
        session_id: Args.get(args, :session_id)
      }

      case Chat.create_room(attrs) do
        {:ok, room} ->
          {:ok,
           %{
             id: room.id,
             name: room.name,
             slug: room.slug,
             chatroom_url: NoizuPromptLingua.MCP.Urls.chat_room_url(room),
             organization_id: room.organization_id,
             project_id: room.project_id,
             created_at: room.inserted_at
           }}

        {:error, cs} ->
          {:error, "Failed: #{inspect(cs.errors)}"}
      end
    else
      {:org, nil} ->
        {:error, "Organization '#{org_ref}' not found"}

      {:error, :project_not_found} ->
        {:error, "Project '#{project_ref}' not found"}

      {:error, :project_not_in_org} ->
        {:error, "Project '#{project_ref}' does not belong to this organization"}
    end
  end
end
