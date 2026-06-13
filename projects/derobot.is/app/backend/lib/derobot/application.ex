defmodule Derobot.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    samly_children =
      if Application.get_env(:derobot, :saml_enabled), do: [Samly.Provider], else: []

    children =
      [
        DerobotWeb.Telemetry,
        Derobot.Repo,
        {Ecto.Migrator,
         repos: Application.fetch_env!(:derobot, :ecto_repos), skip: skip_migrations?()},
        {DNSCluster, query: Application.get_env(:derobot, :dns_cluster_query) || :ignore},
        {Phoenix.PubSub, name: Derobot.PubSub},
        Derobot.Redis
      ] ++
        samly_children ++
        [
          DerobotWeb.Endpoint
        ]

    opts = [strategy: :one_for_one, name: Derobot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    DerobotWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    System.get_env("RELEASE_NAME") == nil
  end
end
