/**
 * Tier-3 stub collaboration data: chat rooms, artifacts, pipeline runs, agents.
 * These back pages that are clearly labeled "coming soon" in the UI.
 */

import type { AgentDefinition, Artifact, ChatRoom, PipelineRun } from "../types";
import { daysAgo, hoursAgo, makeRandom, pick, shortUuid } from "./helpers";

const ROOM_NAMES = [
  "npl-core",
  "frontend-review",
  "weekly-sync",
  "onboarding",
  "incidents",
];

const ARTIFACT_TITLES = [
  "PRD-007-web-interface.md",
  "auth-flow-diagram.svg",
  "npl-full.md",
  "migration-notes-3.x.md",
  "test-coverage-summary.yaml",
  "session-tree-schema.json",
];

const ARTIFACT_KINDS = ["markdown", "yaml", "json", "svg", "code"];

const AGENT_LIST: AgentDefinition[] = [
  { name: "npl-idea-to-spec", purpose: "Feature ideas → personas + user stories", kind: "pipeline" },
  { name: "npl-prd-editor", purpose: "User stories → PRD documents", kind: "pipeline" },
  { name: "npl-tdd-tester", purpose: "PRD → test suites", kind: "pipeline" },
  { name: "npl-tdd-coder", purpose: "Test suites → implementation", kind: "pipeline" },
  { name: "npl-tdd-debugger", purpose: "Test failures → root cause analysis", kind: "pipeline" },
  { name: "npl-winnower", purpose: "Response quality filtering", kind: "utility" },
  { name: "npl-technical-writer", purpose: "Documentation generation", kind: "utility" },
  { name: "npl-tasker-haiku", purpose: "Simple lookups (cheapest)", kind: "executor" },
  { name: "npl-tasker-fast", purpose: "Moderate tasks (fastest)", kind: "executor" },
  { name: "npl-tasker-sonnet", purpose: "Balanced complexity", kind: "executor" },
  { name: "npl-tasker-opus", purpose: "Complex analysis (expensive)", kind: "executor" },
  { name: "npl-tasker-ultra", purpose: "Opus-level reasoning, faster inference", kind: "executor" },
];

function generateRooms(): ChatRoom[] {
  const rng = makeRandom(11111);
  return ROOM_NAMES.map((name, i) => ({
    id: `room-${shortUuid(rng, 6)}`,
    name,
    description: `Shared context for ${name.replace(/-/g, " ")}.`,
    message_count: 4 + Math.floor(rng() * 120),
    last_activity: hoursAgo(Math.floor(rng() * 240)),
  }));
}

function generateArtifacts(): Artifact[] {
  const rng = makeRandom(22222);
  return ARTIFACT_TITLES.map((title, i) => ({
    id: i + 1,
    title,
    kind: pick(rng, ARTIFACT_KINDS) as Artifact["kind"],
    description: "",
    created_by: null,
    latest_revision: 1 + Math.floor(rng() * 8),
    created_at: daysAgo(Math.floor(rng() * 40)),
    updated_at: hoursAgo(Math.floor(rng() * 240)),
  }));
}

function generatePipelineRuns(): PipelineRun[] {
  const rng = makeRandom(33333);
  const features = [
    "Add NPLLoad MCP tool",
    "Migrate to FastMCP 3.x",
    "Consolidate NPL source directories",
    "Rewrite e2e tests for real tools",
  ];
  const statuses = ["complete", "complete", "failed", "complete"] as const;
  const stages = ["test", "code", "debug", "spec"];
  return features.map((feature, i) => ({
    id: `run-${shortUuid(rng, 6)}`,
    feature,
    status: statuses[i % statuses.length],
    stage: stages[i % stages.length],
    started_at: daysAgo(i + 1),
    completed_at:
      statuses[i % statuses.length] === "complete" ? daysAgo(i + 1) : null,
  }));
}

export const CHAT_ROOMS: ChatRoom[] = generateRooms();
export const ARTIFACTS: Artifact[] = generateArtifacts();
export const AGENTS: AgentDefinition[] = AGENT_LIST;
export const PIPELINE_RUNS: PipelineRun[] = generatePipelineRuns();
