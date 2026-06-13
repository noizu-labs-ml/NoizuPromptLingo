# Phase 1 User Stories — Render (CSS + Layout)

**Milestone:** ACID1 Pass
**Deliverables:** CSS parser, box model, layout engine, text rendering

---

### US-100: HTML Parsing via html5ever

**As** P-001 Kai (tool-building developer), **I want** the browser to parse HTML documents using html5ever, **so that** I get spec-compliant DOM construction without reinventing a parser.

**Acceptance Criteria:**
- [ ] html5ever is integrated as the HTML tokenizer and tree builder
- [ ] Malformed HTML is handled according to the HTML5 error-recovery spec
- [ ] Parser produces a well-formed DOM tree for any valid HTML5 document
- [ ] Parse time for a 100KB document is under 50ms on release builds

**Phase:** 1 — Render
**Priority:** P0
**Personas:** P-001, A-002

---

### US-101: DOM Tree Construction and Querying

**As** A-001 Claude (browsing copilot agent), **I want** a queryable DOM tree with standard traversal methods, **so that** I can locate elements by tag, id, class, or CSS selector.

**Acceptance Criteria:**
- [ ] DOM nodes store tag name, attributes, text content, and parent/child/sibling references
- [ ] `querySelector` and `querySelectorAll` style lookups work against the tree
- [ ] DOM tree is immutable during layout to prevent data races
- [ ] Tree supports efficient subtree extraction for agent inspection

**Phase:** 1 — Render
**Priority:** P0
**Personas:** A-001, A-002, P-001

---

### US-102: CSS Parsing

**As** P-001 Kai (tool-building developer), **I want** the browser to parse CSS2.1 stylesheets into a structured rule set, **so that** styles can be resolved against the DOM.

**Acceptance Criteria:**
- [ ] Inline `style` attributes, `<style>` blocks, and linked stylesheets are all parsed
- [ ] Selectors support type, class, ID, descendant, child, and universal combinators
- [ ] Property values are parsed into typed representations (lengths, colors, keywords)
- [ ] Malformed rules are skipped without crashing the parser

**Phase:** 1 — Render
**Priority:** P0
**Personas:** P-001, A-001

---

### US-103: CSS Cascade and Specificity Resolution

**As** P-002 Dr. Amara (researcher), **I want** the browser to resolve conflicting CSS declarations using the standard cascade, **so that** pages render with correct visual priority.

**Acceptance Criteria:**
- [ ] Cascade order is respected: user-agent < author < inline
- [ ] Specificity is computed correctly (id > class > type) with tie-breaking by source order
- [ ] `!important` declarations override normal declarations
- [ ] Inherited properties propagate from parent to child correctly

**Phase:** 1 — Render
**Priority:** P0
**Personas:** P-002, P-001

---

### US-104: CSS Computed and Used Value Resolution

**As** A-001 Claude (browsing copilot agent), **I want** every DOM element to have fully resolved computed styles, **so that** I can inspect the final visual properties of any element.

**Acceptance Criteria:**
- [ ] Percentage values resolve against the containing block
- [ ] `em` and `rem` units resolve to absolute pixel values
- [ ] `inherit`, `initial`, and default values resolve correctly
- [ ] Computed styles are queryable per-element via internal API

**Phase:** 1 — Render
**Priority:** P0
**Personas:** A-001, P-001, P-004

---

### US-105: Box Model Computation

**As** P-001 Kai (tool-building developer), **I want** each element to have computed margin, border, padding, and content dimensions, **so that** layout can position elements correctly.

**Acceptance Criteria:**
- [ ] `margin`, `border-width`, `padding`, and `width`/`height` are computed per element
- [ ] `auto` margins resolve correctly for block-level centering
- [ ] `box-sizing: content-box` is the default; `border-box` adjusts width/height to include padding and border
- [ ] Negative margins are supported

**Phase:** 1 — Render
**Priority:** P0
**Personas:** P-001, A-001

---

### US-106: Block Layout

**As** P-002 Dr. Amara (researcher), **I want** block-level elements to stack vertically with correct margin collapsing, **so that** document flow renders as expected.

**Acceptance Criteria:**
- [ ] Block boxes are laid out top-to-bottom within their containing block
- [ ] Vertical margins between adjacent siblings collapse to the larger value
- [ ] `width: auto` expands to fill the containing block
- [ ] `height: auto` shrinks to fit content

**Phase:** 1 — Render
**Priority:** P0
**Personas:** P-002, P-001

---

### US-107: Inline Layout and Text Wrapping

**As** P-003 Maya (keyboard power user), **I want** inline text to wrap at word boundaries within its container, **so that** paragraphs are readable without horizontal scrolling.

**Acceptance Criteria:**
- [ ] Inline boxes flow left-to-right, wrapping to the next line when the line box is full
- [ ] Line height is computed from `line-height` and font metrics
- [ ] White space collapsing follows CSS `white-space: normal` rules
- [ ] `<br>` forces a line break

**Phase:** 1 — Render
**Priority:** P0
**Personas:** P-003, P-002, A-001

---

### US-108: Font Loading and Text Rendering (System Fonts)

**As** P-003 Maya (keyboard power user), **I want** text rendered using system fonts with correct glyph selection, **so that** content is legible on screen.

**Acceptance Criteria:**
- [ ] System font families (serif, sans-serif, monospace) are resolved to platform fonts
- [ ] `font-size`, `font-weight`, `font-style` are respected in glyph selection
- [ ] Text is rasterized at the correct size and position within line boxes
- [ ] Missing glyphs fall back to a tofu/replacement character rather than crashing

**Phase:** 1 — Render
**Priority:** P0
**Personas:** P-003, P-004, A-001

---

### US-109: Color and Background Rendering

**As** P-002 Dr. Amara (researcher), **I want** elements to render with correct foreground and background colors, **so that** visual hierarchy and readability are preserved.

**Acceptance Criteria:**
- [ ] `color` property applies to text rendering
- [ ] `background-color` fills the padding box of each element
- [ ] Named colors, hex (`#rgb`, `#rrggbb`), and `rgb()` notation are supported
- [ ] Transparent backgrounds show the parent's background through

**Phase:** 1 — Render
**Priority:** P0
**Personas:** P-002, P-004

---

### US-110: List Styling (Bullets and Numbers)

**As** A-002 Crawler (headless data harvester agent), **I want** ordered and unordered lists to render with correct markers, **so that** list semantics are visually represented and structurally parseable.

**Acceptance Criteria:**
- [ ] `<ul>` renders disc markers by default
- [ ] `<ol>` renders decimal numbers starting from 1 (or the `start` attribute)
- [ ] `list-style-type: none` suppresses markers
- [ ] List item content indents correctly from the marker

**Phase:** 1 — Render
**Priority:** P1
**Personas:** A-002, P-002

---

### US-111: Basic Table Layout

**As** P-002 Dr. Amara (researcher), **I want** HTML tables to render with rows, columns, and cell alignment, **so that** tabular data is presented readably.

**Acceptance Criteria:**
- [ ] `<table>`, `<tr>`, `<td>`, `<th>` elements produce a grid layout
- [ ] Column widths distribute based on content (auto table layout algorithm)
- [ ] `border`, `cellpadding`, and `cellspacing` attributes are respected
- [ ] Cells spanning multiple columns (`colspan`) are handled correctly

**Phase:** 1 — Render
**Priority:** P1
**Personas:** P-002, A-002

---

### US-112: Image Placeholders

**As** A-001 Claude (browsing copilot agent), **I want** images with known dimensions to reserve the correct space in layout, **so that** page geometry is stable even before image data loads.

**Acceptance Criteria:**
- [ ] `<img>` with `width` and `height` attributes reserves a box of that size
- [ ] A visible placeholder (gray box or outline) renders in place of the image
- [ ] `alt` text renders inside the placeholder when present
- [ ] Missing dimensions fall back to a default placeholder size (e.g., 300x150)

**Phase:** 1 — Render
**Priority:** P1
**Personas:** A-001, A-002, P-001

---

### US-113: Layout Tree Inspection via MCP

**As** A-001 Claude (browsing copilot agent), **I want** to query the layout tree through an MCP tool interface, **so that** I can read computed styles, box dimensions, and element positions programmatically.

**Acceptance Criteria:**
- [ ] MCP tool `inspect_element(selector)` returns computed styles and box geometry for matched elements
- [ ] MCP tool `layout_tree()` returns a serialized tree with tag, position, and dimensions per node
- [ ] MCP tool `computed_style(selector, property)` returns the resolved value of a specific CSS property
- [ ] All MCP responses use JSON with consistent schema

**Phase:** 1 — Render
**Priority:** P1
**Personas:** A-001, A-003, A-004

---

### US-114: Accessibility Tree Generation from DOM

**As** P-004 Jordan (accessibility advocate), **I want** the browser to build an accessibility tree from the DOM, **so that** screen readers and agent tools can consume semantic structure.

**Acceptance Criteria:**
- [ ] Semantic elements (`<h1>`-`<h6>`, `<nav>`, `<main>`, `<article>`, `<button>`) map to correct accessibility roles
- [ ] `alt` text on images is exposed as the accessible name
- [ ] `aria-label` and `aria-role` attributes override default semantics
- [ ] The accessibility tree is queryable independently from the layout tree

**Phase:** 1 — Render
**Priority:** P1
**Personas:** P-004, A-001, A-003

---

### US-115: Viewport Sizing

**As** P-003 Maya (keyboard power user), **I want** to set the viewport dimensions and have the layout reflow accordingly, **so that** I can view pages at any window size.

**Acceptance Criteria:**
- [ ] Layout uses the viewport width as the initial containing block width
- [ ] Changing viewport size triggers a full relayout
- [ ] Viewport height establishes the visible area for scroll calculations
- [ ] Default viewport is configurable (e.g., 1024x768 for headless, window size for GUI)

**Phase:** 1 — Render
**Priority:** P1
**Personas:** P-003, A-002, P-001

---

### US-116: Vertical Scrolling

**As** P-003 Maya (keyboard power user), **I want** content taller than the viewport to be scrollable, **so that** I can access the full document.

**Acceptance Criteria:**
- [ ] Document height is computed from the layout tree
- [ ] Scroll offset shifts the rendered view without relayout
- [ ] Scroll position is queryable (for agents and keyboard navigation)
- [ ] `overflow: hidden` on an element clips its content and disables scrolling for that box

**Phase:** 1 — Render
**Priority:** P1
**Personas:** P-003, A-001

---

### US-117: ACID1 Test Compliance

**As** P-001 Kai (tool-building developer), **I want** the browser to pass the ACID1 test, **so that** I have a baseline confidence that core CSS and layout are correct.

**Acceptance Criteria:**
- [ ] The ACID1 reference page renders without visual defects when compared to the reference image
- [ ] All box model, color, and positioning rules exercised by ACID1 produce correct output
- [ ] An automated pixel-diff test confirms < 1% deviation from the reference rendering
- [ ] The test runs in CI and blocks merges on failure

**Phase:** 1 — Render
**Priority:** P0
**Personas:** P-001, P-002

---

### US-118: Agent-Queryable DOM Snapshot via MCP

**As** A-002 Crawler (headless data harvester agent), **I want** to retrieve a full DOM snapshot through MCP, **so that** I can extract structured data without rendering.

**Acceptance Criteria:**
- [ ] MCP tool `dom_snapshot()` returns the full DOM as a serialized tree (JSON)
- [ ] Each node includes tag, attributes, text content, and child references
- [ ] Snapshot includes document metadata (title, base URL, encoding)
- [ ] Snapshot generation completes in under 100ms for typical pages

**Phase:** 1 — Render
**Priority:** P1
**Personas:** A-002, A-004, A-001

---

### US-119: Security Boundary — Style Isolation

**As** A-003 Sentinel (security/privacy monitor agent), **I want** CSS parsing to reject resource loads and executable content, **so that** the style layer cannot be used as an attack vector.

**Acceptance Criteria:**
- [ ] CSS `url()` references are parsed but not fetched during Phase 1 (logged as deferred)
- [ ] `expression()` and `-moz-binding` are rejected during parsing
- [ ] No external resource is fetched without explicit approval from the resource policy
- [ ] CSS parse errors are logged with source location for audit

**Phase:** 1 — Render
**Priority:** P1
**Personas:** A-003, P-005
