defmodule DocPointers.MCP.Tools.List do
  use Noizu.MCP.Server.Tool,
    name: "doc-pointer/list",
    description: "List all doc-pointers, optionally filtered by file path prefix or class.",
    annotations: [read_only_hint: true]

  input do
    field :file_prefix, :string,
      description: "Filter to pointers in files matching this prefix (e.g. lib/my_app/)"
    field :class, :string,
      description: "Filter to pointers belonging to this class/module"
    field :limit, :integer,
      description: "Maximum number of results (default 50, max 500)"
    field :offset, :integer,
      description: "Pagination offset (default 0)"
  end

  @impl true
  def call(args, _ctx) do
    limit = min(args[:limit] || 50, 500)
    offset = max(args[:offset] || 0, 0)

    {pointers, total} =
      DocPointers.Store.list(
        file_prefix: args[:file_prefix],
        class: args[:class],
        limit: limit,
        offset: offset
      )

    results =
      Enum.map(pointers, fn p ->
        %{
          uuid: p.uuid,
          token: p.token,
          marker: DocPointers.Hieroglyph.marker(p.token),
          file_path: p.file_path,
          class: p.class,
          function: p.function,
          description: p.description
        }
      end)

    {:ok, %{results: results, total: total, limit: limit, offset: offset}}
  end
end
