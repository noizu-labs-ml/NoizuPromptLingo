defmodule NoizuPromptLingua.Domains.Sessions.Tools.SessionActivity do
  use Noizu.MCP.Server.Tool,
    name: "Session.Activity",
    description: "Get the activity feed for a session — a chronological list of events across all linked items.",
    hidden: true,
    category: "Sessions"

  input do
    field :session_id, :string, required: true, description: "Session UUID"
    field :limit, :integer, description: "Max events to return (default 50)"
    field :since, :string, description: "ISO8601 timestamp — return events after this time"
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
          events: [],
          hint: "Activity feed not yet implemented — events will appear here as items are linked and modified."
        }}
    end
  end
end
