defmodule NoizuPromptLingua.Domains.Sessions.Tools.SessionContents do
  use Noizu.MCP.Server.Tool,
    name: "Session.Contents",
    description: "Get all items linked to a session: chat rooms, artifacts, and tickets.",
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

      _session ->
        {:ok, %{
          session_id: session_id,
          rooms: [],
          artifacts: [],
          tickets: [],
          hint: "Content linking not yet implemented — rooms, artifacts, and tickets will appear here when linked."
        }}
    end
  end
end
