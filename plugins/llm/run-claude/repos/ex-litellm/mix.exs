defmodule ExLiteLLM.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/noizu-labs/ex-litellm"

  def project do
    [
      app: :ex_litellm,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      releases: releases(),
      deps: deps(),
      name: "ex-litellm",
      description: description(),
      package: package(),
      source_url: @source_url,
      dialyzer: [
        plt_add_apps: [:ex_unit, :mix],
        flags: [:error_handling]
      ],
      test_coverage: [summary: [threshold: 0]]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto, :inets, :ssl],
      mod: {ExLiteLLM.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Self-contained release (bundles ERTS + NIFs) — the deployable artifact
  # run-claude launches. Escript can't load NIFs (exqlite), so a release is the
  # packaging; a bin/ex-litellm wrapper maps --host/--port/--config to env.
  defp releases do
    [
      ex_litellm: [
        include_executables_for: [:unix],
        applications: [ex_litellm: :permanent]
      ]
    ]
  end

  defp deps do
    [
      # Core
      {:jason, "~> 1.4"},
      {:jsv, "~> 0.19"},
      {:telemetry, "~> 1.2"},
      # HTTP server (inbound proxy tiers)
      {:plug, "~> 1.16"},
      {:bandit, "~> 1.5"},
      {:websock_adapter, "~> 0.5"},
      # HTTP client (outbound provider calls + front-proxy forwarding)
      {:req, "~> 0.5"},
      # Config
      {:yaml_elixir, "~> 2.9"},
      # Persistence — SQLite default, Postgres optional
      {:ecto_sql, "~> 3.12"},
      {:ecto_sqlite3, "~> 0.17"},
      {:postgrex, "~> 0.19", optional: true},
      # Auth (JWT / SSO)
      {:jose, "~> 1.11"},
      # Dev / test
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:stream_data, "~> 1.1", only: [:dev, :test]}
    ]
  end

  defp description do
    """
    Interface-identical Elixir reimplementation of the LiteLLM proxy — an
    OpenAI-compatible multi-provider LLM gateway with a runtime-alterable
    front-proxy routing tier. Drop-in replacement for run-claude's Python
    litellm + front-proxy layer. SQLite by default, Postgres optional.
    """
  end

  defp package do
    [
      licenses: ["MIT"],
      maintainers: ["Keith Brings"],
      links: %{"GitHub" => @source_url},
      files: ~w(lib priv .formatter.exs mix.exs README* LICENSE* CHANGELOG*)
    ]
  end
end
