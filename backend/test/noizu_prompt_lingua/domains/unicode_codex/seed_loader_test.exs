defmodule NoizuPromptLingua.Domains.UnicodeCodex.SeedLoaderTest do
  @moduledoc """
  UnicodeCodex.SeedLoader — layered YAML seeding (global → organization →
  project) plus every scope-resolution failure branch.

  Seed fixtures are written to a per-test tmp dir, so no dependency on the
  contents of priv/unicode-codex.
  """
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.UnicodeCodex
  alias NoizuPromptLingua.Domains.UnicodeCodex.SeedLoader
  alias NoizuPromptLingua.Schema.Organizations.Organization
  alias NoizuPromptLingua.Schema.Projects.Project

  setup do
    suffix = System.unique_integer([:positive])

    org =
      Repo.insert!(%Organization{
        id: Ecto.UUID.generate(),
        slug: "seed-org-#{suffix}",
        name: "Seed Org #{suffix}"
      })

    project =
      Repo.insert!(%Project{
        id: Ecto.UUID.generate(),
        organization_id: org.id,
        slug: "seed-project-#{suffix}",
        name: "Seed Project #{suffix}"
      })

    dir = Path.join(System.tmp_dir!(), "ucodex-seed-#{suffix}")
    File.mkdir_p!(Path.join(dir, "organizations"))
    File.mkdir_p!(Path.join([dir, "projects", org.slug]))
    on_exit(fn -> File.rm_rf!(dir) end)

    %{org: org, project: project, dir: dir}
  end

  test "default_dir/0 points at the priv seed directory" do
    assert String.ends_with?(SeedLoader.default_dir(), "unicode-codex")
  end

  test "seed_all!/1 loads the global, organization, and project layers", %{
    org: org,
    project: project,
    dir: dir
  } do
    u = System.unique_integer([:positive])

    write(dir, "global.yaml", """
    scope:
      type: global
    special_usages:
      - slug: usage-#{u}
        name: usage-#{u}
        title: Seeded Usage
        description: seeded
    references:
      - url: https://unicode.org
        label: Unicode
        flags: ["editorial"]
        topics: ["npl"]
    elements:
      - slug: el-global-#{u}
        codepoint: "U+231C"
        char: "⌜"
        name: TOP LEFT CORNER
        title: Global Corner
        description: corner glyph
        meaning: NPL corner
        printable: false
        visibility: control
        unicode:
          block: Miscellaneous Technical
        flags: ["npl"]
        topics: ["npl-syntax"]
        sentiments: ["neutral"]
        aliases: ["tlc"]
        search_terms: ["corner"]
        special_usages:
          - usage-#{u}
    """)

    write(dir, "organizations/#{org.slug}.yaml", """
    scope:
      type: organization
      organization: #{org.slug}
    elements:
      - slug: el-global-#{u}
        codepoint: "U+231C"
        char: "⌜"
        name: TOP LEFT CORNER
        title: Org Corner
    """)

    write(dir, "projects/#{org.slug}/#{project.slug}.yaml", """
    scope:
      type: project
      organization: #{org.slug}
      project: #{project.slug}
    elements:
      - slug: el-global-#{u}
        codepoint: "U+231C"
        char: "⌜"
        name: TOP LEFT CORNER
        title: Project Corner
    """)

    assert :ok = SeedLoader.seed_all!(dir)

    assert {:ok, %{element: %{title: "Global Corner"}}} =
             UnicodeCodex.get_element("el-global-#{u}")
  end

  test "seed_all!/1 tolerates a directory with no global.yaml", %{org: org, dir: dir} do
    u = System.unique_integer([:positive])

    write(dir, "organizations/#{org.slug}.yaml", """
    scope:
      type: organization
      organization: #{org.slug}
    elements:
      - slug: el-orgonly-#{u}
        codepoint: "U+231D"
        char: "⌝"
        name: TOP RIGHT CORNER
        title: Org Only Corner
    """)

    assert :ok = SeedLoader.seed_all!(dir)

    assert %{count: 1, elements: [%{title: "Org Only Corner"}]} =
             UnicodeCodex.list_elements(organization_id: org.id, q: "el-orgonly-#{u}")
  end

  test "organization scope with an unknown org raises", %{dir: dir} do
    path =
      write(dir, "bad-org.yaml", """
      scope:
        type: organization
        organization: ghost-org
      elements: []
      """)

    assert_raise(RuntimeError, ~r/unknown organization 'ghost-org'/, fn ->
      SeedLoader.seed_file!(path)
    end)
  end

  test "project scope with an unknown project raises", %{org: org, dir: dir} do
    path =
      write(dir, "bad-project.yaml", """
      scope:
        type: project
        organization: #{org.slug}
        project: ghost-project
      elements: []
      """)

    assert_raise(RuntimeError, ~r/unknown project 'ghost-project'/, fn ->
      SeedLoader.seed_file!(path)
    end)
  end

  test "project scope with an unknown organization raises", %{dir: dir} do
    path =
      write(dir, "bad-project-org.yaml", """
      scope:
        type: project
        organization: ghost-org
        project: some-project
      elements: []
      """)

    assert_raise(RuntimeError, ~r/unknown organization 'ghost-org'/, fn ->
      SeedLoader.seed_file!(path)
    end)
  end

  test "an invalid scope type raises", %{dir: dir} do
    path =
      write(dir, "bad-scope.yaml", """
      scope:
        type: galactic
      elements: []
      """)

    assert_raise(RuntimeError, ~r/has invalid scope/, fn ->
      SeedLoader.seed_file!(path)
    end)
  end

  test "a usage that fails validation raises the seed error", %{org: org, dir: dir} do
    path =
      write(dir, "bad-usage.yaml", """
      scope:
        type: organization
        organization: #{org.slug}
      special_usages:
        - slug: usage-bad-#{System.unique_integer([:positive])}
          name: usage-bad
          title: Bad Usage
          flags: "not-a-list"
      """)

    assert_raise(RuntimeError, ~r/Unicode Codex seed failed:/, fn ->
      SeedLoader.seed_file!(path)
    end)
  end

  defp write(dir, name, contents) do
    path = Path.join(dir, name)
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, contents)
    path
  end
end
