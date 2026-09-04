defmodule NoizuPromptLingua.Domains.Personas.ToolsTest do
  use NoizuPromptLingua.DataCase
  @moduletag :db

  alias NoizuPromptLingua.Domains.Personas.Tools.{
    JournalAdd,
    JournalList,
    KnowledgeAdd,
    KnowledgeDelete,
    KnowledgeGet,
    KnowledgeList,
    KnowledgeUpdate,
    Overview,
    PersonaCreate,
    PersonaDelete,
    PersonaGet,
    PersonaList,
    PersonaUpdate
  }

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Organizations.Organization

  setup do
    org_id = insert_org()
    org_slug = Repo.get!(Organization, org_id).slug
    {:ok, org_id: org_id, org_slug: org_slug}
  end

  defp uniq(suffix), do: "#{suffix}-#{System.unique_integer([:positive])}"

  defp create_persona(org_slug, name) do
    slug = uniq("pers")

    {:ok, %{id: id}} =
      PersonaCreate.call(%{"organization" => org_slug, "slug" => slug, "name" => name}, %{})

    {id, slug}
  end

  test "persona create / get (with journal+kb) / update / list / delete", %{org_slug: org_slug} do
    slug = uniq("pers")

    assert {:ok, %{id: id, slug: ^slug, name: "Ava", status: "active"}} =
             PersonaCreate.call(
               %{"organization" => org_slug, "slug" => slug, "name" => "Ava", "role" => "dev"},
               %{}
             )

    assert {:ok, %{id: ^id, journal: journal, knowledge_base: kb}} =
             PersonaGet.call(%{"organization" => org_slug, "persona" => slug}, %{})

    assert is_list(journal) and is_list(kb)

    assert {:ok, %{id: ^id, name: "Ava II"}} =
             PersonaUpdate.call(%{"organization" => org_slug, "persona" => slug, "name" => "Ava II"}, %{})

    assert {:ok, %{count: 1, personas: [_]}} =
             PersonaList.call(%{"organization" => org_slug}, %{})

    assert {:ok, %{id: ^id, deleted: true}} =
             PersonaDelete.call(%{"organization" => org_slug, "persona" => slug}, %{})

    missing_get = Ecto.UUID.generate()

    assert {:error, msg_get} = PersonaGet.call(%{"organization" => org_slug, "persona" => missing_get}, %{})
    assert msg_get == "Persona '#{missing_get}' not found"
  end

  test "journal add + list for a persona", %{org_slug: org_slug} do
    {id, slug} = create_persona(org_slug, "Journalist")

    assert {:ok, %{id: _entry_id, category: "work_log"}} =
             JournalAdd.call(
               %{"organization" => org_slug, "persona" => slug, "body" => "shipped it", "category" => "work_log"},
               %{}
             )

    assert {:ok, %{count: 1, entries: [_]}} =
             JournalList.call(%{"organization" => org_slug, "persona" => slug}, %{})

    missing = Ecto.UUID.generate()
    assert {:error, msg} = JournalList.call(%{"organization" => org_slug, "persona" => missing}, %{})
    assert msg == "Persona '#{missing}' not found"

    assert is_binary(id)
  end

  test "knowledge add / get / update / list / delete", %{org_slug: org_slug} do
    {id, slug} = create_persona(org_slug, "Scholar")

    assert {:ok, %{id: entry_id, slug: "kb-1", title: "KB One"}} =
             KnowledgeAdd.call(
               %{"organization" => org_slug, "persona" => slug, "slug" => "kb-1", "title" => "KB One", "body" => "b"},
               %{}
             )

    assert {:ok, %{id: ^entry_id}} =
             KnowledgeGet.call(%{"organization" => org_slug, "persona" => slug, "entry" => "kb-1"}, %{})

    assert {:ok, %{id: ^entry_id, title: "KB One v2"}} =
             KnowledgeUpdate.call(%{"id" => entry_id, "title" => "KB One v2"}, %{})

    assert {:ok, %{count: 1, knowledge_base: [_]}} =
             KnowledgeList.call(%{"organization" => org_slug, "persona" => slug}, %{})

    assert {:ok, %{deleted: true}} = KnowledgeDelete.call(%{"id" => entry_id}, %{})
    assert {:error, "Knowledge entry not found"} = KnowledgeDelete.call(%{"id" => Ecto.UUID.generate()}, %{})
    assert {:error, "Knowledge entry not found"} =
             KnowledgeGet.call(%{"organization" => org_slug, "persona" => slug, "entry" => "kb-missing"}, %{})

    assert is_binary(id)
  end

  test "Overview reports persona count and never errors on unknown orgs", %{org_slug: org_slug} do
    assert {:ok, %{persona_count: 0, tools: tools}} = Overview.call(%{"organization" => org_slug}, %{})
    assert is_map(tools)
    assert {:ok, %{persona_count: 0}} = Overview.call(%{"organization" => "nope"}, %{})
  end

  defp insert_org do
    slug = "pers-tools-org-#{System.unique_integer([:positive])}"

    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        [slug, "Personas Tools Org"]
      )

    Ecto.UUID.load!(raw)
  end
end
