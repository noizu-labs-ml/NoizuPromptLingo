# Screen Inventory

## Overview

| Metric | Count |
|--------|-------|
| **Total Screens** | 27 |
| **User Stories Mapped** | US-001 through US-100 |

## Screens by Category

| Category | Screens | Count |
|----------|---------|-------|
| Core Gameplay | Fighter Studio, Battle Replay Viewer, Post-Battle Screen, Training Gym | 4 |
| Discovery | Template Gallery | 1 |
| Competitive | Ranked Arena, Match Confirmation, Season Summary, Fighter Win-Rate Analytics, Tournament Bracket | 5 |
| Community | Laboratory, Clan Hub | 2 |
| Onboarding | Onboarding Tutorial | 1 |
| Education | Education Portal, Node Glossary | 2 |
| Creator | Guide Composer, Creator Dashboard | 2 |
| Social | Public Profile, Share Dialog, Shared Fighter View | 3 |
| Engagement | Daily Challenge | 1 |
| Monetization | Cosmetic Shop | 1 |
| Moderation | Content Moderation Queue | 1 |
| System | Settings, AI Model Documentation, Patch Notes | 3 |
| Sharing | Web Replay Viewer | 1 |

## Screen Type Legend

| Type | Description |
|------|-------------|
| **Primary** | Full-page views in main navigation |
| **Dashboard** | Aggregation/metrics views |
| **Settings** | Configuration panels |
| **Modal** | Overlays/dialogs triggered from other screens |
| **Storyboard** | Multi-step flows/wizards |

## Screen Index

| # | Screen | ID | Type | User Stories |
|---|--------|----|------|-------------|
| 01 | Fighter Studio | `fighter-studio` | Primary | US-001, 006, 015, 017, 019, 053, 058, 062, 070, 071, 075, 087, 088, 089, 093, 097, 100 |
| 02 | Battle Replay Viewer | `battle-replay-viewer` | Primary | US-002, 021, 022, 026, 034, 046, 069, 074, 081, 082, 092, 096 |
| 03 | Post-Battle Screen | `post-battle-screen` | Primary | US-004, 010, 012, 047, 063, 067, 076 |
| 04 | Training Gym | `training-gym` | Primary | US-007, 030, 051, 052, 055, 056, 057, 059 |
| 05 | Template Gallery | `template-gallery` | Primary | US-009, 078 |
| 06 | Ranked Arena | `ranked-arena` | Primary | US-005, 011, 014, 041, 042, 043, 050, 061, 064, 065, 077 |
| 07 | Laboratory | `laboratory` | Primary | US-003, 023, 024, 025, 027, 035, 037, 060, 090, 098 |
| 08 | Onboarding Tutorial | `onboarding-tutorial` | Storyboard | US-008, 064 |
| 09 | Settings | `settings` | Settings | US-020, 054, 066, 074, 080 |
| 10 | Education Portal | `education-portal` | Dashboard | US-028, 029, 030, 032, 033, 036, 038, 040 |
| 11 | Daily Challenge | `daily-challenge` | Primary | US-018 |
| 12 | Clan Hub | `clan-hub` | Primary | US-013 |
| 13 | Patch Notes | `patch-notes` | Primary | US-019, 045 |
| 14 | Match Confirmation | `match-confirmation` | Modal | US-016, 044 |
| 15 | Season Summary | `season-summary` | Primary | US-048 |
| 16 | Guide Composer | `guide-composer` | Primary | US-025 |
| 17 | Creator Dashboard | `creator-dashboard` | Dashboard | US-025, 084, 094 |
| 18 | Public Profile | `public-profile` | Primary | US-094 |
| 19 | Node Glossary | `node-glossary` | Modal | US-031 |
| 20 | AI Model Documentation | `ai-model-documentation` | Primary | US-054 |
| 21 | Cosmetic Shop | `cosmetic-shop` | Primary | US-005, 089 |
| 22 | Content Moderation Queue | `content-moderation-queue` | Dashboard | US-035, 079 |
| 23 | Share Dialog | `share-dialog` | Modal | US-003, 010, 039, 092 |
| 24 | Fighter Win-Rate Analytics | `fighter-win-rate-analytics` | Primary | US-049 |
| 25 | Tournament Bracket | `tournament-bracket` | Primary | US-033, 085, 099 |
| 26 | Shared Fighter View | `shared-fighter-view` | Modal | US-068 |
| 27 | Web Replay Viewer | `web-replay-viewer` | Primary | US-046, 092 |

## User Story Coverage

All 100 user stories (US-001 through US-100) are mapped to at least one screen. Cross-cutting stories (accessibility: US-072, US-073; content moderation: US-035) apply across multiple screens.

Note: US-072 (Switch Control navigation), US-073 (48px touch targets), and US-083 (Training Time-Lapse Export), US-086 (Early Access Preview), US-091 (Heatmap Art Print Export), US-095 (Performance Curve Animation Export) are features that apply within existing screens rather than requiring dedicated screens.
