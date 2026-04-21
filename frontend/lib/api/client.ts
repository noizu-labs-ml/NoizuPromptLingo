/**
 * Stable public API facade for the NPL MCP companion.
 *
 * Pages and components **only** import from this module. Whether the
 * underlying data comes from an in-memory mock or a real fetch call is
 * an implementation detail — see ``lib/api/impl/``.
 *
 * To swap from mock to live REST, change the import of ``impl`` at the
 * bottom of this file. The public surface stays the same.
 */

import type {
  AgentDefinition,
  AgentDetail,
  AgentInfo,
  Artifact,
  ArtifactCreateInput,
  ArtifactKind,
  ArtifactListResult,
  ArtifactRevisionInput,
  ArtifactRevisionsResult,
  ArtifactWithRevision,
  ATDocument,
  CategoryInfo,
  ChatRoom,
  DocContent,
  FRDocument,
  HealthReport,
  Instruction,
  InstructionDetail,
  InstructionFilter,
  LLMCall,
  NPLCoverage,
  NPLElement,
  NPLLoadRequest,
  NPLResponse,
  NPLSpecRequest,
  Persona,
  PipelineRun,
  PRDDetail,
  PRDSummary,
  Project,
  Session,
  SessionFilter,
  SessionTreeNode,
  SkillEvaluationResult,
  SkillValidationResult,
  Story,
  StoryFilter,
  Task,
  TaskCreateInput,
  TaskFilter,
  TaskListResult,
  TaskStatus,
  ToMarkdownRequest,
  ToMarkdownResult,
  ToolCall,
  ToolError,
  FileContent,
  FileTreeNode,
  ToolEntry,
  ToolInvokeResult,
} from "./types";

// ── Implementation swap point ────────────────────────────────────────────

import * as impl from "./impl/hybrid";
// To use mock only:  import * as impl from "./impl/mock";
// To use full REST:  import * as impl from "./impl/rest";

// ── Public API surface ───────────────────────────────────────────────────

export interface ToolsAPI {
  list(): Promise<ToolEntry[]>;
  get(name: string): Promise<ToolEntry | null>;
  search(query: string, mode?: "text" | "intent"): Promise<ToolEntry[]>;
  categories(): Promise<CategoryInfo[]>;
  invoke(name: string, args: Record<string, unknown>): Promise<ToolInvokeResult>;
}

export interface NPLAPI {
  load(request: NPLLoadRequest): Promise<NPLResponse>;
  spec(request: NPLSpecRequest): Promise<NPLResponse>;
  elements(): Promise<NPLElement[]>;
  coverage(): Promise<NPLCoverage>;
}

export interface DocsAPI {
  get(name: "schema" | "arch" | "layout" | "status"): Promise<DocContent>;
}

export interface SessionsAPI {
  list(filter?: SessionFilter): Promise<Session[]>;
  get(uuid: string): Promise<Session | null>;
  tree(rootUuid: string): Promise<SessionTreeNode | null>;
  appendNote(uuid: string, note: string): Promise<Session>;
}

export interface InstructionsAPI {
  list(filter?: InstructionFilter): Promise<Instruction[]>;
  get(uuid: string): Promise<InstructionDetail | null>;
}

export interface ProjectsAPI {
  list(): Promise<Project[]>;
  get(id: string): Promise<Project | null>;
}

export interface PersonasAPI {
  listByProject(projectId: string): Promise<Persona[]>;
  get(id: string): Promise<Persona | null>;
}

export interface StoriesAPI {
  listByProject(projectId: string, filter?: StoryFilter): Promise<Story[]>;
  get(id: string): Promise<Story | null>;
  update(
    id: string,
    patch: Partial<Pick<Story, "status" | "priority" | "story_points" | "tags" | "title">>
  ): Promise<Story>;
}

export interface MetricsAPI {
  recentToolCalls(limit?: number): Promise<ToolCall[]>;
  recentLLMCalls(limit?: number): Promise<LLMCall[]>;
  recentErrors(limit?: number): Promise<ToolError[]>;
}

export interface ChatAPI {
  listRooms(): Promise<ChatRoom[]>;
  getRoom(id: string): Promise<ChatRoom | null>;
}

export interface ArtifactsAPI {
  list(kind?: ArtifactKind, limit?: number): Promise<ArtifactListResult>;
  get(id: number, revision?: number): Promise<ArtifactWithRevision | null>;
  create(input: ArtifactCreateInput): Promise<ArtifactWithRevision>;
  listRevisions(id: number): Promise<ArtifactRevisionsResult>;
  addRevision(id: number, input: ArtifactRevisionInput): Promise<ArtifactWithRevision>;
}

export interface OrchestrationAPI {
  agents(): Promise<AgentDefinition[]>;
  recentRuns(): Promise<PipelineRun[]>;
}

export interface PRDsAPI {
  list(): Promise<PRDSummary[]>;
  get(id: string): Promise<PRDDetail | null>;
  functionalRequirements(id: string): Promise<FRDocument[]>;
  acceptanceTests(id: string): Promise<ATDocument[]>;
}


export interface ProjectExplorerAPI {
  tree(path?: string, depth?: number): Promise<FileTreeNode>;
  file(path: string): Promise<FileContent>;
}

export interface SkillsAPI {
  validate(content: string, filename?: string): Promise<SkillValidationResult>;
  evaluate(content: string, filename?: string): Promise<SkillEvaluationResult>;
}

export interface BrowserAPI {
  toMarkdown(request: ToMarkdownRequest): Promise<ToMarkdownResult>;
}

export interface AgentsAPI {
  list(): Promise<AgentInfo[]>;
  get(name: string): Promise<AgentDetail | null>;
}

export interface HealthAPI {
  check(): Promise<HealthReport>;
  ping(): Promise<{ status: string; ts: string }>;
}

export interface TasksAPI {
  list(filter?: TaskFilter): Promise<TaskListResult>;
  get(id: number): Promise<Task | null>;
  create(input: TaskCreateInput): Promise<Task>;
  updateStatus(id: number, status: TaskStatus, notes?: string): Promise<Task>;
}

// ── Assembled facade ─────────────────────────────────────────────────────

export const api = {
  tools: impl.tools as ToolsAPI,
  npl: impl.npl as NPLAPI,
  sessions: impl.sessions as SessionsAPI,
  instructions: impl.instructions as InstructionsAPI,
  projects: impl.projects as ProjectsAPI,
  personas: impl.personas as PersonasAPI,
  stories: impl.stories as StoriesAPI,
  metrics: impl.metrics as MetricsAPI,
  chat: impl.chat as ChatAPI,
  artifacts: impl.artifacts as ArtifactsAPI,
  orchestration: impl.orchestration as OrchestrationAPI,
  prds: impl.prds as PRDsAPI,
  docs: impl.docs as DocsAPI,
  explorer: impl.explorer as ProjectExplorerAPI,
  skills: impl.skills as SkillsAPI,
  browser: impl.browser as BrowserAPI,
  agents: impl.agents as AgentsAPI,
  health: impl.health as HealthAPI,
  tasks: impl.tasks as TasksAPI,
};

export type API = typeof api;