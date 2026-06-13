# Accessibility & Security Requirements — Browser Reference

## Overview

This document covers browser-specific accessibility and security requirements. Both domains have mandatory legal or standards obligations that affect browser chrome (UI) as well as rendered web content. Requirements are annotated with the relevant specification and a priority designation for therobotbrowses.

Priority designations:
- **Launch** — Must be implemented before any public release
- **Iterate** — Implement in first year / first major iteration
- **Defer** — Implement when user demand or regulatory requirements arrive

---

## Part 1: Accessibility

### Legal Framework

#### United States

| Law / Rule | Applies To | Requirement |
|-----------|-----------|-------------|
| Americans with Disabilities Act (ADA) | All public-facing software | DOJ guidance: WCAG 2.1 AA is the accepted technical standard; WCAG 2.2 AA is the current best practice |
| Section 508 (Rehabilitation Act) | Federal agencies and contractors | Requires WCAG 2.1 AA Level conformance per the 2017 revised standards (36 CFR Part 1194) |
| 21st Century Communications and Video Accessibility Act (CVAA) | Advanced communications services | Applies if the browser includes VoIP or video chat features |

#### European Union

| Law / Rule | Applies To | Requirement |
|-----------|-----------|-------------|
| European Accessibility Act (EAA) — Directive 2019/882 | Consumer products/services sold in EU; enforcement begins June 2025 | Requires EN 301 549 v3.2.1 compliance (which references WCAG 2.2 via ISO/IEC 40500:2025) |
| Web Accessibility Directive — Directive 2016/2102 | EU public sector websites and apps | WCAG 2.1 AA minimum; public sector browsers or government-distributed browsers must comply |

#### United Kingdom

| Law / Rule | Applies To | Requirement |
|-----------|-----------|-------------|
| Equality Act 2010 | All public-facing services | Reasonable adjustments; WCAG 2.1 AA is the accepted technical standard |
| Public Sector Bodies Accessibility Regulations 2018 | UK public sector | WCAG 2.1 AA; WCAG 2.2 adoption is advancing |

---

### WCAG 2.2 AA Applied to Browser Chrome UI

The browser's own UI (address bar, tabs, toolbars, dialogs, menus, settings) must conform to WCAG 2.2 AA — not just the web content it renders.

#### Perceivable

| Requirement | SC | Priority |
|-------------|---|----------|
| All UI controls have accessible names | 1.1.1 (Non-text Content) | Launch |
| Focus indicators are visible (minimum 2px, 3:1 contrast ratio) | 2.4.11 (Focus Not Obscured — new in 2.2) | Launch |
| Text contrast ≥ 4.5:1; large text ≥ 3:1 | 1.4.3 | Launch |
| Non-text contrast ≥ 3:1 (icons, borders, focus rings) | 1.4.11 | Launch |
| Text resize to 200% without loss of content or functionality | 1.4.4 | Launch |
| Reflow at 320px viewport width without horizontal scroll | 1.4.10 | Iterate |
| Audio controls for any browser-initiated audio | 1.4.2 | Launch |

#### Operable

| Requirement | SC | Priority |
|-------------|---|----------|
| All chrome UI operable by keyboard alone | 2.1.1 | Launch |
| No keyboard traps within chrome | 2.1.2 | Launch |
| Skip to content link (or equivalent) from address bar | 2.4.1 | Iterate |
| Page/tab titles programmatically determinable | 2.4.2 | Launch |
| Focus order is logical and predictable | 2.4.3 | Launch |
| Link/button purpose determinable from name | 2.4.4 | Launch |
| Target size minimum 24×24 CSS pixels for chrome controls | 2.5.8 (new in 2.2) | Launch |
| Dragging movements have pointer alternative | 2.5.7 (new in 2.2) | Iterate |
| No pointer cancellation traps | 2.5.2 | Launch |

#### Understandable

| Requirement | SC | Priority |
|-------------|---|----------|
| Language of UI determinable | 3.1.1 | Launch |
| On focus, no unexpected context change | 3.2.1 | Launch |
| On input, no unexpected context change without warning | 3.2.2 | Launch |
| Consistent navigation within browser chrome | 3.2.3 | Launch |
| Error identification and description for chrome UI forms | 3.3.1/3.3.2 | Launch |
| Consistent help location | 3.2.6 (new in 2.2) | Iterate |
| Accessible authentication (no cognitive tests without alternative) | 3.3.8 (new in 2.2) | Iterate |

#### Robust

| Requirement | SC | Priority |
|-------------|---|----------|
| Name, role, value determinable for all UI controls | 4.1.2 | Launch |
| Status messages announced without focus change | 4.1.3 | Launch |

---

### Platform Accessibility API Integration

The browser must expose its chrome UI through the platform's native accessibility API. Screen readers, magnification software, switch access tools, and voice control systems use these APIs.

#### macOS — NSAccessibility (Cocoa Accessibility)

| Requirement | Priority |
|-------------|----------|
| All views implement `NSAccessibilityProtocol` | Launch |
| `accessibilityRole` set for all controls (e.g., `NSAccessibilityButtonRole`, `NSAccessibilityTextFieldRole`) | Launch |
| `accessibilityLabel` / `accessibilityTitle` for all interactive elements | Launch |
| `accessibilityValue` for text fields, sliders, checkboxes | Launch |
| `accessibilityPerformAction` for `NSAccessibilityPressAction` (buttons) and `NSAccessibilityShowMenuAction` | Launch |
| Web content accessibility tree exposed via `AXWebArea` | Launch |
| VoiceOver announcements for navigation events (page load, tab switch, dialog open) | Launch |
| Focus tracking: VoiceOver cursor follows programmatic focus | Launch |

#### Linux — AT-SPI2 (Assistive Technology Service Provider Interface)

| Requirement | Priority |
|-------------|----------|
| Implement AT-SPI2 via `atk` library (or `atspi2` directly) | Launch |
| All UI elements registered with `AtkObject` | Launch |
| `AtkRole` assigned correctly for all controls | Launch |
| Text interfaces (`AtkText`) for editable fields | Launch |
| Action interfaces (`AtkAction`) for buttons and links | Launch |
| Accessible component tree reflects visual hierarchy | Launch |
| Orca screen reader compatibility tested | Iterate |
| Event notifications via `atk_object_notify_state_change()` | Launch |

#### Windows — UI Automation (UIA)

| Requirement | Priority |
|-------------|----------|
| Implement IUIAutomationProvider for all chrome controls | Launch |
| Set `ControlType` (e.g., `UIA_ButtonControlTypeId`, `UIA_EditControlTypeId`) | Launch |
| Implement `Name` property for all elements | Launch |
| Implement Value Pattern for text fields | Launch |
| Implement Invoke Pattern for buttons | Launch |
| Implement Selection Pattern for lists and tabs | Launch |
| NVDA and JAWS compatibility tested | Iterate |
| Windows Narrator compatibility tested | Iterate |
| IAccessible2 fallback for legacy AT support | Iterate |

---

### Keyboard Navigation Requirements

| Area | Requirement | Priority |
|------|-------------|----------|
| Address bar | Focusable via keyboard shortcut (Ctrl+L / Cmd+L); Escape clears/cancels | Launch |
| Tabs | Keyboard navigation between tabs (Ctrl+Tab / Ctrl+Shift+Tab); close with Ctrl+W | Launch |
| Toolbar controls | All toolbar buttons reachable by Tab; activated by Enter/Space | Launch |
| Context menus | Opened by keyboard shortcut (Shift+F10 or application key); navigated by arrow keys; dismissed by Escape | Launch |
| Modal dialogs | Focus trapped within dialog until closed; closed by Escape | Launch |
| Downloads bar | Keyboard accessible; each download item focusable | Iterate |
| Settings UI | Fully keyboard navigable | Launch |
| Page zoom controls | Keyboard shortcuts (Ctrl++/Ctrl+-/Ctrl+0) | Launch |
| Find in page | Ctrl+F opens; Escape closes; Tab navigates within find bar | Launch |
| DevTools | Fully keyboard navigable (independently from page content) | Iterate |

---

### Focus Management: Chrome ↔ Content

The browser must maintain a coherent focus model between its chrome UI and the rendered web content.

| Requirement | Priority |
|-------------|----------|
| F6 / Shift+F6 cycles focus between address bar, content, other chrome panels | Iterate |
| When loading a new page, focus moves to document start (or skip nav) | Launch |
| Tab from address bar enters document; Shift+Tab exits document to chrome | Launch |
| Modal dialogs (browser-native: cert errors, download prompts) trap focus correctly | Launch |
| Page `<dialog>` elements with `showModal()` are focus-trapped per HTML spec | Launch |
| Focus is restored to triggering element when modal closes | Launch |
| `autofocus` attribute honored on page load | Launch |

---

### Screen Reader Announcements

| Event | Announcement | Priority |
|-------|-------------|----------|
| Page load complete | Page title announced | Launch |
| Navigation (SPA) | New page title announced; live region for status | Launch |
| Tab switch | New tab title announced | Launch |
| Download started | "Downloading [filename]" announcement | Iterate |
| Certificate error | Error announced before any interaction | Launch |
| Popup blocked | "Popup blocked" announced | Iterate |
| Form submission error | Error announced and focus moved to error | Launch |

---

### High Contrast / Forced Colors

| Requirement | Priority |
|-------------|----------|
| Browser chrome respects OS forced-colors mode (Windows High Contrast) | Launch |
| `forced-colors` media query honored in rendered web content | Launch |
| `prefers-contrast` media query supported | Launch |
| Custom chrome themes do not override forced-colors mode | Launch |
| System color keywords (`ButtonText`, `CanvasText`, `LinkText`, etc.) used in chrome CSS | Launch |

---

### Touch and Voice Accessibility

| Requirement | Platform | Priority |
|-------------|---------|----------|
| All chrome controls meet 44×44pt minimum touch target (Apple HIG) / 48×48dp (Material) | iOS/Android | Iterate |
| Pinch-to-zoom not blocked in chrome (user can zoom in on any content) | Mobile | Launch |
| iOS VoiceOver swipe navigation works in chrome | iOS | Iterate |
| Android TalkBack swipe navigation works in chrome | Android | Iterate |
| Voice Control (macOS) works for all chrome controls | macOS | Iterate |
| Voice Access (Android) targets correctly assigned | Android | Iterate |
| Switch access (iOS AssistiveTouch / Android Switch Access) navigates chrome | Mobile | Defer |

---

## Part 2: Security

### Process Isolation and Sandboxing

| Component | Requirement | Priority |
|-----------|-------------|----------|
| Renderer processes | Each tab/frame runs in a separate sandboxed process (OS-level sandbox, no filesystem/network syscalls) | Launch |
| JavaScript engine | Runs in renderer process sandbox | Launch |
| GPU process | Separate GPU process for compositing | Iterate |
| Network process | Separate network process (prevents renderer from making raw network calls) | Iterate |
| Plugin processes | NPAPI/legacy plugins disallowed; any plugin in separate sandboxed process | Launch |
| Site isolation | Different-origin iframes get separate renderer processes (Spectre mitigation) | Iterate |
| OS sandbox | Platform-specific: `seccomp-bpf` (Linux), App Sandbox (macOS), AppContainer (Windows) | Launch |

---

### Certificate Verification

| Requirement | Spec | Priority |
|-------------|------|----------|
| X.509 v3 certificate parsing | RFC 5280 | Launch |
| Certificate chain validation | RFC 5280 §6 | Launch |
| Root CA trust store | Mozilla NSS / OS trust store | Launch |
| Certificate Transparency (CT) verification | RFC 9162; Chrome CT Policy | Iterate |
| OCSP stapling support | RFC 6961 | Iterate |
| CRL checking (as fallback) | RFC 5280 §5 | Iterate |
| OCSP hard-fail policy configurable | Chrome CT Policy | Iterate |
| EV (Extended Validation) certificate UI indicator | CAB Forum EV Guidelines | Iterate |
| Certificate pinning (HPKP) — deprecated, do not implement | — | Do not implement |
| Expect-CT header support | RFC 9163 | Iterate |

---

### Same-Origin Policy

| Requirement | Spec | Priority |
|-------------|------|----------|
| Origin tuple: (scheme, host, port) | WHATWG HTML §7.5 | Launch |
| Cross-origin resource isolation | WHATWG Fetch | Launch |
| `document.domain` setter restricted | WHATWG HTML | Launch |
| Cross-origin `postMessage` with origin verification | WHATWG HTML | Launch |
| CORS enforcement for XHR and Fetch | WHATWG Fetch | Launch |
| `null` origin for sandboxed frames | WHATWG HTML | Launch |
| Cross-origin read blocking (CORB) | Fetch Metadata | Iterate |

---

### CSP Enforcement

| Requirement | Spec | Priority |
|-------------|------|----------|
| `Content-Security-Policy` header parsing | W3C CSP L3 | Launch |
| `default-src`, `script-src`, `style-src`, `img-src`, `connect-src` directives | CSP L3 | Launch |
| `nonce` and `hash` sources for inline scripts/styles | CSP L3 | Launch |
| `strict-dynamic` | CSP L3 | Launch |
| `report-uri` and `report-to` directives | CSP L3 | Iterate |
| `Content-Security-Policy-Report-Only` | CSP L3 | Iterate |
| `frame-ancestors` directive | CSP L3 | Launch |
| `upgrade-insecure-requests` | W3C | Launch |
| `Trusted-Types` enforcement | W3C Trusted Types | Defer |

---

### Phishing and Malware Protection

| Requirement | Priority |
|-------------|----------|
| Safe Browsing API integration (Google Safe Browsing or equivalent) | Iterate |
| Local blocklist with periodic updates | Iterate |
| Warning page for confirmed malware/phishing URLs (interstitial) | Iterate |
| Download file malware scanning (reputation-based) | Iterate |
| IDN homograph attack detection and display (Punycode fallback) | Launch |
| Lookalike domain warnings | Defer |

---

### Extension Sandboxing

| Requirement | Priority |
|-------------|----------|
| Extensions run in separate renderer processes | Phase 5 (Extend) |
| Extension permissions model with explicit grant | Phase 5 |
| Manifest V3 or equivalent (no persistent background pages, no remote code execution) | Phase 5 |
| Content scripts isolated from page JS context | Phase 5 |
| No extension access to renderer process internals | Phase 5 |

---

### Private Browsing Requirements

| Requirement | Priority |
|-------------|----------|
| No history written to disk during private session | Launch |
| No cookies persisted across private session boundaries | Launch |
| No cache entries written to disk in private mode | Launch |
| No form autofill data saved in private mode | Launch |
| Separate cookie jar from normal session | Launch |
| Third-party cookie blocking in private mode | Launch |
| Partitioned storage (State Partitioning) in private mode | Launch |
| No IndexedDB / Web Storage persisted in private mode | Launch |
| Private mode windows not included in session restore | Launch |
| OS-level protections: no thumbnails, no taskbar previews of private windows | Iterate |

---

### Credential Security

| Requirement | Priority |
|-------------|----------|
| Saved passwords encrypted at rest (OS keychain or equivalent) | Launch |
| Saved passwords not accessible to web content | Launch |
| Autofill only on HTTPS origins for password fields | Launch |
| `autocomplete="off"` honored for sensitive fields in non-password-manager contexts | Launch |
| Credential Management API (W3C) | Iterate |
| WebAuthn / FIDO2 support | Iterate |
| Breach detection for saved passwords (HaveIBeenPwned integration or equivalent) | Defer |

---

### WebRTC IP Leak Prevention

| Requirement | Priority |
|-------------|----------|
| WebRTC ICE candidate generation respects proxy settings | Launch |
| Default: mDNS obfuscation for local IP candidates | Launch |
| `about:config` / settings to disable WebRTC entirely | Launch |
| No reflexive candidates exposed when VPN is active (configurable) | Iterate |
| Implement RFC 8828 (WebRTC Local IP Policy) | Iterate |

---

### Fingerprinting Resistance

| Requirement | Priority |
|-------------|----------|
| Canvas fingerprinting noise injection in private/strict mode | Iterate |
| WebGL parameter normalization in strict mode | Iterate |
| `navigator.hardwareConcurrency` and `deviceMemory` rounded/capped | Iterate |
| `screen.width`/`screen.height` bucketed in private mode | Iterate |
| Font enumeration restricted (system fonts only, no JS enumeration) | Iterate |
| `navigator.plugins` returns empty or minimal list | Launch |
| `navigator.doNotTrack` removed (deprecated) | — |
| User-Agent Client Hints (UA-CH) by default returns minimal UA string | Launch |
| Timezone clamping in private mode | Defer |
| `AudioContext` fingerprinting noise | Defer |

---

### HTTPS-Only Mode

| Requirement | Priority |
|-------------|----------|
| HTTPS-only mode option in settings | Launch |
| Auto-upgrade HTTP to HTTPS (HSTS preload list) | Launch |
| Warning page for HTTP sites when HTTPS-only is enabled | Launch |
| HSTS preload list included in binary | Launch |
| `Upgrade-Insecure-Requests` header sent on all requests | Launch |
| Mixed content blocked by default | Launch |
| Mixed content upgrade for passive resources (images, video) | Iterate |

---

### Supply Chain Security

| Requirement | Priority |
|-------------|----------|
| Release binaries code-signed with developer certificate | Launch |
| macOS: Notarized with Apple Notarization Service | Launch |
| Windows: Authenticode signed | Launch |
| Linux: GPG-signed packages / distro signature | Iterate |
| SBOM (Software Bill of Materials) published with releases | Iterate |
| SLSA Level 2 build provenance | Iterate |
| SLSA Level 3 hermetic builds | Defer |
| Dependency audit in CI (e.g., `cargo audit`, `npm audit`) | Launch |
| Reproducible builds | Defer |

---

## Priority Summary Table

| Requirement | Domain | Priority |
|-------------|--------|----------|
| WCAG 2.2 AA — chrome UI conformance | Accessibility | Launch |
| Platform AT API integration (NSAccessibility / AT-SPI2 / UIA) | Accessibility | Launch |
| Keyboard navigability — all chrome controls | Accessibility | Launch |
| Focus management (chrome ↔ content) | Accessibility | Launch |
| Screen reader announcements (page load, tab switch) | Accessibility | Launch |
| Forced-colors / high contrast mode | Accessibility | Launch |
| Process isolation (renderer sandbox) | Security | Launch |
| TLS 1.3 + certificate chain validation | Security | Launch |
| Same-origin policy enforcement | Security | Launch |
| CSP Level 3 enforcement | Security | Launch |
| Private browsing (no persistence) | Security | Launch |
| HTTPS-only mode + HSTS preload | Security | Launch |
| IDN homograph attack protection | Security | Launch |
| Code signing (macOS/Windows) | Security | Launch |
| Certificate Transparency | Security | Iterate |
| Site isolation (Spectre mitigation) | Security | Iterate |
| WebRTC IP leak prevention (mDNS) | Security | Launch |
| Fingerprinting resistance | Security | Iterate |
| Phishing/malware protection | Security | Iterate |
| WebAuthn / FIDO2 | Security | Iterate |
| SLSA build provenance | Security | Iterate |
| EN 301 549 Ch. 11 compliance | Accessibility | Launch (EU) |
| Touch accessibility (mobile) | Accessibility | Iterate |
| Switch access | Accessibility | Defer |
| Extension sandboxing | Security | Phase 5 |
| SLSA Level 3 / reproducible builds | Security | Defer |
