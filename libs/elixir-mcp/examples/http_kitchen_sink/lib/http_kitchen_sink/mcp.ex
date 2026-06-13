defmodule HttpKitchenSink.MCP do
  @moduledoc "The MCP server: full feature surface over Streamable HTTP."

  use Noizu.MCP.Server,
    name: "http_kitchen_sink",
    version: "0.1.0",
    instructions: """
    Kitchen-sink demo server. Tools: `echo` (fast), `long_task` (progress +
    cancellation), `consult_llm` (server->client sampling), `util.reverse` and
    `server_time` (toolkit). Hidden tools (callable, not listed): `catalog`
    (discovery — call it to see everything, including hidden tools) and
    `util.checksum`. Resources: `config://app` (subscribable JSON) and
    `note://{id}`. Prompt: `brainstorm`.
    """

  tool HttpKitchenSink.Tools.Echo
  tool HttpKitchenSink.Tools.LongTask
  tool HttpKitchenSink.Tools.ConsultLLM

  # Multi-tool module: every @mcp-annotated function registers as a tool.
  tool HttpKitchenSink.Toolkit

  # Discovery tool — hidden from tools/list but callable as "catalog"; it
  # returns full definitions for everything registered, hidden items included.
  tool Noizu.MCP.Server.Tools.Catalog, hidden: true

  resource HttpKitchenSink.Resources.AppConfig
  resource_template HttpKitchenSink.Resources.Note

  prompt HttpKitchenSink.Prompts.Brainstorm
end
