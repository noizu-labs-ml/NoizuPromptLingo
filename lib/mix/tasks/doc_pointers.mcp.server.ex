defmodule Mix.Tasks.DocPointers.Mcp.Server do
  @shortdoc "Run the doc-pointers MCP server over loopback HTTP"
  @moduledoc """
  Starts the doc-pointers MCP server on Streamable HTTP bound to 127.0.0.1.

  Prefer `mix doc_pointers.mcp.stdio` for local MCP clients.

  ## Usage

      mix doc_pointers.mcp.server
      mix doc_pointers.mcp.server --port 4242 --root /path/to/project
      mix doc_pointers.mcp.server --write

  ## Options

    * `--port` - HTTP port (default 4242, or DOC_POINTERS_PORT env)
    * `--root` - Project root for .meta/ storage (default DOC_POINTERS_ROOT env or cwd)
    * `--write` - List and allow generate/update without `confirm=true`
      (or set DOC_POINTERS_MCP_WRITES=1)

  The listener is loopback-only (`127.0.0.1`). There is no auth.
  """
  use Mix.Task

  @requirements ["app.start"]

  @impl Mix.Task
  def run(args) do
    opts = DocPointers.MCP.Runtime.parse(args)
    DocPointers.MCP.Runtime.configure!(opts)
    port = DocPointers.MCP.Runtime.port(opts)
    DocPointers.MCP.Runtime.start_http!(port)

    Mix.shell().info("doc-pointers MCP (loopback HTTP) → http://127.0.0.1:#{port}/mcp")
    Mix.shell().info("Prefer stdio for local clients: mix doc_pointers.mcp.stdio")
    Process.sleep(:infinity)
  end
end
