defmodule NoizuPromptLingua.MCP.VFS.GatingTest do
  @moduledoc """
  Wave 0 gating matrix (MCP-VFS-GROUP-MOUNTS.md §1.3), over the composed
  backend through `Noizu.MCP.Server.Features.VFS`:

  | principal state                | expected VFS behavior                              |
  |--------------------------------|----------------------------------------------------|
  | org visible, group included    | subtree served                                     |
  | group included, tools disabled | node listed, `writable: false`                     |
  | group hidden                   | `:enoent` subtree (mirrors `visible: false`)       |
  | group excluded from scope      | `:enoent` subtree (no existence leak)              |
  | org not in TRP key scope       | `:enoent` subtree                                  |
  | no resolvable client/scope     | no group subtrees (fail closed)                    |
  | principal A vs B               | per-principal listings/content (cache disabled)    |

  The `/etc/dev` invocation gate (effective-toolset `tool_gate`) is covered on
  the `Principal` seam directly: invisible/disabled tools deny, unknown tools
  fail closed.
  """

  use NoizuPromptLingua.DataCase, async: false

  require Noizu.EntityReference.Records
  alias Noizu.EntityReference.Records, as: R

  alias Noizu.MCP.Server.Features.VFS
  alias Noizu.MCP.VFS.Cache
  alias Noizu.MCP.Ctx
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCP.VFS.{Principal, Root}
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Users.User
  alias NoizuPromptLingua.TRP.Cache, as: TrpCache
  alias NoizuPromptLingua.TRP.TestStub

  setup do
    TrpCache.clear()
    TestStub.reset()

    org_a = "gate-a-#{System.unique_integer([:positive])}"
    org_b = "gate-b-#{System.unique_integer([:positive])}"
    TestStub.seed_org(Ecto.UUID.generate(), org_a, "Gate Org A")
    TestStub.seed_org(Ecto.UUID.generate(), org_b, "Gate Org B")

    on_exit(fn -> Cache.purge(Root) end)

    %{org_a: org_a, org_b: org_b}
  end

  defp key_ctx(config, overrides \\ []) do
    uniq = System.unique_integer([:positive])

    user =
      %User{
        id: Ecto.UUID.generate(),
        email: "vfsgate-#{uniq}@example.com",
        user_name: "vfsgate#{uniq}",
        handle: "vfsgate#{uniq}",
        status: :active
      }
      |> Repo.insert!()

    {:ok, key, _raw} = MCPApiKeys.generate_api_key(user.id, "vfs-gate", toolset_config: config)

    claims =
      %{"api_key_id" => key.id, "sub" => user.id}
      |> Map.merge(Map.new(overrides))

    %Ctx{
      server: NoizuPromptLingua.MCP.VFSServer,
      session_id: "gate-" <> Integer.to_string(uniq),
      assigns: %{auth_claims: claims}
    }
  end

  defp read_meta!(backend, path, ctx) do
    {:ok, json, _} = VFS.read(backend, path, ctx)
    {:ok, Jason.decode!(json)}
  end

  # ── matrix: group state × visibility ──────────────────────────────────────

  test "included + visible group is served; hidden group is :enoent", %{org_a: org} do
    ctx =
      key_ctx(%{
        "groups" => %{
          "wiki" => %{},
          "tickets" => %{"hidden" => true}
        }
      })

    assert {:ok, _} = VFS.stat(Root, "/tobor/#{org}/wiki", ctx)
    assert {:ok, _, _} = VFS.read(Root, "/tobor/#{org}/wiki/overview.md", ctx)

    # Hidden mirrors visible:false — indistinguishable from absent.
    assert {:error, :enoent} = VFS.stat(Root, "/tobor/#{org}/tickets", ctx)
    assert {:error, :enoent} = VFS.read(Root, "/tobor/#{org}/tickets/overview.md", ctx)
    assert {:error, :enoent} = VFS.read(Root, "/tobor/#{org}/_meta/groups/tickets.json", ctx)

    assert {:ok, entries, _} = VFS.list(Root, "/tobor/#{org}", nil, ctx)
    assert Enum.any?(entries, &(&1.name == "wiki"))
    refute Enum.any?(entries, &(&1.name == "tickets"))
  end

  test "included but disabled group lists with writable: false", %{org_a: org} do
    ctx = key_ctx(%{"groups" => %{"wiki" => %{"disabled" => true}}})

    assert {:ok, dir} = VFS.stat(Root, "/tobor/#{org}/wiki", ctx)
    assert dir.type == :dir
    assert dir.writable == false

    assert {:ok, node} = VFS.stat(Root, "/tobor/#{org}/wiki/overview.md", ctx)
    assert node.writable == false

    {:ok, descriptor} = read_meta!(Root, "/tobor/#{org}/_meta/groups/wiki.json", ctx)
    assert descriptor["gate"] == %{"included" => true, "visible" => true, "writable" => false}
    assert descriptor["status"] == "read_only"
  end

  test "group excluded from the key's scope never exists", %{org_a: org} do
    # Key narrows to wiki only: chat is not in the include set at all.
    ctx = key_ctx(%{"groups" => %{"wiki" => %{}}})

    assert {:error, :enoent} = VFS.stat(Root, "/tobor/#{org}/chat", ctx)
    assert {:error, :enoent} = VFS.read(Root, "/tobor/#{org}/chat/overview.md", ctx)

    {:ok, toolsets} = read_meta!(Root, "/tobor/#{org}/_meta/toolsets.json", ctx)
    refute Map.has_key?(toolsets["tools"], "Chat.ListMessages")
    assert toolsets["groups"]["chat"]["included"] == false
  end

  # ── org gating ────────────────────────────────────────────────────────────

  test "/tobor readdir is exactly the principal's TRP org scope", %{org_a: a, org_b: b} do
    ctx = key_ctx(%{"groups" => %{"wiki" => %{}}})

    assert {:ok, orgs, nil} = VFS.list(Root, "/tobor", nil, ctx)
    assert Enum.map(orgs, & &1.name) == [a, b]

    # TRP unreachable/empty ⇒ an empty mount root, never an error.
    TestStub.reset()
    TrpCache.clear()
    assert {:ok, [], nil} = VFS.list(Root, "/tobor", nil, ctx)
    assert {:error, :enoent} = VFS.stat(Root, "/tobor/#{a}", ctx)
  end

  # ── principal isolation (P1: cache disabled) ──────────────────────────────

  test "two principals on the same paths see their own views", %{org_a: a, org_b: b} do
    wide = key_ctx(%{"groups" => %{"wiki" => %{}, "tickets" => %{}}})
    narrow = key_ctx(%{"groups" => %{"wiki" => %{}}})

    {:ok, wide_whoami} = read_meta!(Root, "/tobor/#{a}/_meta/whoami.json", wide)
    {:ok, narrow_whoami} = read_meta!(Root, "/tobor/#{a}/_meta/whoami.json", narrow)

    # Not cross-contaminated: different keys, different effective sets.
    assert wide_whoami["principal"]["api_key_id"] != narrow_whoami["principal"]["api_key_id"]
    assert wide_whoami["groups"]["tickets"]["included"] == true
    assert narrow_whoami["groups"]["tickets"]["included"] == false

    assert {:error, :enoent} =
             VFS.read(Root, "/tobor/#{a}/_meta/groups/tickets.json", narrow)

    assert {:ok, _, _} = VFS.read(Root, "/tobor/#{a}/_meta/groups/tickets.json", wide)

    # Both principals see both orgs (TRP scope is per-KEY; both keys share the
    # stub inventory) — org gating itself is exercised above.
    assert Principal.org_visible?(wide, b)
  end

  test "unresolvable principal fails closed: meta only, no groups", %{org_a: org} do
    # Claims without api_key_id/client_id: the cascade resolves nothing.
    ctx = %Ctx{
      server: NoizuPromptLingua.MCP.VFSServer,
      session_id: "anon-" <> Integer.to_string(System.unique_integer([:positive])),
      assigns: %{auth_claims: %{"sub" => "someone"}}
    }

    assert {:ok, _, _} = VFS.read(Root, "/tobor/#{org}/_meta/whoami.json", ctx)

    assert {:error, :enoent} = VFS.stat(Root, "/tobor/#{org}/wiki", ctx)
    assert {:ok, entries, _} = VFS.list(Root, "/tobor/#{org}", nil, ctx)
    assert Enum.map(entries, & &1.name) == ["_meta"]

    {:ok, whoami} = read_meta!(Root, "/tobor/#{org}/_meta/whoami.json", ctx)
    assert whoami["principal"]["api_key_id"] == nil
  end

  # ── /etc/dev invocation gate ──────────────────────────────────────────────

  test "tool_gate denies disabled/invisible/unknown, allows visible", %{org_a: _org} do
    ctx =
      key_ctx(%{
        "groups" => %{
          "wiki" => %{},
          "tickets" => %{"disabled" => true},
          "chat" => %{"hidden" => true}
        }
      })

    assert Principal.tool_gate("Wiki.PageGet", %{}, ctx) == :ok
    # Disabled tool: present, not invokable.
    assert Principal.tool_gate("Ticket_List", %{}, ctx) == {:error, :eacces}
    # Hidden group's tools: denied.
    assert Principal.tool_gate("Chat.ListMessages", %{}, ctx) == {:error, :eacces}
    # Unknown tools fail closed.
    assert Principal.tool_gate("Nonexistent_Tool", %{}, ctx) == {:error, :eacces}
  end

  test "per-user ACL deny hides the tool from the gate", %{org_a: org} do
    # Same key config, but the user carries an ACL rule denying Page.Get
    # (the D2 override layer is the final pass of the cascade).
    ctx = key_ctx(%{"groups" => %{"wiki" => %{}}})

    user_id = ctx.assigns.auth_claims["sub"]

    {:ok, _} =
      NoizuPromptLingua.Acl.create_rule(%{
        subject_ref: R.ref(module: NoizuPromptLingua.Users.User, id: user_id),
        resource_ref: R.ref(module: NoizuPromptLingua.Schema.McpTool, id: "Wiki_PageGet"),
        action: "mcp.tool",
        effect: "deny"
      })

    assert Principal.tool_gate("Wiki.PageGet", %{}, ctx) == {:error, :eacces}
    # Sibling tool unaffected.
    assert Principal.tool_gate("Wiki.SpaceList", %{}, ctx) == :ok

    # And the descriptor/meta plane still serves the group (deny ≠ exclude).
    assert {:ok, _, _} = VFS.read(Root, "/tobor/#{org}/_meta/groups/wiki.json", ctx)
  end
end
