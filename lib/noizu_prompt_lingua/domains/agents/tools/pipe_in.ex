defmodule NoizuPromptLingua.Domains.Agents.Tools.PipeIn do
  use Noizu.MCP.Server.Tool, name: "Agent.Pipe.In",
    description: "Pull incoming messages for an agent.", hidden: true, category: "Agents.Pipes"

  input do
    field :agent, :string, required: true, description: "Target agent name"
    field :limit, :integer, description: "Max messages (default 10)"
  end

  alias NoizuPromptLingua.Domains.Agents

  @impl true
  def call(args, _ctx) do
    agent = args[:agent] || args["agent"]
    limit = args[:limit] || args["limit"]
    opts = if limit, do: [limit: limit], else: []
    messages = Agents.pipe_in(agent, opts)
    {:ok, %{agent: agent, messages: Enum.map(messages, &%{id: &1.id, sender: &1.sender, content: &1.content, priority: &1.priority, created_at: &1.inserted_at}), count: length(messages)}}
  end
end
