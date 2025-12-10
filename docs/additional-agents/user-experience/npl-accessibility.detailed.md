# npl-accessibility - Detailed Documentation

Inclusive design specialist ensuring NPL framework accessibility across visual, motor, and cognitive abilities.

## Table of Contents

- [Overview](#overview)
- [Core Capabilities](#core-capabilities)
- [Command Reference](#command-reference)
- [WCAG Compliance](#wcag-compliance)
- [Symbol Adaptation](#symbol-adaptation)
- [Progressive Complexity](#progressive-complexity)
- [Assistive Technology Integration](#assistive-technology-integration)
- [Cognitive Support Features](#cognitive-support-features)
- [Configuration Options](#configuration-options)
- [Workflow Patterns](#workflow-patterns)
- [Output Formats](#output-formats)
- [Error Handling](#error-handling)

---

## Overview

The `npl-accessibility` agent transforms NPL's Unicode-heavy syntax into an inclusive system. NPL relies on symbols like `⌜⌝`, `⟪⟫`, and emoji prefixes that create barriers for:

- Screen reader users (symbols read inconsistently)
- Motor-impaired users (Unicode input requires complex key sequences)
- Cognitive-impaired users (symbol density increases cognitive load)

This agent provides alternative input methods, assistive technology integration, and progressive disclosure that preserves NPL power while enabling universal access.

---

## Core Capabilities

### Accessibility Auditing
Analyze NPL prompts and interfaces for WCAG 2.1 compliance issues.

```bash
@npl-accessibility audit --interface="prompt-builder" --standard="wcag-2.1-aa"
```

**Output includes:**
- Compliance score (percentage)
- Critical issues list with severity ratings
- Remediation recommendations ranked by impact
- Automated fix suggestions where applicable

### Alternative Input Methods
Generate text-based alternatives for Unicode symbols.

| Unicode | Text Alternative | Voice Command |
|:--------|:-----------------|:--------------|
| `⌜⌝` | `[begin]...[end]` | "begin block", "end block" |
| `⟪⟫` | `<<...>>` | "directive start", "directive end" |
| `🎯` | `[attention]` | "attention" |
| `🏳️` | `[flag]` | "flag" |

### Screen Reader Optimization
Transform prompts for optimal screen reader pronunciation.

### Progressive Complexity
Three-tier system: Basic, Intermediate, Advanced.

### Cognitive Support
Memory aids, simplified interfaces, and guided workflows.

---

## Command Reference

### audit

Perform accessibility audit on NPL content or interface.

```bash
@npl-accessibility audit [options]
```

**Options:**

| Flag | Type | Default | Description |
|:-----|:-----|:--------|:------------|
| `--interface` | string | - | Interface to audit (prompt-builder, editor, cli) |
| `--standard` | string | wcag-2.1-aa | Compliance standard (wcag-2.0-a, wcag-2.1-aa, wcag-2.1-aaa) |
| `--scope` | string | all | Audit scope (visual, motor, cognitive, all) |
| `--output` | string | report | Output format (report, json, sarif) |
| `--fix` | boolean | false | Auto-fix issues where possible |

**Example:**

```bash
@npl-accessibility audit --interface="editor" --standard="wcag-2.1-aaa" --scope="visual" --output="json"
```

### adapt

Adapt NPL content for specific accessibility needs.

```bash
@npl-accessibility adapt [options]
```

**Options:**

| Flag | Type | Default | Description |
|:-----|:-----|:--------|:------------|
| `--for` | string | - | Target: screen-reader, keyboard, voice, touch, cognitive |
| `--complexity` | string | basic | Complexity level: basic, intermediate, advanced |
| `--symbols` | string | text-alternatives | Symbol handling: text-alternatives, descriptions, phonetic |
| `--preserve-structure` | boolean | true | Maintain document hierarchy |

**Example:**

```bash
@npl-accessibility adapt --for="screen-reader" --complexity="intermediate" --symbols="descriptions"
```

### voice-commands

Configure voice command vocabulary for NPL.

```bash
@npl-accessibility voice-commands [options]
```

**Options:**

| Flag | Type | Default | Description |
|:-----|:-----|:--------|:------------|
| `--install` | boolean | false | Install voice command profile |
| `--vocabulary` | string | npl-basic | Vocabulary set: npl-basic, npl-extended, custom |
| `--confirmation` | boolean | true | Require confirmation for commands |
| `--engine` | string | system | Voice engine: system, dragon, voiceover |
| `--export` | string | - | Export vocabulary to file path |

### configure

Set accessibility preferences.

```bash
@npl-accessibility configure [options]
```

**Options:**

| Flag | Type | Default | Description |
|:-----|:-----|:--------|:------------|
| `--complexity-level` | int | 2 | 1=basic, 2=intermediate, 3=advanced |
| `--cognitive-support` | string | medium | Level: low, medium, high |
| `--visual-aids` | string | enabled | Status: enabled, disabled |
| `--high-contrast` | boolean | false | Enable high contrast mode |
| `--large-text` | boolean | false | Enable large text mode |
| `--reduced-motion` | boolean | false | Disable animations |
| `--focus-indicators` | string | enhanced | Style: default, enhanced, high-visibility |

### validate

Validate accessibility of NPL content.

```bash
@npl-accessibility validate [options]
```

**Options:**

| Flag | Type | Default | Description |
|:-----|:-----|:--------|:------------|
| `--content` | string | - | NPL content or file path |
| `--onboarding-flow` | boolean | false | Validate onboarding sequence |
| `--report-format` | string | markdown | Format: markdown, html, json |

---

## WCAG Compliance

### Supported Standards

| Standard | Level | Coverage |
|:---------|:------|:---------|
| WCAG 2.0 | A | Full |
| WCAG 2.0 | AA | Full |
| WCAG 2.1 | A | Full |
| WCAG 2.1 | AA | Full (default) |
| WCAG 2.1 | AAA | Partial |

### Principle Coverage

**Perceivable (1.x)**
- Text alternatives for symbols (1.1.1)
- Color contrast validation (1.4.3, 1.4.6)
- Text spacing support (1.4.12)

**Operable (2.x)**
- Keyboard accessibility (2.1.1, 2.1.2)
- Focus management (2.4.3, 2.4.7)
- Input modalities (2.5.x)

**Understandable (3.x)**
- Readable content (3.1.x)
- Predictable behavior (3.2.x)
- Input assistance (3.3.x)

**Robust (4.x)**
- Parsing and compatibility (4.1.x)

### Audit Report Structure

```yaml
audit_result:
  timestamp: "2025-12-10T10:30:00Z"
  standard: "wcag-2.1-aa"
  score: 78
  issues:
    critical: 2
    serious: 5
    moderate: 8
    minor: 12
  findings:
    - id: "1.1.1-symbols"
      severity: critical
      criterion: "1.1.1 Non-text Content"
      issue: "Unicode symbols lack text alternatives"
      location: "line 15, column 3"
      remediation: "Add aria-label or text equivalent"
      auto_fixable: true
```

---

## Symbol Adaptation

### Text Alternative Mapping

Complete mapping of NPL symbols to accessible alternatives:

```yaml
declarations:
  "⌜": "[begin-decl]"
  "⌝": "[cont-decl]"
  "⌟": "[end-decl]"

directives:
  "⟪": "[[directive:"
  "⟫": "]]"

attention_markers:
  "🎯": "[ATTENTION]"
  "🔒": "[SECURE]"
  "🏳️": "[FLAG]"
  "🧱": "[TEMPLATE]"

prefixes:
  "👪➤": "[conversational]"
  "❓➤": "[question]"
  "📄➤": "[summary]"
  "🗣️❓➤": "[riddle]"
```

### Voice Command Vocabulary

**Basic Vocabulary (npl-basic)**
- 25 core commands
- Simple, single-word triggers
- Confirmation required

**Extended Vocabulary (npl-extended)**
- 75+ commands
- Multi-word phrases supported
- Command chaining enabled

```yaml
voice_commands:
  "begin block": "⌜"
  "end block": "⌟"
  "attention": "🎯"
  "directive start": "⟪"
  "directive end": "⟫"
  "flag set": "🏳️"
  "secure block": "🔒"
  "template": "🧱"
  "in fill": "[...]"
  "placeholder": "<>"
```

---

## Progressive Complexity

### Level 1: Basic

Minimal syntax, maximum guidance.

**Features:**
- Text-only NPL (no Unicode symbols)
- Single feature at a time
- Inline help tooltips
- Step-by-step wizards
- Validation before submission

**Syntax subset:**
```text
[begin: agent-name]
Description here.
[end: agent-name]
```

### Level 2: Intermediate

Standard syntax with assistance.

**Features:**
- Common Unicode symbols
- Auto-completion
- Syntax highlighting
- Error explanations
- Quick reference panel

**Syntax subset:**
```text
⌜agent-name|type|NPL@1.0⌝
Description and capabilities.
⌞agent-name⌟
```

### Level 3: Advanced

Full NPL syntax.

**Features:**
- Complete symbol set
- Directive shorthand
- Advanced templating
- Minimal guardrails
- Power-user optimizations

---

## Assistive Technology Integration

### Screen Readers

**Supported:**
- NVDA (Windows)
- JAWS (Windows)
- VoiceOver (macOS, iOS)
- TalkBack (Android)
- Orca (Linux)

**Optimizations:**
- Symbol pronunciation dictionaries
- Landmark regions for navigation
- Live region announcements
- Skip links for sections

**Configuration:**

```bash
@npl-accessibility configure --screen-reader="voiceover" --verbosity="medium"
```

### Voice Control

**Supported:**
- Dragon NaturallySpeaking
- Windows Speech Recognition
- macOS Voice Control
- Custom voice engines via API

**Features:**
- NPL-specific vocabulary
- Command confirmation mode
- Undo/correction support
- Dictation with symbol insertion

### Switch Devices

**Support level:** Basic

- Single-switch scanning
- Two-switch step/select
- Joystick navigation
- Sip-and-puff compatibility

---

## Cognitive Support Features

### Memory Aids

**Persistent clipboard:**
- Store frequently used snippets
- Quick insertion shortcuts
- Category organization

**History panel:**
- Recent prompts with context
- Search and filter
- One-click reuse

**Symbol reference:**
- Always-visible legend
- Hover tooltips
- Audio descriptions

### Simplified Interfaces

**Reduced information density:**
- Single-column layouts
- Larger touch targets (minimum 44px)
- Clear visual hierarchy
- Consistent navigation

**Task focus:**
- One task per screen
- Progress indicators
- Clear exit paths
- Save/resume support

### Guided Workflows

**Wizard mode:**
- Step-by-step prompts
- Validation at each step
- Back/forward navigation
- Progress persistence

**Templates:**
- Pre-built prompt structures
- Fill-in-the-blank format
- Example content
- Contextual help

---

## Configuration Options

### Environment Variables

```bash
# Set default accessibility standard
export NPL_ACCESSIBILITY_STANDARD="wcag-2.1-aa"

# Enable high contrast by default
export NPL_ACCESSIBILITY_HIGH_CONTRAST="true"

# Set complexity level (1-3)
export NPL_ACCESSIBILITY_COMPLEXITY="1"

# Configure cognitive support
export NPL_ACCESSIBILITY_COGNITIVE="high"

# Voice command engine
export NPL_ACCESSIBILITY_VOICE_ENGINE="system"
```

### Configuration File

Location: `.npl/accessibility.yaml`

```yaml
accessibility:
  standard: wcag-2.1-aa
  complexity_level: 2

  visual:
    high_contrast: false
    large_text: false
    reduced_motion: true
    focus_indicators: enhanced

  cognitive:
    support_level: medium
    memory_aids: true
    simplified_interface: false
    guided_workflows: true

  input:
    voice_commands: true
    keyboard_shortcuts: true
    touch_optimized: false

  screen_reader:
    enabled: auto
    verbosity: medium
    symbol_pronunciation: phonetic
```

---

## Workflow Patterns

### Accessibility-First Development

```bash
# 1. Audit existing content
@npl-accessibility audit --interface="prompt-builder" --output="json" > audit.json

# 2. Generate adaptations
@npl-accessibility adapt --for="screen-reader" --symbols="text-alternatives"

# 3. Validate changes
@npl-accessibility validate --content="./prompts/" --report-format="markdown"

# 4. Configure runtime
@npl-accessibility configure --complexity-level=2 --cognitive-support=medium
```

### Cross-Agent Integration

```bash
# Accessible onboarding
@npl-onboarding design --accessibility="wcag-aa" --complexity="progressive"
@npl-accessibility validate --onboarding-flow

# Performance with accessibility
@npl-accessibility enable --high-contrast --large-text
@npl-performance measure --accessibility-enabled

# Research-informed accessibility
@npl-user-researcher survey --focus="accessibility-barriers"
@npl-accessibility analyze --user-feedback-data
```

### Remediation Pipeline

```bash
# Identify issues
@npl-accessibility audit --standard="wcag-2.1-aa" --output="sarif" > issues.sarif

# Auto-fix where possible
@npl-accessibility audit --fix --scope="visual"

# Generate manual remediation guide
@npl-accessibility report --issues="issues.sarif" --format="remediation-guide"
```

---

## Output Formats

### Audit Report (Markdown)

```markdown
# Accessibility Audit Report

**Date:** 2025-12-10
**Standard:** WCAG 2.1 AA
**Score:** 78/100

## Critical Issues (2)

### 1.1.1 Non-text Content
- **Location:** prompt-builder.npl:15
- **Issue:** Symbol `⟪` lacks text alternative
- **Fix:** Add `aria-label="directive start"`

## Recommendations
1. Implement text alternatives for all Unicode symbols
2. Add keyboard shortcuts for common actions
3. Increase color contrast in editor theme
```

### JSON Output

```json
{
  "audit": {
    "timestamp": "2025-12-10T10:30:00Z",
    "standard": "wcag-2.1-aa",
    "score": 78,
    "issues": [
      {
        "id": "1.1.1-001",
        "criterion": "1.1.1",
        "severity": "critical",
        "element": "⟪",
        "location": {"file": "prompt-builder.npl", "line": 15},
        "remediation": "Add aria-label attribute"
      }
    ]
  }
}
```

### SARIF Output

Compatible with IDE integrations and CI/CD pipelines.

---

## Error Handling

### Common Errors

| Error Code | Message | Resolution |
|:-----------|:--------|:-----------|
| `ACC001` | Unknown accessibility standard | Use wcag-2.0-a, wcag-2.1-aa, or wcag-2.1-aaa |
| `ACC002` | Voice engine not available | Install system voice engine or specify alternative |
| `ACC003` | Invalid complexity level | Use 1 (basic), 2 (intermediate), or 3 (advanced) |
| `ACC004` | Adaptation target unsupported | Valid targets: screen-reader, keyboard, voice, touch, cognitive |
| `ACC005` | Configuration file malformed | Validate YAML syntax in .npl/accessibility.yaml |

### Graceful Degradation

When accessibility features unavailable:
1. Log warning to console
2. Fall back to default behavior
3. Notify user of limitation
4. Suggest alternatives

---

## Related Resources

- [WCAG 2.1 Quick Reference](https://www.w3.org/WAI/WCAG21/quickref/)
- [NPL Syntax Reference](/npl/syntax.md)
- [npl-onboarding Agent](./npl-onboarding.md)
- [npl-performance Agent](./npl-performance.md)
- [npl-user-researcher Agent](./npl-user-researcher.md)
