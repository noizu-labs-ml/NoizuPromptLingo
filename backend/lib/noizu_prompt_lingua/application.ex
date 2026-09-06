defmodule NoizuPromptLingua.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    OpentelemetryPhoenix.setup(adapter: :bandit)
    OpentelemetryEcto.setup([:noizu_prompt_lingua, :repo])
    OpentelemetryBandit.setup()
    # Phase 4 elevation txn/active grants (ETS)
    _ = NoizuPromptLingua.OAuth.Elevation.ensure_table!()

    samly_children =
      if Application.get_env(:noizu_prompt_lingua, :saml_enabled) do
        [Samly.Provider]
      else
        []
      end

    children =
      [
        NoizuPromptLinguaWeb.Telemetry,
        NoizuPromptLingua.Repo,
        # TRP shared-key plane: dedicated Finch pool + read-cache (W4 cutover).
        {Finch, name: NoizuPromptLingua.TRP.Finch},
        NoizuPromptLingua.TRP.Cache
      ] ++
        [
          {Ecto.Migrator,
           repos: Application.fetch_env!(:noizu_prompt_lingua, :ecto_repos),
           skip: skip_migrations?()},
          {DNSCluster,
           query: Application.get_env(:noizu_prompt_lingua, :dns_cluster_query) || :ignore},
          {Phoenix.PubSub, name: NoizuPromptLingua.PubSub},
          NoizuPromptLingua.Redis,
          # Presence tracker for the notifications domain (Redis-backed online/offline).
          NoizuPromptLingua.Domains.Notifications.Presence,
          Noizu.LiveViewEventServer,
          {Oban, Application.fetch_env!(:noizu_prompt_lingua, Oban)}
        ] ++
        samly_children ++
        [
          NoizuPromptLingua.Events.WebhookHandler,
          # MCP servers (organization / project / session domains + root aggregator)
          NoizuPromptLingua.MCP,
          NoizuPromptLingua.MCP.Custom,
          NoizuPromptLingua.MCP.Organizations,
          NoizuPromptLingua.MCP.Projects,
          NoizuPromptLingua.MCP.Clients,
          NoizuPromptLingua.MCP.Sessions,
          # N3 set-gateway endpoint: serving supervisor family (Registry /
          # TaskSupervisor / SessionSupervisor / EventStore). Omitted pre-B1,
          # every set-gateway initialize 500'd on `no process` once the flag
          # let requests through the gates.
          NoizuPromptLingua.MCP.ToolSetEndpoint,
          # MCP servers ported from the legacy project (artifacts / chat / review)
          NoizuPromptLingua.Domains.Artifacts.MCP,
          NoizuPromptLingua.Domains.Chat.MCP,
          NoizuPromptLingua.Domains.Review.MCP,
          NoizuPromptLingua.Domains.Wiki.MCP,
          NoizuPromptLingua.Domains.Github.MCP,
          NoizuPromptLingua.Domains.Markdown.MCP,
          NoizuPromptLingua.Domains.Notifications.MCP,
          NoizuPromptLingua.Domains.PubSub.MCP,
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
          NoizuPromptLingua.Domains.UnicodeCodex.MCP,
          # VFS Wave 0 substrate: the dedicated fs server (composed Router backend)
          # plus the lib's VFS pubsub hub (explicit supervisor — watch/subscribe
          # for the VFSWS mount transport degrades to no-op without it).
          NoizuPromptLingua.MCP.VFSServer,
          Noizu.MCP.Server.VFSPubSub,
          # Browser relay: correlates Browser.* tool calls with the local controller.
          NoizuPromptLingua.Domains.Browser.Relay,
          # VFS Wave 4 job-dir runner (§3.8): submit bookkeeping + shim pool.
          {Task.Supervisor, name: NoizuPromptLingua.MCP.VFS.Jobs.RunnerSup},
          NoizuPromptLingua.MCP.VFS.Jobs,
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
