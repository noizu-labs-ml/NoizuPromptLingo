# User Stories Index

Regenerated catalog of all stories. One row per file.
Regenerated from YAML frontmatters on disk by `scripts/regen-user-stories-index.py`.

**Progress:** 0 shipped / 129 in-progress / 150 total

## Wave 1 — P0 (MVP-blocking)

| ID | Title | Category | Pri | SP | Primary persona | Status |
|---|---|---|---|---|---|---|
| [US-001](US-001-create-empty-script.md) | Create an empty script with name and description | script-authoring | P0 | 2 | priya-ml-engineer | in-progress |
| [US-002](US-002-add-user-turn-node.md) | Add a user-turn node to a script | script-authoring | P0 | 2 | priya-ml-engineer | in-progress |
| [US-003](US-003-attach-prompt-to-node.md) | Attach a prompt to a script node | script-authoring | P0 | 2 | priya-ml-engineer | in-progress |
| [US-004](US-004-add-expectation-to-node.md) | Add an expectation to a script node | script-authoring | P0 | 3 | priya-ml-engineer | in-progress |
| [US-005](US-005-add-edge-with-match-condition.md) | Add a directed edge between two nodes with a match condition | script-authoring | P0 | 3 | priya-ml-engineer | in-progress |
| [US-006](US-006-publish-first-script-version.md) | Publish the first version of a script | script-authoring | P0 | 3 | priya-ml-engineer | in-progress |
| [US-007](US-007-import-script-from-yaml.md) | Import a script from a YAML file | script-authoring | P0 | 5 | alex-oss-maintainer | in-progress |
| [US-008](US-008-export-script-to-yaml.md) | Export a script to YAML | script-authoring | P0 | 3 | alex-oss-maintainer | in-progress |
| [US-009](US-009-create-standalone-prompt.md) | Create a standalone prompt | prompt-management | P0 | 2 | priya-ml-engineer | in-progress |
| [US-010](US-010-publish-prompt-version.md) | Publish a new prompt version | prompt-management | P0 | 2 | priya-ml-engineer | in-progress |
| [US-011](US-011-reference-prompt-from-node.md) | Reference a published prompt from a script node | prompt-management | P0 | 2 | priya-ml-engineer | in-progress |
| [US-012](US-012-configure-openai-agent-adapter.md) | Configure an OpenAI agent adapter | agent-connectors | P0 | 3 | priya-ml-engineer | in-progress |
| [US-013](US-013-test-agent-health-check.md) | Test agent connectivity with a health check | agent-connectors | P0 | 2 | priya-ml-engineer | in-progress |
| [US-014](US-014-publish-agent-version.md) | Publish an agent version | agent-connectors | P0 | 2 | priya-ml-engineer | in-progress |
| [US-015](US-015-trigger-one-off-run.md) | Trigger a one-off run from the editor | run-execution | P0 | 5 | priya-ml-engineer | in-progress |
| [US-016](US-016-view-run-status-realtime.md) | View run status update in real time | run-execution | P0 | 5 | priya-ml-engineer | in-progress |
| [US-017](US-017-see-step-prompt-and-response.md) | See each step's prompt and agent response in run detail | run-execution | P0 | 3 | priya-ml-engineer | in-progress |
| [US-018](US-018-cancel-in-flight-run.md) | Cancel an in-flight run | run-execution | P0 | 3 | priya-ml-engineer | in-progress |
| [US-019](US-019-run-level-verdict.md) | Get run-level pass/warn/fail verdict | run-execution | P0 | 3 | priya-ml-engineer | in-progress |
| [US-020](US-020-see-individual-step-scores.md) | See individual step scores | run-execution | P0 | 3 | priya-ml-engineer | in-progress |
| [US-021](US-021-aggregate-run-score-summary.md) | See aggregate score summary for a run | run-execution | P0 | 3 | priya-ml-engineer | in-progress |
| [US-022](US-022-fall-through-to-freeball.md) | Fall through to freeball when no authored edge matches | freeball-protocol | P0 | 5 | priya-ml-engineer | in-progress |
| [US-023](US-023-see-freeball-prompt.md) | See freeball-generated prompt in run detail | freeball-protocol | P0 | 2 | priya-ml-engineer | in-progress |
| [US-024](US-024-see-freeball-confidence.md) | See freeball runner confidence per tentative node | freeball-protocol | P0 | 2 | priya-ml-engineer | in-progress |
| [US-025](US-025-list-recent-runs.md) | List recent runs for an organization | results-and-dashboards | P0 | 3 | priya-ml-engineer | in-progress |
| [US-026](US-026-filter-runs-by-script.md) | Filter the run list by script | results-and-dashboards | P0 | 2 | priya-ml-engineer | in-progress |
| [US-027](US-027-filter-runs-by-agent.md) | Filter the run list by agent | results-and-dashboards | P0 | 2 | priya-ml-engineer | in-progress |
| [US-028](US-028-filter-runs-by-status.md) | Filter the run list by status | results-and-dashboards | P0 | 2 | priya-ml-engineer | in-progress |
| [US-029](US-029-open-run-detail-from-list.md) | Open run detail from the list | results-and-dashboards | P0 | 2 | priya-ml-engineer | in-progress |
| [US-030](US-030-conversation-as-timeline.md) | View the conversation as a linear timeline | results-and-dashboards | P0 | 3 | priya-ml-engineer | in-progress |
| [US-031](US-031-drill-down-step-json.md) | Drill down into a single step's full JSON payload | results-and-dashboards | P0 | 3 | priya-ml-engineer | in-progress |
| [US-032](US-032-export-run-as-json.md) | Export a single run as JSON | results-and-dashboards | P0 | 3 | priya-ml-engineer | in-progress |
| [US-033](US-033-create-simple-rubric.md) | Create a simple rubric with LLM-as-judge scoring | rubric-and-scoring | P0 | 3 | sofia-product-manager | in-progress |
| [US-034](US-034-attach-rubric-to-expectation.md) | Attach a rubric to an expectation | rubric-and-scoring | P0 | 2 | sofia-product-manager | in-progress |
| [US-035](US-035-create-basic-persona.md) | Create a basic persona with a tone tag | persona-management | P0 | 2 | yuki-red-teamer | in-progress |
| [US-036](US-036-attach-persona-to-run.md) | Attach a persona to a run | persona-management | P0 | 3 | yuki-red-teamer | in-progress |
| [US-037](US-037-run-script-via-cli.md) | Run a script via codefresh CLI with a YAML file | cli-and-cicd | P0 | 5 | priya-ml-engineer | in-progress |
| [US-038](US-038-cli-pass-fail-exit-code.md) | Get a pass/fail exit code from the CLI | cli-and-cicd | P0 | 2 | priya-ml-engineer | in-progress |
| [US-039](US-039-create-organization.md) | Create an organization | tenancy-and-admin | P0 | 2 | marcus-qa-lead | in-progress |
| [US-040](US-040-invite-user-to-organization.md) | Invite a user as a member of an organization | tenancy-and-admin | P0 | 3 | marcus-qa-lead | in-progress |

## Wave 2 — P1 (Post-MVP polish)

| ID | Title | Category | Pri | SP | Primary persona | Status |
|---|---|---|---|---|---|---|
| [US-041](US-041-add-system-prompt-node.md) | Add a system-prompt node to a script | script-authoring | P1 | 3 | priya-ml-engineer | in-progress |
| [US-042](US-042-add-terminal-node.md) | Add a terminal node to mark the end of a conversation path | script-authoring | P1 | 2 | priya-ml-engineer | in-progress |
| [US-043](US-043-add-freeball-anchor-node.md) | Add a freeball-anchor node to explicitly invite freeball from a point | script-authoring | P1 | 3 | priya-ml-engineer | in-progress |
| [US-044](US-044-start-new-draft-from-published-version.md) | Start a new draft from a published script version | script-authoring | P1 | 3 | priya-ml-engineer | in-progress |
| [US-045](US-045-diff-script-versions.md) | Diff two script versions visually | script-authoring | P1 | 5 | priya-ml-engineer | in-progress |
| [US-046](US-046-fork-script.md) | Fork a published script into a new independent head | script-authoring | P1 | 3 | alex-oss-maintainer | in-progress |
| [US-047](US-047-archive-script.md) | Archive a script | script-authoring | P1 | 2 | marcus-qa-lead | in-progress |
| [US-048](US-048-prompt-template-variables.md) | Define template variables on a prompt | prompt-management | P1 | 3 | priya-ml-engineer | in-progress |
| [US-049](US-049-prompt-tool-schemas.md) | Define tool/function schemas on a prompt | prompt-management | P1 | 5 | priya-ml-engineer | in-progress |
| [US-050](US-050-browse-prompt-library.md) | Browse the prompt library and reuse across scripts | prompt-management | P1 | 2 | priya-ml-engineer | in-progress |
| [US-051](US-051-attach-persona-expectations-to-nodes.md) | Attach persona-layered expectations to script nodes | persona-management | P1 | 5 | derek-support-engineer | in-progress |
| [US-052](US-052-fan-out-across-personas.md) | Fan out a run across multiple personas in parallel | persona-management | P1 | 5 | yuki-red-teamer | in-progress |
| [US-053](US-053-persona-system-preamble.md) | Attach a system-prompt preamble to a persona | persona-management | P1 | 3 | derek-support-engineer | in-progress |
| [US-054](US-054-per-persona-results-breakdown.md) | See per-persona results breakdown on a run | persona-management | P1 | 3 | derek-support-engineer | draft |
| [US-055](US-055-import-persona-library.md) | Import a persona from a shared starter library | persona-management | P1 | 3 | alex-oss-maintainer | in-progress |
| [US-056](US-056-weighted-multi-criterion-rubric.md) | Define a weighted multi-criterion rubric | rubric-and-scoring | P1 | 5 | sofia-product-manager | in-progress |
| [US-057](US-057-ladder-enum-scoring-scale.md) | Configure a rubric to use a ladder / enum scoring scale | rubric-and-scoring | P1 | 3 | sofia-product-manager | in-progress |
| [US-058](US-058-preview-rubric-sample.md) | Preview a rubric by scoring a sample response | rubric-and-scoring | P1 | 3 | sofia-product-manager | in-progress |
| [US-059](US-059-rescore-past-run.md) | Re-score a past run with a newer rubric version | rubric-and-scoring | P1 | 5 | nia-academic | draft |
| [US-060](US-060-score-comparison-across-rubric-versions.md) | See side-by-side score comparison across rubric versions | rubric-and-scoring | P1 | 3 | sofia-product-manager | draft |
| [US-061](US-061-anthropic-agent-adapter.md) | Configure an Anthropic agent adapter | agent-connectors | P1 | 3 | priya-ml-engineer | in-progress |
| [US-062](US-062-langchain-agent-adapter.md) | Configure a LangChain agent adapter | agent-connectors | P1 | 5 | alex-oss-maintainer | in-progress |
| [US-063](US-063-http-agent-adapter.md) | Configure an arbitrary HTTP agent adapter | agent-connectors | P1 | 5 | priya-ml-engineer | in-progress |
| [US-064](US-064-agent-cost-cap-rate-limit.md) | Set per-agent cost cap and rate limit | agent-connectors | P1 | 3 | priya-ml-engineer | in-progress |
| [US-065](US-065-agent-health-on-list.md) | See agent connection health at a glance on the agent list | agent-connectors | P1 | 2 | priya-ml-engineer | in-progress |
| [US-066](US-066-retry-failed-run.md) | Retry a failed run from the failing step | run-execution | P1 | 5 | priya-ml-engineer | draft |
| [US-067](US-067-enforce-run-cost-cap.md) | Enforce run-level cost cap (auto-cancel when exceeded) | run-execution | P1 | 3 | priya-ml-engineer | in-progress |
| [US-068](US-068-stream-scores-realtime.md) | Stream scores in real time alongside the step stream | run-execution | P1 | 5 | priya-ml-engineer | draft |
| [US-069](US-069-schedule-recurring-runs.md) | Schedule recurring runs via cron expression | run-execution | P1 | 5 | priya-ml-engineer | in-progress |
| [US-070](US-070-batch-run-multiple-agents.md) | Trigger a batch run against multiple agents | run-execution | P1 | 5 | yuki-red-teamer | in-progress |
| [US-071](US-071-configure-freeball-runner.md) | Configure the freeball runner model and prompt per organization | freeball-protocol | P1 | 3 | priya-ml-engineer | draft |
| [US-072](US-072-freeball-depth-cap.md) | Enforce a freeball depth cap / budget | freeball-protocol | P1 | 3 | priya-ml-engineer | draft |
| [US-073](US-073-freeball-within-freeball.md) | Support freeball-within-freeball nesting | freeball-protocol | P1 | 5 | priya-ml-engineer | draft |
| [US-074](US-074-freeball-strict-mode.md) | Enforce strict mode on a node (reject freeball) | freeball-protocol | P1 | 2 | priya-ml-engineer | in-progress |
| [US-075](US-075-freeball-required-mode.md) | Require freeball mode on a node (force freeball) | freeball-protocol | P1 | 2 | yuki-red-teamer | in-progress |
| [US-076](US-076-runner-capability-match-warning.md) | Warn when freeball runner model is weaker than the target agent | freeball-protocol | P1 | 3 | yuki-red-teamer | draft |
| [US-077](US-077-diff-two-runs.md) | Side-by-side diff view of two runs | results-and-dashboards | P1 | 5 | priya-ml-engineer | in-progress |
| [US-078](US-078-trend-chart-scores-over-time.md) | Trend chart of aggregate scores over time for a script | results-and-dashboards | P1 | 5 | sofia-product-manager | in-progress |
| [US-079](US-079-filter-runs-by-date-range.md) | Filter the run list by date range | results-and-dashboards | P1 | 2 | priya-ml-engineer | in-progress |
| [US-080](US-080-filter-runs-by-persona.md) | Filter the run list by persona | results-and-dashboards | P1 | 2 | derek-support-engineer | in-progress |
| [US-081](US-081-otlp-receiver-endpoint.md) | Stand up an OTLP gRPC receiver endpoint for inbound agent spans | otel-ingestion | P1 | 8 | priya-ml-engineer | in-progress |
| [US-082](US-082-correlate-otel-spans-to-run-steps.md) | Correlate inbound OTel spans to run_steps | otel-ingestion | P1 | 5 | priya-ml-engineer | in-progress |
| [US-083](US-083-cli-junit-output.md) | Emit JUnit XML from the CLI | cli-and-cicd | P1 | 3 | priya-ml-engineer | in-progress |
| [US-084](US-084-cli-personas-flag.md) | Run with --personas flag from the CLI | cli-and-cicd | P1 | 3 | derek-support-engineer | in-progress |
| [US-085](US-085-github-actions-reusable-workflow.md) | Publish a GitHub Actions reusable workflow for CodeFresh | cli-and-cicd | P1 | 3 | priya-ml-engineer | in-progress |
| [US-086](US-086-gitlab-ci-template.md) | Publish a GitLab CI template for CodeFresh | cli-and-cicd | P1 | 2 | priya-ml-engineer | in-progress |
| [US-087](US-087-cli-login-token-management.md) | codefresh login and local token management | cli-and-cicd | P1 | 5 | priya-ml-engineer | in-progress |
| [US-088](US-088-review-queue-page.md) | Show the freeball review queue | review-and-promotion | P1 | 5 | marcus-qa-lead | in-progress |
| [US-089](US-089-claim-approve-reject-freeball.md) | Claim, approve, or reject a freeball node | review-and-promotion | P1 | 5 | marcus-qa-lead | in-progress |
| [US-090](US-090-promote-freeball-chain.md) | Promote a freeball chain to a new script version | review-and-promotion | P1 | 8 | marcus-qa-lead | in-progress |
| [US-091](US-091-python-sdk-core.md) | Python SDK core — install, authenticate, trigger runs | sdks | P1 | 5 | priya-ml-engineer | in-progress |
| [US-092](US-092-elixir-sdk-core.md) | Elixir SDK core — install, authenticate, trigger runs | sdks | P1 | 5 | priya-ml-engineer | in-progress |
| [US-093](US-093-typescript-sdk-core.md) | TypeScript SDK core — install, authenticate, trigger runs | sdks | P1 | 5 | alex-oss-maintainer | in-progress |
| [US-094](US-094-sdk-otel-bridge-helper.md) | SDK OTel bridge helper for emitting spans to CodeFresh | sdks | P1 | 5 | priya-ml-engineer | in-progress |
| [US-095](US-095-sdk-query-helpers.md) | SDK query helpers for runs, steps, and scores | sdks | P1 | 3 | priya-ml-engineer | in-progress |
| [US-096](US-096-issue-api-token.md) | Issue an API token for SDK / CLI use | tenancy-and-admin | P1 | 3 | priya-ml-engineer | in-progress |
| [US-097](US-097-revoke-rotate-api-token.md) | Revoke or rotate an API token | tenancy-and-admin | P1 | 2 | marcus-qa-lead | in-progress |
| [US-098](US-098-otel-span-query-by-attribute.md) | Query OTel spans by attribute | otel-ingestion | P1 | 5 | priya-ml-engineer | in-progress |
| [US-099](US-099-otel-span-drilldown-in-step.md) | Drill down from a run step into its OTel span tree | otel-ingestion | P1 | 5 | priya-ml-engineer | in-progress |
| [US-100](US-100-otel-semantic-span-search.md) | Semantic search over OTel span names and messages | otel-ingestion | P1 | 5 | priya-ml-engineer | in-progress |
| [US-101](US-101-create-dataset.md) | Create a dataset of request / expected-output pairs | datasets | P1 | 3 | nia-academic | in-progress |
| [US-102](US-102-publish-dataset-version.md) | Publish a new dataset version | datasets | P1 | 3 | nia-academic | in-progress |
| [US-103](US-103-add-dataset-entries.md) | Add entries to a dataset manually | datasets | P1 | 3 | sofia-product-manager | in-progress |
| [US-104](US-104-import-dataset-csv-json.md) | Import a dataset from CSV or JSON | datasets | P1 | 5 | nia-academic | in-progress |
| [US-105](US-105-run-dataset-against-agent.md) | Run a dataset against an agent (model-based eval) | datasets | P1 | 8 | nia-academic | in-progress |
| [US-106](US-106-flag-otel-span-or-interaction.md) | Flag an OTel span or production interaction for future eval use | flagged-captures | P1 | 5 | derek-support-engineer | in-progress |
| [US-107](US-107-browse-flagged-captures-library.md) | Browse the flagged captures library | flagged-captures | P1 | 3 | derek-support-engineer | in-progress |
| [US-108](US-108-promote-flag-to-script-node.md) | Promote a flagged capture to a script node input | flagged-captures | P1 | 5 | derek-support-engineer | in-progress |
| [US-109](US-109-promote-flag-to-dataset-entry.md) | Promote a flagged capture to a dataset entry | flagged-captures | P1 | 5 | derek-support-engineer | in-progress |
| [US-110](US-110-attach-rubric-to-dataset.md) | Attach a rubric to a dataset | datasets | P1 | 3 | sofia-product-manager | in-progress |

## Wave 3 — P2/P3 (Post-launch growth)

| ID | Title | Category | Pri | SP | Primary persona | Status |
|---|---|---|---|---|---|---|
| [US-111](US-111-bulk-node-operations.md) | Bulk node operations in the graph editor | script-authoring | P2 | 5 | priya-ml-engineer | cancelled |
| [US-112](US-112-node-inline-comments.md) | Inline comments on script nodes | script-authoring | P2 | 3 | marcus-qa-lead | cancelled |
| [US-114](US-114-prompt-testing-sandbox.md) | Prompt testing sandbox | prompt-management | P2 | 3 | priya-ml-engineer | in-progress |
| [US-116](US-116-persona-marketplace.md) | Import a persona from a shared marketplace | persona-management | P2 | 5 | derek-support-engineer | draft |
| [US-119](US-119-rubric-marketplace.md) | Import a rubric from a shared marketplace | rubric-and-scoring | P2 | 5 | sofia-product-manager | in-progress |
| [US-120](US-120-rubric-confidence-bands.md) | Rubric confidence bands on scores | rubric-and-scoring | P2 | 3 | nia-academic | in-progress |
| [US-122](US-122-bedrock-vertex-agent-adapters.md) | Bedrock and Vertex AI agent adapters | agent-connectors | P2 | 5 | priya-ml-engineer | in-progress |
| [US-123](US-123-agent-streaming-response-support.md) | Agent response streaming support | agent-connectors | P2 | 5 | priya-ml-engineer | draft |
| [US-124](US-124-cost-prediction-before-run.md) | Cost prediction before a run is triggered | run-execution | P2 | 3 | priya-ml-engineer | draft |
| [US-129](US-129-cohort-comparison.md) | Cohort comparison across multiple runs | results-and-dashboards | P2 | 5 | yuki-red-teamer | in-progress |
| [US-131](US-131-otel-partition-retention-admin.md) | OTel partition + retention admin | otel-ingestion | P2 | 5 | marcus-qa-lead | in-progress |
| [US-132](US-132-otlp-sampling-config.md) | OTLP ingest sampling configuration | otel-ingestion | P2 | 3 | priya-ml-engineer | in-progress |
| [US-134](US-134-codefresh-init-scaffolding.md) | codefresh init — project scaffolding | cli-and-cicd | P2 | 3 | alex-oss-maintainer | in-progress |
| [US-137](US-137-regression-suite-from-rejected-freeballs.md) | Regression suite from rejected freeballs | review-and-promotion | P2 | 5 | marcus-qa-lead | in-progress |
| [US-138](US-138-bulk-review-actions.md) | Bulk actions on the freeball review queue | review-and-promotion | P2 | 3 | marcus-qa-lead | in-progress |
| [US-140](US-140-review-assignment-workflow.md) | Review assignment workflow | review-and-promotion | P2 | 3 | marcus-qa-lead | in-progress |
| [US-142](US-142-sso-saml-oidc.md) | SSO via SAML / OIDC | tenancy-and-admin | P2 | 8 | marcus-qa-lead | in-progress |
| [US-143](US-143-audit-log-export.md) | Audit log export | tenancy-and-admin | P2 | 5 | marcus-qa-lead | in-progress |
| [US-144](US-144-sdk-webhook-subscriptions.md) | SDK webhook subscriptions | sdks | P2 | 5 | priya-ml-engineer | in-progress |
| [US-147](US-147-auto-flagging-rules.md) | Auto-flagging rules for production captures | flagged-captures | P2 | 5 | derek-support-engineer | in-progress |
| [US-149](US-149-huggingface-datasets-integration.md) | HuggingFace datasets integration | datasets | P2 | 5 | nia-academic | in-progress |
| [US-150](US-150-dataset-parquet-export.md) | Export datasets as Parquet | datasets | P2 | 3 | nia-academic | in-progress |
| [US-113](US-113-auto-layout-graph.md) | Auto-layout the script graph | script-authoring | P3 | 3 | priya-ml-engineer | cancelled |
| [US-115](US-115-prompt-loops-conditionals.md) | Loops and conditionals in prompt templating | prompt-management | P3 | 5 | priya-ml-engineer | in-progress |
| [US-117](US-117-persona-heatmap-visualization.md) | Persona heatmap visualization | persona-management | P3 | 3 | sofia-product-manager | cancelled |
| [US-118](US-118-per-step-persona-switching.md) | Per-step persona switching mid-run | persona-management | P3 | 5 | yuki-red-teamer | draft |
| [US-121](US-121-rubric-disagreement-analytics.md) | Rubric disagreement analytics across runs | rubric-and-scoring | P3 | 5 | nia-academic | draft |
| [US-125](US-125-dataset-run-persona-fanout.md) | Dataset-run persona fan-out | run-execution | P3 | 5 | yuki-red-teamer | in-progress |
| [US-126](US-126-freeball-confidence-distribution.md) | Freeball confidence distribution histograms | freeball-protocol | P3 | 3 | priya-ml-engineer | draft |
| [US-127](US-127-freeball-learning-mode.md) | Freeball learning mode (promoted paths tune the runner) | freeball-protocol | P3 | 8 | yuki-red-teamer | draft |
| [US-128](US-128-adaptive-freeball-depth.md) | Adaptive freeball depth based on confidence | freeball-protocol | P3 | 3 | priya-ml-engineer | draft |
| [US-130](US-130-custom-dashboard-builder.md) | Custom dashboard builder | results-and-dashboards | P3 | 8 | sofia-product-manager | in-progress |
| [US-133](US-133-clickhouse-mirror-for-otel.md) | ClickHouse mirror for OTel spans and logs | otel-ingestion | P3 | 13 | priya-ml-engineer | in-progress |
| [US-135](US-135-cli-watch-mode.md) | CLI watch mode for file changes | cli-and-cicd | P3 | 3 | priya-ml-engineer | in-progress |
| [US-136](US-136-cli-tap-allure-formats.md) | TAP and Allure output formats from CLI | cli-and-cicd | P3 | 3 | priya-ml-engineer | in-progress |
| [US-139](US-139-promote-freeball-to-persona-expectation.md) | Promote a freeball expectation to a persona-scoped expectation | review-and-promotion | P3 | 3 | derek-support-engineer | in-progress |
| [US-141](US-141-freeball-sla-aging-alerts.md) | Freeball SLA aging alerts | review-and-promotion | P3 | 3 | marcus-qa-lead | in-progress |
| [US-145](US-145-react-hooks-package.md) | React hooks package for run state | sdks | P3 | 5 | alex-oss-maintainer | in-progress |
| [US-146](US-146-sdk-deno-bun-publish.md) | SDK publish for Deno and Bun runtimes | sdks | P3 | 2 | alex-oss-maintainer | in-progress |
| [US-148](US-148-flag-digest-email.md) | Flag digest email | flagged-captures | P3 | 2 | derek-support-engineer | in-progress |

