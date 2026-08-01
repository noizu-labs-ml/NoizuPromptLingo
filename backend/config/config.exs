import Config

config :seed_helper,
  repo: NoizuPromptLingua.Repo

config :smart_token,
  repo: NoizuPromptLingua.Repo

config :noizu_prompt_lingua, NoizuPromptLingua.Repo,
  types: NoizuPromptLingua.PostgrexTypes,
  migration_primary_key: [name: :id, type: :uuid]

config :noizu_prompt_lingua,
  ecto_repos: [NoizuPromptLingua.Repo],
  generators: [timestamp_type: :utc_datetime]

# Shared pm_core repo (Noizu.PM.Repo). URL bound in runtime.exs when PM_CORE_DATABASE_URL is set.
# Always-on shared mode until microservice split — see docs/pm-core-cutover.md.
config :noizu_labs_pm, Noizu.PM.Repo,
  types: Noizu.PM.PostgrexTypes,
  migration_primary_key: [name: :id, type: :uuid]

config :noizu_prompt_lingua, :pm_core, enabled: true

config :noizu_prompt_lingua, NoizuPromptLinguaWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: NoizuPromptLinguaWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: NoizuPromptLingua.PubSub

config :noizu_sendgrid,
  api_key: System.get_env("SENDGRID_API_KEY") || "SG.dev-placeholder"

# GitHub API client — token passed per-call via options[:token]
config :noizu_github, NoizuLabs.Github.Config,
  # Placeholder; we always pass options[:token] from mapped repo tokens
  api_key: nil,
  owner: nil,
  repo: nil

config :noizu_prompt_lingua, :mail_from, {"NoizuPromptLingua", "noreply@starter.local"}

config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :noizu_prompt_lingua, :redis, uri: "redis://localhost:6379/0", key_prefix: "starter:"

config :noizu_prompt_lingua, NoizuPromptLingua.Guardian,
  issuer: "noizu_prompt_lingua",
  secret_key: "dev-secret-key-change-in-production"

# SSO feature flags (all disabled by default, enabled via runtime env vars)
config :ueberauth, Ueberauth, providers: []

config :noizu_prompt_lingua, :oidc_enabled, false
config :noizu_prompt_lingua, :saml_enabled, false
config :noizu_prompt_lingua, :google_enabled, false
config :noizu_prompt_lingua, :facebook_enabled, false
config :noizu_prompt_lingua, :github_enabled, false
config :noizu_prompt_lingua, :linkedin_enabled, false
config :noizu_prompt_lingua, :sso_require_invite, false

config :junit_formatter,
  report_file: "results.xml"

# Rate limiting
config :hammer,
  backend: {Hammer.Backend.ETS, [expiry_ms: 60_000 * 60, cleanup_interval_ms: 60_000 * 10]}

# Background jobs
config :noizu_prompt_lingua, Oban,
  repo: NoizuPromptLingua.Repo,
  queues: [mailer: 10, default: 10, cleanup: 5, memory: 10],
  plugins: [
    {Oban.Plugins.Pruner, max_age: 60 * 60 * 24 * 7},
    {Oban.Plugins.Cron,
     crontab: [
       {"0 */6 * * *", NoizuPromptLingua.Workers.CleanupWorker}
     ]}
  ]

# ── Memory engine (ported from The Robot Remembers) ────────────────────────
# Dispatch mode for the memory side-effect workers (see NoizuPromptLingua.Domains.Memory.Jobs):
# :oban (durable, queue-processed) in prod/dev, overridden to :sync in test.
config :noizu_prompt_lingua, :jobs_mode, :oban

# genai media-generation provider registry (ADR-016). Hex deps don't ship the lib's own
# config, so the consumer declares which providers GenAI.Media.Router may route to. Used by
# the Assets domain to generate image/voice/music/video via GenAI.generate_media. Providers
# read their API keys from the pod env (OPENAI_API_KEY / GEMINI_API_KEY / SUNO_API_KEY / ...).
config :genai, :media_providers, [
  GenAI.Provider.OpenAI.Image,
  GenAI.Provider.Gemini.Image,
  GenAI.Provider.OpenAI.Speech,
  GenAI.Provider.OpenAI.Transcription,
  GenAI.Provider.Suno,
  GenAI.Provider.LiteLLM.Media
]

# Text → vector embeddings (OpenAI text-embedding-3-small, 1536-d). api_key is set at runtime.
config :noizu_prompt_lingua, :embeddings,
  provider: :openai,
  model: "text-embedding-3-small",
  dimensions: 1536,
  api_base: "https://api.openai.com/v1",
  api_key: nil,
  timeout_ms: 8_000

# Weaviate via noizu_weaviate. Holds the four named text vectors per memory (BYO/vectorizer:none).
# NOTE: noizu_weaviate reads `endpoint` at COMPILE time, so set it per-environment here (dev) /
# prod.exs; the api key is runtime (runtime.exs).
config :noizu_weaviate,
  endpoint: System.get_env("WEAVIATE_ENDPOINT", "https://weaviate.noizu.com/")

# Weaviate is the primary vector store for memory (enabled by default). The test env may override.
config :noizu_prompt_lingua, :memory_weaviate,
  enabled: true,
  class: "NplMemory"

# Recall fusion / scoring knobs.
config :noizu_prompt_lingua, :memory_recall,
  vector_weights: %{content: 1.0, context: 0.8, tangent: 0.8, reflection: 0.7},
  blend: %{semantic: 0.40, emotional: 0.30, recency: 0.15, salience: 0.15},
  rrf_k: 60,
  candidates_per_path: 50,
  default_limit: 12

# Emotional 7-d vector construction.
config :noizu_prompt_lingua, :emotion,
  hormone_baseline: %{cortisol: 0.3, dopamine: 0.4, oxytocin: 0.4, serotonin: 0.5},
  vad_weight: 0.6,
  hormone_weight: 0.4

# Weaver association-linking thresholds/weights.
config :noizu_prompt_lingua, :weaver,
  emotional_resonance_min: 0.85,
  emotional_k: 8,
  temporal_window_s: 3600,
  max_edges_per_dim: 8,
  weights: %{emotional: 0.5, temporal: 0.4, contextual: 0.4, tangent: 0.6, semantic: 0.6}

# Reinforcement / decay dynamics.
config :noizu_prompt_lingua, :reinforcement,
  recall_memory_boost: 0.02,
  recall_edge_boost: 0.05,
  explicit_boost: 0.1,
  denforce_penalty: 0.05,
  hebbian_initial: 0.3,
  graph_max_hops: 3

# Feature flags
config :noizu_prompt_lingua, :feature_flags, %{
  email_verification: true,
  webhooks: false,
  file_uploads: false
}

# i18n
config :noizu_prompt_lingua, NoizuPromptLinguaWeb.Gettext, default_locale: "en"

import_config "#{config_env()}.exs"
