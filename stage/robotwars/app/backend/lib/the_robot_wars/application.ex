defmodule TheRobotWars.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    OpentelemetryPhoenix.setup(adapter: :bandit)
    OpentelemetryEcto.setup([:the_robot_wars, :repo])
    OpentelemetryBandit.setup()

    samly_children =
      if Application.get_env(:the_robot_wars, :saml_enabled) do
        [Samly.Provider]
      else
        []
      end

    children = [
      TheRobotWarsWeb.Telemetry,
      TheRobotWars.Repo,
      {Ecto.Migrator,
       repos: Application.fetch_env!(:the_robot_wars, :ecto_repos), skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:the_robot_wars, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: TheRobotWars.PubSub},
      TheRobotWars.Redis,
      Noizu.LiveViewEventServer,
      {Oban, Application.fetch_env!(:the_robot_wars, Oban)}
    ] ++ samly_children ++ [
      TheRobotWars.Events.WebhookHandler,
      TheRobotWarsWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: TheRobotWars.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    TheRobotWarsWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    System.get_env("RELEASE_NAME") == nil
  end
end
