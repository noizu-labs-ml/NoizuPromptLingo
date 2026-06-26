defmodule NoizuPromptLingua.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    OpentelemetryPhoenix.setup(adapter: :bandit)
    OpentelemetryEcto.setup([:noizu_prompt_lingua, :repo])
    OpentelemetryBandit.setup()

    samly_children =
      if Application.get_env(:noizu_prompt_lingua, :saml_enabled) do
        [Samly.Provider]
      else
        []
      end

    children = [
      NoizuPromptLinguaWeb.Telemetry,
      NoizuPromptLingua.Repo,
      {Ecto.Migrator,
       repos: Application.fetch_env!(:noizu_prompt_lingua, :ecto_repos), skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:noizu_prompt_lingua, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: NoizuPromptLingua.PubSub},
      NoizuPromptLingua.Redis,
      Noizu.LiveViewEventServer,
      {Oban, Application.fetch_env!(:noizu_prompt_lingua, Oban)}
    ] ++ samly_children ++ [
      NoizuPromptLingua.Events.WebhookHandler,
      # MCP servers (organization / project / session domains + root aggregator)
      NoizuPromptLingua.MCP,
      NoizuPromptLingua.MCP.Organizations,
      NoizuPromptLingua.MCP.Projects,
      NoizuPromptLingua.MCP.Sessions,
      # MCP servers ported from the legacy project (artifacts / chat / review)
      NoizuPromptLingua.Domains.Artifacts.MCP,
      NoizuPromptLingua.Domains.Chat.MCP,
      NoizuPromptLingua.Domains.Review.MCP,
      NoizuPromptLingua.Domains.Wiki.MCP,
      NoizuPromptLingua.Domains.Github.MCP,
      NoizuPromptLingua.Domains.Markdown.MCP,
      NoizuPromptLingua.Domains.Pipes.MCP,
      NoizuPromptLingua.Domains.Browser.MCP,
      NoizuPromptLingua.Domains.Memory.MCP,
      # MCP servers whose SSE Registry was not being started (endpoints dead until now)
      NoizuPromptLingua.Domains.Personas.MCP,
      NoizuPromptLingua.Domains.Instructions.MCP,
      NoizuPromptLingua.Domains.Tickets.MCP,
      NoizuPromptLingua.Domains.Assets.MCP,
      # Marketing/go-to-market domains: customer personas, market intel, campaigns.
      NoizuPromptLingua.Domains.Customers.MCP,
      NoizuPromptLingua.Domains.Market.MCP,
      NoizuPromptLingua.Domains.Campaigns.MCP,
      # Browser relay: correlates Browser.* tool calls with the local controller.
      NoizuPromptLingua.Domains.Browser.Relay,
      NoizuPromptLinguaWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: NoizuPromptLingua.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    NoizuPromptLinguaWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    System.get_env("RELEASE_NAME") == nil
  end
end
