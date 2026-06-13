defmodule HttpKitchenSink.MCP do
  @moduledoc "The MCP server: full feature surface over Streamable HTTP."

  use Noizu.MCP.Server,
    name: "http_kitchen_sink",
    version: "0.1.0",
    instructions: """
    Kitchen-sink demo server. Tools: `echo` (fast), `long_task` (progress +
    cancellation), `consult_llm` (server->client sampling). Resources:
    `config://app` (subscribable JSON) and `note://{id}`. Prompt: `brainstorm`.
    """

  tool HttpKitchenSink.Tools.Echo
  tool HttpKitchenSink.Tools.LongTask
  tool HttpKitchenSink.Tools.ConsultLLM

  resource HttpKitchenSink.Resources.AppConfig
  resource_template HttpKitchenSink.Resources.Note

  prompt HttpKitchenSink.Prompts.Brainstorm
end
