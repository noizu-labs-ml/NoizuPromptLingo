/**
 * Shared types for the NPL MCP companion dashboard.
 *
 * These shapes are designed to match the planned REST response bodies,
 * so that swapping the mock implementation for a real fetch-based client
 * is a per-function change (see lib/api/impl/).
 */

// ── Tool catalog ─────────────────────────────────────────────────────────

export interface ToolParam {
  name: string;
  type: string; // "str" | "int" | "bool" | "float" | "list" | "dict"
  required: boolean;
  description: string;
}

export interface ToolEntry {
  name: string;
  category: string;
  description: string;
  parameters: ToolParam[];
  tags?: string[];
  title?: string;
  version?: string;
}

export interface CategoryInfo {
  name: string;
  description: string;
  tool_count: number;
}

export interface ToolInvokeResult {
  tool: string;
  status: "ok" | "mcp" | "stub" | "error";
  message?: string;
  result?: unknown;
  duration_ms?: number;
}

// ── Sessions ─────────────────────────────────────────────────────────────

export interface Session {
  uuid: string;
  agent: string;
  brief: string;
  task: string;
  project: string;
  parent?: string | null;
  notes?: string | null;
  created_at: string;
  updated_at: string;
}

export interface SessionTreeNode extends Session {
  children: SessionTreeNode[];
}

// ── Instructions ─────────────────────────────────────────────────────────

export interface Instruction {
  uuid: string;
  title: string;
  description: string;
  tags: string[];
  active_version: number;
  session_id?: string | null;
  created_at: string;
  updated_at: string;
}

export interface InstructionVersion {
  version: number;
  body: string;
  change_note: string;
  created_at: string;
}

export interface InstructionDetail extends Instruction {
  versions: InstructionVersion[];
}

// ── Projects / Personas / Stories ────────────────────────────────────────

export interface Project {
  id: string;
  name: string;
  title: string;
  description: string;
  persona_count: number;
  story_count: number;
  created_at: string;
}

export interface Persona {
  id: string;
  project_id: string;
  name: string;
  role: string;
  description: string;
  goals: string[];
  pain_points: string[];
  behaviors: string[];
  demographics: Record<string, string | number | boolean>;
  image?: string | null;
  created_at: string;
}

export type StoryStatus = "draft" | "ready" | "in_progress" | "done" | "archived";
export type StoryPriority = "low" | "medium" | "high" | "critical";

export interface Story {
  id: string;
  project_id: string;
  title: string;
  story_text: string;
  description: string;
  priority: StoryPriority;
  status: StoryStatus;
  story_points: number;
  acceptance_criteria: string[];
  tags: string[];
  persona_ids: string[];
  created_at: string;
  updated_at: string;
}

// ── NPL ──────────────────────────────────────────────────────────────────

export interface NPLSectionCoverage {
  section: string;
  total: number;
  complete: number;
  coverage_percent: number;
  missing: string[];
}

export interface NPLCoverage {
  total_sections: number;
  total_components: number;
  complete_components: number;
  coverage_percent: number;
  by_section: NPLSectionCoverage[];
}

export interface NPLElement {
  section: string;
  name: string;
  slug: string;
  friendly_name?: string;
  brief: string;
  priority: number;
  tags?: string[];
}

export interface DocContent {
  path: string;
  content: string;
  size?: number;
}

export interface NPLLoadRequest {
  expression: string;
  layout?: "yaml_order" | "classic" | "grouped";
  /**
   * Optional list of expression terms already loaded elsewhere — those
   * components are excluded from this load. Same grammar as `expression`
   * (without leading `-`).
   */
  skip?: string[];
}

export interface NPLComponentSpec {
  spec: string;                  // "section:*" or "section:name"
  component_priority?: number;   // 0 = default; higher = more verbose
  example_priority?: number;     // 0 = default; higher = more examples
}

export interface NPLSpecRequest {
  components?: Array<string | NPLComponentSpec>;
  rendered?: Array<string | NPLComponentSpec>;
  component_priority?: number;
  example_priority?: number;
  concise?: boolean;
  xml?: boolean;
  extension?: boolean;
}

export interface NPLResponse {
  markdown: string;
  char_count: number;
}

// ── Tool Errors (US-049) ─────────────────────────────────────────────────

export interface ToolError {
  id: number;
  tool_name: string;
  error_type: string;
  error_message: string;
  session_id: string | null;
  stack_excerpt: string | null;
  created_at: string;
}

// ── Metrics (Tier 2 stub) ────────────────────────────────────────────────

export interface ToolCall {
  id: string;
  tool_name: string;
  session_id?: string | null;
  args_summary: string;
  status: "ok" | "error";
  error_message?: string | null;
  response_time_ms: number;
  created_at: string;
}

export interface LLMCall {
  id: string;
  model: string;
  purpose: string; // "intent_search" | "image_description" | "tool_help"
  tokens_in: number;
  tokens_out: number;
  duration_ms: number;
  created_at: string;
}

// ── Chat / Artifacts (Tier 3 stub) ───────────────────────────────────────

export interface ChatRoom {
  id: number;
  name: string;
  description: string;
  message_count: number;
  last_activity: string | null;
  created_at: string;
}

export type ArtifactKind =
  | "markdown"
  | "json"
  | "yaml"
  | "code"
  | "text"
  | "other"
  | "image"
  | "video"
  | "audio"
  | "pdf"
  | "binary";

export const BINARY_ARTIFACT_KINDS: ReadonlyArray<ArtifactKind> = [
  "image",
  "video",
  "audio",
  "pdf",
  "binary",
];

export function isBinaryKind(k: ArtifactKind): boolean {
  return (BINARY_ARTIFACT_KINDS as readonly string[]).includes(k);
}

export interface Artifact {
  id: number;
  title: string;
  kind: ArtifactKind;
  description: string;
  created_by: string | null;
  latest_revision: number;
  created_at: string | null;
  updated_at: string | null;
}

export interface ArtifactRevision {
  id: number;
  artifact_id: number;
  revision: number;
  content: string;
  mime_type?: string | null;
  has_binary?: boolean;
  notes: string | null;
  created_by: string | null;
  created_at: string | null;
}

export interface ArtifactUploadInput {
  file: File;
  title: string;
  kind?: ArtifactKind;
  description?: string;
  created_by?: string | null;
  notes?: string | null;
}

export interface ArtifactRevisionUploadInput {
  file: File;
  notes?: string | null;
  created_by?: string | null;
}

export interface ArtifactRevisionSummary {
  id: number;
  artifact_id: number;
  revision: number;
  notes: string | null;
  created_by: string | null;
  created_at: string | null;
}

export interface ArtifactWithRevision extends Artifact {
  revision: ArtifactRevision;
}

export interface ArtifactListResult {
  artifacts: Artifact[];
  count: number;
}

export interface ArtifactRevisionsResult {
  artifact_id: number;
  revisions: ArtifactRevisionSummary[];
  count: number;
}

export interface ArtifactCreateInput {
  title: string;
  content: string;
  kind?: ArtifactKind;
  description?: string;
  created_by?: string | null;
  notes?: string | null;
}

export interface ArtifactRevisionInput {
  content: string;
  notes?: string | null;
  created_by?: string | null;
}

// ── Orchestration (Tier 3 stub) ──────────────────────────────────────────

export interface AgentDefinition {
  name: string;
  purpose: string;
  kind: "pipeline" | "utility" | "executor";
}

export interface PipelineRun {
  id: string;
  feature: string;
  status: "pending" | "running" | "failed" | "complete";
  stage: string;
  started_at: string;
  completed_at?: string | null;
}

// ── PRDs ────────────────────────────────────────────────────────────────

export interface PRDSummary {
  id: string;           // e.g. "PRD-001-database-infrastructure" OR "PRD-015-npl-loading-extension"
  number: number;       // 1, 2, etc.
  title: string;
  status: string | null;
  has_frs: boolean;
  has_ats: boolean;
  path: string;
}

export interface PRDDetail extends PRDSummary {
  body: string;                                     // main README markdown
  functional_requirements: Array<{ id: string; title: string }>;  // summaries only
  acceptance_tests: Array<{ id: string; title: string }>;
}

export interface FRDocument { id: string; title: string; body: string; }
export interface ATDocument { id: string; title: string; body: string; }

// ── Filter / query options ───────────────────────────────────────────────

export interface SessionFilter {
  project?: string;
  agent?: string;
  search?: string;
  limit?: number;
}

export interface InstructionFilter {
  query?: string;
  mode?: "text" | "intent" | "all";
  tags?: string[];
  limit?: number;
}

export interface StoryFilter {
  status?: StoryStatus;
  priority?: StoryPriority;
  persona_id?: string;
}

// ── Project Explorer (US-025) ────────────────────────────────────────────

export interface FileTreeNode {
  name: string;
  path: string;
  kind: "directory" | "file" | "binary";
  size?: number;
  children?: FileTreeNode[];
}

export interface FileContent {
  path: string;
  content: string | null;
  size: number;
  kind?: "binary";
  truncated?: boolean;
}

// ── Browser / ToMarkdown (US-096) ───────────────────────────────────────

export interface ToMarkdownRequest {
  source: string;
  heading_filter?: string | null;
  collapse_depth?: number | null;
  with_image_descriptions?: boolean;
  bare?: boolean;
}

export interface ToMarkdownResult {
  markdown: string;
  source: string;
  char_count: number;
}

// ── Agents (US-221) ─────────────────────────────────────────────────────

export interface AgentInfo {
  name: string;           // filename stem e.g. "npl-idea-to-spec"
  display_name: string;   // from frontmatter "name:" or fallback to stem
  description: string;    // frontmatter description or first paragraph
  model: string | null;   // frontmatter model
  allowed_tools: string[]; // from frontmatter
  kind: "pipeline" | "utility" | "executor";
  path: string;           // relative to repo root e.g. "agents/npl-idea-to-spec.md"
  body_length: number;    // char count of markdown body
}

export interface AgentDetail extends AgentInfo {
  body: string;           // full markdown body
}

// ── Skills (US-119) ─────────────────────────────────────────────────────

export interface SkillValidationError {
  severity: "error" | "warning";
  field: string;
  message: string;
}

export interface SkillValidationResult {
  valid: boolean;
  errors: SkillValidationError[];
  warnings: SkillValidationError[];
  summary: Record<string, unknown>;
}

export interface SkillQualityScore {
  dimension: "description" | "examples" | "structure" | "completeness";
  score: number; // 0.0 to 1.0
  notes: string[];
}

export interface SkillEvaluationResult {
  overall_score: number; // 0.0 to 1.0
  dimensions: SkillQualityScore[];
  validation: SkillValidationResult;
  suggestions: string[];
}

// ── Tasks (PRD-005 MVP) ─────────────────────────────────────────────────

export type TaskStatus = "pending" | "in_progress" | "blocked" | "review" | "done";

export interface Task {
  id: number;
  title: string;
  description: string;
  status: TaskStatus;
  priority: number;
  assigned_to: string | null;
  notes: string | null;
  created_at: string | null;
  updated_at: string | null;
}

export interface TaskListResult {
  tasks: Task[];
  count: number;
}

export interface TaskCreateInput {
  title: string;
  description?: string;
  status?: TaskStatus;
  priority?: number;
  assigned_to?: string | null;
  notes?: string | null;
}

export interface TaskFilter {
  status?: TaskStatus;
  assigned_to?: string;
  limit?: number;
}

// ── Health / Status ─────────────────────────────────────────────────────

export interface SubsystemHealth {
  status: "ok" | "unavailable" | "missing" | "not_configured";
  message?: string;
  latency_ms?: number;
  [key: string]: unknown;
}

export interface HealthReport {
  server: SubsystemHealth & { uptime_seconds: number; fastmcp_version: string };
  database: SubsystemHealth;
  litellm: SubsystemHealth & { url?: string };
  catalog: SubsystemHealth & {
    tool_count: number;
    mcp_tools: number;
    hidden_tools: number;
    stub_tools: number;
  };
  frontend_build: SubsystemHealth & { dist_path: string };
}

// ── Create inputs ────────────────────────────────────────────────────────

export interface InstructionCreateInput {
  title: string;
  description?: string;
  body?: string;
  tags?: string[];
}

export interface ProjectCreateInput {
  name: string;
  title?: string;
  description?: string;
}

// ── Chat messages ────────────────────────────────────────────────────────

export interface ChatMessage {
  id: number;
  room_id: number;
  content: string;
  author: string;
  created_at: string | null;
}

export interface ChatMessageListResult {
  items: ChatMessage[];
  count: number;
}

export interface ChatRoomListResult {
  items: ChatRoom[];
  count: number;
}

export interface ChatRoomCreateInput {
  name: string;
  description?: string;
}

export interface ChatMessageCreateInput {
  content: string;
  author?: string;
}

// ── Agent Pipes ─────────────────────────────────────────────────────────

export interface PipeInputRequest {
  agent: string;
  since?: string;
  full?: boolean;
  with_sections?: string[];
}

export interface PipeDashboardEntry {
  sender: { agent_id: string; agent_handle: string };
  updated_at: string | null;
  data: unknown;
}

export interface PipeInputResult {
  status: string;
  agent: string;
  agent_handle: string;
  groups: string[];
  entries: number;
  dashboard: Record<string, PipeDashboardEntry | PipeDashboardEntry[]>;
}

export interface PipeOutputRequest {
  agent: string;
  body: string;
}

export interface PipeOutputResult {
  status: string;
  upserted: number;
  sender: string;
}

// ── Orchestration trigger (Wave O) ───────────────────────────────────────

export interface OrchestrationTriggerInput {
  feature_description: string;
  agent?: string;
}

export interface OrchestrationTriggerResult {
  run_id: string;
  status: "queued";
  task_id: number | null;
  created_at: string | null;
}

// ── Metrics (live data) ──────────────────────────────────────────────────

export interface ToolCallMetric {
  id: number;
  tool_name: string;
  status: string;
  response_time_ms: number | null;
  session_id: string | null;
  created_at: string | null;
}

export interface LLMCallMetric {
  id: number;
  model: string;
  purpose: string | null;
  tokens_in: number | null;
  tokens_out: number | null;
  duration_ms: number | null;
  session_id: string | null;
  created_at: string | null;
}

export interface MetricListResult<T> {
  items: T[];
  count: number;
}

// ── Chat Enhanced ───────────────────────────────────────────────────────

export interface ChatRoomMember {
  persona_slug: string;
  joined_at: string | null;
}

export interface ChatEvent {
  id: number;
  event_type: string;
  persona: string;
  data: Record<string, unknown>;
  reply_to_id: number | null;
  created_at: string | null;
}

export interface ChatNotification {
  id: number;
  notification_type: string;
  event_type: string;
  room_id: number;
  data: Record<string, unknown>;
  created_at: string | null;
  read_at: string | null;
}

// ── Reviews ─────────────────────────────────────────────────────────────

export interface Review {
  review_id: number;
  artifact_id: number;
  revision_id: number;
  reviewer_persona: string;
  review_status: string;
  overall_comment: string | null;
  created_at: string | null;
  comments?: InlineComment[];
}

export interface InlineComment {
  id: number;
  location: string;
  comment: string;
  persona: string;
  created_at: string | null;
}

export interface ReviewCreateInput {
  artifact_id: number;
  revision_id: number;
  reviewer_persona: string;
}

export interface ReviewCommentInput {
  location: string;
  comment: string;
  persona: string;
}

// ── Task Queues ─────────────────────────────────────────────────────────

export interface TaskQueue {
  id: number;
  name: string;
  description: string;
  session_id: string | null;
  chat_room_id: number | null;
  queue_status: string;
  task_counts?: Record<string, number>;
  created_at: string | null;
  updated_at: string | null;
}

export interface TaskQueueCreateInput {
  name: string;
  description?: string;
  session_id?: string;
  chat_room_id?: number;
}

export interface TaskEvent {
  id: number;
  event_type: string;
  persona: string | null;
  data: Record<string, unknown>;
  created_at: string | null;
}

export interface TaskArtifact {
  id: number;
  artifact_type: string;
  artifact_id: number | null;
  git_branch: string | null;
  description: string | null;
  created_by: string | null;
  created_at: string | null;
}

export interface TaskArtifactInput {
  artifact_type: string;
  artifact_id?: number;
  git_branch?: string;
  description?: string;
  created_by?: string;
}

// ── Executors / Taskers ─────────────────────────────────────────────────

export interface Tasker {
  tasker_id: string;
  task: string;
  patterns: string[];
  parent_agent_id: string;
  chat_room_id: number;
  session_id: string | null;
  status: string;
  timeout_minutes: number;
  nag_minutes: number;
  created_at: string | null;
  last_activity: string | null;
  terminated_at: string | null;
  termination_reason: string | null;
}

export interface TaskerSpawnInput {
  task: string;
  chat_room_id: number;
  parent_agent_id?: string;
  patterns?: string[];
  session_id?: string;
  timeout_minutes?: number;
  nag_minutes?: number;
}

// ── Session Contents ────────────────────────────────────────────────────

export interface SessionContents {
  session: Record<string, unknown>;
  chat_rooms: Array<{ id: number; name: string; message_count: number; last_activity: string | null }>;
  artifacts: Array<{ id: number; title: string; kind: string; latest_revision: number }>;
}
