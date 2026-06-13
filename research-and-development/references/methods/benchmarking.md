# Benchmarking

Performance comparison methodology for technical systems.

## When to Use

- Comparing performance of technologies, frameworks, or configurations
- Measuring throughput, latency, memory, or resource consumption
- Making build-vs-buy or technology selection decisions
- Validating optimization efforts

## Design Principles

1. **Isolate the variable** — Change one thing at a time
2. **Control the environment** — Same hardware, same load, same data
3. **Warm up first** — JIT compilation, caches, connection pools need time to stabilize
4. **Measure what matters** — Latency percentiles (p50, p95, p99), not just averages
5. **Run long enough** — GC pauses, background tasks, and thermal throttling need time to appear

## Benchmark Protocol

```markdown
### Environment
- **Hardware:** [CPU, RAM, storage type]
- **OS:** [name + version]
- **Runtime:** [language version, VM settings, flags]
- **Data:** [dataset size, characteristics]
- **Load:** [concurrent users/requests, ramp pattern]

### Warm-up
- [N] iterations discarded before measurement
- [Duration] warm-up period

### Measurement
- [N] iterations measured
- [Duration] measurement window
- [Repetitions] full runs repeated

### Controls
- [What was held constant between configurations]
- [What changed between configurations]
```

## Key Metrics

| Metric | What It Measures | How to Report |
|--------|-----------------|---------------|
| **Throughput** | Operations per second | Mean + std dev |
| **Latency** | Time per operation | p50, p95, p99, max |
| **Memory** | Peak/average consumption | Peak RSS, heap |
| **CPU** | Processor utilization | Average %, per-core |
| **Startup time** | Time to first response | Mean + std dev |
| **Cold vs warm** | Cache/JIT impact | Both, separately |

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| No warm-up | JIT/cache effects skew early results | Discard first N iterations |
| Averages only | Hides tail latency | Report percentiles |
| One run | No confidence in results | Minimum 3 runs, report variance |
| Benchmarking in dev | Background processes, debuggers | Use dedicated/isolated environment |
| Wrong dataset | Not representative of production | Use production-like data |
| Micro-benchmark only | Doesn't predict system behavior | Include macro/integration benchmarks |
| Thermal throttling | Performance degrades over time | Monitor CPU frequency during runs |

## Results Template

```markdown
### Benchmark: [Title]

| Configuration | Throughput (ops/s) | p50 (ms) | p95 (ms) | p99 (ms) | Memory (MB) |
|--------------|-------------------|----------|----------|----------|-------------|
| [Config A] | [mean ± std] | [val] | [val] | [val] | [peak] |
| [Config B] | [mean ± std] | [val] | [val] | [val] | [peak] |
| **Difference** | [% change] | [%] | [%] | [%] | [%] |

**Runs:** [N] | **Duration:** [per run] | **Environment:** [summary]
**Winner:** [Config X] for [metric] by [margin]
**Caveat:** [any conditions that could change the outcome]
```
