import Config

# In test, do not attach stdio MCP (stdin closes under mix test).
config :noizu_google_mcp, start_stdio: config_env() != :test
