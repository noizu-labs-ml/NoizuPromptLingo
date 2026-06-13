# Performance Profiling on macOS

## Instruments Overview

Open Instruments: Xcode → Product → Profile (Cmd+I), or `open -a Instruments`.

Key workflow: run target with profiling build (Release config, debug info on), record, identify hot paths, fix, re-profile.

Build settings for useful profiles:
- Debug Information Format: DWARF with dSYM
- Optimization Level: use Release (Same as shipping)
- Strip Debug Symbols: No (for profiling only)

---

## Time Profiler

Best for: CPU hotspots, slow main thread, excessive work.

- Record while reproducing the slow scenario
- Focus on "Heaviest Stack Trace" in the detail pane
- Filter to your module: uncheck "Hide System Libraries" to see full call chain
- Look for unexpectedly large self-time percentages

Key indicators:
- Main thread > 16ms per frame → UI jank
- Large self-time in JSON decode, image resize, string ops → optimize or move off-thread

Moving work off main thread:
```swift
Task.detached(priority: .utility) {
    let result = await heavyComputation()
    await MainActor.run { self.result = result }
}
```

---

## Allocations

Best for: memory growth, excessive object churn, retain cycles.

- Use "Mark Generation" to snapshot baseline, interact, snapshot again — see net allocations
- Filter by category: look for unexpectedly large counts of your types
- "Allocation List" → drill into specific allocations → see creation call stack

Common issues:
- `Data` copies in a loop — reuse buffers
- `String` interpolation in tight loops — use `OSLog` structured logging instead
- Image data held in cache — cap NSCache `totalCostLimit`

```swift
// Cap image cache
let cache = NSCache<NSString, NSImage>()
cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
cache.countLimit = 100
```

---

## Leaks

Best for: objects that are never freed (retain cycles, delegate cycles).

- Record → click Leaks instrument → red bars indicate leaks
- Drill into leaked object → "Root" column shows why it's retained
- Common culprit: `[weak self]` missing in closures

```swift
// Bad
timer = Timer.scheduledTimer(withTimeInterval: 1) { _ in
    self.update() // retains self
}

// Good
timer = Timer.scheduledTimer(withTimeInterval: 1) { [weak self] _ in
    self?.update()
}
```

---

## Energy Impact

Best for: battery drain — excessive wakeups, high CPU on idle, unnecessary I/O.

Instruments → Energy Log. Key signals:
- CPU activity when app is backgrounded
- Timer wakeup rate (target < 1/second when idle)
- Network activity patterns

Recommendations:
- Coalesce network requests — batch rather than per-event
- Use `NSBackgroundActivityScheduler` for deferred work
- Avoid polling; prefer notifications/KVO/Combine publishers

```swift
let activity = NSBackgroundActivityScheduler(identifier: "com.example.sync")
activity.repeats = true
activity.interval = 15 * 60 // 15 minutes
activity.schedule { completion in
    Task { await self.syncData(); completion(.finished) }
}
```

---

## Hang Detection

macOS 12+ reports main-thread hangs > 250ms in Xcode Organizer and crash logs.

In Instruments: **Hangs** template (macOS 14+). Shows hang duration, blocking call stacks.

Common causes:
- Synchronous I/O on main thread
- `DispatchSemaphore.wait()` or `Task { ... }.value` (blocking async on main)
- Deadlock in `@MainActor` code calling `async let`

```swift
// Bad: blocks main thread
let data = try Data(contentsOf: url) // synchronous I/O

// Good
let data = try await URLSession.shared.data(from: url).0
```

Xcode Organizer → Hang Rates tab: aggregate hang data from consented users (macOS 12+, requires App Store or TestFlight distribution).

---

## Network Profiler

Instruments → Network template. Shows:
- Request/response timeline
- DNS resolution time
- TCP handshake, TLS negotiation
- Transfer size and duration

Also use Charles Proxy or `nettop` in Terminal for live inspection:
```bash
nettop -p <pid>         # per-process network I/O
```

For URLSession debugging:
```swift
let config = URLSessionConfiguration.default
config.waitsForConnectivity = true
config.timeoutIntervalForRequest = 30
```

---

## File Activity

Instruments → File Activity. Shows syscalls: `open`, `read`, `write`, `mmap`, `stat`.

Key questions:
- Is the app reading the same file repeatedly? → Cache it.
- Large sequential reads on main thread? → Move to background, use `FileHandle` async reads.
- Excessive `stat` calls in directory enumeration? → Use `FileManager.enumerator` with resource keys pre-fetched.

```swift
let keys: [URLResourceKey] = [.fileSizeKey, .contentModificationDateKey]
let enumerator = FileManager.default.enumerator(
    at: dirURL,
    includingPropertiesForKeys: keys,
    options: .skipsHiddenFiles
)
```

---

## os_signpost

Add custom timing markers visible in Instruments (Time Profiler, Custom Instruments):

```swift
import os.signpost

let log = OSLog(subsystem: "com.example.myapp", category: .pointsOfInterest)
let signpost = OSSignposter(logHandle: log)

// Interval
let state = signpost.beginInterval("ProcessImages", id: signpost.makeSignpostID())
defer { signpost.endInterval("ProcessImages", state) }

// Event
signpost.emitEvent("CacheHit", "key: %{public}s", cacheKey)
```

In Instruments, enable "Points of Interest" track to see your signposts correlated with CPU/allocations.

---

## Memory Graph Debugger

In Xcode (not Instruments): run app → Debug Navigator → Memory graph icon (or Debug → Memory Graph).

Shows object graph: reference paths, retain counts, cycles. Right-click an object → "Focus on retain cycle."

Enable malloc stack logging for full allocation backtraces:
```
Edit Scheme → Diagnostics → Malloc Stack: All Allocations
```

---

## XCTMetric (Performance Tests)

```swift
func testRenderPerformance() {
    let metrics: [XCTMetric] = [
        XCTClockMetric(),
        XCTMemoryMetric(),
        XCTCPUMetric(),
        XCTStorageMetric()
    ]
    measure(metrics: metrics) {
        renderChart(data: sampleData)
    }
}
```

Baselines stored per-machine in `.xcresult`. CI: use `XCTClockMetric` with `XCTMeasureOptions.invocationOptions = [.manuallyStart]` for precise measurement windows.

---

## Profiling Checklist

- [ ] Profile Release build, not Debug (different optimizer behavior)
- [ ] Reproduce realistic workload during recording (not synthetic micro-benchmarks)
- [ ] Time Profiler: check main thread is not > 16ms busy during animations
- [ ] Allocations: no unbounded growth over a typical session
- [ ] Leaks: zero leaks after typical use
- [ ] Energy: CPU usage drops to ~0% when app is idle/backgrounded
- [ ] Hangs: Organizer shows 0 hang rate
- [ ] Use `os_signpost` to mark key operations before profiling
