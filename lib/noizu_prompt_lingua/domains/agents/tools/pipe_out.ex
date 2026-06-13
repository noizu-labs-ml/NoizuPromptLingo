defmodule NoizuPromptLingua.Domains.Agents.Tools.PipeOut do
  use Noizu.MCP.Server.Tool, name: "Agent.Pipe.Out",
    description: "Push structured data to target agents.", hidden: true, category: "Agents.Pipes"

  input_schema %{
    "type" => "object",
    "properties" => %{
      "targets" => %{"type" => "array", "items" => %{"type" => "string"}, "description" => "Target agent names"},
      "content" => %{"type" => "string", "description" => "Message content (YAML)"},
      "sender" => %{"type" => "string", "description" => "Sending agent name"},
      "priority" => %{"type" => "string", "description" => "normal (default) or high"}
    },
    "required" => ["targets", "content", "sender"]
  }

  alias NoizuPromptLingua.Domains.Agents

  @impl true
  def call(args, _ctx) do
    targets = args["targets"]
    content = args["content"]
    sender = args["sender"]
    priority = args["priority"] || "normal"
    case Agents.pipe_out(targets, content, sender, priority: priority) do
      {:ok, count} -> {:ok, %{sent: count, targets: targets}}
      {:error, errors} -> {:error, "Failed: #{inspect(errors)}"}
    end
  end
end
