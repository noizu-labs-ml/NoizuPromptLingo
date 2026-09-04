defmodule NoizuPromptLingua.Domains.Wiki.ToolsTest do
  use NoizuPromptLingua.DataCase
  @moduletag :db

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

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Organizations.Organization

  setup do
    org_id = insert_org()
    org_slug = Repo.get!(Organization, org_id).slug
    {:ok, org_id: org_id, org_slug: org_slug}
  end

  defp uniq(suffix), do: "#{suffix}-#{System.unique_integer([:positive])}"

  defp create_space(org_slug) do
    slug = uniq("space")

    {:ok, %{id: id}} =
      SpaceCreate.call(%{"organization" => org_slug, "slug" => slug, "name" => "Handbook"}, %{})

    id
  end

  defp create_page(org_slug, space_id) do
    slug = uniq("page")

    {:ok, %{id: id}} =
      PageCreate.call(
        %{
          "organization" => org_slug,
          "space" => space_id,
          "slug" => slug,
          "title" => "Home",
          "body" => "hello"
        },
        %{}
      )

    id
  end

  # ── Spaces ─────────────────────────────────────────────────────────

  test "space create / get / update / list / delete", %{org_slug: org_slug} do
    slug = uniq("space")

    assert {:ok, %{id: id, slug: ^slug, name: "Handbook"}} =
             SpaceCreate.call(
               %{"organization" => org_slug, "slug" => slug, "name" => "Handbook"},
               %{}
             )

    assert {:ok, %{id: ^id}} = SpaceGet.call(%{"space" => id}, %{})
    assert {:ok, %{id: ^id}} = SpaceUpdate.call(%{"space" => id, "name" => "Handbook v2"}, %{})
    assert {:ok, %{spaces: [_]}} = SpaceList.call(%{"organization" => org_slug}, %{})
    assert {:ok, %{deleted: true}} = SpaceDelete.call(%{"space" => id}, %{})
  end

  # ── Pages ──────────────────────────────────────────────────────────

  test "page create / get / update / list / delete", %{org_slug: org_slug} do
    space_id = create_space(org_slug)
    slug = uniq("page")

    assert {:ok, %{id: id, slug: ^slug, title: "Home"}} =
             PageCreate.call(
               %{
                 "organization" => org_slug,
                 "space" => space_id,
                 "slug" => slug,
                 "title" => "Home",
                 "body" => "hello"
               },
               %{}
             )

    assert {:error, "Space '" <> _} =
             PageCreate.call(
               %{
                 "organization" => org_slug,
                 "space" => Ecto.UUID.generate(),
                 "slug" => uniq("x"),
                 "title" => "X"
               },
               %{}
             )

    assert {:ok, %{id: ^id}} = PageGet.call(%{"page" => id}, %{})
    assert {:ok, %{id: ^id}} = PageUpdate.call(%{"page" => id, "title" => "Home v2"}, %{})

    assert {:ok, %{pages: [_]}} =
             PageList.call(%{"organization" => org_slug, "space" => space_id}, %{})

    assert {:ok, %{deleted: true}} = PageDelete.call(%{"page" => id}, %{})

    missing = Ecto.UUID.generate()
    assert {:error, msg} = PageGet.call(%{"page" => missing}, %{})
    assert msg == "Page '#{missing}' not found"
  end

  # ── Comments / attachments ─────────────────────────────────────────

  test "comment create / list / delete on a page", %{org_slug: org_slug} do
    space_id = create_space(org_slug)
    page_id = create_page(org_slug, space_id)

    assert {:ok, %{id: comment_id}} =
             CommentCreate.call(
               %{"page" => page_id, "body" => "nice page", "author" => "ana"},
               %{}
             )

    assert {:ok, %{comments: [_]}} = CommentList.call(%{"page" => page_id}, %{})
    assert {:ok, %{deleted: true}} = CommentDelete.call(%{"comment" => comment_id}, %{})
  end

  test "attachment create / list / delete on a page", %{org_slug: org_slug} do
    space_id = create_space(org_slug)
    page_id = create_page(org_slug, space_id)

    assert {:ok, %{id: att_id}} =
             AttachmentCreate.call(
               %{
                 "page" => page_id,
                 "filename" => "spec.pdf",
                 "url" => "https://example.com/spec.pdf",
                 "mime_type" => "application/pdf",
                 "byte_size" => 12_345
               },
               %{}
             )

    assert {:ok, %{attachments: [_]}} = AttachmentList.call(%{"page" => page_id}, %{})
    assert {:ok, %{deleted: true}} = AttachmentDelete.call(%{"attachment" => att_id}, %{})
  end

  # ── Reactions ──────────────────────────────────────────────────────

  test "reaction add / list / remove on a page", %{org_slug: org_slug} do
    space_id = create_space(org_slug)
    page_id = create_page(org_slug, space_id)

    assert {:ok, _} =
             ReactionAdd.call(
               %{"target_type" => "page", "target" => page_id, "emoji" => "👍", "actor" => "ana"},
               %{}
             )

    assert {:ok, %{reactions: [_]}} =
             ReactionList.call(%{"target_type" => "page", "target" => page_id}, %{})

    assert {:ok, _} =
             ReactionRemove.call(
               %{"target_type" => "page", "target" => page_id, "emoji" => "👍", "actor" => "ana"},
               %{}
             )

    # Unknown target type is rejected
    assert {:error, _} =
             ReactionAdd.call(
               %{"target_type" => "planet", "target" => page_id, "emoji" => "x"},
               %{}
             )
  end

  # ── Overview ───────────────────────────────────────────────────────

  test "Overview counts spaces and pages", %{org_slug: org_slug} do
    space_id = create_space(org_slug)
    create_page(org_slug, space_id)

    assert {:ok, %{tools: _} = overview} = Overview.call(%{"organization" => org_slug}, %{})
  end

  defp insert_org do
    slug = "wiki-org-#{System.unique_integer([:positive])}"

    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        [slug, "Wiki Tools Org"]
      )

    Ecto.UUID.load!(raw)
  end
end
