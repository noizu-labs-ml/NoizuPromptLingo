defmodule NoizuPromptLingua.MCP.VFS.InstructionsTest do
  @moduledoc """
  Wave 1 battery for the `instructions` VFS backend (design §2.3), through
  `Root` + `Features.VFS` plus one direct-backend conformance call.

  Covers: create (slug + v1), version-file immutability (`:eexist`), the
  writable `active` pointer (set-active semantics, bad-pointer `:eio`,
  unknown-version `:enoent`), record.json, delete via `remove`, errnos,
  pagination cursor policy, and the §1.3 gate matrix.
  """

  use NoizuPromptLingua.DataCase, async: false

  alias Noizu.MCP.Ctx
  alias Noizu.MCP.Server.Features.VFS
  alias Noizu.MCP.VFS.Cache
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCP.VFS.{Instructions, Root}
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Organizations.Organization
  alias NoizuPromptLingua.TRP.Cache, as: TrpCache
  alias NoizuPromptLingua.TRP.TestStub

  setup do
    TrpCache.clear()
    TestStub.reset()

    suffix = Ecto.UUID.generate() |> binary_part(0, 8)

    org =
      Repo.insert!(%Organization{name: "VFS Instr Org #{suffix}", slug: "vfs-instr-#{suffix}"})

    TestStub.seed_org(org.id, org.slug, org.name)

    on_exit(fn -> Cache.purge(Root) end)

    %{org: org, ctx: key_ctx(%{"groups" => %{"instructions" => %{}}})}
  end

  defp key_ctx(config) do
    uniq = System.unique_integer([:positive])

    user =
      %NoizuPromptLingua.Schema.Users.User{
        id: Ecto.UUID.generate(),
        email: "vfsinstr-#{uniq}@example.com",
        user_name: "vfsinstr#{uniq}",
        handle: "vfsinstr#{uniq}",
        status: :active
      }
      |> Repo.insert!()

    {:ok, key, _} =
      MCPApiKeys.generate_api_key(user.id, "vfs-instructions", toolset_config: config)

    %Ctx{
      server: NoizuPromptLingua.MCP.VFSServer,
      session_id: "instr-" <> Integer.to_string(uniq),
      assigns: %{auth_claims: %{"api_key_id" => key.id, "sub" => user.id}}
    }
  end

  defp base(org), do: "/tobor/#{org.slug}/instructions"

  defp instruction!(org, ctx, slug, body \\ "default body") do
    {:ok, _} = VFS.create(Root, "#{base(org)}/#{slug}", body, ctx)
    slug
  end

  # ── create + read ─────────────────────────────────────────────────────────

  test "create seeds the slug, v1 body, and the active pointer", %{org: org, ctx: ctx} do
    assert {:ok, node} = VFS.create(Root, "#{base(org)}/greeter", "hi {{name}}", ctx)
    assert node.type == :dir

    assert {:ok, entries, nil} = VFS.list(Root, base(org), nil, ctx)
    assert Enum.map(entries, & &1.name) == ["overview.md", "greeter"]

    assert {:ok, "hi {{name}}", _} =
             VFS.read(Root, "#{base(org)}/greeter/versions/v1.md", ctx)

    assert {:ok, "v1", _} = VFS.read(Root, "#{base(org)}/greeter/active", ctx)

    {:ok, record_json, _} = VFS.read(Root, "#{base(org)}/greeter/record.json", ctx)
    {:ok, record} = Jason.decode(record_json)
    assert record["slug"] == "greeter"
    assert record["title"] == "greeter"
    assert record["active_version"] == 1
    assert record["version_count"] == 1
    assert record["organization_id"] == org.id

    assert {:ok, versions, nil} = VFS.list(Root, "#{base(org)}/greeter/versions", nil, ctx)
    assert Enum.map(versions, & &1.name) == ["v1.md"]
  end

  test "duplicate slug collides with :eexist; reserved name refused", %{org: org, ctx: ctx} do
    instruction!(org, ctx, "taken")

    assert {:error, :eexist} = VFS.create(Root, "#{base(org)}/taken", "again", ctx)
    assert {:error, :eexist} = VFS.create(Root, "#{base(org)}/overview.md", "reserved", ctx)
    assert {:error, :enosys} = VFS.create(Root, "#{base(org)}/empty", :dir, ctx)
  end

  # ── version immutability + next-only creates (InstructionUpdate) ──────────

  test "creating the next version advances the pointer; existing numbers :eexist", %{
    org: org,
    ctx: ctx
  } do
    slug = instruction!(org, ctx, "versioned")

    assert {:error, :eexist} = VFS.create(Root, "#{base(org)}/#{slug}/versions/v1.md", "x", ctx)
    assert {:error, :eexist} = VFS.write(Root, "#{base(org)}/#{slug}/versions/v1.md", "x", ctx)

    assert {:ok, _} = VFS.create(Root, "#{base(org)}/#{slug}/versions/v2.md", "v2 body", ctx)

    assert {:ok, "v2", _} = VFS.read(Root, "#{base(org)}/#{slug}/active", ctx)
    assert {:ok, "v2 body", _} = VFS.read(Root, "#{base(org)}/#{slug}/versions/v2.md", ctx)
    assert {:ok, "default body", _} = VFS.read(Root, "#{base(org)}/#{slug}/versions/v1.md", ctx)

    # Gaps refused: only active + 1 can be created.
    assert {:error, :enoent} = VFS.create(Root, "#{base(org)}/#{slug}/versions/v4.md", "x", ctx)
    # Non-markdown names are not version nodes.
    assert {:error, :enoent} = VFS.create(Root, "#{base(org)}/#{slug}/versions/v3.txt", "x", ctx)

    assert {:ok, versions, nil} = VFS.list(Root, "#{base(org)}/#{slug}/versions", nil, ctx)
    assert Enum.map(versions, & &1.name) == ["v1.md", "v2.md"]
  end

  # ── the active pointer (InstructionSetActiveVersion) ──────────────────────

  test "writing the active pointer rolls back and forward", %{org: org, ctx: ctx} do
    slug = instruction!(org, ctx, "pointer")
    {:ok, _} = VFS.create(Root, "#{base(org)}/#{slug}/versions/v2.md", "second", ctx)

    assert {:ok, node} = VFS.write(Root, "#{base(org)}/#{slug}/active", "v1\n", ctx)
    assert node.type == :file

    assert {:ok, "v1", _} = VFS.read(Root, "#{base(org)}/#{slug}/active", ctx)

    {:ok, record_json, _} = VFS.read(Root, "#{base(org)}/#{slug}/record.json", ctx)
    assert {:ok, %{"active_version" => 1}} = Jason.decode(record_json)

    # Roll forward again; whitespace/newline tolerated.
    assert {:ok, _} = VFS.write(Root, "#{base(org)}/#{slug}/active", "  v2  ", ctx)
    assert {:ok, "v2", _} = VFS.read(Root, "#{base(org)}/#{slug}/active", ctx)
  end

  test "pointer to unknown version is :enoent; malformed content is :eio", %{org: org, ctx: ctx} do
    slug = instruction!(org, ctx, "badpointer")

    assert {:error, :enoent} = VFS.write(Root, "#{base(org)}/#{slug}/active", "v9", ctx)
    assert {:error, :eio} = VFS.write(Root, "#{base(org)}/#{slug}/active", "latest please", ctx)
  end

  # ── delete (InstructionDelete mapping) ────────────────────────────────────

  test "removing the instruction dir deletes it (versions cascade)", %{org: org, ctx: ctx} do
    slug = instruction!(org, ctx, "doomed")

    assert :ok = VFS.remove(Root, "#{base(org)}/#{slug}", ctx)
    assert {:error, :enoent} = VFS.stat(Root, "#{base(org)}/#{slug}", ctx)
    assert {:error, :enoent} = VFS.read(Root, "#{base(org)}/#{slug}/versions/v1.md", ctx)

    assert {:error, :enoent} = VFS.remove(Root, "#{base(org)}/#{slug}", ctx)
  end

  test "record.json/pointer writes and structural errnos", %{org: org, ctx: ctx} do
    slug = instruction!(org, ctx, "errno")

    assert {:error, :enosys} = VFS.write(Root, "#{base(org)}/#{slug}/record.json", "{}", ctx)
    assert {:error, :enosys} = VFS.remove(Root, "#{base(org)}/#{slug}/versions/v1.md", ctx)
    assert {:error, :eisdir} = VFS.read(Root, "#{base(org)}/#{slug}", ctx)
    assert {:error, :eisdir} = VFS.read(Root, "#{base(org)}/#{slug}/versions", ctx)
    assert {:error, :enotdir} = VFS.list(Root, "#{base(org)}/#{slug}/active", nil, ctx)
    assert {:error, :enoent} = VFS.read(Root, "#{base(org)}/#{slug}/versions/v9.md", ctx)
    assert {:error, :enoent} = VFS.stat(Root, "#{base(org)}/nope/active", ctx)
  end

  test "invalid cursors rejected; bounded sub-listings accept empty cursor", %{org: org, ctx: ctx} do
    instruction!(org, ctx, "paged")

    assert {:error, %Noizu.MCP.Error{}} = VFS.list(Root, base(org), "junk", ctx)
    assert {:ok, _, nil} = VFS.list(Root, base(org), "", ctx)
    assert {:ok, _, nil} = VFS.list(Root, "#{base(org)}/paged/versions", "", ctx)
  end

  # ── overview ──────────────────────────────────────────────────────────────

  test "overview.md renders from the group's Overview tool", %{org: org, ctx: ctx} do
    assert {:ok, md, _} = VFS.read(Root, "#{base(org)}/overview.md", ctx)
    assert md =~ "Instructions"
  end

  # ── gating (§1.3) ─────────────────────────────────────────────────────────

  test "excluded group is :enoent; disabled group is read-only with :eacces mutations", %{
    org: org
  } do
    excluded = key_ctx(%{"groups" => %{"wiki" => %{}}})
    assert {:error, :enoent} = VFS.stat(Root, base(org), excluded)

    disabled = key_ctx(%{"groups" => %{"instructions" => %{"disabled" => true}}})
    assert {:ok, dir} = VFS.stat(Root, base(org), disabled)
    assert dir.writable == false
    assert {:error, :eacces} = VFS.create(Root, "#{base(org)}/blocked", "x", disabled)
    assert {:ok, _, _} = VFS.read(Root, "#{base(org)}/overview.md", disabled)
  end

  # ── direct backend call ───────────────────────────────────────────────────

  test "backend works standalone on full absolute paths", %{org: org, ctx: ctx} do
    assert {:ok, dir} = Instructions.stat("/tobor/#{org.slug}/instructions", ctx)
    assert dir.type == :dir
    assert {:error, :enosys} = Instructions.write("/tobor/#{org.slug}/instructions/x", "y", ctx)
  end
end
