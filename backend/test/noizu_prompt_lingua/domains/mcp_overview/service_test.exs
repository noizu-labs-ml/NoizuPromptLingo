defmodule NoizuPromptLingua.Domains.MCPOverview.ServiceTest do
  @moduledoc """
  End-to-end flow: embed → NN recall → hit (cached) / miss (generate + store).
  Embeddings run deterministic (test_helper) and generation uses `Generator.Stub`
  (test_helper) — no OpenAI, no LLM calls.
  """
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.MCPOverview.{Service, Store}

  defp specs do
    [
      %{name: "alpha_tool", category: "GroupA", description: "assembles alpha widgets"},
      %{name: "beta_tool", category: "GroupB", description: "brews beta potions"}
    ]
  end

  defp scope, do: "svc-#{System.unique_integer([:positive])}"

  test "miss generates + stores a flagged overview; a repeat task hits the cache" do
    s = scope()
    task = "assemble alpha widgets for the launch"

    assert {:ok, first} = Service.overview(s, task, specs())
    assert first.generated == true
    assert first.cached == false
    assert first.status == "generated"
    assert first.overview_md =~ "MCP Overview"
    # Focused by proximity: the stub lists tool names from the indexed vectors.
    assert first.overview_md =~ "alpha_tool"

    # Persisted as generated, with an embedding (recall-matchable).
    stored = Store.get_overview(first.id)
    assert stored.status == "generated"
    refute is_nil(stored.task_embedding)

    # Same task text → same deterministic embedding → distance 0 → cache hit.
    assert {:ok, second} = Service.overview(s, task, specs())
    assert second.cached == true
    assert second.generated == false
    assert second.id == first.id
  end

  test "approved overviews are preferred on recall" do
    s = scope()
    task = "brew beta potions carefully"

    {:ok, first} = Service.overview(s, task, specs())
    {:ok, _} = Store.set_status(first.id, "approved")

    assert {:ok, hit} = Service.overview(s, task, specs())
    assert hit.cached == true
    assert hit.status == "approved"
    assert hit.id == first.id
  end

  test "a distant task misses and generates a new overview" do
    s = scope()
    {:ok, first} = Service.overview(s, "assemble alpha widgets", specs())

    # Disjoint vocabulary → near-orthogonal deterministic vector → past threshold.
    assert {:ok, second} = Service.overview(s, "zzz quux frobnicate xyzzy", specs())
    assert second.generated == true
    assert second.cached == false
    refute second.id == first.id

    assert length(Store.list_overviews(scope_slug: s)) == 2
  end
end
