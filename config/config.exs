import Config

config :noizu_dropbox,
  access_token: System.get_env("DROPBOX_ACCESS_TOKEN"),
  refresh_token: System.get_env("DROPBOX_REFRESH_TOKEN"),
  app_key: System.get_env("DROPBOX_APP_KEY"),
  app_secret: System.get_env("DROPBOX_APP_SECRET")

config :dropbox_mcp,
  # When true, Application starts MCP over stdio (default for MCP hosts).
  start_stdio: true,
  # Optional default root / path jail. Empty path maps here; other paths must
  # stay under this prefix. Override at runtime with DROPBOX_MCP_ROOT.
  default_root: "",
  # Mutating tools are off unless DROPBOX_MCP_WRITES=1 (or writes: true).
  writes: false,
  # Max bytes returned as text from read_file (larger files get a note).
  max_text_bytes: 1_000_000

import_config "#{config_env()}.exs"
