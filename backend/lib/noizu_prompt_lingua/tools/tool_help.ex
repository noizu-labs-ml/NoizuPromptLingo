defmodule NoizuPromptLingua.Tools.ToolHelp do
  use Noizu.MCP.Server.Tool,
    name: "ToolHelp",
    description:
      "Generate LLM-driven usage instructions for a tool applied to a specific task. " <>
        "Describes how to use or combine tools to accomplish a goal. " <>
        "If tool is omitted, recommends tools for the task.",
    annotations: [read_only_hint: true],
    category: "Discovery"

  input do
    field :task, :string,
      required: true,
      description: "Natural-language description of what you want to accomplish"

    field :tool, :string,
      description: "Specific tool to get help for. If omitted, recommends tools for the task."
  end

  alias NoizuPromptLingua.Tools.Catalog

  @impl true
  def call(args, ctx) do
    task = args.task
    tool_name = Map.get(args, :tool) || Map.get(args, "tool")
    server = (ctx && ctx.server) || NoizuPromptLingua.MCP

    if tool_name do
      tool_specific_help(tool_name, task, server, ctx)
    else
      task_recommendation(task, server, ctx)
    end
  end

  defp tool_specific_help(tool_name, task, server, ctx) do
    case Catalog.get_tool(tool_name, server, ctx) do
      nil ->
        {:ok,
         %{tool: tool_name, status: "error", message: "Tool '#{tool_name}' not found in catalog."}}

      entry ->
        params_text =
          entry.parameters
          |> Enum.map(fn p ->
            req = if p.required, do: " (required)", else: " (optional)"
            "  - `#{p.name}` (#{p.type}#{req}): #{p.description}"
          end)
          |> Enum.join("\n")

        instructions = """
        ## #{entry.name}

        **Category:** #{entry.category}
        **Description:** #{entry.description}

        ### Parameters
        #{params_text}

        ### For your task: "#{task}"

        Call `#{entry.name}` with the appropriate parameters to accomplish this task.
        Use `ToolDefinition(tool="#{entry.name}")` for the full parameter schema.
        """

        {:ok,
         %{
           tool: entry.name,
           category: entry.category,
           task: task,
           instructions: String.trim(instructions)
         }}
    end
  end

  defp task_recommendation(task, server, ctx) do
    catalog = Catalog.build(server, ctx)
    q = String.downcase(task)

    matches =
      catalog
      |> Enum.filter(fn t ->
        String.contains?(String.downcase(t.name), q) or
          String.contains?(String.downcase(t.description), q)
      end)
      |> Enum.take(5)

    recommendations =
      if matches == [] do
        "No tools directly match your task description. Try `ToolSearch(query=\"#{task}\")` or `ToolSummary()` to browse all available tools."
      else
        tool_lines =
          Enum.map(matches, fn t ->
            "- **#{t.name}** [#{t.category}]: #{t.description}"
          end)
          |> Enum.join("\n")

        "These tools may help:\n\n#{tool_lines}\n\nUse `ToolDefinition` to see their full parameter schemas."
      end

    {:ok,
     %{
       task: task,
       instructions: recommendations
     }}
  end
end
