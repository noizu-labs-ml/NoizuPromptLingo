# Component Library

Reusable UI components extracted from the 47 screens in `project-management/screens/`. Each component appears in 2+ screens (by name or clear functional equivalent) or, where noted, is named on a single screen but carries a genuinely complex interaction pattern (drag-and-drop, pixel-anchored positioning, live agent state, schema-driven rendering, policy simulation) that warrants its own reusable spec.

**Total components: 45**

## By Category

| Category | Components |
|----------|------------|
| Tables & Lists | `data-table` |
| Input & Forms | `search-filter-bar`, `create-entity-button`, `selector-dropdown`, `toggle-switch`, `settings-form`, `sso-auth-button`, `dynamic-custom-field-form`, `message-composer` |
| Cards & Tiles | `card-grid`, `entity-header-card`, `ticket-card` |
| Data Display | `stat-summary-cards`, `activity-timeline`, `version-history-panel`, `localized-content-renderer`, `message-timeline-virtualized`, `comment-thread-panel`, `connected-account-panel` |
| Navigation & Layout | `public-nav-bar`, `quick-links-panel`, `tree-navigation-sidebar`, `app-shell-header` |
| Feedback & Indicators | `status-badge`, `loading-spinner-overlay`, `error-status-banner`, `accessibility-utilities`, `reaction-picker` |
| Modals & Overlays | `modal-dialog`, `detail-drawer` |
| AI-Specific | `agent-state-indicator`, `tool-catalog-explorer`, `tool-definition-panel`, `tool-description-tailor-panel`, `semantic-memory-search-bar`, `memory-weight-recall-indicator`, `ai-generation-card` |
| Domain-Specific | `board-column`, `pixel-anchored-overlay-commenter`, `permission-scope-picker`, `npl-reference-detail-card`, `custom-field-type-editor`, `polymorphic-link-panel`, `media-capture-gallery`, `pbac-policy-simulator` |

## Full Index

| # | Component | Category | Used In (count) | Screens |
|---|-----------|----------|:---:|---------|
| 01 | Data Table | Tables & Lists | 18 | 08, 10, 11, 12, 13, 14, 15, 16, 20, 25, 29, 31, 37, 38, 41, 44, 46, 47 |
| 02 | Search & Filter Bar | Input & Forms | 10 | 06, 18, 20, 25, 28, 29, 31, 39, 42, 43 |
| 03 | Create Entity Button | Input & Forms | 10 | 06, 18, 20, 22, 25, 29, 31, 37, 38, 41 |
| 04 | Selector / Dropdown | Input & Forms | 8 | 07, 10, 21, 24, 37, 41, 44, 47 |
| 05 | Toggle Switch | Input & Forms | 4 | 10, 18, 22, 26 |
| 06 | Settings Form | Input & Forms | 9 | 07, 14, 15, 16, 23, 33, 35, 44, 45 |
| 07 | SSO Auth Button | Input & Forms | 2 | 02, 04 |
| 08 | Dynamic Custom-Field Form | Input & Forms | 1 | 25 |
| 09 | Message Composer | Input & Forms | 1 | 23 |
| 10 | Card Grid | Cards & Tiles | 3 | 01, 06, 18 |
| 11 | Entity Header Card | Cards & Tiles | 3 | 19, 21, 33 |
| 12 | Ticket Card | Cards & Tiles | 1 | 24 |
| 13 | Stat Summary Cards | Data Display | 2 | 09, 17 |
| 14 | Activity Timeline | Data Display | 5 | 06, 09, 17, 25, 33 |
| 15 | Version History Panel | Data Display | 2 | 32, 35 |
| 16 | Localized Content Renderer | Data Display | 2 | 26, 28 |
| 17 | Message Timeline (Virtualized) | Data Display | 1 | 23 |
| 18 | Comment Thread Panel | Data Display | 2 | 28, 38 |
| 19 | Connected Account Panel | Data Display | 2 | 07, 13 |
| 20 | Public Nav Bar | Navigation & Layout | 2 | 01, 02 |
| 21 | Quick Links Panel | Navigation & Layout | 2 | 09, 17 |
| 22 | Tree Navigation Sidebar | Navigation & Layout | 3 | 28, 42, 43 |
| 23 | App Shell Header | Navigation & Layout | 4 | 06, 07, 08, 09 |
| 24 | Status Badge | Feedback & Indicators | 9 | 04, 05, 08, 11, 14, 16, 22, 36, 38 |
| 25 | Loading Spinner Overlay | Feedback & Indicators | 2 | 02, 03 |
| 26 | Error / Status Banner | Feedback & Indicators | 4 | 02, 03, 04, 19 |
| 27 | Accessibility Utilities | Feedback & Indicators | 3 | 17, 23, 24 |
| 28 | Reaction Picker | Feedback & Indicators | 2 | 23, 28 |
| 29 | Modal Dialog | Modals & Overlays | 4 | 10, 13, 20, 45 |
| 30 | Detail Drawer | Modals & Overlays | 2 | 11, 15 |
| 31 | Agent State Indicator | AI-Specific | 1 | 33 |
| 32 | Tool Catalog Explorer | AI-Specific | 2 | 08, 40 |
| 33 | Tool Definition Panel | AI-Specific | 2 | 08, 40 |
| 34 | Tool Description Tailor Panel | AI-Specific | 1 | 21 |
| 35 | Semantic Memory Search Bar | AI-Specific | 1 | 36 |
| 36 | Memory Weight & Recall Indicator | AI-Specific | 1 | 36 |
| 37 | AI Generation Card | AI-Specific | 3 | 34, 40, 46 |
| 38 | Board Column | Domain-Specific | 1 | 24 |
| 39 | Pixel-Anchored Overlay Commenter | Domain-Specific | 1 | 30 |
| 40 | Permission Scope Picker | Domain-Specific | 3 | 15, 19, 45 |
| 41 | NPL Reference Detail Card | Domain-Specific | 2 | 42, 43 |
| 42 | Custom Field & Type Editor | Domain-Specific | 1 | 27 |
| 43 | Polymorphic Link Panel | Domain-Specific | 3 | 19, 21, 26 |
| 44 | Media Capture Gallery | Domain-Specific | 1 | 39 |
| 45 | PBAC Policy Simulator | Domain-Specific | 1 | 12 |

## Notes

- Single-screen entries (count = 1) are included only where the screen's Key Components / Interactions describe genuinely complex, bespoke behavior (drag-and-drop kanban columns, pixel-anchored annotation, live agent state, policy simulation, schema-driven forms) rather than page-unique static content.
- Every one of the 47 source screens is covered by at least one component in this index.
