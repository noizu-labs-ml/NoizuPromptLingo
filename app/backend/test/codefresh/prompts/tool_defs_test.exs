defmodule Codefresh.Prompts.ToolDefsTest do
  use ExUnit.Case, async: true

  alias Codefresh.Prompts.ToolDefs

  describe "validate/1" do
    test "empty / missing tools is valid" do
      assert :ok = ToolDefs.validate(%{})
      assert :ok = ToolDefs.validate(%{"tools" => []})
    end

    test "well-formed tool passes" do
      assert :ok =
               ToolDefs.validate(%{
                 "tools" => [
                   %{
                     "name" => "lookup",
                     "description" => "Look up a user",
                     "parameters" => %{"type" => "object"}
                   }
                 ]
               })
    end

    test "missing name fails" do
      assert {:error, {:tool_at_index, 0, {:missing, "name"}}} =
               ToolDefs.validate(%{"tools" => [%{"description" => "x", "parameters" => %{}}]})
    end

    test "non-map parameters fails" do
      assert {:error, {:tool_at_index, 0, {:parameters_must_be_object, "t"}}} =
               ToolDefs.validate(%{
                 "tools" => [%{"name" => "t", "description" => "d", "parameters" => "string"}]
               })
    end
  end

  describe "tool_names/1" do
    test "extracts name list" do
      defs = %{"tools" => [%{"name" => "a"}, %{"name" => "b"}]}
      assert ToolDefs.tool_names(defs) == ["a", "b"]
    end
  end
end
