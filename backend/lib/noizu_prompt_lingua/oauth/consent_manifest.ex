defmodule NoizuPromptLingua.OAuth.ConsentManifest do
  @moduledoc """
  W8: the tool manifest shown on the OAuth consent screen and the parser that
  turns the user's allow/block choices into a per-client `toolset_config`.

  Manifest = one section per group in the global `tobor` default package
  (`MCPCustomScopes.default_package_groups/0`), each listing the tool names the
  gateway serves for that group. Root-plane tools (Discovery / NPL) are NOT in
  the manifest — they cannot be group-gated (see `KeyToolsets`), so consent
  never promises a block it cannot enforce.

  Narrowing semantics (§2 EffectiveToolset / KeyToolsets shape — absent =
  allowed, only BLOCKED entries stored):

      %{"groups" => %{"<group_id>" => %{
           "disabled" => true,
           "tools" => %{"<Tool.Name>" => %{"disabled" => true}}}}}

  Required core groups (`MCPServers.required_ids/0`) are always allowed — the
  consent UI renders them locked, mirroring the all_in_one typed-confirm rule.
  """

  alias Noizu.MCP.Server.Features.Tools
  alias NoizuPromptLingua.{MCPCustomScopes, MCPServers}

  @type section :: %{
          required(:group) => String.t(),
          required(:label) => String.t(),
          required(:required) => boolean(),
          required(:tools) => [String.t()]
        }

  @doc """
  Sections (groups) + per-tool entries the consent screen renders. Resilient:
  a group whose tools cannot be expanded renders with an empty tool list
  rather than failing the consent flow.
  """
  @spec sections() :: [section()]
  def sections do
    required = MCPServers.required_ids()

    MCPCustomScopes.default_package_groups()
    |> Enum.map(fn group_id ->
      %{
        group: group_id,
        label: label(group_id),
        required: group_id in required,
        tools: tool_names(group_id)
      }
    end)
  end

  @doc """
  Build the `toolset_config` narrowing from consent POST params.

  Form encoding: unchecked boxes are simply absent from the params
  (`allow_group[<gid>]` / `allow_tool[<gid>][<tool>]` checkboxes, all rendered
  pre-checked). A group left unchecked → whole group `disabled`; an
  individual tool left unchecked → that tool `disabled`. A fully-allowed
  request yields `%{"groups" => %{}}` (= no narrowing = legacy behavior).
  """
  @spec narrowing([section()], map()) :: map()
  def narrowing(sections, params) when is_map(params) do
    allowed_groups = param_map(params["allow_group"])
    allowed_tools = param_map(params["allow_tool"])

    groups =
      Enum.reduce(sections, %{}, fn %{group: group_id, tools: tools}, acc ->
        cond do
          group_id in MCPServers.required_ids() ->
            acc

          Map.get(allowed_groups, group_id) != "on" ->
            Map.put(acc, group_id, %{"disabled" => true})

          true ->
            group_tools = param_map(Map.get(allowed_tools, group_id))
            blocked = Enum.reject(tools, &(Map.get(group_tools, &1) == "on"))

            case blocked do
              [] -> acc
              blocked -> Map.put(acc, group_id, %{"tools" => Map.new(blocked, &{&1, %{"disabled" => true}})})
            end
        end
      end)

    %{"groups" => groups}
  end

  def narrowing(_sections, _params), do: %{"groups" => %{}}

  # Phoenix nests checkbox params as string-keyed maps; tolerate absence.
  defp param_map(value) when is_map(value), do: value
  defp param_map(_), do: %{}

  defp label(group_id) do
    MCPServers.all()
    |> Enum.find(&(&1.id == group_id))
    |> case do
      %{label: label} -> label
      _ -> group_id
    end
  end

  defp tool_names(group_id) do
    case MCPServers.server_module(group_id) do
      nil ->
        []

      module ->
        module.__mcp__(:tools)
        |> Tools.expand()
        |> Enum.map(& &1.definition.name)
        |> Enum.sort()
        |> Enum.uniq()
    end
  rescue
    _ -> []
  end
end
