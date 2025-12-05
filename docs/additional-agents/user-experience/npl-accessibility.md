# npl-accessibility

Inclusive design specialist ensuring NPL framework accessibility across visual, motor, and cognitive abilities through alternative interaction methods, screen reader support, and progressive complexity options.

## Purpose

Transforms NPL's sophisticated Unicode-heavy syntax into an inclusive system accessible to users with diverse abilities. Addresses critical barriers in complex NPL symbols and interactions by providing alternative input methods, assistive technology integration, and progressive disclosure that preserves power while enabling universal access.

## Capabilities

- Audit NPL prompts and interfaces for WCAG 2.1 AA compliance
- Create alternative input methods for Unicode symbols (voice, keyboard, touch)
- Design progressive complexity levels from simplified entry to full power
- Integrate with screen readers, voice control, and adaptive devices
- Provide high contrast themes, large text options, and visual alternatives
- Implement cognitive support through memory aids and simplified interfaces

## Usage

```bash
# Perform accessibility audit
@npl-accessibility audit --interface="prompt-builder" --standard="wcag-2.1-aa"

# Adapt for screen readers
@npl-accessibility adapt --for="screen-reader" --complexity="basic" --symbols="text-alternatives"

# Install voice commands
@npl-accessibility voice-commands --install --vocabulary="npl-extended" --confirmation=true

# Configure cognitive support
@npl-accessibility configure --complexity-level=1 --cognitive-support=high --visual-aids=enabled
```

## Workflow Integration

```bash
# Accessible onboarding design
@npl-onboarding design --accessibility="wcag-aa" --complexity="progressive" && @npl-accessibility validate --onboarding-flow

# Performance-conscious accessibility
@npl-accessibility enable --high-contrast --large-text && @npl-performance measure --accessibility-enabled

# Research accessibility needs
@npl-user-researcher survey --focus="accessibility-barriers" && @npl-accessibility analyze --user-feedback-data
```

## See Also

- Core definition: `core/additional-agents/user-experience/npl-accessibility.md`
- WCAG guidelines: `npl/accessibility/wcag-compliance.md`
- Voice command setup: `npl/accessibility/voice-commands.md`
