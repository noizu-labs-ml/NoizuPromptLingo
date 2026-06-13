# ACID Test Suites — Browser Standards Reference

## Overview

ACID tests are reference rendering tests used to evaluate browser standards compliance. They provide binary or scored pass/fail results against a canonical reference image or score target. This document covers the three official ACID tests and their successors.

---

## Acid1 (1998)

**Author:** Todd Fahrner  
**Origin:** Incorporated into W3C CSS1 test suite as test 5.5.26.c  
**Specification target:** CSS Level 1  
**Pass criteria:** Pixel-perfect match to reference image  

### What It Tests

Acid1 is a CSS Level 1 compliance test. It validates the browser's ability to correctly apply foundational CSS properties and compute the CSS box model.

#### CSS Properties Tested

| Property | Values Tested |
|----------|--------------|
| `display` | `block`, `inline`, `table`, `none` |
| `float` | `left`, `right`, `none` |
| `clear` | `left`, `right`, `both`, `none` |
| `margin` | positive, negative, collapsing |
| `padding` | all sides |
| `border` | width, style, color |
| `width` | explicit, auto |
| `height` | explicit, auto |
| `overflow` | `hidden`, `visible` |
| `background-color` | named colors, hex |
| `color` | named colors, hex |
| `font-size` | absolute, relative |
| `font-family` | generic families |
| `font-weight` | `bold`, `normal`, numeric |
| `line-height` | numeric, unitless |

#### Box Model Arithmetic

The test exercises correct computation of the CSS box model: `content-width + padding + border + margin = total width`. Browsers that implemented non-standard box models (where padding/border were included inside `width`) would fail.

#### HTML Elements Used

`p`, `blockquote`, `div`, `h1`–`h6`, `table`/`tr`/`td`, `em`, `strong`, `span`

### Bugs Targeted

- **IE/Netscape non-standard box models** — padding and border incorrectly subtracted from content area rather than added outside
- **Float clearing failures** — `clear` property not properly halting flow past floated elements
- **Incorrect margin collapsing** — adjacent block margins not collapsing to the larger value per CSS1 spec
- **`overflow: hidden` not clipping** — content overflowing beyond declared box dimensions

### Pass/Fail

Binary. The browser renders the page; the result is compared pixel-by-pixel to the reference image. Any visual deviation is a failure.

---

## Acid2 (2005)

**Author:** Ian Hickson (for the Web Standards Project)  
**Specification targets:** CSS 2.1, PNG specification, HTML 4.01  
**Pass criteria:** Pixel-perfect yellow smiley face; any red pixel = fail  
**Reference URL:** `http://www.webstandards.org/files/acid2/test.html`

### What It Tests

Acid2 is substantially more complex than Acid1. It tests CSS 2.1 layout and presentation features, PNG image rendering, and HTML 4.01 conformance. The reference image is a yellow smiley face; incorrect rendering produces a distorted or red-tinted result.

#### CSS Properties and Features Tested

| Feature | Details |
|---------|---------|
| Box model | Full CSS 2.1 box model including `min-width`, `max-width`, `min-height`, `max-height` |
| Positioning | `position: absolute`, `relative`, `fixed` |
| Floats | Float interaction with positioned elements |
| Display modes | `display: table`, `table-cell`, `table-row`, `inline-block`, `none` without corresponding HTML markup |
| Generated content | `::before` and `::after` pseudo-elements with `content` property |
| `inherit` keyword | Correct value inheritance through the cascade |
| Negative margins | Negative `margin` values for layout overlap |
| Background | `background-position`, `background-attachment` |
| Stacking/z-order | `z-index` with stacking contexts |
| `:hover` | Pseudo-class hover state rendering |
| Error handling | Intentionally malformed CSS declarations — browser must ignore gracefully |

#### Image Rendering

- PNG with alpha transparency — tests correct alpha compositing
- `data:` URI support — the face is embedded as a data URI, testing the browser's URI scheme handling

#### Key Bugs Targeted

| Bug | Description |
|-----|-------------|
| IE6 PNG alpha | IE6 rendered PNG alpha as solid grey instead of transparent |
| `max-width`/`min-height` ignored | Browsers that did not implement min/max constraints |
| `display: table` without markup | Creating table layout without `<table>` elements |
| Generated content (`::before`/`::after`) | Omitted or incorrectly positioned pseudo-elements |
| `position: fixed` | Elements not fixed relative to viewport on scroll |
| `data:` URI support | Browsers rejecting inline data URIs |
| CSS error recovery | Malformed declarations causing subsequent valid rules to be dropped |

### Pass/Fail

Any red pixel in the rendered output indicates a failure. The test was designed so that incorrect rendering manifests as visible red artifacts rather than subtle layout shifts.

---

## Acid3 (2008, Deprecated 2011)

**Authors:** Ian Hickson, David Baron, others  
**Specification targets:** DOM Level 2, CSS3 Selectors, SVG 1.1, SMIL 2.1, ECMAScript 3/5, HTTP  
**Pass criteria:** Score of 100/100 with smooth animation  
**Deprecation:** 2011 — tests were removed or modified; modern browsers intentionally score 97–99/100

### What It Tests

Acid3 uses 100 discrete subtests organized into 6 buckets. Each passing subtest increments the score by 1 point. The reference requires a score of 100 with a visually smooth animation during test execution.

### Subtest Buckets

| Bucket | Subtest Range | Topics |
|--------|--------------|--------|
| A | 1–25 | DOM Level 2 Core, DOM Level 2 Events, DOM traversal, node manipulation |
| B | 26–50 | CSS3 Selectors — attribute selectors, pseudo-classes, combinators, namespace selectors |
| C | 51–60 | HTTP — caching headers, `Content-Type` handling, XHTML served as `application/xhtml+xml` |
| D | 61–70 | SVG 1.1 — basic shapes, text, transforms, gradients, filters |
| E | 71–80 | SMIL 2.1 — SVG animation (`<animate>`, `<animateTransform>`, `<animateMotion>`) |
| F | 81–100 | ECMAScript — regular expressions, getters/setters, garbage collection behavior, `eval`, exception handling |

### Scoring Details

- Each of the 100 subtests contributes exactly 1 point
- A score of 100 requires pixel-perfect rendering of the reference image in addition to all subtests passing
- The test animation must run smoothly (no dropped frames during execution)

### Known Gotchas

| Issue | Description |
|-------|-------------|
| SVG fonts | Subtests relying on SVG fonts fail in browsers that dropped SVG font support (Chrome, Firefox) — intentional regression |
| Favicon 404 | The test's favicon request is used as an HTTP test; a missing favicon causes a subtest failure |
| DOM liveness | Tests verify that NodeLists are live (update after DOM mutation) |
| XHTML content-type | Subtests require correct handling of `application/xhtml+xml` |
| GC tests | ECMAScript garbage collection behavior tests (bucket F) are non-deterministic and may fail intermittently |

### Deprecation Status

Acid3 was deprecated in 2011 when several subtests were identified as testing behaviors that were either underspecified or deliberately removed from later specifications (SVG fonts, certain SMIL behaviors). Modern browsers intentionally score 97–99/100 rather than achieving 100. The test is no longer used as a meaningful compliance metric.

---

## Web Platform Tests (WPT)

**Repository:** `https://github.com/web-platform-tests/wpt`  
**Test count:** 50,000+ tests  
**URL:** `https://wpt.fyi`

### Overview

WPT is the modern, authoritative browser interoperability test suite, maintained by the W3C and used by all major browser engines (Chromium, WebKit, Gecko). ACID tests are effectively obsolete; WPT is the current standard for measuring compliance.

### Test Types

| Type | Description |
|------|-------------|
| `testharness.js` | JavaScript-based functional tests using the W3C test harness API |
| Reftests | Reference image comparison — browser renders two pages, compares them pixel-by-pixel |
| Crash tests | Pages that must not crash the browser |
| `wdspec` | WebDriver specification tests |
| Manual tests | Tests requiring human judgment (not automatable) |

### Engine Usage

All major engines run WPT continuously:
- **Chromium** — integrated into CQ (commit queue) via `web_tests/`
- **WebKit** — integrated into EWS (Early Warning System)
- **Gecko** — integrated into `mozilla-central` CI

Results are published at `https://wpt.fyi/results/` with per-browser pass rates per spec module.

### Priority Order for a New Engine

When bootstrapping a new browser engine, WPT coverage should be approached in this order:

| Priority | WPT Path | Rationale |
|----------|----------|-----------|
| 1 | `css/css2/` | Foundational layout — required for any page rendering |
| 2 | `css/css-box/` | Box model correctness |
| 3 | `css/css-position/` | Absolute/relative/fixed positioning |
| 4 | `css/css-flexbox/` | Modern layout — vast majority of sites use flexbox |
| 5 | `css/css-grid/` | Grid layout — increasingly common |
| 6 | `css/selectors/` | CSS selector engine |
| 7 | `dom/` | DOM manipulation, events, mutation observers |
| 8 | `fetch/` | Network layer, CORS, request/response |
| 9 | `html/` | HTML parsing and element behavior |
| 10 | `url/` | URL parsing per WHATWG URL spec |

### Interop 2025 Focus Areas

The Interop project (joint initiative by Apple, Google, Microsoft, Mozilla) identifies annually where browsers diverge. Interop 2025 focus areas include:

- Anchor positioning (`css-anchor-position`)
- CSS `@starting-style` transitions
- `scrollbar-width` and `scrollbar-color`
- `text-wrap: balance` and `text-wrap: pretty`
- WebRTC encoded transforms
- `writing-mode` in SVG
- View transitions (Level 1 and 2)
- Custom properties (`@property`)
- `::backdrop` pseudo-element

---

## W3C CSS Test Suites

**Status:** Mostly superseded by WPT  
**Most complete standalone suite:** CSS 2.1 Test Suite

The W3C published standalone CSS test suites separate from WPT for historical reasons. These suites predate WPT's existence and are no longer the authoritative source. The CSS 2.1 Test Suite (`http://test.csswg.org/suites/css2.1/`) remains the most comprehensive standalone suite and is still useful for bootstrapping CSS 2.1 compliance testing in isolation.

Modern development should target WPT paths under `css/` rather than the standalone W3C suites.

---

## Summary: Test Suite Priority for therobotbrowses

| Test | Use Case | When to Target |
|------|----------|---------------|
| Acid1 | CSS1 baseline validation | Phase 1 (Render) milestone |
| Acid2 | CSS 2.1 / PNG baseline | Phase 1–2 milestone |
| Acid3 | Historical reference only | Not a target — deprecated |
| WPT `css/css2/` | Authoritative CSS2 compliance | Phase 1–2 |
| WPT `css/css-flexbox/` | Flexbox layout | Phase 2–3 |
| WPT `css/css-grid/` | Grid layout | Phase 3 |
| WPT `dom/` | DOM API compliance | Phase 3–4 |
| WPT `fetch/` | Network layer | Phase 4 |
