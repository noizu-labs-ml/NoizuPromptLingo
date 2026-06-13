defmodule Codefresh.AgentsTest do
  use Codefresh.DataCase, async: true

  import Codefresh.Fixtures
  alias Codefresh.Agents

  defp with_org do
    %{user: user, organization: org} = org_with_owner()
    %{user: user, org: org}
  end

  defp create!(org, user, attrs \\ %{}) do
    defaults = %{
      "name" => "Agent #{System.unique_integer([:positive])}",
      "organization_id" => org.id,
      "created_by_user_id" => user.id
    }

    {:ok, a} = Agents.create_agent(Map.merge(defaults, stringify(attrs)))
    a
  end

  defp stringify(m), do: for({k, v} <- m, into: %{}, do: {to_string(k), v})

  defp openai_attrs(overrides \\ %{}) do
    base = %{
      adapter: "openai",
      model: "gpt-4o",
      auth_ref: %{"type" => "secret_ref", "ref" => "infisical://proj/OPENAI_API_KEY"},
      request_template: %{"timeout_ms" => 30_000}
    }

    Map.merge(base, overrides)
  end

  describe "create_agent/1 (US-012)" do
    test "auto-derives slug from name and leaves head unpublished" do
      %{org: org, user: u} = with_org()

      assert {:ok, a} =
               Agents.create_agent(%{
                 "name" => "OpenAI Primary!",
                 "organization_id" => org.id,
                 "created_by_user_id" => u.id
               })

      assert a.slug == "openai-primary"
      assert a.current_version_id == nil
    end

    test "slug unique per org" do
      %{org: org, user: u} = with_org()
      _ = create!(org, u, %{slug: "dup", name: "First"})

      assert {:error, cs} =
               Agents.create_agent(%{
                 "name" => "Second",
                 "slug" => "dup",
                 "organization_id" => org.id
               })

      assert "has already been taken" in errors_on(cs).slug
    end

    test "accepts cost cap + rate limit (US-064)" do
      %{org: org, user: u} = with_org()

      assert {:ok, a} =
               Agents.create_agent(%{
                 "name" => "Capped",
                 "organization_id" => org.id,
                 "created_by_user_id" => u.id,
                 "daily_cost_cap_usd" => Decimal.new("25.00"),
                 "rate_limit_per_min" => 60
               })

      assert Decimal.equal?(a.daily_cost_cap_usd, Decimal.new("25.00"))
      assert a.rate_limit_per_min == 60
    end

    test "rejects non-positive cost cap (US-064)" do
      %{org: org, user: u} = with_org()

      assert {:error, cs} =
               Agents.create_agent(%{
                 "name" => "Bad Cap",
                 "organization_id" => org.id,
                 "created_by_user_id" => u.id,
                 "daily_cost_cap_usd" => Decimal.new("0")
               })

      assert "must be greater than 0" in errors_on(cs).daily_cost_cap_usd
    end

    test "rejects non-positive rate limit" do
      %{org: org, user: u} = with_org()

      assert {:error, cs} =
               Agents.create_agent(%{
                 "name" => "Bad Rate",
                 "organization_id" => org.id,
                 "created_by_user_id" => u.id,
                 "rate_limit_per_min" => 0
               })

      assert Map.has_key?(errors_on(cs), :rate_limit_per_min)
    end
  end

  describe "publish_version/2 (US-014)" do
    test "inserts v1 for valid openai config and advances current_version_id" do
      %{org: org, user: u} = with_org()
      agent = create!(org, u)

      assert {:ok, :published, v} =
               Agents.publish_version(agent, Map.put(openai_attrs(), :published_by_user_id, u.id))

      assert v.version_number == 1
      assert v.adapter == "openai"
      assert v.model == "gpt-4o"

      reloaded = Agents.get_agent!(org.id, agent.id)
      assert reloaded.current_version_id == v.id
    end

    test "identical config → noop returning existing version" do
      %{org: org, user: u} = with_org()
      agent = create!(org, u)

      {:ok, :published, v1} = Agents.publish_version(agent, openai_attrs())
      assert {:ok, :noop, v_same} = Agents.publish_version(agent, openai_attrs())
      assert v_same.id == v1.id
    end

    test "differing config bumps to v2" do
      %{org: org, user: u} = with_org()
      agent = create!(org, u)

      {:ok, :published, v1} = Agents.publish_version(agent, openai_attrs())

      {:ok, :published, v2} =
        Agents.publish_version(agent, openai_attrs(%{model: "gpt-4-turbo"}))

      assert v1.version_number == 1
      assert v2.version_number == 2
    end

    test "rejects unknown adapter" do
      %{org: org, user: u} = with_org()
      agent = create!(org, u)

      assert {:error, :unknown_adapter, "quantum"} =
               Agents.publish_version(agent, %{adapter: "quantum", model: "x"})
    end

    test "OpenAI adapter rejects missing model" do
      %{org: org, user: u} = with_org()
      agent = create!(org, u)

      assert {:error, reason} = Agents.publish_version(agent, openai_attrs(%{model: nil}))
      assert reason =~ "model"
    end

    test "OpenAI adapter rejects missing secret_ref auth" do
      %{org: org, user: u} = with_org()
      agent = create!(org, u)

      assert {:error, reason} =
               Agents.publish_version(agent, openai_attrs(%{auth_ref: %{}}))

      assert reason =~ "auth_ref"
    end

    test "Anthropic adapter validates like OpenAI (US-061)" do
      %{org: org, user: u} = with_org()
      agent = create!(org, u)

      attrs = %{
        adapter: "anthropic",
        model: "claude-sonnet-4-5",
        auth_ref: %{"type" => "secret_ref", "ref" => "infisical://proj/ANTHROPIC_API_KEY"}
      }

      assert {:ok, :published, v} = Agents.publish_version(agent, attrs)
      assert v.adapter == "anthropic"
    end

    test "LangChain adapter requires dotted entrypoint (US-062)" do
      %{org: org, user: u} = with_org()
      agent = create!(org, u)

      assert {:error, reason} =
               Agents.publish_version(agent, %{
                 adapter: "langchain",
                 request_template: %{}
               })

      assert reason =~ "entrypoint"

      assert {:ok, :published, v} =
               Agents.publish_version(agent, %{
                 adapter: "langchain",
                 request_template: %{"entrypoint" => "my_module.factory"}
               })

      assert v.adapter == "langchain"
    end

    test "HTTP adapter validates URL + jsonpath (US-063)" do
      %{org: org, user: u} = with_org()
      agent = create!(org, u)

      bad = %{
        adapter: "http",
        endpoint_url: "not-a-url",
        auth_ref: %{"type" => "none"},
        response_jsonpath: "$.text"
      }

      assert {:error, reason} = Agents.publish_version(agent, bad)
      assert reason =~ "endpoint_url"

      good = %{
        adapter: "http",
        endpoint_url: "https://example.com/hook",
        auth_ref: %{"type" => "secret_ref", "ref" => "infisical://proj/WEBHOOK_TOKEN"},
        response_jsonpath: "$.choices[0].text",
        headers: %{"X-Source" => "codefresh"}
      }

      assert {:ok, :published, v} = Agents.publish_version(agent, good)
      assert v.adapter == "http"
      assert v.response_jsonpath == "$.choices[0].text"
    end

    test "streaming toggle persists on request_template (US-065)" do
      %{org: org, user: u} = with_org()
      agent = create!(org, u)

      attrs = openai_attrs(%{request_template: %{"streaming" => true, "timeout_ms" => 10_000}})

      assert {:ok, :published, v} = Agents.publish_version(agent, attrs)
      assert v.request_template["streaming"] == true

      bad = openai_attrs(%{request_template: %{"streaming" => "yes-please"}})
      assert {:error, reason} = Agents.publish_version(agent, bad)
      assert reason =~ "streaming"
    end

    test "model_tier pins on version (US-064)" do
      %{org: org, user: u} = with_org()
      agent = create!(org, u)

      attrs = Map.put(openai_attrs(), :model_tier, "premium")
      assert {:ok, :published, v} = Agents.publish_version(agent, attrs)
      assert v.model_tier == "premium"
    end
  end

  describe "resolve_current_version/2 + pinnable?/2" do
    test "cross-org agent lookup returns :not_found" do
      %{org: org1, user: u1} = with_org()
      %{org: org2} = with_org()
      agent = create!(org1, u1)
      assert {:error, :not_found} = Agents.resolve_current_version(org2.id, agent.id)
    end

    test "pinnable?/2 enforces org ownership" do
      %{org: org1, user: u1} = with_org()
      %{org: org2} = with_org()
      agent = create!(org1, u1)
      {:ok, :published, v} = Agents.publish_version(agent, openai_attrs())
      assert Agents.pinnable?(org1.id, v.id)
      refute Agents.pinnable?(org2.id, v.id)
    end

    test ":not_published when head has no version" do
      %{org: org, user: u} = with_org()
      agent = create!(org, u)
      assert {:error, :not_published} = Agents.resolve_current_version(org.id, agent.id)
    end
  end

  describe "health_check/1 (US-013)" do
    test "real adapter returns :config_valid when published" do
      %{org: org, user: u} = with_org()
      agent = create!(org, u)
      {:ok, :published, _v} = Agents.publish_version(agent, openai_attrs())

      reloaded = Agents.get_agent!(org.id, agent.id)
      assert {:ok, :config_valid} = Agents.health_check(reloaded)
    end

    test "stub adapter returns :not_implemented" do
      %{org: org, user: u} = with_org()
      agent = create!(org, u)

      {:ok, :published, _v} =
        Agents.publish_version(agent, %{
          adapter: "langchain",
          request_template: %{"entrypoint" => "m.f"}
        })

      reloaded = Agents.get_agent!(org.id, agent.id)
      assert {:ok, :not_implemented} = Agents.health_check(reloaded)
    end

    test "unpublished head returns :not_published" do
      %{org: org, user: u} = with_org()
      agent = create!(org, u)
      assert {:error, :not_published} = Agents.health_check(agent)
    end

    test "raw config map dispatches to the right adapter" do
      assert {:ok, :config_valid} = Agents.health_check(openai_attrs())

      assert {:error, reason} = Agents.health_check(%{adapter: "openai", model: "x"})
      assert reason =~ "auth_ref"

      assert {:error, :unknown_adapter, "gemini"} =
               Agents.health_check(%{adapter: "gemini"})
    end
  end

  describe "list_agents/2" do
    test "hides archived by default" do
      %{org: org, user: u} = with_org()
      keep = create!(org, u, %{name: "Keep"})
      hide = create!(org, u, %{name: "Hide"})
      {:ok, _} = Agents.archive_agent(hide)

      names = Agents.list_agents(org.id) |> Enum.map(& &1.name)
      assert names == [keep.name]
    end

    test "only_published filter" do
      %{org: org, user: u} = with_org()
      published = create!(org, u, %{name: "Published", slug: "published"})
      _draft = create!(org, u, %{name: "Draft", slug: "draft"})
      {:ok, :published, _} = Agents.publish_version(published, openai_attrs())

      names = Agents.list_agents(org.id, only_published: true) |> Enum.map(& &1.name)
      assert names == ["Published"]
    end
  end

  defp errors_on(%Ecto.Changeset{} = cs) do
    Ecto.Changeset.traverse_errors(cs, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
