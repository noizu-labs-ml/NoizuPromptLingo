defmodule NoizuPromptLingua.Domains.Sessions.Tools.SessionArchive do
  use Noizu.MCP.Server.Tool,
    name: "Session.Archive",
    description: "Archive a session. Archived sessions remain queryable but are hidden from default listings.",
    hidden: true,
    category: "Sessions"

  input do
    field :session_id, :string, required: true, description: "Session UUID"
  end

  @impl true
  def call(args, _ctx) do
    session_id = args[:session_id] || args["session_id"]

    case NoizuPromptLingua.Domains.Sessions.archive(session_id) do
      {:ok, session} ->
        {:ok, %{
          id: session.id,
          title: session.title,
          status: session.status,
          archived_at: session.updated_at
        }}

      {:error, :not_found} ->
        {:error, "Session '#{session_id}' not found"}

      {:error, changeset} ->
        {:error, "Failed to archive session: #{inspect(changeset.errors)}"}
    end
  end
end
