defmodule Codefresh.MixProject do
  use Mix.Project

  def project do
    [
      app: :codefresh,
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
      mod: {Codefresh.Application, []},
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

      # Noizu
      {:noizu_labs_entities, "~> 0.3.0"},
      {:semaphore, "~> 1.0"},
      {:seed_helper, "~> 0.1.1"},

      # GenAI
      {:genai, "~> 0.3.0"},
      # {:ex_llama, "~> 0.2.0"},

      # Routing
      {:syn, "~> 3.3"},

      # Ecto / Schema
      {:redix, "~> 1.1"},
      {:geo_postgis, "~> 3.7"},
      {:geo, "~> 3.6"},
      {:ecto_psql_extras, "~> 0.8.1"},
      {:pgvector, "~> 0.3.0"},

      # Background jobs (Stage 0 / Stage 5 runner)
      {:oban, "~> 2.17"},

      # OpenTelemetry instrumentation (Stage 0 / Stage 10)
      {:opentelemetry, "~> 1.5"},
      {:opentelemetry_api, "~> 1.4"},
      {:opentelemetry_exporter, "~> 1.8"},
      {:opentelemetry_phoenix, "~> 2.0"},
      {:opentelemetry_bandit, "~> 0.2"},
      {:opentelemetry_ecto, "~> 1.2"},

      # OpenAPI spec (Stage 0.5 contract freeze)
      {:open_api_spex, "~> 3.19"},

      # Test
      {:junit_formatter, "~> 3.4", only: [:test]},
      {:stream_data, "~> 1.0", only: [:test]},
      {:excoveralls, "~> 0.18", only: [:test]},

      # Dev/test lint — no :only because a transitive dep (noizu_labs_entities)
      # requires credo at :prod scope.
      {:credo, "~> 1.7", runtime: false}
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
