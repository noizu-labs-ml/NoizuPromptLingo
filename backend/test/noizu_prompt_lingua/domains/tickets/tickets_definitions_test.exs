defmodule NoizuPromptLingua.Domains.Tickets.DefinitionsTest do
  @moduledoc """
  Definitions domain over the TRP shared-key plane (stub transport): scope
  precedence (project > org > global), disabled tombstones, soft-deleted types,
  effective-set resolution, upserts, and type↔field associations. Uses the REAL
  TRP client + cache against the in-memory stub (house pattern).
  """
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.Tickets.Definitions
  alias NoizuPromptLingua.TRP.{Cache, TestStub}

  setup do
    Cache.clear()
    TestStub.reset()
    org_id = TestStub.seed_org(Ecto.UUID.generate(), "def-org")
    other_org_id = TestStub.seed_org(Ecto.UUID.generate(), "def-org-2")
    {:ok, org_id: org_id, other_org_id: other_org_id}
  end

  defp field_attrs(overrides) do
    Map.merge(
      %{slug: "f-#{System.unique_integer([:positive])}", label: "Field", field_type: "text"},
      overrides
    )
  end

  # ── scope_of ──────────────────────────────────────────────────

  test "scope_of ranks project > org > global", %{org_id: org_id} do
    assert Definitions.scope_of(%{project_id: "p", organization_id: org_id}) == :project
    assert Definitions.scope_of(%{project_id: nil, organization_id: org_id}) == :org
    assert Definitions.scope_of(%{project_id: nil, organization_id: nil}) == :global
  end

  # ── field definitions ─────────────────────────────────────────

  test "create_field requires an organization (no global writes on TRP v1)" do
    assert {:error, :trp_org_required} = Definitions.create_field(field_attrs(%{}))
  end

  test "field CRUD round-trips through TRP", %{org_id: org_id} do
    {:ok, field} = Definitions.create_field(field_attrs(%{organization_id: org_id}))
    assert field.organization_id == org_id

    assert Definitions.get_field(field.id).id == field.id

    assert {:ok, updated} = Definitions.update_field(field.id, %{label: "Renamed"})
    assert updated.label == "Renamed"

    assert Definitions.get_field_in_scope(org_id, nil, field.slug).id == field.id

    assert {:ok, nil} = Definitions.delete_field(field.id)
    # stub deletes hard -> subsequent update 404s to :not_found
    assert {:error, :not_found} = Definitions.update_field(field.id, %{label: "x"})
  end

  test "list_fields is visible-scope filtered and slug-sorted", %{
    org_id: org_id,
    other_org_id: other
  } do
    project_id = Ecto.UUID.generate()

    {:ok, g} =
      Definitions.create_field(%{
        slug: "a-global",
        label: "g",
        field_type: "text",
        organization_id: org_id,
        project_id: nil
      })

    # NOTE: TRP v1 has no global field writes; seed a global row directly.
    TestStub.seed_field(org_id, %{
      id: g.id,
      slug: "a-global",
      label: "g",
      organization_id: nil,
      project_id: nil
    })

    {:ok, o} = Definitions.create_field(field_attrs(%{slug: "b-org", organization_id: org_id}))

    {:ok, p} =
      Definitions.create_field(
        field_attrs(%{slug: "c-proj", organization_id: org_id, project_id: project_id})
      )

    {:ok, _other} =
      Definitions.create_field(field_attrs(%{slug: "d-other", organization_id: other}))

    org_view = Enum.map(Definitions.list_fields(org_id), & &1.slug)
    assert org_view == Enum.sort(["a-global", "b-org"])

    project_view = Enum.map(Definitions.list_fields(org_id, project_id), & &1.slug)
    assert project_view == Enum.sort(["a-global", "b-org", "c-proj"])
  end

  test "resolve_field picks the most-specific scope; disabled tombstone wins as nil", %{
    org_id: org_id
  } do
    project_id = Ecto.UUID.generate()
    slug = "res-#{System.unique_integer([:positive])}"

    {:ok, _org} =
      Definitions.create_field(field_attrs(%{slug: slug, organization_id: org_id, label: "org"}))

    {:ok, _proj} =
      Definitions.create_field(
        field_attrs(%{slug: slug, organization_id: org_id, project_id: project_id, label: "proj"})
      )

    assert Definitions.resolve_field(org_id, project_id, slug).label == "proj"
    assert Definitions.resolve_field(org_id, nil, slug).label == "org"
    assert Definitions.resolve_field(org_id, nil, "nope") == nil

    # project-level tombstone suppresses the slug entirely
    proj_field = Definitions.resolve_field(org_id, project_id, slug)
    {:ok, _} = Definitions.update_field(proj_field.id, %{disabled: true})

    assert Definitions.resolve_field(org_id, project_id, slug) == nil
  end

  test "effective_fields collapses to one non-disabled row per slug", %{org_id: org_id} do
    project_id = Ecto.UUID.generate()
    slug = "eff-#{System.unique_integer([:positive])}"

    {:ok, _} = Definitions.create_field(field_attrs(%{slug: slug, organization_id: org_id}))

    {:ok, proj} =
      Definitions.create_field(
        field_attrs(%{slug: slug, organization_id: org_id, project_id: project_id, label: "win"})
      )

    effective = Definitions.effective_fields(org_id, project_id)
    assert Enum.map(effective, & &1.id) == [proj.id]
    # org-level context sees only the org row
    assert Enum.map(Definitions.effective_fields(org_id), & &1.slug) == [slug]
  end

  test "list_fields degrades to [] when TRP errors", %{org_id: org_id} do
    # 422 so the client's 5xx retry policy can't eat the queued response
    TestStub.queue_response({422, %{"error" => "boom"}})
    assert Definitions.list_fields(org_id) == []
  end

  test "upsert_field creates then updates in place", %{org_id: org_id} do
    attrs = field_attrs(%{organization_id: org_id, label: "v1"})

    {:ok, created} = Definitions.upsert_field(attrs)
    {:ok, updated} = Definitions.upsert_field(%{attrs | label: "v2"})

    assert updated.id == created.id
    assert updated.label == "v2"
  end

  # ── type definitions ──────────────────────────────────────────

  test "create_type requires an organization" do
    assert {:error, :trp_org_required} = Definitions.create_type(%{slug: "t", name: "T"})
  end

  test "type CRUD + soft-delete + resolve/effective", %{org_id: org_id} do
    slug = "type-#{System.unique_integer([:positive])}"

    {:ok, type} =
      Definitions.create_type(%{
        slug: slug,
        name: "Custom",
        organization_id: org_id,
        status_workflow: %{"statuses" => ["open"], "transitions" => %{}}
      })

    assert Definitions.get_type(type.id).slug == slug

    assert {:ok, updated} = Definitions.update_type(type.id, %{name: "Custom 2"})
    assert updated.name == "Custom 2"

    assert Definitions.resolve_type(org_id, nil, slug).id == type.id
    assert Definitions.get_type_in_scope(org_id, nil, slug).id == type.id
    assert Definitions.get_type_in_scope(org_id, nil, "nope") == nil

    assert Definitions.get_status_workflow(org_id, nil, slug) == %{
             "statuses" => ["open"],
             "transitions" => %{}
           }

    assert {:ok, nil} = Definitions.delete_type(type.id)
    assert Definitions.list_types(org_id) == []
    assert Definitions.resolve_type(org_id, nil, slug) == nil
    # soft-deleted type id no longer resolves as live
    refute match?(%{deleted_at: nil}, Definitions.get_type(type.id))
  end

  test "resolve_type honors project > org and disabled tombstones", %{org_id: org_id} do
    project_id = Ecto.UUID.generate()
    slug = "ptype-#{System.unique_integer([:positive])}"

    {:ok, _org} = Definitions.create_type(%{slug: slug, name: "Org", organization_id: org_id})

    {:ok, proj} =
      Definitions.create_type(%{
        slug: slug,
        name: "Proj",
        organization_id: org_id,
        project_id: project_id
      })

    assert Definitions.resolve_type(org_id, project_id, slug).id == proj.id

    # tombstone the project row -> resolution falls to nil (winner disabled)
    {:ok, _} = Definitions.update_type(proj.id, %{disabled: true})
    assert Definitions.resolve_type(org_id, project_id, slug) == nil
    # effective set drops the tombstoned winner
    assert Definitions.effective_types(org_id, project_id) == []
  end

  test "upsert_type creates then updates in place", %{org_id: org_id} do
    slug = "ups-#{System.unique_integer([:positive])}"
    attrs = %{slug: slug, name: "V1", organization_id: org_id}

    {:ok, created} = Definitions.upsert_type(attrs)
    {:ok, updated} = Definitions.upsert_type(%{attrs | name: "V2"})

    assert updated.id == created.id
    assert updated.name == "V2"
  end

  test "list_types sorts by name and rejects deleted rows", %{org_id: org_id} do
    {:ok, b} =
      Definitions.create_type(%{
        slug: "aaa-#{System.unique_integer([:positive])}",
        name: "B Type",
        organization_id: org_id
      })

    {:ok, _} =
      Definitions.create_type(%{
        slug: "bbb-#{System.unique_integer([:positive])}",
        name: "A Type",
        organization_id: org_id
      })

    {:ok, _} = Definitions.delete_type(b.id)

    names = Enum.map(Definitions.list_types(org_id), & &1.name)
    assert names == Enum.sort(names)
    refute "B Type" in names
  end

  # ── type ↔ field associations ─────────────────────────────────

  test "add_field_to_type merges and replaces; type_field_list sorts by position", %{
    org_id: org_id
  } do
    {:ok, type} =
      Definitions.create_type(%{
        slug: "assoc-#{System.unique_integer([:positive])}",
        name: "Assoc",
        organization_id: org_id
      })

    {:ok, f1} = Definitions.create_field(field_attrs(%{slug: "f1", organization_id: org_id}))
    {:ok, f2} = Definitions.create_field(field_attrs(%{slug: "f2", organization_id: org_id}))

    assert {:ok, _} = Definitions.add_field_to_type(type.id, f1.id, required: true, position: 1)
    assert {:ok, _} = Definitions.add_field_to_type(type.id, f2.id, required: false, position: 0)
    # re-adding f1 REPLACES its entry (spec §4.4 replace semantics)
    assert {:ok, _} = Definitions.add_field_to_type(type.id, f1.id, required: false, position: 5)

    preloaded = Definitions.get_type(type.id)

    assert [f2_entry, f1_entry] = Definitions.type_field_list(preloaded)
    assert f2_entry.id == f2.id and f2_entry.position == 0 and f2_entry.required == false
    assert f1_entry.id == f1.id and f1_entry.position == 5 and f1_entry.required == false

    # non-preloaded shape falls back to []
    assert Definitions.type_field_list(%{nope: true}) == []
    assert Definitions.type_field_list(nil) == []

    assert {:ok, 1} = Definitions.remove_field_from_type(type.id, f1.id)
    assert {:ok, 0} = Definitions.remove_field_from_type(type.id, f1.id)

    # missing type -> :not_found
    assert {:error, :not_found} = Definitions.add_field_to_type(Ecto.UUID.generate(), f1.id)
  end

  test "id-only accessors walk the key-scope org list", %{org_id: org_id, other_org_id: other} do
    # field lives in the SECOND org; org-less get_field must find it via the scan
    {:ok, field} = Definitions.create_field(field_attrs(%{organization_id: other}))

    assert Definitions.get_field(field.id).id == field.id

    {:ok, type} =
      Definitions.create_type(%{
        slug: "scan-#{System.unique_integer([:positive])}",
        name: "Scan",
        organization_id: other
      })

    assert Definitions.get_type(type.id).id == type.id
  end
end
