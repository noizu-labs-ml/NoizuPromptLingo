# W3C / WHATWG / IETF Specifications — Browser Reference

## Overview

This document catalogs the specifications a browser engine must implement, organized by domain. Priority designations:
- **MVP** — Must implement before first public release; blocks core functionality
- **P2** — Should implement in first year; expected by most sites
- **P3** — Implement when relevant use cases arise; niche or advanced

---

## 1. HTML & DOM

| Spec | Identifier | Status | Priority |
|------|-----------|--------|----------|
| HTML Living Standard | WHATWG HTML | Living Standard | MVP |
| DOM Living Standard | WHATWG DOM | Living Standard | MVP |
| Infra Standard | WHATWG Infra | Living Standard | MVP |
| Encoding Standard | WHATWG Encoding | Living Standard | MVP |
| URL Standard | WHATWG URL | Living Standard | MVP |
| MIME Sniffing Standard | WHATWG MIME Sniffing | Living Standard | MVP |
| Fetch Standard | WHATWG Fetch | Living Standard | MVP |
| Streams Standard | WHATWG Streams | Living Standard | P2 |
| Console Standard | WHATWG Console | Living Standard | P2 |
| Notifications API | WHATWG Notifications | Living Standard | P2 |
| Storage Standard | WHATWG Storage | Living Standard | P2 |
| HTML Sanitizer API | W3C | WD | P3 |

### Key HTML Living Standard Modules

The WHATWG HTML Living Standard is a monolithic document covering:
- Document parsing (HTML5 parser — tokenization, tree construction)
- Element semantics (all HTML elements and attributes)
- Scripting (`<script>`, module scripts, `import()`)
- Forms and form validation
- `<canvas>` 2D context API
- Media elements (`<video>`, `<audio>`)
- Web Workers (shared and dedicated)
- `postMessage` and `MessageChannel`
- History API (`pushState`, `replaceState`)
- `<template>` and `shadowrootmode`
- Custom elements and `customElements` registry
- `<dialog>` element
- `<details>`/`<summary>`
- Drag and drop API
- `navigator` object
- `window.open()` and cross-origin windowing

---

## 2. CSS Specifications

### Layout

| Spec | Level | Status | Priority |
|------|-------|--------|----------|
| CSS 2.1 | — | W3C REC (2011, errata 2023) | MVP |
| CSS Box Model | L3/L4 | CR | MVP |
| CSS Display | L3 | CR | MVP |
| CSS Positioned Layout | L3 | CR | MVP |
| CSS Flexbox | L1 | CR | MVP |
| CSS Grid Layout | L1 | CR | MVP |
| CSS Grid Layout | L2 | CR | P2 |
| CSS Multi-column Layout | L1 | CR | P2 |
| CSS Fragmentation | L3 | CR | P2 |
| CSS Table | L3 | WD | P2 |
| CSS Overflow | L3 | CR | MVP |
| CSS Overflow | L4 | WD | P3 |

### Box Model and Sizing

| Spec | Level | Status | Priority |
|------|-------|--------|----------|
| CSS Box Sizing | L3 | CR | MVP |
| CSS Intrinsic & Extrinsic Sizing | L3 | CR | MVP |
| CSS Intrinsic & Extrinsic Sizing | L4 | WD | P3 |
| CSS Logical Properties and Values | L1 | CR | P2 |
| CSS Containment | L2 | CR | P2 |
| CSS Containment | L3 | WD | P3 |

### Cascade and Inheritance

| Spec | Level | Status | Priority |
|------|-------|--------|----------|
| CSS Cascade | L4 | CR | MVP |
| CSS Cascade | L5 | CR | P2 |
| CSS Cascade | L6 | WD | P3 |
| CSS Custom Properties (Variables) | L1 | CR | MVP |
| CSS Custom Properties (`@property`) | L1 | CR | P2 |

### Selectors

| Spec | Level | Status | Priority |
|------|-------|--------|----------|
| Selectors | L4 | CR | MVP |
| CSS Pseudo-Elements | L4 | WD | P2 |

### Visual Formatting

| Spec | Level | Status | Priority |
|------|-------|--------|----------|
| CSS Color | L4 | CR | MVP |
| CSS Color | L5 | WD | P3 |
| CSS Images | L4 | CR | P2 |
| CSS Backgrounds and Borders | L3 | CR | MVP |
| CSS Backgrounds and Borders | L4 | WD | P3 |
| CSS Shapes | L1 | CR | P2 |
| CSS Masking | L1 | CR | P2 |
| CSS Filter Effects | L1 | CR | P2 |
| CSS Compositing and Blending | L1 | CR | P2 |
| CSS Transforms | L1 | CR | P2 |
| CSS Transforms | L2 | WD | P3 |
| CSS Transitions | L1 | CR | P2 |
| CSS Animations | L1 | CR | P2 |
| CSS Animations | L2 | WD | P3 |
| Web Animations | L1 | CR | P2 |

### Text

| Spec | Level | Status | Priority |
|------|-------|--------|----------|
| CSS Text | L3 | CR | MVP |
| CSS Text | L4 | WD | P2 |
| CSS Text Decoration | L3 | CR | MVP |
| CSS Text Decoration | L4 | WD | P3 |
| CSS Fonts | L4 | CR | MVP |
| CSS Fonts | L5 | WD | P3 |
| CSS Writing Modes | L4 | CR | P2 |
| CSS Ruby Annotation Layout | L1 | WD | P3 |

### Miscellaneous CSS

| Spec | Level | Status | Priority |
|------|-------|--------|----------|
| CSS Generated Content | L3 | WD | MVP |
| CSS Lists and Counters | L3 | CR | MVP |
| CSS Values and Units | L4 | CR | MVP |
| CSS Values and Units | L5 | WD | P3 |
| CSS Paged Media | L3 | WD | P3 |
| CSS Will-Change | L1 | CR | P2 |
| CSS Viewport | L1 | CR | P2 |
| CSS Environment Variables | L1 | WD | P2 |
| CSS Scrollbars | L1 | CR | P2 |
| CSS Scroll Snap | L1 | CR | P2 |
| CSS Overscroll Behavior | L1 | CR | P2 |
| CSS Nesting | L1 | CR | P2 |
| CSS Anchor Positioning | L1 | WD | P3 |
| CSS View Transitions | L1 | CR | P3 |
| CSS Scoping | L1 | WD | P3 |

---

## 3. JavaScript / ECMAScript

| Spec | Identifier | Status | Priority |
|------|-----------|--------|----------|
| ECMAScript Language Specification | ECMA-262 (2024) | ECMA Standard | MVP |
| ECMAScript Internationalization API | ECMA-402 (2024) | ECMA Standard | P2 |
| JSON | ECMA-404 | ECMA Standard | MVP |
| Web IDL | W3C WebIDL | CR | MVP |
| Structured Clone Algorithm | WHATWG HTML §2.7.6 | Living Standard | MVP |
| JavaScript Modules | WHATWG HTML §8.1.6 | Living Standard | MVP |
| Import Maps | WICG | WD | P2 |
| TC39 Proposals (Stage 4) | ECMA TC39 | Normative | P2 |

### Key ECMAScript Features Required for Modern Web

| Feature | Spec Location | Priority |
|---------|--------------|----------|
| Promises and async/await | ECMA-262 | MVP |
| Arrow functions, destructuring, spread | ECMA-262 | MVP |
| `class` syntax | ECMA-262 | MVP |
| `Map`, `Set`, `WeakMap`, `WeakSet` | ECMA-262 | MVP |
| `Symbol` | ECMA-262 | MVP |
| Generators and iterators | ECMA-262 | MVP |
| `Proxy` and `Reflect` | ECMA-262 | MVP |
| `SharedArrayBuffer` and `Atomics` | ECMA-262 | P2 |
| `BigInt` | ECMA-262 | P2 |
| Logical assignment operators | ECMA-262 | P2 |
| `Array.at()`, `Object.hasOwn()` | ECMA-262 | P2 |

---

## 4. Networking RFCs

### HTTP

| Spec | RFC | Status | Priority |
|------|-----|--------|----------|
| HTTP/1.1 Semantics | RFC 9110 | Internet Standard | MVP |
| HTTP/1.1 Caching | RFC 9111 | Internet Standard | MVP |
| HTTP/1.1 Authentication | RFC 7235 | Internet Standard | MVP |
| HTTP/1.1 on TCP | RFC 9112 | Internet Standard | MVP |
| HTTP/2 | RFC 9113 | Proposed Standard | MVP |
| HTTP/3 | RFC 9114 | Proposed Standard | P2 |
| QPACK (HTTP/3 header compression) | RFC 9204 | Proposed Standard | P2 |

### TLS and Cryptography

| Spec | RFC | Status | Priority |
|------|-----|--------|----------|
| TLS 1.3 | RFC 8446 | Proposed Standard | MVP |
| TLS 1.2 | RFC 5246 | Historic (still required) | MVP |
| OCSP | RFC 6960 | Draft Standard | MVP |
| Certificate Revocation List Profile | RFC 5280 | Draft Standard | MVP |
| Certificate Transparency | RFC 9162 (SCT List) | Experimental | P2 |
| HKDF | RFC 5869 | Informational | MVP |
| ALPN | RFC 7301 | Proposed Standard | MVP |

### WebSocket

| Spec | Identifier | Status | Priority |
|------|-----------|--------|----------|
| WebSocket Protocol | RFC 6455 | Proposed Standard | MVP |
| WebSocket over HTTP/2 | RFC 8441 | Proposed Standard | P2 |

### DNS

| Spec | RFC | Status | Priority |
|------|-----|--------|----------|
| DNS over HTTPS (DoH) | RFC 8484 | Proposed Standard | P2 |
| DNS over TLS (DoT) | RFC 7858 | Proposed Standard | P3 |
| DNSSEC | RFC 4033–4035 | Proposed Standard | P3 |

### Cookies and Headers

| Spec | Identifier | Status | Priority |
|------|-----------|--------|----------|
| HTTP State Management (Cookies) | RFC 6265 / RFC 6265bis | Draft | MVP |
| SameSite Cookies | RFC 6265bis | Draft | MVP |
| Strict Transport Security (HSTS) | RFC 6797 | Proposed Standard | MVP |
| Cross-Origin Resource Sharing (CORS) | WHATWG Fetch | Living Standard | MVP |
| Content Security Policy Level 3 | W3C CSP L3 | CR | MVP |
| Referrer Policy | W3C | CR | MVP |
| Origin Header | RFC 6454 | Proposed Standard | MVP |

---

## 5. Security Standards

| Spec | Identifier | Status | Priority |
|------|-----------|--------|----------|
| Content Security Policy Level 3 | W3C CSP L3 | CR | MVP |
| Subresource Integrity (SRI) | W3C | REC | MVP |
| Referrer Policy | W3C | CR | MVP |
| Same-Origin Policy | WHATWG HTML §7.5 | Living Standard | MVP |
| Mixed Content | W3C | CR | MVP |
| Secure Contexts | W3C | CR | MVP |
| Cross-Origin Opener Policy (COOP) | WHATWG HTML | Living Standard | P2 |
| Cross-Origin Embedder Policy (COEP) | WHATWG HTML | Living Standard | P2 |
| Cross-Origin Resource Policy (CORP) | Fetch | Living Standard | P2 |
| Permissions Policy | W3C | WD | P2 |
| Fetch Metadata Request Headers | W3C | CR | P2 |
| Origin-Keyed Agent Clusters | WHATWG HTML | Living Standard | P2 |
| Trusted Types | W3C | WD | P3 |
| Web Cryptography API | W3C WebCrypto | REC | MVP |
| Credential Management | W3C | CR | P2 |
| Web Authentication (WebAuthn) | W3C | REC | P2 |

---

## 6. Accessibility

| Spec | Identifier | Status | Priority |
|------|-----------|--------|----------|
| Web Content Accessibility Guidelines 2.2 | WCAG 2.2 / ISO 40500:2025 | W3C REC | MVP |
| WAI-ARIA 1.2 | W3C | REC | MVP |
| Accessible Rich Internet Applications (ARIA) in HTML | W3C | REC | MVP |
| Core Accessibility API Mappings 1.2 (Core-AAM) | W3C | REC | MVP |
| HTML Accessibility API Mappings (HTML-AAM) | W3C | REC | MVP |
| SVG Accessibility API Mappings (SVG-AAM) | W3C | WD | P2 |
| CSS Accessibility API Mappings | W3C | WD | P3 |
| Accessible Name and Description Computation 1.2 | W3C | REC | MVP |
| WCAG 2.1 (superseded by 2.2) | WCAG 2.1 | REC | — |

---

## 7. Media & Graphics

### SVG

| Spec | Identifier | Status | Priority |
|------|-----------|--------|----------|
| SVG 2 | W3C SVG 2 | CR | P2 |
| SVG 1.1 (SE) | W3C SVG 1.1 | REC | MVP |

### Canvas

| Spec | Identifier | Status | Priority |
|------|-----------|--------|----------|
| HTML Canvas 2D Context | WHATWG HTML §4.12.5 | Living Standard | MVP |
| OffscreenCanvas | WHATWG HTML | Living Standard | P2 |

### WebGL and WebGPU

| Spec | Identifier | Status | Priority |
|------|-----------|--------|----------|
| WebGL 1.0 | Khronos | REC | P2 |
| WebGL 2.0 | Khronos | REC | P2 |
| WebGPU | W3C | CR | P3 |
| WGSL (WebGPU Shading Language) | W3C | CR | P3 |

### Audio and Video

| Spec | Identifier | Status | Priority |
|------|-----------|--------|----------|
| Web Audio API | W3C | REC | P2 |
| Media Source Extensions | W3C | REC | P2 |
| Encrypted Media Extensions | W3C | REC | P3 |
| WebRTC 1.0 | W3C | REC | P2 |
| WebRTC ORTC | W3C CG | CG Report | P3 |
| Media Capture and Streams | W3C | CR | P2 |
| MediaRecorder | W3C | CR | P2 |
| WebCodecs | W3C | CR | P3 |

### Image Formats

| Format | Spec | Priority |
|--------|------|----------|
| PNG | ISO/IEC 15948:2004 | MVP |
| JPEG | ISO/IEC 10918-1 | MVP |
| GIF89a | CompuServe | MVP |
| WebP | Google (open spec) | MVP |
| AVIF | AOM AV1 / ISO 23000-22 | P2 |
| HEIF/HEIC | ISO/IEC 23008-12 | P3 |
| SVG (raster src) | W3C SVG | P2 |
| ICO | Microsoft | MVP |

---

## 8. Storage & APIs

### Storage

| Spec | Identifier | Status | Priority |
|------|-----------|--------|----------|
| Web Storage (localStorage, sessionStorage) | WHATWG | Living Standard | MVP |
| IndexedDB 3.0 | W3C | CR | P2 |
| Cookie Store API | WICG | WD | P3 |
| File API | W3C | WD | P2 |
| File System Access API | WICG/W3C | WD | P3 |
| Cache API | W3C Service Workers | CR | P2 |
| Storage Quota API | WHATWG Storage | Living Standard | P2 |

### Workers and Messaging

| Spec | Identifier | Status | Priority |
|------|-----------|--------|----------|
| Web Workers | WHATWG HTML | Living Standard | P2 |
| Service Workers | W3C | CR | P2 |
| Shared Workers | WHATWG HTML | Living Standard | P3 |
| Broadcast Channel API | WHATWG HTML | Living Standard | P2 |
| Channel Messaging API | WHATWG HTML | Living Standard | P2 |

### Navigation and History

| Spec | Identifier | Status | Priority |
|------|-----------|--------|----------|
| History API | WHATWG HTML | Living Standard | MVP |
| Navigation API | WICG/W3C | WD | P3 |

### Browser APIs

| Spec | Identifier | Status | Priority |
|------|-----------|--------|----------|
| Intersection Observer | W3C | WD | P2 |
| Resize Observer | W3C | CR | P2 |
| Mutation Observer | WHATWG DOM | Living Standard | P2 |
| Performance Timeline | W3C | CR | P2 |
| Navigation Timing | W3C | CR | P2 |
| Resource Timing | W3C | CR | P2 |
| User Timing | W3C | CR | P2 |
| Paint Timing | W3C | WD | P2 |
| Clipboard API | W3C | WD | P2 |
| Pointer Events | W3C | REC | P2 |
| Touch Events | W3C | CR | P2 |
| Gamepad API | W3C | CR | P3 |
| Geolocation API | W3C | REC | P2 |
| Screen Orientation API | W3C | WD | P3 |
| Wake Lock API | W3C | CR | P3 |
| Web Share API | W3C | CR | P3 |
| Web Locks API | W3C | CR | P3 |
| Prioritized Task Scheduling | WICG | WD | P3 |
| requestIdleCallback | WICG | WD | P2 |
| requestAnimationFrame | WHATWG HTML | Living Standard | P2 |

---

## MVP Prioritization Summary

### Launch Blockers (MVP)

Must be implemented before any public release:

1. **WHATWG HTML Living Standard** — document parsing, element semantics, scripting
2. **WHATWG DOM** — tree manipulation, events, mutation
3. **WHATWG Fetch / CORS** — all network requests
4. **WHATWG URL / Encoding / Infra** — foundational primitives
5. **CSS 2.1 + Display L3 + Flexbox L1 + Box Model** — essential layout
6. **CSS Cascade L4 + Selectors L4 + Custom Properties** — cascade and styling
7. **CSS Color L4 + Backgrounds L3 + Text L3 + Fonts L4** — visual presentation
8. **ECMA-262** — JavaScript execution
9. **Web IDL** — JS/DOM binding layer
10. **HTTP/1.1 (RFC 9110–9112) + HTTP/2 (RFC 9113)** — networking
11. **TLS 1.3 (RFC 8446) + TLS 1.2** — transport security
12. **WebCrypto** — cryptographic primitives
13. **CSP L3 + SRI + Same-Origin + Mixed Content + Secure Contexts** — security model
14. **WCAG 2.2 AA** — legal accessibility compliance
15. **WAI-ARIA 1.2 + Core-AAM + HTML-AAM** — accessibility tree

### Phase 1 (P2 — First Year)

CSS Grid, Flexbox Level 2, CSS Animations/Transitions, Web Animations, Web Workers, Service Workers, IndexedDB, Canvas 2D, SVG 1.1, WebRTC, Web Audio, HTTP/3, COOP/COEP, WebAuthn, Intersection/Resize/Mutation Observers, Performance APIs.

### Phase 2 (P3 — As Needed)

WebGPU, WGSL, Encrypted Media Extensions, File System Access, WebCodecs, WebGL 2, CSS Anchor Positioning, View Transitions, CSS Scoping, Trusted Types, DNS over HTTPS.
