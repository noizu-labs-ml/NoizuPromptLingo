# macOS App Quality Scoring Rubric

Score each criterion 1–5. Multiply by weight for weighted score. Max total: 100.

---

## Scoring Scale

| Score | Meaning |
|-------|---------|
| 1 | Missing or broken |
| 2 | Partially implemented, significant gaps |
| 3 | Functional, meets minimum bar |
| 4 | Solid, above average |
| 5 | Exemplary, production-ready |

---

## 1. Architecture (Weight: 20)

| Criterion | Score (1–5) | Notes |
|-----------|-------------|-------|
| Separation of concerns (view / model / service) | | |
| Correct use of SwiftUI property wrappers (`@State`, `@Binding`, `@Observable`, `@Environment`) | | |
| No business logic in views | | |
| Async patterns correct (`async/await`, no force-unwrap of Task results) | | |
| **Subtotal** | /20 | × weight 1.0 |

**Weighted score: \_\_\_ / 20**

---

## 2. Desktop UX (Weight: 25)

| Criterion | Score (1–5) | Notes |
|-----------|-------------|-------|
| Keyboard navigation — all actions reachable without mouse | | |
| Keyboard shortcuts defined for primary actions | | |
| Context menus (right-click) on appropriate elements | | |
| Window management (resizable, remembers size/position) | | |
| Drag-and-drop where expected | | |
| **Subtotal** | /25 | × weight 1.0 |

**Weighted score: \_\_\_ / 25**

---

## 3. SwiftUI Quality (Weight: 20)

| Criterion | Score (1–5) | Notes |
|-----------|-------------|-------|
| Native macOS controls used (no UIKit transplants) | | |
| Consistent use of system fonts, colors, spacing | | |
| Dark mode / light mode support | | |
| VoiceOver / accessibility labels on interactive elements | | |
| **Subtotal** | /20 | × weight 1.0 |

**Weighted score: \_\_\_ / 20**

---

## 4. Sandbox Compliance (Weight: 20)

| Criterion | Score (1–5) | Notes |
|-----------|-------------|-------|
| Entitlements minimal — no over-broad permissions | | |
| Security-scoped bookmarks used for persistent file access | | |
| Network usage restricted to declared domains | | |
| No hardcoded paths outside container | | |
| **Subtotal** | /20 | × weight 1.0 |

**Weighted score: \_\_\_ / 20**

---

## 5. Distribution Readiness (Weight: 15)

| Criterion | Score (1–5) | Notes |
|-----------|-------------|-------|
| App icon complete (all required sizes, macOS style) | | |
| `Info.plist` — all required keys present | | |
| Notarization / hardened runtime enabled | | |
| Privacy usage descriptions for all sensitive APIs | | |
| No debug logging or test credentials in release build | | |
| **Subtotal** | /15 | × weight 0.6 |

**Weighted score: \_\_\_ / 15**

---

## Summary

| Category | Max | Score |
|----------|-----|-------|
| Architecture | 20 | |
| Desktop UX | 25 | |
| SwiftUI Quality | 20 | |
| Sandbox Compliance | 20 | |
| Distribution Readiness | 15 | |
| **Total** | **100** | |

---

## Grade Bands

| Score | Grade | Recommendation |
|-------|-------|----------------|
| 90–100 | A — Ship it | Ready for production / App Store submission |
| 75–89 | B — Polish pass | Address top gaps, then ship |
| 60–74 | C — Needs work | Architectural or UX issues require attention |
| 45–59 | D — Significant rework | Core issues block shipping |
| < 45 | F — Rebuild | Foundational problems; revisit design |

---

## Review Notes

**Reviewer:**
**Date:**
**App version:**
**Build:**

Key blockers:
1.
2.
3.

Recommended next steps:
1.
2.
3.
