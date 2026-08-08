defmodule NoizuPromptLingua.MCP.Server do
  @moduledoc """
  Drop-in wrapper around `Noizu.MCP.Server` that installs guarded tool dispatch.

  Usage (same opts as noizu_mcp):

      use NoizuPromptLingua.MCP.Server,
        name: "tobor_sessions",
        version: "0.1.0",
        instructions: "..."
  """

  defmacro __using__(opts) do
    quote do
      # Declare handle_call_tool BEFORE `use Noizu.MCP.Server` so the library
      # skips its default dispatch and ours runs ToolGuard first.
      def handle_call_tool(name, args, ctx) do
        NoizuPromptLingua.MCP.Dispatch.call(__MODULE__, name, args, ctx)
      end

      use Noizu.MCP.Server, unquote(opts)
    end
  end
end

