defmodule NoizuPromptLingua.MCP.Keys.Tools.KeyCreate do
  @moduledoc """
  Key.Create — mint a new MCP API key for the calling user. The raw key is
  returned exactly once; only the 8-char prefix is persisted/displayed
  afterward. Optionally seed the per-key toolset inline or from a custom scope.
  """

  use Noizu.MCP.Server.Tool,
    name: "Key.Create",
    description:
      "Create a new MCP API key for your account. Returns the raw key exactly once — " <>
        "store it immediately. Optionally attach a per-key toolset config " <>
        "(groups.{id}.{disabled,hidden} + tools overrides) or copy one from a custom scope.",
    hidden: false,
    category: "Keys",
    annotations: [read_only_hint: false]

  input_schema(%{
    "type" => "object",
    "properties" => %{
      "label" => %{"type" => "string", "description" => "Key label (default \"default\")"},
      "toolset_config" => %{
        "type" => "object",
        "description" =>
          "Per-key toolset overrides: {\"groups\": {\"<group_id>\": " <>
            "{\"disabled\": bool, \"hidden\": bool, \"tools\": {\"<Tool.Name>\": " <>
            "{\"disabled\": bool, \"hidden\": bool}}}}}. Absent fields inherit."
      },
      "toolset_from_scope" => %{
        "type" => "string",
        "description" => "Custom scope slug/UUID whose toolset config to adopt at creation"
      }
    }
  })

  def authz, do: [action: "keys:create", required_role: :owner, resource: :global]

  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, ctx) do
    with user_id when is_binary(user_id) <- Resolve.current_user_id(ctx),
         {:ok, key, raw} <- create_key(user_id, args) do
      {:ok, %{key: MCPApiKeys.mask(key), raw_key: raw, notice: "Store this raw key now — it is never shown again."}}
    else
      nil -> {:error, "authentication required"}
      {:error, %Ecto.Changeset{} = cs} -> {:error, format_errors(cs)}
      {:error, reason} -> {:error, to_string(reason)}
    end
  end

  defp create_key(user_id, args) do
    label = Args.get(args, :label) || "default"

    with {:ok, scope_config} <- validate_scope_config(args) do
      toolset =
        case scope_config do
          nil -> initial_toolset(args)
          config -> config
        end

      case MCPApiKeys.generate_api_key(user_id, label, toolset_config: toolset) do
        {:ok, key, raw} -> {:ok, key, raw}
        {:error, reason} -> {:error, reason}
      end
    end
  end

  # Validate toolset_from_scope up front so a bad ref never mints a key.
  defp validate_scope_config(args) do
    case Args.get(args, :toolset_from_scope) do
      nil ->
        {:ok, nil}

      scope_ref ->
        scope =
          NoizuPromptLingua.MCPCustomScopes.get_by_slug(scope_ref) ||
            scope_by_uuid(scope_ref)

        case scope do
          nil ->
            {:error, "custom scope '#{scope_ref}' not found"}

          scope ->
            {:ok,
             NoizuPromptLingua.MCPCustomScopes.normalize_config(
               scope.config || %{},
               scope.kind
             )}
        end
    end
  end

  defp scope_by_uuid(ref) do
    case Ecto.UUID.cast(ref) do
      {:ok, _} -> NoizuPromptLingua.MCPCustomScopes.get(ref)
      :error -> nil
    end
  end

  defp initial_toolset(args) do
    case Args.get(args, :toolset_config) do
      config when is_map(config) -> config
      _ -> nil
    end
  end

  defp format_errors(cs),
    do: "invalid: " <> inspect(Ecto.Changeset.traverse_errors(cs, fn {m, _} -> m end))
end
