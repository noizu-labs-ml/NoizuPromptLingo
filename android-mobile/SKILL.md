---
name: trl-android-mobile
description: >
  Design and build production-ready Android mobile applications using Kotlin, Jetpack Compose, and Material Design 3.
  Use this skill when the user wants to build an Android app, design mobile UI screens, set up a Kotlin project,
  implement Jetpack Compose layouts, configure Gradle builds, write Android tests, publish to the Google Play Store,
  optimize App Store listings (ASO), add push notifications, implement offline-first architecture, or create a
  companion app for an existing web project — even if they don't say "Android." Also trigger when users mention
  mobile app development, Kotlin Multiplatform, Play Console, APK, AAB, Material Design, Compose navigation,
  Room database, Retrofit, Hilt dependency injection, or Android release management.
---

# Android Mobile

Design and implement production-ready Android applications from concept through Play Store publication.

## Overview

This skill provides a complete methodology for building Android apps that ship. It covers:

- **Architecture design** — Modern Android architecture (MVVM, MVI) with Jetpack components, offline-first patterns, and clean separation of concerns
- **UI implementation** — Jetpack Compose with Material Design 3 theming, adaptive layouts, and accessibility
- **Backend integration** — REST/GraphQL clients, authentication flows, real-time data with WebSockets
- **Quality assurance** — Unit tests, UI tests, screenshot tests, and CI/CD pipelines
- **Release management** — Signing, versioning, Play Store publishing, staged rollouts, and ASO
- **Monetization integration** — In-app purchases, subscriptions, ad integration, and freemium patterns

## Core Philosophy

1. **Compose-first** — Jetpack Compose is the default UI toolkit; Views only when Compose lacks a capability (e.g., MapView). No XML layouts for new projects.
2. **Offline-first architecture** — Assume the network is unreliable. Room as single source of truth, sync when connected. Users should never see a blank screen because of connectivity.
3. **Ship incrementally** — Internal testing track on day one. Every merge to main produces a deployable build. Feature flags over feature branches.
4. **Material Design 3 as foundation, not ceiling** — Use MD3 tokens and components as the base, then layer brand identity on top. Don't fight the system; extend it.
5. **Dependency discipline** — Every library earns its place. Prefer Jetpack-maintained libraries over community alternatives when quality is comparable. Audit transitive dependencies quarterly.

## When to Use This Skill

- **Building a new Android app** — Full lifecycle from project setup through Play Store launch
- **Adding mobile to an existing web project** — Companion app design that shares backend APIs
- **Designing mobile UI** — Screen flows, component selection, adaptive layouts for phones and tablets
- **Setting up Android CI/CD** — GitHub Actions, Gradle configuration, automated testing and deployment
- **Publishing to Play Store** — Signing, listing optimization, staged rollouts, crash monitoring
- **Implementing offline-first** — Room + WorkManager + sync strategies for reliable mobile experiences
- **Migrating from Views to Compose** — Incremental adoption strategy for existing projects
- **Android performance optimization** — Profiling, reducing APK size, improving startup time

> For web UI design and landing pages, see **trl-user-experience-engineer** (`references/outputs/landing-pages.md`).
> For backend API design that mobile apps consume, see the project's backend documentation.
> For app marketing and niche validation, see **trl-market-intelligence** (`references/niche-discovery.md`).
> For ASO content optimization, see **trl-seo-guru** (`kb/01-ai-seo-complete-guide.md`).

## Android Technology Stack

### Core Stack (Required)

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Language | Kotlin 2.x | Primary language, coroutines for async |
| UI | Jetpack Compose + Material 3 | Declarative UI with design system tokens |
| Navigation | Compose Navigation (type-safe) | Screen routing with argument passing |
| DI | Hilt | Compile-time dependency injection |
| Networking | Retrofit + OkHttp + kotlinx.serialization | REST API client with interceptors |
| Local DB | Room | SQLite abstraction, Flow-based queries |
| State | ViewModel + StateFlow | Lifecycle-aware state management |
| Background | WorkManager | Reliable background task scheduling |
| Image Loading | Coil | Kotlin-first image loading for Compose |
| Build | Gradle (Kotlin DSL) + Version Catalogs | Build system with centralized dependencies |

### Optional Stack (Use When Needed)

| Technology | When to Use |
|-----------|-------------|
| Kotlin Multiplatform (KMP) | Sharing business logic with iOS |
| DataStore | Simple key-value preferences (replaces SharedPreferences) |
| Paging 3 | Large lists with pagination |
| Media3 / ExoPlayer | Audio/video playback |
| CameraX | Camera capture |
| Accompanist | Compose utilities (permissions, system UI) |
| Firebase | Analytics, Crashlytics, Cloud Messaging, Remote Config |
| Ktor | Alternative HTTP client (especially with KMP) |
| SQLDelight | Alternative to Room (especially with KMP) |
| Baseline Profiles | Startup and runtime performance optimization |

## Architecture Patterns

### Recommended: Layered Architecture with MVVM

```
┌─────────────────────────────────────┐
│           UI Layer                   │
│  Compose Screens → ViewModels       │
│  (state holders, UI events)         │
├─────────────────────────────────────┤
│         Domain Layer                 │
│  Use Cases / Interactors            │
│  (business logic, pure Kotlin)      │
├─────────────────────────────────────┤
│          Data Layer                  │
│  Repositories → DataSources         │
│  (Room, Retrofit, DataStore)        │
└─────────────────────────────────────┘
```

**Package structure:**
```
com.example.app/
├── di/                    # Hilt modules
├── data/
│   ├── local/             # Room entities, DAOs, database
│   ├── remote/            # API services, DTOs
│   └── repository/        # Repository implementations
├── domain/
│   ├── model/             # Domain models
│   ├── repository/        # Repository interfaces
│   └── usecase/           # Use cases
├── ui/
│   ├── theme/             # Material 3 theme (Color, Type, Theme)
│   ├── components/        # Reusable composables
│   ├── navigation/        # NavHost, routes, graphs
│   └── screens/
│       ├── home/          # HomeScreen, HomeViewModel
│       ├── detail/        # DetailScreen, DetailViewModel
│       └── settings/      # SettingsScreen, SettingsViewModel
└── util/                  # Extensions, constants
```

### When to Use MVI Instead

Use MVI (Model-View-Intent) when:
- Complex screen state with many interdependent fields
- State must be preserved precisely across process death
- Team prefers explicit action/effect patterns over imperative ViewModel methods

**MVI adds ceremony.** Default to MVVM; switch to MVI only when the state management benefits justify the boilerplate.

## Design System: Material Design 3

### Theme Setup

Every app needs three files in `ui/theme/`:

| File | Contents |
|------|----------|
| `Color.kt` | MD3 color roles generated from Material Theme Builder |
| `Type.kt` | Typography scale (display, headline, title, body, label) |
| `Theme.kt` | `MaterialTheme` wrapper with light/dark/dynamic color support |

### Dynamic Color

Android 12+ supports dynamic color derived from the user's wallpaper. Always support it as an option:
- Use `dynamicLightColorScheme()` / `dynamicDarkColorScheme()` when available
- Fall back to your brand color scheme on older devices
- Let users toggle between "app colors" and "system colors" in settings

### Adaptive Layouts

| Window Class | Breakpoint | Layout Strategy |
|-------------|-----------|-----------------|
| Compact | < 600dp | Single-pane, bottom nav |
| Medium | 600-840dp | List-detail (optional), nav rail |
| Expanded | > 840dp | Two-pane, permanent nav drawer |

Use `WindowSizeClass` from `material3-window-size-class` to detect and adapt.

## Development Workflow

### Phase 1: Project Setup (Day 1)

1. Create project with Android Studio (Compose template, Kotlin DSL)
2. Configure version catalog (`libs.versions.toml`)
3. Set up Hilt, Room, Retrofit dependencies
4. Create theme from Material Theme Builder export
5. Configure signing (debug keystore + release keystore in CI)
6. Set up GitHub Actions for build + test on every PR
7. Create internal testing track on Play Console
8. First deploy to internal testing

### Phase 2: Core Features (Weeks 1-3)

1. Implement navigation graph with all screen routes
2. Build data layer: Room entities, API services, repositories
3. Implement core screens with ViewModels
4. Add authentication flow (if applicable)
5. Set up offline-first sync with WorkManager
6. Write unit tests for ViewModels and use cases
7. Write UI tests for critical user flows

### Phase 3: Polish (Week 4)

1. Accessibility audit (TalkBack, content descriptions, touch targets)
2. Performance profiling (startup, jank, memory)
3. Edge case handling (no network, empty states, error states)
4. Tablet/foldable adaptation
5. Dark mode verification
6. Screenshot tests for visual regression

### Phase 4: Launch (Week 5)

1. Generate signed AAB
2. Prepare Play Store listing (screenshots, description, feature graphic)
3. ASO optimization (keywords, title, description)
4. Staged rollout: internal → closed testing → open testing → production
5. Set up crash monitoring (Firebase Crashlytics)
6. Configure Play Console alerts

## Testing Strategy

| Test Type | Tool | Coverage Target | Speed |
|-----------|------|----------------|-------|
| Unit tests | JUnit 5 + Turbine + MockK | ViewModels, use cases, repositories | Fast |
| UI tests | Compose Test | Critical user flows, component behavior | Medium |
| Screenshot tests | Roborazzi or Paparazzi | Visual regression for components | Medium |
| Integration tests | Hilt test + Room in-memory | Data layer end-to-end | Medium |
| E2E tests | Maestro | Happy-path user journeys | Slow |

### Testing Priorities

1. **Always test:** ViewModel state transitions, repository data mapping, navigation routing
2. **Usually test:** Compose component behavior, error state rendering, form validation
3. **Sometimes test:** Animation correctness, exact pixel layout, third-party SDK integration
4. **Rarely test:** Android framework behavior, library internals

## Play Store Publishing

### Pre-Launch Checklist

- [ ] App signed with release keystore (stored securely, NOT in repo)
- [ ] Version code incremented, version name updated
- [ ] ProGuard/R8 rules verified (no runtime crashes from obfuscation)
- [ ] All test tracks passed (internal → closed → open)
- [ ] Crashlytics shows no critical issues in testing
- [ ] Privacy policy URL set in Play Console
- [ ] Data safety form completed
- [ ] Content rating questionnaire submitted
- [ ] Store listing complete (title, short desc, full desc, screenshots, feature graphic)
- [ ] Target API level meets Play Store requirements (currently API 34+)

### ASO (App Store Optimization)

| Element | Max Length | Strategy |
|---------|-----------|----------|
| App title | 30 chars | Primary keyword + brand |
| Short description | 80 chars | Value prop with secondary keywords |
| Full description | 4000 chars | Feature list, keywords naturally woven in |
| Screenshots | 8 per device | First 2 screenshots are critical — show core value |
| Feature graphic | 1024x500 | Brand + tagline, readable at thumbnail size |

## CI/CD Pipeline

### Recommended: GitHub Actions

```
PR opened/updated:
  → Build debug APK
  → Run unit tests
  → Run lint checks
  → Run UI tests (emulator)

Merge to main:
  → Build release AAB
  → Sign with release keystore
  → Upload to internal testing track
  → Post build link to Slack/Discord

Tag (v*):
  → Same as above
  → Promote to production track (manual approval)
```

### Gradle Optimization

- Enable build cache and configuration cache
- Use `org.gradle.parallel=true`
- Define dependency versions in `libs.versions.toml`
- Use convention plugins for shared build logic across modules

## Quick Start Guides

### New Android App from Scratch
1. Fill out [app-brief-worksheet.md](assets/app-brief-worksheet.md)
2. Review architecture guide in [android-architecture-guide.md](references/android-architecture-guide.md)
3. Set up project following Phase 1 checklist above
4. Implement features following the architecture patterns
5. Polish and test following Phase 3-4 checklists
6. Publish following [play-store-publishing.md](references/play-store-publishing.md)

### Companion App for Existing Web Project
1. Identify which web features translate to mobile (not all should)
2. Design mobile-first flows using [material-design-patterns.md](references/material-design-patterns.md)
3. Share API layer — create OpenAPI spec if one doesn't exist
4. Build mobile-specific features (push notifications, offline, camera)
5. Launch with feature parity on core flows, mobile-native UX for interactions

### Add Android to KMP Project
1. Set up shared module with `expect`/`actual` declarations
2. Android-specific implementations for platform APIs
3. Compose UI layer consuming shared ViewModels
4. Shared networking via Ktor, shared persistence via SQLDelight
5. Single test suite for shared logic, platform-specific tests for implementations

### Migrate Views to Compose
1. Add Compose dependencies alongside existing View system
2. Start with leaf screens (settings, about) — low risk, high learning
3. Use `ComposeView` in existing Fragments for gradual adoption
4. Migrate screen-by-screen, never mix Views and Compose within a single screen
5. Remove Fragment/XML infrastructure after full migration

## Reference Guide

| Task | Read These |
|------|-----------|
| **Starting any Android project** | `android-architecture-guide.md`, `material-design-patterns.md` |
| **Setting up CI/CD** | `android-ci-cd-guide.md` |
| **Designing mobile screens** | `material-design-patterns.md` |
| **Writing tests** | `testing-strategy.md` |
| **Publishing to Play Store** | `play-store-publishing.md` |
| **Performance optimization** | `android-architecture-guide.md` (performance section) |
| **Full build walkthrough** | `worked-example-companion-app.md` |

All reference paths are relative to `references/`.

## Related Skills

- **trl-user-experience-engineer** — Design system, wireframes, and visual direction before implementing in Compose
- **trl-market-intelligence** — Validate app niche and audience before building
- **trl-seo-guru** — ASO optimization for Play Store discoverability
- **trl-content-publishing** — App marketing through technical content and tutorials
- **trl-ai-templates** — Package app templates or starter kits as digital products
- **trl-mcp-builder** — Build MCP servers that mobile apps can interact with via API

## Bundled Resources

### References

**Foundation** (read first for any Android project):
- [android-architecture-guide.md](references/android-architecture-guide.md) — Modern Android architecture patterns, package structure, dependency management, and performance optimization
- [material-design-patterns.md](references/material-design-patterns.md) — Material Design 3 theming, component selection, adaptive layouts, accessibility, and brand customization
- [android-ci-cd-guide.md](references/android-ci-cd-guide.md) — GitHub Actions setup, Gradle optimization, signing configuration, and automated deployment

**Quality** (read before shipping):
- [testing-strategy.md](references/testing-strategy.md) — Testing pyramid for Android: unit, UI, screenshot, integration, and E2E test patterns
- [play-store-publishing.md](references/play-store-publishing.md) — Play Console setup, ASO, staged rollouts, crash monitoring, and release management

**Execution** (read during implementation):
- [agent-playbook.claude-code.md](references/agent-playbook.claude-code.md) — Agent role definition and execution workflows for Android development tasks

**Worked Examples:**
- [worked-example-companion-app.md](references/worked-example-companion-app.md) — End-to-end walkthrough: building a companion Android app for an existing web project

### Assets

- [app-brief-worksheet.md](assets/app-brief-worksheet.md) — Intake form for capturing app requirements, target audience, features, and constraints
- [app-scoring-rubric.md](assets/app-scoring-rubric.md) — Quality scoring template for Android apps with weighted criteria
- [release-checklist.md](assets/release-checklist.md) — Pre-publish checklist covering signing, testing, listing, and compliance
