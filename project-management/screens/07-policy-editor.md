# Policy Editor

| Field | Value |
|-------|-------|
| **ID** | `policy-editor` |
| **Type** | Primary |
| **Category** | SafeMCP / Policy |
| **User Stories** | US-008, US-009, US-013, US-014, US-015, US-016, US-017, US-018, US-019, US-030, US-066, US-085 |

## Description

Monaco-based YAML policy editor with six-scope-level navigation. Supports rate limits, deny rules, confirmation gates, argument constraints, time-based rules, and per-caller allow/deny lists.

## Key Components

- **MonacoEditor**
- **ScopeLevelTabs**
- **PolicyValidationFeedback**
- **ConfirmationGateConfig**
- **ArgumentConstraintBuilder**
- **TimeScheduleBuilder**
- **CallerPolicyTable**
- **EffectivePolicyView**

## Interactions

- Edit YAML with real-time validation
- Toggle confirmation gates
- Add argument constraints
- Configure time schedules
- Preview effective policy
- Import from library

## Navigation

- Dashboard / Server Detail / Org Settings -> Policy Editor
