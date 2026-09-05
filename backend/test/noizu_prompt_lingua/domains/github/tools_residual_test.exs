defmodule NoizuPromptLingua.Domains.Github.ToolsResidualTest do
  @moduledoc """
  Wave-5B coverage for the GitHub MCP tool surface beyond the invalid-caller
  pins: per-tool argument validation (missing org → `:organization_not_found`),
  the `repo_not_found` short-circuit (an unknown `owner/name` repo fails in
  `Github.Client.resolve_repo/4` BEFORE any GitHub HTTP call), and `Overview`.

  Also documents the Map.take fix: IssueCreate / PullCreate / PullMerge build
  their request bodies with `Map.new/1` + `Map.take/2` and now reach the client
  path (which `repo_not_found`s here) instead of raising BadMapError.

  No test in this file reaches the network: unknown repos resolve to
  `{:error, :repo_not_found}` from the local DB alone.
  """
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.Github.Tools

  @caller Ecto.UUID.generate()

  defp insert_org do
    slug = "w5b-gh-#{System.unique_integer([:positive])}"

    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        [slug, "W5B Github Org"]
      )

    {Ecto.UUID.load!(raw), slug}
  end

  # Per-tool required arguments (beyond caller_user_id + organization + repo).
  @extra_args %{
    Tools.BranchCreate => %{branch_name: "feature/x", from_sha: "deadbeef"},
    Tools.BranchGet => %{branch_name: "main"},
    Tools.BranchList => %{},
    Tools.IssueComment => %{issue_number: 1, body: "looks good"},
    Tools.IssueCreate => %{title: "Broken thing"},
    Tools.IssueGet => %{issue_number: 7},
    Tools.IssueList => %{},
    Tools.PullComment => %{pull_number: 2, body: "nit:"},
    Tools.PullCreate => %{title: "Add thing", head: "feat", base: "main"},
    Tools.PullGet => %{pull_number: 3},
    Tools.PullList => %{},
    Tools.PullMerge => %{pull_number: 4}
  }

  describe "every repo-scoped tool" do
    test "returns :repo_not_found for an unknown repo without touching the network" do
      {org_id, org_slug} = insert_org()

      for {tool, extra} <- @extra_args do
        args =
          Map.merge(
            %{
              caller_user_id: @caller,
              organization: org_slug,
              repo: "noizu-labs/nope-#{System.unique_integer([:positive])}"
            },
            extra
          )

        assert {:error, :repo_not_found} = tool.call(args, nil),
               "#{inspect(tool)} should short-circuit on an unknown repo"
      end

      assert is_binary(org_id)
    end

    test "returns :organization_not_found when the org cannot be resolved" do
      for {tool, extra} <- @extra_args do
        args =
          Map.merge(
            %{
              caller_user_id: @caller,
              organization: "no-such-org-#{System.unique_integer([:positive])}",
              repo: "owner/name"
            },
            extra
          )

        assert {:error, :organization_not_found} = tool.call(args, nil)
      end
    end

    test "returns :invalid_uuid for an uncastable caller" do
      {org_id, org_slug} = insert_org()

      for {tool, extra} <- @extra_args do
        args =
          Map.merge(%{caller_user_id: "junk", organization: org_slug, repo: "owner/name"}, extra)

        assert {:error, :invalid_uuid} = tool.call(args, nil)
      end

      assert is_binary(org_id)
    end
  end

  describe "IssueCreate / PullCreate / PullMerge request bodies" do
    test "nil optionals are filtered out of the body before the client call" do
      {org_id, org_slug} = insert_org()

      args = %{
        caller_user_id: @caller,
        organization: org_slug,
        repo: "owner/name",
        title: "T",
        body: nil,
        labels: ["bug"],
        assignees: nil,
        head: "h",
        base: "b",
        pull_number: 1,
        commit_title: "ct",
        merge_method: "squash"
      }

      # All three reach the client path (repo_not_found) — the pre-fix
      # BadMapError is gone, and nil body/assignees did not blow up the take.
      assert {:error, :repo_not_found} = Tools.IssueCreate.call(args, nil)
      assert {:error, :repo_not_found} = Tools.PullCreate.call(args, nil)

      merge_args =
        Map.take(args, [
          :caller_user_id,
          :organization,
          :repo,
          :pull_number,
          :commit_title,
          :merge_method
        ])

      assert {:error, :repo_not_found} = Tools.PullMerge.call(merge_args, nil)

      assert is_binary(org_id)
    end
  end

  describe "RepoList (local-DB listing, different arg order)" do
    test "requires caller + org, validates the uuid, then hits the client" do
      {_org_id, org_slug} = insert_org()

      assert {:error, :caller_user_id_required} =
               Tools.RepoList.call(%{caller_user_id: nil, organization: org_slug}, nil)

      assert {:error, :organization_not_found} =
               Tools.RepoList.call(%{caller_user_id: @caller, organization: nil}, nil)

      assert {:error, :invalid_uuid} =
               Tools.RepoList.call(%{caller_user_id: "junk", organization: org_slug}, nil)

      # An org with zero repos lists empty (the client's happy path) without network.
      assert {:ok, %{count: 0, repos: []}} =
               Tools.RepoList.call(%{caller_user_id: @caller, organization: org_slug}, nil)
    end
  end

  describe "Overview" do
    test "describes the ACL model and the tool inventory" do
      assert {:ok, %{acl_model: acl, tools: tools, required_inputs: inputs}} =
               Tools.Overview.call(%{}, nil)

      assert acl =~ "default_acl"
      assert %{category: "Repos", tools: ["RepoList"]} in tools
      assert Enum.any?(inputs, &(&1.name == "caller_user_id" and &1.required))
    end
  end
end
