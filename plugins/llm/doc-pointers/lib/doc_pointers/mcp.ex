defmodule DocPointers.MCP do
  use Noizu.MCP.Server,
    name: "doc_pointers",
    version: "0.1.0",
    instructions: """
    Generate and manage doc-pointer hieroglyphic codes. Doc pointers are durable,
    code-stable cross-document references using UUIDv5-derived 4-character hieroglyphic
    tokens from Egyptian, Meroitic, and Anatolian Unicode blocks.

    Default tools are read-only: doc-pointer/lookup and doc-pointer/list.
    doc-pointer/generate and doc-pointer/update persist to .meta/pointers.yaml.
    They are listed when the server is started with --write (or DOC_POINTERS_MCP_WRITES=1);
    otherwise they require confirm=true (or a client confirmation prompt).

    All pointers are stored in .meta/pointers.yaml at the project root, keyed by full UUID.
    """

  tool(DocPointers.MCP.Tools.Lookup, category: "Pointers")
  tool(DocPointers.MCP.Tools.List, category: "Pointers")
  tool(DocPointers.MCP.Tools.Generate, category: "Pointers", hidden: true)
  tool(DocPointers.MCP.Tools.Update, category: "Pointers", hidden: true)

  @impl true
  def handle_list_tools(cursor, _ctx) do
    Noizu.MCP.Server.Features.Tools.list_registered(
      __mcp__(:tools),
      cursor,
      include_hidden: DocPointers.MCP.Writes.enabled?()
    )
  end
end
