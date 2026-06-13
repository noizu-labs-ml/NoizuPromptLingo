# Worked Example: Database Benchmark

End-to-end walkthrough of "Is SQLite faster than PostgreSQL for our read-heavy workload?"

## Phase 1: Question Formation

**Raw question:** "Our API is slow. Would switching to SQLite be faster since we're mostly reading?"

**Scoping:**
- Current: PostgreSQL 16 on a dedicated server
- Workload: 90% reads, 10% writes. ~500 req/s peak.
- Data: ~2GB, 15 tables, largest table 5M rows
- Reads: Single-row lookups by primary key (60%), filtered queries on indexed columns (30%), aggregations (10%)
- Pain point: p99 latency spikes during peak hours

**Structured question:** "For our specific workload (90% reads, 500 req/s, 2GB data), does an embedded SQLite database deliver lower p99 latency than PostgreSQL via network connection?"

**Prior art:** SQLite excels at embedded read-heavy workloads. But: no connection pooling, single-writer limitation, different concurrency model. Key variable is likely network overhead elimination vs concurrency handling.

## Phase 2: Hypothesis Formation

**H1:** SQLite will deliver lower p99 read latency (by ≥ 30%) compared to PostgreSQL for our workload profile, at the cost of higher p99 write latency.

**H0:** There is no meaningful latency difference between SQLite and PostgreSQL for this workload.

**Variables:**
- **IV:** Database engine (PostgreSQL via TCP vs SQLite embedded)
- **DV:** p50, p95, p99 latency for reads and writes; throughput (req/s)
- **Controlled:** Hardware, OS, data, query patterns, connection count
- **Confounds:** Query planner differences, index implementation differences, WAL configuration

**Success criteria:**
- Read p99 latency reduction ≥ 30%
- Write p99 latency degradation ≤ 100% (acceptable tradeoff)
- Throughput at 500 req/s sustained without errors

## Phase 3: Experiment Design

**Method:** Controlled benchmark with production-representative workload.

**Protocol:**
1. Create identical schemas and data in both databases
2. Write a benchmark harness that replays production query patterns
3. Run identical workload against each database
4. Measure latency at p50/p95/p99 and throughput

**Environment:**
- Same machine for both (M2 MacBook Pro, 16GB RAM)
- PostgreSQL: localhost TCP connection, connection pool of 10
- SQLite: WAL mode, same process, busy_timeout 5000ms
- Data: Production snapshot (2.1GB, anonymized)
- Load: 500 req/s sustained for 10 minutes after 2-min warm-up

**Runs:** 5 full runs per configuration, report median + range.

## Phase 4: Data Collection

**Collection log:**
- Runs 1-5 PostgreSQL: Clean, no anomalies. Consistent results.
- Runs 1-5 SQLite: Run 3 showed writer starvation under concurrent writes. Noted as expected behavior. Other runs clean.
- Deviation: SQLite run 3 write p99 was 3x higher than other runs (writer contention). Included in results but flagged.

## Phase 5: Analysis

### Read Performance

| Metric | PostgreSQL | SQLite | Difference |
|--------|-----------|--------|-----------|
| p50 latency | 1.2ms | 0.3ms | -75% |
| p95 latency | 3.8ms | 0.8ms | -79% |
| p99 latency | 12.4ms | 1.9ms | -85% |
| Max latency | 45ms | 8ms | -82% |

### Write Performance

| Metric | PostgreSQL | SQLite | Difference |
|--------|-----------|--------|-----------|
| p50 latency | 2.1ms | 1.8ms | -14% |
| p95 latency | 5.2ms | 8.4ms | +62% |
| p99 latency | 15.1ms | 34.2ms | +126% |
| Max latency | 38ms | 210ms | +453% |

### Throughput

| Metric | PostgreSQL | SQLite |
|--------|-----------|--------|
| Sustained req/s | 500 (no errors) | 500 (no errors) |
| Max req/s | 2,800 | 4,200 (reads) / 180 (writes) |

### Interpretation

**H1 partially supported.** SQLite read latency is dramatically lower (85% at p99), far exceeding the 30% threshold. However, write p99 is 126% higher — exceeding the 100% acceptable degradation threshold.

The write contention issue (run 3) reveals a real risk: under concurrent write pressure, SQLite's single-writer model causes severe tail latency spikes.

**Confidence:** Medium. The read improvement is unambiguous. The write degradation is borderline and could worsen under higher concurrent write loads than tested.

**Recommendation:** Viable if:
1. Writes are batched or serialized (avoiding concurrent write contention)
2. Write latency SLA is relaxed (or writes moved to a queue)
3. A fallback plan exists if write patterns change

## Phase 6: Publication

**Format:** Technical report for engineering team + KB entry for future reference.

**KB Entry:**

> **Finding:** SQLite delivers 75-85% lower read latency than PostgreSQL for embedded single-server workloads under 5GB, but write p99 degrades 126% due to single-writer limitation.
> **Applies when:** Read-heavy (>80%), single server, data < 10GB, writes can be serialized.
> **Does NOT apply when:** Concurrent writes required, multi-server, data > 10GB, need replication.
> **Confidence:** Medium (single-machine benchmark, not production validation).
