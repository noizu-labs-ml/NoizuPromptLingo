defmodule DropboxMCP do
  @moduledoc """
  Dropbox filesystem MCP server built on `Noizu.MCP` and `Noizu.Dropbox`.

  ## Configure

      export DROPBOX_ACCESS_TOKEN=sl.xxx

      # config/runtime.exs
      config :noizu_dropbox,
        access_token: System.get_env("DROPBOX_ACCESS_TOKEN")

  ## Run (stdio)

      cd /absolute/path/to/dropbox-mcp
      mix deps.get
      mix run --no-halt

  Default grant is read-only. Set `DROPBOX_MCP_WRITES=1` to enable mutations.
  Optional path jail: `DROPBOX_MCP_ROOT=/folder` (or config `:default_root`).

  See README for Claude Code, Desktop, Codex, Cursor, VS Code, and Grok install.

  ## Tools

  See `DropboxMCP.Tools.Filesystem` — list/read/write/mkdir/move/copy/delete/search/share/account.
  """

  defdelegate client(), to: DropboxMCP.Client, as: :get
end
