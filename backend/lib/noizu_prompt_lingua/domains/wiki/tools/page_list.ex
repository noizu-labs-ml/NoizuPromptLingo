defmodule NoizuPromptLingua.Domains.Wiki.Tools.PageList do
  use Noizu.MCP.Server.Tool,
    name: "Wiki.PageList",
    description: "List pages in a wiki space, optionally filtered by search.",
    hidden: true,
    category: "Wiki",
    annotations: [read_only_hint: true]

  input do
    field :space, :string, required: true, description: "Space UUID"
    field :search, :string, description: "Search in title or slug"
    field :limit, :integer, description: "Max results (default 200)"
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
        opts =
          []
          |> put_opt(:search, Args.get(args, :search))
          |> put_opt(:limit, Args.get(args, :limit))

        pages = Wiki.list_pages(space.id, opts)

        {:ok,
         %{
           pages:
             Enum.map(pages, fn p ->
               %{
                 id: p.id,
                 slug: p.slug,
                 title: p.title,
                 parent_id: p.parent_id,
                 position: p.position
               }
             end),
           count: length(pages)
         }}
    end
  end

  defp put_opt(opts, _k, nil), do: opts
  defp put_opt(opts, k, v), do: [{k, v} | opts]
end
