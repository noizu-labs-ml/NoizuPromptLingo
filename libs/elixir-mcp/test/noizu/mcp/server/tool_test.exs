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
      assert Fixtures.RawSchema.__mcp_tool__(:cast_plan) == nil
    end
  end

  describe "cast plan" do
    test "atomizes declared keys, applies defaults, casts enums" do
      plan = Fixtures.Echo.__mcp_tool__(:cast_plan)

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
      plan = Fixtures.Echo.__mcp_tool__(:cast_plan)
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
      plan = Nested.__mcp_tool__(:cast_plan)

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
end
