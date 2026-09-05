defmodule NoizuPromptLinguaWeb.GithubControllerTest do
  @moduledoc """
  Org-scoped GitHub proxy. Covers every branch reachable without live GitHub
  traffic (repo-index DB read with ACL filtering + token masking, repo
  resolution by UUID and owner/name ref, org resolution, and the per-repo ACL
  ladder) PLUS the outbound callback bodies, which are exercised against a
  local Bandit stub: `Noizu.Github.github_base/0` bakes `api.github.com` into
  the module at COMPILE time (plain module attribute, no runtime seam), so the
  tests purge `Noizu.Github` and recompile its source IN MEMORY with the base
  rewritten to `http://127.0.0.1:<stub-port>` — the weaviate_store_test.exs
  purge/recompile pattern, with a source rewrite since the base is an
  attribute rather than an Application env. `on_exit` purges again and the
  on-disk beam reloads untouched.
  """
  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.MockMCPStub
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.GithubRepo
  alias NoizuPromptLingua.Schema.GithubToken

  setup %{conn: conn} do
    %{access_token: token} = setup_user_and_token()
    auth = authenticated_conn(conn, token)

    slug = "gh-org-#{System.unique_integer([:positive])}"

    org_id =
      auth
      |> post("/api/v1/organizations", %{organization: %{slug: slug, name: "GH Org"}})
      |> json_response(201)
      |> get_in(["organization", "id"])

    {:ok, gh_token} =
      Repo.insert(%GithubToken{
        organization_id: org_id,
        label: "ci",
        token: "ghp_secret1234567890"
      })

    {:ok, repo_read} =
      Repo.insert(%GithubRepo{
        organization_id: org_id,
        repo_full_name: "acme/readrepo",
        default_acl: "org_read",
        token_id: gh_token.id
      })

    {:ok, repo_private} =
      Repo.insert(%GithubRepo{
        organization_id: org_id,
        repo_full_name: "acme/privrepo",
        default_acl: "private",
        token_id: gh_token.id
      })

    {:ok, repo_bare} =
      Repo.insert(%GithubRepo{
        organization_id: org_id,
        repo_full_name: "acme/barerepo",
        default_acl: "org_read"
      })

    %{access_token: outsider_token} = setup_user_and_token()

    {:ok,
     auth: auth,
     org_id: org_id,
     repo_read: repo_read,
     repo_private: repo_private,
     repo_bare: repo_bare,
     outsider_token: outsider_token}
  end

  defp base(org_id), do: "/api/v1/organizations/#{org_id}/github"

  # ── Repo index (DB read, ACL-filtered) ────────────────────────────────────

  describe "GET /github (repos index)" do
    test "member sees ACL-readable repos with masked tokens", %{
      auth: auth,
      org_id: org_id,
      repo_read: rr,
      repo_bare: rb,
      repo_private: repo_private
    } do
      assert %{"count" => 2, "repos" => repos} =
               auth |> get(base(org_id)) |> json_response(200)

      by_id = Map.new(repos, &{&1["id"], &1})
      assert Map.has_key?(by_id, rr.id)
      assert Map.has_key?(by_id, rb.id)
      refute Map.has_key?(by_id, repo_private.id)

      # org_read grants member read; the private repo is filtered, and the
      # bare repo's masked token is nil.
      assert by_id[rr.id]["token_preview"] == "ghp_" <> String.duplicate("•", 16)
      assert by_id[rb.id]["token_preview"] == nil
    end

    test "repo_full_name is exposed", %{auth: auth, org_id: org_id} do
      %{"repos" => repos} = auth |> get(base(org_id)) |> json_response(200)
      assert Enum.any?(repos, &(&1["repo_full_name"] == "acme/readrepo"))
    end

    test "non-member sees zero repos (200, ACL-filtered)", %{
      conn: conn,
      org_id: org_id,
      outsider_token: t
    } do
      assert %{"count" => 0, "repos" => []} =
               conn |> authenticated_conn(t) |> get(base(org_id)) |> json_response(200)
    end

    test "unknown org slug is 404", %{auth: auth} do
      assert %{"error" => "Organization not found"} =
               auth |> get(base("no-such-gh-org")) |> json_response(404)
    end

    test "unauthenticated request is rejected by the pipeline", %{conn: conn, org_id: org_id} do
      assert %{"error" => "unauthenticated"} = conn |> get(base(org_id)) |> json_response(401)
    end

    test "controller-level 401 arms guard bare conns", %{org_id: org_id, repo_read: rr} do
      bare = Phoenix.ConnTest.build_conn()

      conn = NoizuPromptLinguaWeb.GithubController.index(bare, %{"org_id" => org_id})
      assert conn.status == 401
      assert %{"error" => "Unauthorized"} = Jason.decode!(conn.resp_body)

      conn2 =
        NoizuPromptLinguaWeb.GithubController.list_pulls(bare, %{
          "org_id" => org_id,
          "repo_id" => rr.id
        })

      assert conn2.status == 401
      assert %{"error" => "Unauthorized"} = Jason.decode!(conn2.resp_body)
    end
  end

  # ── Per-repo routes: resolution + ACL ladder ──────────────────────────────

  describe "repo resolution + ACL (pulls/issues/branches routes)" do
    test "unknown repo uuid is 404", %{auth: auth, org_id: org_id} do
      assert %{"error" => "Repository not found"} =
               auth
               |> get(base(org_id) <> "/repos/#{Ecto.UUID.generate()}/pulls")
               |> json_response(404)
    end

    test "repo without a mapped token is 422", %{auth: auth, org_id: org_id, repo_bare: rb} do
      assert %{"error" => "No token mapped to this repository"} =
               auth
               |> get(base(org_id) <> "/repos/#{rb.id}/pulls")
               |> json_response(422)
    end

    test "repo resolvable by owner/name ref (%2F encoded)", %{
      auth: auth,
      org_id: org_id
    } do
      assert %{"error" => "No token mapped to this repository"} =
               auth
               |> get(base(org_id) <> "/repos/acme%2Fbarerepo/pulls")
               |> json_response(422)
    end

    test "private repo denies a fellow org member read (403)", %{
      auth: auth,
      org_id: org_id,
      repo_private: rp
    } do
      assert %{"error" => "Insufficient permissions"} =
               auth
               |> get(base(org_id) <> "/repos/#{rp.id}/pulls", state: "open")
               |> json_response(403)
    end

    test "non-member is denied read on an org_read repo (403)", %{
      conn: conn,
      org_id: org_id,
      repo_read: rr,
      outsider_token: t
    } do
      assert %{"error" => "Insufficient permissions"} =
               conn
               |> authenticated_conn(t)
               |> get(base(org_id) <> "/repos/#{rr.id}/pulls")
               |> json_response(403)
    end

    test "write on an org_read repo is denied even for a member (403)", %{
      auth: auth,
      org_id: org_id,
      repo_read: rr
    } do
      assert %{"error" => "Insufficient permissions"} =
               auth
               |> post(base(org_id) <> "/repos/#{rr.id}/pulls", %{
                 pull: %{title: "T", head: "a", base: "main"}
               })
               |> json_response(403)
    end

    test "unknown org slug is 404 on repo routes", %{auth: auth, repo_read: rr} do
      assert %{"error" => "Organization not found"} =
               auth
               |> get("/api/v1/organizations/no-such-gh-org/github/repos/#{rr.id}/issues")
               |> json_response(404)
    end

    test "issue creation body is taken before resolution; unknown repo still 404", %{
      auth: auth,
      org_id: org_id
    } do
      assert %{"error" => "Repository not found"} =
               auth
               |> post(base(org_id) <> "/repos/#{Ecto.UUID.generate()}/issues", %{
                 issue: %{title: "Broken", labels: ["bug"]}
               })
               |> json_response(404)
    end

    test "merge body is taken before resolution; unknown repo still 404", %{
      auth: auth,
      org_id: org_id
    } do
      assert %{"error" => "Repository not found"} =
               auth
               |> put(base(org_id) <> "/repos/#{Ecto.UUID.generate()}/pulls/1/merge", %{
                 pull: %{merge_method: "squash"}
               })
               |> json_response(404)
    end

    test "unauthenticated repo route is rejected by the pipeline", %{
      conn: conn,
      org_id: org_id,
      repo_read: rr
    } do
      assert %{"error" => "unauthenticated"} =
               conn
               |> get(base(org_id) <> "/repos/#{rr.id}/branches")
               |> json_response(401)
    end
  end

  # ── Outbound GitHub calls (local Bandit stub, recompiled base URL) ────────

  @deps_github_source Path.join([
                        __DIR__,
                        "../../..",
                        "deps/noizu_github/lib/noizu_github.ex"
                      ])

  # Purge + in-memory recompile of Noizu.Github with @github_base pointed at
  # the stub port. The api/* modules call github_base() at runtime, so the
  # rewrite repoints every outbound URL.
  defp github_stub, do: github_stub(:live)

  # `:dead` compiles against an unbound port — no listener — to drive the
  # transport-failure path without killing a live stub (which would signal the
  # linked test process).
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

  describe "outbound GitHub calls via local stub" do
    setup %{auth: auth, org_id: org_id, repo_read: rr} do
      # Write-capable repo for the POST/PUT arms.
      {:ok, gh_token} =
        Repo.insert(%GithubToken{
          organization_id: org_id,
          label: "w",
          token: "ghp_write_token_123456"
        })

      {:ok, repo_write} =
        Repo.insert(%GithubRepo{
          organization_id: org_id,
          repo_full_name: "acme/writerepo",
          default_acl: "org_write",
          token_id: gh_token.id
        })

      stub = github_stub()

      {:ok, auth: auth, org_id: org_id, repo_read: rr, repo_write: repo_write, stub: stub}
    end

    test "list_pulls hits the stub with the mapped token and returns items", %{
      auth: auth,
      org_id: org_id,
      repo_read: rr,
      stub: stub
    } do
      stub_body(stub, "pulls", ~s([{"number":1,"title":"PR one"}]))

      %{"items" => items} =
        auth
        |> get(base(org_id) <> "/repos/#{rr.id}/pulls", state: "open", per_page: "5")
        |> json_response(200)

      # Collection models flatten to %{items: [...]} maps (cov-w5a client
      # bugfix made the nested structs Jason-encodable).
      assert Enum.any?(items, &(&1["title"] == "PR one"))

      {headers, _body} = MockMCPStub.last_request(stub, "pulls")
      assert {"authorization", "Bearer ghp_secret1234567890"} in headers
      assert MockMCPStub.last_method(stub, "pulls") == "GET"
    end

    test "get_pull parses the pull number (incl. non-numeric tail)", %{
      auth: auth,
      org_id: org_id,
      repo_read: rr,
      stub: stub
    } do
      # GET /repos/o/r/pulls/7 — stub keys on the LAST path segment ("7").
      stub_body(stub, "7", ~s({"number":7,"title":"Seven"}))

      body = auth |> get(base(org_id) <> "/repos/#{rr.id}/pulls/7") |> json_response(200)
      assert body["title"] == "Seven"
      assert body["number"] == 7

      body2 = auth |> get(base(org_id) <> "/repos/#{rr.id}/pulls/7garbage") |> json_response(200)
      assert body2["title"] == "Seven"
    end

    test "create_pull posts the mapped body", %{
      auth: auth,
      org_id: org_id,
      repo_write: rw,
      stub: stub
    } do
      stub_body(stub, "pulls", ~s({"number":2,"title":"New PR"}))

      %{"title" => "New PR"} =
        auth
        |> post(base(org_id) <> "/repos/#{rw.id}/pulls", %{
          pull: %{title: "New PR", head: "feat", base: "main", junk: "dropped"}
        })
        |> json_response(200)

      {_headers, req_body} = MockMCPStub.last_request(stub, "pulls")
      assert %{"title" => "New PR", "head" => "feat", "base" => "main"} = Jason.decode!(req_body)
      refute Map.has_key?(Jason.decode!(req_body), "junk")
      assert MockMCPStub.last_method(stub, "pulls") == "POST"
    end

    test "merge_pull PUTs the merge body", %{
      auth: auth,
      org_id: org_id,
      repo_write: rw,
      stub: stub
    } do
      stub_body(stub, "merge", ~s({"merged":true,"sha":"deadbeef"}))

      %{"merged" => true} =
        auth
        |> put(base(org_id) <> "/repos/#{rw.id}/pulls/1/merge", %{
          pull: %{merge_method: "squash"}
        })
        |> json_response(200)

      assert MockMCPStub.last_method(stub, "merge") == "PUT"
    end

    test "pull conversation comments list + create via the issues-comments API", %{
      auth: auth,
      org_id: org_id,
      repo_write: rw,
      stub: stub
    } do
      stub_body(stub, "comments", ~s([{"id":11,"body":"nice"}]))

      %{"items" => comments} =
        auth
        |> get(base(org_id) <> "/repos/#{rw.id}/pulls/1/comments")
        |> json_response(200)

      assert Enum.any?(comments, &(&1["body"] == "nice"))

      stub_body(stub, "comments", ~s({"id":12,"body":"posted"}))

      %{"body" => "posted"} =
        auth
        |> post(base(org_id) <> "/repos/#{rw.id}/pulls/1/comments", %{comment: %{body: "posted"}})
        |> json_response(200)
    end

    test "issues list / get / create / comment", %{
      auth: auth,
      org_id: org_id,
      repo_write: rw,
      stub: stub
    } do
      stub_body(stub, "issues", ~s([{"number":5,"title":"Broken"}]))

      %{"items" => issues} =
        auth
        |> get(base(org_id) <> "/repos/#{rw.id}/issues", labels: "bug")
        |> json_response(200)

      assert Enum.any?(issues, &(&1["title"] == "Broken"))

      stub_body(stub, "5", ~s({"number":5,"title":"Broken"}))

      %{"title" => "Broken"} =
        auth
        |> get(base(org_id) <> "/repos/#{rw.id}/issues/5")
        |> json_response(200)

      stub_body(stub, "issues", ~s({"number":6,"title":"New issue"}))

      %{"title" => "New issue"} =
        auth
        |> post(base(org_id) <> "/repos/#{rw.id}/issues", %{
          issue: %{title: "New issue", labels: ["bug"]}
        })
        |> json_response(200)

      stub_body(stub, "comments", ~s({"id":31,"body":"me too"}))

      %{"body" => "me too"} =
        auth
        |> post(base(org_id) <> "/repos/#{rw.id}/issues/5/comments", %{comment: %{body: "me too"}})
        |> json_response(200)
    end

    test "branches list + create", %{auth: auth, org_id: org_id, repo_write: rw, stub: stub} do
      stub_body(stub, "branches", ~s([{"name":"main","commit":{"sha":"s1"}}]))

      %{"items" => branches} =
        auth
        |> get(base(org_id) <> "/repos/#{rw.id}/branches")
        |> json_response(200)

      assert Enum.any?(branches, &(&1["name"] == "main"))

      stub_body(stub, "refs", ~s({"ref":"refs/heads/nb","object":{"sha":"s1"}}))

      %{"ref" => "refs/heads/nb"} =
        auth
        |> post(base(org_id) <> "/repos/#{rw.id}/branches", %{
          branch: %{name: "nb", from_sha: "s1"}
        })
        |> json_response(200)
    end

    test "GitHub 4xx is surfaced as {error, status, github_error}", %{
      auth: auth,
      org_id: org_id,
      repo_read: rr,
      stub: stub
    } do
      MockMCPStub.seq(stub, "pulls", [{:status, 404, ~s({"message":"Not Found"})}])

      assert %{"error" => "GitHub API error", "status" => 404, "github_error" => body} =
               auth
               |> get(base(org_id) <> "/repos/#{rr.id}/pulls")
               |> json_response(404)

      assert body =~ "Not Found"
    end

    test "transport failure falls through to the catch-all 500 arm", %{
      auth: auth,
      org_id: org_id,
      repo_read: rr
    } do
      # Recompile against an unbound port — no listener. Finch returns a
      # connection-refused error, normalize passes it through, and
      # handle_error's catch-all answers.
      github_stub(:dead)

      assert %{"error" => "Unknown error"} =
               auth
               |> get(base(org_id) <> "/repos/#{rr.id}/pulls")
               |> json_response(500)
    end
  end
end
