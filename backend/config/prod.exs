import Config

config :logger, level: :info

# Structured JSON logging in production
config :logger, :default_handler,
  formatter: {LoggerJSON.Formatters.Basic, metadata: [:request_id, :trace_id, :span_id]}
