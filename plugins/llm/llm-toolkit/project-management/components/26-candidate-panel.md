# 26: Candidate Panel

| Field | Value |
|-------|-------|
| ID | CMP-26 |
| Category | AI-Specific |
| Surfaces | web, cli-ink |
| Used In | SCR-06, SCR-22 |

## Description
AI-suggested extraction points for the Convert Wizard, each with a confidence score, selectable to pre-fill Step 2's message range and Step 3's suggested name.

## Size Variants

| Variant | Use Case |
|---------|---------|
| Default | Convert Wizard, Step 1/2 boundary |

## Props / Configuration
- `candidates` — array of `{ range, confidence, suggestedName, artifactType }`
- `loading` — boolean while `POST /api/convert/candidates` resolves

## Interactions
- Selecting a candidate jumps the wizard directly to Step 3 with the range and name pre-filled
- Empty state doesn't block the flow — manual selection remains fully available
