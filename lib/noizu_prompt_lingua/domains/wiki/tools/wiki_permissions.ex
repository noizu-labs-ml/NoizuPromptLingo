defmodule NoizuPromptLingua.Domains.Wiki.Tools.WikiPermissions do
  use Noizu.MCP.Server.Tool, name: "Wiki.Permissions",
    description: "Set access control on pages or spaces.", hidden: true, category: "Wiki"

  input do
    field :entity_type, :string, required: true, description: "space or page"
    field :entity_id, :string, required: true, description: "Space or page UUID"
    field :persona, :string, required: true, description: "Persona slug"
    field :permission, :string, required: true, description: "read, write, admin"
    field :action, :string, description: "grant (default) or revoke"
  end

  alias NoizuPromptLingua.Domains.Wiki

  @impl true
  def call(args, _ctx) do
    action = args[:action] || args["action"] || "grant"
    entity_type = args[:entity_type] || args["entity_type"]
    entity_id = args[:entity_id] || args["entity_id"]
    persona = args[:persona] || args["persona"]

    case action do
      "revoke" ->
        case Wiki.revoke_permission(entity_type, entity_id, persona) do
          {:ok, _} -> {:ok, %{revoked: true, entity_type: entity_type, persona: persona}}
          {:error, :not_found} -> {:error, "Permission not found"}
        end
      _ ->
        permission = args[:permission] || args["permission"]
        case Wiki.grant_permission(%{entity_type: entity_type, entity_id: entity_id, persona: persona, permission: permission}) do
          {:ok, p} -> {:ok, %{id: p.id, entity_type: entity_type, persona: persona, permission: p.permission}}
          {:error, cs} -> {:error, "Failed: #{inspect(cs.errors)}"}
        end
    end
  end
end
