defmodule NoizuPromptLingua.Domains.Wiki.Tools.PageCreate do
  use Noizu.MCP.Server.Tool,
    name: "Wiki.PageCreate",
    description: "Create a page in a wiki space (optionally nested under a parent page).",
    hidden: true,
    category: "Wiki"

  input do
    field :space, :string, required: true, description: "Space UUID"
    field :title, :string, required: true, description: "Page title"
    field :slug, :string, description: "URL slug (auto-derived from title when omitted)"
    field :content, :string, description: "Page body (markdown)"
    field :parent, :string, description: "Optional parent page UUID"
    field :position, :integer, description: "Sort position within the space"
  end

  alias NoizuPromptLingua.Domains.Wiki
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    space_id = Args.get(args, :space)

    case Wiki.get_space(space_id) do
      nil ->
        {:error, "Space '#{space_id}' not found"}

      space ->
        attrs = %{
          space_id: space.id,
          parent_id: Args.get(args, :parent),
          title: Args.get(args, :title),
          slug: Args.get(args, :slug),
          content: Args.get(args, :content),
          position: Args.get(args, :position)
        }

        case Wiki.create_page(attrs) do
          {:ok, page} ->
            {:ok, %{id: page.id, slug: page.slug, title: page.title, space_id: page.space_id, parent_id: page.parent_id}}

          {:error, changeset} ->
            {:error, "Failed: #{inspect(changeset.errors)}"}
        end
    end
  end
end
