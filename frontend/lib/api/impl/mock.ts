/**
 * Mock implementation of the API facade.
 *
 * Each exported namespace matches an interface in ``lib/api/client.ts``.
 * All functions are async so switching to a real fetch-based impl is a
 * drop-in swap.
 */

import catalogSnapshot from "../mock/catalog.json" with { type: "json" };
import {
  ARTIFACTS,
  AGENTS,
  CHAT_ROOMS,
  PIPELINE_RUNS,
} from "../mock/collab";
import { INSTRUCTIONS, instructionSummary } from "../mock/instructions";
import { LLM_CALLS, TOOL_CALLS, TOOL_ERRORS } from "../mock/metrics";
import { PERSONAS, PROJECTS, STORIES } from "../mock/projects";
import { SESSIONS, sessionTree } from "../mock/sessions";
import { PRD_SUMMARIES, PRD_DETAILS, MOCK_FRS, MOCK_ATS } from "../mock/prds";

import type {
  AgentDetail,
  AgentInfo,
  ATDocument,
  CategoryInfo,
  FileContent,
  FileTreeNode,
  DocContent,
  FRDocument,
  HealthReport,
  Instruction,
  InstructionDetail,
  InstructionFilter,
  NPLCoverage,
  NPLElement,
  NPLLoadRequest,
  NPLResponse,
  NPLSpecRequest,
  Persona,
  PRDDetail,
  PRDSummary,
  Project,
  Session,
  SessionFilter,
  SessionTreeNode,
  SkillValidationResult,
  Story,
  StoryFilter,
  ToMarkdownRequest,
  ToMarkdownResult,
  ToolEntry,
  ToolInvokeResult,
} from "../types";

// ── Tools ────────────────────────────────────────────────────────────────

const ALL_TOOLS = (catalogSnapshot as {
  catalog: ToolEntry[];
  categories: CategoryInfo[];
}).catalog;

const ALL_CATEGORIES = (catalogSnapshot as {
  catalog: ToolEntry[];
  categories: CategoryInfo[];
}).categories;

async function delay<T>(value: T, ms = 50): Promise<T> {
  await new Promise((r) => setTimeout(r, ms));
  return value;
}

export const tools = {
  async list(): Promise<ToolEntry[]> {
    return delay(ALL_TOOLS);
  },
  async get(name: string): Promise<ToolEntry | null> {
    return delay(ALL_TOOLS.find((t) => t.name === name) ?? null);
  },
  async search(query: string, mode: "text" | "intent" = "text"): Promise<ToolEntry[]> {
    const q = query.trim().toLowerCase();
    if (!q) return delay([]);
    const results = ALL_TOOLS.filter(
      (t) =>
        t.name.toLowerCase().includes(q) ||
        t.description.toLowerCase().includes(q) ||
        (t.tags ?? []).some((tag) => tag.toLowerCase().includes(q)),
    );
    // Mode is advisory for the mock; in real impl it selects the backend path.
    void mode;
    return delay(results.slice(0, 25));
  },
  async categories(): Promise<CategoryInfo[]> {
    return delay(ALL_CATEGORIES);
  },
  async invoke(name: string, args: Record<string, unknown>): Promise<ToolInvokeResult> {
    const tool = ALL_TOOLS.find((t) => t.name === name);
    if (!tool) {
      return delay({
        tool: name,
        status: "error",
        message: `Tool '${name}' not found in mock catalog.`,
        duration_ms: 1,
      });
    }
    return delay(
      {
        tool: name,
        status: "ok",
        result: {
          mock: true,
          args,
          note: "The real server would dispatch this call and return the tool's output.",
        },
        duration_ms: 80 + Math.floor(Math.random() * 400),
      },
      120,
    );
  },
};

// ── NPL ──────────────────────────────────────────────────────────────────

export const npl = {
  async load(request: NPLLoadRequest): Promise<NPLResponse> {
    const skipLine =
      request.skip && request.skip.length > 0
        ? `> Skip: \`${request.skip.join(", ")}\`  \n`
        : "";
    const body = [
      `# NPL Load — mock response`,
      ``,
      `> Expression: \`${request.expression}\`  `,
      `> Layout: \`${request.layout ?? "yaml_order"}\``,
      skipLine ? skipLine.trimEnd() : "",
      ``,
      `---`,
      ``,
      `### qualifier`,
      ``,
      `Annotations that narrow or widen the scope of a statement.`,
      ``,
      `**Syntax:**`,
      ``,
      `- \`{qualifier:text}\``,
      ``,
      `**Examples:**`,
      ``,
      `- **basic**: \`{maybe: the user is asking for help}\``,
      `- **scoped**: \`{in-context: only in the current session}\``,
    ].join("\n");
    return delay({ markdown: body, char_count: body.length });
  },
  async spec(request: NPLSpecRequest): Promise<NPLResponse> {
    const intro = request.extension
      ? "⌜extend:NPL@1.0⌝"
      : "⌜NPL@1.0⌝";
    const footer = request.extension
      ? "⌞extend:NPL@1.0⌟"
      : "⌞NPL@1.0⌟";
    const body = [
      intro,
      "",
      "# Noizu Prompt Lingua (NPL)",
      "Mock NPLSpec output — matches the shape of the real NPLDefinition.format() response.",
      "",
      "## Core Concepts",
      "",
      "**npl-declaration** — Framework version and rule boundaries.",
      "**agent** — Simulated entity with defined behaviors.",
      "",
      `Components requested: ${(request.components ?? []).length || "all"}.  `,
      `Concise: ${request.concise ?? true}. XML: ${request.xml ?? false}.`,
      "",
      footer,
    ].join("\n");
    return delay({ markdown: body, char_count: body.length });
  },
  async elements(): Promise<NPLElement[]> {
    return delay(MOCK_NPL_ELEMENTS);
  },
  async coverage(): Promise<NPLCoverage> {
    return delay(MOCK_NPL_COVERAGE);
  },
};

// ── Sessions ─────────────────────────────────────────────────────────────

export const sessions = {
  async list(filter?: SessionFilter): Promise<Session[]> {
    let list = SESSIONS;
    if (filter?.project) list = list.filter((s) => s.project === filter.project);
    if (filter?.agent) list = list.filter((s) => s.agent === filter.agent);
    if (filter?.search) {
      const q = filter.search.toLowerCase();
      list = list.filter(
        (s) =>
          s.brief.toLowerCase().includes(q) ||
          (s.notes ?? "").toLowerCase().includes(q) ||
          s.task.toLowerCase().includes(q),
      );
    }
    if (filter?.limit) list = list.slice(0, filter.limit);
    return delay(list);
  },
  async get(uuid: string): Promise<Session | null> {
    return delay(SESSIONS.find((s) => s.uuid === uuid) ?? null);
  },
  async tree(rootUuid: string): Promise<SessionTreeNode | null> {
    return delay(sessionTree(rootUuid));
  },
  async appendNote(uuid: string, note: string): Promise<Session> {
    const session = SESSIONS.find((s) => s.uuid === uuid);
    if (!session) throw new Error(`Session ${uuid} not found`);
    const trimmed = note.trim();
    if (!trimmed) throw new Error("note must be a non-empty string");
    const existing = session.notes ?? "";
    if (!existing.includes(trimmed)) {
      session.notes = existing ? `${existing}\n${trimmed}` : trimmed;
      session.updated_at = new Date().toISOString();
    }
    return delay({ ...session });
  },
};

// ── Instructions ─────────────────────────────────────────────────────────

export const instructions = {
  async list(filter?: InstructionFilter): Promise<Instruction[]> {
    let list: Instruction[] = INSTRUCTIONS.map(instructionSummary);
    if (filter?.query) {
      const q = filter.query.toLowerCase();
      list = list.filter(
        (i) =>
          i.title.toLowerCase().includes(q) ||
          i.description.toLowerCase().includes(q) ||
          i.tags.some((t) => t.toLowerCase().includes(q)),
      );
    }
    if (filter?.tags && filter.tags.length > 0) {
      list = list.filter((i) => filter.tags!.every((t) => i.tags.includes(t)));
    }
    if (filter?.limit) list = list.slice(0, filter.limit);
    return delay(list);
  },
  async get(uuid: string): Promise<InstructionDetail | null> {
    return delay(INSTRUCTIONS.find((i) => i.uuid === uuid) ?? null);
  },
};

// ── Projects / Personas / Stories ────────────────────────────────────────

export const projects = {
  async list(): Promise<Project[]> {
    return delay(PROJECTS);
  },
  async get(id: string): Promise<Project | null> {
    return delay(PROJECTS.find((p) => p.id === id) ?? null);
  },
};

export const personas = {
  async listByProject(projectId: string): Promise<Persona[]> {
    return delay(PERSONAS.filter((p) => p.project_id === projectId));
  },
  async get(id: string): Promise<Persona | null> {
    return delay(PERSONAS.find((p) => p.id === id) ?? null);
  },
};

export const stories = {
  async listByProject(projectId: string, filter?: StoryFilter): Promise<Story[]> {
    let list = STORIES.filter((s) => s.project_id === projectId);
    if (filter?.status) list = list.filter((s) => s.status === filter.status);
    if (filter?.priority) list = list.filter((s) => s.priority === filter.priority);
    if (filter?.persona_id)
      list = list.filter((s) => s.persona_ids.includes(filter.persona_id!));
    return delay(list);
  },
  async get(id: string): Promise<Story | null> {
    return delay(STORIES.find((s) => s.id === id) ?? null);
  },
  async update(
    id: string,
    patchData: Partial<Pick<Story, "status" | "priority" | "story_points" | "tags" | "title">>
  ): Promise<Story> {
    const idx = STORIES.findIndex((s) => s.id === id);
    if (idx === -1) throw new Error(`Story '${id}' not found`);
    const updated: Story = { ...STORIES[idx], ...patchData };
    STORIES[idx] = updated;
    return delay(updated);
  },
};

// ── Metrics ──────────────────────────────────────────────────────────────

export const metrics = {
  async recentToolCalls(limit = 30) {
    return delay(TOOL_CALLS.slice(0, limit));
  },
  async recentLLMCalls(limit = 20) {
    return delay(LLM_CALLS.slice(0, limit));
  },
  async recentErrors(limit = 50) {
    return delay(TOOL_ERRORS.slice(0, limit));
  },
};

// ── Chat / Artifacts / Orchestration (Tier 3 stub) ───────────────────────

export const chat = {
  async listRooms() {
    return delay(CHAT_ROOMS);
  },
  async getRoom(id: string) {
    return delay(CHAT_ROOMS.find((r) => r.id === Number(id)) ?? null);
  },
};

export const artifacts = {
  async list(kind?: string, limit?: number) {
    let list = [...ARTIFACTS];
    if (kind) list = list.filter((a) => a.kind === kind);
    if (limit != null) list = list.slice(0, limit);
    return delay({ artifacts: list, count: list.length });
  },
  async get(id: number, revision?: number) {
    const artifact = ARTIFACTS.find((a) => a.id === id);
    if (!artifact) return delay(null);
    const rev = revision ?? artifact.latest_revision;
    return delay({
      ...artifact,
      revision: {
        id: 1000 + artifact.id * 10 + rev,
        artifact_id: artifact.id,
        revision: rev,
        content: `# ${artifact.title}\n\nMock body at revision ${rev}. Connect backend for real content.`,
        notes: null,
        created_by: artifact.created_by,
        created_at: artifact.updated_at,
      },
    });
  },
  async create(input: { title: string; content: string; kind?: string; description?: string; created_by?: string | null; notes?: string | null }) {
    const nextId = Math.max(0, ...ARTIFACTS.map((a) => a.id)) + 1;
    const now = new Date().toISOString();
    const artifact: (typeof ARTIFACTS)[0] = {
      id: nextId,
      title: input.title,
      kind: (input.kind ?? "markdown") as (typeof ARTIFACTS)[0]["kind"],
      description: input.description ?? "",
      created_by: input.created_by ?? null,
      latest_revision: 1,
      created_at: now,
      updated_at: now,
    };
    ARTIFACTS.unshift(artifact);
    return delay({
      ...artifact,
      revision: {
        id: 1000 + nextId * 10 + 1,
        artifact_id: nextId,
        revision: 1,
        content: input.content,
        notes: input.notes ?? null,
        created_by: input.created_by ?? null,
        created_at: now,
      },
    });
  },
  async listRevisions(id: number) {
    const artifact = ARTIFACTS.find((a) => a.id === id);
    if (!artifact) throw new Error(`Artifact ${id} not found`);
    const revisions = Array.from({ length: artifact.latest_revision }, (_, i) => ({
      id: 1000 + artifact.id * 10 + (i + 1),
      artifact_id: artifact.id,
      revision: i + 1,
      notes: i === 0 ? null : `Revision ${i + 1}`,
      created_by: artifact.created_by,
      created_at: artifact.updated_at,
    }));
    return delay({ artifact_id: id, revisions, count: revisions.length });
  },
  async addRevision(id: number, input: { content: string; notes?: string | null; created_by?: string | null }) {
    const artifact = ARTIFACTS.find((a) => a.id === id);
    if (!artifact) throw new Error(`Artifact ${id} not found`);
    artifact.latest_revision += 1;
    artifact.updated_at = new Date().toISOString();
    return delay({
      ...artifact,
      revision: {
        id: 1000 + artifact.id * 10 + artifact.latest_revision,
        artifact_id: artifact.id,
        revision: artifact.latest_revision,
        content: input.content,
        notes: input.notes ?? null,
        created_by: input.created_by ?? null,
        created_at: artifact.updated_at,
      },
    });
  },
};

export const orchestration = {
  async agents() {
    return delay(AGENTS);
  },
  async recentRuns() {
    return delay(PIPELINE_RUNS);
  },
};

// ── PRDs ─────────────────────────────────────────────────────────────────

export const prds = {
  async list(): Promise<PRDSummary[]> {
    return delay(PRD_SUMMARIES);
  },
  async get(id: string): Promise<PRDDetail | null> {
    return delay(PRD_DETAILS.find((p) => p.id === id) ?? null);
  },
  async functionalRequirements(id: string): Promise<FRDocument[]> {
    const prd = PRD_DETAILS.find((p) => p.id === id);
    if (!prd || !prd.has_frs) return delay([]);
    return delay(MOCK_FRS);
  },
  async acceptanceTests(id: string): Promise<ATDocument[]> {
    const prd = PRD_DETAILS.find((p) => p.id === id);
    if (!prd || !prd.has_ats) return delay([]);
    return delay(MOCK_ATS);
  },
};

// ── NPL Elements mock data ────────────────────────────────────────────────

const MOCK_NPL_ELEMENTS: NPLElement[] = [
  { section: "syntax", name: "placeholder", slug: "placeholder", friendly_name: "Placeholder", brief: "Substitution token for dynamic values.", priority: 0, tags: ["core", "required"] },
  { section: "syntax", name: "in-fill", slug: "in-fill", friendly_name: "In-Fill", brief: "LLM-generated content with optional constraints.", priority: 1, tags: ["core"] },
  { section: "syntax", name: "attention", slug: "attention", friendly_name: "Attention Marker", brief: "Directive emoji to focus model attention.", priority: 2, tags: ["formatting"] },
  { section: "syntax", name: "qualifier", slug: "qualifier", friendly_name: "Qualifier", brief: "Annotations that narrow or widen statement scope.", priority: 3, tags: ["modifier"] },
  { section: "syntax", name: "size-indicator", slug: "size-indicator", friendly_name: "Size Indicator", brief: "Constraints on output length.", priority: 4, tags: ["modifier"] },
  { section: "directives", name: "agent", slug: "agent", friendly_name: "Agent", brief: "Define a simulated entity with specific behaviors.", priority: 0, tags: ["core"] },
  { section: "directives", name: "npl-declaration", slug: "npl-declaration", friendly_name: "NPL Declaration", brief: "Framework version and rule boundary markers.", priority: 1, tags: ["core", "required"] },
  { section: "directives", name: "persona", slug: "persona", friendly_name: "Persona", brief: "Identity and behavioral profile for an agent.", priority: 2, tags: ["agent"] },
  { section: "pumps", name: "chain-of-thought", slug: "chain-of-thought", friendly_name: "Chain of Thought", brief: "Step-by-step reasoning before answering.", priority: 0, tags: ["reasoning"] },
  { section: "pumps", name: "reflection", slug: "reflection", friendly_name: "Reflection", brief: "Self-review pass after initial output.", priority: 1, tags: ["reasoning", "quality"] },
  { section: "pumps", name: "tree-of-thought", slug: "tree-of-thought", friendly_name: "Tree of Thought", brief: "Explore multiple reasoning branches in parallel.", priority: 2, tags: ["reasoning", "advanced"] },
  { section: "prefix", name: "note", slug: "note", friendly_name: "Note", brief: "Informational aside outside the main output.", priority: 0, tags: ["formatting"] },
  { section: "prefix", name: "aside", slug: "aside", friendly_name: "Aside", brief: "Secondary content not part of the primary answer.", priority: 1, tags: ["formatting"] },
  { section: "declarations", name: "var", slug: "var", friendly_name: "Variable Declaration", brief: "Declare a reusable named value.", priority: 0, tags: ["core"] },
  { section: "declarations", name: "fn", slug: "fn", friendly_name: "Function Declaration", brief: "Define a reusable transformation or prompt fragment.", priority: 1, tags: ["advanced"] },
];

// ── NPL Coverage mock data ────────────────────────────────────────────────

const MOCK_NPL_COVERAGE: NPLCoverage = {
  total_sections: 7,
  total_components: 55,
  complete_components: 47,
  coverage_percent: 85,
  by_section: [
    { section: "syntax", total: 11, complete: 11, coverage_percent: 100, missing: [] },
    { section: "declarations", total: 6, complete: 6, coverage_percent: 100, missing: [] },
    { section: "pumps", total: 13, complete: 10, coverage_percent: 77, missing: ["mood", "mind-reader", "runtime-flags"] },
    { section: "directives", total: 8, complete: 7, coverage_percent: 88, missing: ["foreach"] },
    { section: "prefixes", total: 9, complete: 7, coverage_percent: 78, missing: ["translate", "ner"] },
    { section: "prompt-sections", total: 5, complete: 4, coverage_percent: 80, missing: ["logic-block"] },
    { section: "special-sections", total: 3, complete: 2, coverage_percent: 67, missing: ["secure-block"] },
  ],
};

// ── Docs ─────────────────────────────────────────────────────────────────

export const docs = {
  async get(name: "schema" | "arch" | "layout" | "status"): Promise<DocContent> {
    const titles: Record<string, string> = {
      schema: "Database Schema Documentation",
      arch: "Architecture Documentation",
      layout: "Project Layout Documentation",
      status: "Project Status",
    };
    const content = `# ${titles[name] ?? name}\n\n_Mock content — connect to backend for real docs._\n`;
    return delay({ path: `docs/PROJ-${name.toUpperCase()}.md`, content, size: content.length });
  },
};

// ── Project Explorer (US-025) ────────────────────────────────────────────

const _MOCK_TREE: FileTreeNode = {
  name: "NoizuPromptLingo",
  path: "",
  kind: "directory",
  children: [
    {
      name: "src",
      path: "src",
      kind: "directory",
      children: [
        { name: "npl_mcp", path: "src/npl_mcp", kind: "directory", children: [] },
      ],
    },
    {
      name: "frontend",
      path: "frontend",
      kind: "directory",
      children: [
        { name: "app", path: "frontend/app", kind: "directory", children: [] },
        { name: "components", path: "frontend/components", kind: "directory", children: [] },
      ],
    },
    { name: "pyproject.toml", path: "pyproject.toml", kind: "file", size: 2048 },
    { name: "README.md", path: "README.md", kind: "file", size: 4096 },
  ],
};

export const explorer = {
  async tree(_path = ".", _depth = 3): Promise<FileTreeNode> {
    return delay(_MOCK_TREE);
  },
  async file(path: string): Promise<FileContent> {
    return delay({
      path,
      content: `# Mock content for ${path}\n\nThis is placeholder content from the mock API.`,
      size: 64,
      truncated: false,
    });
  },
};

// ── Browser (US-096) ─────────────────────────────────────────────────────

export const browser = {
  async toMarkdown(request: ToMarkdownRequest): Promise<ToMarkdownResult> {
    void request;
    const markdown = `# Mock Markdown\n\nThis is a mock conversion of **${request.source}**.\n\nConnect to backend for real content.`;
    return delay({ markdown, source: request.source, char_count: markdown.length });
  },
};

// ── Skills (US-119) ─────────────────────────────────────────────────────

export const skills = {
  async validate(content: string, filename?: string): Promise<SkillValidationResult> {
    // Basic mock validation: check for frontmatter markers
    const hasFrontmatter = content.trimStart().startsWith("---");
    void filename;
    if (!hasFrontmatter) {
      return delay({
        valid: false,
        errors: [
          {
            severity: "error" as const,
            field: "frontmatter",
            message: "No YAML frontmatter found. File must start with --- markers.",
          },
        ],
        warnings: [],
        summary: { yaml_parseable: false, has_frontmatter: false, has_body: true },
      });
    }
    return delay({
      valid: true,
      errors: [],
      warnings: [],
      summary: {
        yaml_parseable: true,
        has_frontmatter: true,
        has_body: true,
        heading_count: 1,
        body_char_count: content.length,
        frontmatter_fields: ["name", "description"],
      },
    });
  },
};

// ── Agents (US-221) ──────────────────────────────────────────────────────

const _MOCK_AGENTS: AgentInfo[] = [
  {
    name: "npl-idea-to-spec",
    display_name: "npl-idea-to-spec",
    description: "Transforms natural language feature ideas into personas and user stories.",
    model: "opus",
    allowed_tools: [],
    kind: "pipeline",
    path: "agents/npl-idea-to-spec.md",
    body_length: 4200,
  },
  {
    name: "npl-tdd-coder",
    display_name: "npl-tdd-coder",
    description: "Implements source code to satisfy failing tests in the TDD cycle.",
    model: "sonnet",
    allowed_tools: [],
    kind: "pipeline",
    path: "agents/npl-tdd-coder.md",
    body_length: 3800,
  },
  {
    name: "npl-tasker-fast",
    display_name: "npl-tasker-fast",
    description: "Fast tasker agent for quick utility tasks.",
    model: "haiku",
    allowed_tools: [],
    kind: "executor",
    path: "agents/npl-tasker-fast.md",
    body_length: 2100,
  },
  {
    name: "npl-winnower",
    display_name: "npl-winnower",
    description: "Winnows and filters content for downstream processing.",
    model: null,
    allowed_tools: [],
    kind: "utility",
    path: "agents/npl-winnower.md",
    body_length: 1800,
  },
];

export const agents = {
  async list(): Promise<AgentInfo[]> {
    return delay(_MOCK_AGENTS);
  },
  async get(name: string): Promise<AgentDetail | null> {
    const found = _MOCK_AGENTS.find((a) => a.name === name);
    if (!found) return delay(null);
    return delay({
      ...found,
      body: `# ${found.display_name}\n\nMock body — connect to backend for real content.\n`,
    });
  },
};

// ── Tasks (PRD-005) ──────────────────────────────────────────────────────

import type {
  Task,
  TaskCreateInput,
  TaskFilter,
  TaskListResult,
  TaskStatus,
} from "../types";

const _MOCK_TASKS: Task[] = [
  {
    id: 1,
    title: "Ship tier-C tasks MVP",
    description: "Flat npl_tasks table with CRUD + list.",
    status: "in_progress",
    priority: 2,
    assigned_to: "npl-tdd-coder",
    notes: "Wired MCP + REST + frontend.",
    created_at: "2026-04-21T10:00:00Z",
    updated_at: "2026-04-21T12:00:00Z",
  },
  {
    id: 2,
    title: "Write commit-grouping plan",
    description: "Group 9+ waves into logical commits.",
    status: "pending",
    priority: 1,
    assigned_to: null,
    notes: null,
    created_at: "2026-04-21T09:00:00Z",
    updated_at: "2026-04-21T09:00:00Z",
  },
  {
    id: 3,
    title: "Regenerate RESUME.md",
    description: "Capture state after waves 1-6.",
    status: "pending",
    priority: 1,
    assigned_to: null,
    notes: null,
    created_at: "2026-04-21T08:00:00Z",
    updated_at: "2026-04-21T08:00:00Z",
  },
];
let _nextTaskId = _MOCK_TASKS.length + 1;

export const tasks = {
  async list(filter?: TaskFilter): Promise<TaskListResult> {
    let list = [..._MOCK_TASKS];
    if (filter?.status) list = list.filter((t) => t.status === filter.status);
    if (filter?.assigned_to) list = list.filter((t) => t.assigned_to === filter.assigned_to);
    if (filter?.limit != null) list = list.slice(0, filter.limit);
    return delay({ tasks: list, count: list.length });
  },
  async get(id: number): Promise<Task | null> {
    return delay(_MOCK_TASKS.find((t) => t.id === id) ?? null);
  },
  async create(input: TaskCreateInput): Promise<Task> {
    const now = new Date().toISOString();
    const task: Task = {
      id: _nextTaskId++,
      title: input.title,
      description: input.description ?? "",
      status: input.status ?? "pending",
      priority: input.priority ?? 1,
      assigned_to: input.assigned_to ?? null,
      notes: input.notes ?? null,
      created_at: now,
      updated_at: now,
    };
    _MOCK_TASKS.unshift(task);
    return delay({ ...task });
  },
  async updateStatus(id: number, status: TaskStatus, notes?: string): Promise<Task> {
    const task = _MOCK_TASKS.find((t) => t.id === id);
    if (!task) throw new Error(`Task ${id} not found`);
    task.status = status;
    if (notes) {
      const existing = task.notes ?? "";
      if (!existing.includes(notes)) {
        task.notes = existing ? `${existing}\n${notes}` : notes;
      }
    }
    task.updated_at = new Date().toISOString();
    return delay({ ...task });
  },
};

// ── Health ───────────────────────────────────────────────────────────────

export const health = {
  async check(): Promise<HealthReport> {
    return delay({
      server: { status: "ok", uptime_seconds: 120, fastmcp_version: "3.x.x" },
      database: { status: "ok", latency_ms: 2.1 },
      litellm: { status: "not_configured" },
      catalog: {
        status: "ok",
        tool_count: 126,
        mcp_tools: 14,
        hidden_tools: 27,
        stub_tools: 87,
      },
      frontend_build: { status: "ok", dist_path: "/mock/dist" },
    } as HealthReport);
  },
  async ping(): Promise<{ status: string; ts: string }> {
    return delay({ status: "ok", ts: new Date().toISOString() });
  },
};
