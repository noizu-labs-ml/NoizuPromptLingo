import type { Persona, Project, Story, StoryPriority, StoryStatus } from "../types";
import { daysAgo, hoursAgo, makeRandom, pick, pickMany, shortUuid } from "./helpers";

const PROJECT_SEEDS = [
  {
    name: "npl-mcp",
    title: "NPL MCP Server",
    description:
      "The authoritative MCP server exposing NPL conventions, session tracking, and PM tools.",
  },
  {
    name: "cowardly-vance-haskell",
    title: "Cowardly Vance (Haskell port)",
    description:
      "Experimental port of the catalog pattern to a Haskell MCP implementation.",
  },
  {
    name: "fluffy-wainwright",
    title: "Fluffy Wainwright",
    description: "Internal prototype for NPL-driven agent orchestration.",
  },
];

const PERSONA_SEEDS = [
  {
    name: "Dave the Developer",
    role: "Senior Software Engineer",
    description:
      "Experienced backend engineer looking for rigorous code review and precise architectural guidance.",
    goals: ["Ship safe, testable code", "Minimize rework", "Automate repetitive review steps"],
    pain_points: ["Flaky tests", "Underspecified requirements", "Silent errors"],
    behaviors: ["Prefers TDD", "Reads PRDs carefully before coding"],
  },
  {
    name: "The Vibe Coder",
    role: "Rapid-prototype Developer",
    description: "Moves fast, wants minimum ceremony, values iteration speed.",
    goals: ["Prototype to working demo in a day", "Avoid yak-shaving"],
    pain_points: ["Over-engineering", "Heavy process", "Slow feedback loops"],
    behaviors: ["Types quickly", "Skips reading long PRDs"],
  },
  {
    name: "Product Manager",
    role: "Non-technical Product Lead",
    description:
      "Tracks requirement coverage, stakeholder updates, and delivery confidence.",
    goals: ["Understand status without reading code", "Trace features to stories"],
    pain_points: ["Jargon-heavy updates", "Unclear test coverage"],
    behaviors: ["Reviews weekly", "Asks about risks before scope"],
  },
  {
    name: "AI Agent",
    role: "Autonomous Programmatic User",
    description: "An LLM-powered agent invoking MCP tools in a pipeline.",
    goals: ["Complete assigned task", "Emit structured reasoning"],
    pain_points: ["Tool spam in tools/list", "Ambiguous parameter shapes"],
    behaviors: ["Calls ToolSearch before acting", "Leaves notes on session"],
  },
  {
    name: "Project Manager",
    role: "Sprint Coordinator",
    description: "Balances story load across agents and tracks cross-cutting work.",
    goals: ["Keep the pipeline flowing", "Catch blocked tasks early"],
    pain_points: ["Stale status metadata", "Unlinked stories"],
    behaviors: ["Runs daily sync", "Tags stories with priorities"],
  },
];

const STORY_SEEDS = [
  { title: "As a developer, I can browse the full tool catalog", points: 3 },
  { title: "As an agent, I can fetch NPL conventions by expression", points: 5 },
  { title: "As a PM, I can see story status grouped by persona", points: 2 },
  { title: "As a dev, I can run the TDD pipeline on a user story", points: 8 },
  { title: "As an agent, I can append notes to an existing session", points: 1 },
  { title: "As a dev, I can see tool-call history by session", points: 5 },
  { title: "As a user, I can view instruction version history", points: 3 },
  { title: "As a reviewer, I can leave inline comments on an artifact", points: 5 },
  { title: "As a PM, I can filter stories by priority and status", points: 2 },
  { title: "As an agent, I can invoke any catalog tool via ToolCall", points: 3 },
  { title: "As a user, I can search the catalog by intent", points: 5 },
  { title: "As a dev, I can regenerate npl-full.md from conventions/", points: 2 },
  { title: "As an agent, I can retrieve a session tree", points: 3 },
  { title: "As a user, I can see the project's persona gallery", points: 2 },
  { title: "As a dev, I can see which MCP tools are MCP-registered vs hidden", points: 1 },
];

function generate(): {
  projects: Project[];
  personas: Persona[];
  stories: Story[];
} {
  const rng = makeRandom(97531);
  const projects: Project[] = [];
  const personas: Persona[] = [];
  const stories: Story[] = [];

  PROJECT_SEEDS.forEach((seed, idx) => {
    const id = `proj-${shortUuid(rng, 6)}`;
    const personaIds: string[] = [];
    const localPersonas = pickMany(rng, PERSONA_SEEDS, 3 + Math.floor(rng() * 2));
    localPersonas.forEach((ps) => {
      const pid = `pers-${shortUuid(rng, 6)}`;
      personaIds.push(pid);
      personas.push({
        id: pid,
        project_id: id,
        name: ps.name,
        role: ps.role,
        description: ps.description,
        goals: ps.goals,
        pain_points: ps.pain_points,
        behaviors: ps.behaviors,
        demographics: {
          experience_years: 3 + Math.floor(rng() * 15),
          primary_language: pick(rng, ["Python", "TypeScript", "Go", "Rust", "Haskell"]),
          team_size: 2 + Math.floor(rng() * 8),
        },
        image: null,
        created_at: daysAgo(30 + idx * 10),
      });
    });

    const storyCount = 4 + Math.floor(rng() * 6);
    const localStories = pickMany(rng, STORY_SEEDS, storyCount);
    const STATUS: StoryStatus[] = ["draft", "ready", "in_progress", "done", "archived"];
    const PRIORITY: StoryPriority[] = ["low", "medium", "high", "critical"];
    localStories.forEach((ss) => {
      const sid = `story-${shortUuid(rng, 6)}`;
      const status = pick(rng, STATUS);
      const priority = pick(rng, PRIORITY);
      stories.push({
        id: sid,
        project_id: id,
        title: ss.title,
        story_text: ss.title.replace(/^As an? [^,]+, /, ""),
        description: `Acceptance-worthy narrative for ${ss.title.toLowerCase()}.`,
        priority,
        status,
        story_points: ss.points,
        acceptance_criteria: [
          "Happy path exercised end-to-end",
          "Edge cases documented",
          "Coverage ≥ 80% on new code",
        ],
        tags: pickMany(rng, ["catalog", "npl", "ui", "backend", "ops"], 1 + Math.floor(rng() * 2)),
        persona_ids: pickMany(rng, personaIds, 1 + Math.floor(rng() * 2)),
        created_at: daysAgo(Math.floor(rng() * 20)),
        updated_at: hoursAgo(Math.floor(rng() * 200)),
      });
    });

    projects.push({
      id,
      name: seed.name,
      title: seed.title,
      description: seed.description,
      persona_count: localPersonas.length,
      story_count: storyCount,
      created_at: daysAgo(30 + idx * 10),
    });
  });

  return { projects, personas, stories };
}

const generated = generate();

export const PROJECTS: Project[] = generated.projects;
export const PERSONAS: Persona[] = generated.personas;
export const STORIES: Story[] = generated.stories;
