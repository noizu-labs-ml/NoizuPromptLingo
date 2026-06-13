---
name: trl-ios-mobile-engineer
description: >
  Design and implement production-ready iOS mobile applications from concept through
  App Store submission using SwiftUI and Swift. Use this skill when the user wants to
  build an iOS app, design mobile interfaces, implement SwiftUI views, architect a
  mobile application, set up Xcode projects, integrate CloudKit or Firebase or Supabase,
  handle push notifications, implement deep linking, create app widgets, submit to the
  App Store, or optimize App Store listings — even if they don't say "iOS" or "mobile."
  Also trigger when users mention SwiftUI, UIKit, Xcode, TestFlight, App Store Connect,
  Core Data, Swift Package Manager, iOS accessibility, mobile navigation patterns,
  MVVM architecture for mobile, or app store optimization.
---

# iOS Mobile Engineer

Design and ship production-ready iOS apps — from first sketch to App Store — with SwiftUI-first architecture and comprehensive backend integration.

## Overview

This skill covers the complete iOS app lifecycle for developers coming from web backgrounds. It translates familiar web concepts (components, routing, state management, API calls) into their iOS equivalents while teaching platform-specific patterns that have no web analog (App Store review, push notifications, widgets, system integrations).

**Core Purpose:**
- Translate web development mental models to iOS/SwiftUI equivalents
- Architect maintainable iOS apps using modern Swift patterns (MVVM, TCA, async/await)
- Implement polished SwiftUI interfaces with animations, accessibility, and adaptive layouts
- Integrate backend services (CloudKit, Firebase, Supabase) with proper offline-first patterns
- Navigate the App Store submission pipeline from TestFlight through public release
- Optimize app performance, binary size, and App Store presence

## Core Philosophy

1. **SwiftUI-first, UIKit when necessary** — Default to declarative SwiftUI for all new views. Drop to UIKit only for capabilities SwiftUI doesn't yet cover (certain camera APIs, complex text editing, MapKit advanced features). Always wrap UIKit in `UIViewRepresentable` to maintain a SwiftUI-native API surface.

2. **Web-to-iOS concept mapping** — Every iOS concept is introduced through its web equivalent. A `NavigationStack` is a router. `@State` is `useState`. `@Observable` is a reactive store. This accelerates comprehension without creating false equivalences — the mapping breaks down at the edges, and the skill teaches where.

3. **Offline-first by default** — Mobile apps lose connectivity. Every data flow assumes intermittent network: local persistence first, sync when available, conflict resolution built in. This is the single biggest mindset shift from web development.

4. **Platform integration over reinvention** — iOS provides system-level features (HealthKit, MapKit, Shortcuts, Widgets, SharePlay) that would take months to build from scratch on web. The skill teaches when to leverage these vs. building custom, and how to integrate them idiomatically.

5. **Ship early via TestFlight** — The App Store review cycle (1-3 days) is unlike web deployment (instant). The skill builds TestFlight distribution into the workflow from day one, so feedback loops stay tight and review rejections surface early.

## When to Use This Skill

- **Building a new iOS app** — Full lifecycle from concept through App Store
- **Porting a web app to iOS** — Translating an existing web application to native mobile
- **Designing mobile-specific UI** — Interfaces that leverage iOS conventions (tab bars, sheets, gestures)
- **Architecting a Swift codebase** — MVVM, TCA, or clean architecture patterns for iOS
- **Integrating backend services** — CloudKit, Firebase, Supabase, or custom REST/GraphQL APIs
- **Submitting to the App Store** — Provisioning, metadata, screenshots, review guidelines
- **Adding iOS-specific features** — Widgets, push notifications, deep links, Shortcuts, Watch complications
- **Performance tuning** — Instruments profiling, memory management, launch time optimization
- **Migrating UIKit to SwiftUI** — Incremental adoption of SwiftUI in an existing UIKit app

> For web UI design principles that translate to mobile, see **trl-user-experience-engineer** (`references/core-philosophy.md`).
> For validating your app idea before building, see **trl-market-intelligence** (`references/niche-discovery.md`).
> For App Store listing optimization (ASO), see **trl-seo-guru** — ASO shares DNA with SEO.
> For packaging app templates as digital products, see **trl-ai-templates** (`references/product-types/`).

## Web-to-iOS Concept Map

| Web Concept | iOS Equivalent | Key Differences |
|-------------|---------------|-----------------|
| React component | SwiftUI `View` | Value type (struct), not class. Re-created on state change. |
| `useState` | `@State` | Scoped to owning view. Use `@Binding` to pass down. |
| Redux/Zustand store | `@Observable` class | No reducers needed. Mutations are direct. SwiftUI auto-tracks. |
| React Context | `@Environment` | System-provided (colorScheme, locale) + custom values. |
| React Router | `NavigationStack` + `NavigationLink` | Value-based routing. Push/pop model, not URL-based. |
| CSS Flexbox | `HStack` / `VStack` / `ZStack` | No CSS. Layout is compositional via view modifiers. |
| CSS Grid | `LazyVGrid` / `LazyHGrid` | Columns defined programmatically. Lazy = virtualized. |
| Media queries | `@Environment(\.horizontalSizeClass)` | Two sizes: compact (phone) and regular (iPad/landscape). |
| `fetch()` / Axios | `URLSession` + `async/await` | Built-in. No npm package needed. Codable for JSON parsing. |
| localStorage | `UserDefaults` / SwiftData | UserDefaults for prefs. SwiftData for structured data. |
| IndexedDB | SwiftData / Core Data | SwiftData is the modern API (iOS 17+). Core Data underneath. |
| Service Worker | Background Tasks / URLSession background | OS-managed. Cannot run arbitrary code in background. |
| PWA install | App Store submission | Binary distribution. Review process. Provisioning profiles. |
| Webpack/Vite | Xcode build system | No config files. Xcode manages everything. SPM for packages. |
| npm | Swift Package Manager (SPM) | Integrated into Xcode. `Package.swift` manifest. |
| Jest/Vitest | XCTest / Swift Testing | XCTest is mature. Swift Testing (iOS 18+) has modern syntax. |
| Playwright/Cypress | XCUITest | UI tests run against simulator. Slower than web E2E. |

## App Architecture Patterns

### Recommended: MVVM + Observable

The default architecture for new SwiftUI apps. Familiar to web developers who've used component + store patterns.

```
View (SwiftUI)          ← Declarative UI, no business logic
  ↕ binds to
ViewModel (@Observable) ← Business logic, state management, data transformation
  ↕ calls
Service layer           ← Networking, persistence, system APIs
  ↕ maps to/from
Model (struct/enum)     ← Plain data types, Codable
```

### When to Consider TCA (The Composable Architecture)

Use TCA when you need:
- Deterministic state management (every state change is testable)
- Complex side effects that must be tracked and cancelled
- Deep composition of features that share state
- A team that already knows Redux/Elm patterns

> For detailed architecture comparisons, see [references/architecture/app-architecture.md](references/architecture/app-architecture.md).

## SwiftUI Component Patterns

### Layout System

SwiftUI layouts compose rather than cascade. There is no CSS — every visual property is a view modifier.

| Pattern | SwiftUI | Web Analog |
|---------|---------|------------|
| Horizontal layout | `HStack { }` | `display: flex; flex-direction: row` |
| Vertical layout | `VStack { }` | `display: flex; flex-direction: column` |
| Overlapping layers | `ZStack { }` | `position: relative` + `position: absolute` |
| Scrollable list | `List { }` or `LazyVStack` in `ScrollView` | `<ul>` or virtualized list |
| Grid | `LazyVGrid(columns:)` | CSS Grid |
| Spacer | `Spacer()` | `flex-grow: 1` |
| Padding | `.padding()` | `padding:` |
| Frame constraints | `.frame(maxWidth: .infinity)` | `width: 100%` |

### Navigation Patterns

| Pattern | Implementation | Use When |
|---------|---------------|----------|
| Tab-based | `TabView` | 3-5 top-level sections |
| Hierarchical drill-down | `NavigationStack` + `NavigationLink` | Master-detail flows |
| Modal presentation | `.sheet()` / `.fullScreenCover()` | Creation flows, settings |
| Custom bottom sheet | `.presentationDetents([.medium, .large])` | Contextual detail panels |
| Sidebar (iPad) | `NavigationSplitView` | Adaptive two/three-column layout |

> For comprehensive navigation implementation, see [references/architecture/navigation-patterns.md](references/architecture/navigation-patterns.md).

## Backend Integration

### Choosing a Backend

| Backend | Best For | Offline Support | Auth Built-in | Cost Model |
|---------|----------|----------------|---------------|------------|
| **CloudKit** | Apple-ecosystem apps | Excellent (built-in sync) | iCloud account | Free tier generous |
| **Firebase** | Cross-platform, rapid prototyping | Firestore offline cache | Firebase Auth | Pay-as-you-go |
| **Supabase** | SQL-native, open-source preference | Manual (with local cache) | GoTrue auth | Free tier + usage |
| **Custom REST/GraphQL** | Full control, existing backend | Manual | Manual | Varies |

### Networking Pattern

All network calls use Swift's native `async/await` with `URLSession`:

```swift
// Web equivalent: const data = await fetch(url).then(r => r.json())
let (data, response) = try await URLSession.shared.data(from: url)
let decoded = try JSONDecoder().decode(MyModel.self, from: data)
```

> For backend-specific integration guides, see:
> - [references/backend/cloudkit-guide.md](references/backend/cloudkit-guide.md)
> - [references/backend/firebase-integration.md](references/backend/firebase-integration.md)
> - [references/backend/supabase-integration.md](references/backend/supabase-integration.md)
> - [references/backend/networking-patterns.md](references/backend/networking-patterns.md)
> - [references/backend/auth-flows.md](references/backend/auth-flows.md)

## App Store Lifecycle

### Submission Pipeline

```
Development → TestFlight (internal) → TestFlight (external) → App Store Review → Release
     ↑              ↑                        ↑                      ↑
  Xcode build   Auto-distributed      Requires review         1-3 day review
  + unit tests  to team members       (1 day turnaround)      Binary + metadata
```

### Common Review Rejection Reasons

| Reason | Prevention |
|--------|-----------|
| Crash on launch | Test on real devices, not just simulator |
| Broken links or placeholder content | QA checklist before submission |
| Missing privacy policy | Add before first submission |
| Incomplete metadata | Fill all App Store Connect fields |
| In-app purchase issues | Test StoreKit in sandbox environment |
| Login wall without demo account | Provide test credentials in review notes |

> For the complete submission guide, see [references/lifecycle/app-store-submission.md](references/lifecycle/app-store-submission.md).
> For ASO strategy, see [references/lifecycle/app-store-optimization.md](references/lifecycle/app-store-optimization.md).

## Testing Strategy

| Test Type | Framework | Speed | What It Tests |
|-----------|-----------|-------|--------------|
| Unit tests | Swift Testing / XCTest | Fast | ViewModels, services, models |
| Snapshot tests | swift-snapshot-testing | Medium | View rendering consistency |
| Integration tests | XCTest | Medium | Service + persistence layers |
| UI tests | XCUITest | Slow | End-to-end user flows |
| Performance tests | XCTest `measure {}` | Medium | Execution time, memory |

> For test architecture and patterns, see [references/lifecycle/testing-strategy.md](references/lifecycle/testing-strategy.md).

## iOS-Specific Features

| Feature | Complexity | Value | Reference |
|---------|-----------|-------|-----------|
| Push notifications | Medium | High — re-engagement | [patterns/push-notifications.md](references/patterns/push-notifications.md) |
| Widgets (WidgetKit) | Medium | High — home screen presence | [patterns/widgets-extensions.md](references/patterns/widgets-extensions.md) |
| Deep linking / Universal Links | Medium | High — web-to-app bridge | [patterns/deep-linking.md](references/patterns/deep-linking.md) |
| Data persistence (SwiftData) | Low-Medium | Essential | [patterns/data-persistence.md](references/patterns/data-persistence.md) |
| In-app purchases (StoreKit 2) | High | Revenue | [patterns/in-app-purchases.md](references/patterns/in-app-purchases.md) |
| App Shortcuts / Siri | Low | Medium — discoverability | [patterns/shortcuts-siri.md](references/patterns/shortcuts-siri.md) |
| Live Activities | Medium | Medium — real-time status | [patterns/live-activities.md](references/patterns/live-activities.md) |

## Quick Start Guides

### Build My First iOS App
1. Read [foundations/swiftui-for-web-devs.md](references/foundations/swiftui-for-web-devs.md) for mental model translation
2. Scaffold project with [foundations/xcode-workflow.md](references/foundations/xcode-workflow.md)
3. Follow [worked-example-fitness-app.md](references/worked-example-fitness-app.md) for a full walkthrough
4. Deploy to TestFlight per [lifecycle/app-store-submission.md](references/lifecycle/app-store-submission.md)

### Port My Web App to iOS
1. Map your web architecture using the concept map above
2. Read [architecture/app-architecture.md](references/architecture/app-architecture.md) to choose your pattern
3. Translate your components with [ui/swiftui-components.md](references/ui/swiftui-components.md)
4. Reconnect your API layer with [backend/networking-patterns.md](references/backend/networking-patterns.md)

### Add a Backend to My App
1. Choose a backend from the comparison table above
2. Read the specific integration guide (CloudKit, Firebase, or Supabase)
3. Implement auth with [backend/auth-flows.md](references/backend/auth-flows.md)
4. Add offline support with [patterns/data-persistence.md](references/patterns/data-persistence.md)

### Ship to the App Store
1. Complete [lifecycle/testing-strategy.md](references/lifecycle/testing-strategy.md) checklist
2. Follow [lifecycle/app-store-submission.md](references/lifecycle/app-store-submission.md) step by step
3. Optimize listing with [lifecycle/app-store-optimization.md](references/lifecycle/app-store-optimization.md)
4. Set up [lifecycle/ci-cd-pipeline.md](references/lifecycle/ci-cd-pipeline.md) for future releases

### Build a Quick Prototype
1. Read [worked-example-quick-prototype.md](references/worked-example-quick-prototype.md)
2. Use SwiftUI previews as your dev server
3. Skip architecture — put logic in views for now
4. Deploy to TestFlight for immediate feedback

## Reference Guide

| Task | Read These |
|------|-----------|
| **Starting iOS development** | `foundations/swiftui-for-web-devs.md`, `foundations/xcode-workflow.md` |
| **Learning Swift basics** | `foundations/swift-essentials.md` |
| **Understanding iOS design** | `foundations/ios-design-principles.md` |
| **Choosing architecture** | `architecture/app-architecture.md` |
| **Implementing navigation** | `architecture/navigation-patterns.md` |
| **Managing state** | `architecture/state-management.md` |
| **Building UI components** | `ui/swiftui-components.md`, `ui/layout-system.md` |
| **Adding animations** | `ui/animations-transitions.md` |
| **Using UIKit from SwiftUI** | `ui/uikit-interop.md` |
| **iOS accessibility** | `ui/accessibility-ios.md` |
| **API networking** | `backend/networking-patterns.md` |
| **CloudKit integration** | `backend/cloudkit-guide.md` |
| **Firebase integration** | `backend/firebase-integration.md` |
| **Supabase integration** | `backend/supabase-integration.md` |
| **Authentication** | `backend/auth-flows.md` |
| **Writing tests** | `lifecycle/testing-strategy.md` |
| **App Store submission** | `lifecycle/app-store-submission.md` |
| **CI/CD setup** | `lifecycle/ci-cd-pipeline.md` |
| **Performance tuning** | `lifecycle/performance-profiling.md` |
| **ASO** | `lifecycle/app-store-optimization.md` |

All reference paths are relative to `references/`.

## Related Skills

- **trl-user-experience-engineer** — Design principles, wireframes, and style systems that inform mobile UI
- **trl-market-intelligence** — Validate app ideas and identify underserved App Store niches
- **trl-seo-guru** — App Store Optimization shares techniques with SEO (keywords, metadata, conversion)
- **trl-ai-templates** — Package app templates, starter kits, or SwiftUI component libraries for sale
- **trl-content-publishing** — Write tutorials about iOS development to build authority
- **trl-metal-graphics-dev** — GPU programming for games or graphics-intensive iOS apps
- **trl-mcp-builder** — Build MCP servers that iOS apps can communicate with via API

## Bundled Resources

### References

**Foundations** (read first):
- [swiftui-for-web-devs.md](references/foundations/swiftui-for-web-devs.md) — Mental model translation from React/Vue/HTML to SwiftUI
- [swift-essentials.md](references/foundations/swift-essentials.md) — Swift language crash course for JS/TS developers
- [ios-design-principles.md](references/foundations/ios-design-principles.md) — Apple HIG distilled: patterns, conventions, platform expectations
- [xcode-workflow.md](references/foundations/xcode-workflow.md) — Project setup, simulator, previews, debugging, Instruments

**Architecture** (`references/architecture/`):
- [app-architecture.md](references/architecture/app-architecture.md) — MVVM vs TCA vs clean architecture: when to use each
- [navigation-patterns.md](references/architecture/navigation-patterns.md) — NavigationStack, TabView, sheets, split views, deep linking
- [state-management.md](references/architecture/state-management.md) — @State, @Binding, @Observable, @Environment, data flow patterns
- [dependency-injection.md](references/architecture/dependency-injection.md) — Environment values, protocol-based DI, testing seams

**UI** (`references/ui/`):
- [swiftui-components.md](references/ui/swiftui-components.md) — Common component catalog with web equivalents
- [layout-system.md](references/ui/layout-system.md) — Stacks, grids, alignment, GeometryReader, custom layouts
- [animations-transitions.md](references/ui/animations-transitions.md) — Implicit/explicit animations, transitions, matched geometry
- [uikit-interop.md](references/ui/uikit-interop.md) — UIViewRepresentable, UIViewControllerRepresentable, bridging patterns
- [accessibility-ios.md](references/ui/accessibility-ios.md) — VoiceOver, Dynamic Type, color contrast, accessibility modifiers

**Backend** (`references/backend/`):
- [networking-patterns.md](references/backend/networking-patterns.md) — URLSession, async/await, Codable, error handling, retry logic
- [cloudkit-guide.md](references/backend/cloudkit-guide.md) — CloudKit setup, record types, subscriptions, sync engine
- [firebase-integration.md](references/backend/firebase-integration.md) — Firestore, Auth, Cloud Functions, FCM, Analytics
- [supabase-integration.md](references/backend/supabase-integration.md) — Supabase Swift client, realtime, auth, storage, edge functions
- [auth-flows.md](references/backend/auth-flows.md) — Sign in with Apple, OAuth, JWT, biometric auth, Keychain

**Lifecycle** (`references/lifecycle/`):
- [testing-strategy.md](references/lifecycle/testing-strategy.md) — Unit, snapshot, integration, UI tests; coverage targets
- [app-store-submission.md](references/lifecycle/app-store-submission.md) — Certificates, profiles, App Store Connect, review process
- [ci-cd-pipeline.md](references/lifecycle/ci-cd-pipeline.md) — Xcode Cloud, GitHub Actions, Fastlane, automated distribution
- [performance-profiling.md](references/lifecycle/performance-profiling.md) — Instruments, memory leaks, launch time, Energy Impact
- [app-store-optimization.md](references/lifecycle/app-store-optimization.md) — Keywords, screenshots, A/B testing, ratings strategy

**Patterns** (`references/patterns/`):
- [data-persistence.md](references/patterns/data-persistence.md) — SwiftData, Core Data, UserDefaults, Keychain, file storage
- [push-notifications.md](references/patterns/push-notifications.md) — APNs setup, permission flow, rich notifications, silent push
- [deep-linking.md](references/patterns/deep-linking.md) — Universal Links, custom URL schemes, deferred deep links
- [widgets-extensions.md](references/patterns/widgets-extensions.md) — WidgetKit, app intents, timeline providers, configuration
- [in-app-purchases.md](references/patterns/in-app-purchases.md) — StoreKit 2, subscriptions, consumables, receipt validation
- [shortcuts-siri.md](references/patterns/shortcuts-siri.md) — App Intents framework, Siri integration, Shortcuts actions
- [live-activities.md](references/patterns/live-activities.md) — ActivityKit, Dynamic Island, Lock Screen updates

**Agent Playbook**:
- [agent-playbook.claude-code.md](references/agent-playbook.claude-code.md) — Agent role definition and execution workflows

**Worked Examples**:
- [worked-example-fitness-app.md](references/worked-example-fitness-app.md) — Full walkthrough: building a fitness tracking app from concept to TestFlight
- [worked-example-quick-prototype.md](references/worked-example-quick-prototype.md) — Fast-path: weekend prototype with SwiftUI previews and TestFlight

### Assets

- [app-brief-worksheet.md](assets/app-brief-worksheet.md) — Fillable intake form for iOS app requirements
- [app-scoring-rubric.md](assets/app-scoring-rubric.md) — Quality scoring template for iOS app evaluation
- [project-tracker.md](assets/project-tracker.md) — iOS app project tracker for milestone monitoring
