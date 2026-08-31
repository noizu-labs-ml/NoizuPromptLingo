defmodule NoizuPromptLingua.MCP.Server do
  @moduledoc """
  Drop-in wrapper around `Noizu.MCP.Server` that installs guarded tool dispatch
  and per-key toolset-aware listing.

  Usage (same opts as noizu_mcp):

      use NoizuPromptLingua.MCP.Server,
        name: "tobor_sessions",
        version: "0.1.0",
        instructions: "..."

  `handle_call_tool/3` routes through `NoizuPromptLingua.MCP.Dispatch` (ToolGuard
  + PDP). `handle_list_tools/2` resolves the calling client (API key OR OAuth
  client, see `NoizuPromptLingua.MCP.EffectiveToolset`) and drops hidden/disabled
  tools before the default listing; servers exposing `catalog_specs/1` (dynamic
  endpoints) are filtered the same way.
  """

  defmacro __using__(opts) do
    quote do
      # Declare handle_call_tool BEFORE `use Noizu.MCP.Server` so the library
      # skips its default dispatch and ours runs ToolGuard first.
      def handle_call_tool(name, args, ctx) do
        NoizuPromptLingua.MCP.Dispatch.call(__MODULE__, name, args, ctx)
      end

      # Per-key toolset-aware listing (hidden/disabled filtered by API key).
      def handle_list_tools(cursor, ctx) do
        NoizuPromptLingua.MCP.Server.list_tools(__MODULE__, cursor, ctx)
      end

      use Noizu.MCP.Server, unquote(opts)
    end
  end

  alias Noizu.MCP.Server.Features.Pagination
  alias Noizu.MCP.Server.Features.Tools

  @doc """
  Shared `handle_list_tools` implementation: expand the server's tool set
  (registered tools, or `catalog_specs/1` for dynamic servers), rewrite names to
  canonical underscore form (dotted spellings are aliases, never emitted), drop
  tools the calling client (API key or OAuth consent narrowing) has
  hidden/disabled via the EffectiveToolset cascade, drop static hidden tools,
  paginate.
  """
  def list_tools(server, cursor, ctx) do
    specs =
      if function_exported?(server, :catalog_specs, 1) do
        server.catalog_specs(ctx)
      else
        server.__mcp__(:tools) |> Tools.expand()
      end

    specs
    |> NoizuPromptLingua.MCP.ToolNames.canonical_specs()
    |> NoizuPromptLingua.MCP.EffectiveToolset.apply_to_specs(ctx, nil)
    |> Enum.reject(& &1.hidden)
    |> Enum.map(& &1.definition)
    |> Pagination.paginate(cursor)
  end
end
