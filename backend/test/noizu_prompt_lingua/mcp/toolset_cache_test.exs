defmodule NoizuPromptLingua.MCP.ToolsetCacheTest do
  use NoizuPromptLingua.DataCase, async: false

  # D1 perf cache: persistent_term TTL cache over the ToolGuard/Catalog hot
  # path lookups (template/scope rows, API keys, OAuth clients). Invariants
  # under test: positives cached, negatives never cached, generation bump
  # invalidates, and a scope/key write path refreshes what EffectiveToolset sees.
  alias NoizuPromptLingua.MCP.{EffectiveToolset, ToolsetCache}
  alias NoizuPromptLingua.MCPCustomScopes
  alias NoizuPromptLingua.OAuth.Clients

  setup do
    ToolsetCache.enable()
    ToolsetCache.flush()

    on_exit(fn ->
      Application.delete_env(:noizu_prompt_lingua, :mcp_toolset_cache_enabled)
    end)

    :ok
  end

  defp counting_loader(counter_ref) do
    fn ->
      :ets.update_counter(counter_ref, :calls, {2, 1}, {:calls, 0})
      System.unique_integer([:positive])
    end
  end

  test "fetch caches positives (loader runs once)" do
    counter_ref = :ets.new(:cache_test_counter, [:public, :named_table])
    loader = counting_loader(counter_ref)

    a = ToolsetCache.fetch(:thing, "x", loader)
    b = ToolsetCache.fetch(:thing, "x", loader)
    c = ToolsetCache.fetch(:thing, "x", loader)

    assert a == b and b == c
    assert :ets.lookup(counter_ref, :calls) == [{:calls, 1}]
  end

  test "fetch keys are independent (kind + id)" do
    counter_ref = :ets.new(:cache_test_counter2, [:public, :named_table])
    loader = counting_loader(counter_ref)

    a = ToolsetCache.fetch(:thing, "x", loader)
    b = ToolsetCache.fetch(:thing, "y", loader)
    c = ToolsetCache.fetch(:other, "x", loader)

    assert [a, b, c] == Enum.uniq([a, b, c])
    assert :ets.lookup(counter_ref, :calls) == [{:calls, 3}]
  end

  test "negatives are never cached (stale DENY impossible)" do
    counter_ref = :ets.new(:cache_test_counter3, [:public, :named_table])
    calls = fn -> :ets.update_counter(counter_ref, :calls, {2, 1}, {:calls, 0}) end

    nil_loader = fn ->
      calls.()
      nil
    end

    assert ToolsetCache.fetch(:thing, "missing", nil_loader) == nil
    assert ToolsetCache.fetch(:thing, "missing", nil_loader) == nil
    assert :ets.lookup(counter_ref, :calls) == [{:calls, 2}]
  end

  test "bump/0 invalidates every entry" do
    counter_ref = :ets.new(:cache_test_counter4, [:public, :named_table])
    loader = counting_loader(counter_ref)

    ToolsetCache.fetch(:thing, "x", loader)
    ToolsetCache.fetch(:thing, "y", loader)
    assert :ets.lookup(counter_ref, :calls) == [{:calls, 2}]

    ToolsetCache.bump()
    ToolsetCache.fetch(:thing, "x", loader)
    assert :ets.lookup(counter_ref, :calls) == [{:calls, 3}]
  end

  test "TTL expiry forces a refetch" do
    Application.put_env(:noizu_prompt_lingua, :mcp_toolset_cache_ttl_ms, 0)
    counter_ref = :ets.new(:cache_test_counter5, [:public, :named_table])
    loader = counting_loader(counter_ref)

    ToolsetCache.fetch(:thing, "x", loader)
    ToolsetCache.fetch(:thing, "x", loader)

    assert :ets.lookup(counter_ref, :calls) == [{:calls, 2}]
  after
    Application.delete_env(:noizu_prompt_lingua, :mcp_toolset_cache_ttl_ms)
  end

  test "scope update path invalidates: EffectiveToolset sees new config immediately" do
    uniq = System.unique_integer([:positive])

    {:ok, scope} =
      MCPCustomScopes.create(%{
        "slug" => "cache-probe-#{uniq}",
        "name" => "cache probe",
        "kind" => "custom",
        "config" => %{"groups" => %{}}
      })

    slug = scope.slug
    ctx = %{assigns: %{custom_scope_slug: slug}}

    # Prime the cache with the current scope row.
    assert EffectiveToolset.scope_from_ctx(ctx).id == scope.id

    {:ok, _} =
      MCPCustomScopes.update(scope, %{
        "config" => %{"groups" => %{"sessions" => %{"disabled" => true}}}
      })

    reloaded = EffectiveToolset.scope_from_ctx(ctx)
    assert reloaded.id == scope.id
    assert reloaded.config["groups"]["sessions"]["disabled"] == true
  end

  test "oauth client config write invalidates: client_for_ctx sees new narrowing" do
    uniq = System.unique_integer([:positive])

    {:ok, reg} =
      Clients.register(%{
        "client_name" => "cache-cli-#{uniq}",
        "redirect_uris" => ["http://127.0.0.1:9876/callback"],
        "token_endpoint_auth_method" => "none"
      })

    client_id = reg["client_id"]
    ctx = %{assigns: %{auth_claims: %{"client_id" => client_id}}}

    # Prime: active legacy client with %{} config resolves with toolset_config: nil.
    primed = EffectiveToolset.client_for_ctx(ctx)
    assert primed != nil and primed.toolset_config == nil

    {:ok, _} =
      Clients.update_toolset_config(Clients.get_active(client_id), %{
        "groups" => %{"chat" => %{"disabled" => true}}
      })

    resolved = EffectiveToolset.client_for_ctx(ctx)
    assert resolved.kind == :oauth_client
    assert resolved.toolset_config["groups"]["chat"]["disabled"] == true
  end
end
