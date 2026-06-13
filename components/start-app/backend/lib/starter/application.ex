defmodule Starter.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    OpentelemetryPhoenix.setup(adapter: :bandit)
    OpentelemetryEcto.setup([:starter, :repo])
    OpentelemetryBandit.setup()

    samly_children =
      if Application.get_env(:starter, :saml_enabled) do
        [Samly.Provider]
      else
        []
      end

    children = [
      StarterWeb.Telemetry,
      Starter.Repo,
      {Ecto.Migrator,
       repos: Application.fetch_env!(:starter, :ecto_repos), skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:starter, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Starter.PubSub},
      Starter.Redis,
      Noizu.LiveViewEventServer,
      {Oban, Application.fetch_env!(:starter, Oban)}
    ] ++ samly_children ++ [
      Starter.Events.WebhookHandler,
      StarterWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Starter.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    StarterWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    System.get_env("RELEASE_NAME") == nil
  end
end
