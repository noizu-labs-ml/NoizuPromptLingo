# Wizard Stepper

| Field | Value |
|-------|-------|
| **ID** | `wizard-stepper` |
| **Category** | Navigation & Layout |
| **Used In** | 02-Morning Planning, 12-Project Creation Wizard, 19-Client Report Generator, 38-Post-Incident Review, 49-OKR Check-In, 51-OKR Scoring, 59-Custom Agent Builder, 60-Agent Collaboration Protocol |

## Description

Multi-step progress indicator for wizard flows showing current step, completed steps, and navigation

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Dot indicators for current position |
| **Compact** | Numbered steps with labels |
| **Expanded** | Steps with descriptions and validation status |

## Props / Configuration

- `steps` — array of {label, description, isComplete, isValid}
- `currentStep` — index
- `onStepClick` — handler
- `allowSkip` — boolean

## Interactions

- click completed steps to go back
- validation prevents advancing
- visual progress indication
