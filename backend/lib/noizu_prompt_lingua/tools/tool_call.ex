defmodule NoizuPromptLingua.Tools.ToolCall do
  use Noizu.MCP.Server.Tool,
    name: "ToolCall",
    description:
      "Invoke any hidden (discoverable) tool by name with arguments. " <>
        "This is the primary way to call domain tools that are not MCP-visible. " <>
        "Canonical names use underscore separators (Session_Create); the legacy " <>
        "dotted spelling (Session.Create) is accepted as an alias.",
    category: "Discovery"

  input_schema(%{
    "type" => "object",
    "properties" => %{
      "tool" => %{
        "type" => "string",
        "description" =>
          "Exact tool name, canonical underscore form (e.g., \"Project_Create\"); dotted \"Project.Create\" accepted as alias"
      },
      "arguments" => %{
        "type" => "object",
        "description" => "Tool-specific arguments as a JSON object"
      }
    },
    "required" => ["tool"]
  })

  alias NoizuPromptLingua.Tools.Catalog

  @impl true
  def call(args, ctx) do
    tool_name = args["tool"]
    arguments = args["arguments"] || %{}
    server = (ctx && ctx.server) || NoizuPromptLingua.MCP

    case Catalog.call_hidden_tool(tool_name, arguments, server, ctx) do
      {:ok, result} -> {:ok, result}
      {:mcp, message} -> {:ok, %{status: "mcp", message: message}}
      {:error, reason} -> {:error, to_string(reason)}
    end
  end
end
