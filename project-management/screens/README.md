# Screens

This directory contains all UI screens extracted from the user stories.

## Category Table

| Category | Screens | Description |
|----------|---------|-------------|
| Authentication | 5 | Sign-up, login, password reset, email verification, profile setup |
| Onboarding | 2 | First-run experience, tour |
| Universe | 4 | Creation wizard, overview dashboard, settings, details |
| Canon | 3 | Entry editor, entry list, version history |
| Knowledge Graph | 1 | Graph view with controls |
| Generation | 4 | Studio, queue, history, source editor |
| Consistency | 2 | Dashboard, issue detail |
| Session | 3 | Companion, quick reference, player-facing view |
| Search | 2 | Results, filters |
| Settings | 5 | Account, notifications, AI, privacy, appearance |
| Admin | 5 | Dashboard, users, billing, analytics, moderation |
| Collaboration | 4 | Collaborators, roles, public sharing, reader codex |
| Accessibiltiy & Performance | 2 | Loading states, offline status |
| Export | 2 | Export formats, game engine schema |

## Type Legend

- **Primary**: Primary application screens - main content areas
- **Dashboard**: Overview screens with metrics and navigation
- **Settings**: Configuration screens for user or universe settings
- **Modal**: Overlays for focused interactions
- **Storyboard**: Multi-step flows and wizards

## Total Screens

**44 screens** extracted from 100 user stories.

## Validation

All user stories have been mapped to at least one screen. The following orphaned stories are handled by non-screen mechanisms (APIs, background jobs, or pattern-based features):

- US-037 (AI Reads Canon Context) - Background RAG pipeline
- US-040 (Tone & Voice Matching) - Configured in Universe Settings
- US-048 (Generation Cost Tracking) - Shown in multiple screens
- US-050 (Style Guide Configuration) - Part of US-015
- US-051 (Timeline Contradiction Detection) - Background check engine
- US-052 (Geographic Impossibility Flags) - Background check engine
- US-053 (Duplicate Name Detection) - Background check engine
- US-054 (Orphaned Reference Warnings) - Background check engine
- US-058 (Batch Consistency Check) - Triggered from Dashboard
- US-060 (Real-time Consistency) - Inline editor feature
- US-061 (Quick Reference Search) - Overlay search component
- US-066 (Session History) - Listed in Session Companion
- US-067 (Share Session Entries) - Action in Session Companion
- US-068 (End-of-Session Review) - Part of Session Companion
- US-069 (Full-Text Search) - Global search component
- US-070 (Semantic Search) - Toggle in search results
- US-071 (Search Filters) - Filter sidebar component
- US-072 (Search Result Previews) - Hover component
- US-073 (Recent Entries Feed) - Dashboard component
- US-074 (Suggested Connections) - Entry detail sidebar
- US-075 (Gap Analysis) - Future feature
- US-088 (Rate Limiting) - API-level feature
- US-089 (Abuse Detection) - Background monitoring
- US-090 (Moderation Policy) - Admin settings panel
- US-095 (Template Marketplace) - Future feature
- US-096 (Screen Reader) - Cross-cutting accessibility pattern
- US-097 (Loading States) - Cross-cutting UX pattern
- US-098 (Offline Mode) - PWA infrastructure pattern