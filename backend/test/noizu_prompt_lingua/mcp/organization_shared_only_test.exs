defmodule NoizuPromptLingua.MCP.OrganizationSharedOnlyTest do
  @moduledoc """
  Shared-only regression for Organization List / Overview after the pm_core cutover.

  **Contract:** organizations always list/count via `Noizu.PM.Repo`.
  Source-only checks — no DB required.
  """
  use ExUnit.Case, async: true

  @list_src Path.expand(
              "../../../lib/noizu_prompt_lingua/mcp/organizations/tools/organization_list.ex",
              __DIR__
            )
  @overview_src Path.expand(
                  "../../../lib/noizu_prompt_lingua/mcp/organizations/tools/overview.ex",
                  __DIR__
                )
  @create_src Path.expand(
                "../../../lib/noizu_prompt_lingua/mcp/organizations/tools/organization_create.ex",
                __DIR__
              )

  describe "source shared-only contracts" do
    test "Organization.List uses PMCore.with_pm and Noizu.PM.Repo only" do
      src = File.read!(@list_src)
      assert src =~ "NoizuPromptLingua.PMCore.with_pm"
      assert src =~ "Noizu.PM.Repo"
      assert src =~ "Noizu.PM.Schema.Organizations.Organization"
      refute src =~ "NoizuPromptLingua.Repo.all"
      refute src =~ "NoizuPromptLingua.Schema.Organizations.Organization"
    end

    test "Organization.Overview aggregates via PMCore.with_pm and Noizu.PM.Repo only" do
      src = File.read!(@overview_src)
      assert src =~ "NoizuPromptLingua.PMCore.with_pm"
      assert src =~ "Noizu.PM.Repo.aggregate"
      assert src =~ "Noizu.PM.Schema.Organizations.Organization"
      refute src =~ "NoizuPromptLingua.Repo.aggregate"
      refute src =~ "NoizuPromptLingua.Schema.Organizations.Organization"
    end

    test "Organization.Create goes through create_organization_with_owner (pm_core path)" do
      src = File.read!(@create_src)
      assert src =~ "create_organization_with_owner"
    end
  end
end
