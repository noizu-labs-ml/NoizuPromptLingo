defmodule NoizuPromptLingua.MCP.Sessions.Tools.Overview do
  use Noizu.MCP.Server.Tool,
    name: "Session.Overview",
    description: "List session tools and active session count.",
    annotations: [read_only_hint: true],
    category: "Sessions"

  import Ecto.Query

  input do
  end

  @impl true
  def call(_args, _ctx) do
    active =
      NoizuPromptLingua.Repo.aggregate(
        from(s in NoizuPromptLingua.Schema.Sessions.Session, where: s.status == "active"),
        :count
      )

    {:ok,
     %{
       domain: "Sessions",
       active_sessions: active,
       note: "Sessions require an organization; a project association is optional.",
       tools: %{
         crud: [
           "Session.List",
           "Session.Get",
           "Session.Create",
           "Session.Update",
           "Session.Archive"
         ]
       }
     }}
  end
end
