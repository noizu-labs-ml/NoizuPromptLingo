defmodule NoizuPromptLingua.NPL.AliasesTest do
  @moduledoc """
  Wave-1 loader behavior for NPL conventions: `section_aliases` from npl.yaml
  (legacy `fences` -> `prompt-sections`), component `aliases:` lists, and
  explicit-id loading of `instructional:` entries (excluded from whole-section
  loads by the token guard). Driven by the static fixture conventions dir
  (`test/fixtures/npl_aliases`) so these tests never depend on the real YAML
  while it is being authored. Covers both the NPLLoad path
  (Parser/Loader/Resolver/Layout) and the NPLSpec path (Definition/
  ConventionFormatter).
  """

  use ExUnit.Case, async: true

  alias NoizuPromptLingua.NPL.{Definition, Layout, Loader, Parser, Resolver}

  @fixtures Path.expand("../../fixtures/npl_aliases", __DIR__)
  @aliases %{"fences" => "prompt-sections"}

  defp resolver_tmp_dir do
    dir = Path.join(System.tmp_dir!(), "npl-alias-#{System.unique_integer([:positive])}")
    File.mkdir_p!(dir)
    on_exit(fn -> File.rm_rf!(dir) end)
    dir
  end

  # ---------------------------------------------------------------------------
  # Parser — section aliases
  # ---------------------------------------------------------------------------

  describe "Parser section aliases" do
    test "alias term parses to the canonical section" do
      assert {:ok, %{additions: [comp]}} = Parser.parse("fences", @aliases)
      assert comp.section == "prompt-sections"
      assert comp.component == nil
    end

    test "alias in a component term and a subtraction" do
      assert {:ok, %{additions: [a], subtractions: [s]}} =
               Parser.parse("fences#format-prompt-section -fences:+2", @aliases)

      assert a.section == "prompt-sections" and a.component == "format-prompt-section"
      assert s.section == "prompt-sections" and s.component == nil
      assert s.priority_max == 2
    end

    test "without aliases the legacy name stays unknown (lists the 7 real sections)" do
      assert {:error, msg} = Parser.parse("fences")
      assert msg =~ "Unknown section: 'fences'"
      refute msg =~ "Valid sections:.*fences"
    end

    test "alias pointing at a non-section is rejected" do
      assert {:error, msg} = Parser.parse("fences", %{"fences" => "not-a-section"})
      assert msg =~ "Unknown section: 'fences'"
    end
  end

  # ---------------------------------------------------------------------------
  # Loader / Resolver — section alias, component aliases, instructional ids
  # ---------------------------------------------------------------------------

  describe "Loader section aliases" do
    test "fences loads the prompt-sections section through npl.yaml aliases" do
      assert {:ok, text} = Loader.load("fences", npl_dir: @fixtures)
      assert text =~ "### format-prompt-section (`format-prompt-section`)"
    end

    test "output uses the canonical section name" do
      assert {:ok, text} = Loader.load("fences", npl_dir: @fixtures, layout: :grouped)
      assert text =~ "## Prompt Sections"
      refute text =~ "## Fences"
    end
  end

  describe "Loader component aliases" do
    test "pumps#cot ≡ pumps#chain-of-thought with an alias note in the heading" do
      {:ok, via_alias} = Loader.load("pumps#cot", npl_dir: @fixtures)
      {:ok, canonical} = Loader.load("pumps#chain-of-thought", npl_dir: @fixtures)

      assert via_alias =~ "### chain-of-thought (`chain-of-thought`) (alias: cot)"
      assert canonical =~ "### chain-of-thought (`chain-of-thought`)"
      refute canonical =~ "(alias:"
      # everything but the heading note is identical
      assert String.replace(via_alias, " (alias: cot)", "") == canonical
    end

    test "multi-alias component resolves through any alias" do
      {:ok, a} = Loader.load("pumps#intent", npl_dir: @fixtures)
      {:ok, b} = Loader.load("pumps#npl-intent", npl_dir: @fixtures)
      {:ok, c} = Loader.load("pumps#intent-declaration", npl_dir: @fixtures)

      assert a =~ "### intent-declaration (`intent-declaration`) (alias: intent)"
      assert b =~ "### intent-declaration (`intent-declaration`) (alias: npl-intent)"
      assert c =~ "### intent-declaration (`intent-declaration`)"
      refute c =~ "(alias:"
    end

    test "subtraction by alias removes the canonical component" do
      {:ok, full} = Loader.load("pumps", npl_dir: @fixtures)
      {:ok, trimmed} = Loader.load("pumps -pumps#cot", npl_dir: @fixtures)

      assert full =~ "(`chain-of-thought`)"
      refute trimmed =~ "(`chain-of-thought`)"
      assert trimmed =~ "(`intent-declaration`)"
    end

    test "skip accepts alias ids" do
      {:ok, text} = Loader.load("pumps", npl_dir: @fixtures, skip: ["pumps#npl-intent"])
      refute text =~ "(`intent-declaration`)"
      assert text =~ "(`chain-of-thought`)"
    end

    test "alias and canonical term deduplicate to one component" do
      {:ok, text} = Loader.load("pumps#cot pumps#chain-of-thought", npl_dir: @fixtures)
      assert length(Regex.scan(~r/\(`chain-of-thought`\)/, text)) == 1
    end

    test "unknown id errors list canonical ids AND aliases AND instructional slugs" do
      assert {:error, msg} = Loader.load("pumps#bogus-id", npl_dir: @fixtures)
      assert msg =~ "Component 'bogus-id' not found in section 'pumps'"
      assert msg =~ "chain-of-thought"
      assert msg =~ "intent-declaration"
      assert msg =~ "pump-ordering"
      assert msg =~ "Available aliases: cot, intent, npl-intent"
    end

    test "existing available-components listing is preserved for unknown ids" do
      dir = resolver_tmp_dir()
      File.write!(Path.join(dir, "syntax.yaml"), "name: syntax\ncomponents:\n- name: c1\n")
      assert {:error, msg} = Loader.load("syntax#nope", npl_dir: dir)
      assert msg =~ "Available components: c1"
      refute msg =~ "Available aliases"
    end
  end

  describe "Loader instructional entries" do
    test "explicit id loads and renders the content" do
      assert {:ok, text} = Loader.load("pumps#pump-ordering", npl_dir: @fixtures)
      assert text =~ "### Pump Ordering (`pump-ordering`)"
      assert text =~ "PUMP-ORDERING-FIXTURE-MARKER"
    end

    test "whole-section loads exclude instructional entries (token guard)" do
      {:ok, text} = Loader.load("pumps", npl_dir: @fixtures)
      assert text =~ "(`chain-of-thought`)"
      assert text =~ "(`intent-declaration`)"
      refute text =~ "PUMP-ORDERING-FIXTURE-MARKER"
      refute text =~ "REFLECTION-EMOJIS-FIXTURE-MARKER"
      refute text =~ "(`pump-ordering`)"
    end

    test "explicit subtraction of an instructional id is a no-op with a warning log" do
      {:ok, text} = Loader.load("pumps -pumps#pump-ordering", npl_dir: @fixtures)
      refute text =~ "PUMP-ORDERING-FIXTURE-MARKER"
    end

    test "Resolver resolves whole-section additions to components only" do
      {:ok, comps} =
        Resolver.resolve(Resolver.new(@fixtures), %Parser.Expression{
          additions: [%Parser.Component{section: "pumps", component: nil, priority_max: nil}],
          subtractions: []
        })

      assert Enum.map(comps, & &1.slug) |> Enum.sort() ==
               ["chain-of-thought", "intent-declaration", "mood"]
    end
  end

  # ---------------------------------------------------------------------------
  # Layout — alias note + content rendering
  # ---------------------------------------------------------------------------

  describe "Layout" do
    test "renders matched_alias note and instructional content" do
      text =
        Layout.format(
          [
            %Resolver.ResolvedComponent{
              section: "pumps",
              name: "Chain of Thought",
              slug: "chain-of-thought",
              brief: "",
              description: "",
              matched_alias: "cot",
              content: nil
            },
            %Resolver.ResolvedComponent{
              section: "pumps",
              name: "Pump Ordering",
              slug: "pump-ordering",
              brief: "",
              description: "",
              content: "PUMP-ORDERING-FIXTURE-MARKER: body",
              matched_alias: nil
            }
          ],
          :yaml_order
        )

      assert text =~ "### Chain of Thought (`chain-of-thought`) (alias: cot)"
      assert text =~ "### Pump Ordering (`pump-ordering`)"
      assert text =~ "PUMP-ORDERING-FIXTURE-MARKER: body"
    end

    test "no alias note when matched canonically" do
      text =
        Layout.format(
          [
            %Resolver.ResolvedComponent{
              section: "pumps",
              name: "Mood",
              slug: "mood",
              brief: "",
              description: ""
            }
          ],
          :yaml_order
        )

      assert text == "### Mood (`mood`)"
    end
  end

  # ---------------------------------------------------------------------------
  # NPLSpec parity — Definition + ConventionFormatter
  # ---------------------------------------------------------------------------

  describe "NPLSpec (Definition) alias + instructional parity" do
    setup do
      {:ok, defn} = Definition.new(@fixtures)
      %{defn: defn}
    end

    test "definition loads section_aliases from npl.yaml", %{defn: defn} do
      assert defn.section_aliases == @aliases
    end

    test "section alias spec renders the canonical section", %{defn: defn} do
      text = Definition.format(defn, components: ["fences:format-prompt-section"])
      assert text =~ "Format Prompt Section"

      whole = Definition.format(defn, components: ["fences"])
      assert whole =~ "Format Prompt Section"
    end

    test "component alias spec resolves and pulls dependencies", %{defn: defn} do
      text = Definition.format(defn, components: ["pumps:cot"])
      assert text =~ "Chain of Thought"
      # chain-of-thought requires pumps.mood — dep walk on the canonical name
      assert text =~ "Mood"
    end

    test "instructional id is loadable and content renders", %{defn: defn} do
      text = Definition.format(defn, components: ["pumps:pump-ordering"])
      assert text =~ "Pump Ordering"
      assert text =~ "PUMP-ORDERING-FIXTURE-MARKER"
      refute text =~ "REFLECTION-EMOJIS-FIXTURE-MARKER"
      refute text =~ "Chain of Thought"
    end

    test "whole-section spec excludes instructional entries", %{defn: defn} do
      text = Definition.format(defn, components: ["pumps"])
      assert text =~ "Chain of Thought"
      refute text =~ "PUMP-ORDERING-FIXTURE-MARKER"
    end

    test "rendered specs match through aliases", %{defn: defn} do
      text =
        Definition.format(defn,
          components: ["pumps:chain-of-thought,intent-declaration"],
          rendered: ["pumps:npl-intent"]
        )

      assert text =~ "Chain of Thought"
      refute text =~ "Intent Declaration"
    end

    test "mixed canonical, alias, and instructional ids render together", %{defn: defn} do
      text = Definition.format(defn, components: ["pumps:cot,pump-ordering"])
      assert text =~ "Chain of Thought"
      assert text =~ "PUMP-ORDERING-FIXTURE-MARKER"
    end
  end
end
