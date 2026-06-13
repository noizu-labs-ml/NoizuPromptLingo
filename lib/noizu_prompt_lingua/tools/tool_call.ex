defmodule NoizuPromptLingua.Tools.ToolCall do
  use Noizu.MCP.Server.Tool,
    name: "ToolCall",
    description:
      "Invoke any hidden (discoverable) tool by name with arguments. " <>
        "This is the primary way to call domain tools that are not MCP-visible. " <>
        "Supports alias resolution for old tool names.",
    category: "Discovery"

  input_schema %{
    "type" => "object",
    "properties" => %{
      "tool" => %{
        "type" => "string",
        "description" => "Exact tool name (e.g., \"Ticket.Create\")"
      },
      "arguments" => %{
        "type" => "object",
        "description" => "Tool-specific arguments as a JSON object"
      }
    },
    "required" => ["tool"]
  }

  alias NoizuPromptLingua.Tools.Catalog

  @impl true
  def call(args, _ctx) do
    tool_name = args["tool"]
    arguments = args["arguments"] || %{}

    case Catalog.call_hidden_tool(tool_name, arguments) do
      {:ok, result} -> {:ok, result}
      {:mcp, message} -> {:ok, %{status: "mcp", message: message}}
      {:error, reason} -> {:error, to_string(reason)}
    end
  end
end
