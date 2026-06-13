# iOS App Scoring Rubric

> Quality assessment template for iOS applications. Score each category, provide evidence, and calculate a weighted total. Use during code review, pre-submission audits, or portfolio evaluation.

---

## Scoring Scale

| Score | Label | Meaning |
|-------|-------|---------|
| 1 | Poor | Major issues, not shippable |
| 2 | Below Average | Significant gaps, needs rework |
| 3 | Acceptable | Meets minimum bar, some rough edges |
| 4 | Good | Solid implementation, minor improvements possible |
| 5 | Excellent | Best-practice implementation, polished |

---

## 1. Code Quality (Weight: 20%)

| Criterion | Score (1-5) | Evidence / Notes |
|-----------|:-----------:|------------------|
| Architecture pattern (MVVM, TCA, etc.) is consistent | | |
| Separation of concerns (UI / logic / data) | | |
| Error handling (no force unwraps, proper do/catch) | | |
| Naming conventions (clear, Swift-idiomatic) | | |
| No dead code, TODOs, or debug artifacts | | |
| Dependency management (SPM, minimal third-party) | | |
| Concurrency correctness (actors, @MainActor, Sendable) | | |

**Category Average:** _____ / 5

**Key Findings:**

```
[Write here]
```

---

## 2. UI Polish (Weight: 20%)

| Criterion | Score (1-5) | Evidence / Notes |
|-----------|:-----------:|------------------|
| Consistent spacing, alignment, and typography | | |
| Smooth animations and transitions | | |
| Loading states (skeleton views, progress indicators) | | |
| Empty states (helpful messaging, clear CTAs) | | |
| Error states (user-friendly, actionable) | | |
| Dark mode support | | |
| Dynamic Type support | | |
| Adaptive layout (iPhone SE through Pro Max) | | |
| iPad support (if applicable) | | |

**Category Average:** _____ / 5

**Key Findings:**

```
[Write here]
```

---

## 3. Performance (Weight: 15%)

| Criterion | Score (1-5) | Evidence / Notes |
|-----------|:-----------:|------------------|
| Launch time (< 2s cold start) | | |
| Scroll performance (60fps, no hitches) | | |
| Memory usage (no leaks, reasonable footprint) | | |
| Network efficiency (caching, pagination, no over-fetch) | | |
| Battery impact (no unnecessary background work) | | |
| Image handling (lazy loading, proper sizing, caching) | | |
| App size (< 200MB, asset catalogs optimized) | | |

**Category Average:** _____ / 5

**Key Findings:**

```
[Write here]
```

---

## 4. Accessibility (Weight: 15%)

| Criterion | Score (1-5) | Evidence / Notes |
|-----------|:-----------:|------------------|
| VoiceOver navigation works end-to-end | | |
| All images have accessibility labels | | |
| Touch targets >= 44x44pt | | |
| Color contrast meets WCAG AA (4.5:1 text, 3:1 large) | | |
| Dynamic Type scales correctly | | |
| Reduce Motion respected | | |
| Bold Text preference respected | | |
| Keyboard navigation (external keyboard) | | |

**Category Average:** _____ / 5

**Key Findings:**

```
[Write here]
```

---

## 5. Test Coverage (Weight: 15%)

| Criterion | Score (1-5) | Evidence / Notes |
|-----------|:-----------:|------------------|
| Unit tests for business logic / view models | | |
| Unit test coverage percentage | | |
| Integration tests for data layer | | |
| UI tests for critical flows | | |
| Snapshot tests for key screens (if applicable) | | |
| Edge cases covered (empty data, errors, offline) | | |
| Tests run in CI | | |

**Category Average:** _____ / 5

**Key Findings:**

```
[Write here]
```

---

## 6. App Store Readiness (Weight: 15%)

| Criterion | Score (1-5) | Evidence / Notes |
|-----------|:-----------:|------------------|
| App icon (all required sizes, polished) | | |
| Screenshots for all required device sizes | | |
| App description (clear, keyword-optimized) | | |
| Privacy policy URL provided | | |
| App privacy labels accurate (nutrition labels) | | |
| In-app purchases configured and tested | | |
| Review guidelines compliance (no private APIs, etc.) | | |
| Crash-free rate (>99% in TestFlight) | | |
| Localization (if targeting non-English markets) | | |

**Category Average:** _____ / 5

**Key Findings:**

```
[Write here]
```

---

## Overall Score

| Category | Weight | Score | Weighted |
|----------|--------|-------|----------|
| Code Quality | 20% | /5 | |
| UI Polish | 20% | /5 | |
| Performance | 15% | /5 | |
| Accessibility | 15% | /5 | |
| Test Coverage | 15% | /5 | |
| App Store Readiness | 15% | /5 | |
| **Total** | **100%** | | **_____ / 5.00** |

### Grade

| Range | Grade | Verdict |
|-------|-------|---------|
| 4.5 - 5.0 | A | Ship it |
| 4.0 - 4.4 | B | Ship with minor polish |
| 3.5 - 3.9 | C | Address gaps before submission |
| 3.0 - 3.4 | D | Significant rework needed |
| < 3.0 | F | Not ready for review |

**Final Grade:** _____

---

## Action Items

### Critical (must fix before submission)

- [ ] 
- [ ] 
- [ ] 

### Important (fix before v1.1)

- [ ] 
- [ ] 
- [ ] 

### Nice-to-Have (backlog)

- [ ] 
- [ ] 
- [ ] 

---

## Reviewer

| Field | Value |
|-------|-------|
| **Reviewer** | |
| **Date** | |
| **App Version** | |
| **Build Number** | |
| **Device Tested** | |
| **iOS Version** | |

---

*Template version: 0.1.0*
*Last updated: 2026-05-12*
