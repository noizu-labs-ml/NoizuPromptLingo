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
end
