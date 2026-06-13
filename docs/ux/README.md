# UX Wireframes

PlantUML Salt wireframes derived from [user stories](../user-stories/). Each `.puml` file maps to one or more user stories.

## Screen Index

### Script Authoring
| File | Screen | Stories |
|------|--------|---------|
| `script-list.puml` | Script Library | US-001, US-007, US-046, US-047 |
| `script-create-modal.puml` | Create Script Modal | US-001 |
| `script-graph-editor.puml` | Script Graph Editor | US-001–008, US-041–047, US-074, US-075, US-111–113 |
| `node-detail-pane.puml` | Node Detail / Inspector | US-002–004, US-011, US-041–043, US-048, US-112 |
| `expectation-editor.puml` | Expectation Editor | US-004, US-034 |
| `edge-editor.puml` | Edge Editor | US-005 |
| `yaml-import-modal.puml` | YAML Import Modal | US-007 |
| `script-version-history.puml` | Version History Panel | US-006, US-044–046 |
| `script-version-diff.puml` | Version Diff View | US-045 |
| `fork-script-modal.puml` | Fork Script Modal | US-046 |

### Prompt Management
| File | Screen | Stories |
|------|--------|---------|
| `prompt-list.puml` | Prompt Library | US-009, US-050 |
| `prompt-detail-editor.puml` | Prompt Editor | US-009–011, US-048–049, US-114–115 |
| `prompt-picker-modal.puml` | Prompt Picker Modal | US-003, US-011, US-050 |

### Agent Connectors
| File | Screen | Stories |
|------|--------|---------|
| `agent-list.puml` | Agent List | US-065 |
| `agent-config-form.puml` | Agent Configuration | US-012, US-061–064, US-122 |
| `agent-detail.puml` | Agent Detail | US-013–014, US-064 |

### Run Execution
| File | Screen | Stories |
|------|--------|---------|
| `run-trigger-form.puml` | Run Trigger Form | US-015, US-036, US-052, US-067, US-070, US-076, US-124–125 |
| `run-list.puml` | Run List | US-025–029, US-077, US-079–080, US-129 |
| `run-detail.puml` | Run Detail | US-016–024, US-029–030, US-059–060, US-066–068, US-072–073, US-076, US-120, US-123, US-126 |
| `step-json-viewer.puml` | Step JSON Viewer | US-031 |
| `batch-run-dashboard.puml` | Batch Run Dashboard | US-070 |
| `run-diff-view.puml` | Run Diff View | US-077 |
| `schedule-form.puml` | Schedule Configuration | US-069 |
| `schedule-list.puml` | Schedule List | US-069 |
| `dataset-run-trigger-form.puml` | Dataset Run Trigger | US-125 |

### Results & Dashboards
| File | Screen | Stories |
|------|--------|---------|
| `script-trends-tab.puml` | Script Trends Tab | US-078 |
| `cohort-dashboard.puml` | Cohort Dashboard | US-129 |
| `custom-dashboard-builder.puml` | Custom Dashboard Builder | US-130 |

### Rubric & Scoring
| File | Screen | Stories |
|------|--------|---------|
| `rubric-list.puml` | Rubric List | US-033, US-056–057 |
| `rubric-editor.puml` | Rubric Editor | US-033, US-056–058 |
| `rubric-detail.puml` | Rubric Detail | US-033, US-056–057 |
| `rubric-marketplace.puml` | Rubric Marketplace | US-119 |
| `rubric-disagreement-analytics.puml` | Rubric Disagreement | US-121 |

### Persona Management
| File | Screen | Stories |
|------|--------|---------|
| `persona-list.puml` | Persona List | US-035–036, US-051–053 |
| `persona-editor.puml` | Persona Editor | US-035, US-051, US-053 |
| `persona-detail.puml` | Persona Detail | US-035, US-051, US-053 |
| `persona-library-browser.puml` | Persona Library | US-055 |
| `persona-marketplace.puml` | Persona Marketplace | US-116 |
| `persona-heatmap.puml` | Persona Heatmap | US-117 |

### Review & Promotion
| File | Screen | Stories |
|------|--------|---------|
| `review-queue.puml` | Freeball Review Queue | US-088, US-138, US-140–141 |
| `freeball-review-detail.puml` | Freeball Review Detail | US-089, US-139–140 |
| `freeball-promotion-preview.puml` | Promotion Preview | US-090, US-138 |
| `regression-suite-view.puml` | Regression Suite | US-137 |
| `freeball-confidence-histogram.puml` | Confidence Distribution | US-126 |

### OTel Ingestion
| File | Screen | Stories |
|------|--------|---------|
| `otel-span-explorer.puml` | Span Explorer | US-098, US-100 |
| `run-step-otel-tab.puml` | Step OTel Trace Tab | US-099 |
| `span-attribute-detail.puml` | Span Attribute Detail | US-098–099, US-106 |
| `otel-settings-retention.puml` | OTel Retention Settings | US-131 |
| `otel-settings-sampling.puml` | OTel Sampling Config | US-132 |

### Datasets
| File | Screen | Stories |
|------|--------|---------|
| `dataset-list.puml` | Dataset List | US-101–102, US-105, US-149–150 |
| `dataset-create-modal.puml` | Create Dataset Modal | US-101 |
| `dataset-detail.puml` | Dataset Detail | US-101–105, US-110, US-149–150 |
| `dataset-entry-form.puml` | Dataset Entry Form | US-103 |
| `dataset-import-wizard.puml` | Dataset Import Wizard (Step 1) | US-104, US-149 |
| `dataset-import-wizard-step2.puml` | Dataset Import Wizard (Steps 2-3) | US-104, US-149 |
| `run-dataset-modal.puml` | Run Dataset Modal | US-105 |
| `dataset-run-results.puml` | Dataset Run Results | US-105 |

### Flagged Captures
| File | Screen | Stories |
|------|--------|---------|
| `flagged-captures-library.puml` | Captures Library | US-107, US-147–148 |
| `flagged-capture-detail.puml` | Capture Detail | US-106–109 |
| `flag-form-modal.puml` | Flag Capture Modal | US-106 |
| `promote-to-script-modal.puml` | Promote to Script | US-108 |
| `promote-to-dataset-modal.puml` | Promote to Dataset | US-109 |
| `auto-flagging-rules.puml` | Auto-Flagging Rules | US-147 |

### Tenancy & Admin
| File | Screen | Stories |
|------|--------|---------|
| `create-org.puml` | Create Organization | US-039 |
| `org-settings.puml` | Org Settings Shell | US-039–040, US-096–097, US-141–144 |
| `org-members.puml` | Organization Members | US-040 |
| `api-tokens.puml` | API Tokens | US-096–097 |
| `sso-configuration.puml` | SSO Configuration | US-142 |
| `audit-log.puml` | Audit Log | US-143 |
| `webhook-settings.puml` | Webhook Settings | US-144 |
| `org-settings-freeball.puml` | Freeball Settings | US-071, US-127 |
| `notification-preferences.puml` | Notification Prefs | US-148 |
