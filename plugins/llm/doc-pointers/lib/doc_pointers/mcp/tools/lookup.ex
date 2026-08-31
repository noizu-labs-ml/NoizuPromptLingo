defmodule DocPointers.MCP.Tools.Lookup do
  use Noizu.MCP.Server.Tool,
    name: "doc-pointer/lookup",
    description: "Look up a doc-pointer by token, UUID, file path, or function name.",
    annotations: [read_only_hint: true]

  input do
    field :token, :string,
      description: "4-character hieroglyph token (e.g. 𓳔𔐮𔘟𔄵)"
    field :uuid, :string,
      description: "Full UUID string"
    field :file_path, :string,
      description: "Source file path to find pointers in"
    field :function_name, :string,
      description: "Function name to search for"
  end

  @impl true
  def call(args, _ctx) do
    cond do
      args[:uuid] ->
        case DocPointers.Store.get(args.uuid) do
          nil -> {:ok, %{results: [], count: 0}}
          p -> {:ok, %{results: [pointer_to_map(p)], count: 1}}
        end

      args[:token] ->
        case DocPointers.Store.get_by_token(args.token) do
          nil -> {:ok, %{results: [], count: 0}}
          p -> {:ok, %{results: [pointer_to_map(p)], count: 1}}
        end

      args[:file_path] || args[:function_name] ->
        all = DocPointers.Store.all()

        results =
          all
          |> maybe_filter(:file_path, args[:file_path])
          |> maybe_filter(:function, args[:function_name])
          |> Enum.map(&pointer_to_map/1)

        {:ok, %{results: results, count: length(results)}}

      true ->
        {:error, "At least one search field (token, uuid, file_path, function_name) is required"}
    end
  end

  defp maybe_filter(pointers, _field, nil), do: pointers

  defp maybe_filter(pointers, field, value) do
    Enum.filter(pointers, fn p -> Map.get(p, field) == value end)
  end

  defp pointer_to_map(%DocPointers.Pointer{} = p) do
    %{
      uuid: p.uuid,
      token: p.token,
      marker: DocPointers.Hieroglyph.marker(p.token),
      file_path: p.file_path,
      class: p.class,
      function: p.function,
      line: p.line,
      description: p.description,
      created_at: p.created_at,
      updated_at: p.updated_at
    }
  end
end
