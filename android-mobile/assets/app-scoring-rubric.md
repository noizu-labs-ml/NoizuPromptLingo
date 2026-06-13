# Android App Quality Scoring Rubric

Score each criterion 1-10. Multiply by weight. Passing: 7.0/10 weighted average. Target: 8.5+/10.

## Scoring

| Criterion | Weight | Score (1-10) | Weighted | Evidence |
|-----------|--------|-------------|----------|----------|
| Architecture quality | 15% | | | |
| UI/UX polish | 20% | | | |
| Test coverage | 15% | | | |
| Performance | 15% | | | |
| Offline reliability | 10% | | | |
| Accessibility | 10% | | | |
| Release readiness | 10% | | | |
| Code quality | 5% | | | |
| **TOTAL** | **100%** | | | |

## Criterion Details

### Architecture Quality (15%)

| Score | Description |
|-------|-------------|
| 1-3 | No clear separation of concerns, God Activities, business logic in UI |
| 4-6 | Basic MVVM but inconsistent, some layers mixed, partial DI |
| 7-8 | Clean layered architecture, consistent DI, proper state management |
| 9-10 | Exemplary separation, domain layer with use cases, offline-first, modularized |

### UI/UX Polish (20%)

| Score | Description |
|-------|-------------|
| 1-3 | Default Material components, no theming, broken layouts |
| 4-6 | Custom theme but inconsistent, some responsive issues, basic navigation |
| 7-8 | Consistent MD3 theming, adaptive layouts, smooth animations, good empty/error states |
| 9-10 | Branded design system, dynamic color, tablet adaptation, delightful micro-interactions |

### Test Coverage (15%)

| Score | Description |
|-------|-------------|
| 1-3 | No tests or only trivial tests |
| 4-6 | ViewModel unit tests for happy paths, no UI tests |
| 7-8 | ViewModel + repository tests, Compose UI tests for critical flows, screenshot tests |
| 9-10 | Full pyramid coverage, CI-integrated, E2E smoke tests, visual regression detection |

### Performance (15%)

| Score | Description |
|-------|-------------|
| 1-3 | Visible jank, slow startup (>3s), large APK (>50MB without media) |
| 4-6 | Occasional jank, acceptable startup, reasonable APK size |
| 7-8 | Smooth scrolling, fast startup (<1.5s), optimized APK, baseline profiles |
| 9-10 | Sub-second startup, zero jank, R8 full mode, per-ABI splits, benchmarked |

### Offline Reliability (10%)

| Score | Description |
|-------|-------------|
| 1-3 | Crashes or shows blank screen without network |
| 4-6 | Shows cached data but sync is manual/unreliable |
| 7-8 | Room as SSOT, automatic sync via WorkManager, clear offline indicators |
| 9-10 | Optimistic updates, conflict resolution, queue-based offline mutations |

### Accessibility (10%)

| Score | Description |
|-------|-------------|
| 1-3 | No content descriptions, small touch targets, no TalkBack support |
| 4-6 | Content descriptions on images, adequate touch targets |
| 7-8 | Full TalkBack navigation, semantic grouping, text scaling support |
| 9-10 | Custom accessibility actions, switch access support, color-blind safe palette |

### Release Readiness (10%)

| Score | Description |
|-------|-------------|
| 1-3 | No signing, no CI, no Play Console setup |
| 4-6 | Signed builds, basic CI, Play Console set up but listing incomplete |
| 7-8 | Full CI/CD pipeline, complete store listing, staged rollout plan, Crashlytics |
| 9-10 | Automated deployment, ASO-optimized listing, monitoring alerts, release cadence |

### Code Quality (5%)

| Score | Description |
|-------|-------------|
| 1-3 | Inconsistent style, no lint, deprecated APIs, Java mixed in |
| 4-6 | Consistent Kotlin, basic lint, some deprecations |
| 7-8 | Clean Kotlin idioms, lint clean, version catalog, convention plugins |
| 9-10 | Exemplary Kotlin, KDoc on public APIs, detekt configured, zero warnings |
