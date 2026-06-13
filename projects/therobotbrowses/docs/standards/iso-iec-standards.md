# ISO/IEC Standards — Browser Relevance Reference

## Overview

This document catalogs ISO/IEC and related standards relevant to web browser implementation. Standards are organized by domain with applicability notes specific to a browser engine. Many of these are legally mandated in specific jurisdictions or required for government/enterprise procurement.

---

## Document Standards

### ISO/IEC 15445:2000 — HyperText Markup Language (HTML)

**Status:** Obsolete  
**Superseded by:** WHATWG HTML Living Standard  
**Relevance:** Historical only. ISO 15445 was a strict subset of HTML 4.01. It has been completely superseded and is not referenced in any current browser specification or procurement requirement.

### ISO 8879:1986 — Standard Generalized Markup Language (SGML)

**Status:** Historical  
**Relevance:** HTML was originally defined as an SGML application. Modern browsers do not implement an SGML parser; the WHATWG HTML parser is a custom state-machine parser. SGML is relevant only for understanding the historical lineage of HTML.

### ISO 32000-2:2020 — Document Management: Portable Document Format (PDF 2.0)

**Status:** Active  
**Relevance:** High — browsers with native PDF rendering (Chrome, Firefox, Safari) must implement PDF parsing and display. Save-to-PDF functionality must produce conformant PDF output.

**Browser requirements:**
- Native PDF viewer must render PDF 1.x and PDF 2.0 documents
- Save-to-PDF must produce ISO 32000-2 conformant output
- PDF/A subset compliance (ISO 19005) for archival save-to-PDF
- Embedded fonts, forms, and annotations should render correctly

---

## Accessibility Standards

### ISO/IEC 40500:2025 — W3C Web Content Accessibility Guidelines 2.2 (WCAG 2.2)

**Status:** Active (updated 2025 to reflect WCAG 2.2)  
**Legal mandate:**
- **EU:** European Accessibility Act (EAA) requires WCAG 2.2 AA via EN 301 549 v3.2.1
- **US:** ADA technical guidance, Section 508 (revised 2017) aligns with WCAG 2.1 AA; WCAG 2.2 is the current target
- **UK:** Public Sector Bodies Accessibility Regulations require WCAG 2.1 AA

**Browser requirements:**

The browser chrome UI itself (not just rendered content) must conform to WCAG 2.2 AA:
- All UI controls must meet 4.5:1 contrast ratio (3:1 for large text)
- All functionality must be keyboard accessible
- No keyboard traps in chrome UI
- Focus indicators must be visible (Success Criterion 2.4.11 — new in 2.2)
- Dragging movements must have a pointer alternative (SC 2.5.7 — new in 2.2)
- Target size minimum 24×24 CSS pixels (SC 2.5.8 — new in 2.2)

**Key WCAG 2.2 additions (beyond 2.1):**
| SC | Level | Title |
|----|-------|-------|
| 2.4.11 | AA | Focus Not Obscured (Minimum) |
| 2.4.12 | AAA | Focus Not Obscured (Enhanced) |
| 2.4.13 | AAA | Focus Appearance |
| 2.5.7 | AA | Dragging Movements |
| 2.5.8 | AA | Target Size (Minimum) |
| 3.2.6 | AA | Consistent Help |
| 3.3.7 | AA | Redundant Entry |
| 3.3.8 | AA | Accessible Authentication (Minimum) |
| 3.3.9 | AAA | Accessible Authentication (Enhanced) |

### EN 301 549 v3.2.1 — Accessibility Requirements for ICT Products and Services

**Status:** Active (current version)  
**Legal mandate:** Required for all ICT products and services in the EU public sector; adopted by EAA for private sector products with accessibility obligations  
**Relationship to WCAG:** EN 301 549 Chapter 9 incorporates WCAG 2.2 by reference; Chapter 11 covers non-web software (browser chrome UI)

**Chapter 11 — Non-web software requirements applicable to browser UI:**
- 11.1 through 11.4 mirror WCAG success criteria but applied to software UI
- 11.5 — Interoperability with assistive technology (platform accessibility API integration)
- 11.5.2.3 — Use of accessibility services (must use OS accessibility APIs, not custom)
- 11.5.2.5 — Object information (every UI element must expose role, name, state)
- 11.5.2.7 — Values (numeric/range inputs must expose current/min/max values)
- 11.5.2.11 — List of actions (interactive elements must advertise available actions)
- 11.5.2.12 — Execution of actions (actions invocable via AT)
- 11.5.2.15 — Change notification (AT must be notified of UI state changes)
- 11.6.2 — No disruption of accessibility features (must not disable OS AT)
- 11.8 — Authoring tools (if browser includes a DOM inspector or editor)

---

## Ergonomics and Usability Standards

### ISO 9241 Series — Ergonomics of Human-System Interaction

**Status:** Active (multiple parts, various revision dates)

| Part | Title | Browser Relevance |
|------|-------|-------------------|
| ISO 9241-11:2018 | Usability: Definitions and concepts | Usability metrics framework for browser UI evaluation |
| ISO 9241-110:2020 | Interaction principles | Dialogue principles: suitability for task, self-descriptiveness, conformity with user expectations, error tolerance, suitability for individualization |
| ISO 9241-171:2008 | Guidance on software accessibility | Software accessibility guidance; overlaps with EN 301 549 Ch. 11 |
| ISO 9241-210:2019 | Human-centred design for interactive systems | HCD process framework for browser UI design |

**Applicability:** ISO 9241 is rarely cited in procurement requirements but provides the underlying framework for usability testing and accessibility guidance referenced by EN 301 549 and WCAG.

---

## Security and Quality Standards

### ISO/IEC 15408 — Common Criteria for Information Technology Security Evaluation

**Status:** Active (CC v3.1 Rev 5 / ISO/IEC 15408:2022)  
**Relevance:** Government and defense procurement in NATO member countries, US federal government (via NIAP), EU

**Evaluation Assurance Levels (EAL):**
| Level | Description | Browser Target |
|-------|-------------|---------------|
| EAL1 | Functionally tested | Baseline for general-purpose browser |
| EAL2 | Structurally tested | Most commercial browsers |
| EAL4 | Methodically designed, tested, reviewed | Enterprise/government browser deployment |

**Protection Profiles relevant to browsers:**
- PP_Browser_v2.0 — National Information Assurance Partnership (NIAP) Protection Profile for Web Browsers
  - Requires: TLS 1.2+, certificate validation, HSTS, process isolation, extension sandboxing, private browsing, password management security
- PP_ESM_v3.0 — Enterprise Security Management (for managed browser deployments)

### ISO/IEC 27001:2022 — Information Security Management Systems

**Status:** Active  
**Relevance:** Organizational certification; browser development teams in enterprise environments. Not a browser product requirement but frequently required in procurement contracts for the development organization.

### ISO/IEC 27002:2022 — Information Security Controls

**Status:** Active  
**Relevance:** Control catalog for implementing ISMS; provides best practices for secure browser development processes (code review, vulnerability management, cryptographic key management, secure development lifecycle).

### ISO/IEC 27034:2011/2015 — Application Security

**Status:** Active (multiple parts)  
**Relevance:** Framework for integrating security into application development lifecycle. Directly applicable to browser security architecture:
- 27034-1: Concepts and framework — Application Security Management Process
- 27034-2: Organization normative framework
- 27034-3: Application security management process
- 27034-5: Protocols and application security controls data structure

---

## Character Encoding Standards

### ISO/IEC 10646 — Universal Coded Character Set (UCS)

**Status:** Active (synchronized with Unicode 15.1 / 2023)  
**Relationship to Unicode:** ISO/IEC 10646 and Unicode are synchronized; the character repertoire is identical. ISO/IEC 10646 defines the Universal Coded Character Set (UCS); Unicode Standard adds additional semantics (bidirectionality, normalization, algorithms).

**Browser requirements:**
- Full UCS/Unicode support in HTML parser (WHATWG Encoding spec)
- Correct UTF-8, UTF-16, UTF-32 encoding/decoding
- Accurate character property lookup (general category, bidirectional class, combining class)
- Unicode normalization (NFC, NFD, NFKC, NFKD) via `String.normalize()`
- Correct text rendering of complex scripts (Arabic, Hebrew RTL; Indic conjuncts; CJK)

### ISO 8859 Series — 8-bit Single-Byte Coded Graphic Character Sets

**Status:** Legacy (largely superseded by UTF-8)  
**Relevance:** Legacy web content. Browsers must decode legacy encodings per WHATWG Encoding specification:
- ISO-8859-1 (Latin-1) — most common legacy encoding
- ISO-8859-2 through ISO-8859-16 — regional variants
- The WHATWG Encoding spec maps these to their correct code point tables

---

## Language and Locale Standards

### ISO 639 / ISO 3166 / ISO 15924 — Language, Country, Script Codes

**Status:** Active  
**Used via:** IETF BCP 47 (Best Current Practice for Language Tags)

| Standard | Covers | Example Tags |
|----------|--------|-------------|
| ISO 639-1/2/3 | Language codes | `en`, `fr`, `zh`, `ar` |
| ISO 3166-1 alpha-2 | Country/region codes | `US`, `GB`, `CN`, `DE` |
| ISO 15924 | Script codes | `Latn`, `Cyrl`, `Arab`, `Hans` |

**Browser requirements:**
- `lang` attribute parsing per BCP 47 (affects spellcheck language, hyphenation, text shaping)
- `Accept-Language` HTTP header construction from user locale settings
- `Intl` JavaScript API locale support (ECMA-402)
- Correct script selection and font fallback for multilingual content
- `dir` attribute support (`ltr`, `rtl`, `auto`) per Unicode Bidi Algorithm

---

## Software Quality

### ISO/IEC 25010:2023 — Systems and Software Quality Requirements and Evaluation (SQuaRE)

**Status:** Active (2023 revision)  
**Quality characteristics relevant to browser:**

| Characteristic | Sub-characteristics | Browser Application |
|----------------|--------------------|--------------------|
| Functional suitability | Completeness, correctness, appropriateness | Spec compliance, rendering accuracy |
| Performance efficiency | Time behavior, resource utilization, capacity | Page load time, memory usage, FPS |
| Compatibility | Co-existence, interoperability | Web standards interoperability |
| Usability | Learnability, operability, accessibility, UI aesthetics | Chrome UI design, accessibility |
| Reliability | Maturity, availability, fault tolerance, recoverability | Crash rate, recovery from renderer crashes |
| Security | Confidentiality, integrity, non-repudiation, accountability, authenticity | Sandboxing, certificate validation |
| Maintainability | Modularity, reusability, analysability, modifiability, testability | Code architecture |
| Portability | Adaptability, installability | Cross-platform support |

### ISO/IEC 29119 — Software and Systems Engineering — Software Testing

**Status:** Active (multiple parts)  
**Parts relevant to browser testing:**

| Part | Title | Application |
|------|-------|-------------|
| 29119-1 | Concepts and definitions | Testing terminology |
| 29119-2 | Test processes | Test planning and management |
| 29119-3 | Test documentation | Test plans, cases, results |
| 29119-4 | Test techniques | Black-box, white-box, experience-based |
| 29119-5 | Keyword-driven testing | Test automation frameworks |

---

## Priority Summary Table

| Standard | Priority | Reason |
|----------|----------|--------|
| ISO/IEC 40500 (WCAG 2.2) | Launch blocker | Legal mandate in EU/US; browser chrome UI must comply |
| EN 301 549 v3.2.1 Ch. 11 | Launch blocker | EU legal requirement; AT integration requirements |
| ISO/IEC 10646 (Unicode) | Launch blocker | Correct text rendering; required for any non-ASCII content |
| ISO 32000-2 (PDF 2.0) | P1 | Native PDF viewer/save-to-PDF feature |
| ISO 639/3166/15924 (BCP 47) | P1 | Locale/language handling; `Accept-Language`; `Intl` API |
| ISO 8859 series | P1 | Legacy encoding support for older web content |
| ISO 9241-110 (Interaction) | P2 | UI design guidelines; no legal mandate |
| ISO 9241-171 (Accessibility) | P2 | Overlaps with EN 301 549; informative |
| ISO/IEC 15408 (Common Criteria) | P2 | Required for government/enterprise deployment |
| ISO/IEC 25010 (Quality model) | P2 | Quality metrics framework |
| ISO/IEC 27001/27002 (ISMS) | P3 | Organizational; not a product requirement |
| ISO/IEC 27034 (App security) | P3 | Development process; informative |
| ISO/IEC 29119 (Testing) | P3 | Testing process framework |
| ISO/IEC 15445 (HTML) | N/A | Obsolete |
| ISO 8879 (SGML) | N/A | Historical only |
