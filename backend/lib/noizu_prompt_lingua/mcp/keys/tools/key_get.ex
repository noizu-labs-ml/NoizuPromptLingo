defmodule NoizuPromptLingua.MCP.Keys.Tools.KeyGet do
  @moduledoc "Key.Get — fetch one of the calling user's MCP API keys (masked)."

  use Noizu.MCP.Server.Tool,
    name: "Key.Get",
    description:
      "Get one of your MCP API keys by id (masked — prefix only, never the raw key). " <>
        "Includes the per-key toolset config.",
    hidden: false,
    category: "Keys",
    annotations: [read_only_hint: true]

  input_schema(%{
    "type" => "object",
    "properties" => %{
      "key" => %{"type" => "string", "description" => "API key id (UUID)"}
    },
    "required" => ["key"]
  })

  def authz, do: [action: "keys:get", required_role: :owner, resource: :global]

  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, ctx) do
    with user_id when is_binary(user_id) <- Resolve.current_user_id(ctx),
         key_id when is_binary(key_id) <- Args.get(args, :key),
         %{} = key <- owned_key(user_id, key_id) do
      {:ok, %{key: MCPApiKeys.mask(key)}}
    else
      nil -> {:error, "authentication required"}
      :not_found -> {:error, "key not found (or not yours)"}
      _ -> {:error, "key id required"}
    end
  end

  defp owned_key(user_id, key_id) do
    case MCPApiKeys.get(key_id) do
      %{user_id: ^user_id} = key -> key
      _ -> :not_found
    end
  end
end
