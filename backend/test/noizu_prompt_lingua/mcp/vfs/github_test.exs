defmodule NoizuPromptLingua.MCP.VFS.GithubTest do
  @moduledoc """
  Wave 4 battery for the `github` read-mostly mirror VFS backend (design
  §2.19), through the backend directly (full absolute paths) and the
  cache-aware `Features.VFS` wrappers.

  Covers: the RepoList tree (owner/repo grouping, ACL-filtered, no
  existence leak), branch/pull/issue mirror round-trips against a local
  Bandit stub (`Noizu.Github.github_base/0` is a compile-time attribute, so
  the github_controller_test purge/recompile pattern repoints it at the
  stub), create ops (BranchCreate / PullCreate / IssueCreate / comments),
  the §3.5 PullMerge control-note (never a file write), client error →
  errno arms (404 / forbidden / token / transport), and the §1.3 gate
  matrix. No test touches the real GitHub API.
  """

  use NoizuPromptLingua.DataCase, async: false

  alias Noizu.MCP.Ctx
  alias Noizu.MCP.Server.Features.VFS
  alias Noizu.MCP.VFS.Cache
  alias NoizuPromptLingua.Authz.ScopedMemberships
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCP.VFS.Github, as: Backend
  alias NoizuPromptLingua.MockMCPStub
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.GithubRepo
  alias NoizuPromptLingua.Schema.GithubToken
  alias NoizuPromptLingua.Schema.Organizations.Organization
  alias NoizuPromptLingua.TRP.Cache, as: TrpCache
  alias NoizuPromptLingua.TRP.TestStub

  @group "github"

  setup do
    TrpCache.clear()
    TestStub.reset()

    suffix = Ecto.UUID.generate() |> binary_part(0, 8)
    org = Repo.insert!(%Organization{name: "VFS GH Org #{suffix}", slug: "vfs-gh-#{suffix}"})
    TestStub.seed_org(org.id, org.slug, org.name)

    uniq = System.unique_integer([:positive])

    user =
      %NoizuPromptLingua.Schema.Users.User{
        id: Ecto.UUID.generate(),
        email: "vfsgh-#{uniq}@example.com",
        user_name: "vfsgh#{uniq}",
        handle: "vfsgh#{uniq}",
        status: :active
      }
      |> Repo.insert!()

    # DB-level org membership drives the client ACL; the TRP stub drives the
    # VFS §1.3 org gate. Both must see this principal.
    {:ok, _} = ScopedMemberships.add_member("organization", org.id, user.id, "member")

    {:ok, token} =
      Repo.insert(%GithubToken{
        organization_id: org.id,
        label: "ci",
        token: "ghp_secret1234567890"
      })

    repo! = fn full_name, acl, token_id ->
      Repo.insert!(%GithubRepo{
        organization_id: org.id,
        repo_full_name: full_name,
        default_acl: acl,
        token_id: token_id
      })
    end

    repos = %{
      read: repo!.("acme/readrepo", "org_read", token.id),
      write: repo!.("acme/writerepo", "org_write", token.id),
      private: repo!.("acme/privrepo", "private", token.id),
      bare: repo!.("acme/barerepo", "org_read", nil)
    }

    on_exit(fn -> Cache.purge(Backend) end)

    %{
      org: org,
      user: user,
      repos: repos,
      ctx: key_ctx(user.id, %{"groups" => %{@group => %{}}})
    }
  end

  defp key_ctx(user_id, config, session \\ nil) do
    uniq = System.unique_integer([:positive])

    {:ok, key, _} = MCPApiKeys.generate_api_key(user_id, "vfs-github", toolset_config: config)

    %Ctx{
      server: NoizuPromptLingua.MCP.VFSServer,
      session_id: session || "gh-" <> Integer.to_string(uniq),
      assigns: %{auth_claims: %{"api_key_id" => key.id, "sub" => user_id}}
    }
  end

  defp base(org), do: "/tobor/#{org.slug}/github"
  defp repo_base(org, name), do: "#{base(org)}/acme/#{name}"

  # ── RepoList tree (DB-only, ACL-filtered) ─────────────────────────────────

  test "the mirror tree lists ACL-readable repos grouped by owner", %{org: org, ctx: ctx} do
    assert {:ok, dir} = VFS.stat(Backend, base(org), ctx)
    assert dir.type == :dir and dir.writable == false

    assert {:ok, entries, nil} = VFS.list(Backend, base(org), nil, ctx)
    assert Enum.map(entries, & &1.name) == ["overview.md", "acme"]

    assert {:ok, entries, nil} = VFS.list(Backend, "#{base(org)}/acme", nil, ctx)
    # `private` is filtered (no existence leak); token-less repos still list.
    assert Enum.map(entries, & &1.name) == ["barerepo", "readrepo", "writerepo"]

    assert {:ok, md, _} = VFS.read(Backend, "#{base(org)}/overview.md", ctx)
    assert md =~ "github"
    assert md =~ "RepoList"
  end

  test "unreachable repos are :enoent (no existence leak)", %{org: org, ctx: ctx} do
    assert {:error, :enoent} = VFS.stat(Backend, "#{base(org)}/acme/privrepo", ctx)
    assert {:error, :enoent} = VFS.stat(Backend, "#{base(org)}/acme/ghostrepo", ctx)
    assert {:error, :enoent} = VFS.stat(Backend, "#{base(org)}/ghostorg/readrepo", ctx)
    assert {:error, :enoent} = VFS.list(Backend, "#{base(org)}/acme/privrepo/pulls", nil, ctx)
  end

  test "a visible repo lists its collections; reads need a mapped token", %{org: org, ctx: ctx} do
    assert {:ok, dir} = VFS.stat(Backend, repo_base(org, "readrepo"), ctx)
    assert dir.type == :dir

    assert {:ok, entries, nil} = VFS.list(Backend, repo_base(org, "readrepo"), nil, ctx)
    assert Enum.map(entries, & &1.name) == ["branches", "pulls", "issues"]

    # Syntactic stat (shape only); the read is the authoritative fetch.
    assert {:ok, file} = VFS.stat(Backend, "#{repo_base(org, "readrepo")}/pulls/1.json", ctx)
    assert file.type == :file

    # Token-less repo: readable per ACL, unservable without creds → :eacces.
    assert {:error, :eacces} =
             VFS.read(Backend, "#{repo_base(org, "barerepo")}/branches/main.json", ctx)
  end

  # ── mirror round-trips (local Bandit stub, recompiled base) ───────────────

  describe "outbound mirror reads via local stub" do
    setup %{org: org, user: user} do
      stub = github_stub()
      {:ok, org: org, user: user, stub: stub}
    end

    test "BranchList readdir + BranchGet, slashy branch names encoded", %{
      org: org,
      ctx: ctx,
      stub: stub
    } do
      stub_body(
        stub,
        "branches",
        ~s([{"name":"main","commit":{"sha":"a1"}},{"name":"feat/x","commit":{"sha":"b2"}}])
      )

      stub_body(stub, "main", ~s({"name":"main","commit":{"sha":"a1"}}))
      stub_body(stub, "x", ~s({"name":"feat/x","commit":{"sha":"b2"}}))

      assert {:ok, entries, nil} =
               VFS.list(Backend, "#{repo_base(org, "readrepo")}/branches", nil, ctx)

      assert Enum.map(entries, & &1.name) == ["feat%2Fx.json", "main.json"]

      assert {:ok, json, _} =
               VFS.read(Backend, "#{repo_base(org, "readrepo")}/branches/main.json", ctx)

      assert %{"name" => "main", "commit" => %{"sha" => "a1"}} = Jason.decode!(json)

      # %2F decodes back to the branch name for the upstream fetch.
      assert {:ok, json2, _} =
               VFS.read(Backend, "#{repo_base(org, "readrepo")}/branches/feat%2Fx.json", ctx)

      assert %{"name" => "feat/x"} = Jason.decode!(json2)

      {_headers, _body} = MockMCPStub.last_request(stub, "main")
      assert MockMCPStub.last_method(stub, "main") == "GET"
    end

    test "PullList readdir includes the §3.5 merge control notes; PullGet reads", %{
      org: org,
      ctx: ctx,
      stub: stub
    } do
      stub_body(stub, "pulls", ~s([{"number":2,"title":"Two"},{"number":1,"title":"One"}]))
      stub_body(stub, "1", ~s({"number":1,"title":"One","state":"open"}))

      assert {:ok, entries, nil} =
               VFS.list(Backend, "#{repo_base(org, "readrepo")}/pulls", nil, ctx)

      assert Enum.map(entries, & &1.name) == ["1.json", "1.merge", "2.json", "2.merge"]
      assert Enum.all?(entries, &(&1.type in [:file, :control]))

      assert {:ok, json, _} = VFS.read(Backend, "#{repo_base(org, "readrepo")}/pulls/1.json", ctx)
      assert %{"number" => 1, "title" => "One"} = Jason.decode!(json)
    end

    test "the merge note documents the confirm-gated /etc/dev route; merging is never a file write",
         %{
           org: org,
           ctx: ctx
         } do
      path = "#{repo_base(org, "readrepo")}/pulls/1.merge"

      assert {:ok, node} = VFS.stat(Backend, path, ctx)
      assert node.type == :control and node.writable == false
      assert node.xattrs["file_write"] == "never"

      assert {:ok, note, _} = VFS.read(Backend, path, ctx)
      {:ok, doc} = Jason.decode(note)
      assert doc["op"] == "Github.PullMerge"
      assert doc["route"] == "/etc/dev/tools/Github.PullMerge"
      assert doc["gate"] =~ "tool_gate"

      # §3.5: merge state transitions ride control writes, never content edits.
      assert {:error, :enosys} = VFS.write(Backend, path, "{}", ctx)

      assert {:error, :enosys} =
               VFS.write(Backend, "#{repo_base(org, "readrepo")}/pulls/1.json", "{}", ctx)

      assert {:error, :enosys} = VFS.remove(Backend, path, ctx)
    end

    test "IssueList readdir + IssueGet", %{org: org, ctx: ctx, stub: stub} do
      stub_body(stub, "issues", ~s([{"number":3,"title":"Broken","state":"open"}]))
      stub_body(stub, "3", ~s({"number":3,"title":"Broken","state":"open"}))

      assert {:ok, entries, nil} =
               VFS.list(Backend, "#{repo_base(org, "readrepo")}/issues", nil, ctx)

      assert Enum.map(entries, & &1.name) == ["3.json"]

      assert {:ok, json, _} =
               VFS.read(Backend, "#{repo_base(org, "readrepo")}/issues/3.json", ctx)

      assert %{"number" => 3, "title" => "Broken"} = Jason.decode!(json)
    end

    test "comment dirs list and read back at {id}.json", %{org: org, ctx: ctx, stub: stub} do
      stub_body(stub, "comments", ~s([{"id":5,"body":"first"},{"id":6,"body":"second"}]))

      assert {:ok, entries, nil} =
               VFS.list(Backend, "#{repo_base(org, "readrepo")}/pulls/1.comments", nil, ctx)

      assert Enum.map(entries, & &1.name) == ["5.json", "6.json"]

      stub_body(stub, "comments", ~s([{"id":5,"body":"first"},{"id":6,"body":"second"}]))

      assert {:ok, json, _} =
               VFS.read(Backend, "#{repo_base(org, "readrepo")}/pulls/1.comments/6.json", ctx)

      assert %{"id" => 6, "body" => "second"} = Jason.decode!(json)

      assert {:error, :enoent} =
               VFS.read(Backend, "#{repo_base(org, "readrepo")}/pulls/1.comments/99.json", ctx)
    end

    test "error arms: 404 → :enoent, unauthorized → :enoent, other statuses → :eio", %{
      org: org,
      ctx: ctx,
      stub: stub
    } do
      # Status entries go to seq directly (stub_body wraps in {:raw, ...}).
      MockMCPStub.seq(stub, "ghost", [{:status, 404, ~s({"message":"Not Found"})}])
      MockMCPStub.seq(stub, "boom", [{:status, 502, ~s({"message":"boom"})}])

      assert {:error, :enoent} =
               VFS.read(Backend, "#{repo_base(org, "readrepo")}/branches/ghost.json", ctx)

      assert {:error, :eio} =
               VFS.read(Backend, "#{repo_base(org, "readrepo")}/branches/boom.json", ctx)

      # A private repo (exists, not readable) hides behind :enoent on reads.
      assert {:error, :enoent} =
               VFS.read(Backend, "#{repo_base(org, "privrepo")}/branches/main.json", ctx)
    end
  end

  # ── create ops (stubbed outbound) ─────────────────────────────────────────

  describe "create ops via local stub" do
    setup %{org: org, user: user} do
      stub = github_stub()
      {:ok, org: org, user: user, stub: stub}
    end

    test "BranchCreate posts refs/heads/{name} from the request sha", %{
      org: org,
      ctx: ctx,
      stub: stub
    } do
      stub_body(stub, "refs", ~s({"ref":"refs/heads/feature","object":{"sha":"deadbeef"}}))

      request = Jason.encode!(%{"sha" => "deadbeef"})

      assert {:ok, node} =
               VFS.create(
                 Backend,
                 "#{repo_base(org, "writerepo")}/branches/feature.json",
                 request,
                 ctx
               )

      assert node.type == :file

      {_headers, body} = MockMCPStub.last_request(stub, "refs")
      assert %{"ref" => "refs/heads/feature", "sha" => "deadbeef"} = Jason.decode!(body)
      assert MockMCPStub.last_method(stub, "refs") == "POST"
    end

    test "PullCreate accepts any filename; an existing number collides with :eexist", %{
      org: org,
      ctx: ctx,
      stub: stub
    } do
      stub_body(stub, "pulls", ~s({"number":9,"title":"New PR"}))
      stub_body(stub, "1", ~s({"number":1,"title":"One"}))

      request = Jason.encode!(%{"title" => "New PR", "head" => "feat", "base" => "main"})

      assert {:ok, _} =
               VFS.create(
                 Backend,
                 "#{repo_base(org, "writerepo")}/pulls/new-pr.json",
                 request,
                 ctx
               )

      {_headers, body} = MockMCPStub.last_request(stub, "pulls")
      assert %{"title" => "New PR", "head" => "feat", "base" => "main"} = Jason.decode!(body)

      assert {:error, :eexist} =
               VFS.create(Backend, "#{repo_base(org, "writerepo")}/pulls/1.json", request, ctx)

      # Missing required fields are a malformed request.
      assert {:error, :eio} =
               VFS.create(
                 Backend,
                 "#{repo_base(org, "writerepo")}/pulls/other.json",
                 ~s({"title":"x"}),
                 ctx
               )
    end

    test "IssueCreate + IssueComment post through the mirror", %{org: org, ctx: ctx, stub: stub} do
      stub_body(stub, "issues", ~s({"number":4,"title":"Fresh"}))
      stub_body(stub, "comments", ~s({"id":12,"body":"looks bad"}))

      assert {:ok, _} =
               VFS.create(
                 Backend,
                 "#{repo_base(org, "writerepo")}/issues/queue-item.json",
                 Jason.encode!(%{"title" => "Fresh", "body" => "steps..."}),
                 ctx
               )

      assert {:ok, _} =
               VFS.create(
                 Backend,
                 "#{repo_base(org, "writerepo")}/issues/4.comments/ts-a.json",
                 Jason.encode!(%{"body" => "looks bad"}),
                 ctx
               )

      {_headers, body} = MockMCPStub.last_request(stub, "comments")
      # Issue comments post through the same issues-comments API.
      assert Jason.decode!(body) == "looks bad"
    end

    test "PullComment posts to the issues-comments API", %{org: org, ctx: ctx, stub: stub} do
      stub_body(stub, "comments", ~s({"id":7,"body":"ship it"}))

      assert {:ok, _} =
               VFS.create(
                 Backend,
                 "#{repo_base(org, "writerepo")}/pulls/2.comments/ts-b.json",
                 Jason.encode!(%{"body" => "ship it"}),
                 ctx
               )

      {_headers, body} = MockMCPStub.last_request(stub, "comments")
      # The client posts the comment text as the raw JSON body string.
      assert Jason.decode!(body) == "ship it"

      assert {:error, :eio} =
               VFS.create(
                 Backend,
                 "#{repo_base(org, "writerepo")}/pulls/2.comments/ts-c.json",
                 ~s({"body": ""}),
                 ctx
               )
    end

    test "create on a readable but non-writable repo is :eacces", %{org: org, ctx: ctx} do
      request = Jason.encode!(%{"title" => "T", "head" => "h", "base" => "b"})

      assert {:error, :eacces} =
               VFS.create(Backend, "#{repo_base(org, "readrepo")}/pulls/new.json", request, ctx)

      assert {:error, :eacces} =
               VFS.create(
                 Backend,
                 "#{repo_base(org, "readrepo")}/branches/x.json",
                 Jason.encode!(%{"sha" => "abc"}),
                 ctx
               )
    end
  end

  # ── transport failure ─────────────────────────────────────────────────────

  test "a dead upstream maps to :eio", %{org: org, ctx: ctx} do
    github_stub(:dead)

    assert {:error, :eio} =
             VFS.read(Backend, "#{repo_base(org, "readrepo")}/branches/main.json", ctx)
  end

  # ── read-only + cursor policy ─────────────────────────────────────────────

  test "mirror content is never edited in place; unknown nodes are :enoent", %{org: org, ctx: ctx} do
    assert {:error, :enosys} = VFS.write(Backend, "#{base(org)}/overview.md", "x", ctx)
    assert {:error, :enosys} = VFS.create(Backend, repo_base(org, "readrepo"), :dir, ctx)
    assert {:error, :eisdir} = VFS.read(Backend, "#{repo_base(org, "readrepo")}/pulls", ctx)

    assert {:error, :enotdir} =
             VFS.list(Backend, "#{repo_base(org, "readrepo")}/pulls/1.json", nil, ctx)

    assert {:error, :enoent} =
             VFS.read(Backend, "#{repo_base(org, "readrepo")}/pulls/not-a-number.json", ctx)

    assert {:error, :enoent} =
             VFS.read(Backend, "#{repo_base(org, "readrepo")}/branches/.json", ctx)
  end

  test "cursor policy: valid empty cursor, foreign cursor rejected", %{org: org, ctx: ctx} do
    assert {:ok, _entries, nil} = VFS.list(Backend, base(org), nil, ctx)
    assert {:ok, _entries, nil} = VFS.list(Backend, base(org), "", ctx)
    assert {:error, %Noizu.MCP.Error{}} = VFS.list(Backend, base(org), "bogus-cursor", ctx)
  end

  # ── gating (§1.3) ─────────────────────────────────────────────────────────

  test "excluded group is :enoent everywhere", %{org: org, user: user} do
    ctx = key_ctx(user.id, %{"groups" => %{"markdown" => %{}}})

    assert {:error, :enoent} = VFS.stat(Backend, base(org), ctx)
    assert {:error, :enoent} = VFS.list(Backend, base(org), nil, ctx)
    assert {:error, :enoent} = VFS.read(Backend, "#{base(org)}/overview.md", ctx)
  end

  test "included-but-disabled group reads; create ops are :eacces", %{org: org, user: user} do
    ctx = key_ctx(user.id, %{"groups" => %{@group => %{"disabled" => true}}})

    assert {:ok, dir} = VFS.stat(Backend, base(org), ctx)
    assert dir.writable == false

    assert {:ok, entries, nil} = VFS.list(Backend, base(org), nil, ctx)
    assert Enum.map(entries, & &1.name) == ["overview.md", "acme"]

    assert {:error, :eacces} =
             VFS.create(
               Backend,
               "#{repo_base(org, "writerepo")}/pulls/new.json",
               Jason.encode!(%{"title" => "T", "head" => "h", "base" => "b"}),
               ctx
             )
  end

  test "an org the principal cannot see is :enoent", %{user: user} do
    ctx = key_ctx(user.id, %{"groups" => %{@group => %{}}})

    assert {:error, :enoent} = VFS.stat(Backend, "/tobor/no-such-org/#{@group}", ctx)
  end

  test "a principal without an identity leaks nothing", %{org: org} do
    # Claims-less connections fail the §1.3 org gate first — the tree's shape
    # and existence are invisible (the backend's inner :eacces identity guard
    # is defense-in-depth behind it).
    ctx = %Ctx{server: NoizuPromptLingua.MCP.VFSServer, session_id: "anon", assigns: %{}}

    assert {:error, :enoent} = VFS.stat(Backend, base(org), ctx)
    assert {:error, :enoent} = VFS.list(Backend, base(org), nil, ctx)
    assert {:error, :enoent} = VFS.read(Backend, "#{base(org)}/overview.md", ctx)
  end

  # ── stub plumbing (github_controller_test purge/recompile pattern) ────────

  @deps_github_source Path.join([
                        __DIR__,
                        "../../../..",
                        "deps/noizu_github/lib/noizu_github.ex"
                      ])

  defp github_stub, do: github_stub(:live)

  # `:dead` compiles against an unbound port — no listener — to drive the
  # transport-failure path without killing a live stub.
  defp github_stub(:dead) do
    {:ok, sock} = :gen_tcp.listen(0, ip: {127, 0, 0, 1})
    {:ok, port} = :inet.port(sock)
    :gen_tcp.close(sock)

    recompile_base("http://127.0.0.1:#{port}")
    :ok
  end

  defp github_stub(:live) do
    stub = MockMCPStub.start()
    on_exit(fn -> MockMCPStub.stop(stub) end)
    recompile_base("http://127.0.0.1:#{stub.port}")
    stub
  end

  defp recompile_base(base_url) do
    if Process.whereis(Noizu.Github.Finch) == nil do
      start_supervised!({Finch, name: Noizu.Github.Finch})
    end

    patched =
      @deps_github_source
      |> File.read!()
      |> String.replace(
        ~s(@github_base "https://api.github.com"),
        ~s(@github_base "#{base_url}")
      )

    :code.purge(Noizu.Github)
    :code.delete(Noizu.Github)

    # The dep source carries pre-existing warnings outside its cached build —
    # keep them out of the suite output.
    ExUnit.CaptureIO.capture_io(:stdio, fn ->
      ExUnit.CaptureIO.capture_io(:stderr, fn ->
        Code.compile_string(patched, @deps_github_source)
      end)
    end)

    on_exit(fn ->
      :code.purge(Noizu.Github)
      :code.delete(Noizu.Github)
    end)

    :ok
  end

  defp stub_body(stub, segment, raw_json) do
    MockMCPStub.seq(stub, segment, [{:raw, raw_json}])
  end
end
