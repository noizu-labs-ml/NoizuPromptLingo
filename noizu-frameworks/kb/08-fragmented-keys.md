# fragmented_keys (0.1.0)

Cache invalidation via composite keys built from independently versioned tags.

## Installation
```elixir
{:fragmented_keys, "~> 0.1.0"}
# Optional: {:redix, "~> 1.5"} for Redis backend
```

## Core Concept

Cache keys are composed from multiple versioned "tags." When any tag's version changes, the composite key hash changes, effectively invalidating all dependent cache entries — without bulk deletes.

```
Key = MD5("KeyName_GroupID:tTag1:vVer1:tTag2:vVer2...")
```

## Quick Start

```elixir
# 1. Set up handler
handler = FragmentedKeys.CacheHandler.Memory.new()
FragmentedKeys.Configuration.set_default_cache_handler(handler)

# 2. Create tags
tag_user = FragmentedKeys.Tag.Standard.new("User", "42")
tag_city = FragmentedKeys.Tag.Standard.new("City", "chicago")

# 3. Build composite key
key = FragmentedKeys.Key.new("Dashboard", [tag_user, tag_city])
key_str = FragmentedKeys.Key.get_key_str(key)  # => "a1b2c3..." (MD5)

# 4. Invalidate
FragmentedKeys.Tag.increment(tag_user)
# Now Dashboard key for user 42 produces a DIFFERENT hash
```

## Tag Types

### Standard Tag
```elixir
tag = FragmentedKeys.Tag.Standard.new(tag_name, instance, opts \\ [])
FragmentedKeys.Tag.get_tag_version(tag)    # Current version
FragmentedKeys.Tag.increment(tag)          # Bump version → invalidate
FragmentedKeys.Tag.reset_tag_version(tag)  # Reset to microtime
FragmentedKeys.Tag.set_tag_version(tag, version, update_store)
```

### Constant Tag
```elixir
tag = FragmentedKeys.Tag.Constant.new(tag_name, instance, version)
# Version never changes — increment/reset are no-ops
# Use for site-wide settings, global constants
```

## KeyRing (Template Factory)

```elixir
ring = FragmentedKeys.KeyRing.new(
  cache_handlers: %{"memory" => handler},
  default_cache_handler: "memory",
  global_tag_options: %{"site" => %{"type" => "constant", "version" => 1.0}}
)

ring = FragmentedKeys.KeyRing.define_key(ring, "UserProfile", ["site", "user", "region"])
key = FragmentedKeys.KeyRing.get_key_obj(ring, "UserProfile", ["MilkyWay", "42", "US"])
key_str = FragmentedKeys.Key.get_key_str(key)
```

## CacheHandler Protocol

```elixir
# Protocol callbacks
FragmentedKeys.CacheHandler.group_name(handler)
FragmentedKeys.CacheHandler.get(handler, key)
FragmentedKeys.CacheHandler.set(handler, key, value, ttl)
FragmentedKeys.CacheHandler.get_multi(handler, keys)  # Bulk fetch optimization
```

### Built-in Handlers
- `FragmentedKeys.CacheHandler.Memory` — Agent-backed, in-memory (dev/test)
- `FragmentedKeys.CacheHandler.Redis` — Redix-backed, uses MGET/MSET for bulk ops

## Key Concepts
1. **Version-based invalidation** — No bulk deletes needed, old entries expire naturally
2. **Composite keying** — Keys depend on multiple independent dimensions
3. **Bulk fetch optimization** — Tags grouped by handler, fetched via `get_multi` in single round-trip
4. **Constant tags** — Fixed dimensions that never change (environment, site)
5. **KeyRing templates** — Reusable key patterns with parameterized tag values
