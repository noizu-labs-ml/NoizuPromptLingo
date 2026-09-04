defmodule NoizuPromptLingua.Domains.MockMCPTest do
  use NoizuPromptLingua.DataCase, async: true

  alias NoizuPromptLingua.Domains.MockMCP

  setup do
    {:ok, org_id: insert_org("mock-test-org")}
  end

  defp insert_org(prefix) do
    %{rows: [[raw_id]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["#{prefix}-#{System.unique_integer([:positive])}", "Test Org"]
      )

    Ecto.UUID.load!(raw_id)
  end

  defp valid_attrs(org_id, overrides \\ %{}) do
    Map.merge(
      %{
        organization_id: org_id,
        slug: "weather-#{System.unique_integer([:positive])}",
        title: "Weather Service",
        prompt: "An MCP server that reports weather for a city."
      },
      overrides
    )
  end

  describe "create/1 + get/1" do
    test "creates a draft definition and fetches it by slug and id", %{org_id: org_id} do
      attrs = valid_attrs(org_id)
      assert {:ok, def_} = MockMCP.create(attrs)
      assert def_.status == "draft"
      assert def_.tools_json == []
      assert def_.organization_id == org_id

      assert MockMCP.get(def_.slug).id == def_.id
      assert MockMCP.get(def_.id).slug == def_.slug
    end

    test "rejects an invalid slug", %{org_id: org_id} do
      assert {:error, cs} = MockMCP.create(valid_attrs(org_id, %{slug: "Bad Slug!"}))
      refute cs.valid?
    end

    test "requires organization_id" do
      assert {:error, cs} = MockMCP.create(valid_attrs(nil) |> Map.delete(:organization_id))
      refute cs.valid?
    end
  end

  describe "lifecycle + tools" do
    test "set_tools, activate, get_active, get_tools, archive", %{org_id: org_id} do
      {:ok, def_} = MockMCP.create(valid_attrs(org_id))

      tools = [
        %{
          "name" => "get_weather",
          "description" => "Get weather",
          "inputSchema" => %{"type" => "object"}
        }
      ]

      assert {:ok, updated} = MockMCP.set_tools(def_.id, tools)
      assert [%{"name" => "get_weather"}] = updated.tools_json

      # Not active yet → get_active returns nil, get_tools empty.
      assert MockMCP.get_active(def_.slug) == nil
      assert MockMCP.get_tools(def_.slug) == []

      assert {:ok, active} = MockMCP.activate(def_.slug)
      assert active.status == "active"
      assert MockMCP.get_active(def_.slug).id == def_.id
      assert [%{"name" => "get_weather"}] = MockMCP.get_tools(def_.slug)

      assert {:ok, archived} = MockMCP.archive(def_.slug)
      assert archived.status == "archived"
      assert MockMCP.get_active(def_.slug) == nil
    end
  end

  describe "list/1" do
    test "scopes to organization and filters by status", %{org_id: org_id} do
      {:ok, a} = MockMCP.create(valid_attrs(org_id))
      {:ok, _b} = MockMCP.create(valid_attrs(org_id))
      {:ok, _} = MockMCP.activate(a.slug)

      assert length(MockMCP.list(organization_id: org_id)) == 2
      assert [one] = MockMCP.list(organization_id: org_id, status: "active")
      assert one.id == a.id

      # Different org sees nothing.
      other_org = insert_org("other-org")
      assert MockMCP.list(organization_id: other_org) == []
    end
  end

  describe "LLM connection pool + active resolution" do
    test "create/list/update/delete llms scoped to org", %{org_id: org_id} do
      assert {:ok, llm} =
               MockMCP.create_llm(%{
                 organization_id: org_id,
                 label: "OpenAI prod",
                 provider: "openai",
                 model: "gpt-4o",
                 api_key: "sk-secret"
               })

      assert [^llm] = [hd(MockMCP.list_llms(org_id))]
      assert {:ok, updated} = MockMCP.update_llm(llm.id, %{model: "gpt-4o-mini"})
      assert updated.model == "gpt-4o-mini"
      assert {:ok, _} = MockMCP.delete_llm(llm.id)
      assert MockMCP.list_llms(org_id) == []
    end

    test "label is unique per org", %{org_id: org_id} do
      base = %{organization_id: org_id, label: "dup", provider: "openai", model: "gpt-4o"}
      assert {:ok, _} = MockMCP.create_llm(base)
      assert {:error, cs} = MockMCP.create_llm(base)
      refute cs.valid?
    end

    test "active_llm_opts resolves the active connection, [] when unset", %{org_id: org_id} do
      {:ok, def_} = MockMCP.create(valid_attrs(org_id))
      assert MockMCP.active_llm_opts(def_) == []

      {:ok, llm} =
        MockMCP.create_llm(%{
          organization_id: org_id,
          label: "Local LM Studio",
          provider: "openai",
          model: "llama-3.1-70b",
          endpoint: "http://localhost:1234/v1/chat/completions",
          api_key: "lm-key"
        })

      {:ok, def_} = MockMCP.update(def_.slug, %{active_llm_id: llm.id})
      opts = MockMCP.active_llm_opts(def_)
      assert opts[:provider] == "openai"
      assert opts[:model] == "llama-3.1-70b"
      assert opts[:endpoint] == "http://localhost:1234/v1/chat/completions"
      assert opts[:api_key] == "lm-key"
    end
  end

  describe "set_surface/2" do
    test "stores tools, resources, and prompts", %{org_id: org_id} do
      {:ok, def_} = MockMCP.create(valid_attrs(org_id))

      surface = %{
        "tools" => [%{"name" => "t1", "description" => "d", "handler" => "h"}],
        "resources" => [%{"uri" => "mock://r", "name" => "r", "handler" => "h"}],
        "prompts" => [%{"name" => "p", "description" => "d", "handler" => "h"}]
      }

      assert {:ok, updated} = MockMCP.set_surface(def_.id, surface)
      assert [%{"name" => "t1"}] = updated.tools_json
      assert [%{"uri" => "mock://r"}] = updated.resources_json
      assert [%{"name" => "p"}] = updated.prompts_json
    end
  end

  describe "call logging" do
    test "log_call and list_calls", %{org_id: org_id} do
      {:ok, def_} = MockMCP.create(valid_attrs(org_id))

      assert {:ok, _} =
               MockMCP.log_call(def_.id, %{
                 method: "tools/call",
                 tool_name: "get_weather",
                 arguments: %{"city" => "Paris"},
                 response: %{content: [%{"type" => "text", "text" => "Sunny"}]},
                 latency_ms: 42
               })

      assert [log] = MockMCP.list_calls(def_.id)
      assert log.tool_name == "get_weather"
      assert log.latency_ms == 42
    end
  end

  # ── surface schema persistence + module lifecycle + provisioning ─────────

  describe "set_surface/2 with a backing schema" do
    test "persists schema_json for the provisioner", %{org_id: org_id} do
      {:ok, def_} = MockMCP.create(valid_attrs(org_id))

      surface = %{
        "tools" => [%{"name" => "t1"}],
        "schema" => %{"postgres" => ["CREATE TABLE t (id int)"], "weaviate" => []}
      }

      assert {:ok, updated} = MockMCP.set_surface(def_.id, surface)
      assert updated.schema_json == %{"postgres" => ["CREATE TABLE t (id int)"], "weaviate" => []}
    end

    test "surface without a schema leaves schema_json untouched", %{org_id: org_id} do
      {:ok, def_} = MockMCP.create(valid_attrs(org_id))

      assert {:ok, updated} = MockMCP.set_surface(def_.id, %{"tools" => []})
      assert updated.schema_json == nil
    end
  end

  describe "module entries" do
    test "put_module/get_module/delete_module round trip", %{org_id: org_id} do
      {:ok, def_} = MockMCP.create(valid_attrs(org_id))

      entry = %{"tool" => "ping", "status" => "draft", "source" => ":ok"}

      assert {:error, :not_found} = MockMCP.put_module(Ecto.UUID.generate(), entry)

      assert {:ok, _} = MockMCP.put_module(def_.id, entry)
      assert %{"tool" => "ping"} = MockMCP.get_module(MockMCP.get(def_.id), "ping")
      assert MockMCP.get_module(MockMCP.get(def_.id), "ghost") == nil

      # put replaces by tool name, preserving other entries
      assert {:ok, _} = MockMCP.put_module(def_.id, %{"tool" => "pong", "status" => "draft"})
      assert {:ok, _} = MockMCP.put_module(def_.id, %{"tool" => "ping", "status" => "approved"})

      updated = MockMCP.get(def_.id)
      assert length(updated.modules_json) == 2
      assert %{"status" => "approved"} = MockMCP.get_module(updated, "ping")

      assert {:ok, _} = MockMCP.delete_module(def_.id, "ping")
      assert MockMCP.get_module(MockMCP.get(def_.id), "ping") == nil
      assert {:error, :not_found} = MockMCP.delete_module("no-such-slug", "ping")
    end
  end

  describe "schema_name/1" do
    test "cleans a slug into a safe schema identifier" do
      # NOTE: punctuation becomes a separator, so a trailing bang yields a
      # trailing underscore — pinned current behavior.
      assert MockMCP.schema_name("Team A!") == "mockmcp_team_a_"
      assert MockMCP.schema_name("weather") == "mockmcp_weather"
    end
  end

  describe "provision_db/1" do
    setup %{org_id: org_id} do
      {:ok, def_} = MockMCP.create(valid_attrs(org_id))
      {:ok, def_: def_}
    end

    test "unknown slug -> {:error, :not_found}" do
      assert {:error, :not_found} = MockMCP.provision_db("no-such-slug")
    end

    test "provisions a schema and is idempotent", %{def_: def_} do
      assert {:ok, provisioned} = MockMCP.provision_db(def_.id)
      assert provisioned.db_provisioned
      assert provisioned.db_name == MockMCP.schema_name(def_.slug)

      # second call short-circuits on db_provisioned
      assert {:ok, again} = MockMCP.provision_db(provisioned.slug)
      assert again.id == provisioned.id
    end

    test "broken design DDL -> {:error, ...} and no provisioning flag", %{org_id: org_id} do
      {:ok, def_} =
        MockMCP.create(
          valid_attrs(org_id, %{schema_json: %{"postgres" => ["CREATE TABLE oops("]}})
        )

      assert {:error, reason} = MockMCP.provision_db(def_.id)
      assert reason =~ "schema DDL failed"

      refute MockMCP.get(def_.id).db_provisioned
    end

    test "provisions cleanly with no designed schema at all", %{def_: def_} do
      assert {:ok, provisioned} = MockMCP.provision_db(def_.id)
      assert provisioned.db_provisioned
    end
  end
end
