defmodule NoizuPromptLinguaWeb.GithubControllerTest do
  @moduledoc """
  Org-scoped GitHub proxy. Covers every branch reachable without live GitHub
  traffic: the repo-index DB read (ACL-filtered, token masking), repo
  resolution by UUID and owner/name ref, org resolution, and the per-repo ACL
  ladder (401 pipeline / 404 org / 404 repo / 422 unmapped token / 403
  forbidden — including write-level denial on read-scoped repos).

  Uncovered by design (requires live api.github.com traffic; no offline HTTP
  stub exists for the compile-time-hardcoded Noizu.Github.Api base URL): the
  Client callback bodies (parse_int/opts_from_params helpers), the
  {:error, {:github, status, body}} handler arm, and the catch-all handler arm.
  The controller's {nil, _} 401 arms are similarly unreachable — the
  :authenticated pipeline rejects first.
  """
  use NoizuPromptLinguaWeb.ConnCase

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
end
