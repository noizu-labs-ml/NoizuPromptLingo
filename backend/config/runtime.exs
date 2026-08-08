import Config

if System.get_env("PHX_SERVER") do
  config :noizu_prompt_lingua, NoizuPromptLinguaWeb.Endpoint, server: true
end

config :noizu_prompt_lingua, :redis,
  uri: System.get_env("REDIS_URL") || "redis://localhost:6379/0",
  key_prefix: System.get_env("REDIS_KEY_PREFIX", "starter:")

# ── GenAI providers (Mock MCP inference) ─────────────────────────
# Keys flow through the dc/Infisical pipeline; only wire env names here.
if openai_key = System.get_env("OPENAI_API_KEY") do
  config :genai, :openai,
    api_key: openai_key,
    api_org: System.get_env("OPENAI_API_ORG")
end

if anthropic_key = System.get_env("ANTHROPIC_API_KEY") do
  config :genai, :anthropic, api_key: anthropic_key
end

# Additional chat providers (Mock MCP + asset-generation text models). Each genai
# provider reads its key from `config :genai, :<config_key>, api_key:` — the bare
# env vars are published to the pod via Infisical (/apps/npl-mcp, includeAllSecrets).
# Media/image providers (openai_image, gemini_image, suno, litellm media) instead
# read OPENAI_API_KEY / GEMINI_API_KEY / SUNO_API_KEY / LITELLM_API_KEY directly
# from env, so they need no config block here.
for {config_key, env} <- [
      deepseek: "DEEPSEEK_API_KEY",
      zai: "ZAI_API_KEY",
      cerebras: "CEREBRAS_API_KEY",
      xai: "XAI_API_KEY",
      groq: "GROQ_API_KEY",
      gemini: "GEMINI_API_KEY",
      mistral: "MISTRAL_API_KEY"
    ] do
  if key = System.get_env(env) do
    config :genai, config_key, api_key: key
  end
end

# LiteLLM proxy: deployment-specific base_url + master key (both from env/Infisical).
if litellm_key = System.get_env("LITELLM_API_KEY") do
  config :genai, :litellm,
    api_key: litellm_key,
    base_url: System.get_env("LITELLM_BASE_URL", "http://localhost:4000")
end

config :noizu_prompt_lingua, :mock_mcp,
  default_provider: System.get_env("MOCK_MCP_DEFAULT_PROVIDER", "openai"),
  default_model: System.get_env("MOCK_MCP_DEFAULT_MODEL", "gpt-4o-mini"),
  # Runtime-compiled tool modules (LLM-authored Elixir). Gated; AST-guarded +
  # timeout-bounded at execution (see MockMCP.ModuleRuntime). Disable with
  # MOCK_MCP_ALLOW_MODULES=false.
  allow_modules: System.get_env("MOCK_MCP_ALLOW_MODULES", "true") == "true",
  module_timeout_ms: String.to_integer(System.get_env("MOCK_MCP_MODULE_TIMEOUT_MS") || "10000")

# ── Memory engine: embeddings + Weaviate (all envs) ──────────────
# Keyword lists deep-merge with the config.exs defaults; these only override env-sourced values.
config :noizu_prompt_lingua, :embeddings,
  api_key: System.get_env("OPENAI_API_KEY"),
  api_base: System.get_env("OPENAI_API_BASE", "https://api.openai.com/v1"),
  model: System.get_env("EMBEDDING_MODEL", "text-embedding-3-small")

# noizu_weaviate api key (runtime). The endpoint is compile-time (see config.exs).
config :noizu_weaviate, weaviate_api_key: System.get_env("WEAVIATE_API_KEY")

config :noizu_prompt_lingua, :memory_weaviate,
  enabled: System.get_env("WEAVIATE_ENABLED") == "true",
  class: System.get_env("WEAVIATE_CLASS", "NplMemory")

# ── OpenTelemetry ────────────────────────────────────────────────
if otel_endpoint = System.get_env("OTEL_EXPORTER_OTLP_ENDPOINT") do
  config :opentelemetry_exporter,
    otlp_protocol: :grpc,
    otlp_endpoint: otel_endpoint

  config :opentelemetry,
    span_processor: :batch,
    resource: %{
      "service.name" => System.get_env("OTEL_SERVICE_NAME") || "starter-backend",
      "service.version" => "0.1.0"
    }
end

if config_env() == :prod or config_env() == :dev do
  # DATABASE_URL: required in prod; in dev, only override dev.exs defaults when
  # the env var is actually set (so `mix phx.server` uses the dev.exs connection
  # — tobor_locker@localhost:5432 — without needing DATABASE_URL).
  if database_url = System.get_env("DATABASE_URL") do
    config :noizu_prompt_lingua, NoizuPromptLingua.Repo,
      url: database_url,
      pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")
  else
    if config_env() == :prod do
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://user:pass@host/database
      """
    end
  end

  # Shared pm_core — always on; no legacy dual-path. Require URL in prod.
  if pm_url = System.get_env("PM_CORE_DATABASE_URL") do
    config :noizu_labs_pm, Noizu.PM.Repo,
      url: pm_url,
      pool_size: String.to_integer(System.get_env("PM_CORE_POOL_SIZE") || "5")
  else
    if config_env() == :prod do
      raise """
      environment variable PM_CORE_DATABASE_URL is missing.
      Shared PM data has no legacy mode. Set PM_CORE_DATABASE_URL to the pm_core database.
      """
    end
  end

  config :noizu_prompt_lingua, :pm_core, enabled: true

  secret_key_base =
    cond do
      env = System.get_env("SECRET_KEY_BASE") ->
        env

      config_env() == :prod ->
        raise """
        environment variable SECRET_KEY_BASE is missing.
        You can generate one by calling: mix phx.gen.secret
        """

      # Dev: fall back to a stable local key so `mix phx.server` boots without
      # env vars. SECRET_KEY_BASE above still wins when provided (e.g. Docker dev).
      true ->
        "dev-secret-key-base-not-for-production-must-be-at-least-64-bytes-long!!!"
    end

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :noizu_prompt_lingua, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  guardian_secret =
    cond do
      env = System.get_env("GUARDIAN_SECRET_KEY") ->
        env

      config_env() == :prod ->
        raise """
        environment variable GUARDIAN_SECRET_KEY is missing.
        You can generate one by calling: mix guardian.gen.secret
        """

      # Dev: fall back to a stable local secret so `mix phx.server` boots
      # without env vars. GUARDIAN_SECRET_KEY above still wins when provided.
      true ->
        "dev-guardian-secret-key-not-for-production-min-64-bytes-long-padding!!!"
    end

  config :noizu_prompt_lingua, NoizuPromptLingua.Guardian,
    issuer: "noizu_prompt_lingua",
    secret_key: guardian_secret

  # MCP JWT asymmetric signing (Phase 0). When unset, an ephemeral RSA key is
  # generated on first mint (dev/test). Production should set MCP_JWT_PRIVATE_KEY.
  require_aud =
    case System.get_env("MCP_JWT_REQUIRE_AUD") do
      v when v in ["true", "1"] -> true
      v when v in ["false", "0"] -> false
      _ -> false
    end

  config :noizu_prompt_lingua, :mcp_oauth,
    issuer: System.get_env("MCP_JWT_ISSUER") || "tobor-locker",
    issuer_url:
      System.get_env("MCP_ISSUER_URL") ||
        System.get_env("FRONTEND_URL") ||
        "https://#{host}",
    access_token_ttl_seconds:
      String.to_integer(System.get_env("MCP_JWT_TTL_SECONDS") || "#{7 * 24 * 3600}"),
    oauth_access_ttl_seconds:
      String.to_integer(System.get_env("MCP_OAUTH_ACCESS_TTL_SECONDS") || "3600"),
    require_aud: require_aud,
    signing_alg: System.get_env("MCP_JWT_ALG") || "RS256",
    public_scheme: System.get_env("MCP_PUBLIC_SCHEME") || "https",
    private_key_pem: System.get_env("MCP_JWT_PRIVATE_KEY"),
    kid: System.get_env("MCP_JWT_KID") || "mcp-1",
    resource_metadata_url: System.get_env("MCP_RESOURCE_METADATA_URL")

  mcp_pdp_mode =
    case System.get_env("MCP_PDP_MODE") do
      "spicedb" -> :spicedb
      "disabled" -> :disabled
      "local" -> :local
      _ -> :local
    end

  config :noizu_prompt_lingua, :mcp_pdp,
    mode: mcp_pdp_mode,
    spicedb_http_endpoint: System.get_env("SPICEDB_HTTP_ENDPOINT"),
    spicedb_preshared_key: System.get_env("SPICEDB_PRESHARED_KEY")

  # Phase 4: set MCP_API_KEY_MINT_ENABLED=false to retire API-key mint/create.
  mint_enabled =
    case System.get_env("MCP_API_KEY_MINT_ENABLED") do
      v when v in ["false", "0", "no"] -> false
      v when v in ["true", "1", "yes"] -> true
      _ -> true
    end

  config :noizu_prompt_lingua, :mcp_legacy_api_keys, mint_enabled: mint_enabled

  elev_enabled =
    case System.get_env("MCP_ELEVATION_ENABLED") do
      v when v in ["false", "0", "no"] -> false
      v when v in ["true", "1", "yes"] -> true
      _ -> true
    end

  config :noizu_prompt_lingua, :mcp_elevation, enabled: elev_enabled

  # Where the SPA lives. After OIDC the backend 302s the browser here; if this
  # is nil/empty the redirect becomes a relative path against the backend host,
  # and the browser lands on Phoenix for frontend routes like
  # /auth/sso-callback (→ NoRouteError). Default to the same host the backend
  # is served from so single-host deployments work without extra config.
  frontend_url =
    case System.get_env("FRONTEND_URL") do
      nil -> "https://#{host}"
      "" -> "https://#{host}"
      url -> url
    end

  config :noizu_prompt_lingua, :frontend_url, frontend_url

  if sendgrid_key = System.get_env("SENDGRID_API_KEY") do
    config :noizu_sendgrid, api_key: sendgrid_key
  end

  config :noizu_prompt_lingua,
         :mail_from,
         {System.get_env("MAIL_FROM_NAME", "NoizuPromptLingua"),
          System.get_env("MAIL_FROM_ADDRESS", "noreply@starter.local")}

  # ── Storage (S3/MinIO) ──────────────────────────────────────────
  if s3_bucket = System.get_env("S3_BUCKET") do
    config :noizu_prompt_lingua, NoizuPromptLingua.Storage,
      bucket: s3_bucket,
      region: System.get_env("S3_REGION", "us-east-1"),
      host: System.get_env("S3_ENDPOINT"),
      scheme: System.get_env("S3_SCHEME", "https://"),
      access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
      secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY")

    config :ex_aws,
      access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
      secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY"),
      region: System.get_env("S3_REGION", "us-east-1"),
      s3: [
        scheme: System.get_env("S3_SCHEME", "https://"),
        host: System.get_env("S3_ENDPOINT"),
        region: System.get_env("S3_REGION", "us-east-1")
      ]
  end

  # ── SSO: OIDC ──────────────────────────────────────────────────
  if oidc_client_id = System.get_env("OIDC_CLIENT_ID") do
    # openid_connect 1.0 takes an explicit config map (atom keys) at each call
    # site rather than a named provider registered in app env.
    config :noizu_prompt_lingua, :oidc_provider, %{
      discovery_document_uri:
        System.get_env("OIDC_ISSUER") <> "/.well-known/openid-configuration",
      client_id: oidc_client_id,
      client_secret: System.get_env("OIDC_CLIENT_SECRET"),
      redirect_uri: System.get_env("OIDC_REDIRECT_URI") || "https://#{host}/auth/oidc/callback",
      response_type: "code",
      scope: "openid email profile"
    }

    config :noizu_prompt_lingua, :oidc_enabled, true
  end

  # ── SSO: SAML ──────────────────────────────────────────────────
  if saml_metadata = System.get_env("SAML_IDP_METADATA_URL") do
    sp_cert = System.get_env("SAML_SP_CERT", "") |> String.replace("\\n", "\n")
    sp_key = System.get_env("SAML_SP_KEY", "") |> String.replace("\\n", "\n")

    config :samly, Samly.Provider,
      idp: [
        %{
          id: "default",
          sp_id: "default",
          base_url: "https://#{host}/sso/saml",
          metadata_url: saml_metadata
        }
      ],
      sp: [
        %{
          id: "default",
          entity_id: System.get_env("SAML_SP_ENTITY_ID") || "https://#{host}",
          certfile_data: sp_cert,
          keyfile_data: sp_key
        }
      ]

    config :noizu_prompt_lingua, :saml_enabled, true
  end

  # ── SSO: Social OAuth (each enabled when *_CLIENT_ID is set) ──
  config :noizu_prompt_lingua, :sso_require_invite, System.get_env("SSO_REQUIRE_INVITE") == "true"

  oauth_providers = []

  oauth_providers =
    if google_id = System.get_env("GOOGLE_CLIENT_ID") do
      config :ueberauth, Ueberauth.Strategy.Google.OAuth,
        client_id: google_id,
        client_secret: System.get_env("GOOGLE_CLIENT_SECRET")

      config :noizu_prompt_lingua, :google_enabled, true
      [{:google, {Ueberauth.Strategy.Google, [default_scope: "email profile"]}} | oauth_providers]
    else
      oauth_providers
    end

  oauth_providers =
    if fb_id = System.get_env("FACEBOOK_CLIENT_ID") do
      config :ueberauth, Ueberauth.Strategy.Facebook.OAuth,
        client_id: fb_id,
        client_secret: System.get_env("FACEBOOK_CLIENT_SECRET")

      config :noizu_prompt_lingua, :facebook_enabled, true

      [
        {:facebook, {Ueberauth.Strategy.Facebook, [default_scope: "email,public_profile"]}}
        | oauth_providers
      ]
    else
      oauth_providers
    end

  oauth_providers =
    if gh_id = System.get_env("GITHUB_CLIENT_ID") do
      config :ueberauth, Ueberauth.Strategy.Github.OAuth,
        client_id: gh_id,
        client_secret: System.get_env("GITHUB_CLIENT_SECRET")

      config :noizu_prompt_lingua, :github_enabled, true
      [{:github, {Ueberauth.Strategy.Github, [default_scope: "user:email"]}} | oauth_providers]
    else
      oauth_providers
    end

  # LinkedIn SSO disabled — ueberauth_linkedin has incompatible oauth2 dep
  # oauth_providers =
  #   if li_id = System.get_env("LINKEDIN_CLIENT_ID") do
  #     config :ueberauth, Ueberauth.Strategy.LinkedIn.OAuth,
  #       client_id: li_id,
  #       client_secret: System.get_env("LINKEDIN_CLIENT_SECRET")
  #     config :noizu_prompt_lingua, :linkedin_enabled, true
  #     [{:linkedin, {Ueberauth.Strategy.LinkedIn, [default_scope: "r_liteprofile r_emailaddress"]}} | oauth_providers]
  #   else
  #     oauth_providers
  #   end

  if oauth_providers != [] do
    config :ueberauth, Ueberauth, providers: oauth_providers
  end

  config :noizu_prompt_lingua, NoizuPromptLinguaWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base
end
