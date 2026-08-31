defmodule NoizuPromptLingua.MCP.Keys.Tools.KeyUpdate do
  @moduledoc """
  Key.Update — update one of the calling user's keys: label, status, and/or
  per-key toolset config (inline, or copied from a custom scope via
  `toolset_from_scope`).
  """

  use Noizu.MCP.Server.Tool,
    name: "Key.Update",
    description:
      "Update your MCP API key: label, status (active|revoked), or per-key toolset config. " <>
        "Toolset flags are per tool and per group ({\"groups\": {...}}) with disabled/hidden " <>
        "semantics; absent fields inherit from the custom-scope cascade. " <>
        "Use toolset_from_scope to copy a custom scope's config onto this key.",
    hidden: false,
    category: "Keys",
    annotations: [read_only_hint: false]

  input_schema(%{
    "type" => "object",
    "properties" => %{
      "key" => %{"type" => "string", "description" => "API key id (UUID)"},
      "label" => %{"type" => "string", "description" => "New label"},
      "status" => %{
        "type" => "string",
        "enum" => ["active", "revoked"],
        "description" => "New status (revoking stops the key from verifying)"
      },
      "toolset_config" => %{
        "type" => "object",
        "description" =>
          "Full per-key toolset config (replaces existing): {\"groups\": {\"<group_id>\": " <>
            "{\"disabled\": bool, \"hidden\": bool, \"tools\": {\"<Tool.Name>\": " <>
            "{\"disabled\": bool, \"hidden\": bool}}}}}. Empty object {} = inherit everything."
      },
      "toolset_from_scope" => %{
        "type" => "string",
        "description" => "Custom scope slug/UUID whose toolset config replaces this key's"
      }
    },
    "required" => ["key"]
  })

  def authz, do: [action: "keys:update", required_role: :owner, resource: :global]

  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, ctx) do
    with user_id when is_binary(user_id) <- Resolve.current_user_id(ctx),
         key_id when is_binary(key_id) <- Args.get(args, :key),
         %{} = key <- owned_key(user_id, key_id),
         {:ok, key} <- apply_updates(key, args) do
      {:ok, %{key: MCPApiKeys.mask(key)}}
    else
      nil -> {:error, "authentication required"}
      :not_found -> {:error, "key not found (or not yours)"}
      {:error, %Ecto.Changeset{} = cs} -> {:error, format_errors(cs)}
      {:error, reason} -> {:error, to_string(reason)}
      _ -> {:error, "key id required"}
    end
  end

  defp owned_key(user_id, key_id) do
    case MCPApiKeys.get(key_id) do
      %{user_id: ^user_id} = key -> key
      _ -> :not_found
    end
  end

  defp apply_updates(key, args) do
    # Args.take only includes present args, so omitting toolset_config never
    # wipes the stored config.
    attrs = Args.take(args, [:label, :status, :toolset_config])

    with {:ok, key} <- MCPApiKeys.update(key, attrs, owner_id: key.user_id),
         {:ok, key} <- apply_scope_copy(key, args) do
      {:ok, key}
    end
  end

  defp apply_scope_copy(key, args) do
    case Args.get(args, :toolset_from_scope) do
      nil -> {:ok, key}
      scope_ref -> MCPApiKeys.copy_toolset_from(key, scope_ref)
    end
  end

  defp format_errors(cs),
    do: "invalid: " <> inspect(Ecto.Changeset.traverse_errors(cs, fn {m, _} -> m end))
end
