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
    handlers =
      if Keyword.has_key?(opts, :toolset) do
        # Toolset mode (PRD-N3): serve EXCLUSIVELY through the lib protocol
        # path — listing and dispatch both resolve the server's `toolset:` opt
        # per request (select_toolset). No legacy Dispatch/EffectiveToolset
        # overrides. N5 flips every server to this mode.
        quote do
          def handle_list_tools(cursor, ctx) do
            Noizu.MCP.Server.Features.Tools.protocol_list(__MODULE__, cursor, ctx)
          end

          def handle_call_tool(name, args, ctx) do
            NoizuPromptLingua.MCP.Server.protocol_call_guarded(__MODULE__, name, args, ctx)
          end
        end
      else
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
        end
      end

    quote do
      unquote(handlers)

      use Noizu.MCP.Server, unquote(opts)
    end
  end

  alias Noizu.MCP.Server.Features.Pagination
  alias Noizu.MCP.Server.Features.Tools
  alias NoizuPromptLingua.MCPServers

  require Logger

  @doc """
  Toolset-mode tools/call: the SAME pipeline as the lib's
  `Noizu.MCP.Server.Features.Tools.protocol_call/4` (select_toolset → resolve →
  invoke, with the resolve D5 rescue boundary) plus one NPL-owned addition
  (B13): when the resolved entry's cast plan carries fields the effective
  schema no longer advertises (i.e. `hide_field` removed them), the effective
  schema is CLOSED with `additionalProperties: false` before invoke, so the
  hidden key is REJECTED by the effective-schema validation instead of being
  silently dropped (handlers would otherwise run with the field's default).
  Entries without hidden fields keep the permissive schema (root parity —
  unknown keys stay ignored).
  """
  def protocol_call_guarded(server, name, args, ctx) do
    toolset = Tools.select_toolset(server, ctx)

    case resolve_effective(toolset, name, ctx) do
      {:ok, effective} ->
        Noizu.MCP.Toolset.invoke(toolset, close_hidden_fields(effective), args, ctx, [])

      {:error, %Noizu.MCP.Error{}} = error ->
        error
    end
  end

  # The lib's protocol_call rescues resolve failures into an internal error
  # (D5: a broken toolset disables the surface, never the server) — mirrored.
  defp resolve_effective(toolset, name, ctx) do
    Noizu.MCP.Toolset.resolve(toolset, name, ctx, [])
  rescue
    e -> {:error, Noizu.MCP.Error.internal("toolset resolve failed: #{Exception.message(e)}")}
  end

  # Cast-plan keys missing from the effective schema's properties = hidden
  # fields. Renames never read as hidden: the plan `key` stays the original
  # and only `wire_key` moves, so the key remains advertised under its new
  # spelling.
  defp close_hidden_fields(%Noizu.MCP.Toolset.Effective{} = effective) do
    entry = effective.entry
    schema = entry.input_schema

    if is_list(entry.cast_plan) and is_map(schema) and
         MapSet.size(hidden_keys(entry.cast_plan, schema)) > 0 do
      schema = Map.put(schema, "additionalProperties", false)
      %{effective | entry: %{entry | input_schema: schema}}
    else
      effective
    end
  end

  defp hidden_keys(cast_plan, schema) do
    advertised = schema |> Map.get("properties", %{}) |> Map.keys() |> MapSet.new()

    # Hidden = advertised under NEITHER spelling (plan `key` nor a rename's
    # `wire_key`). A rename alone is NOT hidden: the schema property moves to
    # `wire_key` while the plan `key` stays the original.
    cast_plan
    |> Enum.reject(fn entry ->
      MapSet.member?(advertised, entry.key) or
        (is_binary(Map.get(entry, :wire_key)) and MapSet.member?(advertised, entry.wire_key))
    end)
    |> MapSet.new(& &1.key)
  end

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

  @doc """
  Write-path invalidation for toolset-affecting writes (custom-scope
  create/update/delete, API-key toolset/status writes, OAuth-client
  toolset_config/revoke): bump the `ToolsetCache` generation AND broadcast
  `notifications/tools/list_changed` to every connected session on every NPL
  MCP server (root aggregate, the custom-scope endpoint, and all group
  servers — `notify_changed/1` is generated per server module by the
  `use Noizu.MCP.Server` macro, so the broadcast fans out over the catalog).

  This is the FINAL home of the notify call sites (N1 parity workstream):
  best-effort by contract — a server whose session registry is down is logged
  and skipped, never fails the write that triggered it.
  """
  def notify_toolset_changed do
    NoizuPromptLingua.MCP.ToolsetCache.bump()

    for mod <- server_modules() do
      try do
        if Code.ensure_loaded?(mod) and function_exported?(mod, :notify_changed, 1) do
          mod.notify_changed(:tools)
        end
      rescue
        e ->
          Logger.warning(
            "[MCP.Server] notify_changed(:tools) failed for #{inspect(mod)}: #{Exception.message(e)}"
          )
      end
    end

    :ok
  end

  defp server_modules do
    [NoizuPromptLingua.MCP, NoizuPromptLingua.MCP.Custom] ++
      Enum.flat_map(MCPServers.all(), fn %{id: id} ->
        case MCPServers.server_module(id) do
          nil -> []
          mod -> [mod]
        end
      end)
  end
end
