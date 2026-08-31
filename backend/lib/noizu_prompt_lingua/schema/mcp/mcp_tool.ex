defmodule NoizuPromptLingua.Schema.McpTool do
  @moduledoc """
  Phantom ERP entity kind for MCP tool ACL resources (debt D2).

  NOT backed by a table — the module exists so `NoizuPromptLingua.Acl.ERPRef`
  can round-trip tool resource refs through the JSONB encoding
  (`{"type": "NoizuPromptLingua.Schema.McpTool", "id": "<canonical tool name>"}`;
  load goes through `String.to_existing_atom/1`, so the kind atom must exist on
  a running node) and so kind-wildcard rules (`"id": "any"`) resolve.

  ACL convention (TOBOR-CONTRACTS §1 + EffectiveToolset):

    * action: `"mcp.tool"` (or the `"*"` wildcard)
    * per-tool resource: `{:ref, NoizuPromptLingua.Schema.McpTool, canonical_tool_name}`
    * every-tool resource: `{:ref, NoizuPromptLingua.Schema.McpTool, :any}`
  """

  require Noizu.EntityReference.Records
  alias Noizu.EntityReference.Records, as: R

  @doc "Resource ref for a canonical tool name (ACL action `mcp.tool`)."
  def ref(tool_name), do: R.ref(module: __MODULE__, id: tool_name)
end
