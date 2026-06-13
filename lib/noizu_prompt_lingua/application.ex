defmodule NoizuPromptLingua.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      NoizuPromptLingua.Repo,
      NoizuPromptLingua.MCP,
      {Bandit, plug: NoizuPromptLingua.Router, port: 4040}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: NoizuPromptLingua.Supervisor)
  end
end
