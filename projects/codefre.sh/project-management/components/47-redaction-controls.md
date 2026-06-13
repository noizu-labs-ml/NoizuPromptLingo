# Redaction Controls

| Field | Value |
|-------|-------|
| **ID** | `redaction-controls` |
| **Category** | Input & Forms |
| **Used In** | 21-Capture Detail |

## Description

Interface for scrubbing PII and sensitive data from captured content before promotion or storage. Allows selecting text regions to redact, applying pattern-based auto-redaction (emails, phone numbers, SSNs), and previewing the redacted output.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Toolbar above content display with highlight-to-redact and auto-detect buttons |

## Props / Configuration

- `content` — Original content to redact
- `redactions` — Array of { start, end, replacement }
- `autoPatterns` — Built-in PII patterns (email, phone, SSN, credit card)
- `onRedact` — Callback with updated redacted content
- `previewMode` — Show redacted vs original toggle

## Interactions

- Select text to manually redact (replaces with [REDACTED])
- Click "Auto-detect" to find and mark PII patterns
- Review and approve/reject each auto-detected redaction
- Toggle preview to see final redacted output
