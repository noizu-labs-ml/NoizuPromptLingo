defmodule NoizuPromptLingua.NPL.EngineTest do
  @moduledoc """
  NPL engine core: Parser (expression DSL), Layout (formatting strategies),
  Loader (parse -> fold skip -> resolve -> format), and Resolver (YAML ->
  ResolvedComponents, subtraction, priority filtering, caching).

  All file-backed tests pass an explicit `npl_dir` (real priv/conventions for
  happy paths, temp dirs for error paths) so the suite never reads or mutates
  the `:npl_conventions_dir` Application env — that keeps it race-free against
  modules that do override the env.
  """

  use ExUnit.Case, async: true

  alias NoizuPromptLingua.NPL.{Layout, Loader, Parser, Resolver}

  @real_dir Path.join(:code.priv_dir(:noizu_prompt_lingua), "conventions")

  # ---------------------------------------------------------------------------
  # Parser
  # ---------------------------------------------------------------------------

  describe "Parser.parse/1" do
    test "empty and whitespace-only expressions are rejected" do
      assert {:error, "Expression cannot be empty"} = Parser.parse("")
      assert {:error, "Expression cannot be empty"} = Parser.parse("   \n\t ")
    end

    test "single section term" do
      assert {:ok, %Parser.Expression{additions: [comp], subtractions: []}} =
               Parser.parse("syntax")

      assert comp == %Parser.Component{section: "syntax", component: nil, priority_max: nil}
    end

    test "multiple terms split on whitespace" do
      assert {:ok, %Parser.Expression{additions: additions}} =
               Parser.parse("syntax   directives\t\npumps")

      assert Enum.map(additions, & &1.section) == ~w(syntax directives pumps)
    end

    test "section reference with component" do
      assert {:ok, %{additions: [comp]}} = Parser.parse("syntax#placeholder")
      assert comp.component == "placeholder"
      assert comp.priority_max == nil
    end

    test "section reference with component and positive priority" do
      assert {:ok, %{additions: [comp]}} = Parser.parse("syntax#placeholder:+2")
      assert comp.priority_max == 2
    end

    test "priority :+0 parses as zero" do
      assert {:ok, %{additions: [comp]}} = Parser.parse("syntax:+0")
      assert comp.priority_max == 0
    end

    test "uppercase section names are rejected by the term regex" do
      assert {:error, msg} = Parser.parse("SYNTAX")
      assert msg =~ "Expected format"
    end

    test "dashed section names are valid" do
      assert {:ok, %{additions: [comp]}} = Parser.parse("prompt-sections#component-ref")
      assert comp.section == "prompt-sections"
    end

    test "subtraction term lands in subtractions" do
      assert {:ok, %{additions: [a], subtractions: [s]}} =
               Parser.parse("syntax -syntax#literal-string")

      assert a.section == "syntax" and a.component == nil
      assert s.section == "syntax" and s.component == "literal-string"
    end

    test "bare '-' is an invalid subtraction" do
      assert {:error, msg} = Parser.parse("syntax -")
      assert msg =~ "Invalid subtraction"
    end

    test "invalid subtraction term propagates the section error" do
      assert {:error, msg} = Parser.parse("syntax -bogus")
      assert msg =~ "Unknown section: 'bogus'"
    end

    test "only subtractions is rejected" do
      assert {:error, msg} = Parser.parse("-syntax#literal-string")
      assert msg =~ "at least one section to load"
    end

    test "'@' separator gets a targeted hint" do
      assert {:error, msg} = Parser.parse("syntax@placeholder")
      assert msg =~ "Use '#' to separate section from component"
    end

    test "'::' gets a targeted hint" do
      assert {:error, msg} = Parser.parse("syntax#placeholder::2")
      assert msg =~ "Found '::'"
    end

    test "malformed term gets the format hint" do
      assert {:error, msg} = Parser.parse("syntax#UPPER")
      assert msg =~ "Expected format: section[#component][:+N]"
    end

    test "unknown section lists the valid sections (alphabetical)" do
      assert {:error, msg} = Parser.parse("bogus")
      assert msg =~ "Unknown section: 'bogus'"

      assert msg =~
               "declarations, directives, fences, prefixes, prompt-sections, pumps, " <>
                 "special-sections, syntax"
    end

    test "numeric-prefixed section name fails validation, not the regex" do
      assert {:error, msg} = Parser.parse("syntax2")
      assert msg =~ "Unknown section: 'syntax2'"
    end

    test "':2' (missing +) is rejected by the priority parser" do
      assert {:error, msg} = Parser.parse("syntax:2")
      assert msg =~ "Use :+N"
    end

    test "':-2' (negative) is rejected" do
      assert {:error, msg} = Parser.parse("syntax:-2")
      assert msg =~ "Use :+N"
    end

    test "':+-1' parses structurally then fails the non-negative guard" do
      assert {:error, msg} = Parser.parse("syntax:+-1")
      assert msg =~ "Priority must be a non-negative number"
    end

    test "':+abc' (letter priority) reaches the parse failure branch" do
      assert {:error, msg} = Parser.parse("syntax:+abc")
      assert msg =~ "Priority must be a non-negative number"
    end

    test "trailing junk after the priority fails the whole-term regex" do
      assert {:error, msg} = Parser.parse("syntax:+2x")
      assert msg =~ "Expected format"
    end
  end

  # ---------------------------------------------------------------------------
  # Layout
  # ---------------------------------------------------------------------------

  defp comp(opts) do
    struct!(
      Resolver.ResolvedComponent,
      Map.merge(
        %{
          section: "syntax",
          name: "Comp",
          slug: "",
          brief: "",
          description: "",
          syntax: [],
          examples: [],
          labels: [],
          require: [],
          priority_filtered: false
        },
        Map.new(opts)
      )
    )
  end

  describe "Layout.format/2" do
    test "empty list renders as empty string" do
      assert Layout.format([], :yaml_order) == ""
      assert Layout.format([], :classic) == ""
      assert Layout.format([], :grouped) == ""
    end

    test "minimal component renders a bare name heading" do
      assert Layout.format([comp(name: "Bare")], :yaml_order) == "### Bare"
    end

    test "slug renders into the heading" do
      text = Layout.format([comp(name: "Comp", slug: "comp")], :yaml_order)
      assert text == "### Comp (`comp`)"
    end

    test "full component renders brief, description, syntax, examples, labels, requires" do
      text =
        Layout.format(
          [
            comp(
              name: "Comp",
              slug: "comp",
              brief: "the brief",
              description: "the description",
              syntax: [%{"syntax" => "|<x>"}, %{"name" => "named-only"}],
              examples: [%{"name" => "ex1", "brief" => "b1", "priority" => 1}, %{"name" => "ex2"}],
              labels: ["inline", "modifier"],
              require: ["syntax.placeholder"]
            )
          ],
          :yaml_order
        )

      assert text =~ "*the brief*"
      assert text =~ "the description"
      assert text =~ "**Syntax:**"
      assert text =~ "- `|<x>`"
      # syntax entry without a "syntax" key falls back to "name"
      assert text =~ "- `named-only`"
      assert text =~ "**Examples:**"
      assert text =~ "- **ex1**: b1 (priority 1)"
      assert text =~ "- **ex2** (priority 0)"
      assert text =~ "*Labels: `inline`, `modifier`*"
      assert text =~ "*Requires: `syntax.placeholder`*"
      assert text =~ ~r/\A### Comp/
    end

    test "classic strategy groups by first label and title-cases it" do
      text =
        Layout.format(
          [
            comp(name: "Zed", labels: ["beta-group"]),
            comp(name: "Ay", labels: ["alpha-group"]),
            comp(name: "None", labels: [])
          ],
          :classic
        )

      assert text =~ "## Alpha Group"
      assert text =~ "## Beta Group"
      assert text =~ "## Uncategorized"
      # categories sorted alphabetically
      offset = fn marker -> text |> String.split(marker) |> hd() |> String.length() end
      assert offset.("## Alpha Group") < offset.("## Beta Group")
      assert offset.("## Beta Group") < offset.("## Uncategorized")
    end

    test "classic title-case splits on dashes and underscores" do
      text = Layout.format([comp(name: "X", labels: ["multi_part-label"])], :classic)
      assert text =~ "## Multi Part Label"
    end

    test "grouped strategy groups by section with title-cased headers" do
      text =
        Layout.format(
          [
            comp(name: "A", section: "special-sections"),
            comp(name: "B", section: "special-sections"),
            comp(name: "C", section: "pumps")
          ],
          :grouped
        )

      assert text =~ "## Special Sections"
      assert text =~ "## Pumps"
      assert text =~ "### A"
      assert text =~ "### B"
      assert text =~ "### C"
    end

    test "unknown strategy falls back to yaml_order" do
      components = [comp(name: "Comp", slug: "comp", brief: "b")]
      assert Layout.format(components, :what) == Layout.format(components, :yaml_order)
    end
  end

  # ---------------------------------------------------------------------------
  # Loader (real conventions dir, passed explicitly)
  # ---------------------------------------------------------------------------

  describe "Loader.load/2" do
    test "loads a section end-to-end" do
      assert {:ok, text} = Loader.load("syntax", npl_dir: @real_dir)
      assert text =~ "### "
      assert text =~ "qualifier"
    end

    test "loads multiple sections in expression order" do
      assert {:ok, text} = Loader.load("pumps syntax", npl_dir: @real_dir)
      assert text =~ "### "
    end

    test "classic layout differs from yaml_order and groups by label" do
      {:ok, yaml_order} = Loader.load("syntax", npl_dir: @real_dir, layout: :yaml_order)
      {:ok, classic} = Loader.load("syntax", npl_dir: @real_dir, layout: :classic)
      {:ok, grouped} = Loader.load("syntax", npl_dir: @real_dir, layout: :grouped)

      assert classic != yaml_order
      assert classic =~ "## "
      assert grouped =~ "## Syntax"
    end

    test "unknown layout atom falls back to yaml_order" do
      {:ok, fallback} = Loader.load("syntax", npl_dir: @real_dir, layout: :bogus)
      {:ok, yaml_order} = Loader.load("syntax", npl_dir: @real_dir, layout: :yaml_order)
      assert fallback == yaml_order
    end

    test "subtraction removes a component" do
      {:ok, full} = Loader.load("syntax", npl_dir: @real_dir)
      {:ok, trimmed} = Loader.load("syntax -syntax#qualifier", npl_dir: @real_dir)

      assert full =~ "### qualifier (`qualifier`)"
      refute trimmed =~ "### qualifier (`qualifier`)"
    end

    test "skip folds extra subtraction terms into the expression" do
      {:ok, text} = Loader.load("syntax", npl_dir: @real_dir, skip: "syntax#qualifier")
      refute text =~ "### qualifier (`qualifier`)"
    end

    test "skip accepts a list with blank terms and merges with inline subtractions" do
      {:ok, full} = Loader.load("syntax -syntax#placeholder", npl_dir: @real_dir)

      {:ok, trimmed} =
        Loader.load("syntax -syntax#placeholder",
          npl_dir: @real_dir,
          skip: ["syntax#qualifier", "  "]
        )

      assert full =~ "### qualifier (`qualifier`)"
      refute full =~ "### placeholder (`placeholder`)"
      refute trimmed =~ "### qualifier (`qualifier`)"
    end

    test "skip with an empty list is a no-op" do
      {:ok, text} = Loader.load("syntax", npl_dir: @real_dir, skip: [])
      assert text =~ "### qualifier (`qualifier`)"
    end

    test "skip with an invalid term aborts the load" do
      assert {:error, msg} = Loader.load("syntax", npl_dir: @real_dir, skip: "bogus#x")
      assert msg =~ "Unknown section: 'bogus'"
    end

    test "parser errors propagate" do
      assert {:error, "Expression cannot be empty"} = Loader.load("", npl_dir: @real_dir)
      assert {:error, msg} = Loader.load("-syntax", npl_dir: @real_dir)
      assert msg =~ "at least one section"
      assert {:error, msg} = Loader.load("syntax @x", npl_dir: @real_dir)
      assert msg =~ "'#' to separate"
      assert {:error, msg} = Loader.load("bogus", npl_dir: @real_dir)
      assert msg =~ "Unknown section"
    end

    test "missing section file surfaces the resolver error" do
      assert {:error, msg} = Loader.load("fences", npl_dir: @real_dir)
      assert msg =~ "Section file not found: fences.yaml"
    end
  end

  # ---------------------------------------------------------------------------
  # Resolver
  # ---------------------------------------------------------------------------

  defp resolver_tmp_dir do
    dir = Path.join(System.tmp_dir!(), "npl-resolver-#{System.unique_integer([:positive])}")
    File.mkdir_p!(dir)
    on_exit(fn -> File.rm_rf!(dir) end)
    dir
  end

  defp expression(additions, subtractions \\ []) do
    %Parser.Expression{
      additions: Enum.map(additions, fn
        {section, component} ->
          %Parser.Component{section: section, component: component, priority_max: nil}

        section ->
          %Parser.Component{section: section, component: nil, priority_max: nil}
      end),
      subtractions:
        Enum.map(subtractions, fn {section, component} ->
          %Parser.Component{section: section, component: component, priority_max: nil}
        end)
    }
  end

  describe "Resolver.resolve/2" do
    test "whole section resolves all components in file order" do
      {:ok, comps} = Resolver.resolve(Resolver.new(@real_dir), expression(["syntax"]))
      assert length(comps) > 3
      assert Enum.all?(comps, &(&1.section == "syntax"))
      assert Enum.any?(comps, &(&1.name == "qualifier"))
    end

    test "single component resolves with priority_max nil (no example filtering)" do
      {:ok, [comp]} =
        Resolver.resolve(Resolver.new(@real_dir), expression([{"syntax", "qualifier"}]))

      assert comp.name == "qualifier"
      assert comp.slug == "qualifier"
      assert comp.priority_filtered == false
      assert comp.examples != []
      assert comp.require == ["syntax.placeholder", "syntax.in-fill", "syntax.size-indicator"]
      assert comp.labels == ["inline", "modifier", "constraint"]
    end

    test "priority_max filters examples and flags the component" do
      {:ok, [comp]} =
        Resolver.resolve(
          Resolver.new(@real_dir),
          expression_add_priority({"syntax", "qualifier"}, 0)
        )

      assert comp.examples == []
      assert comp.priority_filtered == true
    end

    test "priority_max keeps examples at or under the cap" do
      {:ok, [comp]} =
        Resolver.resolve(
          Resolver.new(@real_dir),
          expression_add_priority({"syntax", "qualifier"}, 2)
        )

      priorities = Enum.map(comp.examples, &Map.get(&1, "priority", 0))
      assert priorities != [] and Enum.all?(priorities, &(&1 <= 2))
      assert comp.priority_filtered == true
    end

    test "negative priority_max drops all examples" do
      {:ok, [comp]} =
        Resolver.resolve(
          Resolver.new(@real_dir),
          expression_add_priority({"syntax", "qualifier"}, -1)
        )

      assert comp.examples == []
      assert comp.priority_filtered == true
    end

    test "missing component errors with the available list" do
      assert {:error, msg} =
               Resolver.resolve(Resolver.new(@real_dir), expression([{"syntax", "nonexistent"}]))

      assert msg =~ "Component 'nonexistent' not found in section 'syntax'"
      assert msg =~ "Available components:"
      assert msg =~ "qualifier"
    end

    test "section subtraction removes the whole section" do
      resolver = Resolver.new(@real_dir)
      expr = expression(["syntax", "pumps"], [{"syntax", nil}])
      {:ok, comps} = Resolver.resolve(resolver, expr)
      assert comps != []
      refute Enum.any?(comps, &(&1.section == "syntax"))
      assert Enum.all?(comps, &(&1.section == "pumps"))
    end

    test "component subtraction removes just that component" do
      resolver = Resolver.new(@real_dir)
      {:ok, comps} = Resolver.resolve(resolver, expression(["syntax"], [{"syntax", "qualifier"}]))
      refute Enum.any?(comps, &(&1.name == "qualifier"))
      assert Enum.any?(comps, &(&1.name == "placeholder"))
    end

    test "subtracting an absent component logs and ignores" do
      resolver = Resolver.new(@real_dir)
      expr = expression(["syntax"], [{"syntax", "never-loaded"}])
      assert {:ok, comps} = Resolver.resolve(resolver, expr)
      assert Enum.any?(comps, &(&1.name == "qualifier"))
    end

    test "duplicate additions deduplicate via the seen set" do
      resolver = Resolver.new(@real_dir)

      expr = %Parser.Expression{
        additions: [
          %Parser.Component{section: "syntax", component: "qualifier", priority_max: nil},
          %Parser.Component{section: "syntax", component: "qualifier", priority_max: nil}
        ],
        subtractions: []
      }

      assert {:ok, [comp]} = Resolver.resolve(resolver, expr)
      assert comp.name == "qualifier"
    end

    test "unknown section in a hand-built expression errors" do
      assert {:error, "Unknown section: 'bogus-sec'"} =
               Resolver.resolve(Resolver.new(@real_dir), expression(["bogus-sec"]))
    end

    test "missing section file errors with the expected path" do
      dir = resolver_tmp_dir()
      assert {:error, msg} = Resolver.resolve(Resolver.new(dir), expression(["syntax"]))
      assert msg =~ "Section file not found: syntax.yaml"
      assert msg =~ dir
    end

    test "invalid YAML surfaces a parse error" do
      dir = resolver_tmp_dir()
      File.write!(Path.join(dir, "syntax.yaml"), "{ not: [valid")
      assert {:error, msg} = Resolver.resolve(Resolver.new(dir), expression(["syntax"]))
      assert msg =~ "Invalid YAML in syntax.yaml"
    end

    test "second resolve on the same resolver hits the section cache" do
      resolver = Resolver.new(@real_dir)
      assert {:ok, first} = Resolver.resolve(resolver, expression(["syntax"]))

      assert {:ok, second} =
               Resolver.resolve(%{resolver | cache: resolver.cache}, expression(["syntax"]))

      assert first == second
    end
  end

  defp expression_add_priority({section, component}, max) do
    %Parser.Expression{
      additions: [%Parser.Component{section: section, component: component, priority_max: max}],
      subtractions: []
    }
  end
end
