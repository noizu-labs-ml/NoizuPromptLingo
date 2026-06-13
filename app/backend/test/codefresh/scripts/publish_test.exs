defmodule Codefresh.Scripts.PublishTest do
  use Codefresh.DataCase, async: true

  alias Codefresh.{Scripts, Prompts}

  import Codefresh.Fixtures

  defp setup_full_script do
    %{organization: org, user: user} = org_with_owner()

    {:ok, prompt} =
      Prompts.create_prompt(%{
        "organization_id" => org.id,
        "created_by_user_id" => user.id,
        "name" => "Greeter"
      })

    {:ok, :published, pv} =
      Prompts.publish_version(prompt, %{body: "hello", published_by_user_id: user.id})

    {:ok, script, draft} =
      Scripts.create_script(%{"organization_id" => org.id, "name" => "Flow"})

    {:ok, n1} =
      Scripts.add_node(draft, %{"node_key" => "start", "kind" => "user_turn"})

    {:ok, _} = Scripts.attach_prompt(n1, pv.id)

    {:ok, n2} = Scripts.add_node(draft, %{"node_key" => "end", "kind" => "terminal"})

    {:ok, _} =
      Scripts.add_expectation(n1, %{
        "label" => "says hi",
        "scoring_method" => "regex",
        "config" => %{"pattern" => "(?i)hi|hello"}
      })

    {:ok, _} =
      Scripts.add_edge(draft, %{
        "from_node_id" => n1.id,
        "to_node_id" => n2.id,
        "match_method" => "always"
      })

    %{org: org, user: user, script: script, draft: draft}
  end

  describe "publish_version/2 (US-006)" do
    test "publishes a valid script" do
      %{script: s, user: u} = setup_full_script()

      assert {:ok, :published, v} = Scripts.publish_version(s, published_by_user_id: u.id)
      assert is_binary(v.yaml_source)
      assert byte_size(v.checksum) == 32
      assert v.published_by_user_id == u.id

      reloaded = Scripts.get_script!(s.organization_id, s.id)
      assert reloaded.current_version_id == v.id
    end

    test "republishing same content is a noop" do
      %{script: s, user: u} = setup_full_script()
      {:ok, :published, v1} = Scripts.publish_version(s, published_by_user_id: u.id)
      {:ok, :noop, v2} = Scripts.publish_version(s, published_by_user_id: u.id)
      assert v1.id == v2.id
    end

    test "rejects publish when no expectations" do
      %{organization: org} = org_with_owner()
      {:ok, s, draft} = Scripts.create_script(%{"organization_id" => org.id, "name" => "Empty"})
      {:ok, _} = Scripts.add_node(draft, %{"node_key" => "start", "kind" => "user_turn"})

      assert {:error, :no_expectations} = Scripts.publish_version(s)
    end

    test "rejects publish when no nodes" do
      %{organization: org} = org_with_owner()
      {:ok, s, _draft} = Scripts.create_script(%{"organization_id" => org.id, "name" => "Empty"})

      assert {:error, :no_nodes} = Scripts.publish_version(s)
    end

    test "rejects publish when root not set (no user_turn)" do
      %{organization: org} = org_with_owner()
      {:ok, s, draft} = Scripts.create_script(%{"organization_id" => org.id, "name" => "Flow"})
      {:ok, n} = Scripts.add_node(draft, %{"node_key" => "sys", "kind" => "system"})

      {:ok, _} =
        Scripts.add_expectation(n, %{
          "label" => "x",
          "scoring_method" => "regex",
          "config" => %{}
        })

      assert {:error, :root_not_set} = Scripts.publish_version(s)
    end
  end

  describe "export_yaml/1 (US-008) + round-trip (US-007)" do
    test "exports YAML and re-imports produces identical checksum" do
      %{script: s, user: u, org: org} = setup_full_script()
      {:ok, :published, v} = Scripts.publish_version(s, published_by_user_id: u.id)
      yaml = Scripts.export_yaml(v)

      assert is_binary(yaml)
      assert String.contains?(yaml, "slug: flow") or String.contains?(yaml, "slug: 'flow'")

      # Re-import into a fresh org with the same prompt slug/version published
      %{organization: org2, user: u2} = org_with_owner()

      {:ok, p2} =
        Prompts.create_prompt(%{
          "organization_id" => org2.id,
          "created_by_user_id" => u2.id,
          "name" => "Greeter",
          "slug" => "greeter"
        })

      {:ok, :published, _pv2} =
        Prompts.publish_version(p2, %{body: "hello", published_by_user_id: u2.id})

      {:ok, :imported, imported_script, imported_v} =
        Scripts.import_yaml(yaml, org2.id, imported_by_user_id: u2.id)

      assert imported_script.organization_id == org2.id
      assert imported_script.slug == s.slug
      assert imported_v.checksum == v.checksum
      _ = org
    end

    test "import rejects missing prompt reference" do
      %{script: s, user: u} = setup_full_script()
      {:ok, :published, v} = Scripts.publish_version(s, published_by_user_id: u.id)
      yaml = Scripts.export_yaml(v)

      %{organization: org2} = org_with_owner()

      assert {:error, {:prompt_not_found, "greeter", 1}} =
               Scripts.import_yaml(yaml, org2.id)
    end

    test "re-importing identical YAML into same org is a noop (checksum dedup)" do
      %{script: s, user: u} = setup_full_script()
      {:ok, :published, v} = Scripts.publish_version(s, published_by_user_id: u.id)
      yaml = Scripts.export_yaml(v)

      assert {:ok, :noop, noop_script, noop_v} =
               Scripts.import_yaml(yaml, s.organization_id)

      assert noop_script.id == s.id
      assert noop_v.id == v.id
    end
  end
end
