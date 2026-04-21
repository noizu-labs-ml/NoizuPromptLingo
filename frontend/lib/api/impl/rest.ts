// Not yet active. Swap in ../client.ts when backend REST endpoints ship.

/**
 * REST implementation of the API facade.
 *
 * Each exported namespace matches the same interface as impl/mock.ts.
 * Wired to planned REST endpoints — not yet implemented on the backend.
 * To activate: replace the mock import in lib/api/client.ts with this module.
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
  ArtifactRevisionUploadInput,
  ArtifactUploadInput,
  ArtifactRevisionsResult,
  ArtifactWithRevision,
  ATDocument,
  CategoryInfo,
  ChatMessage,
  ChatMessageCreateInput,
  ChatMessageListResult,
  ChatRoom,
  ChatRoomCreateInput,
  ChatRoomListResult,
  DocContent,
  FileContent,
  FileTreeNode,
  FRDocument,
  HealthReport,
  Instruction,
  InstructionCreateInput,
  InstructionDetail,
  InstructionFilter,
  LLMCall,
  LLMCallMetric,
  MetricListResult,
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
  ProjectCreateInput,
  Session,
  SessionFilter,
  SessionTreeNode,
  SkillEvaluationResult,
  SkillValidationResult,
  Story,
  StoryFilter,
  ToMarkdownRequest,
  ToMarkdownResult,
  ToolCall,
  ToolCallMetric,
  ToolError,
  ToolEntry,
  ToolInvokeResult,
  OrchestrationTriggerInput,
  OrchestrationTriggerResult,
} from "../types";

// ── Base URL (dev proxy to backend on :8765) ─────────────────────────────

const BASE =
  typeof window !== "undefined" && window.location.port === "3000"
    ? "http://127.0.0.1:8765"
    : "";

function url(path: string): string {
  return `${BASE}${path}`;
}

// ── Fetch helpers ────────────────────────────────────────────────────────

async function post<T>(path: string, body: unknown): Promise<T> {
  const r = await fetch(url(path), {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  if (!r.ok) throw new Error(`${path} returned ${r.status}`);
  return r.json();
}

async function get<T>(path: string): Promise<T> {
  const r = await fetch(url(path));
  if (!r.ok) throw new Error(`${path} returned ${r.status}`);
  return r.json();
}

async function tryGet<T>(path: string): Promise<T | null> {
  const r = await fetch(url(path));
  if (r.status === 404) return null;
  if (!r.ok) throw new Error(`${path} returned ${r.status}`);
  return r.json();
}

async function patch<T>(path: string, body: unknown): Promise<T> {
  const r = await fetch(url(path), {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  if (!r.ok) throw new Error(`${path} returned ${r.status}`);
  return r.json();
}

// ── Tools ────────────────────────────────────────────────────────────────

export const tools = {
  async list(): Promise<ToolEntry[]> {
    return get<ToolEntry[]>("/api/catalog");
  },
  async get(name: string): Promise<ToolEntry | null> {
    return tryGet<ToolEntry>(`/api/catalog/tool/${encodeURIComponent(name)}`);
  },
  async search(query: string, mode: "text" | "intent" = "text"): Promise<ToolEntry[]> {
    const params = new URLSearchParams({ q: query, mode });
    return get<ToolEntry[]>(`/api/catalog/search?${params}`);
  },
  async categories(): Promise<CategoryInfo[]> {
    return get<CategoryInfo[]>("/api/catalog/categories");
  },
  async invoke(name: string, args: Record<string, unknown>): Promise<ToolInvokeResult> {
    return post<ToolInvokeResult>("/api/catalog/invoke", { name, args });
  },
};

// ── NPL ──────────────────────────────────────────────────────────────────

export const npl = {
  async load(request: NPLLoadRequest): Promise<NPLResponse> {
    return post<NPLResponse>("/api/npl/load", request);
  },
  async spec(request: NPLSpecRequest): Promise<NPLResponse> {
    const normalize = (c: unknown) =>
      typeof c === "string" ? { spec: c } : c;
    return post<NPLResponse>("/api/npl/spec", {
      ...request,
      components: request.components?.map(normalize),
      rendered: request.rendered?.map(normalize),
    });
  },
  async elements(): Promise<NPLElement[]> {
    return get<NPLElement[]>("/api/npl/elements");
  },
  async coverage(): Promise<NPLCoverage> {
    return get<NPLCoverage>("/api/npl/coverage");
  },
};

// ── Sessions ─────────────────────────────────────────────────────────────

export const sessions = {
  async list(filter?: SessionFilter): Promise<Session[]> {
    const params = new URLSearchParams();
    if (filter?.project) params.set("project", filter.project);
    if (filter?.agent) params.set("agent", filter.agent);
    if (filter?.search) params.set("search", filter.search);
    if (filter?.limit != null) params.set("limit", String(filter.limit));
    const qs = params.toString();
    return get<Session[]>(`/api/sessions${qs ? `?${qs}` : ""}`);
  },
  async get(uuid: string): Promise<Session | null> {
    return tryGet<Session>(`/api/sessions/${encodeURIComponent(uuid)}`);
  },
  async tree(rootUuid: string): Promise<SessionTreeNode | null> {
    return tryGet<SessionTreeNode>(
      `/api/sessions/${encodeURIComponent(rootUuid)}/tree`
    );
  },
  async appendNote(uuid: string, note: string): Promise<Session> {
    return post<Session>(
      `/api/sessions/${encodeURIComponent(uuid)}/notes`,
      { note },
    );
  },
};

// ── Instructions ─────────────────────────────────────────────────────────

export const instructions = {
  async list(filter?: InstructionFilter): Promise<Instruction[]> {
    const params = new URLSearchParams();
    if (filter?.query) params.set("query", filter.query);
    if (filter?.mode) params.set("mode", filter.mode);
    if (filter?.tags && filter.tags.length > 0) params.set("tags", filter.tags.join(","));
    if (filter?.limit != null) params.set("limit", String(filter.limit));
    const qs = params.toString();
    return get<Instruction[]>(`/api/instructions${qs ? `?${qs}` : ""}`);
  },
  async get(uuid: string): Promise<InstructionDetail | null> {
    return tryGet<InstructionDetail>(
      `/api/instructions/${encodeURIComponent(uuid)}`
    );
  },
  async create(input: InstructionCreateInput): Promise<InstructionDetail> {
    return post<InstructionDetail>("/api/instructions", input);
  },
};

// ── Projects / Personas / Stories ────────────────────────────────────────

export const projects = {
  async list(): Promise<Project[]> {
    return get<Project[]>("/api/projects");
  },
  async get(id: string): Promise<Project | null> {
    return tryGet<Project>(`/api/projects/${encodeURIComponent(id)}`);
  },
  async create(input: ProjectCreateInput): Promise<Project> {
    return post<Project>("/api/projects", input);
  },
};

export const personas = {
  async listByProject(projectId: string): Promise<Persona[]> {
    return get<Persona[]>(`/api/projects/${encodeURIComponent(projectId)}/personas`);
  },
  async get(id: string): Promise<Persona | null> {
    return tryGet<Persona>(`/api/personas/${encodeURIComponent(id)}`);
  },
};

export const stories = {
  async listByProject(projectId: string, filter?: StoryFilter): Promise<Story[]> {
    const params = new URLSearchParams();
    if (filter?.status) params.set("status", filter.status);
    if (filter?.priority) params.set("priority", filter.priority);
    if (filter?.persona_id) params.set("persona_id", filter.persona_id);
    const qs = params.toString();
    return get<Story[]>(
      `/api/projects/${encodeURIComponent(projectId)}/stories${qs ? `?${qs}` : ""}`
    );
  },
  async get(id: string): Promise<Story | null> {
    return tryGet<Story>(`/api/stories/${encodeURIComponent(id)}`);
  },
  async update(
    id: string,
    patchData: Partial<Pick<Story, "status" | "priority" | "story_points" | "tags" | "title">>
  ): Promise<Story> {
    return patch<Story>(`/api/stories/${encodeURIComponent(id)}`, patchData);
  },
};

// ── Metrics ──────────────────────────────────────────────────────────────

export const metrics = {
  async recentToolCalls(limit: number = 20): Promise<ToolCall[]> {
    const r = await fetch(url(`/api/metrics/tool-calls?limit=${limit}`));
    if (r.status === 501) return []; // not yet provisioned
    if (!r.ok) throw new Error(`/api/metrics/tool-calls returned ${r.status}`);
    const data: MetricListResult<ToolCallMetric> = await r.json();
    return data.items.map((item) => ({
      id: String(item.id),
      tool_name: item.tool_name,
      session_id: item.session_id,
      args_summary: "",
      status: (item.status === "ok" ? "ok" : "error") as "ok" | "error",
      error_message: null,
      response_time_ms: item.response_time_ms ?? 0,
      created_at: item.created_at ?? new Date().toISOString(),
    }));
  },
  async recentLLMCalls(limit: number = 20): Promise<LLMCall[]> {
    const r = await fetch(url(`/api/metrics/llm-calls?limit=${limit}`));
    if (r.status === 501) return []; // not yet provisioned
    if (!r.ok) throw new Error(`/api/metrics/llm-calls returned ${r.status}`);
    const data: MetricListResult<LLMCallMetric> = await r.json();
    return data.items.map((item) => ({
      id: String(item.id),
      model: item.model,
      purpose: item.purpose ?? "",
      tokens_in: item.tokens_in ?? 0,
      tokens_out: item.tokens_out ?? 0,
      duration_ms: item.duration_ms ?? 0,
      created_at: item.created_at ?? new Date().toISOString(),
    }));
  },
  async recentErrors(limit = 50): Promise<ToolError[]> {
    return get<ToolError[]>(`/api/errors?limit=${limit}`);
  },
};

// ── Chat / Artifacts / Orchestration ─────────────────────────────────────

export const chat = {
  async listRooms(): Promise<ChatRoom[]> {
    const r = await fetch(url("/api/chat/rooms"));
    if (!r.ok) throw new Error(`/api/chat/rooms returned ${r.status}`);
    const data: ChatRoomListResult = await r.json();
    return data.items;
  },
  async getRoom(id: string): Promise<ChatRoom | null> {
    return tryGet<ChatRoom>(`/api/chat/rooms/${encodeURIComponent(id)}`);
  },
  async createRoom(input: ChatRoomCreateInput): Promise<ChatRoom> {
    return post<ChatRoom>("/api/chat/rooms", input);
  },
  async sendMessage(roomId: number, input: ChatMessageCreateInput): Promise<ChatMessage> {
    return post<ChatMessage>(`/api/chat/rooms/${roomId}/messages`, input);
  },
  async listMessages(roomId: number, limit: number = 50): Promise<ChatMessage[]> {
    const r = await fetch(url(`/api/chat/rooms/${roomId}/messages?limit=${limit}`));
    if (!r.ok) throw new Error(`/api/chat/rooms/${roomId}/messages returned ${r.status}`);
    const data: ChatMessageListResult = await r.json();
    return data.items;
  },
};

export const artifacts = {
  async list(kind?: ArtifactKind, limit?: number): Promise<ArtifactListResult> {
    const params = new URLSearchParams();
    if (kind) params.set("kind", kind);
    if (limit != null) params.set("limit", String(limit));
    const qs = params.toString();
    return get<ArtifactListResult>(`/api/artifacts${qs ? `?${qs}` : ""}`);
  },
  async get(id: number, revision?: number): Promise<ArtifactWithRevision | null> {
    const qs = revision != null ? `?revision=${revision}` : "";
    return tryGet<ArtifactWithRevision>(`/api/artifacts/${id}${qs}`);
  },
  async create(input: ArtifactCreateInput): Promise<ArtifactWithRevision> {
    return post<ArtifactWithRevision>("/api/artifacts", input);
  },
  async listRevisions(id: number): Promise<ArtifactRevisionsResult> {
    return get<ArtifactRevisionsResult>(`/api/artifacts/${id}/revisions`);
  },
  async addRevision(id: number, input: ArtifactRevisionInput): Promise<ArtifactWithRevision> {
    return post<ArtifactWithRevision>(`/api/artifacts/${id}/revisions`, input);
  },
  async upload(input: ArtifactUploadInput): Promise<ArtifactWithRevision> {
    const fd = new FormData();
    fd.append("file", input.file);
    fd.append("title", input.title);
    if (input.kind) fd.append("kind", input.kind);
    if (input.description) fd.append("description", input.description);
    if (input.created_by) fd.append("created_by", input.created_by);
    if (input.notes) fd.append("notes", input.notes);
    const r = await fetch(url("/api/artifacts/upload"), { method: "POST", body: fd });
    if (!r.ok) throw new Error(`/api/artifacts/upload returned ${r.status}`);
    return r.json();
  },
  async addRevisionUpload(
    id: number,
    input: ArtifactRevisionUploadInput
  ): Promise<ArtifactWithRevision> {
    const fd = new FormData();
    fd.append("file", input.file);
    if (input.notes) fd.append("notes", input.notes);
    if (input.created_by) fd.append("created_by", input.created_by);
    const r = await fetch(url(`/api/artifacts/${id}/revisions/upload`), {
      method: "POST",
      body: fd,
    });
    if (!r.ok)
      throw new Error(`/api/artifacts/${id}/revisions/upload returned ${r.status}`);
    return r.json();
  },
  rawUrl(id: number, revision: number): string {
    return url(`/api/artifacts/${id}/revisions/${revision}/raw`);
  },
};

export const orchestration = {
  async agents(): Promise<AgentDefinition[]> {
    return get<AgentDefinition[]>("/api/orchestration/agents");
  },
  async recentRuns(): Promise<PipelineRun[]> {
    return get<PipelineRun[]>("/api/orchestration/runs");
  },
  async trigger(input: OrchestrationTriggerInput): Promise<OrchestrationTriggerResult> {
    return post<OrchestrationTriggerResult>("/api/orchestration/trigger", input);
  },
};

// ── PRDs ─────────────────────────────────────────────────────────────────

export const prds = {
  async list(): Promise<PRDSummary[]> {
    return get<PRDSummary[]>("/api/prds");
  },
  async get(id: string): Promise<PRDDetail | null> {
    return tryGet<PRDDetail>(`/api/prds/${encodeURIComponent(id)}`);
  },
  async functionalRequirements(id: string): Promise<FRDocument[]> {
    return get<FRDocument[]>(`/api/prds/${encodeURIComponent(id)}/functional-requirements`);
  },
  async acceptanceTests(id: string): Promise<ATDocument[]> {
    return get<ATDocument[]>(`/api/prds/${encodeURIComponent(id)}/acceptance-tests`);
  },
};

// ── Project Explorer (US-025) ────────────────────────────────────────────

export const explorer = {
  async tree(path = ".", depth = 3): Promise<FileTreeNode> {
    const params = new URLSearchParams({ path, depth: String(depth) });
    return get<FileTreeNode>(`/api/project/tree?${params}`);
  },
  async file(path: string): Promise<FileContent> {
    const params = new URLSearchParams({ path });
    return get<FileContent>(`/api/project/file?${params}`);
  },
};

// ── Docs (US-047) ────────────────────────────────────────────────────────

export const docs = {
  async get(name: "schema" | "arch" | "layout" | "status"): Promise<DocContent> {
    return get<DocContent>(`/api/docs/${encodeURIComponent(name)}`);
  },
};

// ── Skills (US-119 + US-120) ─────────────────────────────────────────────

export const skills = {
  async validate(content: string, filename?: string): Promise<SkillValidationResult> {
    return post<SkillValidationResult>("/api/skills/validate", { content, filename });
  },
  async evaluate(content: string, filename?: string): Promise<SkillEvaluationResult> {
    return post<SkillEvaluationResult>("/api/skills/evaluate", { content, filename });
  },
};

// ── Browser (US-096) ─────────────────────────────────────────────────────

export const browser = {
  async toMarkdown(request: ToMarkdownRequest): Promise<ToMarkdownResult> {
    return post<ToMarkdownResult>("/api/browser/to-markdown", request);
  },
};

// ── Agents (US-221) ──────────────────────────────────────────────────────

export const agents = {
  async list(): Promise<AgentInfo[]> {
    return get<AgentInfo[]>("/api/agents");
  },
  async get(name: string): Promise<AgentDetail | null> {
    return tryGet<AgentDetail>(`/api/agents/${encodeURIComponent(name)}`);
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

export const tasks = {
  async list(filter?: TaskFilter): Promise<TaskListResult> {
    const params = new URLSearchParams();
    if (filter?.status) params.set("status", filter.status);
    if (filter?.assigned_to) params.set("assigned_to", filter.assigned_to);
    if (filter?.limit != null) params.set("limit", String(filter.limit));
    const qs = params.toString();
    return get<TaskListResult>(`/api/tasks${qs ? `?${qs}` : ""}`);
  },
  async get(id: number): Promise<Task | null> {
    return tryGet<Task>(`/api/tasks/${id}`);
  },
  async create(input: TaskCreateInput): Promise<Task> {
    return post<Task>("/api/tasks", input);
  },
  async updateStatus(id: number, status: TaskStatus, notes?: string): Promise<Task> {
    return patch<Task>(`/api/tasks/${id}/status`, { status, ...(notes ? { notes } : {}) });
  },
};

// ── Health ───────────────────────────────────────────────────────────────

export const health = {
  async check(): Promise<HealthReport> {
    return get<HealthReport>("/api/health");
  },
  async ping(): Promise<{ status: string; ts: string }> {
    return get<{ status: string; ts: string }>("/api/health/ping");
  },
};
