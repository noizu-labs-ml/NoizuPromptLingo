defmodule NoizuPromptLingua.Domains.Assets.Tools.AssetContentReference do
  use Noizu.MCP.Server.Tool, name: "Asset.ContentReference",
    description: "Get format-specific generation reference for a solution or use-case.",
    hidden: true, category: "Assets.Generation",
    annotations: [read_only_hint: true]

  input do
    field :solution, :string, description: "Solution name (e.g. mermaid, svg_js, latex, vexflow)"
    field :use_case, :string, description: "Use-case name (e.g. diagram-generation, data-visualization)"
  end

  alias NoizuPromptLingua.Domains.Assets.ContentGenerator

  @impl true
  def call(args, _ctx) do
    solution = args[:solution] || args["solution"]
    use_case = args[:use_case] || args["use_case"]

    cond do
      solution ->
        case ContentGenerator.get_solution_reference(solution) do
          {:ok, content} -> {:ok, %{solution: solution, reference: content}}
          :error -> {:error, "Solution '#{solution}' not found"}
        end
      use_case ->
        case ContentGenerator.get_use_case_reference(use_case) do
          {:ok, content} -> {:ok, %{use_case: use_case, reference: content}}
          :error -> {:error, "Use-case '#{use_case}' not found"}
        end
      true ->
        {:error, "Provide either 'solution' or 'use_case' parameter"}
    end
  end
end
