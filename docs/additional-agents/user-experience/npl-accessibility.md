# npl-accessibility

Inclusive design specialist ensuring NPL framework accessibility across visual, motor, and cognitive abilities through alternative interaction methods, screen reader support, and progressive complexity options.

**Detailed documentation:** [npl-accessibility.detailed.md](./npl-accessibility.detailed.md)

## Purpose

Transforms NPL's Unicode-heavy syntax into an inclusive system accessible to users with diverse abilities. Addresses barriers in complex NPL symbols by providing alternative input methods, assistive technology integration, and progressive disclosure.

See [Overview](./npl-accessibility.detailed.md#overview) for barrier analysis.

## Capabilities

- Audit NPL prompts for WCAG 2.1 AA compliance
- Create alternative input methods for Unicode symbols (voice, keyboard, touch)
- Design progressive complexity levels (basic to advanced)
- Integrate with screen readers, voice control, and adaptive devices
- Provide high contrast themes and visual alternatives
- Implement cognitive support through memory aids and simplified interfaces

See [Core Capabilities](./npl-accessibility.detailed.md#core-capabilities) for details.

## Quick Reference

```bash
# Audit for accessibility issues
@npl-accessibility audit --interface="prompt-builder" --standard="wcag-2.1-aa"

# Adapt content for screen readers
@npl-accessibility adapt --for="screen-reader" --symbols="text-alternatives"

# Install voice commands
@npl-accessibility voice-commands --install --vocabulary="npl-extended"

# Configure preferences
@npl-accessibility configure --complexity-level=1 --cognitive-support=high
```

See [Command Reference](./npl-accessibility.detailed.md#command-reference) for all options.

## Commands

| Command | Purpose | Details |
|:--------|:--------|:--------|
| `audit` | WCAG compliance check | [audit options](./npl-accessibility.detailed.md#audit) |
| `adapt` | Transform for accessibility | [adapt options](./npl-accessibility.detailed.md#adapt) |
| `voice-commands` | Voice input setup | [voice-commands options](./npl-accessibility.detailed.md#voice-commands) |
| `configure` | Set preferences | [configure options](./npl-accessibility.detailed.md#configure) |
| `validate` | Verify accessibility | [validate options](./npl-accessibility.detailed.md#validate) |

## Symbol Alternatives

NPL Unicode symbols map to text and voice alternatives:

| Symbol | Text | Voice |
|:-------|:-----|:------|
| `⌜⌝⌟` | `[begin]...[end]` | "begin block", "end block" |
| `⟪⟫` | `<<...>>` | "directive start/end" |
| `🎯` | `[attention]` | "attention" |

See [Symbol Adaptation](./npl-accessibility.detailed.md#symbol-adaptation) for complete mapping.

## Progressive Complexity

| Level | Users | Features |
|:------|:------|:---------|
| 1 Basic | New users, cognitive support | Text-only, wizards, inline help |
| 2 Intermediate | Standard users | Common symbols, auto-complete |
| 3 Advanced | Power users | Full syntax, minimal guardrails |

See [Progressive Complexity](./npl-accessibility.detailed.md#progressive-complexity) for syntax subsets.

## Workflow Integration

```bash
# Accessible onboarding
@npl-onboarding design --accessibility="wcag-aa" && @npl-accessibility validate --onboarding-flow

# Performance with accessibility enabled
@npl-accessibility enable --high-contrast --large-text && @npl-performance measure

# Research accessibility barriers
@npl-user-researcher survey --focus="accessibility-barriers" && @npl-accessibility analyze --user-feedback-data
```

See [Workflow Patterns](./npl-accessibility.detailed.md#workflow-patterns) for pipelines.

## Configuration

Environment variables:
```bash
export NPL_ACCESSIBILITY_STANDARD="wcag-2.1-aa"
export NPL_ACCESSIBILITY_COMPLEXITY="1"
export NPL_ACCESSIBILITY_COGNITIVE="high"
```

See [Configuration Options](./npl-accessibility.detailed.md#configuration-options) for all settings.

## See Also

- [WCAG Compliance](./npl-accessibility.detailed.md#wcag-compliance) - Standards coverage
- [Assistive Technology](./npl-accessibility.detailed.md#assistive-technology-integration) - Screen reader, voice control support
- [Cognitive Support](./npl-accessibility.detailed.md#cognitive-support-features) - Memory aids, simplified interfaces
- [npl-onboarding](./npl-onboarding.md) - User onboarding flows
- [npl-performance](./npl-performance.md) - Performance measurement
- [npl-user-researcher](./npl-user-researcher.md) - User research
