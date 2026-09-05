defmodule NoizuPromptLingua.MCP.VFS.ReviewTest do
  @moduledoc """
  Wave 2 battery for the §2.17 Review natural-overlay tree: record.json CRUD
  + freeze, overlay.md natural file (append), append-only comments/,
  attached.json, actions/complete + actions/compile control writes, and the
  compiled.md render.
  """

  use NoizuPromptLingua.DataCase, async: false

  alias Noizu.MCP.Server.Features.VFS
  alias Noizu.MCP.VFS.Cache
  alias Noizu.MCP.Ctx
  alias NoizuPromptLingua.Domains.Artifacts
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCP.VFS.Review
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Users.User
  alias NoizuPromptLingua.TRP.Cache, as: TrpCache
  alias NoizuPromptLingua.TRP.TestStub

  @config %{"groups" => %{"review" => %{}}}

  setup do
    TrpCache.clear()
    TestStub.reset()
    on_exit(fn -> Cache.purge(Review) end)
    :ok
  end

  defp key_ctx(config) do
    uniq = System.unique_integer([:positive])

    user =
      %User{
        id: Ecto.UUID.generate(),
        email: "vfsrev-#{uniq}@example.com",
        user_name: "vfsrev#{uniq}",
        handle: "vfsrev#{uniq}",
        status: :active
      }
      |> Repo.insert!()

    {:ok, key, _raw} = MCPApiKeys.generate_api_key(user.id, "vfs-rev", toolset_config: config)

    %Ctx{
      server: NoizuPromptLingua.MCP.VFSServer,
      session_id: "rev-" <> Integer.to_string(uniq),
      assigns: %{auth_claims: %{"api_key_id" => key.id, "sub" => user.id}}
    }
  end

  defp owned_org(ctx) do
    slug = "vfsrev-#{System.unique_integer([:positive])}"
    TestStub.seed_org(Ecto.UUID.generate(), slug, "Rev Org")

    {:ok, org} =
      NoizuPromptLingua.Organizations.create_organization_with_owner(
        %{"slug" => slug, "name" => "Rev Org"},
        ctx.assigns.auth_claims["sub"]
      )

    %{slug: slug, id: org.id}
  end

  defp seeded_artifact(org) do
    {:ok, artifact} =
      Artifacts.create(%{
        organization_id: org.id,
        kind: "document",
        title: "Doc under review",
        content: "v1"
      })

    %{id: artifact.id, revision_id: artifact.revisions |> hd() |> Map.get(:id)}
  end

  defp create_review(ctx, org, artifact, token) do
    body =
      Jason.encode!(%{
        "artifact_id" => artifact.id,
        "revision_id" => artifact.revision_id,
        "reviewer_persona" => "reviewer-a",
        "title" => "Rev battery"
      })

    VFS.create(Review, "/tobor/#{org.slug}/review/#{token}/record.json", body, ctx)
  end

  test "create mints a review with the canonical path in xattrs; readdir lists ids" do
    ctx = key_ctx(@config)
    org = owned_org(ctx)
    artifact = seeded_artifact(org)

    assert {:ok, node} = create_review(ctx, org, artifact, "r1")
    assert id = node.xattrs["id"]
    assert node.xattrs["canonical_path"] == "/tobor/#{org.slug}/review/#{id}/record.json"

    assert {:ok, entries, nil} = VFS.list(Review, "/tobor/#{org.slug}/review", nil, ctx)
    assert [%{name: ^id, type: :dir}] = entries

    assert {:ok, dir} = VFS.stat(Review, "/tobor/#{org.slug}/review/#{id}", ctx)
    assert dir.type == :dir and dir.xattrs["id"] == id
  end

  test "create verifies the artifact belongs to the org and requires fields" do
    ctx = key_ctx(@config)
    org = owned_org(ctx)

    bad_body =
      Jason.encode!(%{
        "artifact_id" => Ecto.UUID.generate(),
        "revision_id" => Ecto.UUID.generate(),
        "reviewer_persona" => "r"
      })

    assert {:error, :enoent} =
             VFS.create(Review, "/tobor/#{org.slug}/review/rx/record.json", bad_body, ctx)

    assert {:error, :eio} =
             VFS.create(
               Review,
               "/tobor/#{org.slug}/review/rx/record.json",
               ~s({"artifact_id":1}),
               ctx
             )
  end

  test "record.json: read + write round-trip; completed freezes; transitions ride actions/" do
    ctx = key_ctx(@config)
    org = owned_org(ctx)
    artifact = seeded_artifact(org)
    {:ok, node} = create_review(ctx, org, artifact, "r2")
    id = node.xattrs["id"]

    base = "/tobor/#{org.slug}/review/#{id}"
    path = base <> "/record.json"

    {:ok, body, _} = VFS.read(Review, path, ctx)
    assert {:ok, %{"title" => "Rev battery", "status" => "open"}} = Jason.decode(body)

    assert {:ok, _} = VFS.write(Review, path, ~s({"title":"Retitled"}), ctx)
    assert {:error, :eacces} = VFS.write(Review, path, ~s({"status":"completed"}), ctx)

    assert {:ok, control} = VFS.stat(Review, base <> "/actions/complete", ctx)
    assert control.type == :control

    assert {:ok, _} =
             VFS.write(
               Review,
               base <> "/actions/complete",
               ~s({"summary":"ship it","verdict":"approved"}),
               ctx
             )

    {:ok, body, _} = VFS.read(Review, path, ctx)
    assert {:ok, %{"status" => "completed", "verdict" => "approved"}} = Jason.decode(body)

    # The domain freezes completed reviews — further content edits refuse.
    assert {:error, :eacces} = VFS.write(Review, path, ~s({"title":"too late"}), ctx)
  end

  test "overlay.md renders the set; writes append annotations (never destroy)" do
    ctx = key_ctx(@config)
    org = owned_org(ctx)
    artifact = seeded_artifact(org)
    {:ok, node} = create_review(ctx, org, artifact, "r3")
    id = node.xattrs["id"]

    overlay = "/tobor/#{org.slug}/review/#{id}/overlay.md"

    {:ok, empty, _} = VFS.read(Review, overlay, ctx)
    assert empty =~ "Overlay"

    assert {:ok, _} = VFS.write(Review, overlay, "line 42 drags on mobile", ctx)
    assert {:ok, _} = VFS.write(Review, overlay, "spacing is off in the header", ctx)

    {:ok, rendered, _} = VFS.read(Review, overlay, ctx)
    assert rendered =~ "line 42 drags on mobile"
    assert rendered =~ "spacing is off in the header"
    assert rendered =~ "reviewer-a"
  end

  test "comments/: create appends, canonical names re-read, entries immutable" do
    ctx = key_ctx(@config)
    org = owned_org(ctx)
    artifact = seeded_artifact(org)
    {:ok, node} = create_review(ctx, org, artifact, "r4")
    id = node.xattrs["id"]

    comments_dir = "/tobor/#{org.slug}/review/#{id}/comments"

    body = ~s({"content":"Naming nit","author":"reviewer-b","location":"L12"})

    assert {:ok, created} = VFS.create(Review, comments_dir <> "/local-name.json", body, ctx)
    assert comment_id = created.xattrs["id"]
    canonical = created.xattrs["canonical_path"]
    assert canonical =~ "comments/"

    assert {:ok, entries, nil} = VFS.list(Review, comments_dir, nil, ctx)
    assert [%{name: name}] = entries
    assert name == canonical |> String.split("/") |> List.last()
    assert name =~ comment_id

    {:ok, body, _} = VFS.read(Review, comments_dir <> "/" <> name, ctx)
    assert {:ok, %{"content" => "Naming nit", "location" => "L12"}} = Jason.decode(body)

    assert {:error, :eacces} = VFS.write(Review, comments_dir <> "/" <> name, "x", ctx)

    assert {:error, :eio} =
             VFS.create(Review, comments_dir <> "/n2.json", ~s({"author":"x"}), ctx)
  end

  test "attached.json: read is the array; write adds one or many" do
    ctx = key_ctx(@config)
    org = owned_org(ctx)
    artifact = seeded_artifact(org)
    {:ok, node} = create_review(ctx, org, artifact, "r5")
    id = node.xattrs["id"]

    attached = "/tobor/#{org.slug}/review/#{id}/attached.json"

    assert {:ok, _} =
             VFS.write(
               Review,
               attached,
               ~s({"artifact_type":"url","url":"https://example.com/spec"}),
               ctx
             )

    assert {:ok, _} =
             VFS.write(
               Review,
               attached,
               ~s({"attachments":[{"artifact_type":"url","url":"https://example.com/a"},{"description":"notes"}]}),
               ctx
             )

    {:ok, body, _} = VFS.read(Review, attached, ctx)
    assert {:ok, list} = Jason.decode(body)
    assert length(list) == 3
    assert Enum.any?(list, &(&1["url"] == "https://example.com/spec"))
  end

  test "actions/compile validates; compiled.md renders the compiled feedback" do
    ctx = key_ctx(@config)
    org = owned_org(ctx)
    artifact = seeded_artifact(org)
    {:ok, node} = create_review(ctx, org, artifact, "r6")
    id = node.xattrs["id"]

    base = "/tobor/#{org.slug}/review/#{id}"

    assert {:ok, _} =
             VFS.create(
               Review,
               base <> "/comments/c1.json",
               ~s({"content":"polish","author":"rev-b"}),
               ctx
             )

    assert {:ok, _} = VFS.write(Review, base <> "/actions/compile", "compile", ctx)
    assert {:ok, control} = VFS.stat(Review, base <> "/actions/compile", ctx)
    assert control.type == :control

    {:ok, compiled, _} = VFS.read(Review, base <> "/compiled.md", ctx)
    assert compiled =~ "Rev battery"
    assert compiled =~ "polish"
    assert compiled =~ "rev-b"
    assert compiled =~ "open"
  end

  test "foreign-org review id and excluded group are :enoent" do
    ctx = key_ctx(@config)
    org_a = owned_org(ctx)
    org_b = owned_org(ctx)
    artifact = seeded_artifact(org_a)
    {:ok, node} = create_review(ctx, org_a, artifact, "r7")
    id = node.xattrs["id"]

    assert {:error, :enoent} =
             VFS.read(Review, "/tobor/#{org_b.slug}/review/#{id}/record.json", ctx)

    excluded = key_ctx(%{"groups" => %{"wiki" => %{}}})
    assert {:error, :enoent} = VFS.stat(Review, "/tobor/#{org_a.slug}/review", excluded)
  end
end
