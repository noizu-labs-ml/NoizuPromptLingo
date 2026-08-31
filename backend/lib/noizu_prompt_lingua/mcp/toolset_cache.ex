defmodule NoizuPromptLingua.MCP.ToolsetCache do
  @moduledoc """
  Tiny TTL cache (a single `:persistent_term` entry) for the ToolGuard / Catalog
  hot path: the global `tobor` template scope, custom scopes by slug, MCP API
  keys, and OAuth clients.

  Every tool call and listing used to re-read these rows; the cache turns that
  into a map lookup. Rules:

    * **Positives only.** A `nil` (miss) is never cached — a stale negative could
      only ever *deny*, so misses always re-read the DB. This makes the cache
      unable to serve a stale DENY where a fresh read would allow.
    * **Explicit invalidation.** Writers (scope create/update/delete, key
      update/revoke, OAuth client config/revoke) call `bump/0`, which bumps a
      generation and drops every entry — no key bookkeeping on the write side.
    * **Short TTL.** Entries expire after `:mcp_toolset_cache_ttl_ms`
      (default 45s) even without a bump, as the backstop for out-of-band writes.

  Tests disable the cache via `:mcp_toolset_cache_enabled, false` (config/test.exs)
  so suites stay hermetic; cache-specific tests opt in with `enable/0` + `flush/0`.

  Concurrency note: `fetch/3` fill is a read-modify-write of the single term, so
  two concurrent misses can lose one fill. Harmless — the loser refills on its
  next fetch.
  """

  @key :noizu_prompt_lingua_mcp_toolset_cache

  @doc "Cached read. `loader/0` runs only on a miss/expiry; its `nil` result is never cached."
  @spec fetch(term(), term(), (-> value)) :: value when value: term()
  def fetch(kind, id, loader) do
    if enabled?() do
      now = System.monotonic_time(:millisecond)
      {gen, entries} = :persistent_term.get(@key, {0, %{}})

      case Map.get(entries, {kind, id}) do
        {^gen, expires_at, value} when expires_at > now ->
          value

        _ ->
          value = loader.()

          if is_nil(value) do
            value
          else
            {cur_gen, cur_entries} = :persistent_term.get(@key, {0, %{}})
            :persistent_term.put(@key, {cur_gen, Map.put(cur_entries, {kind, id}, {cur_gen, now + ttl_ms(), value})})
            value
          end
      end
    else
      loader.()
    end
  end

  @doc """
  Invalidate EVERYTHING (generation bump). Called by the scope / api-key /
  OAuth-client write paths after a successful write.
  """
  @spec bump() :: :ok
  def bump do
    {gen, _} = :persistent_term.get(@key, {0, %{}})
    :persistent_term.put(@key, {gen + 1, %{}})
    :ok
  end

  @doc "Hard reset (generation 0, no entries). Test helper."
  @spec flush() :: :ok
  def flush do
    :persistent_term.put(@key, {0, %{}})
    :ok
  end

  @doc "Opt-in helper for cache-specific tests (global state — pair with `flush/0` in `on_exit`)."
  @spec enable() :: :ok
  def enable do
    Application.put_env(:noizu_prompt_lingua, :mcp_toolset_cache_enabled, true)
  end

  defp enabled?, do: Application.get_env(:noizu_prompt_lingua, :mcp_toolset_cache_enabled, true)

  defp ttl_ms, do: Application.get_env(:noizu_prompt_lingua, :mcp_toolset_cache_ttl_ms, 45_000)
end
