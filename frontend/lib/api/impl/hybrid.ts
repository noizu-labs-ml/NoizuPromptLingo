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
 *   npl.load/spec  → mock  (MCP tools only)
 *   explorer.*     → rest  (/api/project/tree, /api/project/file)
 *   metrics.recentErrors → rest  (/api/errors)
 *   metrics.recentToolCalls/LLMCalls → mock  (no backend yet)
 *   chat.*         → mock  (no backend yet)
 *   artifacts.*    → mock  (no backend yet)
 *   orchestration.*→ mock  (no backend yet)
 *   skills.*       → rest  (/api/skills/validate)
 *   browser.*      → rest  (/api/browser/to-markdown)
 *   agents.*       → rest  (/api/agents*)
 */

import * as mock from "./mock";
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

// NPL: elements + coverage from REST, load/spec stay on mock (no REST endpoint)
export const npl = {
  load: mock.npl.load.bind(mock.npl),
  spec: mock.npl.spec.bind(mock.npl),
  elements: rest.npl.elements.bind(rest.npl),
  coverage: rest.npl.coverage.bind(rest.npl),
};

// metrics: tool errors are live (real DB endpoint), others remain mock
export const metrics = {
  ...mock.metrics,
  recentErrors: rest.metrics.recentErrors.bind(rest.metrics),
};

// Domains kept on mock (no backend endpoint yet)
export const chat = mock.chat;
export const orchestration = mock.orchestration;

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
