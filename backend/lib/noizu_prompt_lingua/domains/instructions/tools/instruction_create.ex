defmodule NoizuPromptLingua.Domains.Instructions.Tools.InstructionCreate do
  use Noizu.MCP.Server.Tool, name: "Instruction.Create",
    description: "Save a reusable instruction prompt (v1) with optional declared params.",
    hidden: true, category: "Instructions"

  input_schema %{
    "type" => "object",
    "properties" => %{
      "organization" => %{"type" => "string", "description" => "Organization slug or UUID (required)"},
      "project" => %{"type" => "string", "description" => "Optional project slug or UUID"},
      "slug" => %{"type" => "string", "description" => "Handle, unique within the organization"},
      "title" => %{"type" => "string"},
      "description" => %{"type" => "string"},
      "body" => %{"type" => "string", "description" => "Prompt body; use {{param}} placeholders"},
      "tags" => %{"type" => "array", "items" => %{"type" => "string"}},
      "parameters" => %{"type" => "array",
        "description" => "Declared params: [{name, description, required, default}]",
        "items" => %{"type" => "object"}}
    },
    "required" => ["organization", "slug", "title", "body"]
  }

  alias NoizuPromptLingua.Domains.Instructions
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    case Resolve.scope(Args.get(args, :organization), Args.get(args, :project)) do
      {:ok, org_id, project_id} ->
        attrs = %{organization_id: org_id, project_id: project_id,
                  slug: args["slug"], title: args["title"], description: args["description"],
                  tags: args["tags"] || [], parameters: args["parameters"] || []}

        case Instructions.create(attrs, body: args["body"]) do
          {:ok, i} -> {:ok, %{id: i.id, slug: i.slug, title: i.title, active_version: i.active_version}}
          {:error, cs} -> {:error, "Failed: #{inspect(cs.errors)}"}
        end

      {:error, :org_not_found} -> {:error, "Organization not found"}
      {:error, :project_not_found} -> {:error, "Project not found"}
      {:error, :project_not_in_org} -> {:error, "Project does not belong to this organization"}
    end
  end
end
