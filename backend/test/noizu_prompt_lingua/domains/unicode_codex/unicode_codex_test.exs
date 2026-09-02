defmodule NoizuPromptLingua.Domains.UnicodeCodexTest do
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.UnicodeCodex
  alias NoizuPromptLingua.Schema.Organizations.Organization
  alias NoizuPromptLingua.Schema.Projects.Project
  alias NoizuPromptLingua.Schema.Unicode.Element

  test "scope validation rejects impossible layer combinations" do
    changeset =
      Element.changeset(%Element{}, %{
        scope: "project",
        slug: "bad-layer",
        name: "BAD",
        title: "Bad Layer"
      })

    refute changeset.valid?
    assert {"is required for project scope", _} = changeset.errors[:organization_id]
    assert {"is required for project scope", _} = changeset.errors[:project_id]
  end

  test "project entries override organization entries, which override global entries" do
    {org, project} = org_project!()
    usage_slug = unique("usage")
    slug = unique("layered")

    {:ok, _usage} =
      UnicodeCodex.upsert_special_usage(%{
        scope: "global",
        slug: usage_slug,
        name: usage_slug,
        title: "Layer Usage"
      })

    {:ok, _global} = element!(slug, "global", nil, nil, "Global Title", usage_slug)
    {:ok, _org} = element!(slug, "organization", org.id, nil, "Org Title", usage_slug)
    {:ok, _project} = element!(slug, "project", org.id, project.id, "Project Title", usage_slug)

    effective =
      UnicodeCodex.list_elements(organization_id: org.id, project_id: project.id, q: slug)

    assert [%{title: "Project Title", scope: "project", overrides: overrides}] =
             effective.elements

    assert Enum.map(overrides, & &1.scope) == ["organization", "global"]

    all_layers =
      UnicodeCodex.list_elements(
        organization_id: org.id,
        project_id: project.id,
        q: slug,
        include_shadowed: true
      )

    assert all_layers.count == 3
    assert Enum.count(all_layers.elements, &(&1.shadowed_by != nil)) == 2
  end

  test "non-printable control entries expose safe display and warnings" do
    slug = unique("escape")
    usage_slug = unique("hazard")

    {:ok, _usage} =
      UnicodeCodex.upsert_special_usage(%{
        scope: "global",
        slug: usage_slug,
        name: usage_slug,
        title: "Hazard"
      })

    {:ok, element} =
      UnicodeCodex.upsert_element(%{
        scope: "global",
        slug: slug,
        codepoint: "U+001B",
        name: "ESCAPE",
        title: "Escape",
        printable: false,
        visibility: "control",
        flags: ["control", "terminal-sensitive"]
      })

    UnicodeCodex.replace_element_usages(element, [usage_slug], nil, nil)

    {:ok, %{element: detail}} = UnicodeCodex.get_element(slug)
    assert detail.display == "<Escape>"
    assert detail.copy_value == nil
    assert "non_printable" in detail.warnings
    assert "control_sensitive" in detail.warnings
    assert "terminal_sensitive" in detail.warnings
    assert detail.escape_forms.codepoint == "U+001B"
  end

  test "Unicode.Search MCP tool uses the same effective scope resolution" do
    {org, _project} = org_project!()
    slug = unique("mcp")

    {:ok, _element} =
      UnicodeCodex.upsert_element(%{
        scope: "organization",
        organization_id: org.id,
        slug: slug,
        codepoint: "U+231C",
        char: "⌜",
        name: "TOP LEFT CORNER",
        title: "MCP Scoped Corner",
        flags: ["npl"],
        topics: ["npl-syntax"]
      })

    assert {:ok, %{elements: [result], count: 1}} =
             NoizuPromptLingua.Domains.UnicodeCodex.Tools.Search.call(
               %{"organization" => org.id, "query" => slug},
               %{}
             )

    assert result.slug == slug
    assert result.scope == "organization"
  end

  # ── Scope resolution ─────────────────────────────────────────────

  describe "list_elements scope resolution" do
    test "unscoped requests see only global rows" do
      {org, _project} = org_project!()
      slug = unique("scopes")
      upsert_element!(slug: slug, title: "Global #{slug}")
      upsert_element!(slug: slug, scope: "organization", organization_id: org.id, title: "Org")

      %{count: count, elements: elements} = UnicodeCodex.list_elements(q: slug)

      assert count == 1
      assert [%{scope: "global", title: "Global " <> ^slug}] = elements
    end

    test "blank-string scope filters are treated as absent" do
      {org, _project} = org_project!()
      slug = unique("blank")
      upsert_element!(slug: slug, title: "Global #{slug}")

      assert %{count: 1} = UnicodeCodex.list_elements(organization_id: "", project_id: "", q: slug)

      # and an org row is invisible under a blank org id
      upsert_element!(slug: slug, scope: "organization", organization_id: org.id, title: "Org")
      assert %{count: 1} = UnicodeCodex.list_elements(organization_id: "", q: slug)
    end

    test "org scope sees global + own org rows, never another org's rows" do
      {org_a, _} = org_project!()
      {org_b, _} = org_project!()
      slug = unique("cross")

      upsert_element!(slug: slug, title: "Global")
      upsert_element!(slug: slug, scope: "organization", organization_id: org_a.id, title: "A")
      upsert_element!(slug: slug, scope: "organization", organization_id: org_b.id, title: "B")

      # default (effective) view: layers collapse to the winning row
      assert %{count: 1, elements: [effective]} =
               UnicodeCodex.list_elements(organization_id: org_a.id, q: slug)

      assert %{scope: "organization", title: "A", overrides: [%{scope: "global"}]} = effective

      # include_shadowed view: every visible layer, org_b's row still excluded
      all =
        UnicodeCodex.list_elements(
          organization_id: org_a.id,
          q: slug,
          include_shadowed: true
        )

      assert all.count == 2
      titles = Enum.map(all.elements, & &1.title)
      assert "B" not in titles
      assert Enum.sort(titles) == ["A", "Global"]
    end

    test "org scope without project id hides project rows" do
      {org, project} = org_project!()
      slug = unique("layered2")
      upsert_element!(slug: slug, title: "Global")
      upsert_element!(slug: slug, scope: "organization", organization_id: org.id, title: "Org")
      upsert_element!(
        slug: slug,
        scope: "project",
        organization_id: org.id,
        project_id: project.id,
        title: "Project"
      )

      assert %{count: 1, elements: [effective]} =
               UnicodeCodex.list_elements(organization_id: org.id, q: slug)

      assert effective.scope == "organization"
      assert Enum.map(effective.overrides, & &1.scope) == ["global"]
    end

    test "count reflects all matches while elements honors limit/offset" do
      prefix = unique("paged")

      for title <- ["One", "Two", "Three"] do
        upsert_element!(slug: "#{prefix}-#{String.downcase(title)}", title: title)
      end

      opts = [q: prefix]
      assert %{count: 3, elements: elements} = UnicodeCodex.list_elements(opts ++ [limit: 2])
      assert length(elements) == 2

      assert %{elements: [second]} = UnicodeCodex.list_elements(opts ++ [limit: 1, offset: 1])

      # downcased title sort: One, Three, Two
      assert second.title == "Three"
    end

    test "limit accepts binaries and clamps to at least one row" do
      slug = unique("clamp")
      upsert_element!(slug: slug, title: "Solo")

      assert %{elements: [element]} = UnicodeCodex.list_elements(q: slug, limit: 0)
      assert element.slug == slug

      assert %{elements: [_]} = UnicodeCodex.list_elements(q: slug, limit: "1", offset: "0")
      assert %{elements: [_]} = UnicodeCodex.list_elements(q: slug, limit: "", offset: "")
      assert %{elements: [_]} = UnicodeCodex.list_elements(q: slug, limit: "bogus")
      # negative offsets clamp to zero
      assert %{elements: [_]} = UnicodeCodex.list_elements(q: slug, offset: -5)
    end

    test "rows sort by downcased title then slug" do
      prefix = unique("sort")
      upsert_element!(slug: "#{prefix}-b", title: "banana")
      upsert_element!(slug: "#{prefix}-a", title: "Apple")
      upsert_element!(slug: "#{prefix}-a2", title: "Apple")

      %{elements: elements} = UnicodeCodex.list_elements(q: prefix)

      assert Enum.map(elements, & &1.slug) == [
               "#{prefix}-a",
               "#{prefix}-a2",
               "#{prefix}-b"
             ]
    end
  end

  # ── Filters (DB + in-memory paths) ───────────────────────────────

  describe "list_elements filters" do
    setup do
      {org, _project} = org_project!()
      slug = unique("filter")

      element =
        upsert_element!(
          slug: slug,
          title: "Filterable",
          printable: false,
          visibility: "control",
          flags: ["npl", "terminal-sensitive"],
          topics: ["syntax"],
          sentiments: ["negative"],
          aliases: ["esc-char"],
          search_terms: ["esc-key"],
          description: "escape hatch"
        )

      %{org: org, slug: slug, element: element}
    end

    test "in-memory printable filter handles strings and booleans", %{slug: slug} do
      assert %{count: 0} = UnicodeCodex.list_elements(q: slug, printable: true)
      assert %{count: 1} = UnicodeCodex.list_elements(q: slug, printable: false)
      assert %{count: 1} = UnicodeCodex.list_elements(q: slug, printable: "false")
      assert %{count: 1} = UnicodeCodex.list_elements(q: slug, printable: "")
      assert %{count: 1} = UnicodeCodex.list_elements(q: slug)
    end

    test "in-memory visibility/flag/topic/sentiment filters", %{slug: slug} do
      assert %{count: 1} = UnicodeCodex.list_elements(q: slug, visibility: "control")
      assert %{count: 0} = UnicodeCodex.list_elements(q: slug, visibility: "glyph")
      # blank strings mean "no filter"
      assert %{count: 1} = UnicodeCodex.list_elements(q: slug, visibility: "")
      assert %{count: 1} = UnicodeCodex.list_elements(q: slug, flag: "terminal-sensitive")
      assert %{count: 0} = UnicodeCodex.list_elements(q: slug, flag: "missing")
      assert %{count: 1} = UnicodeCodex.list_elements(q: slug, flag: "")
      assert %{count: 1} = UnicodeCodex.list_elements(q: slug, topic: "syntax")
      assert %{count: 0} = UnicodeCodex.list_elements(q: slug, topic: "other")
      assert %{count: 1} = UnicodeCodex.list_elements(q: slug, topic: "")
      assert %{count: 1} = UnicodeCodex.list_elements(q: slug, sentiment: "negative")
      assert %{count: 0} = UnicodeCodex.list_elements(q: slug, sentiment: "positive")
    end

    test "in-memory usage filter matches loaded special usages", %{slug: slug, element: element} do
      usage = upsert_usage!(slug: unique("umem"), title: "Usage Match")
      UnicodeCodex.replace_element_usages(element, [usage.slug], nil, nil)

      assert %{count: 1} = UnicodeCodex.list_elements(q: slug, usage: usage.slug)
      assert %{count: 0} = UnicodeCodex.list_elements(q: slug, usage: "no-such-usage")
      assert %{count: 1} = UnicodeCodex.list_elements(q: slug, usage: "")
    end

    test "in-memory q search covers codepoint, name, description, aliases, search terms", %{
      slug: _slug
    } do
      for needle <- ["letter a", "U+0041", "escape hatch", "esc-char", "esc-key", "FILTERAB"] do
        assert %{count: 1} = UnicodeCodex.list_elements(q: needle), "needle: #{needle}"
      end

      assert %{count: 0} = UnicodeCodex.list_elements(q: "zebra")
    end

    test "query alias behaves like q", %{slug: slug} do
      assert %{count: 1} = UnicodeCodex.list_elements(query: slug)
      # blank query = no filter
      assert %{count: 1} = UnicodeCodex.list_elements(query: "")
    end

    test "include_shadowed pushes identical filters into the DB query", %{slug: slug} do
      assert %{count: 1} =
               UnicodeCodex.list_elements(
                 q: slug,
                 include_shadowed: true,
                 printable: false,
                 visibility: "control",
                 flag: "npl",
                 topic: "syntax",
                 sentiment: "negative"
               )

      assert %{count: 0} =
               UnicodeCodex.list_elements(
                 q: slug,
                 include_shadowed: true,
                 printable: true
               )

      assert %{count: 0} =
               UnicodeCodex.list_elements(q: slug, include_shadowed: true, visibility: "glyph")

      assert %{count: 0} =
               UnicodeCodex.list_elements(q: slug, include_shadowed: true, flag: "missing")

      assert %{count: 0} =
               UnicodeCodex.list_elements(q: slug, include_shadowed: true, topic: "other")

      assert %{count: 0} =
               UnicodeCodex.list_elements(q: slug, include_shadowed: true, sentiment: "positive")
    end

    test "DB usage filter joins through element usages", %{slug: slug, element: element} do
      usage = upsert_usage!(slug: unique("udb"), title: "Usage DB")
      UnicodeCodex.replace_element_usages(element, [usage.slug], nil, nil)

      assert %{count: 1} =
               UnicodeCodex.list_elements(q: slug, usage: usage.slug, include_shadowed: true)

      assert %{count: 0} =
               UnicodeCodex.list_elements(
                 q: slug,
                 usage: "missing-usage",
                 include_shadowed: true
               )
    end

    test "DB q search matches array columns via SQL", %{slug: _slug} do
      assert %{count: 1} =
               UnicodeCodex.list_elements(q: "esc-key", include_shadowed: true)

      assert %{count: 0} =
               UnicodeCodex.list_elements(q: "zebra", include_shadowed: true)
    end
  end

  # ── get_element ──────────────────────────────────────────────────

  describe "get_element" do
    test "unknown slugs are not found" do
      assert {:error, :not_found} = UnicodeCodex.get_element(unique("ghost"))
    end

    test "slug lookup normalizes case and whitespace" do
      slug = unique("norm")
      upsert_element!(slug: slug, title: "Normalized")

      assert {:ok, _} = UnicodeCodex.get_element("  #{String.upcase(slug)}  ")
    end

    test "returns effective row with layers ordered highest scope first" do
      {org, project} = org_project!()
      slug = unique("detail")
      usage = upsert_usage!(slug: unique("du"), title: "Detail Usage")

      global = upsert_element!(slug: slug, title: "Global")
      UnicodeCodex.replace_element_usages(global, [usage.slug], nil, nil)
      upsert_element!(slug: slug, scope: "organization", organization_id: org.id, title: "Org")
      upsert_element!(
        slug: slug,
        scope: "project",
        organization_id: org.id,
        project_id: project.id,
        title: "Project"
      )

      assert {:ok, %{element: detail, layers: layers}} =
               UnicodeCodex.get_element(slug, organization_id: org.id, project_id: project.id)

      assert detail.title == "Project"
      assert Enum.map(layers, & &1.scope) == ["project", "organization", "global"]
      assert [top, org_layer, global_layer] = layers
      assert top.shadowed_by == nil
      assert top.overrides |> Enum.map(& &1.scope) |> Enum.sort() == ["global", "organization"]

      assert org_layer.shadowed_by.slug == slug
      assert org_layer.shadowed_by.scope == "project"
      assert Enum.map(org_layer.overrides, & &1.scope) == ["global"]

      assert global_layer.overrides == []
      assert global_layer.shadowed_by.slug == slug

      # usage links are per-layer: the project (effective) row has none, the
      # global layer they were attached to carries them
      assert detail.special_usages == []
      usage_slug = usage.slug

      assert [%{slug: ^usage_slug, title: "Detail Usage", scope: "global"}] =
               List.last(layers).special_usages

      assert List.last(layers).special_usage_count == 1
      assert detail.relations == []
    end

    test "detail includes outgoing relations with targets" do
      source = upsert_element!(slug: unique("rel-src"), title: "Source")
      target = upsert_element!(slug: unique("rel-dst"), title: "Target")
      insert_relation!(source, target, "confusable-with", %{"note" => "looks alike"})

      assert {:ok, %{element: detail}} = UnicodeCodex.get_element(source.slug)

      assert [%{relation_type: "confusable-with", metadata: %{"note" => "looks alike"}}] =
               detail.relations

      assert hd(detail.relations).target.slug == target.slug
    end
  end

  # ── Special usages ───────────────────────────────────────────────

  describe "special usages" do
    test "list honors scope, filters, and sorting" do
      {org, _} = org_project!()
      prefix = unique("su")

      upsert_usage!(slug: "#{prefix}-b", title: "beta", flags: ["core"])
      upsert_usage!(slug: "#{prefix}-a", title: "Alpha", topics: ["syntax"])
      upsert_usage!(slug: "#{prefix}-o", scope: "organization", organization_id: org.id, title: "org-only")

      assert %{count: 2, special_usages: usages} = UnicodeCodex.list_special_usages(q: prefix)
      assert Enum.map(usages, & &1.slug) == ["#{prefix}-a", "#{prefix}-b"]

      assert %{count: 3} =
               UnicodeCodex.list_special_usages(
                 q: prefix,
                 organization_id: org.id,
                 include_shadowed: true
               )

      # org scope: all three slugs visible (distinct slugs → three effective rows)
      assert %{count: 3, special_usages: scoped} =
               UnicodeCodex.list_special_usages(q: prefix, organization_id: org.id)

      assert "org-only" in Enum.map(scoped, & &1.title)

      assert %{count: 1} = UnicodeCodex.list_special_usages(q: prefix, flag: "core")
      # blank strings mean "no filter"
      assert %{count: 2} = UnicodeCodex.list_special_usages(q: prefix, flag: "")
      assert %{count: 1} = UnicodeCodex.list_special_usages(q: prefix, topic: "syntax")
      assert %{count: 0} = UnicodeCodex.list_special_usages(q: prefix, topic: "missing")

      # description participates in the usage search
      upsert_usage!(slug: "#{prefix}-d", title: "Hidden", description: "xyzzy-glory")
      assert %{count: 1} = UnicodeCodex.list_special_usages(q: "xyzzy-glory")
    end

    test "get_special_usage resolves layers or not_found" do
      {org, _} = org_project!()
      slug = unique("sud")

      upsert_usage!(slug: slug, title: "Global")
      assert {:error, :not_found} = UnicodeCodex.get_special_usage(unique("ghost-usage"))

      upsert_usage!(slug: slug, scope: "organization", organization_id: org.id, title: "Org")

      assert {:ok, %{special_usage: effective, layers: layers}} =
               UnicodeCodex.get_special_usage(String.upcase(slug),
                 organization_id: org.id
               )

      assert effective.title == "Org"
      assert Enum.map(layers, & &1.scope) == ["organization", "global"]
      assert hd(layers).shadowed_by == nil
      assert List.last(layers).shadowed_by.slug == slug
    end
  end

  # ── related / count ──────────────────────────────────────────────

  describe "related and count" do
    test "count delegates to list_elements" do
      slug = unique("cnt")
      upsert_element!(slug: slug, title: "Counted")
      assert UnicodeCodex.count(q: slug) == 1
      assert UnicodeCodex.count() >= 1
    end

    test "related returns relations for an effective element" do
      source = upsert_element!(slug: unique("r-src"), title: "Source")
      target = upsert_element!(slug: unique("r-dst"), title: "Target")
      insert_relation!(source, target, "same-topic")

      assert {:ok, %{relations: [relation], count: 1}} =
               UnicodeCodex.related(source.slug)

      assert relation.relation_type == "same-topic"
      assert relation.description == nil
      assert relation.metadata == %{}
      assert relation.target.slug == target.slug
      assert relation.target.shadowed_by == nil
    end

    test "related is not_found for unknown slugs" do
      assert {:error, :not_found} = UnicodeCodex.related(unique("r-ghost"))
    end

    test "related falls back to the raw target row when out of caller scope" do
      {org_a, _} = org_project!()
      source = upsert_element!(slug: unique("r2-src"), title: "Source")

      foreign =
        upsert_element!(
          slug: unique("r2-foreign"),
          scope: "organization",
          organization_id: org_a.id,
          title: "Foreign Target"
        )

      insert_relation!(source, foreign, "variant-of")

      # no scope: foreign org row is not effective, raw row is used as target
      assert {:ok, %{relations: [relation]}} = UnicodeCodex.related(source.slug)
      assert relation.target.title == "Foreign Target"
      assert relation.target.scope == "organization"
    end

    test "related resolves effective (global) rows for scoped callers" do
      {org, project} = org_project!()
      source = upsert_element!(slug: unique("r3-src"), title: "Source")
      target = upsert_element!(slug: unique("r3-dst"), title: "Global Target")
      insert_relation!(source, target, "related-control")

      assert {:ok, %{relations: [relation]}} =
               UnicodeCodex.related(source.slug, organization_id: org.id, project_id: project.id)

      assert relation.target.title == "Global Target"
    end
  end

  # ── Upserts + seed helpers ───────────────────────────────────────

  describe "upserts" do
    test "upsert_element inserts then updates in place (global scope)" do
      slug = unique("up")
      {:ok, first} = UnicodeCodex.upsert_element(%{slug: slug, name: "N", title: "V1"})
      {:ok, second} = UnicodeCodex.upsert_element(%{slug: slug, name: "N", title: "V2"})

      assert first.id == second.id
      assert second.title == "V2"
    end

    test "upsert accepts string keys and normalizes slug" do
      slug = unique("strk")

      {:ok, element} =
        UnicodeCodex.upsert_element(%{
          "scope" => "global",
          "slug" => "  #{String.upcase(slug)}  ",
          "name" => "N",
          "title" => "String Keys"
        })

      assert element.scope == "global"
      assert element.slug == slug
    end

    test "org and project layers do not collide with the global row" do
      {org, project} = org_project!()
      slug = unique("layers3")

      {:ok, global} = UnicodeCodex.upsert_element(%{slug: slug, name: "N", title: "G"})

      {:ok, org_row} =
        UnicodeCodex.upsert_element(%{
          slug: slug,
          scope: "organization",
          organization_id: org.id,
          name: "N",
          title: "O"
        })

      {:ok, project_row} =
        UnicodeCodex.upsert_element(%{
          slug: slug,
          scope: "project",
          organization_id: org.id,
          project_id: project.id,
          name: "N",
          title: "P"
        })

      refute global.id == org_row.id
      refute org_row.id == project_row.id
      # updating the org layer leaves the other layers alone
      {:ok, updated} =
        UnicodeCodex.upsert_element(%{
          slug: slug,
          scope: "organization",
          organization_id: org.id,
          name: "N",
          title: "O2"
        })

      assert updated.id == org_row.id
      assert updated.title == "O2"
    end

    test "upsert_special_usage mirrors element behavior" do
      {org, _} = org_project!()
      slug = unique("su-up")

      {:ok, global} = UnicodeCodex.upsert_special_usage(%{slug: slug, name: "N", title: "G"})

      {:ok, org_row} =
        UnicodeCodex.upsert_special_usage(%{
          slug: slug,
          scope: "organization",
          organization_id: org.id,
          name: "N",
          title: "O"
        })

      refute global.id == org_row.id

      {:ok, updated} =
        UnicodeCodex.upsert_special_usage(%{slug: String.upcase(slug), name: "N", title: "G2"})

      assert updated.id == global.id
      assert updated.title == "G2"
    end

    test "effective_element_by_slug / effective_special_usage_by_slug resolve layers" do
      {org, project} = org_project!()
      slug = unique("eff")

      upsert_element!(slug: slug, title: "Global")
      assert %{title: "Global"} = UnicodeCodex.effective_element_by_slug(slug, nil, nil)
      assert nil == UnicodeCodex.effective_element_by_slug(unique("missing"), nil, nil)

      upsert_element!(slug: slug, scope: "organization", organization_id: org.id, title: "Org")
      assert %{title: "Org"} = UnicodeCodex.effective_element_by_slug(slug, org.id, project.id)

      usage = upsert_usage!(slug: slug, title: "Usage Global")

      assert %{title: "Usage Global"} =
               UnicodeCodex.effective_special_usage_by_slug(" #{String.upcase(slug)} ", nil, nil)

      assert usage.slug == slug
      assert nil == UnicodeCodex.effective_special_usage_by_slug(unique("missing-u"), nil, nil)
    end
  end

  describe "replace_element_usages / replace_element_relations" do
    test "wraps single slugs, normalizes, and rejects blanks without raising" do
      {org, project} = org_project!()
      element = upsert_element!(slug: unique("ru-e"), title: "E")
      usage_a = upsert_usage!(slug: unique("ru-a"), title: "A")
      upsert_usage!(slug: unique("ru-b"), title: "B")

      assert :ok =
               UnicodeCodex.replace_element_usages(
                 element,
                 ["  #{String.upcase(usage_a.slug)}  ", nil, usage_a.slug],
                 org.id,
                 project.id
               )

      assert refreshed_usages!(element) == [usage_a.slug]

      # quirk: blank (non-nil) slugs normalize to "" and raise rather than skip
      assert_raise RuntimeError, ~r/Unicode special usage '' not found/, fn ->
        UnicodeCodex.replace_element_usages(element, ["   "], org.id, project.id)
      end
    end

    test "unknown usage slug raises" do
      element = upsert_element!(slug: unique("ru-x"), title: "X")

      assert_raise RuntimeError, ~r/not found for element/, fn ->
        UnicodeCodex.replace_element_usages(element, ["nope-#{unique("x")}"], nil, nil)
      end
    end

    test "duplicate usage links are collapsed by on_conflict" do
      element = upsert_element!(slug: unique("ru-dup"), title: "Dup")
      usage = upsert_usage!(slug: unique("ru-dup-u"), title: "DupU")

      assert :ok = UnicodeCodex.replace_element_usages(element, [usage.slug, usage.slug], nil, nil)
      assert refreshed_usages!(element) == [usage.slug]
    end

    test "relations accept string and atom spec keys and default metadata" do
      {org, project} = org_project!()
      element = upsert_element!(slug: unique("rr-e"), title: "E")
      target = upsert_element!(slug: unique("rr-t"), title: "T")

      assert :ok =
               UnicodeCodex.replace_element_relations(
                 element,
                 [
                   %{"type" => "same-topic", "target" => target.slug},
                   %{type: "composes-with", target: target.slug, description: "stacks"}
                 ],
                 org.id,
                 project.id
               )

      assert {:ok, %{element: detail}} = UnicodeCodex.get_element(element.slug)

      types = Enum.map(detail.relations, & &1.relation_type)
      assert Enum.sort(types) == ["composes-with", "same-topic"]
      assert Enum.all?(detail.relations, &(&1.metadata == %{}))
      assert hd(detail.relations).target.slug == target.slug
    end

    test "relations replace prior rows and collapse duplicates" do
      element = upsert_element!(slug: unique("rr-rep"), title: "E")
      t1 = upsert_element!(slug: unique("rr-t1"), title: "T1")
      t2 = upsert_element!(slug: unique("rr-t2"), title: "T2")

      :ok = UnicodeCodex.replace_element_relations(element, [%{"type" => "same-topic", "target" => t1.slug}], nil, nil)
      :ok = UnicodeCodex.replace_element_relations(element, [%{"type" => "variant-of", "target" => t2.slug}], nil, nil)

      assert {:ok, %{element: detail, layers: _}} = UnicodeCodex.get_element(element.slug)
      assert [%{relation_type: "variant-of"}] = detail.relations

      # duplicate spec within one call → second insert conflicts → :nothing
      :ok =
        UnicodeCodex.replace_element_relations(
          element,
          [%{"type" => "variant-of", "target" => t2.slug}, %{"type" => "variant-of", "target" => t2.slug}],
          nil,
          nil
        )

      assert {:ok, %{element: detail}} = UnicodeCodex.get_element(element.slug)
      assert length(detail.relations) == 1
    end

    test "unknown relation target raises" do
      element = upsert_element!(slug: unique("rr-x"), title: "X")

      assert_raise RuntimeError, ~r/Unicode relation target/, fn ->
        UnicodeCodex.replace_element_relations(
          element,
          [%{"type" => "same-topic", "target" => "ghost-target"}],
          nil,
          nil
        )
      end
    end
  end

  # ── JSON helpers (pure) ──────────────────────────────────────────

  describe "element_json presentation rules" do
    test "unsafe visibility renders as <title> and blocks copy" do
      for visibility <- ["control", "invisible", "space", "combining", "directional"] do
        json = UnicodeCodex.element_json(bare_element(visibility: visibility, title: "Danger"))
        assert json.display == "<Danger>"
        assert json.copy_value == nil
      end
    end

    test "safe printable rows expose char for display and copy" do
      json = UnicodeCodex.element_json(bare_element(char: "A", printable: true))
      assert json.display == "A"
      assert json.copy_value == "A"
    end

    test "safe but non-printable rows show char yet block copy" do
      json = UnicodeCodex.element_json(bare_element(char: "A", printable: false))
      assert json.display == "A"
      assert json.copy_value == nil
    end

    test "empty char falls back to <title> display and nil copy" do
      json = UnicodeCodex.element_json(bare_element(char: "", title: "Empty"))
      assert json.display == "<Empty>"
      assert json.copy_value == nil
    end

    test "nil array/meta fields coalesce to empty containers" do
      json = UnicodeCodex.element_json(bare_element())

      assert json.unicode == %{}
      assert json.flags == []
      assert json.topics == []
      assert json.sentiments == []
      assert json.aliases == []
      assert json.search_terms == []
      assert json.special_usages == []
      assert json.special_usage_count == 0
      assert json.overrides == []
      assert json.shadowed_by == nil
      assert json.escape_forms == %{}
    end

    test "warnings compose in source order" do
      json =
        UnicodeCodex.element_json(
          bare_element(
            printable: false,
            visibility: "invisible",
            flags: ["terminal-sensitive"]
          )
        )

      assert json.warnings == ["non_printable", "invisible_sensitive", "terminal_sensitive"]
    end

    test "clean rows carry no warnings" do
      assert UnicodeCodex.element_json(bare_element(char: "A")).warnings == []
    end
  end

  describe "escape_forms" do
    test "multiple codepoints render unicode/hex/html forms" do
      json = UnicodeCodex.element_json(bare_element(codepoint: "U+0041 U+0042"))

      assert json.escape_forms.unicode == ["\\u0041", "\\u0042"]
      assert json.escape_forms.hex == ["\\x41", "\\x42"]
      assert json.escape_forms.html == ["&#x41;", "&#x42;"]
    end

    test "wide codepoints keep unicode/html but drop overlong hex" do
      json = UnicodeCodex.element_json(bare_element(codepoint: "U+231C"))

      assert json.escape_forms.unicode == ["\\u231C"]
      assert json.escape_forms.hex == []
      assert json.escape_forms.html == ["&#x231C;"]
    end

    test "\\u and \\x notations parse as codepoints" do
      json = UnicodeCodex.element_json(bare_element(codepoint: "\\u0041 \\x42"))

      assert json.escape_forms.unicode == ["\\u0041", "\\u0042"]
    end
  end

  describe "layers and refs" do
    test "shadowed_by/overrides are computed from layer ranks" do
      {org, project} = org_project!()
      slug = unique("lay")

      global = upsert_element!(slug: slug, title: "G")
      org_row = upsert_element!(slug: slug, scope: "organization", organization_id: org.id, title: "O")

      project_row =
        upsert_element!(
          slug: slug,
          scope: "project",
          organization_id: org.id,
          project_id: project.id,
          title: "P"
        )

      rows = [global, org_row, project_row]

      g = UnicodeCodex.element_json(global, rows)
      o = UnicodeCodex.element_json(org_row, rows)
      p = UnicodeCodex.element_json(project_row, rows)

      assert g.overrides == []
      assert g.shadowed_by.scope == "project"

      assert Enum.map(o.overrides, & &1.scope) == ["global"]
      assert o.shadowed_by.scope == "project"

      assert p.overrides |> Enum.map(& &1.scope) |> Enum.sort() == ["global", "organization"]
      assert p.shadowed_by == nil

      for ref <- [g.shadowed_by, hd(o.overrides)] do
        assert Enum.sort(Map.keys(ref)) ==
                 Enum.sort([:id, :slug, :scope, :organization_id, :project_id])
      end
    end
  end

  describe "scope_rank" do
    test "project > organization > global > unknown" do
      assert UnicodeCodex.scope_rank(%{scope: "project"}) == 2
      assert UnicodeCodex.scope_rank(%{scope: "organization"}) == 1
      assert UnicodeCodex.scope_rank(%{scope: "global"}) == 0
      assert UnicodeCodex.scope_rank(%{scope: "bogus"}) == -1
      assert UnicodeCodex.scope_rank(%{}) == -1
    end
  end

  # ── helpers ──────────────────────────────────────────────────────

  defp refreshed_usages!(element) do
    element =
      NoizuPromptLingua.Repo.reload!(element)
      |> NoizuPromptLingua.Repo.preload(:special_usages)

    Enum.map(element.special_usages, & &1.slug)
  end

  defp element!(slug, scope, org_id, project_id, title, usage_slug) do
    result =
      UnicodeCodex.upsert_element(%{
        scope: scope,
        organization_id: org_id,
        project_id: project_id,
        slug: slug,
        codepoint: "U+231C",
        char: "⌜",
        name: "TOP LEFT CORNER",
        title: title,
        flags: ["npl"],
        topics: ["npl-syntax"]
      })

    {:ok, element} = result
    UnicodeCodex.replace_element_usages(element, [usage_slug], org_id, project_id)
    result
  end

  defp org_project! do
    suffix = System.unique_integer([:positive])

    org =
      NoizuPromptLingua.Repo.insert!(%Organization{
        id: Ecto.UUID.generate(),
        slug: "unicode-org-#{suffix}",
        name: "Unicode Org #{suffix}"
      })

    project =
      NoizuPromptLingua.Repo.insert!(%Project{
        id: Ecto.UUID.generate(),
        organization_id: org.id,
        slug: "unicode-project-#{suffix}",
        name: "Unicode Project #{suffix}"
      })

    {org, project}
  end

  defp unique(prefix), do: "#{prefix}-#{System.unique_integer([:positive])}"

  # ── Additional helpers (coverage expansion) ─────────────────────

  defp upsert_element!(attrs) do
    attrs =
      Map.merge(
        %{
          scope: "global",
          codepoint: "U+0041",
          char: "A",
          name: "LATIN CAPITAL LETTER A",
          title: "Letter A"
        },
        Map.new(attrs, fn {k, v} -> {k, v} end)
      )

    {:ok, element} = UnicodeCodex.upsert_element(attrs)
    element
  end

  defp upsert_usage!(attrs) do
    attrs = Map.merge(%{scope: "global", name: "usage", title: "Usage"}, Map.new(attrs))
    {:ok, usage} = UnicodeCodex.upsert_special_usage(attrs)
    usage
  end

  defp insert_relation!(source, target, type, metadata \\ %{}) do
    {:ok, relation} =
      %NoizuPromptLingua.Schema.Unicode.ElementRelation{}
      |> NoizuPromptLingua.Schema.Unicode.ElementRelation.changeset(%{
        source_element_id: source.id,
        target_element_id: target.id,
        relation_type: type,
        metadata: metadata
      })
      |> NoizuPromptLingua.Repo.insert()

    relation
  end

  # Bare map hitting element_json's nil-coalescing branches without a DB row.
  defp bare_element(overrides \\ []) do
    Map.merge(
      %{
        id: nil,
        scope: "global",
        organization_id: nil,
        project_id: nil,
        slug: "bare",
        codepoint: nil,
        codepoint_int: nil,
        char: nil,
        name: "BARE",
        title: "Bare",
        description: nil,
        meaning: nil,
        printable: true,
        visibility: "glyph",
        unicode_meta: nil,
        flags: nil,
        topics: nil,
        sentiments: nil,
        aliases: nil,
        search_terms: nil
      },
      Map.new(overrides)
    )
  end
end
