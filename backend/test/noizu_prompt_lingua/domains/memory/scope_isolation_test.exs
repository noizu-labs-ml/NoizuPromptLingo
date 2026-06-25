defmodule NoizuPromptLingua.Domains.Memory.ScopeIsolationTest do
  @moduledoc "Scope visibility: per-scope isolation + weego-sees-its-team."
  use NoizuPromptLingua.MemoryCase, async: false
  @moduletag :memory
  @moduletag timeout: 120_000

  test "two personas in the same org do not see each other's memories" do
    org = insert_org()
    ada = persona_scope(org, insert_persona(org, "ada"))
    bob = persona_scope(org, insert_persona(org, "bob"))

    {:ok, %{id: aid}} =
      Memory.remember(%{content: "ada's private rust note", valence: 0.0, arousal: 0.5, dominance: 0.5}, ada)

    # Confirm ada CAN see her own (wait for Weaviate), then assert bob cannot.
    assert eventually(fn ->
             case Memory.recall("rust note", [limit: 5], ada) do
               {:ok, %{results: r}} -> if Enum.any?(r, &(&1.id == aid)), do: r, else: nil
               _ -> nil
             end
           end)

    {:ok, %{results: bob_results}} = Memory.recall("rust note", [limit: 5], bob)
    refute Enum.any?(bob_results, &(&1.id == aid)), "bob must not see ada's memory"
  end

  test "the weego sees its team members' memories; a team member sees only its own" do
    org = insert_org()
    tm = team_member_scope(org)
    other = team_member_scope(org)
    weego = weego_scope(org)

    {:ok, %{id: tid}} =
      Memory.remember(%{content: "nimbus cluster deploy log", valence: 0.2, arousal: 0.5, dominance: 0.6}, tm)

    # weego (org-wide read) surfaces the team member's memory
    assert eventually(fn ->
             case Memory.recall("nimbus deploy", [limit: 10], weego) do
               {:ok, %{results: r}} -> if Enum.any?(r, &(&1.id == tid)), do: r, else: nil
               _ -> nil
             end
           end),
           "weego should see its team member's memory"

    # the owning team member sees its own
    assert eventually(fn ->
             case Memory.recall("nimbus deploy", [limit: 5], tm) do
               {:ok, %{results: r}} -> if Enum.any?(r, &(&1.id == tid)), do: r, else: nil
               _ -> nil
             end
           end)

    # a different team member does NOT
    {:ok, %{results: other_results}} = Memory.recall("nimbus deploy", [limit: 5], other)
    refute Enum.any?(other_results, &(&1.id == tid)), "a different team member must not see it"
  end
end
