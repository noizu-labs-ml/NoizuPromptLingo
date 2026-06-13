defmodule NoizuPromptLingua.Domains.Sessions.Tools.SessionList do
  use Noizu.MCP.Server.Tool,
    name: "Session.List",
    description: "List sessions with optional filtering by status.",
    hidden: true,
    category: "Sessions"

  input do
    field :status, :string, description: "Filter by status (e.g., \"active\", \"archived\")"
    field :limit, :integer, description: "Max results (default 50)"
    field :offset, :integer, description: "Pagination offset"
  end

  @impl true
  def call(args, _ctx) do
    opts =
      []
      |> maybe_opt(:status, args[:status] || args["status"])
      |> maybe_opt(:limit, args[:limit] || args["limit"])
      |> maybe_opt(:offset, args[:offset] || args["offset"])

    sessions = NoizuPromptLingua.Domains.Sessions.list(opts)

    {:ok, %{
      sessions: Enum.map(sessions, fn s ->
        %{id: s.id, title: s.title, status: s.status, created_at: s.inserted_at}
      end),
      count: length(sessions)
    }}
  end

  defp maybe_opt(opts, _key, nil), do: opts
  defp maybe_opt(opts, key, val), do: Keyword.put(opts, key, val)
end
