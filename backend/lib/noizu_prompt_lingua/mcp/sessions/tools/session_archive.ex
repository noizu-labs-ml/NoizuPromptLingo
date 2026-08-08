defmodule NoizuPromptLingua.MCP.Sessions.Tools.SessionArchive do
  use Noizu.MCP.Server.Tool,
    name: "Session.Archive",
    description: "Archive a session by UUID.",
    hidden: true,
    category: "Sessions"

  alias NoizuPromptLingua.MCP.Args

  input do
    field :session, :string, required: true, description: "Session UUID"
  end

  @impl true
  def call(args, _ctx) do
    id = Args.get(args, :session)

    case NoizuPromptLingua.Sessions.archive(id) do
      {:ok, session} -> {:ok, %{id: session.id, title: session.title, status: session.status}}
      {:error, :not_found} -> {:error, "Session '#{id}' not found"}
      {:error, changeset} -> {:error, "Failed: #{inspect(changeset.errors)}"}
    end
  end
end
