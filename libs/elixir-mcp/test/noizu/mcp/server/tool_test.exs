defmodule Noizu.MCP.Server.ToolTest do
  use ExUnit.Case, async: true

  alias Noizu.MCP.Server.Tool.Fields
  alias Noizu.MCP.Fixtures

  describe "definition/0" do
    test "compiles the input field DSL to JSON Schema" do
      definition = Fixtures.Echo.definition()

      assert definition.name == "echo"
      assert definition.description == "Echo a message back"

      assert definition.input_schema == %{
               "type" => "object",
               "properties" => %{
                 "message" => %{"type" => "string", "description" => "Message to echo"},
                 "repeat" => %{
                   "type" => "integer",
                   "minimum" => 1,
                   "maximum" => 10,
                   "default" => 1
                 },
                 "mode" => %{
                   "type" => "string",
                   "enum" => ["plain", "loud"],
                   "default" => "plain"
                 }
               },
               "required" => ["message"]
             }
    end

    test "wire map renders annotations camelCased" do
      map = Noizu.MCP.Types.Tool.to_map(Fixtures.Echo.definition())
      assert map["annotations"] == %{"readOnlyHint" => true}
      assert map["inputSchema"]["required"] == ["message"]
    end

    test "output schema is captured" do
      definition = Fixtures.Weather.definition()
      assert definition.output_schema["required"] == ["temperature", "conditions"]
    end

    test "default name derives from module basename" do
      assert Fixtures.Crash.definition().name == "crash"
    end

    test "raw input_schema escape hatch" do
      definition = Fixtures.RawSchema.definition()
      assert definition.input_schema["required"] == ["query"]
      assert [%{cast_plan: nil}] = Fixtures.RawSchema.__mcp_tools__()
    end
  end

  describe "__mcp_tools__/0" do
    test "classic tool modules export a one-element spec list" do
      assert [%Noizu.MCP.Server.Tool.Spec{} = spec] = Fixtures.Echo.__mcp_tools__()
      assert spec.module == Fixtures.Echo
      assert spec.fun == :call
      assert spec.arity == 2
      assert spec.definition == Fixtures.Echo.definition()
      assert spec.hidden == false
      assert is_list(spec.cast_plan)
    end

    test "output schema is carried on the spec" do
      assert [spec] = Fixtures.Weather.__mcp_tools__()
      assert spec.output_schema["required"] == ["temperature", "conditions"]
    end
  end

  describe "cast plan" do
    test "atomizes declared keys, applies defaults, casts enums" do
      [%{cast_plan: plan}] = Fixtures.Echo.__mcp_tools__()

      assert Fields.cast(plan, %{"message" => "hi"}) == %{
               message: "hi",
               repeat: 1,
               mode: :plain
             }

      assert Fields.cast(plan, %{"message" => "hi", "mode" => "loud", "repeat" => 2}) == %{
               message: "hi",
               repeat: 2,
               mode: :loud
             }
    end

    test "undeclared keys are dropped, never atomized" do
      [%{cast_plan: plan}] = Fixtures.Echo.__mcp_tools__()
      cast = Fields.cast(plan, %{"message" => "hi", "__proto__" => "evil"})
      refute Map.has_key?(cast, :__proto__)
      refute Map.has_key?(cast, "__proto__")
    end
  end

  describe "nested fields" do
    defmodule Nested do
      use Noizu.MCP.Server.Tool, description: "nested"

      input do
        field :filters, :object, description: "Search filters" do
          field :status, :enum, values: [:open, :closed], default: :open
          field :tags, {:array, :string}
        end

        field :rows, {:array, :object}, required: true do
          field :id, :integer, required: true
        end
      end

      @impl true
      def call(args, _ctx), do: {:ok, inspect(args)}
    end

    test "object and array-of-object schemas" do
      schema = Nested.definition().input_schema

      assert schema["properties"]["filters"]["type"] == "object"
      assert schema["properties"]["filters"]["description"] == "Search filters"

      assert schema["properties"]["filters"]["properties"]["status"]["enum"] == [
               "open",
               "closed"
             ]

      assert schema["properties"]["filters"]["properties"]["tags"] == %{
               "type" => "array",
               "items" => %{"type" => "string"}
             }

      assert schema["properties"]["rows"]["items"]["required"] == ["id"]
      assert schema["required"] == ["rows"]
    end

    test "nested cast" do
      [%{cast_plan: plan}] = Nested.__mcp_tools__()

      cast =
        Fields.cast(plan, %{
          "filters" => %{"status" => "closed", "tags" => ["a"]},
          "rows" => [%{"id" => 1}, %{"id" => 2}]
        })

      assert cast == %{
               filters: %{status: :closed, tags: ["a"]},
               rows: [%{id: 1}, %{id: 2}]
             }
    end
  end

  describe "Fields.from_spec/1" do
    defmodule SpecEquivalent do
      use Noizu.MCP.Server.Tool, description: "DSL twin of the data-form spec"

      input do
        field :message, :string, required: true, description: "Message to echo"
        field :repeat, :integer, min: 1, max: 10, default: 1
        field :mode, :enum, values: [:plain, :loud], default: :plain

        field :address, :object, required: true do
          field :street, :string
        end

        field :tags, {:array, :string}

        field :rows, {:array, :object} do
          field :id, :integer
        end

        field :note, :string
      end

      @impl true
      def call(args, _ctx), do: {:ok, inspect(args)}
    end

    @spec_form [
      message: [type: :string, required: true, description: "Message to echo"],
      repeat: [type: :integer, min: 1, max: 10, default: 1],
      mode: [type: :enum, values: [:plain, :loud], default: :plain],
      address: [type: :object, required: true, fields: [street: [type: :string]]],
      tags: [type: {:array, :string}],
      rows: [type: {:array, :object}, fields: [id: [type: :integer]]],
      note: :string
    ]

    test "produces the same JSON Schema as the field DSL" do
      schema = @spec_form |> Fields.from_spec() |> Fields.to_json_schema()
      assert schema == SpecEquivalent.definition().input_schema
    end

    test "produces the same cast plan as the field DSL" do
      plan = @spec_form |> Fields.from_spec() |> Fields.to_cast_plan()
      [%{cast_plan: dsl_plan}] = SpecEquivalent.__mcp_tools__()
      assert plan == dsl_plan
    end

    test "empty spec yields an empty object schema" do
      assert Fields.from_spec([]) |> Fields.to_json_schema() ==
               %{"type" => "object", "properties" => %{}}
    end

    test "shorthand array type" do
      schema = Fields.from_spec(tags: {:array, :string}) |> Fields.to_json_schema()

      assert schema["properties"]["tags"] == %{
               "type" => "array",
               "items" => %{"type" => "string"}
             }
    end

    test "invalid specs raise ArgumentError" do
      assert_raise ArgumentError, ~r/:enum requires values/, fn ->
        Fields.from_spec(mode: [type: :enum])
      end

      assert_raise ArgumentError, ~r/:object requires nested fields/, fn ->
        Fields.from_spec(a: [type: :object])
      end

      assert_raise ArgumentError, ~r/requires nested fields/, fn ->
        Fields.from_spec(a: [type: {:array, :object}])
      end

      assert_raise ArgumentError, ~r/unknown type/, fn ->
        Fields.from_spec(a: :wat)
      end

      assert_raise ArgumentError, ~r/requires a :type/, fn ->
        Fields.from_spec(a: [required: true])
      end

      assert_raise ArgumentError, ~r/must be a keyword list/, fn ->
        Fields.from_spec(%{a: :string})
      end
    end
  end

  describe "JSON-text schemas" do
    defmodule JsonTextTool do
      use Noizu.MCP.Server.Tool, description: "schema from raw JSON text"

      input_schema """
      {"type": "object", "properties": {"q": {"type": "string"}}, "required": ["q"]}
      """

      output_schema """
      {"type": "object", "properties": {"echo": {"type": "string"}}, "required": ["echo"]}
      """

      @impl true
      def call(%{"q" => q}, _ctx), do: {:ok, %{"echo" => q}}
    end

    test "input_schema/output_schema accept raw JSON text" do
      definition = JsonTextTool.definition()
      assert definition.input_schema["required"] == ["q"]
      assert definition.output_schema["required"] == ["echo"]

      assert [%{cast_plan: nil} = spec] = JsonTextTool.__mcp_tools__()
      assert spec.output_schema["required"] == ["echo"]
    end

    test "malformed JSON is a compile-time error naming the module" do
      assert_raise ArgumentError, ~r/invalid JSON schema text/, fn ->
        Code.compile_string("""
        defmodule Noizu.MCP.ToolTestBadJson#{System.unique_integer([:positive])} do
          use Noizu.MCP.Server.Tool, description: "bad"

          input_schema "{nope"

          @impl true
          def call(_args, _ctx), do: {:ok, "x"}
        end
        """)
      end
    end

    test "JSON text that is not an object is a compile-time error" do
      assert_raise ArgumentError, ~r/must decode to an object/, fn ->
        Code.compile_string("""
        defmodule Noizu.MCP.ToolTestJsonArray#{System.unique_integer([:positive])} do
          use Noizu.MCP.Server.Tool, description: "bad"

          input_schema "[1, 2]"

          @impl true
          def call(_args, _ctx), do: {:ok, "x"}
        end
        """)
      end
    end
  end

  describe "category" do
    defmodule Categorized do
      use Noizu.MCP.Server.Tool,
        description: "categorized",
        category: "Utility",
        meta: %{"k" => "v"}

      @impl true
      def call(_args, _ctx), do: {:ok, "ok"}
    end

    test "category merges into meta and rides in _meta on the wire" do
      definition = Categorized.definition()
      assert definition.meta == %{"k" => "v", "category" => "Utility"}

      map = Noizu.MCP.Types.Tool.to_map(definition)
      assert map["_meta"]["category"] == "Utility"
      assert map["_meta"]["k"] == "v"
    end

    test "no category and no meta leaves meta nil" do
      assert Fixtures.Echo.definition().meta == nil
    end
  end
end
