# Screen Inventory

**Total screens: 37**
**User stories mapped: 150/150** (all mapped to at least one screen or marked as CLI/SDK-only below)

## Screen Categories

| Category | Screens | Count |
|----------|---------|-------|
| Script Authoring | script-list, graph-editor, script-version-diff | 3 |
| Prompt Management | prompt-library, prompt-detail | 2 |
| Agent Connectors | agent-list, agent-detail | 2 |
| Run Execution | run-trigger-modal, schedule-list, batch-run-dashboard | 3 |
| Results & Dashboards | run-list, run-detail, run-diff, trend-dashboard, cohort-dashboard, custom-dashboard-builder | 6 |
| Rubric & Scoring | rubric-list, rubric-detail, rubric-score-comparison, rubric-marketplace | 4 |
| Persona Management | persona-list, persona-detail, persona-library-modal, persona-marketplace, persona-heatmap | 5 |
| Freeball Protocol | freeball-confidence-histogram | 1 |
| Review & Promotion | review-queue, review-detail | 2 |
| Datasets | dataset-list, dataset-detail | 2 |
| Flagged Captures | flagged-captures-library, capture-detail, auto-flag-rules | 3 |
| Observability | otel-span-search, otel-span-drilldown | 2 |
| Tenancy & Admin | organization-settings, api-token-management | 2 |

## Type Legend

| Type | Description |
|------|-------------|
| **Primary** | Full-page views in main navigation |
| **Dashboard** | Aggregation/metrics/visualization views |
| **Settings** | Configuration panels |
| **Modal** | Overlays/dialogs triggered from other screens |
| **Storyboard** | Multi-step flows/wizards |

## Type Distribution

| Type | Count |
|------|-------|
| Primary | 25 |
| Dashboard | 6 |
| Settings | 3 |
| Modal | 2 |
| Storyboard | 1 |

## CLI/SDK-Only Stories (No Dedicated UI Screen)

The following user stories describe CLI, SDK, or CI/CD functionality that does not require a dedicated screen but may surface results in existing screens (Run List, Run Detail, etc.):

| Story | Title | Surface |
|-------|-------|---------|
| US-037 | Run script via CLI | Results visible in Run List/Detail |
| US-038 | CLI pass/fail exit code | Terminal output only |
| US-083 | CLI JUnit output | File output only |
| US-084 | CLI --personas flag | Terminal output only |
| US-085 | GitHub Actions workflow | CI artifact |
| US-086 | GitLab CI template | CI artifact |
| US-087 | CLI login/token management | Terminal flow; tokens visible in API Token Management |
| US-091 | Python SDK core | Library only |
| US-092 | Elixir SDK core | Library only |
| US-093 | TypeScript SDK core | Library only |
| US-094 | SDK OTel bridge helper | Library only |
| US-095 | SDK query helpers | Library only |
| US-134 | codefresh init scaffolding | Terminal flow only |
| US-135 | CLI watch mode | Terminal flow only |
| US-136 | CLI TAP/Allure formats | File output only |
| US-144 | SDK webhook subscriptions | Configured in Org Settings; delivery log visible there |
| US-145 | React hooks package | Library only |
| US-146 | SDK Deno/Bun publish | Library only |
| US-148 | Flag digest email | Email delivery only |
| US-133 | ClickHouse mirror | Infrastructure only |

## Full Story-to-Screen Mapping

| Screen | User Stories |
|--------|-------------|
| 01-script-list | US-001, US-006, US-007, US-044, US-046, US-047 |
| 02-graph-editor | US-001, US-002, US-003, US-004, US-005, US-006, US-008, US-011, US-015, US-041, US-042, US-043, US-044, US-045, US-048, US-074, US-075, US-111, US-112, US-113 |
| 03-script-version-diff | US-045 |
| 04-prompt-library | US-009, US-010, US-050 |
| 05-prompt-detail | US-009, US-010, US-011, US-048, US-049, US-114, US-115 |
| 06-agent-list | US-012, US-061, US-062, US-063, US-065, US-122 |
| 07-agent-detail | US-012, US-013, US-014, US-050, US-061, US-062, US-063, US-064, US-065, US-122, US-123 |
| 08-run-list | US-025, US-026, US-027, US-028, US-029, US-077, US-079, US-080 |
| 09-run-detail | US-016, US-017, US-018, US-019, US-020, US-021, US-022, US-023, US-024, US-029, US-030, US-031, US-032, US-036, US-054, US-066, US-067, US-068, US-099 |
| 10-run-diff | US-077 |
| 11-rubric-list | US-033, US-119 |
| 12-rubric-detail | US-033, US-034, US-056, US-057, US-058, US-059, US-060, US-120 |
| 13-persona-list | US-035, US-055, US-116 |
| 14-persona-detail | US-035, US-036, US-051, US-053 |
| 15-run-trigger-modal | US-015, US-036, US-052, US-067, US-070, US-076, US-124 |
| 16-review-queue | US-088, US-089, US-090, US-137, US-138, US-139, US-140, US-141 |
| 17-review-detail | US-089, US-090, US-139 |
| 18-dataset-list | US-101, US-104, US-149 |
| 19-dataset-detail | US-101, US-102, US-103, US-104, US-105, US-110, US-125, US-150 |
| 20-flagged-captures-library | US-106, US-107, US-108, US-109, US-147 |
| 21-capture-detail | US-106, US-108, US-109 |
| 22-otel-span-search | US-098, US-100 |
| 23-otel-span-drilldown | US-099 |
| 24-organization-settings | US-039, US-040, US-064, US-071, US-096, US-097, US-131, US-132, US-142, US-143 |
| 25-schedule-list | US-069 |
| 26-trend-dashboard | US-078 |
| 27-cohort-dashboard | US-129 |
| 28-persona-heatmap | US-117 |
| 29-custom-dashboard-builder | US-130 |
| 30-batch-run-dashboard | US-070 |
| 31-rubric-score-comparison | US-059, US-060, US-121 |
| 32-auto-flag-rules | US-147 |
| 33-persona-library-modal | US-055 |
| 34-persona-marketplace | US-116 |
| 35-rubric-marketplace | US-119 |
| 36-freeball-confidence-histogram | US-126 |
| 37-api-token-management | US-096, US-097 |

## Stories Mapped to CLI/SDK/Infra (No Screen)

US-037, US-038, US-083, US-084, US-085, US-086, US-087, US-091, US-092, US-093, US-094, US-095, US-133, US-134, US-135, US-136, US-144, US-145, US-146, US-148

## Stories Mapped to Multiple Screens (Behavior Spans UI Boundaries)

- US-007 (Import YAML): Script List + CLI
- US-008 (Export YAML): Graph Editor + CLI
- US-032 (Export JSON): Run Detail + CLI
- US-034 (Attach rubric): Graph Editor + Rubric Detail
- US-066 (Retry run): Run Detail
- US-072 (Freeball depth cap): Run Detail (visible in error state)
- US-073 (Freeball nesting): Run Detail (nested display)
- US-074/US-075 (Strict/Required mode): Graph Editor node config
- US-076 (Runner capability warning): Run Trigger Modal
- US-081/US-082 (OTLP receiver/correlator): Backend-only, results in OTel screens
- US-105 (Run dataset): Dataset Detail trigger, results in Run Detail
- US-118 (Per-step persona switching): Graph Editor (node config) + Run Detail (display)
- US-127 (Freeball learning mode): Organization Settings toggle
- US-128 (Adaptive freeball depth): Run config in Run Trigger Modal

## Confirmation

All 150 user stories (US-001 through US-150) are accounted for:
- **130 stories** mapped to one or more UI screens
- **20 stories** are CLI/SDK/infrastructure-only with no dedicated UI screen (results surface in existing screens where applicable)
