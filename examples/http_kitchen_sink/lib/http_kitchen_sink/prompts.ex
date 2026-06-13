defmodule HttpKitchenSink.Prompts.Brainstorm do
  @moduledoc """
  A prompt whose `style` argument supports argument completion — the
  `complete:` static-list sugar answers `completion/complete` requests with
  prefix-filtered suggestions.
  """

  use Noizu.MCP.Server.Prompt,
    name: "brainstorm",
    description: "Brainstorm ideas about a topic in a given style"

  arguments do
    arg :topic, required: true, description: "What to brainstorm about"
    arg :style, description: "Brainstorming style", complete: ["wild", "practical", "contrarian"]
  end

  @impl true
  def get(%{"topic" => topic} = args, _ctx) do
    style = args["style"] || "practical"

    {:ok,
     [
       Noizu.MCP.Types.PromptMessage.user(
         "Brainstorm five #{style} ideas about: #{topic}. Number them."
       )
     ]}
  end
end
