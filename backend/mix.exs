defmodule NoizuPromptLingua.MixProject do
  use Mix.Project

  def project do
    [
      app: :noizu_prompt_lingua,
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
      mod: {NoizuPromptLingua.Application, []},
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
      {:stream_data, "~> 1.0", only: [:test, :dev]},
      {:noizu_sendgrid, "~> 2.1.0"},
      {:req, "~> 0.5"},
      {:floki, "~> 0.36"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.26"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.2.0"},
      {:bandit, "~> 1.5"},
      {:guardian, "~> 2.3"},
      {:bcrypt_elixir, "~> 3.0"},

      # SSO / OAuth
      # castore provides the CA trust store for openid_connect's Finch/Mint
      # HTTPS calls (discovery doc + token endpoint); it's only an optional
      # transitive dep otherwise, so pull it in explicitly.
      {:castore, "~> 1.0"},
      {:openid_connect, "~> 1.0"},
      {:samly, "~> 1.4"},
      {:ueberauth, "~> 0.10"},
      {:ueberauth_google, "~> 0.12"},
      {:ueberauth_facebook, "~> 0.10"},
      {:ueberauth_github, "~> 0.8"},
      # {:ueberauth_linkedin, "~> 0.3"}, # incompatible oauth2 dep — needs replacement

      # Noizu
      {:noizu_labs_entities, "~> 0.3.0"},
      {:semaphore, "~> 1.0"},
      {:seed_helper, "~> 0.1.1"},
      {:smart_token, "~> 0.1.3"},
      {:noizu_weaviate, "~> 0.2.0"},
      # Shared pm_core data layer (orgs/projects/items) via Noizu.PM.Repo.
      noizu_labs_pm_dep(),

      # GenAI
      {:genai, "~> 0.3.2"},
      # {:ex_llama, "~> 0.2.0"},

      # Routing
      {:syn, "~> 3.3"},

      # Ecto / Schema
      {:redix, "~> 1.1"},
      {:geo_postgis, "~> 3.7"},
      {:geo, "~> 3.6"},
      {:ecto_psql_extras, "~> 0.8.1"},
      {:pgvector, "~> 0.3.0"},

      # Rate Limiting
      {:hammer, "~> 6.2"},

      # Storage
      {:ex_aws, "~> 2.5"},
      {:ex_aws_s3, "~> 2.5"},

      # Image Processing
      {:vix, "~> 0.31"},

      # Background Jobs
      {:oban, "~> 2.18"},

      # Carried over from prior NoizuPromptLingo mix.exs
      {:noizu_mcp, "~> 0.1.3"},
      {:noizu_github, "~> 0.5.0"},
      {:jose, "~> 1.11"},
      {:yaml_elixir, "~> 2.11"},

      # Observability
      {:opentelemetry, "~> 1.4"},
      {:opentelemetry_api, "~> 1.3"},
      {:opentelemetry_exporter, "~> 1.7"},
      {:opentelemetry_phoenix, "~> 2.0"},
      {:opentelemetry_ecto, "~> 1.2"},
      {:opentelemetry_bandit, "~> 0.2"},
      {:logger_json, "~> 6.0"},

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

  # Shared PM data layer (pm_core). Resolution order:
  # 1) NOIZU_LABS_PM_PATH env
  # 2) monorepo Portfolio/Libs/pm (local/dev builds, canonical source)
  # 3) vendor/noizu_labs_pm (Docker build artifact synced from Portfolio/Libs/pm,
  #    used when the monorepo path isn't present)
  defp noizu_labs_pm_dep do
    candidates =
      [
        System.get_env("NOIZU_LABS_PM_PATH"),
        Path.expand("../../../../Libs/pm", __DIR__),
        Path.expand("vendor/noizu_labs_pm", __DIR__)
      ]
      |> Enum.reject(&is_nil/1)

    case Enum.find(candidates, &File.dir?/1) do
      nil ->
        Mix.raise("""
        noizu_labs_pm not found. Vendor it under backend/vendor/noizu_labs_pm \
        or set NOIZU_LABS_PM_PATH.
        """)

      path ->
        {:noizu_labs_pm, path: path}
    end
  end
end
