# Performance Profiling for iOS

Practical guide to finding and fixing performance problems in iOS apps.
Covers Instruments, memory management, SwiftUI optimization, network
performance, and binary size reduction.

---

## Instruments Overview

Instruments is Xcode's profiling toolkit. Launch via Product > Profile (Cmd+I)
or open Instruments.app directly.

### Key Instruments

| Instrument | What It Finds | When to Use |
|-----------|---------------|-------------|
| Time Profiler | CPU bottlenecks, hot functions | App feels slow or unresponsive |
| Allocations | Memory growth, abandoned memory | Memory usage climbs over time |
| Leaks | Retain cycles, leaked objects | Memory never freed |
| Energy Log | CPU/GPU/network energy impact | Battery drain complaints |
| Network | HTTP traffic, latency, payload size | Slow data loading |
| Core Animation | Offscreen rendering, blending | Scroll jank, animation stutter |
| Hangs | Main thread blocks >250ms | UI freezes |
| SwiftUI | View body evaluations, identity changes | SwiftUI-specific perf issues |

### Profiling Workflow

1. **Profile on a real device** — simulator performance is not representative
2. **Use Release configuration** — Debug builds have overhead that skews results
3. **Reproduce the problem** — navigate to the slow screen, trigger the action
4. **Record for 10-30 seconds** — capture enough data without drowning in noise
5. **Analyze the heaviest stack traces** — sort by weight, drill into call trees

### Time Profiler Tips

```
Record > Navigate to slow screen > Stop
Call Tree options:
  [x] Separate by Thread
  [x] Invert Call Tree
  [x] Hide System Libraries
```

Inverting the call tree shows leaf functions first — the actual work being done.
This is almost always what you want.

---

## Launch Time Optimization

App launch is the first impression. Apple measures two phases:

### Pre-main (before main() executes)

Affected by:
- Number of dynamic frameworks loaded
- Objective-C class registration (+load methods)
- Static initializers

**Optimizations:**
- Reduce dynamic framework count (merge small frameworks)
- Eliminate +load methods; use +initialize lazily
- Avoid static initializers in Swift (rare, but watch for C++ interop)
- Use `DYLD_PRINT_STATISTICS=1` environment variable to measure

### Post-main (main() to first frame rendered)

Affected by:
- App delegate setup work
- Initial view controller construction
- Network requests blocking UI
- Database migrations

**Optimizations:**
- Defer non-essential work (analytics, prefetching) to after first frame
- Use background queues for heavy initialization
- Lazy-load view controllers not immediately visible
- Cache last-known state for instant UI display

### Measuring Launch Time

```swift
// In App delegate or @main struct
let launchStart = CFAbsoluteTimeGetCurrent()

// After first view appears
let launchEnd = CFAbsoluteTimeGetCurrent()
let launchTime = launchEnd - launchStart
os_log("Launch time: %.3f seconds", launchTime)
```

Xcode Organizer shows real-world launch time percentiles from user devices.

**Targets:**
- Cold launch: under 2 seconds
- Warm launch: under 1 second
- Resume: under 0.5 seconds

---

## Memory Management

### ARC Fundamentals

Swift uses Automatic Reference Counting. Each strong reference increments
the count; when it hits zero, the object is deallocated.

**Common retain cycle patterns:**

```swift
// PROBLEM: closure captures self strongly
class ViewModel: ObservableObject {
    var timer: Timer?

    func startPolling() {
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            self.refresh()  // strong capture — ViewModel never deallocates
        }
    }
}

// FIX: weak capture
timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
    self?.refresh()
}
```

### Retain Cycle Detection

1. **Instruments > Leaks** — run the app, navigate through screens, check for leaks
2. **Memory Graph Debugger** — Xcode debug bar > memory icon > inspect object graph
3. **deinit logging** — add `deinit { print("ViewModel deallocated") }` during development

### Weak vs Unowned

| Keyword | When to Use | Behavior on Dealloc |
|---------|-------------|---------------------|
| `weak` | Reference may outlive the object | Becomes `nil` (must be optional) |
| `unowned` | Reference always shorter-lived | Crash if accessed after dealloc |

**Default to `weak`.** Use `unowned` only when you can prove the lifetime
relationship (e.g., a child that cannot outlive its parent).

### Value Types for Memory Safety

Prefer structs over classes when possible. Structs are stack-allocated (usually),
have no reference counting overhead, and cannot form retain cycles.

---

## SwiftUI Performance

### View Body Evaluation

SwiftUI calls `body` whenever state changes. Expensive body computations
cause frame drops.

**Measure evaluations:**

```swift
var body: some View {
    let _ = Self._printChanges()  // Debug only — prints what triggered re-evaluation
    VStack {
        // ...
    }
}
```

### Lazy Views

```swift
// BAD: creates all 10,000 rows immediately
ScrollView {
    VStack {
        ForEach(items) { item in
            RowView(item: item)
        }
    }
}

// GOOD: creates rows on demand
ScrollView {
    LazyVStack {
        ForEach(items) { item in
            RowView(item: item)
        }
    }
}
```

Use `LazyVStack`, `LazyHStack`, `LazyVGrid`, `LazyHGrid` for scrollable content.

### Equatable Conformance

SwiftUI skips body evaluation if the view's inputs haven't changed. Help it
by conforming to `Equatable`:

```swift
struct ItemRow: View, Equatable {
    let item: Item

    static func == (lhs: ItemRow, rhs: ItemRow) -> Bool {
        lhs.item.id == rhs.item.id && lhs.item.title == rhs.item.title
    }

    var body: some View {
        HStack {
            Text(item.title)
            Spacer()
            Text(item.price, format: .currency(code: "USD"))
        }
    }
}
```

### Task Modifiers

Use `.task` for async work tied to view lifecycle. It cancels automatically
on disappear.

```swift
struct ProfileView: View {
    @State private var user: User?

    var body: some View {
        content
            .task {
                user = try? await UserService.fetch()
            }
    }
}
```

Avoid `onAppear` with `Task { }` — it does not cancel on disappear and can
cause work to pile up during rapid navigation.

### Observable Granularity (iOS 17+)

With `@Observable`, SwiftUI tracks property-level access. Only views that
read a changed property re-evaluate.

```swift
@Observable
class AppState {
    var user: User?          // Only views reading .user re-evaluate
    var notifications: Int   // Only views reading .notifications re-evaluate
}
```

This is a major improvement over `ObservableObject` where any `@Published`
change triggered all subscribers.

---

## Network Performance

### URLSession Configuration

```swift
let config = URLSessionConfiguration.default
config.timeoutIntervalForRequest = 30
config.timeoutIntervalForResource = 300
config.waitsForConnectivity = true          // Wait for network instead of failing
config.allowsConstrainedNetworkAccess = true // Allow on Low Data Mode (or set false)

let session = URLSession(configuration: config)
```

### Response Caching

```swift
// Use URLCache for HTTP-level caching
let cache = URLCache(
    memoryCapacity: 50 * 1024 * 1024,   // 50 MB memory
    diskCapacity: 200 * 1024 * 1024     // 200 MB disk
)
config.urlCache = cache
config.requestCachePolicy = .returnCacheDataElseLoad
```

Respect `Cache-Control` headers from the server. For API responses, implement
app-level caching with timestamps and staleness checks.

### Image Loading

- Use `AsyncImage` for simple cases (no caching beyond URLCache)
- Use a library (Kingfisher, Nuke) for production image loading with disk cache
- Resize images to display size before rendering — never load a 4000px image
  for a 100pt thumbnail

---

## Binary Size Optimization

Large binaries slow downloads, increase launch time, and hit the 200 MB
cellular download limit.

### Measuring

```bash
# After archive, check the .app size
du -sh build/MyApp.xcarchive/Products/Applications/MyApp.app

# For detailed breakdown
xcrun swift-stdlib-tool --analyze build/MyApp.xcarchive
```

### Optimization Techniques

| Technique | Impact | Effort |
|-----------|--------|--------|
| Strip debug symbols for release | 10-30% | Low (Xcode default) |
| Enable Link-Time Optimization | 5-15% | Low (build setting) |
| Remove unused code (dead stripping) | 5-20% | Low (build setting) |
| Audit dependencies | Variable | Medium |
| Use Asset Catalogs (not bundled PNGs) | Variable | Medium |
| App Thinning (bitcode, slicing) | 20-40% | Free (Apple handles it) |
| On-demand resources | Variable | High |

### Build Settings for Size

```
DEAD_CODE_STRIPPING = YES
STRIP_INSTALLED_PRODUCT = YES
SWIFT_COMPILATION_MODE = wholemodule
SWIFT_OPTIMIZATION_LEVEL = -Osize    # Optimize for size over speed
GCC_OPTIMIZATION_LEVEL = -Os
ENABLE_LTO = YES                      # Link-Time Optimization
```

### Dependency Audit

Every SPM package and framework adds binary size. Periodically review:

```bash
# List all resolved dependencies
swift package show-dependencies --format json | jq '.dependencies[].identity'
```

Ask for each dependency: is this worth the size cost? Could a 50-line
implementation replace a 2 MB framework?

---

## Profiling Checklist

```
[ ] Profile on a real device, Release configuration
[ ] Launch time under 2 seconds (cold) measured in Instruments
[ ] No leaked objects in Leaks instrument after navigation test
[ ] Memory stable during long usage sessions (Allocations)
[ ] No main thread hangs >250ms (Hangs instrument)
[ ] Scroll performance: 60fps in Core Animation instrument
[ ] Network: no redundant requests, caching effective
[ ] Binary size: under 50 MB uncompressed (under 200 MB for cellular)
[ ] Energy impact: no unnecessary background work (Energy Log)
```
