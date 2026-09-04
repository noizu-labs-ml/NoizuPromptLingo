defmodule NoizuPromptLingua.Domains.Memory.ToolsTest do
  @moduledoc """
  MCP tool surface for the memory engine: Scope resolution, Remember/Recall/
  RecallByEmotion/Reinforce/Denforce/Associations and the agent registry tools.
  Weaviate-dependent paths assert shape only (eventual consistency), never order.
  """
  use NoizuPromptLingua.MemoryCase, async: false

  alias NoizuPromptLingua.Domains.Memory.Tools.{
    AgentList,
    AgentRegister,
    Denforce,
    MemoryAssociations,
    Overview,
    Recall,
    RecallByEmotion,
    Remember,
    Reinforce,
    Scope
  }

  # ── Scope ──────────────────────────────────────────────────────────

  test "Scope.resolve builds persona / weego / team_member contexts and error paths" do
    org = insert_org()
    persona_id = insert_persona(org)

    assert {:ok, %{scope_type: :persona, scope_id: ^persona_id = pid, source_agent: "mcp"}} =
             Scope.resolve(%{
               "organization" => to_string(org),
               "scope_type" => "persona",
               "agent" => to_string(persona_id)
             })

    assert is_binary(pid)

    {:ok, cs} = NoizuPromptLingua.Domains.Memory.Agents.register(org, :team_member)
    assert {:ok, %{scope_type: :team_member}} =
             Scope.resolve(%{
               "organization" => to_string(org),
               "scope_type" => "team_member",
               "agent" => cs.call_sign
             })

    assert {:error, "Organization 'nope-org' not found"} =
             Scope.resolve(%{"organization" => "nope-org", "scope_type" => "persona"})

    assert {:error, "scope_type must be one of: persona | weego | team_member"} =
             Scope.resolve(%{"organization" => to_string(org), "scope_type" => "boss"})

    assert {:error, "Persona 'ghost' not found"} =
             Scope.resolve(%{
               "organization" => to_string(org),
               "scope_type" => "persona",
               "agent" => "ghost"
             })

    assert {:error, "Agent 'ghost-sign' not found in this org"} =
             Scope.resolve(%{
               "organization" => to_string(org),
               "scope_type" => "team_member",
               "agent" => "ghost-sign"
             })
  end

  # ── Remember / Recall / RecallByEmotion ────────────────────────────

  test "Remember stores via the engine and Recall finds it" do
    org = insert_org()
    persona_id = insert_persona(org)

    args = %{
      "organization" => to_string(org),
      "scope_type" => "persona",
      "agent" => to_string(persona_id),
      "content" => "w4c-remember-#{System.unique_integer([:positive])} deployed the gateway",
      "content_type" => "semantic",
      "valence" => 0.5,
      "arousal" => 0.7,
      "collaborators" => "a, b",
      "domain" => "testing"
    }

    assert {:ok, %{id: id, status: status, confidence: conf}} = Remember.call(args, %{})
    assert is_binary(id)
    assert is_binary(status)
    assert conf in ["low", "medium", "high"] or is_number(conf)

    eventually(fn ->
      case Recall.call(Map.merge(args, %{"query" => args["content"], "limit" => 5}), %{}) do
        {:ok, %{count: count, results: results, xml: xml}} when count > 0 ->
          assert is_binary(xml)
          assert Enum.all?(results, &is_map/1)
          true

        _ ->
          false
      end
    end)
  end

  test "RecallByEmotion returns a shaped batch" do
    org = insert_org()
    persona_id = insert_persona(org)

    assert {:ok, %{count: count, results: results, xml: xml}} =
             RecallByEmotion.call(
               %{
                 "organization" => to_string(org),
                 "scope_type" => "persona",
                 "agent" => to_string(persona_id),
                 "valence" => -0.5,
                 "arousal" => 0.8,
                 "dominance" => 0.2,
                 "limit" => 3
               },
               %{}
             )

    assert is_integer(count)
    assert length(results) == count
    assert is_binary(xml)
  end

  # ── Reinforce / Denforce / Associations ────────────────────────────

  test "Reinforce and Denforce adjust a stored memory's decay weight" do
    org = insert_org()
    persona_id = insert_persona(org)

    scope_args = %{
      "organization" => to_string(org),
      "scope_type" => "persona",
      "agent" => to_string(persona_id)
    }

    content = "w4c-reinforce-#{System.unique_integer([:positive])} tuned the relay"
    {:ok, %{id: mem_id}} = Remember.call(Map.merge(scope_args, %{"content" => content}), %{})

    eventually(fn -> recall_hit?(scope_args, content) end)

    assert {:ok, %{memory_id: ^mem_id = mid, decay_weight: w1}} =
             Reinforce.call(Map.merge(scope_args, %{"memory_id" => mem_id}), %{})

    assert mid == mem_id
    assert is_number(w1)

    assert {:ok, %{decay_weight: _}} = Denforce.call(Map.merge(scope_args, %{"memory_id" => mem_id}), %{})

    assert {:error, "memory not found in this scope"} =
             Reinforce.call(Map.merge(scope_args, %{"memory_id" => Ecto.UUID.generate()}), %{})
  end

  test "MemoryAssociations lists association edges for a memory" do
    org = insert_org()
    persona_id = insert_persona(org)

    scope_args = %{
      "organization" => to_string(org),
      "scope_type" => "persona",
      "agent" => to_string(persona_id)
    }

    {:ok, %{id: mem_id}} =
      Remember.call(Map.merge(scope_args, %{"content" => "w4c-assoc-#{System.unique_integer([:positive])}"}), %{})

    eventually(fn -> recall_hit?(scope_args, "w4c-assoc") end)

    assert {:ok, %{memory_id: ^mem_id, count: count, edges: edges}} =
             MemoryAssociations.call(Map.merge(scope_args, %{"memory_id" => mem_id}), %{})

    assert is_integer(count)
    assert length(edges) == count
  end

  defp recall_hit?(scope_args, query) do
    case Recall.call(Map.merge(scope_args, %{"query" => query, "limit" => 5}), %{}) do
      {:ok, %{count: count}} -> count > 0
      _ -> false
    end
  end

  # ── Agent registry tools ───────────────────────────────────────────

  test "AgentRegister + AgentList + Overview cover the call-sign registry" do
    org = insert_org()
    org_ref = to_string(org)
    call_sign = "w4c-agent-#{System.unique_integer([:positive])}"

    assert {:ok, %{call_sign: ^call_sign, kind: "team_member"} = registered} =
             AgentRegister.call(
               %{"organization" => org_ref, "kind" => "team_member", "call_sign" => call_sign},
               %{}
             )

    assert Map.has_key?(registered, :id)

    assert {:error, msg} = AgentRegister.call(%{"organization" => org_ref, "kind" => "boss"}, %{})
    assert msg =~ "kind"

    assert {:ok, %{agents: agents}} = AgentList.call(%{"organization" => org_ref}, %{})
    assert is_list(agents)
    assert Enum.any?(agents, &(&1.call_sign == call_sign))

    assert {:ok, %{registered_agents: count, tools: %{memory: memory_tools, agents: agent_tools}}} =
             Overview.call(%{"organization" => org_ref}, %{})

    assert is_integer(count)
    assert "Memory.AgentRegister" in agent_tools
    assert "Memory.Recall" in memory_tools

    # Overview is static + never errors; an unknown org just reports zero agents.
    assert {:ok, %{registered_agents: 0}} = Overview.call(%{"organization" => "ghost-org"}, %{})
  end
end
