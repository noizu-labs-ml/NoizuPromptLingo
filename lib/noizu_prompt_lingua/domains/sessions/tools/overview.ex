defmodule NoizuPromptLingua.Domains.Sessions.Tools.Overview do
  use Noizu.MCP.Server.Tool,
    name: "Session.Overview",
    description: "List session tools and active session count.",
    annotations: [read_only_hint: true],
    category: "Sessions"

  input do
  end

  @impl true
  def call(_args, _ctx) do
    active_count = NoizuPromptLingua.Domains.Sessions.count_active()

    {:ok, %{
      domain: "Sessions",
      subdomain: "sessions.tobor.locker",
      active_sessions: active_count,
      tools: [
        %{name: "Session.Create", description: "Create a work session to group rooms, artifacts, tickets"},
        %{name: "Session.Update", description: "Update session title, status, or description"},
        %{name: "Session.Get", description: "Fetch a session by UUID"},
        %{name: "Session.List", description: "List sessions filtered by status"},
        %{name: "Session.Contents", description: "Get aggregated contents (linked rooms, artifacts, tickets)"},
        %{name: "Session.Archive", description: "Archive a session"},
        %{name: "Session.Activity", description: "Activity feed for a session"}
      ]
    }}
  end
end
