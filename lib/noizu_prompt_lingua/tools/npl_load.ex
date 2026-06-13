defmodule NoizuPromptLingua.Tools.NPLLoad do
  use Noizu.MCP.Server.Tool,
    description: "Load NPL components by expression DSL — agent-friendly alternative to NPLSpec",
    annotations: [read_only_hint: true]

  input do
    field :expression, :string,
      required: true,
      description:
        "NPL loading expression. Space-separated terms of the form section[#component][:+priority]. " <>
          "Prefix '-' to subtract. Sections: syntax, declarations, directives, prefixes, prompt-sections, " <>
          "special-sections, pumps, fences. Examples: \"syntax\", \"syntax#placeholder:+2\", " <>
          "\"syntax directives -syntax#literal-string\""

    field :layout, :enum,
      values: [:yaml_order, :classic, :grouped],
      default: :yaml_order,
      description:
        "Layout strategy: yaml_order (default, flat section order), " <>
          "classic (grouped by first label), or grouped (by section type)."

    field :skip, {:array, :string},
      description:
        "Optional list of expression terms already loaded elsewhere. Their components are " <>
          "excluded from this load. Same grammar as expression, without leading '-'. " <>
          "Example: [\"syntax#placeholder\", \"pumps\"]"
  end

  @impl true
  def call(args, _ctx) do
    expression = args.expression
    layout = Map.get(args, :layout, :yaml_order)
    skip = Map.get(args, :skip, nil)

    case NoizuPromptLingua.NPL.Loader.load(expression, layout: layout, skip: skip) do
      {:ok, result} -> {:ok, result}
      {:error, reason} -> {:error, reason}
    end
  end
end
