defmodule NoizuPromptLingua.Domains.Agents.Tools.InstructionsCreate do
  use Noizu.MCP.Server.Tool, name: "Agent.Instructions.Create",
    description: "Create a new instruction document.", hidden: true, category: "Agents.Instructions"

  input_schema %{
    "type" => "object",
    "properties" => %{
      "title" => %{"type" => "string", "description" => "Instruction title"},
      "content" => %{"type" => "string", "description" => "Instruction body (markdown)"},
      "tags" => %{"type" => "array", "items" => %{"type" => "string"}, "description" => "Tags"},
      "session_id" => %{"type" => "string", "description" => "Session UUID"}
    },
    "required" => ["title", "content"]
  }

  alias NoizuPromptLingua.Domains.Agents

  @impl true
  def call(args, _ctx) do
    attrs = %{title: args["title"], content: args["content"], tags: args["tags"], session_id: args["session_id"]}
    case Agents.create_instruction(attrs) do
      {:ok, instr} -> {:ok, %{id: instr.id, title: instr.title, version: instr.version, created_at: instr.inserted_at}}
      {:error, cs} -> {:error, "Failed: #{inspect(cs.errors)}"}
    end
  end
end
