# Kino.ETS

Interactive ETS table inspection and monitoring for LiveBook notebooks.

## Description

Kino.ETS provides real-time visualization of Erlang Term Storage (ETS) tables within LiveBook. Part of the core Kino library, it displays table contents, metadata, and statistics with live updates for monitoring table changes.

**Documentation**: [hexdocs.pm/kino/Kino.ETS.html](https://hexdocs.pm/kino/Kino.ETS.html)

## Installation

Built-in with Kino. No additional dependencies required.

```elixir
# Already available in LiveBook
```

## Basic Usage

```elixir
# Create and populate an ETS table
table = :ets.new(:sample_table, [:set, :public])
:ets.insert(table, {:user_1, "Alice", 30})
:ets.insert(table, {:user_2, "Bob", 25})
:ets.insert(table, {:user_3, "Carol", 35})

# Display table contents
Kino.ETS.new(table)
```

```elixir
# Monitor existing table by name
:ets.new(:stats, [:named_table, :public])
:ets.insert(:stats, {:requests, 1245})
:ets.insert(:stats, {:errors, 12})

Kino.ETS.new(:stats)
```

```elixir
# With refresh interval for live monitoring
Kino.ETS.new(:stats, refresh: 1000)  # Update every second
```

## Strengths

- **Live Updates**: Real-time table monitoring with configurable refresh
- **Table Introspection**: Shows metadata, size, memory usage
- **Zero Configuration**: Works with any ETS table immediately
- **Debug-Friendly**: Perfect for troubleshooting ETS operations
- **Memory Efficient**: Only displays table references, not full data

## Limitations

- **LiveBook Only**: Cannot be used outside notebook environment
- **Performance Impact**: Frequent refresh can affect table performance
- **Read-Only View**: No table modification capabilities
- **Large Table Handling**: May become slow with very large tables

## Best Use Cases

- **Debugging**: Inspecting ETS table state during development
- **Monitoring**: Real-time observation of cache or state tables
- **Learning**: Understanding ETS behavior and operations
- **Performance Analysis**: Watching table growth and access patterns

## NPL-FIM Integration

```npl
⟪kino-ets-fim⟫
↦ context: LiveBook ETS table inspection
↦ input: ETS table reference or name
↦ output: interactive table viewer with metadata
↦ constraints: LiveBook environment, ETS table access
⟫
```

**FIM Pattern**: Table → Inspect → Monitor
- **Table**: ETS table reference or named table
- **Inspect**: Display contents and metadata
- **Monitor**: Live updates for table changes

**Integration Points**:
- Cache monitoring in web applications
- State table debugging in GenServers
- Performance analysis of ETS usage
- Educational demonstrations of ETS concepts