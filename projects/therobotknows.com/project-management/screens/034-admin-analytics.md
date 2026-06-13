# Admin Analytics

| Field | Value |
|-------|-------|
| **ID** | admin-analytics |
| **Type** | Primary |
| **Category** | Admin |
| **User Stories** | US-085 |

## Description

Detailed analytics on growth, feature adoption, and retention.

## Key Components

- **Date Range Selector** — Choose analytics period (US-085)
- **Growth Charts** — New signups, DAU/WAU/MAU line charts (US-085)
- **Volume Charts** — Generation requests, consistency checks (US-085)
- **Feature Adoption Panel** — Percentage using each major feature (US-085)
- **Retention Cohort Table** — Week-over-week retention by cohort month (US-085)
- **Export Report Button** — CSV download with date range in filename (US-085)
- **Skeleton Loaders** | Loading states for each chart (US-085, US-097)

## Interactions

- Charts load within 3 seconds
- Data pre-aggregated via nightly job
- PII excluded from exports
- Export CSV includes displayed metrics
- Cohort table shows retention percentages

## Navigation

- Accessible from: Admin Dashboard (Analytics link)
- Links to: None