# Universe Creation Wizard

| Field | Value |
|-------|-------|
| **ID** | universe-creation-wizard |
| **Type** | Storyboard |
| **Category** | Universe |
| **User Stories** | US-009, US-011, US-015, US-020 |

## Description

Multi-step wizard for guided universe creation with genre, tone, and template configuration.

## Key Components

- **Step 1: Name & Description** — Basic universe identity (US-009)
- **Step 2: Genre & Tone** — Primary genre, sub-genres, tone descriptors, style note (US-015)
- **Step 3: Starter Template** — Template selection with preview of pre-populated entries (US-011, US-020)
- **Step 4: Confirm & Create** — Review summary and create button (US-011)
- **Progress Indicator** — Visual progress through wizard steps (US-011)
- **Navigation Buttons** — Back, Cancel, Create (US-011)
- **Template Preview Panel** — Shows which entry types and example entries will be created (US-011)

## Interactions

- Sequential steps with back/cancel navigation
- Template preview updates on selection
- "Blank" template creates empty universe
- Creates universe with all configured settings
- Redirects to Universe Overview with tour offer

## Navigation

- Accessible from: Dashboard (Create Universe button), First Run Experience
- Links to: Universe Overview (on completion)