defmodule NoizuPromptLingua.Domains.MCPOverview.StoreTest do
  @moduledoc """
  Exercises the pgvector nearest-neighbor store against the running Postgres
  (npl-test-pg, real `vector` type). Embeddings are FIXED, hand-built 1536-d
  vectors — no OpenAI — so distances and ordering are deterministic.
  """
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.MCPOverview.{Store, Indexer}

  @dims 1536

  # A unit 1536-d vector whose cosine DISTANCE from axis-0 (`[1,0,0,…]`) is exactly
  # `dist`: it puts cos = (1 - dist) on axis 0 and the remainder on axis 1, so the
  # vector is already unit-norm and `axis0 · v = 1 - dist`.
  defp vec_at_distance(dist) do
    c = 1.0 - dist
    b = :math.sqrt(max(1.0 - c * c, 0.0))

    for j <- 0..(@dims - 1) do
      cond do
        j == 0 -> c
        j == 1 -> b
        true -> 0.0
      end
    end
  end

  defp query_vec, do: vec_at_distance(0.0)

  defp insert(scope, dist, status) do
    {:ok, row} =
      Store.insert_overview(%{
        scope_slug: scope,
        task_text: "task d=#{dist} #{status}",
        task_embedding: vec_at_distance(dist),
        overview_md: "# overview d=#{dist}",
        status: status
      })

    row
  end

  defp scope, do: "store-#{System.unique_integer([:positive])}"

  describe "nearest_overview/3 — ordering + threshold" do
    test "returns the nearest generated overview within threshold" do
      s = scope()
      near = insert(s, 0.0, "generated")
      _far = insert(s, 0.10, "generated")

      assert {:ok, hit} = Store.nearest_overview(s, query_vec())
      assert hit.id == near.id
    end

    test "excludes overviews beyond the cosine-distance threshold" do
      s = scope()
      # 1.0 distance (orthogonal) is well past the 0.25 default threshold.
      _beyond = insert(s, 1.0, "generated")

      assert :miss = Store.nearest_overview(s, query_vec())
    end

    test "an in-threshold overview matches; a sibling past threshold is ignored" do
      s = scope()
      within = insert(s, 0.10, "generated")
      _beyond = insert(s, 1.0, "generated")

      assert {:ok, hit} = Store.nearest_overview(s, query_vec())
      assert hit.id == within.id
    end

    test "rejected overviews never match" do
      s = scope()
      _rejected = insert(s, 0.0, "rejected")

      assert :miss = Store.nearest_overview(s, query_vec())
    end

    test "scope isolates matches" do
      s = scope()
      _other = insert("other-#{System.unique_integer([:positive])}", 0.0, "generated")

      assert :miss = Store.nearest_overview(s, query_vec())
    end
  end

  describe "nearest_overview/3 — approved preference" do
    test "prefers an approved overview over a closer generated one" do
      s = scope()
      _closer_generated = insert(s, 0.0, "generated")
      approved = insert(s, 0.10, "approved")

      assert {:ok, hit} = Store.nearest_overview(s, query_vec())
      assert hit.id == approved.id
      assert hit.status == "approved"
    end

    test "falls back to generated when no approved is within threshold" do
      s = scope()
      generated = insert(s, 0.05, "generated")

      assert {:ok, hit} = Store.nearest_overview(s, query_vec())
      assert hit.id == generated.id
      assert hit.status == "generated"
    end
  end

  describe "Indexer.refresh/3 — hash-skip" do
    defp specs do
      [
        %{name: "alpha_tool", category: "GroupA", description: "assembles alpha widgets"},
        %{name: "beta_tool", category: "GroupA", description: "brews beta potions"}
      ]
    end

    test "embeds new tools, then skips unchanged ones on re-run" do
      s = scope()

      first = Indexer.refresh(s, specs())
      assert first.configured
      assert first.embedded == 2
      assert first.skipped == 0
      assert length(Store.list_tool_vectors(s)) == 2

      second = Indexer.refresh(s, specs())
      assert second.embedded == 0
      assert second.skipped == 2
      # Still exactly one vector per tool.
      assert length(Store.list_tool_vectors(s)) == 2
    end

    test "re-embeds only the tool whose description changed" do
      s = scope()
      Indexer.refresh(s, specs())

      changed = [
        %{name: "alpha_tool", category: "GroupA", description: "assembles alpha widgets"},
        %{name: "beta_tool", category: "GroupA", description: "NOW brews DIFFERENT beta potions"}
      ]

      result = Indexer.refresh(s, changed)
      assert result.embedded == 1
      assert result.skipped == 1
      assert result.changed == ["beta_tool"]
      # No accumulation of stale rows: one current vector per tool.
      assert length(Store.list_tool_vectors(s)) == 2
    end
  end
end
