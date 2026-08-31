defmodule NoizuPromptLingua.MCP.SessionManifest do
  @moduledoc """
  Backing logic for the `Session_Manifest` MCP tool (TOBOR-CONTRACTS.md §5).

  Enumerates every registered MCP method across all servers and annotates each
  with its **effective** state for the CALLING client — enabled (execution),
  visible (discovery/listing) and `expires_at` — as resolved by
  `NoizuPromptLingua.MCP.EffectiveToolset` (§2), invoked through the
  `NoizuPromptLingua.MCP.EffectiveToolset.Behaviour` seam.

  Semantics mirror the toolset layer's inverted default: a tool absent from the
  resolved map (or with no flags) is `enabled: true, visible: true,
  expires_at: nil`.

  Tool names are emitted in the canonical underscore form (§4) — dotted
  registered names (e.g. `Session.Create`) are folded via
  `NoizuPromptLingua.MCP.ToolNames.canonical/1` when that module is present
  (F5), else via a local dot→underscore fold, so the output is identical in
  both cases and never contains dotted names.
  """

  alias Noizu.MCP.Server.Features.Tools
  alias NoizuPromptLingua.MCPServers

  @manifest_tool "Session_Manifest"

  @doc """
  Build the manifest for the calling ctx.

      %{tools: [%{name, group, enabled, visible, expires_at}], generated_at}
  """
  def generate(ctx, at \\ DateTime.utc_now()) do
    states = effective_states(ctx, at)

    tools =
      ctx
      |> registered_specs()
      |> Enum.map(fn {group_id, spec} ->
        name = canonical_name(spec.definition.name)
        state = Map.get(states, name) || %{}

        %{
          name: name,
          group: group_id,
          enabled: Map.get(state, :enabled, true),
          visible: Map.get(state, :visible, true),
          expires_at: Map.get(state, :expires_at)
        }
      end)
      |> Enum.uniq_by(& &1.name)
      |> Enum.sort_by(&{&1.group, &1.name})

    %{tools: tools, generated_at: at}
  end

  @doc "Canonical underscore tool name (§4). Prefers F5's ToolNames when loaded."
  def canonical_name(name) when is_binary(name) do
    if Code.ensure_loaded?(NoizuPromptLingua.MCP.ToolNames) and
         function_exported?(NoizuPromptLingua.MCP.ToolNames, :canonical, 1) do
      NoizuPromptLingua.MCP.ToolNames.canonical(name)
    else
      String.replace(name, ".", "_")
    end
  end

  # ---- registered method enumeration -----------------------------------------

  # Every server in the MCPServers catalog (root = the bare-host aggregate
  # server), expanded to concrete tool specs. Returns `{group_id, spec}` pairs;
  # `group_id` is the owning MCP group (`sessions`, `tickets`, ...), `nil`
  # resolving tools (root-only Discovery/NPL) fall back to `"root"`.
  defp registered_specs(_ctx) do
    Enum.flat_map(servers(), fn {group_id, server_mod} ->
      specs = expand(server_mod)

      Enum.map(specs, fn spec ->
        {group_for(spec.module, group_id), spec}
      end)
    end)
  rescue
    _ -> []
  end

  defp servers do
    roots = [{"root", NoizuPromptLingua.MCP}]

    roots ++
      Enum.flat_map(MCPServers.all(), fn %{id: id} ->
        case MCPServers.server_module(id) do
          nil -> []
          mod -> [{id, mod}]
        end
      end)
  end

  defp expand(server_mod) do
    if Code.ensure_loaded?(server_mod) and function_exported?(server_mod, :__mcp__, 1) do
      server_mod.__mcp__(:tools) |> Tools.expand()
    else
      []
    end
  rescue
    _ -> []
  end

  defp group_for(module, default_group) do
    case MCPServers.group_id_for_tool_module(module) do
      nil -> default_group
      group_id -> group_id
    end
  end

  # ---- EffectiveToolset seam ---------------------------------------------------

  defp effective_states(ctx, at) do
    impl = impl_module()

    if Code.ensure_loaded?(impl) and function_exported?(impl, :resolve, 4) do
      apply(impl, :resolve, [scope_for(ctx), client_for(ctx), user_ref(ctx), at])
    else
      %{}
    end
  rescue
    _ -> %{}
  end

  defp impl_module do
    Application.get_env(
      :noizu_prompt_lingua,
      :effective_toolset_impl,
      NoizuPromptLingua.MCP.EffectiveToolset
    )
  end

  # The custom scope the request is served under (`/custom/:slug/mcp`), else
  # nil — F2's cascade still applies the global `tobor` template layer for a
  # nil scope, so static-subdomain callers inherit template-level overrides.
  defp scope_for(ctx) do
    case assigns(ctx)[:custom_scope_slug] || assigns(ctx)["custom_scope_slug"] do
      slug when is_binary(slug) and slug != "" ->
        NoizuPromptLingua.MCPCustomScopes.get_by_slug(slug)

      _ ->
        nil
    end
  end

  defp user_ref(ctx) do
    claims(ctx)["sub"]
  end

  @doc """
  The calling client per §2: `%{id, kind: :api_key | :oauth_client, toolset_config}`.
  API keys carry their stored `toolset_config`; OAuth clients (and anonymous /
  system principals) have none yet (W8 wires per-client `toolset_config`).
  """
  def client_for(ctx) do
    claims = claims(ctx)

    case claims["api_key_id"] do
      api_key_id when is_binary(api_key_id) ->
        %{
          id: api_key_id,
          kind: :api_key,
          toolset_config: toolset_config(api_key_id)
        }

      _ ->
        %{
          id: claims["oauth_client_id"] || claims["sub"],
          kind: :oauth_client,
          toolset_config: nil
        }
    end
  end

  defp toolset_config(api_key_id) do
    case NoizuPromptLingua.Repo.get(NoizuPromptLingua.Schema.McpApiKey, api_key_id) do
      %{toolset_config: config} when is_map(config) -> config
      _ -> nil
    end
  rescue
    _ -> nil
  end

  defp claims(ctx), do: get_in(ctx, [Access.key(:assigns, %{}), Access.key(:auth_claims, %{})]) || %{}
  defp assigns(ctx), do: Map.get(ctx || %{}, :assigns) || %{}

  @doc "The canonical name of this manifest tool itself."
  def manifest_tool, do: @manifest_tool
end
