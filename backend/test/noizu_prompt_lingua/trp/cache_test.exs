defmodule NoizuPromptLingua.TRP.CacheTest do
  @moduledoc "ETS cache: TTL expiry, prefix/exact bust, stale fallback, stats."
  use ExUnit.Case, async: false

  alias NoizuPromptLingua.TRP.Cache

  setup do
    Cache.clear()
    :ok
  end

  test "put/get round-trip within TTL" do
    Cache.put([:item, "org", "id"], %{title: "x"}, 60_000)
    assert {:ok, %{title: "x"}} = Cache.get([:item, "org", "id"])
  end

  test "expired entries miss (lazy eviction)" do
    Cache.put([:k], :v, 1)
    Process.sleep(5)
    assert :miss = Cache.get([:k])
  end

  test "get_stale ignores TTL" do
    Cache.put([:k], :v, 1)
    Process.sleep(5)
    assert {:ok, :v} = Cache.get_stale([:k])
  end

  test "bust_prefix evicts every key sharing the prefix" do
    Cache.put([:items_list, "o1", [status: "open"]], :a, 60_000)
    Cache.put([:items_list, "o1", [status: nil]], :b, 60_000)
    Cache.put([:items_list, "o2", []], :c, 60_000)
    Cache.put([:item, "o1", "id1"], :d, 60_000)

    assert Cache.bust_prefix([:items_list, "o1"]) == 2
    assert :miss = Cache.get([:items_list, "o1", [status: "open"]])
    assert {:ok, :c} = Cache.get([:items_list, "o2", []])
    assert {:ok, :d} = Cache.get([:item, "o1", "id1"])
  end

  test "bust evicts exactly one key" do
    Cache.put([:k, 1], :a, 60_000)
    Cache.bust([:k, 1])
    assert :miss = Cache.get([:k, 1])
  end

  test "stats counters + entries" do
    Cache.put([:a], 1, 60_000)
    {:ok, _} = Cache.get([:a])
    :miss = Cache.get([:nope])
    stats = Cache.stats()
    assert stats.entries >= 1
    assert stats.hits >= 1
    assert stats.misses >= 1
  end

  test "cached_get caches fetch results and skips nil/errors" do
    calls = :counters.new(1, [:atomics])

    fetch = fn ->
      :counters.add(calls, 1, 1)
      %{v: :counters.get(calls, 1)}
    end

    assert %{v: 1} = Cache.cached_get([:k], 60_000, fetch)
    assert %{v: 1} = Cache.cached_get([:k], 60_000, fetch)
    assert :counters.get(calls, 1) == 1

    # errors are not cached
    assert {:error, :boom} = Cache.cached_get([:err], 60_000, fn -> {:error, :boom} end)
    assert {:error, :boom} = Cache.cached_get([:err], 60_000, fn -> {:error, :boom} end)

    # nil is not cached
    assert nil == Cache.cached_get([:nil], 60_000, fn -> nil end)
    assert nil == Cache.cached_get([:nil], 60_000, fn -> nil end)
  end
end
