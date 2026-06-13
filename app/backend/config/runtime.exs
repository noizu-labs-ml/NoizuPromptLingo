import Config

if System.get_env("PHX_SERVER") do
  config :derobot, DerobotWeb.Endpoint, server: true
end

if config_env() == :prod do
  required_env = fn name, message ->
    case System.get_env(name) do
      value when is_binary(value) and value != "" ->
        value

      _ ->
        raise """
        environment variable #{name} is missing.
        #{message}
        """
    end
  end

  database_config =
    case System.get_env("DATABASE_URL") do
      value when is_binary(value) and value != "" ->
        [url: value]

      _ ->
        missing_db_env_message =
          "Set DATABASE_URL or DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, and DB_NAME."

        [
          hostname: required_env.("DB_HOST", missing_db_env_message),
          port: String.to_integer(System.get_env("DB_PORT") || "5432"),
          username: required_env.("DB_USER", missing_db_env_message),
          password: required_env.("DB_PASSWORD", missing_db_env_message),
          database: required_env.("DB_NAME", missing_db_env_message)
        ]
    end

  repo_config =
    Keyword.put(database_config, :pool_size, String.to_integer(System.get_env("POOL_SIZE") || "10"))

  config :derobot, Derobot.Repo, repo_config

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :derobot, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  guardian_secret =
    System.get_env("GUARDIAN_SECRET_KEY") ||
      raise """
      environment variable GUARDIAN_SECRET_KEY is missing.
      You can generate one by calling: mix guardian.gen.secret
      """

  config :derobot, Derobot.Guardian,
    issuer: "derobot",
    secret_key: guardian_secret

  config :derobot, DerobotWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  if redis_url = System.get_env("REDIS_URL") do
    config :derobot, :redis, uri: redis_url, key_prefix: "derobot:"
  end

  if frontend_url = System.get_env("FRONTEND_URL") do
    config :derobot, :frontend_url, frontend_url
  end

  # -- SSO: OIDC --------------------------------------------------------------
  if oidc_client_id = System.get_env("OIDC_CLIENT_ID") do
    oidc_issuer =
      "OIDC_ISSUER"
      |> required_env.("Set OIDC_ISSUER when OIDC_CLIENT_ID is configured.")
      |> String.trim_trailing("/")

    config :openid_connect, :providers,
      default: [
        discovery_document_uri: "#{oidc_issuer}/.well-known/openid-configuration",
        client_id: oidc_client_id,
        client_secret:
          required_env.(
            "OIDC_CLIENT_SECRET",
            "Set OIDC_CLIENT_SECRET when OIDC_CLIENT_ID is configured."
          ),
        redirect_uri: System.get_env("OIDC_REDIRECT_URI") || "https://#{host}/auth/oidc/callback",
        response_type: "code",
        scope: "openid email profile"
      ]
    config :derobot, :oidc_enabled, true
  end

  # -- SSO: SAML ---------------------------------------------------------------
  if saml_metadata = System.get_env("SAML_IDP_METADATA_URL") do
    sp_cert = System.get_env("SAML_SP_CERT", "") |> String.replace("\\n", "\n")
    sp_key = System.get_env("SAML_SP_KEY", "") |> String.replace("\\n", "\n")

    config :samly, Samly.Provider,
      idp: [%{id: "default", sp_id: "default", base_url: "https://#{host}/sso/saml", metadata_url: saml_metadata}],
      sp: [%{id: "default", entity_id: System.get_env("SAML_SP_ENTITY_ID") || "https://#{host}", certfile_data: sp_cert, keyfile_data: sp_key}]
    config :derobot, :saml_enabled, true
  end

  # -- SSO: Social OAuth -------------------------------------------------------
  config :derobot, :sso_require_invite, System.get_env("SSO_REQUIRE_INVITE") == "true"

  oauth_providers = []

  oauth_providers =
    if google_id = System.get_env("GOOGLE_CLIENT_ID") do
      config :ueberauth, Ueberauth.Strategy.Google.OAuth,
        client_id: google_id,
        client_secret: System.get_env("GOOGLE_CLIENT_SECRET")
      config :derobot, :google_enabled, true
      [{:google, {Ueberauth.Strategy.Google, [default_scope: "email profile"]}} | oauth_providers]
    else
      oauth_providers
    end

  oauth_providers =
    if github_id = System.get_env("GITHUB_CLIENT_ID") do
      config :ueberauth, Ueberauth.Strategy.Github.OAuth,
        client_id: github_id,
        client_secret: System.get_env("GITHUB_CLIENT_SECRET")
      config :derobot, :github_enabled, true
      [{:github, {Ueberauth.Strategy.Github, [default_scope: "user:email"]}} | oauth_providers]
    else
      oauth_providers
    end

  if oauth_providers != [] do
    config :ueberauth, Ueberauth, providers: oauth_providers
  end
end
