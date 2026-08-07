defmodule NoizuPromptLingua.MCP.Dispatch do
  @moduledoc """
  tools/call dispatch with ToolGuard + PDP before handler invoke.

  Used by `NoizuPromptLingua.MCP.Server` so every domain server gets the same
  authz seam without patching `noizu_mcp`.
  """

  alias Noizu.MCP.Server.Features.Tools
  alias Noizu.MCP.Server.Tool.Spec
  alias Noizu.MCP.Protocol.{Error, ToolResult}
  alias NoizuPromptLingua.MCP.ToolGuard

  def call(server_mod, name, args, ctx) when is_atom(server_mod) and is_binary(name) do
    registered = server_mod.__mcp__(:tools)

    case registered |> Tools.expand() |> Enum.find(&(&1.definition.name == name)) do
      nil ->
        {:error, Error.invalid_params("Unknown tool: #{name}")}

      %Spec{} = spec ->
        case ToolGuard.before_call(spec_to_guard(spec), args, ctx) do
          :ok ->
            Tools.dispatch(registered, name, args, ctx)

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
