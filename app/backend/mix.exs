defmodule Derobot.MixProject do
  use Mix.Project

  def project do
    [
      app: :derobot,
      version: "0.1.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      listeners: [Phoenix.CodeReloader]
    ]
  end

  def application do
    [
      mod: {Derobot.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.8.1"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.13"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:swoosh, "~> 1.16"},
      {:req, "~> 0.5"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.26"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.2.0"},
      {:bandit, "~> 1.5"},
      {:guardian, "~> 2.3"},
      {:bcrypt_elixir, "~> 3.0"},

      # SSO / Federation
      {:openid_connect, "~> 1.0"},
      {:samly, "~> 1.4"},
      {:ueberauth, "~> 0.10"},
      {:ueberauth_google, "~> 0.12"},
      {:ueberauth_github, "~> 0.8"},

      # Noizu
      {:noizu_labs_entities, "~> 0.3.0"},
      {:semaphore, "~> 1.0"},
      {:seed_helper, "~> 0.1.1"},

      # GenAI
      {:genai, "~> 0.3.0"},
      #{:ex_llama, "~> 0.2.0"},

      # Routing
      {:syn, "~> 3.3"},

      # Ecto / Schema
      {:redix, "~> 1.1"},
      {:geo_postgis, "~> 3.7"},
      {:geo, "~> 3.6"},
      {:ecto_psql_extras, "~> 0.8.1"},
      {:pgvector, "~> 0.3.0"},

      # Test
      {:junit_formatter, "~> 3.4", only: [:test]}


    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
