defmodule NoizuPromptLingua.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      NoizuPromptLingua.Repo,
      NoizuPromptLingua.MCP,
      NoizuPromptLingua.Domains.Sessions.MCP,
      NoizuPromptLingua.Domains.Tickets.MCP,
      NoizuPromptLingua.Domains.Review.MCP,
      NoizuPromptLingua.Domains.Chat.MCP,
      NoizuPromptLingua.Domains.Wiki.MCP,
      NoizuPromptLingua.Domains.Projects.MCP,
      NoizuPromptLingua.Domains.Artifacts.MCP,
      NoizuPromptLingua.Domains.Assets.MCP,
      NPLWeb.Endpoint
    ]

    result = Supervisor.start_link(children, strategy: :one_for_one, name: NoizuPromptLingua.Supervisor)

    case result do
      {:ok, _pid} ->
        seed_ticket_definitions()
        result
      other ->
        other
    end
  end

  defp seed_ticket_definitions do
    try do
      NoizuPromptLingua.Domains.Tickets.Seed.run()
    rescue
      e -> require Logger; Logger.warning("Ticket seed skipped: #{inspect(e)}")
    end
  end
end
