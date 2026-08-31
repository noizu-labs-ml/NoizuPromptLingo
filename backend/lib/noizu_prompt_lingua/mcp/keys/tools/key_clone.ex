defmodule NoizuPromptLingua.MCP.Keys.Tools.KeyClone do
  @moduledoc """
  Key.Clone — duplicate one of the calling user's keys onto a new key,
  carrying the source's toolset config. The new raw key is returned exactly
  once.
  """

  use Noizu.MCP.Server.Tool,
    name: "Key.Clone",
    description:
      "Clone one of your MCP API keys: the new key inherits the source's per-key toolset " <>
        "config (per tool/group disabled/hidden flags). Returns the new raw key exactly once.",
    hidden: false,
    category: "Keys",
    annotations: [read_only_hint: false]

  input_schema(%{
    "type" => "object",
    "properties" => %{
      "key" => %{"type" => "string", "description" => "Source API key id (UUID)"},
      "label" => %{
        "type" => "string",
        "description" => "Label for the clone (defaults to the source label)"
      }
    },
    "required" => ["key"]
  })

  def authz, do: [action: "keys:clone", required_role: :owner, resource: :global]

  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, ctx) do
    with user_id when is_binary(user_id) <- Resolve.current_user_id(ctx),
         key_id when is_binary(key_id) <- Args.get(args, :key),
         %{user_id: ^user_id} = source <- MCPApiKeys.get(key_id),
         {:ok, key, raw} <-
           MCPApiKeys.clone(source,
             user_id: user_id,
             label: Args.get(args, :label)
           ) do
      {:ok, %{
        key: MCPApiKeys.mask(key),
        raw_key: raw,
        notice: "Store this raw key now — it is never shown again."
      }}
    else
      nil -> {:error, "authentication required"}
      _other -> {:error, "source key not found (or not yours)"}
    end
  end
end
