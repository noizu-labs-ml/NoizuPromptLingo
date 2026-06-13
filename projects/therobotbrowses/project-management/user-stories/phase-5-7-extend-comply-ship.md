# User Stories — Phases 5–7: Extend, Comply, Ship

> **Project:** therobotbrowses — AI/LLM-native web browser (Rust)
> **Phases covered:** 5 (Extend), 6 (Comply), 7 (Ship)
> **Total stories:** 33

---

## Phase 5 — Extend

### US-501: Plugin Manifest Format and Loading

**As** P-001 Kai (tool-building developer), **I want** a declarative plugin manifest format (TOML/JSON) that declares permissions, entry points, and metadata, **so that** I can package and distribute browser plugins with a predictable structure.

**Acceptance Criteria:**
- [ ] Manifest schema is documented with required fields: name, version, permissions, entry points, author, description
- [ ] Browser discovers and loads plugins from a designated plugins directory on startup
- [ ] Invalid or malformed manifests produce clear error messages and do not crash the browser
- [ ] Plugin loading is lazy — code is not executed until the plugin is activated
- [ ] Manifest supports declaring minimum browser version compatibility

**Phase:** 5 — Extend
**Priority:** P0
**Personas:** P-001, A-001

---

### US-502: Content Script Injection

**As** P-001 Kai (tool-building developer), **I want** to inject JavaScript and CSS into specific web pages based on URL match patterns, **so that** I can modify page behavior and appearance on a per-site basis.

**Acceptance Criteria:**
- [ ] Content scripts are declared in the plugin manifest with URL match patterns (glob and regex)
- [ ] CSS is injected before first paint; JS is injected at configurable run timing (document_start, document_end, document_idle)
- [ ] Injected scripts run in an isolated world — they share DOM access but not JS global scope with the page
- [ ] Content scripts can communicate with the plugin background script via a message-passing API
- [ ] URL match patterns support include and exclude lists

**Phase:** 5 — Extend
**Priority:** P0
**Personas:** P-001, A-001, A-002

---

### US-503: Plugin API — DOM, Network, and Storage Access

**As** P-001 Kai (tool-building developer), **I want** a well-defined plugin API that provides controlled access to DOM inspection, network request interception, and persistent key-value storage, **so that** I can build powerful extensions without relying on fragile hacks.

**Acceptance Criteria:**
- [ ] DOM API allows reading and mutating page DOM from content scripts
- [ ] Network API allows observing, modifying, and blocking HTTP requests/responses (declarativeNetRequest-style)
- [ ] Storage API provides persistent key-value storage scoped per plugin (sync and local tiers)
- [ ] All API surfaces require explicit permission grants declared in the manifest
- [ ] API calls from unpermitted plugins return clear permission-denied errors
- [ ] API is versioned with a stability contract (stable, experimental, deprecated)

**Phase:** 5 — Extend
**Priority:** P0
**Personas:** P-001, A-001, A-004

---

### US-504: Plugin Sandboxing via WASM Isolation

**As** P-005 Suki (security analyst), **I want** plugins to execute inside WASM sandboxes with capability-based permissions, **so that** a malicious or buggy plugin cannot compromise the browser process or access unauthorized data.

**Acceptance Criteria:**
- [ ] Plugin background scripts run inside a WASM sandbox (e.g., Wasmtime) with no direct host access
- [ ] Sandbox enforces capability-based permissions — only manifest-declared APIs are available
- [ ] Memory and CPU limits are configurable per plugin; exceeding limits terminates the plugin gracefully
- [ ] File system access is virtualized and scoped to the plugin's storage directory
- [ ] Sandbox escape attempts are logged and reported to the user
- [ ] Plugin crashes are isolated — they do not affect other plugins or the browser process

**Phase:** 5 — Extend
**Priority:** P0
**Personas:** P-005, A-003, P-001

---

### US-505: Plugin Marketplace and Registry

**As** P-001 Kai (tool-building developer), **I want** a plugin registry where I can publish, discover, and install plugins, **so that** the ecosystem can grow and users can find useful extensions.

**Acceptance Criteria:**
- [ ] CLI tool or browser UI can search, install, update, and uninstall plugins from the registry
- [ ] Registry hosts plugin manifests, signatures, and download URLs (not necessarily binaries)
- [ ] Plugins are signed with author keys; unsigned plugins require explicit user consent
- [ ] Registry supports versioning with semver and dependency declarations
- [ ] Users can rate and flag plugins; flagged plugins are reviewed before removal
- [ ] Self-hosted registry option for enterprise/private deployments

**Phase:** 5 — Extend
**Priority:** P1
**Personas:** P-001, P-005, P-003

---

### US-506: Theming Engine for Browser Chrome

**As** P-003 Maya (keyboard power user), **I want** to customize the browser chrome (toolbar, tabs, sidebar, status bar) with custom CSS themes, **so that** I can make the browser match my aesthetic and reduce visual fatigue.

**Acceptance Criteria:**
- [ ] Themes are packaged as plugin-type manifests with CSS targeting browser chrome components
- [ ] Theme CSS uses a defined set of custom properties (--trb-bg-primary, --trb-text-primary, etc.) for stable theming
- [ ] Theme switching is instant (no restart required) and previews are available before applying
- [ ] Built-in light, dark, and high-contrast themes ship with the browser
- [ ] Themes cannot inject scripts or access page content — CSS only
- [ ] Invalid theme CSS is gracefully ignored without breaking chrome layout

**Phase:** 5 — Extend
**Priority:** P1
**Personas:** P-003, P-004, P-001

---

### US-507: Plugin-to-Plugin Communication

**As** P-001 Kai (tool-building developer), **I want** plugins to send messages to other installed plugins via a typed message bus, **so that** I can build composable extensions that interoperate without tight coupling.

**Acceptance Criteria:**
- [ ] Plugins can declare public message channels in their manifest
- [ ] Sending plugin specifies target plugin ID and channel; receiving plugin registers handlers
- [ ] Messages are serialized (JSON) and validated against optional schema declarations
- [ ] Communication requires mutual opt-in — receiver must declare willingness to accept messages from external plugins
- [ ] Message delivery is async with optional response callbacks
- [ ] Rate limiting prevents message flooding between plugins

**Phase:** 5 — Extend
**Priority:** P2
**Personas:** P-001, A-001, A-004

---

### US-508: Agent-as-Plugin Installation

**As** A-001 Claude (browsing copilot agent), **I want** to be installable as a browser plugin with access to the plugin API, **so that** I can integrate deeply with the browsing experience using the same extension model as human-authored plugins.

**Acceptance Criteria:**
- [ ] Agent plugins use the same manifest format as standard plugins with an additional `agent` section declaring LLM provider, model, and tool permissions
- [ ] Agent plugins have access to the full plugin API surface (DOM, network, storage) subject to manifest permissions
- [ ] Agent plugins can register for browser events (navigation, tab create/close, page load) as triggers
- [ ] Users can enable/disable agent plugins and review their permission grants independently
- [ ] Agent plugins can invoke other plugins via the plugin-to-plugin message bus
- [ ] Agent resource usage (API calls, tokens, compute) is tracked and surfaced in a dashboard

**Phase:** 5 — Extend
**Priority:** P1
**Personas:** A-001, A-003, A-004, P-001

---

### US-509: Plugin DevTools and Debugging

**As** P-001 Kai (tool-building developer), **I want** a built-in plugin developer console that shows logs, API calls, permission checks, and sandbox state, **so that** I can debug plugins efficiently during development.

**Acceptance Criteria:**
- [ ] Plugin DevTools panel is accessible from the browser's developer tools
- [ ] Console shows plugin logs, API call traces, and permission grant/deny events
- [ ] Live reload is supported — saving a manifest or script triggers hot reload without browser restart
- [ ] Breakpoints can be set in content scripts and background scripts
- [ ] Sandbox memory and CPU usage are visible in real time
- [ ] Error messages include actionable suggestions (e.g., "Permission 'network.intercept' not declared in manifest")

**Phase:** 5 — Extend
**Priority:** P1
**Personas:** P-001

---

### US-510: Plugin Permission Escalation Controls

**As** P-005 Suki (security analyst), **I want** plugin permission changes on update to require explicit user re-approval, **so that** a trusted plugin cannot silently escalate its access after installation.

**Acceptance Criteria:**
- [ ] Plugin updates that add new permissions trigger a user approval prompt before activation
- [ ] The prompt clearly shows which permissions are new vs. previously granted
- [ ] Users can reject the new permissions and remain on the previous version
- [ ] Permission downgrades (removing permissions) are applied silently
- [ ] A full permission audit log is available per plugin showing all grants and changes over time

**Phase:** 5 — Extend
**Priority:** P0
**Personas:** P-005, A-003, P-003

---

## Phase 6 — Comply

### US-601: ACID2 Test Pass

**As** P-001 Kai (tool-building developer), **I want** the browser's rendering engine to pass the ACID2 test completely, **so that** I can trust that fundamental CSS box model, positioning, and rendering are correct.

**Acceptance Criteria:**
- [ ] Browser renders the ACID2 reference page pixel-perfectly matching the reference rendering
- [ ] No visual artifacts, misaligned elements, or incorrect stacking
- [ ] ACID2 pass is verified in CI via headless screenshot comparison with tolerance < 1%
- [ ] Regressions against ACID2 block merges to main

**Phase:** 6 — Comply
**Priority:** P0
**Personas:** P-001, A-002

---

### US-602: ACID3 Test Target (>95/100)

**As** P-001 Kai (tool-building developer), **I want** the browser to score at least 95/100 on the ACID3 test, **so that** I can verify broad compliance with DOM, CSS, and ECMAScript standards.

**Acceptance Criteria:**
- [ ] Browser scores ≥ 95/100 on the ACID3 test suite
- [ ] Failing subtests are documented with root cause and priority for future fixes
- [ ] ACID3 score is tracked in CI with a regression threshold (score cannot decrease)
- [ ] Known intentional deviations (if any) are documented with rationale

**Phase:** 6 — Comply
**Priority:** P1
**Personas:** P-001, A-002

---

### US-603: Full Accessibility Tree

**As** P-004 Jordan (accessibility advocate), **I want** the browser to build a complete accessibility tree from the DOM with correct ARIA roles, states, and properties, **so that** assistive technologies receive accurate semantic information about page content.

**Acceptance Criteria:**
- [ ] Every DOM element maps to an appropriate accessibility tree node with computed role, name, and description
- [ ] ARIA attributes (role, aria-label, aria-labelledby, aria-describedby, aria-expanded, aria-checked, etc.) are reflected in the tree
- [ ] Implicit roles from HTML semantics (button, nav, main, article, etc.) are correctly computed
- [ ] Accessibility tree updates in response to DOM mutations (dynamic content, AJAX)
- [ ] Tree is inspectable via browser DevTools accessibility panel
- [ ] Accessibility tree conforms to the WAI-ARIA 1.2 specification

**Phase:** 6 — Comply
**Priority:** P0
**Personas:** P-004, A-001, P-003

---

### US-604: Screen Reader Integration

**As** P-004 Jordan (accessibility advocate), **I want** the browser to integrate with platform accessibility APIs (macOS Accessibility, AT-SPI on Linux, UIA on Windows), **so that** screen readers like VoiceOver, Orca, and NVDA can read and navigate web content.

**Acceptance Criteria:**
- [ ] Browser exposes the accessibility tree via the platform's native accessibility API
- [ ] Screen readers can read page content, navigate by headings/landmarks/links, and interact with form controls
- [ ] Live regions (aria-live) trigger screen reader announcements on content change
- [ ] Focus changes are communicated to the screen reader in real time
- [ ] Integration is tested with at least one screen reader per platform (VoiceOver, Orca, NVDA)
- [ ] Browser chrome (toolbar, tabs, menus) is also accessible via screen reader

**Phase:** 6 — Comply
**Priority:** P0
**Personas:** P-004, P-003

---

### US-605: Keyboard Navigation and Focus Management

**As** P-003 Maya (keyboard power user), **I want** complete keyboard navigation with correct tab order, focus indicators, and skip links, **so that** I can use the browser and web content entirely without a mouse.

**Acceptance Criteria:**
- [ ] Tab key cycles through all focusable elements in document order (or tabindex order)
- [ ] Focus indicators are always visible and meet WCAG 2.2 contrast requirements
- [ ] Skip-to-content mechanism is available for pages with navigation
- [ ] Arrow keys navigate within composite widgets (menus, tabs, trees, grids) per WAI-ARIA authoring practices
- [ ] Focus trapping works correctly in modal dialogs
- [ ] Browser chrome is fully keyboard-navigable (address bar, tabs, menus, settings)
- [ ] Custom focus order via tabindex is respected

**Phase:** 6 — Comply
**Priority:** P0
**Personas:** P-003, P-004, A-001

---

### US-606: CSS Flexbox Layout

**As** P-001 Kai (tool-building developer), **I want** the rendering engine to fully support CSS Flexbox layout, **so that** modern web pages using flex containers render correctly.

**Acceptance Criteria:**
- [ ] All Flexbox properties are supported: display:flex, flex-direction, flex-wrap, justify-content, align-items, align-content, flex-grow, flex-shrink, flex-basis, order, align-self, gap
- [ ] Passes the CSS Flexbox test suite from web-platform-tests (>95% pass rate)
- [ ] Nested flex containers render correctly
- [ ] Flex layout interacts correctly with min/max constraints, overflow, and margins

**Phase:** 6 — Comply
**Priority:** P0
**Personas:** P-001, A-002

---

### US-607: CSS Grid Layout

**As** P-001 Kai (tool-building developer), **I want** the rendering engine to fully support CSS Grid layout, **so that** complex two-dimensional page layouts render correctly.

**Acceptance Criteria:**
- [ ] All Grid properties are supported: display:grid, grid-template-columns/rows, grid-template-areas, grid-column/row, grid-gap, auto-fill/auto-fit, minmax(), repeat()
- [ ] Passes the CSS Grid test suite from web-platform-tests (>90% pass rate)
- [ ] Implicit and explicit grid tracks are computed correctly
- [ ] Grid layout interacts correctly with Flexbox, positioning, and overflow

**Phase:** 6 — Comply
**Priority:** P0
**Personas:** P-001, A-002

---

### US-608: Media Queries and Responsive Layout

**As** A-002 Crawler (headless data harvester agent), **I want** the browser to support CSS media queries for viewport dimensions, resolution, and prefers-color-scheme, **so that** I can render pages as they appear across different device configurations.

**Acceptance Criteria:**
- [ ] Media queries for width, height, min-width, max-width, min-height, max-height are evaluated correctly
- [ ] Device-pixel-ratio and resolution queries are supported
- [ ] prefers-color-scheme and prefers-reduced-motion queries reflect browser/OS settings
- [ ] Viewport resizing triggers media query re-evaluation and layout reflow
- [ ] Headless mode supports configurable viewport dimensions for responsive testing

**Phase:** 6 — Comply
**Priority:** P1
**Personas:** A-002, P-001

---

### US-609: Web Fonts (@font-face)

**As** P-002 Dr. Amara (researcher), **I want** the browser to support @font-face declarations for loading custom web fonts, **so that** pages render with their intended typography.

**Acceptance Criteria:**
- [ ] @font-face rules are parsed and fonts are fetched from declared URLs
- [ ] WOFF, WOFF2, TTF, and OTF formats are supported
- [ ] Font loading does not block initial render — fallback fonts display until custom fonts load (FOUT behavior configurable)
- [ ] Font subsetting via unicode-range is respected
- [ ] Font loading failures fall back gracefully to the next font in the stack
- [ ] Font cache persists across sessions to avoid redundant downloads

**Phase:** 6 — Comply
**Priority:** P1
**Personas:** P-002, P-001, A-002

---

### US-610: CSS Animations and Transitions

**As** P-003 Maya (keyboard power user), **I want** the browser to support CSS transitions and keyframe animations, **so that** interactive UI elements respond smoothly and pages with motion design render correctly.

**Acceptance Criteria:**
- [ ] CSS transition properties (transition-property, transition-duration, transition-timing-function, transition-delay) are supported
- [ ] CSS @keyframes animations with animation-* properties are supported
- [ ] Hardware-accelerated properties (transform, opacity) are composited on the GPU when available
- [ ] prefers-reduced-motion media query disables or reduces animations when set
- [ ] Animation frame rate targets 60fps; dropped frames are recoverable without layout thrash
- [ ] JavaScript animation APIs (requestAnimationFrame, Web Animations API) are supported

**Phase:** 6 — Comply
**Priority:** P1
**Personas:** P-003, P-001, A-002

---

### US-611: High-Contrast and Forced-Colors Mode

**As** P-004 Jordan (accessibility advocate), **I want** the browser to support forced-colors mode and the prefers-contrast media query, **so that** users with low vision can override page colors for readability.

**Acceptance Criteria:**
- [ ] forced-colors: active mode overrides page colors with system-defined high-contrast palette
- [ ] prefers-contrast media query (no-preference, more, less, custom) is supported
- [ ] System color keywords (Canvas, CanvasText, LinkText, etc.) resolve correctly in forced-colors mode
- [ ] Authors can use forced-color-adjust to opt specific elements out of forced colors
- [ ] High-contrast mode is togglable from browser settings without OS-level changes

**Phase:** 6 — Comply
**Priority:** P1
**Personas:** P-004, P-003

---

## Phase 7 — Ship

### US-701: Cross-Platform Packaging

**As** P-001 Kai (tool-building developer), **I want** the browser to produce native packages for macOS (.dmg/.app), Linux (.deb, .rpm, AppImage), and Windows (.msi, .exe), **so that** users can install it through familiar platform mechanisms.

**Acceptance Criteria:**
- [ ] CI pipeline produces signed release artifacts for all three platforms
- [ ] macOS build is a universal binary (arm64 + x86_64) in a signed and notarized .dmg
- [ ] Linux builds include .deb (Debian/Ubuntu), .rpm (Fedora/RHEL), and AppImage
- [ ] Windows build is a signed .msi installer with optional .exe portable variant
- [ ] Each package registers file associations (HTML, XHTML) and as a default browser candidate
- [ ] Package size is documented and tracked; bloat regressions trigger CI warnings

**Phase:** 7 — Ship
**Priority:** P0
**Personas:** P-001, P-003

---

### US-702: Auto-Update Mechanism

**As** P-003 Maya (keyboard power user), **I want** the browser to check for and install updates automatically in the background, **so that** I always have the latest features and security fixes without manual intervention.

**Acceptance Criteria:**
- [ ] Browser checks for updates on a configurable schedule (default: daily)
- [ ] Updates download in the background without interrupting browsing
- [ ] User is notified when an update is ready and can defer or apply immediately
- [ ] Updates are verified via cryptographic signatures before installation
- [ ] Rollback to the previous version is available if the update causes issues
- [ ] Update channel selection is supported (stable, beta, nightly)
- [ ] Auto-update can be disabled entirely for managed/enterprise deployments

**Phase:** 7 — Ship
**Priority:** P0
**Personas:** P-003, P-005, P-001

---

### US-703: Opt-In Crash Reporting and Telemetry

**As** P-001 Kai (tool-building developer), **I want** an opt-in crash reporting and anonymous usage telemetry system, **so that** I can identify and fix stability issues in the wild.

**Acceptance Criteria:**
- [ ] Crash reporter captures minidump, stack trace, browser version, OS version, and loaded plugins
- [ ] Telemetry is strictly opt-in — disabled by default with clear first-run prompt
- [ ] Users can review exactly what data will be sent before opting in
- [ ] Telemetry data is anonymized — no PII, no browsing history, no page content
- [ ] Crash reports are uploaded to a self-hosted endpoint (not a third-party service)
- [ ] Opt-in status can be changed at any time from settings
- [ ] A local crash log is always available regardless of opt-in status

**Phase:** 7 — Ship
**Priority:** P0
**Personas:** P-001, P-005, A-003

---

### US-704: User Profile and Sync

**As** P-002 Dr. Amara (researcher), **I want** to create a user profile that stores my settings, bookmarks, history, and plugin configuration, and optionally sync it across devices, **so that** my browsing environment is consistent everywhere I work.

**Acceptance Criteria:**
- [ ] User profile stores: settings, bookmarks, history, cookies, plugin list, theme, and saved passwords
- [ ] Multiple profiles are supported with fast profile switching
- [ ] Optional sync via encrypted cloud storage (user-provided endpoint or built-in service)
- [ ] Sync uses end-to-end encryption — the server cannot read profile data
- [ ] Conflict resolution for concurrent edits (last-write-wins with merge for bookmarks)
- [ ] Profiles can be exported and imported as encrypted archives

**Phase:** 7 — Ship
**Priority:** P1
**Personas:** P-002, P-003, P-005

---

### US-705: Bookmark Management

**As** P-002 Dr. Amara (researcher), **I want** a bookmark manager with folders, tags, search, and import/export, **so that** I can organize and retrieve my research references efficiently.

**Acceptance Criteria:**
- [ ] Bookmarks support folders (nested), tags, and descriptions
- [ ] Full-text search across bookmark titles, URLs, tags, and descriptions
- [ ] Import from Chrome, Firefox, and Safari bookmark formats (HTML and JSON)
- [ ] Export to HTML and JSON formats
- [ ] Bookmarks bar is toggleable and supports drag-and-drop reordering
- [ ] Duplicate bookmark detection warns before creating duplicates
- [ ] Keyboard shortcut to bookmark current page (Ctrl/Cmd+D)

**Phase:** 7 — Ship
**Priority:** P1
**Personas:** P-002, P-003, A-001

---

### US-706: Password Manager Integration

**As** P-005 Suki (security analyst), **I want** the browser to integrate with system keychain and third-party password managers (1Password, Bitwarden) via their browser extension APIs, **so that** users can autofill credentials securely without a built-in password store.

**Acceptance Criteria:**
- [ ] Browser exposes the Web Credentials API for password manager extensions to hook into
- [ ] Native messaging host protocol is supported for communicating with external password managers
- [ ] Built-in minimal credential store uses OS keychain (macOS Keychain, GNOME Keyring, Windows Credential Manager)
- [ ] Autofill UI shows credential suggestions on login forms without exposing passwords in plaintext
- [ ] Users can disable built-in credential storage entirely if using an external manager
- [ ] Credential autofill works with both standard and shadow-DOM login forms

**Phase:** 7 — Ship
**Priority:** P1
**Personas:** P-005, P-003, P-002

---

### US-707: Download Manager

**As** P-003 Maya (keyboard power user), **I want** a download manager that shows progress, supports pause/resume, and lets me organize downloads by type, **so that** I can manage file downloads efficiently.

**Acceptance Criteria:**
- [ ] Download progress bar shows speed, percentage, and estimated time remaining
- [ ] Downloads can be paused and resumed (if server supports Range requests)
- [ ] Default download directory is configurable; "ask every time" option is available
- [ ] Download history is searchable and clearable
- [ ] Dangerous file type warnings (executables, scripts) require explicit user confirmation
- [ ] Completed downloads can be opened or revealed in the file manager from the UI
- [ ] Keyboard shortcut opens the download manager (Ctrl/Cmd+J)

**Phase:** 7 — Ship
**Priority:** P1
**Personas:** P-003, P-002, A-002

---

### US-708: Print Support

**As** P-002 Dr. Amara (researcher), **I want** to print web pages and save them as PDF with correct pagination, headers/footers, and print-specific stylesheets, **so that** I can produce physical or archival copies of research material.

**Acceptance Criteria:**
- [ ] Print dialog supports page range, copies, orientation, and paper size selection
- [ ] Save-to-PDF produces a high-quality PDF with selectable text and embedded fonts
- [ ] @media print stylesheets are applied during print rendering
- [ ] Page breaks (break-before, break-after, break-inside) are respected
- [ ] Headers and footers (page number, URL, date) are configurable
- [ ] Print preview is available before committing to print
- [ ] Background graphics printing is optional (off by default)

**Phase:** 7 — Ship
**Priority:** P2
**Personas:** P-002, P-001

---

### US-709: First-Run Experience and Onboarding

**As** P-003 Maya (keyboard power user), **I want** a concise first-run onboarding flow that lets me import data from other browsers, set defaults, and learn key features, **so that** I can be productive immediately without reading documentation.

**Acceptance Criteria:**
- [ ] First-run wizard launches on initial startup with 3-5 steps maximum
- [ ] Import step offers to import bookmarks, history, passwords, and settings from Chrome, Firefox, and Safari
- [ ] Default browser prompt is shown (with option to skip)
- [ ] Quick tour highlights key differentiating features (agent integration, keyboard shortcuts, privacy controls)
- [ ] Theme selection (light/dark/system) is offered during onboarding
- [ ] Telemetry opt-in is presented with clear explanation
- [ ] Onboarding can be skipped entirely with a single click
- [ ] Onboarding can be re-accessed from settings

**Phase:** 7 — Ship
**Priority:** P1
**Personas:** P-003, P-004, P-002

---

### US-710: Agent Onboarding and Defaults

**As** A-001 Claude (browsing copilot agent), **I want** the first-run experience to include an agent setup step where users can enable/disable bundled agents and configure their API keys, **so that** the AI-native features are discoverable and correctly configured from the start.

**Acceptance Criteria:**
- [ ] Onboarding includes an optional "AI Assistant" step after basic setup
- [ ] Bundled agents are listed with descriptions, permission summaries, and enable/disable toggles
- [ ] API key configuration (for LLM providers) is handled in this step with validation
- [ ] Users who skip agent setup can configure agents later from settings
- [ ] Default agent permissions are conservative — users must explicitly grant elevated access
- [ ] A brief demo or example interaction shows what agents can do

**Phase:** 7 — Ship
**Priority:** P1
**Personas:** A-001, A-004, P-001, P-003

---

### US-711: Release Signing and Supply Chain Security

**As** P-005 Suki (security analyst), **I want** all release artifacts to be reproducibly built, cryptographically signed, and published with SLSA provenance attestations, **so that** users can verify the integrity and provenance of every download.

**Acceptance Criteria:**
- [ ] CI builds are reproducible — same source commit produces bit-identical artifacts
- [ ] All binaries are signed with the project's code-signing certificate (per-platform)
- [ ] SLSA Level 3 provenance attestations are generated and published alongside releases
- [ ] SHA-256 checksums are published for every artifact
- [ ] Users can verify signatures via a documented process in the release notes
- [ ] Build pipeline is hardened against dependency confusion and typosquatting attacks

**Phase:** 7 — Ship
**Priority:** P0
**Personas:** P-005, A-003, P-001
