defmodule Mix.Tasks.DocPointers.Mcp.Stdio do
  @shortdoc "Run the doc-pointers MCP server over stdio"
  @moduledoc """
  Starts the doc-pointers MCP server on stdin/stdout (preferred local transport).

      mix doc_pointers.mcp.stdio
      mix doc_pointers.mcp.stdio --root /path/to/project
      mix doc_pointers.mcp.stdio --write --root /path/to/project

  ## Options

    * `--root` - Project root for .meta/ storage (default DOC_POINTERS_ROOT env or cwd)
    * `--write` - List and allow generate/update without `confirm=true`
      (or set DOC_POINTERS_MCP_WRITES=1)

  Default tools: `doc-pointer/lookup`, `doc-pointer/list`. Do not write to stdout —
  it is the JSON-RPC stream.

  ## Client registration

      claude mcp add doc-pointers -- mix doc_pointers.mcp.stdio
  """
  use Mix.Task

  @requirements ["app.start"]

  @impl Mix.Task
  def run(args) do
    opts = DocPointers.MCP.Runtime.parse(args)
    DocPointers.MCP.Runtime.configure!(opts)
    DocPointers.MCP.Runtime.start_stdio!()
    Process.sleep(:infinity)
  end
end
