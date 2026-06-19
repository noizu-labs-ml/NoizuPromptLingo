defmodule NoizuPromptLingua.Domains.Sessions.Tools.SessionGet do
  use Noizu.MCP.Server.Tool,
    name: "Session.Get",
    description: "Fetch a single session by UUID with metadata.",
    hidden: true,
    category: "Sessions"

  input do
    field :session_id, :string, required: true, description: "Session UUID"
  end

  @impl true
  def call(args, _ctx) do
    session_id = args[:session_id] || args["session_id"]

    case NoizuPromptLingua.Domains.Sessions.get(session_id) do
      nil ->
        {:error, "Session '#{session_id}' not found"}

      session ->
        {:ok, %{
          id: session.id,
          title: session.title,
          description: session.description,
          status: session.status,
          project_id: session.project_id,
          created_at: session.inserted_at,
          updated_at: session.updated_at
        }}
    end
  end
end
