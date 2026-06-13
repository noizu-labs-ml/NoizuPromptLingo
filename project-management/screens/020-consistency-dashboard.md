# Consistency Dashboard

| Field | Value |
|-------|-------|
| **ID** | consistency-dashboard |
| **Type** | Dashboard |
| **Category** | Consistency |
| **User Stories** | US-057, US-055, US-058 |

## Description

Overview of all consistency issues with severity grouping and triage controls.

## Key Components

- **Summary Panel** — Total open issues, breakdown by severity (error/warning/suggestion) (US-057, US-055)
- **Severity Count Badges** — Red/Error, Amber/Warning, Blue/Suggestion with icons (US-055)
- **Issue List** — Sortable/filterable list of all issues (US-057)
- **Issue Detail** — Type, description, severity, affected entries, detected timestamp (US-057)
- **Severity Filters** — Show errors only, warnings only, etc. (US-055)
- **Entry Type Filters** — Filter by character, location, etc. (US-057)
- **Sort Controls** — Sort by severity (descending), most recent (US-057)
- **Run Full Check Button** — Trigger batch consistency scan (US-058)
- **Progress Indicator** — Show batch check percentage and ETA (US-058)
- **No Issues State** — Green health indicator with last check timestamp (US-057)
- **Real-time Updates** — New issues appear without page reload (US-060)

## Interactions

- Sort by severity shows errors first
- Filters update result counts immediately
- Clicking issue opens resolution workflow
- Run Full Check queues batch job
- Progress shows while running, can navigate away
- Real-time updates issue list as checks complete

## Navigation

- Accessible from: Universe Overview, Canon Editor (real-time check)
- Links to: Consistency Issue Detail, Resolution Workflow