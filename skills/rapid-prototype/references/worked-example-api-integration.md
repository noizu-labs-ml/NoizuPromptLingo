# Worked Example: Third-Party Weather API Integration

A complete walkthrough of the trl-rapid-prototype process, evaluating whether a weather API meets latency and reliability requirements for a real-time dashboard feature.

---

## Context

A team is building a logistics dashboard. They want to show real-time weather alerts for delivery routes. The question: "Can the OpenWeatherMap API serve our latency and data requirements, or do we need a more expensive provider?"

---

## Phase 1: Frame

### Hypothesis

> We believe that the OpenWeatherMap free-tier API can deliver route-relevant weather alerts with < 500ms latency and sufficient geographic granularity, which would enable the weather overlay feature without additional SaaS cost.

### Success Criteria

| Criterion | Threshold | Measurement |
|-----------|-----------|-------------|
| Response latency | < 500ms p95 | Time 50 sequential requests |
| Geographic granularity | Zip-code level | Query multiple points along a route |
| Data freshness | < 30 min delay | Compare API timestamp to current time |
| Rate limit headroom | > 60 req/min on free tier | Hit API at max rate, observe throttling |

### Timebox

**1.5 hours** (trivial-to-moderate complexity — single API, clear criteria)

### Anti-Scope
- No UI rendering of weather data
- No route-planning integration
- No error handling or retry logic
- No caching layer
- No authentication beyond hardcoded API key

---

## Phase 2: Spike

### Code (Python — chosen for speed)

```python
import requests
import time
import statistics

API_KEY = "hardcoded-free-tier-key-here"
BASE_URL = "https://api.openweathermap.org/data/2.5/weather"

# Test points along a Chicago-to-Detroit route
TEST_COORDS = [
    (41.8781, -87.6298),  # Chicago
    (41.9742, -87.9073),  # Elmhurst
    (42.0334, -87.2343),  # Waukegan area
    (42.2711, -83.7263),  # Ann Arbor
    (42.3314, -83.0458),  # Detroit
]

# Latency test: 50 requests
latencies = []
for i in range(50):
    coord = TEST_COORDS[i % len(TEST_COORDS)]
    start = time.time()
    resp = requests.get(BASE_URL, params={
        "lat": coord[0], "lon": coord[1],
        "appid": API_KEY, "units": "imperial"
    })
    elapsed = (time.time() - start) * 1000
    latencies.append(elapsed)
    print(f"Request {i+1}: {elapsed:.0f}ms - status {resp.status_code}")
    if resp.status_code == 429:
        print("RATE LIMITED")
        break

print(f"\nLatency p50: {statistics.median(latencies):.0f}ms")
print(f"Latency p95: {sorted(latencies)[int(len(latencies)*0.95)]:.0f}ms")
print(f"Latency max: {max(latencies):.0f}ms")

# Data freshness check
import json
from datetime import datetime, timezone

resp = requests.get(BASE_URL, params={
    "lat": 41.8781, "lon": -87.6298,
    "appid": API_KEY, "units": "imperial"
})
data = resp.json()
api_time = datetime.fromtimestamp(data["dt"], tz=timezone.utc)
now = datetime.now(timezone.utc)
freshness = (now - api_time).total_seconds() / 60
print(f"\nData freshness: {freshness:.1f} minutes old")
print(f"Weather: {data['weather'][0]['description']}")
print(f"Temp: {data['main']['temp']}F")

# Geographic granularity — compare nearby points
for lat, lon in TEST_COORDS:
    resp = requests.get(BASE_URL, params={
        "lat": lat, "lon": lon,
        "appid": API_KEY, "units": "imperial"
    })
    d = resp.json()
    print(f"({lat}, {lon}) -> {d['name']}: {d['weather'][0]['description']}, {d['main']['temp']}F")
```

### Raw Observations

**Latency:** p50 = 180ms, p95 = 340ms, max = 520ms. One outlier at 520ms, rest well under 500ms.

**Rate limiting:** No 429s in 50 requests at ~2 req/sec. Free tier docs say 60 req/min — we're within that.

**Freshness:** Data was 12 minutes old. Acceptable.

**Geographic granularity:** Each coordinate returned a different city name and potentially different weather. However, two nearby points (5 miles apart) returned the same station data. Granularity is station-level, not coordinate-level.

### Halfway Checkpoint (at 45 min)

Signal: **Converging.** Core question is answerable. Latency and freshness look good. Geographic granularity is the interesting finding — it's not as granular as expected but may be sufficient.

Decision: **Continue** to complete rate limit stress test.

---

## Phase 3: Evaluate

| Dimension | Score | Evidence |
|-----------|-------|---------|
| Technical Feasibility | 5 | API works exactly as documented, data format is clean JSON |
| Performance | 4 | p95 = 340ms, well under 500ms threshold. One outlier at 520ms — acceptable for non-critical overlay |
| Complexity | 5 | Production version is straightforward: add caching, error handling, and config. Maybe 2-3 days. |
| Integration | 4 | JSON response maps cleanly to our data model. Need a thin adapter for coordinate-to-weather mapping. |
| Maintainability | 4 | Well-documented API, large community, stable provider. Free tier limitations are clear. |
| Dependencies | 3 | Free tier has 60 req/min limit. With 50 routes active, we'd need ~50 req/min for 5-min refresh. Tight. Paid tier ($40/mo) gives 1000 req/min. |
| **Average** | **4.2** | |

---

## Phase 4: Recommend

### Recommendation: GO WITH CONDITIONS

**Condition:** Budget approval for paid tier ($40/month) if route count exceeds 10 active routes. Free tier works for MVP but will hit rate limits at scale.

### Key Findings
1. Latency is well within requirements (p95 = 340ms vs 500ms threshold)
2. Geographic granularity is station-level, not coordinate-level — weather data may be identical for route points within ~10 miles of each other. Acceptable for weather alerts but won't show hyper-local conditions.
3. Free tier rate limit (60 req/min) is the main constraint. With aggressive caching (cache by station, not by coordinate), we can serve ~30 routes on free tier.

### Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| Rate limit hit at scale | Medium | Implement station-based caching; budget for paid tier |
| API latency spike during weather events | Low | Circuit breaker + stale-data fallback |
| Provider deprecation | Low | Adapter pattern makes provider swap straightforward |

### Next Steps
1. Implement station-based caching layer (dedup nearby coordinates)
2. Build adapter mapping route coordinates to weather data
3. Get budget approval for paid tier as a contingency
4. Estimated production timeline: 1 week

---

## Artifacts
- `weather_spike.py` — The spike script above
- This report

---

## Meta-Commentary

This prototype took **1.5 hours total** (45 min spike, 25 min eval, 20 min report). The most valuable finding was the geographic granularity limitation — something not obvious from reading docs alone. The rate limit constraint was predictable but quantifying it against actual route counts made the paid-tier decision concrete rather than hypothetical.

Without the structured evaluation, the team might have said "it works!" and been surprised by rate limiting at scale. The framework forced the conversation about dependencies that led to the caching recommendation.
