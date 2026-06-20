defmodule NoizuPromptLingua.Domains.Wiki.Tools.CommentDelete do
  use Noizu.MCP.Server.Tool,
    name: "Wiki.CommentDelete",
    description: "Delete a wiki page comment (and its replies).",
    hidden: true,
    category: "Wiki"

  input do
    field :comment, :string, required: true, description: "Comment UUID"
  end

  alias NoizuPromptLingua.Domains.Wiki
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    id = Args.get(args, :comment)

    case Wiki.delete_comment(id) do
      {:ok, _} -> {:ok, %{deleted: true, id: id}}
      {:error, :not_found} -> {:error, "Comment '#{id}' not found"}
      {:error, changeset} -> {:error, "Failed: #{inspect(changeset.errors)}"}
    end
  end
end
