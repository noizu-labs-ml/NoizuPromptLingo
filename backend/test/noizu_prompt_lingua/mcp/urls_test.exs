defmodule NoizuPromptLingua.MCP.UrlsTest do
  use NoizuPromptLingua.DataCase

  alias NoizuPromptLingua.MCP.Urls

  @host "tobor.locker"

  describe "url shapes (contract §2 / W1)" do
    test "scope_url prefers the org path when an org slug is supplied" do
      scope = %{slug: "my-mcp-slug", organization_id: "org-uuid"}

      assert Urls.scope_url(scope, host: @host, org_slug: "the-robot-lives") ==
               "https://tobor.locker/org/the-robot-lives/custom/my-mcp-slug/mcp"
    end

    test "scope_url falls back to the legacy shape without an org" do
      assert Urls.scope_url(%{slug: "abc123"}, host: @host) ==
               "https://tobor.locker/custom/abc123/mcp"

      assert Urls.scope_url(%{slug: "abc123", organization_id: nil}, host: @host) ==
               "https://tobor.locker/custom/abc123/mcp"
    end

    test "user_url is the account-level sharing path" do
      assert Urls.user_url(%{slug: "my-shared-stack"}, host: @host) ==
               "https://tobor.locker/user/my-shared-stack/mcp"
    end

    test "legacy_url is the permanent /custom/:hex alias" do
      assert Urls.legacy_url(%{slug: "ce076e2f9655"}, host: @host) ==
               "https://tobor.locker/custom/ce076e2f9655/mcp"

      # bare slug strings are accepted too
      assert Urls.legacy_url("ce076e2f9655", host: @host) ==
               "https://tobor.locker/custom/ce076e2f9655/mcp"
    end
  end

  describe "org slug resolution (DB)" do
    test "scope_url resolves the organization slug from organization_id" do
      uniq = System.unique_integer([:positive])

      org =
        %NoizuPromptLingua.Schema.Organizations.Organization{
          slug: "test-org-#{uniq}",
          name: "Test Org #{uniq}"
        }
        |> NoizuPromptLingua.Repo.insert!()

      scope = %{slug: "my-slug", organization_id: org.id}

      assert Urls.scope_url(scope, host: @host) ==
               "https://tobor.locker/org/test-org-#{uniq}/custom/my-slug/mcp"
    end
  end
end
