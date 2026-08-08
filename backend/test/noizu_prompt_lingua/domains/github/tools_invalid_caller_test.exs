defmodule NoizuPromptLingua.Domains.Github.ToolsInvalidCallerTest do
  @moduledoc """
  Every GitHub MCP tool takes a `caller_user_id` and validates it as a UUID.
  Most of them then branched on the result with

      case {parse_uuid(caller_user_id), ensure_org(org_id)} do
        ...
        {{:error, _}, _} -> {:error, :invalid_uuid}
      end

  but `parse_uuid/1` returns a bare `:error`, never `{:error, _}`. That last
  clause could not match, so an invalid caller id matched *no* clause and
  raised `CaseClauseError` — a 500 on a tool call whose only fault was a
  malformed argument. `caller_user_id` is a client-supplied tool argument, so
  this was reachable by anyone, including by omitting it entirely (nil).

  The compiler had been warning about it 8 times a build ("the 1st argument is
  empty ... most likely because it is the result of an expression that always
  fails"), which is exactly the warning that gets tuned out.

  Two tools never had the bug: `BranchCreate` and `RepoList` use `with/else`
  and match the bare `:error` correctly. They are covered here anyway, so the
  file documents the whole surface rather than only the broken part of it.
  """
  use NoizuPromptLingua.DataCase, async: true

  alias NoizuPromptLingua.Domains.Github.Tools

  # The tools that carried the unreachable clause, plus BranchCreate, which
  # already handled it. All reach the invalid-uuid branch before any GitHub
  # client call, so no network is involved.
  #
  # IssueCreate, PullCreate and PullMerge are deliberately absent: they cannot
  # reach argument validation at all. See the `Map.take/2` describe block.
  @tools_returning_invalid_uuid [
    Tools.BranchCreate,
    Tools.BranchGet,
    Tools.BranchList,
    Tools.IssueComment,
    Tools.IssueGet,
    Tools.IssueList,
    Tools.PullComment,
    Tools.PullGet,
    Tools.PullList
  ]

  # Separate, older defect, found by this file and NOT fixed here — fixing it
  # is outside the scope this test was written for.
  @tools_broken_before_validation [
    Tools.IssueCreate,
    Tools.PullCreate,
    Tools.PullMerge
  ]

  # A caller id that is not a 36-character UUID, in the shapes a client can
  # actually send. "sixteen-char-abc" is here because Ecto.UUID.cast/1 would
  # have accepted it as a raw 16-byte binary — this suite's other subject.
  @bad_caller_ids ["not-a-uuid", "", "sixteen-char-abc", nil]

  describe "an invalid caller_user_id returns {:error, :invalid_uuid} rather than raising" do
    for tool <- @tools_returning_invalid_uuid do
      @tool tool

      test "#{inspect(tool)}" do
        for bad <- @bad_caller_ids do
          args = %{
            caller_user_id: bad,
            organization: "no-such-org-#{System.unique_integer([:positive])}",
            repo: "owner/name",
            branch_name: "main",
            from_sha: "deadbeef",
            issue_number: 1,
            pull_number: 1,
            title: "t",
            body: "b"
          }

          assert @tool.call(args, nil) == {:error, :invalid_uuid},
                 "#{inspect(@tool)} did not reject caller_user_id #{inspect(bad)}"
        end
      end
    end
  end

  describe "Map.take/2 on a keyword list — a separate, older defect" do
    # These three build their request body with
    #
    #     Map.take([title: ..., body: ...], [:title, :body])
    #
    # but the first argument is a keyword *list*, and Map.take/2 requires a
    # map. It raises BadMapError unconditionally, on every call, with any
    # arguments — the line runs before the `case` that validates anything. So
    # these three tools cannot succeed and never could; nothing had ever called
    # them, which is why it went unnoticed until this file did.
    #
    # Pinned rather than fixed: this is not the unreachable-clause bug, and
    # fixing it was not in scope. The assertion is deliberately a statement of
    # what is broken. When someone fixes it — `Enum.filter` the keyword list
    # directly, or wrap it in `Map.new/1` first — this test will fail, which is
    # the intended signal to move the module into
    # @tools_returning_invalid_uuid above.
    for tool <- @tools_broken_before_validation do
      @tool tool

      test "#{inspect(tool)} raises BadMapError before it can validate anything" do
        args = %{
          caller_user_id: Ecto.UUID.generate(),
          organization: "no-such-org-#{System.unique_integer([:positive])}",
          repo: "owner/name",
          title: "t",
          body: "b",
          pull_number: 1
        }

        assert_raise BadMapError, fn -> @tool.call(args, nil) end
      end
    end
  end

  describe "the org branch still works — the fix did not swallow it" do
    test "a valid caller uuid with an unresolvable org reports the org, not the uuid" do
      args = %{
        caller_user_id: Ecto.UUID.generate(),
        organization: "no-such-org-#{System.unique_integer([:positive])}",
        repo: "owner/name",
        branch_name: "main"
      }

      # BranchGet's ensure_org/1 names it :org_not_found and the clause maps it
      # to :organization_not_found; either way it must not be :invalid_uuid.
      assert Tools.BranchGet.call(args, nil) == {:error, :organization_not_found}
    end
  end

  describe "RepoList checks its arguments in a different order" do
    test "an unresolvable org is reported before the caller uuid is judged" do
      # Not a bug, just a different contract: RepoList screens {caller, org}
      # for nils first. Pinned so the difference is deliberate and visible.
      args = %{
        caller_user_id: "not-a-uuid",
        organization: "no-such-org-#{System.unique_integer([:positive])}"
      }

      assert Tools.RepoList.call(args, nil) == {:error, :organization_not_found}
    end

    test "a resolvable-looking caller with a nil organization is still not a raise" do
      assert Tools.RepoList.call(%{caller_user_id: nil, organization: nil}, nil) ==
               {:error, :caller_user_id_required}
    end
  end
end
