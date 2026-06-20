defmodule NoizuPromptLingua.Domains.Wiki.Tools.SpaceGet do
  use Noizu.MCP.Server.Tool,
    name: "Wiki.SpaceGet",
    description: "Get a wiki space by UUID, including its page list.",
    hidden: true,
    category: "Wiki",
    annotations: [read_only_hint: true]

  input do
    field :space, :string, required: true, description: "Space UUID"
  end

  alias NoizuPromptLingua.Domains.Wiki
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    id = Args.get(args, :space)

    case Wiki.get_space(id) do
      nil ->
        {:error, "Space '#{id}' not found"}

      space ->
        {:ok, %{
          id: space.id,
          slug: space.slug,
          name: space.name,
          description: space.description,
          organization_id: space.organization_id,
          project_id: space.project_id,
          pages: Enum.map(Wiki.list_pages(space.id), fn p ->
            %{id: p.id, slug: p.slug, title: p.title, parent_id: p.parent_id, position: p.position}
          end)
        }}
    end
  end
end
