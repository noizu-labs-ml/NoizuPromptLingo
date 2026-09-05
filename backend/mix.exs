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
      listeners: [Phoenix.CodeReloader],
      # Coverage (excoveralls; dev/test only — see deps)
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Replaces the removed `:preferred_cli_env` project keyword (deprecated in
  # Elixir 1.17, removed in 1.19 — silences the per-run CI warning).
  def cli do
    [
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.html": :test,
        "coveralls.json": :test,
        # The smoke alias must not leak dev.exs config (tobor_locker user) into
        # the run — aliases keep the ambient MIX_ENV otherwise.
        smoke: :test
      ]
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

      # GenAI
      # 0.3.9 is on develop (Qwen media + OpenRouter); Hex still at 0.3.5.
      {:genai, "~> 0.3.9", github: "noizu-labs-ml/genai", branch: "develop"},
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
      # ex_aws uses Req (already a dep) as its HTTP client — see config/config.exs.
      # Do NOT add :hackney: it pulls :h2 which conflicts with chatterbox's h2_* modules
      # at mix release time (duplicate module error).
      {:ex_aws, "~> 2.5"},
      {:ex_aws_s3, "~> 2.5"},

      # Image Processing
      {:vix, "~> 0.31"},

      # Background Jobs
      {:oban, "~> 2.18"},

      # Carried over from prior NoizuPromptLingo mix.exs
      # N2b: noizu_mcp pinned to the PRD-4 freeze (5f7217e = merge of PR #4,
      # persistence store; version 0.3.0, unpublished on hex — hex stops at 0.1.6).
      # Git ref, not the old local path dep (…/Libs/ai/elixir-mcp/.worktrees/n2b-gate):
      # the path only exists on the dev Mac and broke CI mix compile. Repo is
      # public, so CI resolves the ref without extra credentials.
      {:noizu_mcp, git: "https://github.com/noizu-labs-ml/elixir-mcp-lib.git", ref: "5f7217ed63a3e242a8595aa71f546c56bc1d2bef"},
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
      {:junit_formatter, "~> 3.4", only: [:test]},
      # Line coverage tooling — dev/test only, never a runtime dep.
      # `mix coveralls.json` → cover/excoveralls.json; `mix test --cover` also works.
      {:excoveralls, "~> 0.18", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: [
        "ecto.create --quiet",
        "ecto.migrate --quiet",
        "test"
      ],
      # CI push-gate subset: curated HERMETIC suites only (no Weaviate / TRP /
      # LLM-provider-key / external-network dependencies). Fast (~minutes) and
      # green on stock runners; the full suite stays available via
      # `mix test` locally and the workflow_dispatch exhaustive CI job.
      # Adding a suite here = a promise it passes on a bare runner; validate
      # with: env -u OPENAI_API_KEY -u TRP_API_BASE_URL -u TRP_SHARED_KEY mix smoke
      smoke: [
        "ecto.create --quiet",
        "ecto.migrate --quiet",
        # One `test` invocation — alias list entries are separate tasks, so the
        # curated paths must ride the same string.
        "test --exclude memory --exclude live_trp " <>
          # mcp core: rename/cast regression, manifest parity, guards, resolvers
          "test/noizu_prompt_lingua/mcp/tool_set_invoke_regression_test.exs " <>
          "test/noizu_prompt_lingua/mcp/session_manifest_parity_test.exs " <>
          "test/noizu_prompt_lingua/mcp/session_manifest_test.exs " <>
          "test/noizu_prompt_lingua/mcp/tool_guard_branches_test.exs " <>
          "test/noizu_prompt_lingua/mcp/window_endpoint_resolver_branches_test.exs " <>
          "test/noizu_prompt_lingua/mcp/negotiations_provider_branches_test.exs " <>
          # stable controller sweeps
          "test/noizu_prompt_lingua_web/controllers/remote_access_tunnels_test.exs " <>
          "test/noizu_prompt_lingua_web/controllers/media_controllers_test.exs " <>
          "test/noizu_prompt_lingua_web/controllers/controller_tail_sweep_test.exs " <>
          # auth / sso
          "test/noizu_prompt_lingua/auth/sso_test.exs " <>
          "test/noizu_prompt_lingua_web/controllers/sso_controller_test.exs " <>
          "test/noizu_prompt_lingua_web/controllers/auth_controller_test.exs " <>
          "test/noizu_prompt_lingua_web/controllers/oauth_controller_test.exs " <>
          "test/noizu_prompt_lingua_web/controllers/oauth_consent_test.exs"
      ]
    ]
  end

end
