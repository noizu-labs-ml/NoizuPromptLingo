defmodule NoizuPromptLingua.MCP.Sessions.Tools.SessionGet do
  use Noizu.MCP.Server.Tool,
    name: "Session.Get",
    description: "Get a session by UUID.",
    hidden: true,
    category: "Sessions",
    annotations: [read_only_hint: true]

  alias NoizuPromptLingua.MCP.Args

  input do
    field :session, :string, required: true, description: "Session UUID"
  end

  @impl true
  def call(args, _ctx) do
    id = Args.get(args, :session)

    case NoizuPromptLingua.Sessions.get_session(id) do
      nil ->
        {:error, "Session '#{id}' not found"}

      session ->
        {:ok,
         %{
           id: session.id,
           title: session.title,
           description: session.description,
           status: session.status,
           organization_id: session.organization_id,
           project_id: session.project_id,
           model: session.model,
           runner: session.runner,
           created_at: session.inserted_at
         }}
    end
  end
end
