/**
 * Hybrid implementation: dispatches to REST for domains the backend serves,
 * falls back to mock for domains not yet wired.
 *
 * Wire status:
 *   tools.*        → rest  (/api/catalog*)
 *   sessions.*     → rest  (/api/sessions*)
 *   instructions.* → rest  (/api/instructions*)
 *   projects.*     → rest  (/api/projects*)
 *   personas.*     → rest  (/api/projects/{id}/personas)
 *   stories.*      → rest  (/api/projects/{id}/stories)
 *   prds.*         → rest  (/api/prds*)
 *   docs.*         → rest  (/api/docs/*)
 *   npl.elements   → rest  (/api/npl/elements)
 *   npl.coverage   → rest  (/api/npl/coverage)
 *   npl.*          → rest  (/api/npl/*)
 *   explorer.*     → rest  (/api/project/tree, /api/project/file)
 *   metrics.*      → rest  (/api/errors, /api/metrics/* — 501 returns [] for unprovisioned)
 *   chat.*         → rest  (/api/chat/rooms*)
 *   artifacts.*    → rest  (/api/artifacts*)
 *   orchestration.*  → rest  (/api/orchestration/*)
 *   skills.*       → rest  (/api/skills/validate)
 *   browser.*      → rest  (/api/browser/to-markdown)
 *   agents.*       → rest  (/api/agents*)
 */

import * as rest from "./rest";

// Domains wired to real REST endpoints
export const tools = rest.tools;
export const sessions = rest.sessions;
export const instructions = rest.instructions;
export const projects = rest.projects;
export const personas = rest.personas;
export const stories = rest.stories;
export const prds = rest.prds;
export const docs = rest.docs;
export const explorer = rest.explorer;

// NPL: fully REST — /api/npl/{load,spec,elements,coverage}
export const npl = rest.npl;

// metrics: all methods now via rest (tool-calls/llm-calls return [] on 501)
export const metrics = {
  ...rest.metrics,
};

// chat: wired to REST endpoint (/api/chat/rooms*)
export const chat = rest.chat;
export const orchestration = rest.orchestration;

// Artifacts: wired to REST endpoint (/api/artifacts*) — PRD-002 MVP
export const artifacts = rest.artifacts;

// Skills: wired to REST endpoint (/api/skills/validate)
export const skills = rest.skills;

// Browser: wired to REST endpoint (/api/browser/to-markdown)
export const browser = rest.browser;

// Agents: wired to REST endpoint (/api/agents*)
export const agents = rest.agents;

// Health: wired to REST endpoint (/api/health*)
export const health = rest.health;

// Tasks: wired to REST endpoint (/api/tasks*)
export const tasks = rest.tasks;

// Pipes: wired to REST endpoint (/api/pipes/*)
export const pipes = rest.pipes;

// Reviews: wired to REST endpoint (/api/reviews*)
export const reviews = rest.reviews;

// Taskers: wired to REST endpoint (/api/taskers*)
export const taskers = rest.taskers;
