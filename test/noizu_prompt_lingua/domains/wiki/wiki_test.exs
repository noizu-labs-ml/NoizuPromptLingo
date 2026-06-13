defmodule NoizuPromptLingua.Domains.WikiTest do
  use NoizuPromptLingua.DataCase, async: true

  alias NoizuPromptLingua.Domains.Wiki
  alias NoizuPromptLingua.Services.{Comment, Attach}

  defp create_space(attrs \\ %{}) do
    defaults = %{slug: "space-#{System.unique_integer([:positive])}", name: "Test Space"}
    Wiki.create_space(Map.merge(defaults, attrs))
  end

  defp create_page(space_id, attrs \\ %{}) do
    defaults = %{space_id: space_id, slug: "page-#{System.unique_integer([:positive])}", title: "Test Page", content: "# Hello"}
    Wiki.create_page(Map.merge(defaults, attrs))
  end

  describe "spaces" do
    test "create and list" do
      {:ok, space} = create_space(%{slug: "eng", name: "Engineering"})
      assert space.slug == "eng"
      assert Wiki.space_count() >= 1
      assert Enum.any?(Wiki.list_spaces(), &(&1.id == space.id))
    end

    test "get by slug and id" do
      {:ok, space} = create_space(%{slug: "get-me"})
      assert Wiki.get_space("get-me").id == space.id
      assert Wiki.get_space(space.id).id == space.id
    end

    test "unique slug" do
      {:ok, _} = create_space(%{slug: "uniq"})
      assert {:error, _} = create_space(%{slug: "uniq"})
    end
  end

  describe "pages" do
    test "create page with artifact" do
      {:ok, space} = create_space()
      {:ok, page} = create_page(space.id, %{title: "Getting Started", content: "# Intro"})
      assert page.title == "Getting Started"
      assert page.artifact_id
    end

    test "get page with content" do
      {:ok, space} = create_space()
      {:ok, page} = create_page(space.id, %{content: "Original"})
      {p, rev} = Wiki.get_page(page.id)
      assert p.id == page.id
      assert rev.content == "Original"
    end

    test "edit page creates new revision" do
      {:ok, space} = create_space()
      {:ok, page} = create_page(space.id, %{content: "V1"})
      {:ok, {updated, rev}} = Wiki.edit_page(page.id, %{content: "V2", edit_message: "update"})
      assert rev.revision_number == 2
      assert rev.note == "update"

      {_, latest} = Wiki.get_page(page.id)
      assert latest.content == "V2"
    end

    test "edit page updates title and tags" do
      {:ok, space} = create_space()
      {:ok, page} = create_page(space.id, %{content: "X", tags: ["old"]})
      {:ok, {updated, _}} = Wiki.edit_page(page.id, %{content: "Y", title: "New Title", tags: ["new"]})
      assert updated.title == "New Title"
      assert updated.tags == ["new"]
    end

    test "list pages with filters" do
      {:ok, space} = create_space()
      {:ok, p1} = create_page(space.id, %{tags: ["guide"]})
      {:ok, p2} = create_page(space.id, %{tags: ["api"]})

      all = Wiki.list_pages(space_id: space.id)
      assert length(all) == 2

      guides = Wiki.list_pages(tag: "guide")
      assert Enum.all?(guides, &("guide" in &1.tags))
    end

    test "hierarchical pages" do
      {:ok, space} = create_space()
      {:ok, parent} = create_page(space.id, %{title: "Parent"})
      {:ok, child} = create_page(space.id, %{title: "Child", parent_page_id: parent.id})

      children = Wiki.list_pages(parent_page_id: parent.id)
      assert length(children) == 1
      assert hd(children).id == child.id
    end

    test "search by title" do
      {:ok, space} = create_space()
      {:ok, _} = create_page(space.id, %{title: "UniqueWikiTitle987"})
      results = Wiki.list_pages(search: "UniqueWikiTitle")
      assert length(results) >= 1
    end
  end

  describe "permissions" do
    test "grant and list" do
      {:ok, space} = create_space()
      {:ok, _} = Wiki.grant_permission(%{entity_type: "space", entity_id: space.id, persona: "alice", permission: "admin"})
      perms = Wiki.list_permissions("space", space.id)
      assert length(perms) == 1
      assert hd(perms).permission == "admin"
    end

    test "grant upserts" do
      {:ok, space} = create_space()
      Wiki.grant_permission(%{entity_type: "space", entity_id: space.id, persona: "bob", permission: "read"})
      Wiki.grant_permission(%{entity_type: "space", entity_id: space.id, persona: "bob", permission: "write"})
      perms = Wiki.list_permissions("space", space.id)
      assert length(perms) == 1
      assert hd(perms).permission == "write"
    end

    test "revoke" do
      {:ok, space} = create_space()
      Wiki.grant_permission(%{entity_type: "space", entity_id: space.id, persona: "charlie", permission: "read"})
      assert {:ok, _} = Wiki.revoke_permission("space", space.id, "charlie")
      assert Wiki.list_permissions("space", space.id) == []
    end
  end

  describe "cross-cutting" do
    test "comment on page" do
      {:ok, space} = create_space()
      {:ok, page} = create_page(space.id)
      {:ok, c} = Comment.add("wiki_page", page.id, %{content: "Nice page", author: "alice"})
      assert c.entity_type == "wiki_page"
      assert length(Comment.list("wiki_page", page.id)) == 1
    end

    test "attach to page" do
      {:ok, space} = create_space()
      {:ok, page} = create_page(space.id)
      {:ok, att} = Attach.add("wiki_page", page.id, %{artifact_type: "url", url: "https://example.com"})
      assert length(Attach.list("wiki_page", page.id)) == 1
    end
  end
end
