defmodule NoizuPromptLingua.Domains.Assets.Tools.AssetContentFormats do
  use Noizu.MCP.Server.Tool, name: "Asset.ContentFormats",
    description: "List available content generation formats and solutions per asset type.",
    hidden: true, category: "Assets.Generation",
    annotations: [read_only_hint: true]

  input do
    field :asset_type, :string, description: "Filter by asset type (image, diagram, svg, html, component, document, music, video, voice, style_guide)"
  end

  alias NoizuPromptLingua.Domains.Assets.ContentGenerator

  @impl true
  def call(args, _ctx) do
    asset_type = args[:asset_type] || args["asset_type"]

    if asset_type do
      solutions = ContentGenerator.list_solutions(asset_type)
      {:ok, %{
        asset_type: asset_type,
        solutions: solutions,
        use_case: ContentGenerator.list_use_cases()[asset_type],
        count: length(solutions)
      }}
    else
      all = ContentGenerator.list_use_cases()
      |> Enum.map(fn {type, use_case} ->
        %{asset_type: type, use_case: use_case, solutions: ContentGenerator.list_solutions(type)}
      end)
      {:ok, %{formats: all, total_types: length(all)}}
    end
  end
end
