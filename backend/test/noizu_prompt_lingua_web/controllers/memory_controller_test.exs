defmodule NoizuPromptLinguaWeb.MemoryControllerTest do
  @moduledoc """
  Agent-memory browser REST surface (/api/organization/:org/agent/:slug/...):
  the scope-selector listing (personas + call signs), recent/recall/recall-
  by-emotion round-trips through the memory engine (deterministic offline
  embeddings), association edges, and the unknown-agent 404 arm. Fixtures per
  the MemoryCase builders (w2c/w4c pattern); the caller holds a viewer role on
  the inserted org for the :org_viewer pipeline.
  """

  use NoizuPromptLinguaWeb.ConnCase, async: false

  import NoizuPromptLingua.MemoryCase

  alias NoizuPromptLingua.Authz.ScopedMemberships
  alias NoizuPromptLingua.Domains.Memory
  alias NoizuPromptLingua.Domains.Memory.Agents

  setup %{conn: conn} do
    %{access_token: token, user: user} = setup_user_and_token()
    auth = authenticated_conn(conn, token)

    org = insert_org()
    {:ok, _} = ScopedMemberships.add_member("organization", org, user.id, "viewer")

    persona_id = insert_persona(org, "ada")
    {:ok, _weego} = Agents.register(org, :weego, call_sign: "weego")
    {:ok, viper} = Agents.register(org, :team_member, call_sign: "viper")

    scope = persona_scope(org, persona_id)

    {:ok, %{id: mem_id}} =
      Memory.remember(
        %{
          content: "wrestled the rust borrow checker and lifetimes",
          domain: "engineering",
          valence: -0.2,
          arousal: 0.6,
          dominance: 0.4
        },
        scope
      )

    {:ok, auth: auth, org: org, persona_id: persona_id, viper: viper, mem_id: mem_id}
  end

  defp base(org), do: "/api/organization/#{org}"

  describe "GET /agents (scope selector)" do
    test "lists personas and call signs for the org", %{auth: auth, org: org, viper: viper} do
      %{"agents" => agents} = auth |> get("#{base(org)}/agents") |> json_response(200)

      assert Enum.any?(agents, &(&1["scope_type"] == "persona" and &1["slug"] == "ada"))

      assert Enum.any?(
               agents,
               &(&1["scope_type"] == "team_member" and &1["scope_id"] == viper.id)
             )

      assert Enum.any?(agents, &(&1["slug"] == "weego"))
    end
  end

  describe "GET /agent/:agent_slug/memory (recent)" do
    test "returns the recent list for the persona scope", %{auth: auth, org: org} do
      conn = get(auth, "#{base(org)}/agent/ada/memory")

      assert %{"results" => results} = json_response(conn, 200)
      assert is_list(results)
    end

    test "honours the limit param", %{auth: auth, org: org} do
      conn = get(auth, "#{base(org)}/agent/ada/memory", %{limit: "1"})

      assert %{"results" => results} = json_response(conn, 200)
      assert length(results) <= 1
    end

    test "works for a call-sign scope (weego)", %{auth: auth, org: org} do
      conn = get(auth, "#{base(org)}/agent/weego/memory")

      assert %{"results" => results} = json_response(conn, 200)
      assert is_list(results)
    end

    test "unknown agent slug -> 404", %{auth: auth, org: org} do
      assert %{"error" => "agent not found in this organization"} =
               json_response(get(auth, "#{base(org)}/agent/ghost/memory"), 404)
    end
  end

  describe "POST /agent/:agent_slug/memory/recall" do
    test "surfaces a remembered memory by query", %{auth: auth, org: org, mem_id: mem_id} do
      results =
        eventually(fn ->
          case auth
               |> post("#{base(org)}/agent/ada/memory/recall", %{query: "rust borrow checker"}) do
            conn ->
              case json_response(conn, 200) do
                %{"results" => r} ->
                  if Enum.any?(r, &(&1["id"] == mem_id)), do: {:ok, r}, else: nil

                _ ->
                  nil
              end
          end
        end)

      assert {:ok, results} = results
      assert Enum.any?(results, &(&1["id"] == mem_id))
    end
  end

  describe "POST /agent/:agent_slug/memory/recall_by_emotion" do
    test "accepts a mood map and returns results", %{auth: auth, org: org} do
      conn =
        post(auth, "#{base(org)}/agent/ada/memory/recall_by_emotion", %{
          "mood" => %{"valence" => "-0.2", "arousal" => "0.6", "dominance" => "0.4"}
        })

      assert %{"results" => results} = json_response(conn, 200)
      assert is_list(results)
    end

    test "defaults the mood when absent", %{auth: auth, org: org} do
      conn = post(auth, "#{base(org)}/agent/ada/memory/recall_by_emotion", %{})

      assert %{"results" => results} = json_response(conn, 200)
      assert is_list(results)
    end
  end

  describe "GET /agent/:agent_slug/memory/:id/associations" do
    test "maps association edges of a memory", %{auth: auth, org: org, persona_id: persona_id} do
      # Two same-domain memories auto-link with a :contextual edge.
      {:ok, %{id: a}} =
        Memory.remember(
          %{content: "debugged the flaky channel test", domain: "debugging"},
          persona_scope(org, persona_id)
        )

      {:ok, _} =
        Memory.remember(
          %{content: "postgres connection pool tuning", domain: "debugging"},
          persona_scope(org, persona_id)
        )

      edges =
        eventually(fn ->
          case auth |> get("#{base(org)}/agent/ada/memory/#{a}/associations") do
            conn ->
              case json_response(conn, 200) do
                %{"edges" => []} -> nil
                %{"edges" => edges} -> {:ok, edges}
                _ -> nil
              end
          end
        end)

      assert {:ok, edges} = edges

      assert Enum.any?(
               edges,
               &(&1["edge_type"] == "contextual" and is_binary(&1["source_memory_id"]) and
                   is_binary(&1["target_memory_id"]))
             )
    end
  end

  describe "unknown-agent 404 arms on write endpoints" do
    test "recall and recall_by_emotion 404 for an unknown slug", %{auth: auth, org: org} do
      assert %{"error" => "agent not found in this organization"} =
               json_response(
                 post(auth, "#{base(org)}/agent/ghost/memory/recall", %{query: "x"}),
                 404
               )

      assert %{"error" => "agent not found in this organization"} =
               json_response(
                 post(auth, "#{base(org)}/agent/ghost/memory/recall_by_emotion", %{}),
                 404
               )
    end
  end

  describe "mood parameter parsing (recall_by_emotion)" do
    test "numeric mood values pass through", %{auth: auth, org: org} do
      conn =
        post(auth, "#{base(org)}/agent/ada/memory/recall_by_emotion", %{
          "mood" => %{"valence" => 0.5, "arousal" => 1, "dominance" => 0}
        })

      assert %{"results" => results} = json_response(conn, 200)
      assert is_list(results)
    end

    test "unparseable mood values fall back to defaults", %{auth: auth, org: org} do
      conn =
        post(auth, "#{base(org)}/agent/ada/memory/recall_by_emotion", %{
          "mood" => %{"valence" => "not-a-number", "arousal" => [], "dominance" => "0.7x"}
        })

      assert %{"results" => results} = json_response(conn, 200)
      assert is_list(results)
    end
  end
end
