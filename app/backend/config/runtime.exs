import Config

if System.get_env("PHX_SERVER") in ["true", "1"] do
  config :codefresh, CodefreshWeb.Endpoint, server: true
end

# OpenTelemetry — only enable OTLP exporter when endpoint is explicitly configured
case System.get_env("OTLP_ENDPOINT") do
  nil ->
    config :opentelemetry, traces_exporter: :none

  endpoint ->
    config :opentelemetry, traces_exporter: :otlp

    config :opentelemetry_exporter,
      otlp_protocol: :http_protobuf,
      otlp_endpoint: endpoint
end

if config_env() == :prod do
  config :codefresh, Codefresh.Repo,
    hostname: System.fetch_env!("DB_HOST"),
    port: String.to_integer(System.get_env("DB_PORT") || "5432"),
    username: System.fetch_env!("DB_USER"),
    password: System.fetch_env!("DB_PASSWORD"),
    database: System.fetch_env!("DB_NAME"),
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :codefresh, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  guardian_secret =
    System.get_env("GUARDIAN_SECRET_KEY") ||
      raise """
      environment variable GUARDIAN_SECRET_KEY is missing.
      You can generate one by calling: mix guardian.gen.secret
      """

  config :codefresh, Codefresh.Guardian,
    issuer: "codefresh",
    secret_key: guardian_secret

  config :codefresh, CodefreshWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base
end
