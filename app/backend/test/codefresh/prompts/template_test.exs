defmodule Codefresh.Prompts.TemplateTest do
  use ExUnit.Case, async: true

  alias Codefresh.Prompts.Template

  describe "extract_vars/1" do
    test "extracts unique names, ignoring whitespace inside braces" do
      body = "Hello {{ name }}, today is {{day}}, {{name}} again."
      assert Template.extract_vars(body) == MapSet.new(["name", "day"])
    end

    test "ignores non-matching brace patterns" do
      assert Template.extract_vars("single {brace}") == MapSet.new([])
      assert Template.extract_vars("{{ 9not_ident }}") == MapSet.new([])
    end
  end

  describe "validate/2" do
    test ":ok when every var is declared" do
      assert :ok = Template.validate("Hi {{name}}", %{"name" => %{}})
    end

    test ":ok with declared-but-unused vars (warning-class, not error)" do
      assert :ok = Template.validate("Hi {{name}}", %{"name" => %{}, "unused" => %{}})
    end

    test "error when body references undeclared vars" do
      assert {:error, {:undeclared_vars, ["city"]}} =
               Template.validate("{{name}} from {{city}}", %{"name" => %{}})
    end
  end

  describe "render/3" do
    test "uses provided bindings" do
      assert {:ok, "Hi Priya"} =
               Template.render("Hi {{name}}", %{"name" => %{}}, %{"name" => "Priya"})
    end

    test "falls back to defaults" do
      assert {:ok, "Hi there"} =
               Template.render("Hi {{name}}", %{"name" => %{"default" => "there"}}, %{})
    end

    test "missing required without default errors" do
      assert {:error, {:missing_required_vars, ["name"]}} =
               Template.render("Hi {{name}}", %{"name" => %{"required" => true}}, %{})
    end

    test "missing optional without default renders blank" do
      assert {:ok, "Hi !"} = Template.render("Hi {{name}}!", %{"name" => %{}}, %{})
    end
  end

  describe "control flow (US-115)" do
    test "{% if %} emits branch when truthy" do
      body = "hello{% if greet %} world{% endif %}!"
      assert {:ok, "hello world!"} = Template.render(body, %{"greet" => %{}}, %{"greet" => true})
      assert {:ok, "hello!"} = Template.render(body, %{"greet" => %{}}, %{"greet" => false})
      assert {:ok, "hello!"} = Template.render(body, %{"greet" => %{}}, %{})
    end

    test "{% for %} iterates and exposes loop-local" do
      body = "items:{% for x in xs %} {{x}}{% endfor %}."

      assert {:ok, "items: a b c."} =
               Template.render(body, %{"xs" => %{}}, %{"xs" => ["a", "b", "c"]})
    end

    test "nested if inside for" do
      body = "{% for x in xs %}{% if x %}{{x}} {% endif %}{% endfor %}"
      assert {:ok, "a c "} = Template.render(body, %{"xs" => %{}}, %{"xs" => ["a", "", "c"]})
    end

    test "extract_vars excludes loop-locals, includes collection name" do
      body = "{% for item in users %}{{item}}{% endfor %}"
      vars = Template.extract_vars(body)
      assert MapSet.member?(vars, "users")
      refute MapSet.member?(vars, "item")
    end

    test "validate catches undeclared if-var" do
      body = "{% if missing %}x{% endif %}"
      assert {:error, {:undeclared_vars, ["missing"]}} = Template.validate(body, %{})
    end
  end
end
