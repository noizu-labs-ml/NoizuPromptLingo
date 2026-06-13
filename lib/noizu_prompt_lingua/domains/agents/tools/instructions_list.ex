defmodule NoizuPromptLingua.Domains.Agents.Tools.InstructionsList do
  use Noizu.MCP.Server.Tool, name: "Agent.Instructions.List",
    description: "Search/list instruction documents.", hidden: true, category: "Agents.Instructions",
    annotations: [read_only_hint: true]

  input_schema %{
    "type" => "object",
    "properties" => %{
      "search" => %{"type" => "string", "description" => "Text search in title and content"},
      "tags" => %{"type" => "array", "items" => %{"type" => "string"}, "description" => "Filter by tags"},
      "session_id" => %{"type" => "string", "description" => "Filter by session"},
      "limit" => %{"type" => "integer", "description" => "Max results (default 50)"}
    }
  }

  alias NoizuPromptLingua.Domains.Agents

  @impl true
  def call(args, _ctx) do
    opts = []
    opts = if s = args["search"], do: [{:search, s} | opts], else: opts
    opts = if t = args["tags"], do: [{:tags, t} | opts], else: opts
    opts = if s = args["session_id"], do: [{:session_id, s} | opts], else: opts
    opts = if l = args["limit"], do: [{:limit, l} | opts], else: opts
    instructions = Agents.list_instructions(opts)
    {:ok, %{instructions: Enum.map(instructions, &%{id: &1.id, title: &1.title, tags: &1.tags, version: &1.version}), count: length(instructions)}}
  end
end
