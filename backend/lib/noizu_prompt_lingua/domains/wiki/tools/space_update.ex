defmodule NoizuPromptLingua.Domains.Wiki.Tools.SpaceUpdate do
  use Noizu.MCP.Server.Tool,
    name: "Wiki.SpaceUpdate",
    description: "Update a wiki space's name, slug, or description.",
    hidden: true,
    category: "Wiki"

  input do
    field :space, :string, required: true, description: "Space UUID"
    field :name, :string, description: "New name"
    field :slug, :string, description: "New slug"
    field :description, :string, description: "New description"
  end

  alias NoizuPromptLingua.Domains.Wiki
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    id = Args.get(args, :space)

    case Wiki.get_space(id) do
      nil ->
        {:error, "Space '#{id}' not found"}

      _space ->
        attrs = Args.take(args, [:name, :slug, :description])

        case Wiki.update_space(id, attrs) do
          {:ok, updated} ->
            {:ok, %{id: updated.id, slug: updated.slug, name: updated.name, description: updated.description}}

          {:error, :not_found} -> {:error, "Space '#{id}' not found"}
          {:error, changeset} -> {:error, "Failed: #{inspect(changeset.errors)}"}
        end
    end
  end
end
