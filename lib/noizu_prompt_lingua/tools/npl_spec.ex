defmodule NoizuPromptLingua.Tools.NPLSpec do
  use Noizu.MCP.Server.Tool,
    description: "Noizu Prompt Lingua specification generation and formatting",
    annotations: [read_only_hint: true]

  input do
    field :components, {:array, :object},
      description:
        "List of component specs to include. Empty list includes all conventions. " <>
          "Each object has: spec (string, e.g. \"syntax:*\" or \"pumps:npl-intent\"), " <>
          "component_priority (integer, default 0), example_priority (integer, default 0)." do
      field :spec, :string, required: true, description: "Component spec string, e.g. \"syntax:*\" or \"pumps:npl-intent,chain-of-thought\""
      field :component_priority, :integer, default: 0, description: "Maximum component priority to include"
      field :example_priority, :integer, default: 0, description: "Maximum example priority to include"
    end

    field :rendered, {:array, :object},
      description:
        "List of component specs already rendered elsewhere. Excluded from output but " <>
          "treated as known for example selection. Empty list means nothing pre-rendered." do
      field :spec, :string, required: true, description: "Rendered component spec string"
      field :component_priority, :integer, default: 0
      field :example_priority, :integer, default: 0
    end

    field :component_priority, :integer,
      default: 0,
      description: "Default max component priority to include"

    field :example_priority, :integer,
      default: 0,
      description: "Default max example priority to include"

    field :extension, :boolean,
      default: false,
      description: "If true, wraps in extend markers instead of definition markers"

    field :concise, :boolean,
      default: true,
      description: "If true, use brief descriptions"

    field :xml, :boolean,
      default: false,
      description: "If true, use XML tags for examples instead of fenced code blocks"
  end

  @impl true
  def call(args, _ctx) do
    components = normalize_specs(Map.get(args, :components, []))
    rendered = normalize_specs(Map.get(args, :rendered, []))
    component_priority = Map.get(args, :component_priority, 0)
    example_priority = Map.get(args, :example_priority, 0)
    extension = Map.get(args, :extension, false)
    concise = Map.get(args, :concise, true)
    xml = Map.get(args, :xml, false)

    components_arg = if components == [], do: nil, else: components
    rendered_arg = if rendered == [], do: nil, else: rendered

    case NoizuPromptLingua.NPL.Definition.new() do
      {:ok, defn} ->
        result =
          NoizuPromptLingua.NPL.Definition.format(defn,
            components: components_arg,
            rendered: rendered_arg,
            component_priority: component_priority,
            example_priority: example_priority,
            extension: extension,
            flags: %{concise: concise, xml: xml}
          )

        {:ok, result}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp normalize_specs(nil), do: []
  defp normalize_specs([]), do: []

  defp normalize_specs(specs) do
    Enum.map(specs, fn
      %{spec: spec} = s ->
        %{
          spec: spec,
          component_priority: Map.get(s, :component_priority, 0),
          example_priority: Map.get(s, :example_priority, 0)
        }

      s when is_binary(s) ->
        s
    end)
  end
end
