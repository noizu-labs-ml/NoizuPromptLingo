defmodule NoizuPromptLingua.Domains.PersonasTest do
  use NoizuPromptLingua.DataCase
  @moduletag :db

  alias NoizuPromptLingua.Domains.Personas
  alias NoizuPromptLingua.Schema.Persona

  setup do
    org_id = insert_org()
    project_id = insert_project(org_id, "pers-proj")
    {:ok, org_id: org_id, project_id: project_id}
  end

  defp persona_attrs(org_id, extra \\ %{}) do
    Map.merge(
      %{
        organization_id: org_id,
        slug: "persona-#{System.unique_integer([:positive])}",
        name: "Persona #{System.unique_integer([:positive])}",
        role: "engineer",
        tags: ["alpha"]
      },
      extra
    )
  end

  # ── CRUD ───────────────────────────────────────────────────────────

  test "create / get / resolve by id and slug", %{org_id: org_id} do
    {:ok, p} = Personas.create(persona_attrs(org_id))

    assert %Persona{} = Personas.get(p.id)
    assert Personas.get(Ecto.UUID.generate()) == nil

    assert Personas.resolve(org_id, p.id).id == p.id
    assert Personas.resolve(org_id, p.slug).id == p.id
    # An org-scoped slug that is not visible to another org does not resolve.
    other_org = insert_org()
    assert Personas.resolve(other_org, p.slug) == nil
  end

  test "resolve falls back to slug lookup when the id-shaped value has no row", %{org_id: org_id} do
    {:ok, p} = Personas.create(persona_attrs(org_id))

    # A syntactically-valid UUID string that matches no id, used as the slug.
    uuid = Ecto.UUID.generate()
    {:ok, fake} = Personas.create(persona_attrs(org_id, %{slug: uuid}))
    assert Personas.resolve(org_id, uuid).id == fake.id
    assert p.id != fake.id
  end

  test "update / set_status / archive / activate / delete + not_found paths", %{org_id: org_id} do
    {:ok, p} = Personas.create(persona_attrs(org_id))

    assert {:ok, p2} = Personas.update(p.id, %{role: "designer"})
    assert p2.role == "designer"
    assert {:error, :not_found} = Personas.update(Ecto.UUID.generate(), %{role: "x"})

    assert {:ok, archived} = Personas.archive(p.id)
    assert archived.status == "archived"
    assert {:ok, active} = Personas.activate(p.id)
    assert active.status == "active"
    assert {:ok, inactive_set} = Personas.set_status(p.id, "archived")
    assert inactive_set.status == "archived"
    assert {:error, :not_found} = Personas.set_status(Ecto.UUID.generate(), "active")

    assert {:ok, _} = Personas.delete(p.id)
    assert Personas.get(p.id) == nil
    assert {:error, :not_found} = Personas.delete(p.id)
  end

  test "create with missing required fields fails changeset", %{org_id: org_id} do
    assert {:error, cs} = Personas.create(%{organization_id: org_id})
    assert Keyword.has_key?(cs.errors, :slug)
    assert Keyword.has_key?(cs.errors, :name)
  end

  test "duplicate slug within an org is rejected", %{org_id: org_id} do
    attrs = persona_attrs(org_id)
    {:ok, _} = Personas.create(attrs)
    assert {:error, _} = Personas.create(attrs)
  end

  # ── list / count / scoping ─────────────────────────────────────────

  test "list filters by org, project, include_org_level union, status and tag", %{
    org_id: org_id,
    project_id: project_id
  } do
    {:ok, in_proj} = Personas.create(persona_attrs(org_id, %{project_id: project_id}))
    {:ok, org_level} = Personas.create(persona_attrs(org_id))
    {:ok, tagged} = Personas.create(persona_attrs(org_id, %{tags: ["special"]}))
    other_org = insert_org()
    {:ok, _} = Personas.create(persona_attrs(other_org))

    # Org filter
    all = Personas.list(organization_id: org_id)
    assert length(all) == 3
    # Ascending name order
    names = Enum.map(all, & &1.name)
    assert names == Enum.sort(names)

    # Exact project scope excludes org-level personas
    assert [%{id: id}] = Personas.list(organization_id: org_id, project_id: project_id)
    assert id == in_proj.id

    # Effective list = project + org-level (tagged persona has no project either)
    effective = Personas.list(organization_id: org_id, project_id: project_id, include_org_level: true)
    assert length(effective) == 3
    assert Enum.sort(Enum.map(effective, & &1.id)) ==
             Enum.sort([in_proj.id, org_level.id, tagged.id])

    # Status filter (in_proj now archived)
    Personas.archive(in_proj.id)
    actives = Personas.list(organization_id: org_id, status: "active")
    assert Enum.sort(Enum.map(actives, & &1.id)) == Enum.sort([org_level.id, tagged.id])

    # Tag filter
    assert [%{tags: tags}] = Personas.list(organization_id: org_id, tag: "special")
    assert "special" in tags
  end

  test "list honors limit and offset", %{org_id: org_id} do
    for _ <- 1..3, do: {:ok, _} = Personas.create(persona_attrs(org_id))
    assert length(Personas.list(organization_id: org_id, limit: 2)) == 2

    [first | _] = Personas.list(organization_id: org_id)
    [offset_first | _] = Personas.list(organization_id: org_id, limit: 2, offset: 1)
    assert offset_first.id != first.id
  end

  test "count is org-scoped", %{org_id: org_id} do
    {:ok, _} = Personas.create(persona_attrs(org_id))
    {:ok, _} = Personas.create(persona_attrs(org_id))
    other = insert_org()
    {:ok, _} = Personas.create(persona_attrs(other))
    assert Personas.count(org_id) == 2
    assert Personas.count(other) == 1
  end

  # ── Journal ────────────────────────────────────────────────────────

  test "journal add / list with category filter and ordering / delete", %{org_id: org_id} do
    {:ok, p} = Personas.create(persona_attrs(org_id))

    assert {:ok, e1} = Personas.add_journal_entry(p.id, %{body: "first", category: "work_log"})
    assert {:ok, _} = Personas.add_journal_entry(p.id, %{body: "second", category: "note"})

    entries = Personas.list_journal(p.id)
    assert length(entries) == 2
    assert Enum.sort(Enum.map(entries, & &1.body)) == ["first", "second"]

    assert [%{body: "first"}] = Personas.list_journal(p.id, category: "work_log")
    assert length(Personas.list_journal(p.id, limit: 1)) == 1
    assert [%{body: "second"}] = Personas.list_journal(p.id, limit: 1, offset: 1)

    assert {:ok, _} = Personas.delete_journal_entry(e1.id)
    assert length(Personas.list_journal(p.id)) == 1
    assert {:error, :not_found} = Personas.delete_journal_entry(Ecto.UUID.generate())
  end

  test "journal entry requires body", %{org_id: org_id} do
    {:ok, p} = Personas.create(persona_attrs(org_id))
    assert {:error, cs} = Personas.add_journal_entry(p.id, %{title: "no body"})
    assert Keyword.has_key?(cs.errors, :body)
  end

  # ── Knowledge base ─────────────────────────────────────────────────

  test "knowledge add / update / get by id and slug / list with tag filter / delete", %{
    org_id: org_id
  } do
    {:ok, p} = Personas.create(persona_attrs(org_id))
    {:ok, other} = Personas.create(persona_attrs(org_id))

    {:ok, k} = Personas.add_knowledge(p.id, %{slug: "kb-1", title: "KB One", body: "b1"})
    assert {:ok, _} = Personas.add_knowledge(other.id, %{slug: "kb-1", title: "Other", body: "b2"})

    assert {:ok, k2} = Personas.update_knowledge(k.id, %{title: "KB One Updated"})
    assert k2.title == "KB One Updated"
    assert {:error, :not_found} = Personas.update_knowledge(Ecto.UUID.generate(), %{})

    assert Personas.get_knowledge(p.id, k.id).id == k.id
    assert Personas.get_knowledge(p.id, "kb-1").id == k.id
    assert Personas.get_knowledge(other.id, "kb-1").id != k.id

    assert [%{id: id}] = Personas.list_knowledge(p.id)
    assert id == k.id

    # Tag filter
    {:ok, _} = Personas.add_knowledge(p.id, %{slug: "kb-2", title: "Two", body: "b", tags: ["ref"]})
    assert [%{slug: "kb-2"}] = Personas.list_knowledge(p.id, tag: "ref")

    assert {:ok, _} = Personas.delete_knowledge(k.id)
    assert Personas.list_knowledge(p.id) |> length() == 1
    assert {:error, :not_found} = Personas.delete_knowledge(Ecto.UUID.generate())
  end

  test "knowledge entry requires slug/title/body", %{org_id: org_id} do
    {:ok, p} = Personas.create(persona_attrs(org_id))
    assert {:error, cs} = Personas.add_knowledge(p.id, %{title: "missing body + slug"})
    assert Keyword.has_key?(cs.errors, :body)
    assert Keyword.has_key?(cs.errors, :slug)
  end

  # ── helpers ────────────────────────────────────────────────────────

  defp insert_org do
    slug = "pers-org-#{System.unique_integer([:positive])}"

    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        [slug, "Personas Test Org"]
      )

    Ecto.UUID.load!(raw)
  end

  defp insert_project(org_id, slug_base) do
    slug = "#{slug_base}-#{System.unique_integer([:positive])}"

    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO projects (id, organization_id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, $3, now(), now()) RETURNING id",
        [Ecto.UUID.dump!(org_id), slug, "Project #{slug_base}"]
      )

    Ecto.UUID.load!(raw)
  end
end
