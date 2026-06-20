defmodule NoizuPromptLingua.Domains.Chat.Tools.ListRooms do
  use Noizu.MCP.Server.Tool,
    name: "Chat.ListRooms", description: "List chat rooms.", hidden: true, category: "Chat",
    annotations: [read_only_hint: true]

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID (required)"
    field :project, :string, description: "Filter by project slug or UUID"
    field :session_id, :string, description: "Filter by session UUID"
    field :limit, :integer, description: "Max results (default 50)"
    field :offset, :integer, description: "Pagination offset"
  end

  alias NoizuPromptLingua.Domains.Chat
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    org_ref = Args.get(args, :organization)

    case Resolve.organization_id(org_ref) do
      nil ->
        {:error, "Organization '#{org_ref}' not found"}

      org_id ->
        project = Resolve.project(Args.get(args, :project))

        opts =
          [organization_id: org_id, project_id: project && project.id]
          |> Enum.reject(fn {_k, v} -> is_nil(v) end)
          |> Keyword.merge(
            Enum.reduce([:session_id, :limit, :offset], [], fn k, acc ->
              val = args[k] || args[Atom.to_string(k)]
              if val, do: [{k, val} | acc], else: acc
            end)
          )

        rooms = Chat.list_rooms(opts)
        {:ok, %{rooms: Enum.map(rooms, &%{id: &1.id, name: &1.name, created_at: &1.inserted_at}), count: length(rooms)}}
    end
  end
end
