defmodule NoizuPromptLingua.Domains.Sessions.Tools.SessionCreate do
  use Noizu.MCP.Server.Tool,
    name: "Session.Create",
    description: "Create a new work session. Sessions group chat rooms, artifacts, and tickets under a shared context.",
    hidden: true,
    category: "Sessions"

  input do
    field :title, :string, required: true, description: "Human-readable session title"
    field :description, :string, description: "Optional longer description of the session's purpose"
    field :status, :string, description: "Initial status (default \"active\")"
  end

  @impl true
  def call(args, _ctx) do
    attrs = %{
      title: args[:title] || args["title"],
      description: args[:description] || args["description"],
      status: args[:status] || args["status"] || "active"
    }

    case NoizuPromptLingua.Domains.Sessions.create(attrs) do
      {:ok, session} ->
        {:ok, %{
          id: session.id,
          title: session.title,
          status: session.status,
          created_at: session.inserted_at
        }}

      {:error, changeset} ->
        {:error, "Failed to create session: #{inspect(changeset.errors)}"}
    end
  end
end
