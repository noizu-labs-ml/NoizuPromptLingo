defmodule NoDslServer.MCP do
  @moduledoc """
  An MCP server built without any DSL macros — every callback of the
  `Noizu.MCP.Server` behaviour is implemented by hand.

  Implementing a `handle_*` callback is what flips the corresponding server
  capability: `handle_list_tools/2` + `handle_call_tool/3` advertise `tools`,
  `handle_list_resources/2` + `handle_read_resource/2` advertise `resources`.

  Behaviour-level handlers receive **string-keyed, unvalidated** arguments —
  the validation/casting layer belongs to the component DSL. Validate by hand
  (or trust your schemas) and return `{:error, "message"}` for execution
  errors the model can self-correct from.
  """

  use Noizu.MCP.Server,
    name: "no_dsl",
    version: "0.1.0",
    instructions:
      "Hand-rolled demo server. `upcase` shouts text, `add` sums two numbers, " <>
        "and readme://about explains why this example exists."

  alias Noizu.MCP.Error
  alias Noizu.MCP.Types.{Resource, ResourceContents, Tool}

  @about_uri "readme://about"

  @about_text """
  # no_dsl server

  This MCP server is implemented with plain behaviour callbacks instead of the
  `tool`/`resource` DSL macros. The tool list below is an ordinary Elixir term,
  so it could just as easily be built at runtime — from a database, a config
  file, or another service.
  """

  # Tool definitions are plain `%Noizu.MCP.Types.Tool{}` structs with
  # hand-written JSON-Schema input/output maps. Nothing here is compile-time
  # magic — swap this attribute for a function and the list becomes dynamic.
  @tools [
    %Tool{
      name: "upcase",
      description: "Uppercase the given text.",
      input_schema: %{
        "type" => "object",
        "properties" => %{
          "text" => %{"type" => "string", "description" => "Text to uppercase"}
        },
        "required" => ["text"]
      },
      annotations: [read_only_hint: true, idempotent_hint: true]
    },
    %Tool{
      name: "add",
      description: "Add two numbers and return the sum as structured content.",
      input_schema: %{
        "type" => "object",
        "properties" => %{
          "a" => %{"type" => "number", "description" => "First addend"},
          "b" => %{"type" => "number", "description" => "Second addend"}
        },
        "required" => ["a", "b"]
      },
      output_schema: %{
        "type" => "object",
        "properties" => %{"sum" => %{"type" => "number"}},
        "required" => ["sum"]
      },
      annotations: [read_only_hint: true, idempotent_hint: true]
    }
  ]

  # ── tools ─────────────────────────────────────────────────────────────────

  @impl Noizu.MCP.Server
  def handle_list_tools(_cursor, _ctx) do
    {:ok, @tools, nil}
  end

  @impl Noizu.MCP.Server
  def handle_call_tool("upcase", %{"text" => text}, _ctx) when is_binary(text) do
    # {:ok, binary} produces a single text content block.
    {:ok, String.upcase(text)}
  end

  def handle_call_tool("add", %{"a" => a, "b" => b}, _ctx)
      when is_number(a) and is_number(b) do
    # {:ok, map} produces structuredContent (validated against output_schema
    # when one is registered via the DSL; here it is simply serialized).
    {:ok, %{"sum" => a + b}}
  end

  def handle_call_tool(name, _args, _ctx) when name in ["upcase", "add"] do
    # Arguments arrive unvalidated at the behaviour level — return an
    # execution error (isError: true) the model can self-correct from.
    {:error, "Invalid arguments for tool #{name}; check the inputSchema."}
  end

  def handle_call_tool(name, _args, _ctx) do
    {:error, Error.invalid_params("Unknown tool: #{name}")}
  end

  # ── resources ─────────────────────────────────────────────────────────────

  @impl Noizu.MCP.Server
  def handle_list_resources(_cursor, _ctx) do
    resources = [
      %Resource{
        uri: @about_uri,
        name: "About",
        description: "Why this example skips the DSL",
        mime_type: "text/markdown"
      }
    ]

    {:ok, resources, nil}
  end

  @impl Noizu.MCP.Server
  def handle_read_resource(@about_uri, _ctx) do
    {:ok, ResourceContents.text(@about_uri, @about_text, mime_type: "text/markdown")}
  end

  def handle_read_resource(uri, _ctx) do
    {:error, Error.resource_not_found(uri)}
  end
end
