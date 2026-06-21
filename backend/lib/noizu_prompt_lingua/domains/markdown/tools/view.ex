defmodule NoizuPromptLingua.Domains.Markdown.Tools.View do
  use Noizu.MCP.Server.Tool,
    name: "Markdown.View",
    description:
      "Filter and collapse a Markdown document by heading. The filter accepts a heading name, a \"Parent > Child\" path, \"Parent > *\" (children), or a level selector like \"h2\". In context mode (default) the full document is returned with non-matched sections collapsed (📦); in bare mode only matched sections are returned. depth/filter_inner_depth collapse deeper headings.",
    annotations: [read_only_hint: true],
    category: "Markdown"

  input do
    field :markdown, :string, required: true, description: "The Markdown document to view"
    field :filter, :string, description: "Heading selector (e.g. \"API > Auth\", \"h2\")"

    field :bare, :boolean,
      default: false,
      description: "Return only matched sections instead of the full collapsed document"

    field :depth, :integer, description: "Collapse headings deeper than this level (1-6)"

    field :filter_inner_depth, :integer,
      description: "Within matched sections, collapse headings deeper than this level"
  end

  alias NoizuPromptLingua.Domains.Markdown
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    markdown = Args.get(args, :markdown)

    opts = [
      filter: Args.get(args, :filter),
      bare: Args.get(args, :bare),
      depth: Args.get(args, :depth),
      filter_inner_depth: Args.get(args, :filter_inner_depth)
    ]

    case Markdown.view(markdown, opts) do
      {:ok, %{markdown: md, matched: matched}} -> {:ok, %{markdown: md, matched: matched}}
      {:error, reason} -> {:error, reason}
    end
  end
end
