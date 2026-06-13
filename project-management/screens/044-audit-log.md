# Audit Log

| Field | Value |
|-------|-------|
| **ID** | `audit-log` |
| **Type** | Settings |
| **Category** | Administration |
| **User Stories** | US-084, US-085, US-089 |

## Description

Detailed, append-only activity log accessible to universe owners (for universe-scoped events) and platform admins (for platform-wide events). Provides a tamper-evident record of who did what and when — covering content edits, collaborator changes, generation requests, sharing toggles, and flagged abuse signals. Used for accountability, debugging, and compliance.

## Key Components

- **Scope Selector** — Toggle between Universe Log (owner view) and Platform Log (admin only); admin log includes all universes and users (US-084, US-085)
- **Log Table** — Columns: Timestamp, Actor (user + avatar), Action Type, Target (entry/universe/user), Detail Summary, IP / Device (admin only); rows sorted newest-first (US-084)
- **Action Type Filter** — Multi-select filter: Content Edits, Collaborator Changes, Settings Changes, Generation Requests, Sharing Events, Login/Auth, Flagged/Abuse (US-089)
- **Date Range Picker** — Calendar picker to scope log to a time window; defaults to last 30 days (US-085)
- **Actor Search** — Filter log by username or email (US-084)
- **Flag Indicator** — Rows with abuse-detection flags shown with a red warning chip; click expands abuse detail panel (US-089)
- **Abuse Detail Panel** — Slide-out showing detection reason, confidence score, flagged content excerpt, and admin action buttons (Dismiss / Warn User / Suspend Account) (US-089)
- **Export Button** — Downloads filtered log as CSV; available to owners and admins (US-085)
- **Retention Notice** — Footer note indicating log retention policy (e.g., "Logs retained for 90 days on your plan") (US-085)

## Interactions

- Filter and date range changes reload the log table without full page refresh
- Clicking a log row expands an inline detail view with full diff or payload where applicable
- Flagged rows open the Abuse Detail Panel; admin actions (Warn, Suspend) require confirmation dialog
- Export applies current filters; large exports queued and delivered via email notification
- Platform log is read-only for universe owners; admin-only columns (IP, device) hidden from owner view

## Navigation

- Accessible from: Universe Settings (Activity / Audit section) for owners; Admin Dashboard (Moderation / Audit section) for admins
- Links to: Admin User Management (via actor name click in admin view), Admin Moderation screen (via flagged item links)
