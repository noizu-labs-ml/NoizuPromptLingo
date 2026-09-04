defmodule NoizuPromptLingua.Domains.Wiki.WikiResidualTest do
  @moduledoc """
  Wave-5B residuals for the wiki domain: the not-found arms of every
  update/delete, page_get's nested comments/attachments/reactions projection,
  reaction dedup (the on_conflict re-fetch), list search filters, and the
  tools' changeset-error / project-resolution arms beyond `ToolsTest`.
  """
  use NoizuPromptLingua.DataCase, async: false
  @moduletag :db

  alias NoizuPromptLingua.Domains.Wiki

  alias NoizuPromptLingua.Domains.Wiki.Tools.{
    AttachmentCreate,
    AttachmentDelete,
    AttachmentList,
    CommentCreate,
    CommentDelete,
    CommentList,
    Overview,
    PageCreate,
    PageDelete,
    PageGet,
    PageList,
    PageUpdate,
    ReactionAdd,
    ReactionList,
    ReactionRemove,
    SpaceCreate,
    SpaceDelete,
    SpaceGet,
    SpaceList,
    SpaceUpdate
  }

  setup do
    NoizuPromptLingua.TRP.Cache.clear()
    NoizuPromptLingua.TRP.TestStub.reset()
    org_id = insert_org()
    stub = NoizuPromptLingua.TRP.TestStub
    stub_org_id = stub.seed_org(org_id, slug_of(org_id))

    %{id: project_id} =
      stub.seed_project(stub_org_id, %{slug: uniq("proj"), name: "Wiki Residual Project"})

    {:ok, space_id} =
      SpaceCreate.call(
        %{"organization" => slug_of(org_id), "slug" => uniq("space"), "name" => "Handbook"},
        %{}
      )
      |> case do
        {:ok, %{id: id}} -> {:ok, id}
        other -> other
      end

    {:ok, page_id} =
      PageCreate.call(
        %{
          "organization" => slug_of(org_id),
          "space" => space_id,
          "slug" => uniq("page"),
          "title" => "Home",
          "body" => "hello"
        },
        %{}
      )
      |> case do
        {:ok, %{id: id}} -> {:ok, id}
        other -> other
      end

    {:ok,
     org_id: org_id,
     org_slug: slug_of(org_id),
     project_id: project_id,
     space_id: space_id,
     page_id: page_id}
  end

  defp uniq(suffix), do: "#{suffix}-#{System.unique_integer([:positive])}"

  defp insert_org do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        [uniq("wiki-org"), "Wiki Residual Org"]
      )

    Ecto.UUID.load!(raw)
  end

  defp slug_of(org_id),
    do: Repo.get!(NoizuPromptLingua.Schema.Organizations.Organization, org_id).slug

  defp missing, do: Ecto.UUID.generate()

  # ── Domain-level not-found / lookup arms ───────────────────────────

  test "space lookups, update/delete misses, and slug lookup" do
    assert Wiki.get_space_by_slug(Ecto.UUID.generate(), "nope") == nil
    assert {:error, :not_found} = Wiki.update_space(missing(), %{name: "x"})
    assert {:error, :not_found} = Wiki.delete_space(missing())
    assert Wiki.get_space(missing()) == nil
  end

  test "page update/delete and comment/attachment delete miss arms" do
    assert {:error, :not_found} = Wiki.update_page(missing(), %{title: "x"})
    assert {:error, :not_found} = Wiki.delete_page(missing())
    assert {:error, :not_found} = Wiki.delete_comment(missing())
    assert {:error, :not_found} = Wiki.delete_attachment(missing())
  end

  test "comment create dispatches and delete removes", %{org_id: org_id, page_id: page_id} do
    {:ok, comment} =
      Wiki.create_comment(%{
        organization_id: org_id,
        page_id: page_id,
        author: "sre-lead",
        body: "looks thin"
      })

    assert comment.author == "sre-lead"
    assert {:ok, _} = Wiki.delete_comment(comment.id)
  end

  test "attachment create + list + delete round-trip", %{org_id: org_id, page_id: page_id} do
    {:ok, att} =
      Wiki.create_attachment(%{
        organization_id: org_id,
        page_id: page_id,
        filename: "spec.pdf",
        mime_type: "application/pdf",
        url: "https://example.test/spec.pdf",
        uploader: "sre-lead"
      })

    mine = Enum.filter(Wiki.list_attachments(page_id), &(&1.id == att.id))
    assert length(mine) == 1
    assert {:ok, _} = Wiki.delete_attachment(att.id)
  end

  test "add_reaction dedups on conflict by re-fetching the existing row", %{page_id: page_id} do
    attrs = %{target_type: "page", target_id: page_id, emoji: "🔥", actor: "sre-lead"}

    {:ok, first} = Wiki.add_reaction(attrs)
    {:ok, second} = Wiki.add_reaction(attrs)

    assert first.id == second.id
    assert length(Wiki.list_reactions("page", page_id)) == 1
  end

  test "page list search filters and empty-search arms", %{space_id: space_id} do
    Wiki.create_page(%{
      organization_id: Ecto.UUID.generate(),
      space_id: space_id,
      slug: uniq("srch"),
      title: "QuantumFoo"
    })

    assert Wiki.list_pages(space_id, search: "") |> is_list()
    assert Wiki.list_pages(space_id, search: nil) |> is_list()
    assert Wiki.list_pages(space_id, search: "QuantumFoo") != []
  end

  # ── Tools ──────────────────────────────────────────────────────────

  test "Overview describes the wiki surface", %{org_slug: org_slug} do
    assert {:ok, _} = Overview.call(%{"organization" => org_slug}, nil)
  end

  test "space tools: get/list/update/delete + org and project error arms", %{
    org_slug: org_slug,
    project_id: project_id
  } do
    {:ok, %{id: space_id}} =
      SpaceCreate.call(
        %{"organization" => org_slug, "slug" => uniq("sp2"), "name" => "Runbooks"},
        %{}
      )

    assert {:ok, %{id: ^space_id}} = SpaceGet.call(%{"space" => space_id}, nil)
    assert {:error, "Space '" <> _} = SpaceGet.call(%{"space" => missing()}, nil)
    assert {:ok, %{spaces: spaces}} = SpaceList.call(%{"organization" => org_slug}, nil)
    assert Enum.any?(spaces, &(&1.id == space_id))

    # Project-scoped create resolves through the project; a bad project errors.
    {:ok, _} =
      SpaceCreate.call(
        %{
          "organization" => org_slug,
          "project" => project_id,
          "slug" => uniq("sp3"),
          "name" => "Scoped"
        },
        %{}
      )

    assert {:error, "Project 'nope' not found"} =
             SpaceCreate.call(
               %{
                 "organization" => org_slug,
                 "project" => "nope",
                 "slug" => uniq("sp4"),
                 "name" => "X"
               },
               %{}
             )

    assert {:error, "Organization 'nope' not found"} =
             SpaceCreate.call(
               %{"organization" => "nope", "slug" => uniq("sp5"), "name" => "X"},
               %{}
             )

    # A duplicate slug trips the changeset error arm.
    dupe = uniq("dupe")

    {:ok, _} = SpaceCreate.call(%{"organization" => org_slug, "slug" => dupe, "name" => "A"}, %{})

    assert {:error, "Failed: " <> _} =
             SpaceCreate.call(%{"organization" => org_slug, "slug" => dupe, "name" => "B"}, %{})

    assert {:ok, %{name: "Runbooks v2"}} =
             SpaceUpdate.call(%{"space" => space_id, "name" => "Runbooks v2"}, nil)

    assert {:error, _} = SpaceUpdate.call(%{"space" => missing(), "name" => "x"}, nil)

    assert {:ok, _} = SpaceDelete.call(%{"space" => space_id}, nil)
    assert {:error, "Space '" <> _} = SpaceDelete.call(%{"space" => missing()}, nil)
  end

  test "page tools: get nests comments/attachments/reactions; update/delete arms", %{
    org_slug: org_slug,
    space_id: space_id,
    page_id: page_id
  } do
    CommentCreate.call(
      %{"organization" => org_slug, "page" => page_id, "author" => "a1", "body" => "c1"},
      nil
    )

    AttachmentCreate.call(
      %{
        "organization" => org_slug,
        "page" => page_id,
        "filename" => "f.txt",
        "mime_type" => "text/plain",
        "url" => "https://example.test/f.txt"
      },
      nil
    )

    ReactionAdd.call(%{"target_type" => "page", "target" => page_id, "emoji" => "👍"}, nil)

    {:ok, page} = PageGet.call(%{"page" => page_id}, nil)
    assert length(page.comments) == 1
    assert length(page.attachments) == 1
    assert length(page.reactions) == 1

    assert {:error, "Page '" <> _} = PageGet.call(%{"page" => missing()}, nil)

    assert {:ok, %{pages: _}} = PageList.call(%{"space" => space_id}, nil)

    # default_slug autogenerates a slug from the title; a duplicate slug trips the
    # changeset error arm instead.
    dup = uniq("dupeslug")

    {:ok, _} =
      PageCreate.call(
        %{"organization" => org_slug, "space" => space_id, "slug" => dup, "title" => "First"},
        nil
      )

    assert {:error, "Failed: " <> _} =
             PageCreate.call(
               %{
                 "organization" => org_slug,
                 "space" => space_id,
                 "slug" => dup,
                 "title" => "Second"
               },
               nil
             )

    assert {:ok, %{title: "Renamed"}} =
             PageUpdate.call(%{"page" => page_id, "title" => "Renamed"}, nil)

    assert {:error, _} = PageUpdate.call(%{"page" => missing(), "title" => "x"}, nil)
    assert {:ok, _} = PageDelete.call(%{"page" => page_id}, nil)
    assert {:error, "Page '" <> _} = PageDelete.call(%{"page" => missing()}, nil)
  end

  test "comment tools round-trip and miss cleanly", %{org_slug: org_slug, page_id: page_id} do
    {:ok, %{id: comment_id}} =
      CommentCreate.call(
        %{"organization" => org_slug, "page" => page_id, "author" => "a2", "body" => "c2"},
        nil
      )

    assert {:ok, %{comments: cs}} = CommentList.call(%{"page" => page_id}, nil)
    assert Enum.any?(cs, &(&1.id == comment_id))

    assert {:ok, _} = CommentDelete.call(%{"comment" => comment_id}, nil)
    assert {:error, "Comment '" <> _} = CommentDelete.call(%{"comment" => missing()}, nil)
  end

  test "attachment tools list and delete; missing id errors", %{page_id: page_id} do
    assert {:ok, %{attachments: _}} = AttachmentList.call(%{"page" => page_id}, nil)

    assert {:error, "Attachment '" <> _} =
             AttachmentDelete.call(%{"attachment" => missing()}, nil)
  end

  test "reaction tools: add validates type/target, lists, removes", %{page_id: page_id} do
    assert {:error, "target_type must be \"page\" or \"comment\""} =
             ReactionAdd.call(
               %{"target_type" => "wiki", "target" => page_id, "emoji" => "🚀"},
               nil
             )

    assert {:error, "Target not found"} =
             ReactionAdd.call(
               %{"target_type" => "page", "target" => missing(), "emoji" => "🚀"},
               nil
             )

    {:ok, %{id: rid}} =
      ReactionAdd.call(%{"target_type" => "page", "target" => page_id, "emoji" => "🚀"}, nil)

    assert {:ok, %{reactions: rs}} =
             ReactionList.call(%{"target_type" => "page", "target" => page_id}, nil)

    assert Enum.any?(rs, &(&1.id == rid))

    assert {:ok, _} =
             ReactionRemove.call(
               %{"target_type" => "page", "target" => page_id, "emoji" => "🚀"},
               nil
             )

    assert {:error, "Reaction not found"} =
             ReactionRemove.call(
               %{"target_type" => "page", "target" => page_id, "emoji" => "🚀"},
               nil
             )
  end
end
