defmodule NoizuPromptLingua.Cache do
  @moduledoc """
  Thin cache-aside wrapper over `NoizuPromptLingua.Redis` (Redix).

  Intentionally simple: string keys, string values, a TTL, no tagging.
  Used for lightweight lookups such as org slug → UUID resolution, where a
  stale or absent entry is cheap to recompute.
  """

  alias NoizuPromptLingua.Redis

  @default_ttl 3_600

  @doc """
  Cache-aside fetch.

  Reads `key` from Redis; on a hit returns `{:ok, value}`. On a miss it runs
  `loader_fn./0`, stores a successful result with the given TTL, and returns it.
  Misses (`{:error, :not_found}` or `nil` from the loader) are returned but
  **not** cached.
  """
  def fetch(key, loader_fn, ttl \\ @default_ttl) do
    case get(key) do
      {:ok, value} when is_binary(value) ->
        {:ok, value}

      _ ->
        case loader_fn.() do
          {:ok, value} ->
            put(key, value, ttl)
            {:ok, value}

          {:error, :not_found} = err ->
            err

          nil ->
            {:error, :not_found}
        end
    end
  end

  def get(key) do
    case Redis.get(key) do
      {:ok, nil} -> {:error, :not_found}
      {:ok, value} -> {:ok, value}
      other -> other
    end
  end

  def put(key, value, ttl \\ @default_ttl) do
    Redis.set(key, value, ex: ttl)
  end

  def invalidate(key) do
    Redis.del(key)
  end

  @doc "Namespaced key for an org slug → UUID entry."
  def slug_key(slug), do: "org:slug:#{slug}"
end
