defmodule NoizuPromptLingua.NPL.DefinitionFormatterTest do
  @moduledoc """
  Definition (npl.yaml model + NPLSpec-style full-spec rendering: component
  specs, rendered-exclusion, dependency walking) and ConventionFormatter
  (single-convention markdown: priority/filtered rendering, concise/xml flags,
  heading offsets, category example set-cover).

  Every call passes an explicit conventions dir (real priv/conventions for
  happy paths; crafted temp dirs for priority/set-cover/backtick branches), so
  the suite never touches the `:npl_conventions_dir` env.
  """

  use ExUnit.Case, async: true

  alias NoizuPromptLingua.NPL.{ConventionFormatter, Definition}

  @real_dir Path.join(:code.priv_dir(:noizu_prompt_lingua), "conventions")

  defp fixture_dir(files) do
    dir = Path.join(System.tmp_dir!(), "npl-defn-#{System.unique_integer([:positive])}")
    File.mkdir_p!(dir)

    Enum.each(files, fn {name, contents} ->
      File.write!(Path.join(dir, name), contents)
    end)

    on_exit(fn -> File.rm_rf!(dir) end)
    dir
  end

  # Two categories; cat-a has two components (one high-priority) and a category
  # example that covers both. cat-b has no components (renders empty).
  @basic_conv """
  name: testconv
  title: Test Convention
  brief: Short brief
  description: Long description text
  purpose: The convention purpose
  categories:
    - name: cat-a
      title: Category A
      description: Cat A description
      examples:
        - name: cover-all
          brief: Covers both components
          covers: [comp-1, comp-2]
    - name: cat-b
      title: Category B
      description: Cat B description
  components:
    - name: comp-1
      category: cat-a
      priority: 0
      friendly-name: Component One
      brief: Brief one
      description: Long description one
      syntax:
        - name: s1
          syntax: "|<x>"
          description: |
            first line
            second line
      examples:
        - name: ex-low
          priority: 0
          example: "simple example"
          thread:
            - role: user
              message: hello there
        - name: ex-high
          priority: 5
          example: "high priority example"
    - name: comp-2
      category: cat-a
      priority: 3
      brief: Brief two
      labels: ["|<x>"]
  """

  # ---------------------------------------------------------------------------
  # Definition.new/1
  # ---------------------------------------------------------------------------

  describe "Definition.new/1" do
    test "loads the real npl.yaml model" do
      assert {:ok, defn} = Definition.new(@real_dir)
      assert defn.version == "1.0"

      assert defn.section_order == ~w(syntax declarations pumps directives prefixes
                                        prompt-sections special-sections)

      assert defn.concepts != []
      assert defn.description != ""
      assert defn.dep_graph == nil
      assert defn.convention_components == nil
    end

    test "errors on a missing npl.yaml" do
      dir = fixture_dir(%{})
      assert {:error, msg} = Definition.new(dir)
      assert msg =~ "Failed to load npl.yaml"
    end

    test "string versions pass through; float versions render with one decimal" do
      dir =
        fixture_dir(%{
          "npl.yaml" => "/npl:\n  version: \"2.5\"\n  description: d\n",
          "syntax.yaml" => "name: syntax\ncomponents: []\n"
        })

      assert {:ok, defn} = Definition.new(dir)
      assert defn.version == "2.5"

      float_dir =
        fixture_dir(%{
          "npl.yaml" => "/npl:\n  version: 1.0\n  description: d\n",
          "syntax.yaml" => "name: syntax\ncomponents: []\n"
        })

      assert {:ok, defn} = Definition.new(float_dir)
      assert defn.version == "1.0"
    end

    test "missing section_order/components key defaults to an empty list" do
      dir =
        fixture_dir(%{
          "npl.yaml" => "/npl:\n  version: 1.0\n  description: d\n",
          "syntax.yaml" => "name: syntax\ncomponents: []\n"
        })

      assert {:ok, defn} = Definition.new(dir)
      assert defn.section_order == []
    end
  end

  # ---------------------------------------------------------------------------
  # Definition.format/2
  # ---------------------------------------------------------------------------

  describe "Definition.format/2 (full-spec rendering)" do
    test "renders the full framework block with markers and all sections" do
      {:ok, defn} = Definition.new(@real_dir)
      text = Definition.format(defn)

      assert text =~ ~r/\A⌜NPL@1\.0⌝\n# Noizu Prompt Lingua \(NPL\)\n/
      assert text =~ "⌞NPL@1.0⌟"
      assert text =~ "## Core Concepts"
      assert text =~ "npl-declaration"
      assert text =~ "NPL Syntax Overview"
      assert text =~ "Directives"
    end

    test "extension mode swaps the markers" do
      {:ok, defn} = Definition.new(@real_dir)
      text = Definition.format(defn, extension: true)
      assert text =~ "⌜extend:NPL@1.0⌝"
      assert text =~ "⌞extend:NPL@1.0⌟"
    end

    test "empty component list renders concepts only (no convention bodies)" do
      {:ok, defn} = Definition.new(@real_dir)
      text = Definition.format(defn, components: [])
      refute text =~ "NPL Syntax Overview"
      assert text =~ "## Core Concepts"
    end

    test "a '*' spec renders nothing beyond the concepts" do
      {:ok, defn} = Definition.new(@real_dir)
      text = Definition.format(defn, components: ["*"])
      refute text =~ "NPL Syntax Overview"
    end

    test "component spec expands dependencies (qualifier pulls its requires)" do
      {:ok, defn} = Definition.new(@real_dir)
      text = Definition.format(defn, components: ["syntax:qualifier"])

      assert text =~ "Qualifier"
      # dependency walk pulls in the three requires of syntax.qualifier
      assert text =~ ~r/#### .*[Pp]laceholder/
      assert text =~ ~r/#### .*[Ss]ize [Ii]ndicator/
      refute text =~ "Mermaid"
    end

    test "rendered specs are excluded from re-rendering" do
      {:ok, defn} = Definition.new(@real_dir)

      text =
        Definition.format(defn, components: ["syntax:qualifier"], rendered: ["syntax:placeholder"])

      assert text =~ "Qualifier"
      refute text =~ ~r/#### .*[Pp]laceholder/
    end

    test "rendered specs without a component part are ignored" do
      {:ok, defn} = Definition.new(@real_dir)

      # "syntax" has no ":comp" suffix, so parse_rendered_specs drops it and
      # placeholder renders normally.
      text = Definition.format(defn, components: ["syntax:qualifier"], rendered: ["syntax"])
      assert text =~ "Qualifier"
      assert text =~ ~r/#### .*[Pp]laceholder/
    end

    test "component renders are deterministic across repeated formats" do
      {:ok, defn} = Definition.new(@real_dir)
      first = Definition.format(defn, components: ["syntax:qualifier"])
      assert first =~ "Qualifier"

      second = Definition.format(defn, components: ["syntax:qualifier"])
      assert second == first
    end

    test "dep-graph loading tolerates conventions whose yaml file is missing" do
      dir =
        fixture_dir(%{"npl.yaml" => "/npl:\n  version: 1.0\n  section_order:\n    components:\n      - syntax\n"})

      {:ok, defn} = Definition.new(dir)

      # components: ["*"] yields an empty (non-nil) conv_map, which still
      # triggers dependency-graph loading; the missing syntax.yaml is skipped.
      text = Definition.format(defn, components: ["*"])
      refute text =~ "NPL Syntax"
    end

    test "already-included dependency gets its priority raised" do
      {:ok, defn} = Definition.new(@real_dir)

      # syntax.placeholder is included at priority 0 by its own spec;
      # directives.table-formatting at priority 3 requires it cross-convention,
      # so the dep walk raises placeholder's priority.
      text =
        Definition.format(defn, components: [
          "syntax:placeholder",
          %{spec: "directives:table-formatting", component_priority: 3, example_priority: 0}
        ])

      assert text =~ "Table Formatting"
      assert text =~ ~r/#### .*[Pp]laceholder/
    end

    test "pre-set dep_graph short-circuits dependency-graph loading" do
      {:ok, defn} = Definition.new(@real_dir)

      # dep_graph/convention_components are part of the public struct; handing
      # a prepared definition in takes the cache clause of load_dependency_graph.
      prepared = %{
        defn
        | dep_graph: %{"syntax.qualifier" => ["syntax.placeholder"]},
          convention_components: %{"syntax" => ["qualifier", "placeholder"]}
      }

      text = Definition.format(prepared, components: ["syntax:qualifier"])
      assert text =~ "Qualifier"
      assert text =~ ~r/#### .*[Pp]laceholder/
    end

    test "whole-convention spec (no colon) expands to all component names" do
      {:ok, defn} = Definition.new(@real_dir)
      text = Definition.format(defn, components: ["syntax"])
      assert text =~ "Qualifier"
      assert text =~ "Size Indicator"
    end

    test "conv:* spec expands to all component names via the spec parser" do
      {:ok, defn} = Definition.new(@real_dir)
      text = Definition.format(defn, components: ["syntax:*"])
      assert text =~ "Qualifier"
    end

    test "specs merge per convention and take the max priorities" do
      {:ok, defn} = Definition.new(@real_dir)

      text =
        Definition.format(defn, components: [
          "syntax:qualifier",
          %{spec: "syntax:qualifier", component_priority: 2, example_priority: 1},
          %{spec: "syntax:placeholder", component_priority: 0, example_priority: 0}
        ])

      # both components rendered (merge, not overwrite)
      assert text =~ "Qualifier"
      assert text =~ ~r/#### .*[Pp]laceholder/
    end

    test "unknown convention in specs falls through to the extras path" do
      {:ok, defn} = Definition.new(@real_dir)
      text = Definition.format(defn, components: ["bogus-conv:comp"])
      assert text =~ "Error: File not found"
    end

    test "specs for conventions outside section_order still render (extras appended)" do
      {:ok, defn} = Definition.new(@real_dir)

      # fences is a valid section that npl.yaml's section_order omits; with
      # explicit comps it renders via the extras path (file absent -> error text).
      text = Definition.format(defn, components: ["fences:fences-comp"])
      assert text =~ "Error: File not found"
      assert text =~ "fences"
    end

    test "conv:* spec for a convention outside section_order expands to nothing" do
      {:ok, defn} = Definition.new(@real_dir)

      # convention_components is only populated for section_order conventions,
      # so a nil-comps spec for an out-of-order convention drops out entirely.
      text = Definition.format(defn, components: ["fences:*"])
      refute text =~ "Error: File not found"
    end
  end

  # ---------------------------------------------------------------------------
  # ConventionFormatter
  # ---------------------------------------------------------------------------

  describe "ConventionFormatter.format_convention/2" do
    test "renders a real convention concisely by default" do
      text = ConventionFormatter.format_convention("syntax", conventions_dir: @real_dir)

      assert text =~ "# NPL Syntax Overview"
      # concise mode substitutes the brief for the long description
      assert text =~ "Core syntax elements and conventions"
      assert text =~ "### Core Syntax"
      assert text =~ "\"|<qualifier>\""
      assert text =~ ": Appends qualifying instructions"
      # concise rendering includes category example snippets
      assert text =~ "```example"
    end

    test "missing convention file renders an inline error block" do
      text = ConventionFormatter.format_convention("nope-conv", conventions_dir: @real_dir)
      assert text =~ "FORMAT CONVENTION nope-conv"
      assert text =~ "Error: File not found"
    end

    test "heading_offset shifts every heading" do
      text =
        ConventionFormatter.format_convention("syntax",
          conventions_dir: @real_dir,
          heading_offset: 1
        )

      assert text =~ "## NPL Syntax Overview"
      assert text =~ "#### Core Syntax"
      refute text =~ "\n# NPL Syntax"
    end

    test "concise false renders long descriptions, sub-headings and example metadata" do
      text =
        ConventionFormatter.format_convention("syntax",
          conventions_dir: @real_dir,
          example_priority: 2,
          flags: %{"concise" => false}
        )

      assert text =~ "##### Syntax"
      assert text =~ "##### Examples"
      assert text =~ "###### "
      assert text =~ "```purpose"
    end

    test "atom-key flags are honored too" do
      text =
        ConventionFormatter.format_convention("syntax",
          conventions_dir: @real_dir,
          flags: %{concise: false}
        )

      assert text =~ "##### Syntax"
    end

    test "xml flag wraps snippets and threads in npl-example tags" do
      text =
        ConventionFormatter.format_convention("syntax",
          conventions_dir: @real_dir,
          flags: %{"xml" => true}
        )

      assert text =~ "<npl-example>"
      assert text =~ "<msg role="
      refute text =~ "```example"
    end

    test "xml flag wraps example bodies in snippet tags (fixture)" do
      text =
        ConventionFormatter.format_convention("testconv",
          conventions_dir: fixture_dir(%{"testconv.yaml" => @basic_conv}),
          example_priority: 1,
          flags: %{"xml" => true}
        )

      assert text =~ "<npl-example>\n<snippet>\nsimple example\n</snippet>\n</npl-example>"
      assert text =~ "<thread>"
    end

    test "component filter restricts rendering to the named components" do
      text =
        ConventionFormatter.format_convention("syntax",
          conventions_dir: @real_dir,
          components: ["qualifier"]
        )

      assert text =~ "Qualifier"
      refute text =~ "Size Indicator"
    end

    test "priority filtering drops components above component_priority" do
      base = [conventions_dir: fixture_dir(%{"testconv.yaml" => @basic_conv})]

      at_zero = ConventionFormatter.format_convention("testconv", base ++ [component_priority: 0])
      assert at_zero =~ "Component One"
      refute at_zero =~ "Component Two"
      refute at_zero =~ "comp-2"

      at_five = ConventionFormatter.format_convention("testconv", base ++ [component_priority: 5])
      assert at_five =~ "Component One"
      # comp-2 has no friendly-name, so the heading falls back to the raw name
      assert at_five =~ "#### comp-2"
    end

    test "example_priority gates per-component examples" do
      dir = fixture_dir(%{"testconv.yaml" => @basic_conv})

      at_zero =
        ConventionFormatter.format_convention("testconv",
          conventions_dir: dir,
          example_priority: 0
        )

      assert at_zero =~ "simple example"
      refute at_zero =~ "high priority example"

      at_five =
        ConventionFormatter.format_convention("testconv",
          conventions_dir: dir,
          example_priority: 5
        )

      assert at_five =~ "high priority example"
    end

    test "rendered_components are excluded and known for coverage accounting" do
      text =
        ConventionFormatter.format_convention("testconv",
          conventions_dir: fixture_dir(%{"testconv.yaml" => @basic_conv}),
          components: ["comp-1", "comp-2"],
          component_priority: 5,
          rendered_components: MapSet.new(["comp-1"])
        )

      assert text =~ "#### comp-2"
      refute text =~ "Component One"
      # the category example still renders (coverage accounting includes
      # rendered comps as known)
      assert text =~ "Covers both components"
    end

    test "category without rendered components is omitted" do
      text =
        ConventionFormatter.format_convention("testconv",
          conventions_dir: fixture_dir(%{"testconv.yaml" => @basic_conv}),
          components: ["comp-1"]
        )

      assert text =~ "Category A"
      refute text =~ "Category B"
    end

    test "multi-line syntax descriptions get : prefix per line" do
      text =
        ConventionFormatter.format_convention("testconv",
          conventions_dir: fixture_dir(%{"testconv.yaml" => @basic_conv})
        )

      assert text =~ ": first line\n: second line"
    end

    test "category examples without covers fall back to label-based coverage" do
      labels_conv = """
      name: labelsconv
      title: Labels Convention
      categories:
        - name: cat
          title: Cat
          description: d
      components:
        - name: comp-1
          category: cat
          brief: b
          syntax:
            - name: s1
              syntax: "|<x>"
      """

      with_labels = """
      name: labelsconv
      title: Labels Convention
      categories:
        - name: cat
          title: Cat
          description: d
          examples:
            - name: label-example
              brief: covered via label
              labels: ["|<x>"]
      components:
        - name: comp-1
          category: cat
          brief: b
          syntax:
            - name: s1
              syntax: "|<x>"
      """

      no_match =
        ConventionFormatter.format_convention("labelsconv",
          conventions_dir: fixture_dir(%{"labelsconv.yaml" => labels_conv})
        )

      # no covering example -> no category examples block
      refute no_match =~ "Examples"

      matched =
        ConventionFormatter.format_convention("labelsconv",
          conventions_dir: fixture_dir(%{"labelsconv.yaml" => with_labels})
        )

      assert matched =~ "#### Cat Examples"
      assert matched =~ "covered via label"

      # labels that match no component syntax contribute no coverage but do
      # not crash the label-based fallback
      unmatched_labels = String.replace(with_labels, "\"|<x>\"", "\"|<nope>\"", global: false)

      unmatched =
        ConventionFormatter.format_convention("labelsconv",
          conventions_dir: fixture_dir(%{"labelsconv.yaml" => unmatched_labels})
        )

      refute unmatched =~ "Cat Examples"
    end

    test "greedy set-cover stops at three examples when coverage is disjoint" do
      components = ~w(c1 c2 c3 c4)

      yaml =
        Enum.join(
          [
            "name: coverconv",
            "title: Cover Convention",
            "categories:",
            "  - name: cat",
            "    title: Cat",
            "    description: d",
            "    examples:"
          ] ++
            Enum.map(components, fn c ->
              "      - name: ex-#{c}\n        brief: covers #{c}\n        covers: [#{c}]"
            end) ++
            [
              "components:"
            ] ++
            Enum.map(components, fn c ->
              "    - name: #{c}\n      category: cat\n      brief: b"
            end),
          "\n"
        ) <> "\n"

      text =
        ConventionFormatter.format_convention("coverconv",
          conventions_dir: fixture_dir(%{"coverconv.yaml" => yaml})
        )

      assert text =~ "covers c1"
      assert text =~ "covers c2"
      assert text =~ "covers c3"
      refute text =~ "covers c4"
    end

    test "thread-only preference in fallback example selection" do
      yaml = """
      name: threadconv
      title: Thread Convention
      categories:
        - name: cat
          title: Cat
          description: d
      components:
        - name: comp-1
          category: cat
          brief: b
          examples:
            - name: no-thread
              priority: 0
              example: plain
              covers: [comp-1]
            - name: with-thread
              priority: 0
              example: richer
              covers: [comp-1]
              thread:
                - role: user
                  message: hi
      """

      text =
        ConventionFormatter.format_convention("threadconv",
          conventions_dir: fixture_dir(%{"threadconv.yaml" => yaml})
        )

      # fallback selection prefers thread-bearing examples in the category block;
      # both examples still render under the component itself
      [category_block | _] = String.split(text, "#### Cat Examples") |> tl()
      assert category_block =~ "richer"
      refute category_block =~ "plain"
    end

    test "backtick fences grow past content fences (non-xml snippets)" do
      fenced = """
      name: fenceconv
      title: Fence Convention
      categories:
        - name: cat
          title: Cat
          description: d
          examples:
            - name: fenced-example
              brief: has fences
              covers: [comp-1]
              example: |
                ```
                inner fenced content
                ```
      components:
        - name: comp-1
          category: cat
          brief: b
      """

      text =
        ConventionFormatter.format_convention("fenceconv",
          conventions_dir: fixture_dir(%{"fenceconv.yaml" => fenced})
        )

      # content contains ``` so the wrapper fence uses 5 backticks
      assert text =~ "`````example"
      assert text =~ "inner fenced content"
    end

    test "category example thread renders as yaml-ish roles (non-xml)" do
      text =
        ConventionFormatter.format_convention("testconv",
          conventions_dir: fixture_dir(%{"testconv.yaml" => @basic_conv}),
          flags: %{"concise" => false}
        )

      assert text =~ "role: user"
      assert text =~ "message: |"
      assert text =~ "hello there"
    end

    test "non-binary category example body is skipped safely" do
      yaml = """
      name: oddconv
      title: Odd Convention
      categories:
        - name: cat
          title: Cat
          description: d
          examples:
            - name: odd
              brief: brief only
              covers: [comp-1]
      components:
        - name: comp-1
          category: cat
          brief: b
      """

      text =
        ConventionFormatter.format_convention("oddconv",
          conventions_dir: fixture_dir(%{"oddconv.yaml" => yaml})
        )

      assert text =~ "brief only"
    end
  end
end
