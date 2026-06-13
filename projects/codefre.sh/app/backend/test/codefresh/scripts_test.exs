defmodule Codefresh.ScriptsTest do
  use Codefresh.DataCase, async: true

  alias Codefresh.{Scripts, Prompts}
  alias Codefresh.Scripts.{Script, ScriptVersion, ScriptNode}

  import Codefresh.Fixtures

  describe "create_script/1 (US-001)" do
    test "creates head + draft v1 version" do
      %{organization: org, user: user} = org_with_owner()

      {:ok, %Script{} = s, %ScriptVersion{} = v} =
        Scripts.create_script(%{
          "organization_id" => org.id,
          "created_by_user_id" => user.id,
          "name" => "Greeter Flow"
        })

      assert s.slug == "greeter-flow"
      assert s.current_version_id == nil
      assert v.version_number == 1
      assert v.script_id == s.id
      assert v.root_node_id == nil
    end

    test "rejects duplicate slug in same org" do
      %{organization: org} = org_with_owner()

      {:ok, _, _} = Scripts.create_script(%{"organization_id" => org.id, "name" => "Flow"})
      {:error, cs} = Scripts.create_script(%{"organization_id" => org.id, "name" => "Flow"})
      assert cs.errors[:slug] || cs.errors[:organization_id] |> is_tuple()
    end
  end

  describe "add_node/2 (US-002)" do
    test "first user_turn node becomes root_node_id" do
      %{organization: org} = org_with_owner()
      {:ok, s, v} = Scripts.create_script(%{"organization_id" => org.id, "name" => "Flow"})

      {:ok, n} =
        Scripts.add_node(v, %{
          "node_key" => "start",
          "kind" => "user_turn"
        })

      reloaded = Scripts.get_version!(v.id)
      assert reloaded.root_node_id == n.id
    end

    test "second node does not overwrite root" do
      %{organization: org} = org_with_owner()
      {:ok, _s, v} = Scripts.create_script(%{"organization_id" => org.id, "name" => "Flow"})

      {:ok, n1} = Scripts.add_node(v, %{"node_key" => "start", "kind" => "user_turn"})
      {:ok, _n2} = Scripts.add_node(v, %{"node_key" => "step2", "kind" => "user_turn"})

      assert Scripts.get_version!(v.id).root_node_id == n1.id
    end

    test "non-user_turn first node does not set root" do
      %{organization: org} = org_with_owner()
      {:ok, _s, v} = Scripts.create_script(%{"organization_id" => org.id, "name" => "Flow"})

      {:ok, _} = Scripts.add_node(v, %{"node_key" => "sys", "kind" => "system"})
      assert Scripts.get_version!(v.id).root_node_id == nil
    end

    test "rejects duplicate node_key in same version" do
      %{organization: org} = org_with_owner()
      {:ok, _s, v} = Scripts.create_script(%{"organization_id" => org.id, "name" => "Flow"})

      {:ok, _} = Scripts.add_node(v, %{"node_key" => "start", "kind" => "user_turn"})

      {:error, cs} = Scripts.add_node(v, %{"node_key" => "start", "kind" => "user_turn"})
      assert cs.errors[:node_key] || cs.errors[:script_version_id]
    end
  end

  describe "attach_prompt/2 (US-003)" do
    test "pins same-org published prompt" do
      %{organization: org, user: user} = org_with_owner()
      {:ok, _s, v} = Scripts.create_script(%{"organization_id" => org.id, "name" => "Flow"})
      {:ok, n} = Scripts.add_node(v, %{"node_key" => "start", "kind" => "user_turn"})

      {:ok, prompt} =
        Prompts.create_prompt(%{
          "organization_id" => org.id,
          "created_by_user_id" => user.id,
          "name" => "Greeter"
        })

      {:ok, :published, pv} =
        Prompts.publish_version(prompt, %{body: "hi", published_by_user_id: user.id})

      {:ok, updated} = Scripts.attach_prompt(n, pv.id)
      assert %ScriptNode{prompt_version_id: pvid} = updated
      assert pvid == pv.id
    end

    test "rejects cross-org prompt" do
      %{organization: org_a} = org_with_owner()
      %{organization: org_b, user: user_b} = org_with_owner()

      {:ok, _s, v} = Scripts.create_script(%{"organization_id" => org_a.id, "name" => "Flow"})
      {:ok, n} = Scripts.add_node(v, %{"node_key" => "start", "kind" => "user_turn"})

      {:ok, prompt_b} =
        Prompts.create_prompt(%{
          "organization_id" => org_b.id,
          "created_by_user_id" => user_b.id,
          "name" => "X"
        })

      {:ok, :published, pv} =
        Prompts.publish_version(prompt_b, %{body: "x", published_by_user_id: user_b.id})

      assert {:error, :prompt_not_pinnable} = Scripts.attach_prompt(n, pv.id)
    end
  end

  describe "add_expectation/2 (US-004)" do
    test "inserts regex expectation" do
      %{organization: org} = org_with_owner()
      {:ok, _s, v} = Scripts.create_script(%{"organization_id" => org.id, "name" => "Flow"})
      {:ok, n} = Scripts.add_node(v, %{"node_key" => "start", "kind" => "user_turn"})

      {:ok, exp} =
        Scripts.add_expectation(n, %{
          "label" => "contains greeting",
          "scoring_method" => "regex",
          "config" => %{"pattern" => "(?i)hello|hi"}
        })

      assert exp.label == "contains greeting"
      assert exp.direction == "positive"
    end

    test "rubric method without rubric_version_id is rejected" do
      %{organization: org} = org_with_owner()
      {:ok, _s, v} = Scripts.create_script(%{"organization_id" => org.id, "name" => "Flow"})
      {:ok, n} = Scripts.add_node(v, %{"node_key" => "start", "kind" => "user_turn"})

      assert {:error, :rubric_required} =
               Scripts.add_expectation(n, %{
                 "label" => "judge",
                 "scoring_method" => "rubric"
               })
    end
  end

  describe "add_edge/2 (US-005)" do
    test "adds edge between two nodes in same version" do
      %{organization: org} = org_with_owner()
      {:ok, _s, v} = Scripts.create_script(%{"organization_id" => org.id, "name" => "Flow"})
      {:ok, n1} = Scripts.add_node(v, %{"node_key" => "start", "kind" => "user_turn"})
      {:ok, n2} = Scripts.add_node(v, %{"node_key" => "end", "kind" => "terminal"})

      {:ok, edge} =
        Scripts.add_edge(v, %{
          "from_node_id" => n1.id,
          "to_node_id" => n2.id,
          "match_method" => "always"
        })

      assert edge.from_node_id == n1.id
      assert edge.to_node_id == n2.id
    end

    test "self-loop without match_method=always is rejected" do
      %{organization: org} = org_with_owner()
      {:ok, _s, v} = Scripts.create_script(%{"organization_id" => org.id, "name" => "Flow"})
      {:ok, n1} = Scripts.add_node(v, %{"node_key" => "start", "kind" => "user_turn"})

      {:error, cs} =
        Scripts.add_edge(v, %{
          "from_node_id" => n1.id,
          "to_node_id" => n1.id,
          "match_method" => "regex",
          "match_config" => %{"pattern" => "."}
        })

      assert cs.errors[:from_node_id]
    end

    test "self-loop with match_method=always is allowed" do
      %{organization: org} = org_with_owner()
      {:ok, _s, v} = Scripts.create_script(%{"organization_id" => org.id, "name" => "Flow"})
      {:ok, n1} = Scripts.add_node(v, %{"node_key" => "start", "kind" => "user_turn"})

      {:ok, _edge} =
        Scripts.add_edge(v, %{
          "from_node_id" => n1.id,
          "to_node_id" => n1.id,
          "match_method" => "always"
        })
    end

    test "rejects edge to node in a different version" do
      %{organization: org} = org_with_owner()
      {:ok, _s1, v1} = Scripts.create_script(%{"organization_id" => org.id, "name" => "Flow1"})
      {:ok, _s2, v2} = Scripts.create_script(%{"organization_id" => org.id, "name" => "Flow2"})

      {:ok, n1} = Scripts.add_node(v1, %{"node_key" => "a", "kind" => "user_turn"})
      {:ok, n2} = Scripts.add_node(v2, %{"node_key" => "b", "kind" => "user_turn"})

      assert {:error, :to_node_not_in_version} =
               Scripts.add_edge(v1, %{
                 "from_node_id" => n1.id,
                 "to_node_id" => n2.id,
                 "match_method" => "always"
               })
    end
  end
end
