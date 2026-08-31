defmodule NoizuPromptLingua.MCP.Custom do
  @moduledoc """
  Dynamic MCP server that exposes a DB-configured include set of existing
  domain MCP tools as one endpoint.
  """
  use NoizuPromptLingua.MCP.Server,
    name: "tobor_custom",
    version: "0.1.0",
    instructions:
      "Custom Noizu Prompt Lingua MCP scope. Use Discovery tools to inspect the enabled tool set."

  alias Noizu.MCP.Server.Features.Pagination
  alias Noizu.MCP.Server.Features.Tools
  alias Noizu.MCP.Types
  alias Noizu.MCP.Error
  alias NoizuPromptLingua.MCP.EffectiveToolset
  alias NoizuPromptLingua.MCPResources
  alias NoizuPromptLingua.MCPCustomScopes
  alias NoizuPromptLingua.MCPrompts

  @discovery_tools [
    {NoizuPromptLingua.Tools.ToolSummary, [category: "Discovery"]},
    {NoizuPromptLingua.Tools.ToolSearch, [category: "Discovery"]},
    {NoizuPromptLingua.Tools.ToolDefinition, [category: "Discovery"]},
    {NoizuPromptLingua.Tools.ToolCall, [category: "Discovery"]},
    {NoizuPromptLingua.Tools.ToolHelp, [category: "Discovery"]}
  ]

  def catalog_specs(ctx) do
    custom_specs(ctx) ++ npl_specs(ctx) ++ discovery_specs() ++ overview_specs()
  end

  # Hidden overview tool (auto-registered like the discovery block). Its scope is
  # taken from ctx assigns (`custom_scope_slug`) at call time.
  defp overview_specs do
    Tools.expand([{NoizuPromptLingua.Tools.McpOverview, [category: "Discovery"]}])
  end

  def custom_specs(ctx) do
    with slug when is_binary(slug) <- scope_slug(ctx),
         scope when not is_nil(scope) <- MCPCustomScopes.get_by_slug(slug) do
      # Effective state for the scope layer (client layer is applied later by
      # MCP.Server.list_tools via KeyToolsets/EffectiveToolset with the ctx).
      states = EffectiveToolset.resolve(scope, nil, nil)

      scope.config
      |> MCPCustomScopes.normalize_config(scope.kind)
      |> Map.fetch!("groups")
      |> Enum.flat_map(fn {group_id, group_config} ->
        group_specs(group_id, group_config, states)
      end)
    else
      _ -> []
    end
  end

  defp group_specs(_group_id, %{"disabled" => true}, _states), do: []

  defp group_specs(group_id, _group_config, states) do
    with module when is_atom(module) and not is_nil(module) <-
           NoizuPromptLingua.MCPServers.server_module(group_id) do
      module.__mcp__(:tools)
      |> Tools.expand()
      |> Enum.reject(&(tool_category(&1) == "Discovery"))
      |> Enum.map(fn spec ->
        EffectiveToolset.apply_state(spec, EffectiveToolset.lookup(states, spec.definition.name))      end)
      |> Enum.reject(&is_nil/1)
    else
      _ -> []
    end
  end

  defp discovery_specs do
    Tools.expand(@discovery_tools)
  end

  # NPL load/spec live on the root aggregator, not a selectable group. Include
  # them on the default all-in-one package so one endpoint covers the daily set.
  @npl_tools [
    {NoizuPromptLingua.Tools.NPLLoad, [category: "NPL"]},
    {NoizuPromptLingua.Tools.NPLSpec, [category: "NPL"]}
  ]

  defp npl_specs(ctx) do
    if include_npl?(ctx), do: Tools.expand(@npl_tools), else: []
  end

  defp include_npl?(ctx) do
    with slug when is_binary(slug) <- scope_slug(ctx),
         scope when not is_nil(scope) <- MCPCustomScopes.get_by_slug(slug) do
      scope.kind == "all_in_one" or
        scope.slug == MCPCustomScopes.default_package_slug() or
        scope.source_template_slug == MCPCustomScopes.default_package_slug() or
        scope.name == MCPCustomScopes.account_default_name() or
        not is_nil(scope.user_id) or
        not is_nil(scope.organization_id)
    else
      _ -> false
    end
  end

  defp tool_category(spec) do
    (spec.definition.meta && spec.definition.meta["category"]) || "Uncategorized"
  end

  defp scope_slug(%Noizu.MCP.Ctx{assigns: assigns}) do
    assigns[:custom_scope_slug] || assigns["custom_scope_slug"]
  end

  defp scope_slug(_), do: nil

  # ══ W4: DB-backed prompts / resources / resource-templates ════════════════
  #
  # Scope config gates these like tool groups:
  #   groups absent from config     → capability not part of the endpoint
  #   groups.<id>.disabled == true  → listed empty + get/read refused
  #   groups.<id>.hidden == true    → hidden from list, get/read still served
  #   groups.<id>.entries.<name>    → per-entry disabled/hidden (same semantics)
  # Absent per-entry flags = enabled + visible (inverted semantics, same as tools).

  @prompt_group "prompts"
  @resource_group "resources"

  # ── prompts/list ──────────────────────────────────────────────────────────

  def handle_list_prompts(cursor, ctx) do
    case entity_group(ctx, @prompt_group) do
      {:served, group_cfg} ->
        entries = entry_config(group_cfg)
        opts = scope_opts(ctx)

        if group_hidden?(group_cfg) do
          Pagination.paginate([], nil)
        else
          MCPrompts.list(opts)
          |> Enum.reject(&entry_hidden?(entries, &1.slug))
          |> Enum.map(&to_prompt_type/1)
          |> Pagination.paginate(cursor)
        end

      _ ->
        Pagination.paginate([], nil)
    end
  end

  # ── prompts/get ───────────────────────────────────────────────────────────

  def handle_get_prompt(name, args, ctx) when is_binary(name) do
    case entity_group(ctx, @prompt_group) do
      {:served, group_cfg} ->
        entries = entry_config(group_cfg)
        slug = slugify_name(name)
        opts = scope_opts(ctx)

        cond do
          entry_disabled?(entries, slug) ->
            {:error, Error.invalid_params("Prompt not available: #{name}")}

          prompt = MCPrompts.effective(slug, opts[:organization_id], opts[:project_id]) ->
            render_prompt(prompt, args || %{})

          true ->
            {:error, Error.invalid_params("Unknown prompt: #{name}")}
        end

      _ ->
        {:error, Error.invalid_params("Prompt not available: #{name}")}
    end
  end

  def handle_get_prompt(_name, _args, _ctx) do
    {:error, Error.invalid_params("Prompt name must be a string")}
  end

  defp render_prompt(prompt, args) do
    case MCPrompts.render(prompt, args) do
      {:ok, text} ->
        {:ok, [%Types.PromptMessage{role: :user, content: Types.Content.text(text)}]}

      {:error, {:missing_arguments, missing}} ->
        {:error,
         Error.invalid_params("Missing required argument(s): #{Enum.join(missing, ", ")}")}

      {:error, _} ->
        {:error, Error.invalid_params("Prompt could not be rendered")}
    end
  end

  # ── resources/list + resources/templates/list + resources/read ────────────

  def handle_list_resources(cursor, ctx) do
    case entity_group(ctx, @resource_group) do
      {:served, group_cfg} ->
        entries = entry_config(group_cfg)
        opts = scope_opts(ctx)

        if group_hidden?(group_cfg) do
          Pagination.paginate([], nil)
        else
          MCPResources.list_resources(opts)
          |> Enum.reject(&entry_hidden?(entries, &1.uri))
          |> Enum.map(&to_resource_type/1)
          |> Pagination.paginate(cursor)
        end

      _ ->
        Pagination.paginate([], nil)
    end
  end

  def handle_list_resource_templates(cursor, ctx) do
    case entity_group(ctx, @resource_group) do
      {:served, group_cfg} ->
        entries = entry_config(group_cfg)
        opts = scope_opts(ctx)

        if group_hidden?(group_cfg) do
          Pagination.paginate([], nil)
        else
          MCPResources.list_templates(opts)
          |> Enum.reject(&entry_hidden?(entries, &1.uri_template))
          |> Enum.map(&to_template_type/1)
          |> Pagination.paginate(cursor)
        end

      _ ->
        Pagination.paginate([], nil)
    end
  end

  def handle_read_resource(uri, ctx) when is_binary(uri) do
    case entity_group(ctx, @resource_group) do
      {:served, group_cfg} ->
        entries = entry_config(group_cfg)
        opts = scope_opts(ctx)

        cond do
          entry_disabled?(entries, uri) ->
            {:error, Error.resource_not_found(uri)}

          resource =
              MCPResources.find_resource_by_uri(uri, opts[:organization_id], opts[:project_id]) ->
            {:ok, resource.content}

          true ->
            {:error, Error.resource_not_found(uri)}
        end

      _ ->
        {:error, Error.resource_not_found(uri)}
    end
  end

  def handle_read_resource(_uri, _ctx) do
    {:error, Error.invalid_params("Resource URI must be a string")}
  end

  # ── gating helpers (shared by prompts + resources groups) ─────────────────

  # `{:served, group_cfg}` when the group is part of the endpoint and enabled;
  # `:absent` (not opted in) or `:disabled` otherwise.
  defp entity_group(ctx, group_id) do
    case scope_record(ctx) do
      nil ->
        :absent

      scope ->
        cfg = get_in(scope.config || %{}, ["groups", group_id])

        cond do
          is_nil(cfg) -> :absent
          Map.get(cfg, "disabled") == true -> :disabled
          true -> {:served, cfg}
        end
    end
  end

  defp entry_config(group_cfg), do: Map.get(group_cfg, "entries") || %{}

  defp group_hidden?(group_cfg), do: Map.get(group_cfg, "hidden") == true

  defp entry_disabled?(entries, key), do: get_in(entries, [key, "disabled"]) == true
  defp entry_hidden?(entries, key), do: get_in(entries, [key, "hidden"]) == true

  defp scope_record(ctx) do
    case scope_slug(ctx) do
      slug when is_binary(slug) -> MCPCustomScopes.get_by_slug(slug)
      _ -> nil
    end
  end

  defp scope_opts(ctx) do
    case scope_record(ctx) do
      nil ->
        []

      scope ->
        # Keys are always present: explicit nil means "globals only" for a
        # scope with no org/project binding.
        [organization_id: scope.organization_id, project_id: scope.project_id]
    end
  end

  defp slugify_name(name), do: name |> String.trim() |> String.downcase()

  # ── protocol-type mappers ─────────────────────────────────────────────────

  defp to_prompt_type(%NoizuPromptLingua.Schema.MCP.McpPrompt{} = prompt) do
    %Types.Prompt{
      name: prompt.slug,
      title: prompt.name,
      description: prompt.description,
      arguments:
        prompt.arguments
        |> List.wrap()
        |> Enum.map(fn
          %{"name" => n} = arg ->
            %Types.Prompt.Argument{
              name: n,
              title: arg["title"],
              description: arg["description"],
              required: arg["required"] == true
            }

          %{name: n} = arg ->
            %Types.Prompt.Argument{
              name: n,
              title: Map.get(arg, :title),
              description: Map.get(arg, :description),
              required: Map.get(arg, :required) == true
            }

          _ ->
            nil
        end)
        |> Enum.reject(&is_nil/1)
    }
  end

  defp to_resource_type(%NoizuPromptLingua.Schema.MCP.McpResource{} = r) do
    %Types.Resource{
      uri: r.uri,
      name: r.name,
      description: r.description,
      mime_type: r.mime_type
    }
  end

  defp to_template_type(%NoizuPromptLingua.Schema.MCP.McpResourceTemplate{} = t) do
    %Types.ResourceTemplate{
      uri_template: t.uri_template,
      name: t.name,
      description: t.description,
      mime_type: t.mime_type
    }
  end
end
