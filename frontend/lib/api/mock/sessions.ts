import type { Session, SessionTreeNode } from "../types";
import { daysAgo, hoursAgo, makeRandom, pick, range, shortUuid } from "./helpers";

const AGENTS = [
  "npl-idea-to-spec",
  "npl-prd-editor",
  "npl-tdd-tester",
  "npl-tdd-coder",
  "npl-tdd-debugger",
  "npl-tasker-sonnet",
  "npl-tasker-opus",
  "npl-winnower",
  "Explore",
  "Plan",
  "Root",
];

const PROJECTS = ["npl-mcp", "cowardly-vance-haskell", "fluffy-wainwright"];

const TASKS = [
  "frontend-companion",
  "npl-consolidation",
  "mcp3-migration",
  "catalog-refactor",
  "docs-regen",
  "test-coverage",
  "browser-tools",
  "instruction-system",
  "pm-crud",
  "root",
  "design-review",
  "schema-audit",
];

const BRIEFS = [
  "Flesh out features needed for website companion dashboard",
  "Migrate FastMCP from 2.x to 3.x, validate discovery layer",
  "Consolidate duplicate NPL YAML source directories",
  "Add mcp_discoverable helper decorator for metadata enrichment",
  "Expose load_npl expression DSL as MCP tool",
  "Baseline test coverage before risky refactor",
  "Session: 2026-04-21T12:00:00.000Z",
  "Investigating SSE middleware crash on tool-call messages",
  "Restructure catalog ToolEntry with optional tags/title/version",
  "Verify schema compatibility of conventions vs npl directories",
];

const NOTES_POOL = [
  "See PRD-015 acceptance tests.",
  "Blocked on schema migration for npl_instruction_embeddings.",
  "Decided to keep our custom dispatcher — 3.x enabled=False can't express hidden-but-callable.",
  "Regenerated npl-full.md from conventions/; 74k chars.",
  "Pure-ASGI middleware replacement confirmed SSE-safe.",
  null,
  null,
  "ToolCall now returns status='mcp' for MCP-registered tools.",
];

function generateSessions(): Session[] {
  const rng = makeRandom(1357911);
  const out: Session[] = [];

  // Create a handful of root sessions per project
  for (const project of PROJECTS) {
    for (let i = 0; i < 3; i++) {
      const uuid = shortUuid(rng);
      const created = Math.floor(rng() * 14);
      out.push({
        uuid,
        agent: "Root",
        brief: `Session: ${daysAgo(created).slice(0, 19)}.000Z`,
        task: "root",
        project,
        parent: null,
        notes: null,
        created_at: daysAgo(created),
        updated_at: hoursAgo(Math.floor(rng() * 72)),
      });
    }
  }

  // Task sessions under each root
  const roots = [...out];
  for (const root of roots) {
    const childCount = 2 + Math.floor(rng() * 4);
    for (let i = 0; i < childCount; i++) {
      const uuid = shortUuid(rng);
      const agent = pick(rng, AGENTS);
      out.push({
        uuid,
        agent,
        brief: pick(rng, BRIEFS),
        task: pick(rng, TASKS),
        project: root.project,
        parent: root.uuid,
        notes: pick(rng, NOTES_POOL),
        created_at: daysAgo(Math.floor(rng() * 10)),
        updated_at: hoursAgo(Math.floor(rng() * 72)),
      });
    }
  }

  // A smattering of grandchildren (sub-agent sessions)
  for (let i = 0; i < 12; i++) {
    const parent = out[Math.floor(rng() * out.length)];
    if (parent.parent === null) continue; // skip roots, prefer task-under-root
    out.push({
      uuid: shortUuid(rng),
      agent: pick(rng, ["Explore", "Plan", "npl-tasker-sonnet", "npl-tasker-fast"]),
      brief: pick(rng, BRIEFS),
      task: pick(rng, TASKS),
      project: parent.project,
      parent: parent.uuid,
      notes: pick(rng, NOTES_POOL),
      created_at: daysAgo(Math.floor(rng() * 5)),
      updated_at: hoursAgo(Math.floor(rng() * 48)),
    });
  }

  return out.sort(
    (a, b) => new Date(b.updated_at).getTime() - new Date(a.updated_at).getTime(),
  );
}

export const SESSIONS: Session[] = generateSessions();

export function sessionTree(rootUuid: string): SessionTreeNode | null {
  const root = SESSIONS.find((s) => s.uuid === rootUuid);
  if (!root) return null;
  const build = (node: Session): SessionTreeNode => ({
    ...node,
    children: SESSIONS.filter((s) => s.parent === node.uuid).map(build),
  });
  return build(root);
}
