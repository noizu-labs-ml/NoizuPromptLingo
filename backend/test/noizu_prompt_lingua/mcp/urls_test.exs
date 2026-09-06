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

  describe "app item urls (deep links)" do
    test "session/ticket/artifact urls follow /app/:org/:segment/:id" do
      assert Urls.session_url(%{id: "s-1", organization_id: "org-uuid"},
               host: @host,
               org_slug: "the-robot-lives"
             ) == "https://tobor.locker/app/the-robot-lives/sessions/s-1"

      assert Urls.ticket_url(%{id: "t-1", organization_id: "org-uuid"},
               host: @host,
               org_slug: "the-robot-lives"
             ) == "https://tobor.locker/app/the-robot-lives/tickets/t-1"

      assert Urls.artifact_url(%{id: "a-1", organization_id: "org-uuid"},
               host: @host,
               org_slug: "the-robot-lives"
             ) == "https://tobor.locker/app/the-robot-lives/artifacts/a-1"
    end

    test "chat_room_url still resolves via the shared helper" do
      assert Urls.chat_room_url(%{id: "r-1", organization_id: "org-uuid"},
               host: @host,
               org_slug: "the-robot-lives"
             ) == "https://tobor.locker/app/the-robot-lives/chat/r-1"
    end

    test "item urls return nil when the org slug cannot be resolved" do
      assert Urls.session_url(%{id: "s-1"}, host: @host) == nil
      assert Urls.ticket_url(%{id: "t-1", organization_id: nil}, host: @host) == nil
    end

    test "session_url resolves the org slug from the DB" do
      uniq = System.unique_integer([:positive])

      org =
        %NoizuPromptLingua.Schema.Organizations.Organization{
          slug: "test-org-#{uniq}",
          name: "Test Org #{uniq}"
        }
        |> NoizuPromptLingua.Repo.insert!()

      assert Urls.session_url(%{id: "s-1", organization_id: org.id}, host: @host) ==
               "https://tobor.locker/app/test-org-#{uniq}/sessions/s-1"
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

  describe "tool-set urls (PRD-N3 FR-3-10)" do
    test "set_url is the org-addressed machine route" do
      assert Urls.set_url("md-set", "the-org", host: @host) ==
               "https://tobor.locker/org/the-org/set/md-set/mcp"

      # org record form works too
      assert Urls.set_url(%{slug: "md-set"}, %{slug: "the-org"}, host: @host) ==
               "https://tobor.locker/org/the-org/set/md-set/mcp"
    end

    test "set_project_url is the project-addressed machine route" do
      assert Urls.set_project_url("md-set", "the-org", "proj-a", host: @host) ==
               "https://tobor.locker/org/the-org/project/proj-a/set/md-set/mcp"
    end

    test "tool_set_admin_url is the human settings route" do
      assert Urls.tool_set_admin_url("the-org", "md-set", host: @host) ==
               "https://tobor.locker/app/the-org/settings/tool-sets/md-set"
    end
  end
end
