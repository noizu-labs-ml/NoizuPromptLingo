defmodule NoizuPromptLingua.Domains.Sessions.Tools.SessionUpdate do
  use Noizu.MCP.Server.Tool,
    name: "Session.Update",
    description: "Update an existing session's metadata.",
    hidden: true,
    category: "Sessions"

  input do
    field :session_id, :string, required: true, description: "Session UUID"
    field :title, :string, description: "New title"
    field :description, :string, description: "New description"
    field :status, :string, description: "New status"
  end

  @impl true
  def call(args, _ctx) do
    session_id = args[:session_id] || args["session_id"]

    attrs =
      %{}
      |> maybe_put(:title, args[:title] || args["title"])
      |> maybe_put(:description, args[:description] || args["description"])
      |> maybe_put(:status, args[:status] || args["status"])

    case NoizuPromptLingua.Domains.Sessions.update(session_id, attrs) do
      {:ok, session} ->
        {:ok, %{
          id: session.id,
          title: session.title,
          description: session.description,
          status: session.status,
          updated_at: session.updated_at
        }}

      {:error, :not_found} ->
        {:error, "Session '#{session_id}' not found"}

      {:error, changeset} ->
        {:error, "Failed to update session: #{inspect(changeset.errors)}"}
    end
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, val), do: Map.put(map, key, val)
end
