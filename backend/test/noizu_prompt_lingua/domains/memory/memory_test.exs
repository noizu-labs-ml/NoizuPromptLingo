defmodule NoizuPromptLingua.Domains.Memory.MemoryTest do
  @moduledoc "End-to-end engine: remember → Weaviate → recall (text + emotion), reinforce, associations."
  use NoizuPromptLingua.MemoryCase, async: false
  @moduletag :memory
  @moduletag timeout: 120_000

  setup do
    org = insert_org()
    scope = persona_scope(org, insert_persona(org))
    {:ok, org: org, scope: scope}
  end

  test "remember stores a memory and active (text) recall surfaces it", %{scope: scope} do
    {:ok, %{id: id}} =
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

    {:ok, _} =
      Memory.remember(
        %{
          content: "shipped the dashboard journey filter",
          domain: "product",
          valence: 0.5,
          arousal: 0.5,
          dominance: 0.5
        },
        scope
      )

    results =
      eventually(fn ->
        case Memory.recall("rust borrow checker lifetimes", [limit: 5], scope) do
          {:ok, %{results: r}} -> if Enum.any?(r, &(&1.id == id)), do: r, else: nil
          _ -> nil
        end
      end)

    assert results, "the rust memory should surface for a rust query"
  end

  test "recall_by_emotion surfaces emotionally-similar memories", %{scope: scope} do
    {:ok, %{id: neg}} =
      Memory.remember(
        %{content: "the stressful 2am outage", valence: -0.7, arousal: 0.9, dominance: 0.3},
        scope
      )

    {:ok, _} =
      Memory.remember(
        %{content: "a calm afternoon refactor", valence: 0.6, arousal: 0.3, dominance: 0.7},
        scope
      )

    results =
      eventually(fn ->
        case Memory.recall_by_emotion(
               %{mood: %{valence: -0.7, arousal: 0.9, dominance: 0.3}},
               [limit: 5],
               scope
             ) do
          {:ok, %{results: r}} -> if r != [] and hd(r).id == neg, do: r, else: nil
          _ -> nil
        end
      end)

    assert results, "a stressed query should surface the outage memory first"
  end

  test "reinforce raises and denforce lowers the decay weight (clamped)", %{scope: scope} do
    {:ok, %{id: id}} =
      Memory.remember(
        %{content: "a neutral note", valence: 0.0, arousal: 0.5, dominance: 0.5},
        scope
      )

    {:ok, w0} = Memory.denforce(id, scope)
    assert w0 < 1.0
    {:ok, w1} = Memory.reinforce(id, scope)
    assert w1 > w0
  end

  test "the Weaver builds contextual association edges (shared domain)", %{scope: scope} do
    {:ok, %{id: a}} =
      Memory.remember(
        %{
          content: "postgres deadlock at midnight",
          domain: "debugging",
          valence: -0.3,
          arousal: 0.6,
          dominance: 0.4
        },
        scope
      )

    {:ok, _} =
      Memory.remember(
        %{
          content: "postgres connection pool tuning",
          domain: "debugging",
          valence: 0.1,
          arousal: 0.5,
          dominance: 0.6
        },
        scope
      )

    edges = Memory.associations(a, scope)

    assert Enum.any?(edges, &(&1.edge_type == :contextual)),
           "shared-domain memories should be linked"
  end
end
