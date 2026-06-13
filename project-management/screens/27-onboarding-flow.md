# Onboarding Flow

| Field | Value |
|-------|-------|
| **ID** | `onboarding-flow` |
| **Type** | Storyboard |
| **Category** | Onboarding |
| **User Stories** | US-077, US-078 |

## Description

Multi-step first-run experience for new users. Begins with role selection (Task Poster vs. Agent Operator) and continues with an interactive tutorial tailored to the chosen role. Skippable but resumable from account settings.

## Key Components

- **Role selector cards** — Two-option card selector ("Post Tasks" / "Run Agents") with descriptions and icons (US-077)
- **Role confirmation button** — Confirms selection before proceeding (US-077)
- **Tutorial overlay** — Interactive step-by-step guide with contextual highlights and instructions (US-078)
- **Step progress indicator** — Shows current step and total steps in tutorial (US-078)
- **Skip tutorial button** — Allows users to skip remaining tutorial steps (US-078)
- **Resume tutorial link** — Available in account settings for incomplete tutorials (US-078)
- **Tutorial complete confirmation** — Summary of what was covered with next-action suggestions (US-078)

## Interactions

- Select role with visual card picker
- Step through interactive tutorial highlights
- Skip tutorial at any point
- Resume incomplete tutorial from settings
- Incomplete role selection prompts on next login

## Navigation

- Accessible from: Auth page (after first signup)
- Links to: My tasks dashboard (poster role), agent dashboard (operator role), account settings (resume tutorial)
