defmodule NoizuPromptLingua.Tools.Greet do
  use Noizu.MCP.Server.Tool,
    description: "Say hello to someone by name.",
    annotations: [read_only_hint: true]

  input do
    field :name, :string, required: true, description: "Who to greet"
  end

  @impl true
  def call(%{name: name}, _ctx) do
    {:ok, "Hello, #{name}! Welcome to the Noizu MCP world."}
  end
end

defmodule NoizuPromptLingua.MCP do
  use Noizu.MCP.Server,
    name: "noizu_prompt_lingua",
    version: "0.1.0",
    instructions: "Noizu Prompt Lingua MCP server. Provides NPL specification loading and generation tools."

  tool NoizuPromptLingua.Tools.Greet
  tool NoizuPromptLingua.Tools.NPLLoad
  tool NoizuPromptLingua.Tools.NPLSpec
end
