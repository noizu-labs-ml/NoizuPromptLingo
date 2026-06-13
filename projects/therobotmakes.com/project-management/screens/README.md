# noizu.ink — Screen Inventory

30 screens extracted from 100 user stories (INK-001 through INK-100), covering all 4 pipeline phases plus platform infrastructure.

## Screen Index by Category

### Authentication (3 screens)

| # | Screen | Type | User Stories |
|---|--------|------|--------------|
| 02 | [Signup](02-signup.md) | Primary | INK-001, INK-003 |
| 03 | [Login](03-login.md) | Primary | INK-002, INK-003 |
| 04 | [Password Reset](04-password-reset.md) | Storyboard | INK-004 |

### Marketing (1 screen)

| # | Screen | Type | User Stories |
|---|--------|------|--------------|
| 01 | [Landing Page](01-landing-page.md) | Primary | INK-081, INK-082, INK-083, INK-084 |

### Onboarding (1 screen)

| # | Screen | Type | User Stories |
|---|--------|------|--------------|
| 06 | [Project Type Selector](06-project-type-selector.md) | Primary | INK-087 |

### Sketch Phase (5 screens)

| # | Screen | Type | User Stories |
|---|--------|------|--------------|
| 07 | [Pitch Input](07-pitch-input.md) | Primary | INK-005, INK-008, INK-085 |
| 08 | [Pitch Refinement](08-pitch-refinement.md) | Primary | INK-006, INK-007 |
| 09 | [Persona Curation](09-persona-curation.md) | Primary | INK-009, INK-010, INK-011, INK-012 |
| 10 | [Story Curation](10-story-curation.md) | Primary | INK-013, INK-014, INK-015, INK-016 |
| 11 | [PRD Editor](11-prd-editor.md) | Primary | INK-017, INK-018, INK-019, INK-020 |

### Draft Phase (8 screens)

| # | Screen | Type | User Stories |
|---|--------|------|--------------|
| 12 | [Style Preset Picker](12-style-preset-picker.md) | Primary | INK-021, INK-022 |
| 13 | [Color Palette Editor](13-color-palette-editor.md) | Primary | INK-023 |
| 14 | [Typography Scale](14-typography-scale.md) | Primary | INK-024 |
| 15 | [Spacing & Layout Tokens](15-spacing-layout-tokens.md) | Primary | INK-025, INK-026 |
| 16 | [Style Guide Revision](16-style-guide-revision.md) | Primary | INK-027 |
| 17 | [Wireframe Gallery](17-wireframe-gallery.md) | Primary | INK-028, INK-031 |
| 18 | [Wireframe Editor](18-wireframe-editor.md) | Primary | INK-030, INK-032, INK-033 |
| 19 | [Navigation Flow Diagram](19-navigation-flow-diagram.md) | Primary | INK-029 |
| 20 | [Mockup Viewer](20-mockup-viewer.md) | Primary | INK-034, INK-035, INK-036 |
| 21 | [Interactive Prototype](21-interactive-prototype.md) | Primary | INK-037 |
| 22 | [Export Hub](22-export-hub.md) | Primary | INK-038, INK-039, INK-040, INK-094 |

### Ink Phase (4 screens)

| # | Screen | Type | User Stories |
|---|--------|------|--------------|
| 23 | [Scaffold Generation](23-scaffold-generation.md) | Storyboard | INK-041, INK-042, INK-043, INK-044 |
| 24 | [Agent Development](24-agent-development.md) | Primary | INK-045, INK-046, INK-047, INK-048, INK-049, INK-050, INK-051, INK-052 |
| 25 | [Agent Dashboard](25-agent-dashboard.md) | Dashboard | INK-053, INK-054, INK-055, INK-056 |
| 26 | [Demo Preview](26-demo-preview.md) | Primary | INK-057, INK-058, INK-059, INK-060 |

### Publish Phase (2 screens)

| # | Screen | Type | User Stories |
|---|--------|------|--------------|
| 27 | [Review Gate](27-review-gate.md) | Primary | INK-061, INK-062, INK-063, INK-064 |
| 28 | [Deploy](28-deploy.md) | Storyboard | INK-065, INK-066, INK-067, INK-068 |

### Platform (3 screens)

| # | Screen | Type | User Stories |
|---|--------|------|--------------|
| 05 | [Projects Dashboard](05-projects-dashboard.md) | Dashboard | INK-069, INK-070, INK-071, INK-072, INK-073, INK-088 |
| 29 | [Billing & Settings](29-billing-settings.md) | Settings | INK-074, INK-075, INK-076, INK-077 |
| 30 | [Account Settings](30-account-settings.md) | Settings | INK-089, INK-090, INK-091, INK-092, INK-096 |

## Type Legend

| Type | Count | Purpose |
|------|-------|---------|
| Primary | 23 | Full-page views in main navigation |
| Dashboard | 2 | Aggregation/metrics views |
| Settings | 2 | Configuration panels |
| Storyboard | 3 | Multi-step flows/wizards |

## Coverage

- **Total screens:** 30
- **User stories mapped:** 100/100
- **Cross-cutting stories** (INK-078, INK-079, INK-080, INK-085, INK-086, INK-093, INK-095, INK-097, INK-098, INK-099, INK-100) affect multiple screens as platform-wide behaviors rather than dedicated views

## Cross-Cutting Concerns (not dedicated screens)

These user stories apply across all/multiple screens rather than mapping to a single dedicated view:

| ID | Title | Applies To |
|----|-------|------------|
| INK-078 | Project Resume from Any Step | All project phase screens (breadcrumb nav) |
| INK-079 | Project Duplication as Template | 05-Projects Dashboard (modal) |
| INK-080 | Project Archiving and Read-Only Sharing | 05-Projects Dashboard + shared viewer |
| INK-085 | Wizard-as-Onboarding | 07-Pitch Input + all Sketch screens |
| INK-086 | Progressive Feature Disclosure | All phase screens |
| INK-093 | Shareable Read-Only Links | All project screens (share action) |
| INK-095 | Export to GitHub | 22-Export Hub + 28-Deploy |
| INK-097 | WCAG 2.2 AA Compliance | All screens |
| INK-098 | Full Keyboard Navigation | All screens |
| INK-099 | Screen Reader Support | 25-Agent Dashboard + all phase screens |
| INK-100 | Mobile-Responsive | All screens |
