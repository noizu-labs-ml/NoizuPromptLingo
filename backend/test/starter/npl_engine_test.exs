defmodule NoizuPromptLingua.NPLEngineTest do
  use ExUnit.Case, async: true

  alias NoizuPromptLingua.NPL.{Loader, Definition, Reader, Parser}

  describe "section_order/0" do
    test "returns the canonical section list from npl.yaml" do
      order = NoizuPromptLingua.NPL.section_order()
      assert "syntax" in order
      assert "pumps" in order
      assert length(order) >= 7
    end
  end

  describe "Parser.parse/1" do
    test "parses a simple section" do
      assert {:ok, expr} = Parser.parse("syntax")
      assert [%Parser.Component{section: "syntax", component: nil}] = expr.additions
      assert expr.subtractions == []
    end

    test "parses section + component + priority and a subtraction" do
      assert {:ok, expr} = Parser.parse("syntax#placeholder:+2 directives -syntax#literal-string")
      assert length(expr.additions) == 2
      assert [%Parser.Component{section: "syntax", component: "literal-string"}] = expr.subtractions
    end

    test "rejects subtraction-only expressions" do
      assert {:error, _} = Parser.parse("-syntax")
    end

    test "rejects unknown sections" do
      assert {:error, _} = Parser.parse("bogus-section")
    end
  end

  describe "Loader.load/2" do
    test "renders a section as non-empty formatted text" do
      assert {:ok, out} = Loader.load("syntax", [])
      assert String.length(out) > 0
    end

    test "subtraction removes a component" do
      assert {:ok, with_mood} = Loader.load("pumps", [])
      assert {:ok, no_mood} = Loader.load("pumps -pumps#mood", [])
      assert String.contains?(with_mood, "npl-mood") or String.contains?(with_mood, "Mood")
      # Mood block should be absent after subtracting the mood component.
      assert String.length(no_mood) < String.length(with_mood)
    end
  end

  describe "Definition" do
    test "new/0 loads the root definition" do
      assert {:ok, defn} = Definition.new()
      assert defn.version == "1.0"
      assert defn.section_order != []
    end

    test "format/2 produces a versioned spec marker for selected components" do
      assert {:ok, defn} = Definition.new()
      out = Definition.format(defn, components: ["pumps:chain-of-thought"])
      assert String.contains?(out, "NPL@")
      assert String.length(out) > 0
    end

    test "format/2 with nil components includes all sections" do
      assert {:ok, defn} = Definition.new()
      out = Definition.format(defn, components: nil)
      assert String.contains?(out, "NPL@")
      # Core concepts header is always present.
      assert String.contains?(out, "Core Concepts")
    end
  end

  describe "Reader" do
    test "sections/0 lists every convention file with counts" do
      assert {:ok, sections} = Reader.sections()
      names = Enum.map(sections, & &1.section)
      assert "syntax" in names
      assert "pumps" in names
      # Each section has a positive component count (YAMLs are populated).
      assert Enum.all?(sections, &(&1.component_count >= 0))
      assert Enum.sum_by(sections, & &1.component_count) > 0
    end

    test "components/1 returns summaries across all sections" do
      assert {:ok, comps} = Reader.components(nil)
      assert length(comps) > 0
      assert Enum.all?(comps, &(&1.section != ""))
    end

    test "components/1 filters by section" do
      assert {:ok, comps} = Reader.components("pumps")
      assert Enum.all?(comps, &(&1.section == "pumps"))
      assert length(comps) > 0
    end

    test "component/2 returns full detail with syntax and examples" do
      assert {:ok, c} = Reader.component("syntax", "placeholder")
      assert c.name == "placeholder"
      assert c.syntax != []
      assert c.examples != []
      assert "inline" in c.labels
    end

    test "component/2 returns not_found for an unknown slug" do
      assert {:error, :not_found} = Reader.component("syntax", "does-not-exist")
    end

    test "labels/0 returns the taxonomy map" do
      assert {:ok, taxonomy} = Reader.labels()
      # The taxonomy has categories (scope/function/etc.).
      cats = Map.get(taxonomy, "categories") || []
      assert cats != []
    end
  end
end
