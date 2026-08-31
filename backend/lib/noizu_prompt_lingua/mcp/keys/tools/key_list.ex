defmodule NoizuPromptLingua.MCP.Keys.Tools.KeyList do
  @moduledoc "Key.List — list the calling user's MCP API keys (masked; no raw values)."

  use Noizu.MCP.Server.Tool,
    name: "Key.List",
    description:
      "List your MCP API keys. Responses are masked (key prefix only; raw key values " <>
        "are never returned). Includes each key's per-key toolset config.",
    hidden: false,
    category: "Keys",
    annotations: [read_only_hint: true]

  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCP.Resolve

  def authz, do: [action: "keys:list", required_role: :owner, resource: :global]

  @impl true
  def call(_args, ctx) do
    with user_id when is_binary(user_id) <- Resolve.current_user_id(ctx) do
      keys = user_id |> MCPApiKeys.list_for_user() |> Enum.map(&MCPApiKeys.mask/1)
      {:ok, %{keys: keys, count: length(keys)}}
    else
      nil -> {:error, "authentication required"}
    end
  end
end
