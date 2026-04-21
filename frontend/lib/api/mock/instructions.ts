import type { Instruction, InstructionDetail, InstructionVersion } from "../types";
import { daysAgo, hoursAgo, makeRandom, pick, pickMany, shortUuid } from "./helpers";

const TAG_POOL = [
  "agents", "npl", "tdd", "security", "review", "docs",
  "workflow", "pipeline", "browser", "sessions", "catalog",
  "migration", "testing", "deployment", "style", "onboarding",
];

const INSTRUCTION_SEEDS: Array<{ title: string; description: string; body: string }> = [
  {
    title: "Session Initialization Protocol",
    description:
      "Mandatory steps each agent must take at the start of a conversation.",
    body:
      "# Session Initialization\n\n1. Call ToolSession.Generate with (agent, brief, task, project).\n2. Save the returned UUID as the session ID.\n3. Use the UUID for all downstream tool calls requiring a session reference.\n",
  },
  {
    title: "TDD Pipeline Guidelines",
    description:
      "Flow between npl-idea-to-spec → npl-prd-editor → npl-tdd-tester → npl-tdd-coder.",
    body:
      "# TDD Pipeline\n\nEach stage produces artifacts consumed by the next. Tester writes failing tests first; coder only writes production code to make them pass.\n",
  },
  {
    title: "NPL Convention Loading",
    description:
      "When to use NPLLoad expression DSL vs NPLSpec structured composer.",
    body:
      "# NPL Loading\n\n- Ad-hoc snippet → **NPLLoad** (\"syntax#placeholder:+2\")\n- Full spec bootstrapping → **NPLSpec**\n- Source of truth: `conventions/*.yaml`\n",
  },
  {
    title: "Artifact Review Workflow",
    description: "Creating reviews and resolving inline comments.",
    body:
      "# Reviews\n\n1. Open a review on an artifact revision.\n2. Add inline comments.\n3. Mark resolved once addressed.\n",
  },
  {
    title: "Browser Automation Best Practices",
    description: "Playwright usage patterns for ToMarkdown and Screenshot.",
    body:
      "# Browser Tools\n\n- Use `ToMarkdown` for content extraction.\n- Add `with_image_descriptions=true` when pages include illustrative imagery.\n- Chain `Screenshot` for visual diffing.\n",
  },
  {
    title: "Security Review Checklist",
    description: "Common vulnerabilities to look for in generated code.",
    body:
      "# Security Review\n\n- [ ] No unsanitized string interpolation in SQL\n- [ ] No shell injection in subprocess calls\n- [ ] Secrets referenced via ${secret.NAME}, never inlined\n- [ ] Input validation at boundaries only\n",
  },
  {
    title: "Documentation Style Guide",
    description:
      "House style for PRDs, user stories, and arch docs.",
    body:
      "# Docs Style\n\n- Summary under 300 lines; extract overflow into sibling files.\n- Use mermaid for diagrams.\n- Cross-link with relative paths.\n",
  },
  {
    title: "PRD Template",
    description: "Required sections for every PRD in project-management/PRDs/.",
    body:
      "# PRD Template\n\n## Overview\n## Functional Requirements\n## Acceptance Tests\n## Non-Goals\n## Risks\n",
  },
  {
    title: "Onboarding — First Week",
    description: "Reading list and exercises for a new contributor.",
    body:
      "# Onboarding\n\nWeek 1:\n- Read CLAUDE.md, PROJ-ARCH.md, PROJ-LAYOUT.md\n- Run `uv run npl-mcp` locally\n- Pick up a good-first-issue labeled story\n",
  },
  {
    title: "Deployment Runbook",
    description: "Restart procedure for the server + frontend.",
    body:
      "# Deployment\n\n1. `uv sync`\n2. `uv run npl-docs-regen`\n3. `npm run build` in frontend/\n4. Restart `uv run npl-mcp`\n",
  },
];

function mkVersions(rng: () => number, body: string, count: number): InstructionVersion[] {
  const versions: InstructionVersion[] = [];
  for (let v = 1; v <= count; v++) {
    versions.push({
      version: v,
      body: v === count ? body : `${body}\n\n<!-- earlier revision ${v} -->`,
      change_note:
        v === 1
          ? "Initial version."
          : pick(rng, [
              "Clarified section on edge cases.",
              "Corrected command flags.",
              "Added troubleshooting block.",
              "Updated link targets.",
              "Expanded example.",
            ]),
      created_at: daysAgo(Math.floor(rng() * 30) + (count - v) * 5),
    });
  }
  return versions;
}

function generate(): InstructionDetail[] {
  const rng = makeRandom(2468101);
  return INSTRUCTION_SEEDS.map((seed) => {
    const versionCount = 1 + Math.floor(rng() * 4);
    const versions = mkVersions(rng, seed.body, versionCount);
    return {
      uuid: shortUuid(rng),
      title: seed.title,
      description: seed.description,
      tags: pickMany(rng, TAG_POOL, 2 + Math.floor(rng() * 3)),
      active_version: versionCount,
      session_id: null,
      created_at: versions[0].created_at,
      updated_at: versions[versionCount - 1].created_at,
      versions,
    };
  });
}

export const INSTRUCTIONS: InstructionDetail[] = generate();

export function instructionSummary(d: InstructionDetail): Instruction {
  const { versions, ...rest } = d;
  void versions;
  return rest;
}
