defmodule NoizuPromptLingua.NPL.ReaderTest do
  @moduledoc """
  Reader (raw convention introspection for the web UI) and the NoizuPromptLingua.NPL
  config helpers (conventions_dir/version/section_order/concepts/description).

  This is the only engine suite that overrides the `:npl_conventions_dir`
  Application env (Reader has no dir parameter), so it runs async: false; temp
  conventions dirs are fully self-contained and the env is restored on exit.
  """

  use ExUnit.Case, async: false

  alias NoizuPromptLingua.NPL.Reader

  @real_dir Path.join(:code.priv_dir(:noizu_prompt_lingua), "conventions")

  setup do
    Application.delete_env(:noizu_prompt_lingua, :npl_conventions_dir)

    on_exit(fn ->
      Application.delete_env(:noizu_prompt_lingua, :npl_conventions_dir)
    end)

    :ok
  end

  defp use_conventions_dir(files) do
    dir = Path.join(System.tmp_dir!(), "npl-reader-#{System.unique_integer([:positive])}")
    File.mkdir_p!(dir)

    Enum.each(files, fn {name, contents} ->
      File.write!(Path.join(dir, name), contents)
    end)

    Application.put_env(:noizu_prompt_lingua, :npl_conventions_dir, dir)
    on_exit(fn -> File.rm_rf!(dir) end)
    dir
  end

  # ---------------------------------------------------------------------------
  # NoizuPromptLingua.NPL helpers (real conventions dir)
  # ---------------------------------------------------------------------------

  describe "NoizuPromptLingua.NPL config helpers" do
    test "conventions_dir/0 defaults to the app priv conventions dir" do
      dir = NoizuPromptLingua.NPL.conventions_dir()
      assert File.dir?(dir)
      assert dir =~ "conventions"
    end

    test "conventions_dir/0 honors the app env override" do
      dir = use_conventions_dir(%{})
      assert NoizuPromptLingua.NPL.conventions_dir() == dir
    end

    test "version/0 reads the npl.yaml version (raw YAML value, float)" do
      assert NoizuPromptLingua.NPL.version() == 1.0
    end

    test "section_order/0 follows npl.yaml (fences has no file and is absent)" do
      assert NoizuPromptLingua.NPL.section_order() == ~w(syntax declarations pumps directives
                                                        prefixes prompt-sections special-sections)
    end

    test "concepts/0 and description/0 read the npl.yaml preamble" do
      assert NoizuPromptLingua.NPL.concepts() != []
      assert NoizuPromptLingua.NPL.description() != ""
    end

    test "valid_sections/0 lists all eight sections" do
      assert NoizuPromptLingua.NPL.valid_sections() ==
               ~w(syntax declarations directives prefixes prompt-sections special-sections
                  pumps fences)
    end
  end

  describe "NoizuPromptLingua.NPL config helpers (missing/odd npl.yaml)" do
    test "version/0 falls back to 1.0 when npl.yaml is missing" do
      use_conventions_dir(%{})
      assert NoizuPromptLingua.NPL.version() == "1.0"
    end

    test "version/0 stringifies a quoted (non-float) version" do
      use_conventions_dir(%{"npl.yaml" => "/npl:\n  version: \"2.5\"\n"})
      assert NoizuPromptLingua.NPL.version() == "2.5"
    end

    test "section_order/0 falls back to valid_sections without a section_order key" do
      use_conventions_dir(%{"npl.yaml" => "/npl:\n  version: 1.0\n"})
      assert NoizuPromptLingua.NPL.section_order() == NoizuPromptLingua.NPL.valid_sections()
    end

    test "section_order/0 falls back when npl.yaml is missing" do
      use_conventions_dir(%{})
      assert NoizuPromptLingua.NPL.section_order() == NoizuPromptLingua.NPL.valid_sections()
    end

    test "concepts/0 and description/0 degrade to empty on a missing file" do
      use_conventions_dir(%{})
      assert NoizuPromptLingua.NPL.concepts() == []
      assert NoizuPromptLingua.NPL.description() == ""
    end
  end

  # ---------------------------------------------------------------------------
  # Reader against the real conventions dir
  # ---------------------------------------------------------------------------

  describe "Reader (real conventions)" do
    test "sections/0 lists the npl.yaml section order with counts" do
      assert {:ok, sections} = Reader.sections()
      assert Enum.map(sections, & &1.section) == NoizuPromptLingua.NPL.section_order()

      syntax = Enum.find(sections, &(&1.section == "syntax"))
      assert syntax.title == "NPL Syntax Overview"
      assert syntax.component_count > 0
      assert syntax.brief != ""
      assert is_integer(syntax.category_count)
    end

    test "components/1 lists summaries for a section" do
      assert {:ok, comps} = Reader.components("syntax")
      assert comps != []
      assert Enum.all?(comps, &(&1.section == "syntax"))

      qualifier = Enum.find(comps, &(&1.slug == "qualifier"))
      assert qualifier.name == "qualifier"
      assert qualifier.brief =~ "constraints or context"
      assert "inline" in qualifier.labels
      assert qualifier.category == "modifiers"
      assert qualifier.friendly_name == "Qualifier"
    end

    test "components/0 spans all sections" do
      assert {:ok, comps} = Reader.components(nil)
      sections = comps |> Enum.map(& &1.section) |> Enum.uniq()
      assert sections == NoizuPromptLingua.NPL.section_order()
    end

    test "component/2 returns the normalized detail view" do
      assert {:ok, detail} = Reader.component("syntax", "qualifier")

      assert detail.section == "syntax"
      assert detail.name == "qualifier"
      assert detail.friendly_name == "Qualifier"
      assert detail.description != ""
      assert detail.category == "modifiers"
      assert detail.require == ["syntax.placeholder", "syntax.in-fill", "syntax.size-indicator"]
      assert [%{name: "pipe-qualifier", syntax: "|<qualifier>"}] = detail.syntax

      assert Enum.all?(detail.examples, fn ex ->
               is_binary(ex.name) and is_integer(ex.priority) and is_list(ex.thread) and
                 is_list(ex.labels) and is_list(ex.covers)
             end)
    end

    test "component/2 misses return not_found" do
      assert {:error, :not_found} = Reader.component("syntax", "nonexistent-component")
    end

    test "labels/0 returns the taxonomy from npl.yaml" do
      assert {:ok, taxonomy} = Reader.labels()
      assert is_map(taxonomy)
    end

    test "index/0 returns flat search triples" do
      assert {:ok, index} = Reader.index()
      assert index != []

      qualifier = Enum.find(index, &(&1.slug == "qualifier"))
      assert qualifier.section == "syntax"
      assert qualifier.name == "qualifier"
      assert Map.has_key?(qualifier, :friendly_name)
      assert Map.has_key?(qualifier, :category)
    end
  end

  # ---------------------------------------------------------------------------
  # Reader against crafted conventions (error + normalization branches)
  # ---------------------------------------------------------------------------

  describe "Reader (crafted conventions)" do
    test "sections/0 zeroes out sections whose file is missing" do
      use_conventions_dir(%{
        "npl.yaml" => """
        /npl:
          version: 1.0
          section_order:
            components:
              - syntax
              - fences
        """,
        "syntax.yaml" => "name: syntax\ntitle: T\nbrief: b\ncomponents:\n  - name: c1\n"
      })

      assert {:ok, [syntax, fences]} = Reader.sections()
      assert syntax.component_count == 1
      assert fences.title == "Fences"
      assert fences.component_count == 0
      assert fences.brief == ""
    end

    test "sections/0 humanizes the title when the section has none" do
      use_conventions_dir(%{
        "npl.yaml" => "/npl:\n  section_order:\n    components:\n      - prompt-sections\n",
        "prompt-sections.yaml" => "name: prompt-sections\ncomponents: []\n"
      })

      assert {:ok, [sec]} = Reader.sections()
      assert sec.title == "Prompt Sections"
    end

    test "components/0 with an unknown or file-less section yields nothing" do
      use_conventions_dir(%{
        "npl.yaml" => "/npl:\n  section_order:\n    components:\n      - fences\n"
      })

      assert {:ok, []} = Reader.components("fences")
      assert {:ok, []} = Reader.components("bogus-section")
    end

    test "component/2 on an unknown section returns the section error" do
      assert {:error, "Unknown section: 'bogus-section'"} =
               Reader.component("bogus-section", "x")
    end

    test "component/2 on a section without a file returns the file error" do
      use_conventions_dir(%{
        "npl.yaml" => "/npl:\n  section_order:\n    components:\n      - syntax\n"
      })

      assert {:error, msg} = Reader.component("syntax", "x")
      assert msg =~ "Section file not found"
    end

    test "labels/0 degrades to an error without npl.yaml" do
      use_conventions_dir(%{})
      assert {:error, msg} = Reader.labels()
      assert msg =~ "Failed to load npl.yaml"
    end

    test "labels/0 returns the taxonomy block" do
      use_conventions_dir(%{
        "npl.yaml" => """
        /npl:
          version: 1.0
          labels:
            taxonomy:
              scope:
                - core
                - extended
        """
      })

      assert {:ok, %{"scope" => ["core", "extended"]}} = Reader.labels()
    end

    test "detail normalization tolerates odd shapes (string syntax/require/thread)" do
      use_conventions_dir(%{
        "npl.yaml" => "/npl:\n  section_order:\n    components:\n      - syntax\n",
        "syntax.yaml" => """
        name: syntax
        components:
          - name: weird-comp
            syntax: "not-a-list"
            require: "not-a-list"
            examples:
              - title: Titled Example
                brief: has brief
                description: described
                priority: 3
                example: "the example"
                thread: "not-a-list"
                covers: [weird-comp]
        """
      })

      assert {:ok, detail} = Reader.component("syntax", "weird-comp")
      assert detail.syntax == []
      assert detail.require == []
      assert [%{}] = detail.examples

      [example] = detail.examples
      assert example.name == "Titled Example"
      assert example.brief == "has brief"
      assert example.priority == 3
      assert example.thread == []
      assert example.covers == ["weird-comp"]
    end

    test "requires entries that are not strings are stringified" do
      use_conventions_dir(%{
        "npl.yaml" => "/npl:\n  section_order:\n    components:\n      - syntax\n",
        "syntax.yaml" => """
        name: syntax
        components:
          - name: comp
            require:
              - plain
              - 42
        """
      })

      assert {:ok, detail} = Reader.component("syntax", "comp")
      assert detail.require == ["plain", "42"]
    end
  end
end
