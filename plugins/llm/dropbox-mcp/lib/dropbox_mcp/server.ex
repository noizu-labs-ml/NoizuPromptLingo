defmodule DropboxMCP.Server do
  @moduledoc """
  MCP server: Dropbox filesystem tools and `dropbox://` resources.

  Start over stdio (default Application child):

      {DropboxMCP.Server, transport: :stdio}

  Or test in-process with `Noizu.MCP.Test.connect(DropboxMCP.Server)`.
  """

  use Noizu.MCP.Server,
    name: "dropbox",
    version: "0.1.0",
    instructions: """
    Dropbox filesystem MCP. Paths use Dropbox conventions: empty string or /
    is the account root; other paths are absolute (e.g. /Documents/notes.md).
    When DROPBOX_MCP_ROOT (or config :default_root) is set, all tool paths are
    jailed under that prefix.

    Default grant is read-only. Mutating tools (write_file, mkdir, move, copy,
    delete, create_shared_link) require DROPBOX_MCP_WRITES=1. dropbox_delete
    also requires confirm=true.

    Prefer dropbox_list_folder to explore, dropbox_read_file for content, and
    dropbox_search for queries.
    """

  tool(DropboxMCP.Tools.Filesystem)
  resource_template(DropboxMCP.Resources.Path)
end
