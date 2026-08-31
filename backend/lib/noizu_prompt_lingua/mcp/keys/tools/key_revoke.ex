defmodule NoizuPromptLingua.MCP.Keys.Tools.KeyRevoke do
  @moduledoc "Key.Revoke — revoke one of the calling user's MCP API keys."

  use Noizu.MCP.Server.Tool,
    name: "Key.Revoke",
    description:
      "Revoke one of your MCP API keys. A revoked key stops verifying immediately; " <>
        "its toolset config is retained for audit but the key cannot mint tokens.",
    hidden: false,
    category: "Keys",
    annotations: [read_only_hint: false, destructive_hint: true]

  input_schema(%{
    "type" => "object",
    "properties" => %{
      "key" => %{"type" => "string", "description" => "API key id (UUID)"}
    },
    "required" => ["key"]
  })

  def authz, do: [action: "keys:revoke", required_role: :owner, resource: :global]

  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, ctx) do
    with user_id when is_binary(user_id) <- Resolve.current_user_id(ctx),
         key_id when is_binary(key_id) <- Args.get(args, :key),
         :ok <- owned_key(user_id, key_id),
         {:ok, key} <- MCPApiKeys.revoke(key_id) do
      {:ok, %{key: MCPApiKeys.mask(key), notice: "Key revoked."}}
    else
      nil -> {:error, "authentication required"}
      :not_found -> {:error, "key not found (or not yours)"}
      _ -> {:error, "key id required"}
    end
  end

  defp owned_key(user_id, key_id) do
    case MCPApiKeys.get(key_id) do
      %{user_id: ^user_id} -> :ok
      _ -> :not_found
    end
  end
end
