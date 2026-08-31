defmodule DocPointers.MCP.Tools.Generate do
  use Noizu.MCP.Server.Tool,
    name: "doc-pointer/generate",
    description: """
    Generate a new doc-pointer hieroglyphic code for a source location.
    Returns the full UUID, 4-character hieroglyph token, and writes metadata to .meta/pointers.yaml.
    """,
    annotations: [destructive_hint: true]

  input do
    field(:file_path, :string,
      required: true,
      description: "Relative path to the source file (e.g. lib/my_module.ex)"
    )

    field(:function_name, :string,
      required: true,
      description: "Function or method name"
    )

    field(:description, :string,
      required: true,
      description: "Human-readable description of what this code location does"
    )

    field(:class, :string, description: "Module or class name (e.g. MyApp.Auth)")
    field(:line, :integer, description: "Line number in the source file")
    field(:salt, :string, description: "Optional deterministic salt for UUID derivation")

    field(:name_override, :string,
      description: "Override the auto-derived name (default: file_path::function_name)"
    )

    field(:confirm, :boolean,
      description: "Required true unless the server was started with --write"
    )
  end

  @max_attempts 10_000

  @impl true
  def call(args, ctx) do
    with :ok <- DocPointers.MCP.Writes.authorize(args, ctx) do
      do_call(args)
    end
  end

  defp do_call(args) do
    base_name =
      args[:name_override] ||
        DocPointers.UUID5.build_annotation_name(args.file_path, args.function_name)

    case generate_with_collision_check(base_name, args[:salt], 0) do
      {:ok, uuid_string, token} ->
        pointer =
          DocPointers.Pointer.new(%{
            uuid: uuid_string,
            token: token,
            file_path: args.file_path,
            class: args[:class],
            function: args.function_name,
            line: args[:line],
            description: args.description
          })

        DocPointers.Store.put(pointer)

        {:ok,
         %{
           uuid: uuid_string,
           token: token,
           marker: DocPointers.Hieroglyph.marker(token),
           declaration:
             DocPointers.Hieroglyph.declaration(token, args.function_name, args.description),
           file_path: args.file_path,
           function: args.function_name,
           class: args[:class]
         }}

      {:error, :max_attempts} ->
        {:error, "Failed to generate a unique token after #{@max_attempts} attempts"}
    end
  end

  defp generate_with_collision_check(_base_name, _salt, attempt) when attempt >= @max_attempts do
    {:error, :max_attempts}
  end

  defp generate_with_collision_check(base_name, salt, attempt) do
    name = DocPointers.UUID5.build_name(base_name, salt, attempt)
    uuid_bytes = DocPointers.UUID5.generate(name)
    uuid_string = DocPointers.UUID5.to_string(uuid_bytes)
    token = DocPointers.Hieroglyph.encode(uuid_bytes)

    if DocPointers.Store.token_exists?(token) do
      generate_with_collision_check(base_name, salt, attempt + 1)
    else
      {:ok, uuid_string, token}
    end
  end
end
