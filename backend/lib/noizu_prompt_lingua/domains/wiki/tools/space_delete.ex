defmodule NoizuPromptLingua.Domains.Wiki.Tools.SpaceDelete do
  use Noizu.MCP.Server.Tool,
    name: "Wiki.SpaceDelete",
    description: "Delete a wiki space and all of its pages.",
    hidden: true,
    category: "Wiki"

  input do
    field :space, :string, required: true, description: "Space UUID"
  end

  alias NoizuPromptLingua.Domains.Wiki
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    id = Args.get(args, :space)

    case Wiki.delete_space(id) do
      {:ok, _} -> {:ok, %{deleted: true, id: id}}
      {:error, :not_found} -> {:error, "Space '#{id}' not found"}
      {:error, changeset} -> {:error, "Failed: #{inspect(changeset.errors)}"}
    end
  end
end
