defmodule NoizuPromptLingua.MCP.Dispatch do
  @moduledoc """
  tools/call dispatch with ToolGuard + PDP before handler invoke.

  Used by `NoizuPromptLingua.MCP.Server` so every domain server gets the same
  authz seam without patching `noizu_mcp`.
  """

  alias Noizu.MCP.{Error, Schema}
  alias Noizu.MCP.Server.Features.Tools
  alias Noizu.MCP.Server.Tool.{Fields, Spec}
  alias Noizu.MCP.Types.ToolResult
  alias NoizuPromptLingua.MCP.{ToolGuard, ToolNames}

  def call(server_mod, name, args, ctx) when is_atom(server_mod) and is_binary(name) do
    specs = expand_specs(server_mod, ctx)

    # Names are matched on the canonical underscore form; dotted spellings
    # (Session.Create) are aliases accepted at dispatch, never the wire name.
    case Enum.find(specs, &(ToolNames.canonical(&1.definition.name) == ToolNames.canonical(name))) do
      nil ->
        {:error, Error.invalid_params("Unknown tool: #{name}")}

      %Spec{} = spec ->
        # Canonicalize so ToolGuard/config keys and error text see the
        # underscore name regardless of which alias the client dispatched.
        spec = ToolNames.canonical_spec(spec)

        case ToolGuard.before_call(spec_to_guard(spec), args, ctx) do
          :ok ->
            run_spec(spec, args || %{}, ctx)

          {:error, %{code: code, reason: reason, elevation_uri: uri} = meta} when is_binary(uri) ->
            # Phase 4 step-up: surface elevation URI for HITL approval.
            ToolResult.error(
              Jason.encode!(%{
                error: "insufficient_authorization",
                error_description: "tool requires elevation",
                elevation_uri: uri,
                reason: reason,
                code: code,
                tool: meta[:tool],
                txn: meta[:txn]
              })
            )

          {:error, %{code: code, reason: reason} = meta} ->
            ToolResult.error(
              "authorization_denied: #{code} reason=#{inspect(reason)} action=#{inspect(meta[:action])}"
            )

          {:error, other} ->
            ToolResult.error("authorization_denied: #{inspect(other)}")
        end
    end
  end

  # Dynamic servers (e.g. NoizuPromptLingua.MCP.Custom) expose their tool set
  # via catalog_specs/1 instead of the compile-time __mcp__(:tools) registry.
  defp expand_specs(server_mod, ctx) do
    if function_exported?(server_mod, :catalog_specs, 1) do
      server_mod.catalog_specs(ctx)
    else
      server_mod.__mcp__(:tools) |> Tools.expand()
    end
  end

  # Clients sanitize MCP tool names for their own tool-name charset
  # ("Organization.Overview" -> "Organization_Overview"), so dispatch matches on
  # the canonical underscore form; dotted spellings are accepted as aliases.

  defp run_spec(%Spec{} = spec, args, ctx) do
    case Schema.validate(spec.definition.input_schema, args) do
      :ok ->
        args =
          case spec.cast_plan do
            nil -> args
            plan -> Fields.cast(plan, args)
          end

        call_args =
          case spec.arity do
            0 -> []
            1 -> [args]
            2 -> [args, ctx]
          end

        apply(spec.module, spec.fun, call_args) |> Tools.normalize(spec.output_schema)

      {:error, message} ->
        ToolResult.error("Invalid arguments for tool #{spec.definition.name}: #{message}")
    end
  end

  defp spec_to_guard(%Spec{} = spec) do
    authz =
      cond do
        function_exported?(spec.module, :authz, 0) ->
          spec.module.authz()

        true ->
          # Module attribute may not be available at runtime after compile
          nil
      end

    %{
      name: spec.definition.name,
      module: spec.module,
      authz: authz
    }
  end
end
