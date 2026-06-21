defmodule NoizuPromptLingua.Domains.Instructions.Tools.InstructionUpdate do
  use Noizu.MCP.Server.Tool, name: "Instruction.Update",
    description: "Update instruction metadata and/or add a new body version.",
    hidden: true, category: "Instructions"

  input_schema %{
    "type" => "object",
    "properties" => %{
      "instruction" => %{"type" => "string", "description" => "Slug handle or UUID (required)"},
      "organization" => %{"type" => "string", "description" => "Org slug/UUID (to resolve a slug)"},
      "title" => %{"type" => "string"},
      "description" => %{"type" => "string"},
      "tags" => %{"type" => "array", "items" => %{"type" => "string"}},
      "parameters" => %{"type" => "array", "items" => %{"type" => "object"}},
      "status" => %{"type" => "string", "description" => "active or archived"},
      "body" => %{"type" => "string", "description" => "New body — creates a new active version"},
      "change_note" => %{"type" => "string"}
    },
    "required" => ["instruction"]
  }

  alias NoizuPromptLingua.Domains.Instructions
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    key = Args.get(args, :instruction)
    org_id = Resolve.organization_id(Args.get(args, :organization))
    instruction = (org_id && Instructions.resolve(org_id, key)) || Instructions.get(key)

    case instruction do
      nil -> {:error, "Instruction '#{key}' not found"}
      i ->
        attrs =
          %{}
          |> put_if(:title, args["title"])
          |> put_if(:description, args["description"])
          |> put_if(:tags, args["tags"])
          |> put_if(:parameters, args["parameters"])
          |> put_if(:status, args["status"])

        case Instructions.update(i.id, attrs, body: args["body"], change_note: args["change_note"]) do
          {:ok, u} -> {:ok, %{id: u.id, slug: u.slug, active_version: u.active_version}}
          {:error, :not_found} -> {:error, "Instruction not found"}
          {:error, cs} -> {:error, "Failed: #{inspect(cs.errors)}"}
        end
    end
  end

  defp put_if(map, _k, nil), do: map
  defp put_if(map, k, v), do: Map.put(map, k, v)
end
