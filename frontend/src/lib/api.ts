// Browser talks same-origin (ingress splits /api to Phoenix). A baked
// NEXT_PUBLIC_API_URL that doesn't match the page origin used to hide SSO
// and fail the code exchange after Authentik.
import { AUTH_COOKIE_MAX_AGE_SEC, cookieDomainAttribute } from "@/lib/auth-redirect";

const API_URL =
  typeof window !== "undefined" ? "" : process.env.NEXT_PUBLIC_API_URL || "";

export interface User {
  id: string;
  email: string;
  user_name?: string;
  handle?: string;
  role?: string;
  bio?: string;
  status?: string;
  verified?: boolean;
}

// Roles a user may assign to themselves on their own profile. Privileged
// roles (moderator, admin, owner, service) must be granted by an admin and
// are rejected by the backend on self-update.
export const SELF_ASSIGNABLE_ROLES = ["user", "other"] as const;

export interface Organization {
  id: string;
  slug: string;
  name: string;
  role?: string;
  /** The caller's effective role in this org, echoed per-row by the list serializer
   *  (ticket 16dc3df2) for advisory affordance gating; equals `role` today. */
  effective_role?: string;
  owner?: string | null;
}

// A resource membership (PBAC, ticket 4a9aa9d9). member_type-agnostic: "user" today;
// "persona"/"agent" rows appear later (ccaf5684) with zero FE change.
export interface OrgMember {
  id: string;
  /** member_type: "user" | "persona". Branch on this for an agent badge/link (ccaf5684). */
  member_type: string;
  /**
   * Unified display name across user + persona rows (aniket seq740). Use this for the
   * primary cell — persona rows have nil user_id/email, so user_name||email would blank.
   */
  display_name?: string;
  /** Optional avatar (persona avatar; nil for users — fall back to the dot/initial). */
  avatar?: string | null;
  // ── user rows ── (nil on persona rows)
  user_id?: string;
  email?: string;
  user_name?: string;
  // ── persona rows ── (nil on user rows; ccaf5684 / ADR-017)
  persona_id?: string;
  persona_slug?: string;
  /** The target member's canonical role: owner | admin | lead | member | viewer. */
  role: string;
  /** Membership scope. */
  resource_type: string;
  resource_id?: string;
  /** The CALLER's role in this resource, echoed per row (16dc3df2) — drives the gates. */
  effective_role?: string;
  joined_at: string;
  expires_at?: string | null;
}

export interface Project {
  id: string;
  organization_id?: string;
  name: string;
  slug: string;
  description?: string | null;
  settings?: Record<string, unknown>;
  status?: string;
  /** Prefix for human ticket keys (e.g. "ABC" -> ABC-001); lucia 055. */
  key_prefix?: string | null;
  // Present on detail/create/update responses
  archived_at?: string | null;
  inserted_at?: string;
  updated_at?: string;
  // Present on list responses (from list_user_accessible_projects)
  created_at?: string;
  role_name?: string;
  inherited_from_org?: boolean;
}

export interface ProjectInput {
  name: string;
  slug: string;
  description?: string;
  settings?: Record<string, unknown>;
  key_prefix?: string;
}

/** Server-side org dashboard aggregates (GET .../dashboard/stats). */
export interface OrgDashboardStats {
  range: number;
  counts: {
    projects: number;
    sessions: number;
    artifacts: number;
    reviews: number;
    tickets: number;
    chat_rooms: number;
  };
  by_status: {
    sessions: Record<string, number>;
    tickets: Record<string, number>;
  };
  by_kind: {
    artifacts: Record<string, number>;
  };
  daily: {
    keys: string[];
    sessions: number[];
    artifacts: number[];
    chat_rooms: number[];
    tickets: number[];
    reviews: number[];
    projects?: number[];
  };
  weekly: Array<{
    week: string;
    sessions: number;
    artifacts: number;
    chat: number;
    tickets: number;
  }>;
  heatmap?: number[][];
  attention?: {
    open_reviews: Array<{ id: string; title?: string | null; status: string; updated_at?: string | null }>;
    blocked_tickets: Array<{ id: string; title?: string | null; status: string; updated_at?: string | null }>;
  };
  recent?: Array<{ type: string; id: string; title?: string | null; at?: string | null }>;
}

export interface VoiceApprovalScriptResponse {
  approval_script: string;
  execution_enabled: boolean;
  preview: {
    endpoint: string;
    command: string;
    organization: string;
    project_id?: string | null;
    title: string;
    ticket_type: string;
    description?: string;
  };
}

// Admin GitHub config. Token values are always masked by the backend.
export interface GithubToken {
  id: string;
  label: string;
  token_preview: string;
  inserted_at: string;
}

export interface GithubRepo {
  id: string;
  repo_full_name: string;
  token_id: string | null;
  token_label?: string | null;
  default_acl: "private" | "org_read" | "org_write";
  inserted_at: string;
}

export type RepoAcl = "private" | "org_read" | "org_write";
export type RepoGrantLevel = "read" | "write";

export interface GithubRepoGrant {
  id: string;
  group_id: string;
  group_name: string;
  display_name?: string | null;
}

// ── GitHub API operations (live data proxied through the backend) ──────────
export interface GithubRepoSummary {
  id: string;
  repo_full_name: string;
  default_acl: "private" | "org_read" | "org_write";
  token_preview: string | null;
  inserted_at: string;
}

export interface GithubUserRef {
  login: string;
}

export interface GithubPullRequest {
  id: number;
  number: number;
  title: string;
  state: "open" | "closed";
  user?: GithubUserRef | null;
  head?: { ref: string; sha: string };
  base?: { ref: string };
  body?: string | null;
  created_at?: string;
  updated_at?: string;
}

export interface GithubIssue {
  id: number;
  number: number;
  title: string;
  state: "open" | "closed";
  user?: GithubUserRef | null;
  assignees?: GithubUserRef[];
  labels?: Array<{ name: string }>;
  body?: string | null;
  created_at?: string;
  updated_at?: string;
}

export interface GithubComment {
  id: number;
  user?: GithubUserRef | null;
  body: string;
  created_at?: string;
  updated_at?: string;
}

export interface GithubBranch {
  name: string;
  commit?: { sha: string };
}

// MCP API keys: long-lived credentials used to mint short-lived MCP JWTs.
// The raw key is returned ONCE at creation (raw_key field); reads only expose
// the prefix for recognition.
export interface McpApiKey {
  id: string;
  label: string;
  key_prefix: string;
  status: "active" | "revoked";
  last_used_at?: string | null;
  expires_at?: string | null;
  inserted_at: string;
}

// A capture produced by a connected browser controller. `url` is a relative
// `/media/<short_id>` path; build absolute media URLs as `${API_URL}${url}`.
export interface BrowserCapture {
  id: string;
  short_id: string;
  url: string;
  media_type: "image" | "video";
  inserted_at: string;
}

export interface Session {
  id: string;
  organization_id: string;
  // Associating a session with a project is optional.
  project_id?: string | null;
  title: string;
  description?: string | null;
  status?: string;
  archived_at?: string | null;
  inserted_at?: string;
  updated_at?: string;
}

export interface McpTokenResponse {
  token: string;
  expires_at: string;
}

export interface McpServerConfig {
  id: string;
  label: string;
  required: boolean;
  desc: string;
  url: string;
  kind?: string;
  default?: boolean;
}

export interface McpConfigResponse {
  host: string;
  servers: McpServerConfig[];
  ala_carte?: McpServerConfig[];
  default_scope?: McpCustomScope | null;
  oauth?: {
    issuer: string;
    mcp_url: string;
    authorization_server_metadata: string;
  };
  legacy_api_key_mint_enabled?: boolean;
}

export interface McpOAuthConnection {
  grant_id: string;
  client_id: string;
  resource: string;
  scope: string;
  status: string;
  inserted_at?: string;
  expires_at?: string | null;
}

// OAuth 2.1 client (DCR-registered or first-party). Admin-only listing;
// grant_count is the number of active MCP pairing grants for this client.
export interface OAuthClient {
  client_id: string;
  client_name: string;
  token_endpoint_auth_method: string;
  redirect_uris: string[];
  is_first_party: boolean;
  status: "active" | "revoked";
  grant_count: number;
  inserted_at: string;
}

export interface McpCustomToolParam {
  name: string;
  type: string;
  required: boolean;
  description: string;
}

export interface McpCustomTool {
  name: string;
  category: string;
  description: string;
  parameters: McpCustomToolParam[];
  hidden: boolean;
}

export interface McpCustomGroup {
  id: string;
  label: string;
  desc: string;
  required?: boolean;
  tools: McpCustomTool[];
}

export interface McpCustomScopeConfig {
  groups: Record<string, {
    disabled?: boolean;
    hidden?: boolean;
    tools?: Record<string, { disabled?: boolean; hidden?: boolean }>;
  }>;
}

export interface McpCustomScope {
  id: string;
  slug: string;
  name: string;
  kind?: string;
  organization_id?: string | null;
  project_id?: string | null;
  user_id?: string | null;
  is_default?: boolean;
  source_template_slug?: string | null;
  owner_kind?: "template" | "user" | "organization" | string;
  editable?: boolean;
  description?: string | null;
  config: McpCustomScopeConfig;
  url?: string | null;
  inserted_at: string;
  updated_at?: string;
}

export interface McpEndpointsResponse {
  templates: McpCustomScope[];
  endpoints: McpCustomScope[];
  default_scope: McpCustomScope | null;
}

export interface McpCustomScopeInput {
  slug?: string;
  name: string;
  description?: string;
  kind?: string;
  config: McpCustomScopeConfig;
}

export interface SessionInput {
  title: string;
  description?: string;
  status?: string;
  // Optional — omit to leave the session unassociated with a project.
  project_id?: string | null;
}

// ── Chat / Artifacts / Reviews ──────────────────────────────────
// All three bind to an organization (required); project is optional.
export interface ChatRoom {
  id: string;
  organization_id: string;
  project_id?: string | null;
  session_id?: string | null;
  name: string;
  // slug: stable per-org/project handle, generated from name (BE ticket 0b2b1b46).
  // Optional until that lands; falls back to id/name in the UI.
  slug?: string | null;
  description?: string | null;
  inserted_at?: string;
  updated_at?: string;
}

export interface ChatRoomInput {
  name: string;
  description?: string;
  project_id?: string | null;
  session_id?: string | null;
}

// Chat messages + reactions (epic ffc795c5).
// Matches marcus-dev's FINAL contract (seq124/144): message uses content/sender and
// embeds batched per-message reaction summaries {emoji,count,me} (no N+1, server `me`).
export interface ChatMessage {
  id: string;
  room_id: string;
  sender?: string | null;
  content: string;
  inserted_at?: string;
  // Embedded grouped summaries; server-computed `me` (persona-scoped, per ADR-013 R2).
  reactions?: ChatReactionSummary[];
}

// Grouped reaction summary the room view renders directly. The BE supplies this
// shape both embedded per message and from the reaction endpoints (aniket seq171),
// with a server-computed `me` (viewer's own reaction state, persona-scoped per
// ADR-013 R2) — no client-side grouping/`me` synthesis needed.
export interface ChatReactionSummary {
  emoji: string;
  count: number;
  me: boolean;
}

export type ArtifactKind = "code" | "document" | "image" | "wiki" | "config" | "binary";

export interface Artifact {
  id: string;
  organization_id: string;
  project_id?: string | null;
  kind: ArtifactKind | string;
  title: string;
  mime_type?: string | null;
  // Present on show responses.
  content?: string | null;
  revision_id?: string | null;
  revision_number?: number | null;
  inserted_at?: string;
  updated_at?: string;
}

export interface ArtifactInput {
  kind: ArtifactKind | string;
  title: string;
  content: string;
  mime_type?: string;
  project_id?: string | null;
}

export interface Review {
  id: string;
  organization_id: string;
  project_id?: string | null;
  artifact_id: string;
  revision_id: string;
  reviewer_persona: string;
  title?: string | null;
  status: string;
  summary?: string | null;
  verdict?: string | null;
  inserted_at?: string;
  updated_at?: string;
}

export interface ReviewInput {
  artifact_id: string;
  revision_id: string;
  reviewer_persona: string;
  title?: string;
  project_id?: string | null;
}

// ── Tickets ("tasks"): org-scoped (required), optional project ──
export const TICKET_PRIORITIES = ["low", "medium", "high", "critical"] as const;
export type TicketPriority = (typeof TICKET_PRIORITIES)[number];

export interface Ticket {
  id: string;
  organization_id: string;
  project_id?: string | null;
  title: string;
  description?: string | null;
  ticket_type: string;
  status: string;
  priority?: string | null;
  assignee?: string | null;
  reporter?: string | null;
  queue_id?: string | null;
  parent_id?: string | null;
  stage_id?: string | null;
  iteration_id?: string | null;
  custom_fields?: Record<string, unknown>;
  inserted_at?: string;
  updated_at?: string;
}

export interface TicketInput {
  title: string;
  description?: string;
  ticket_type?: string;
  status?: string;
  priority?: string | null;
  assignee?: string;
  reporter?: string;
  project_id?: string | null;
  queue_id?: string | null;
  parent_id?: string | null;
  stage_id?: string | null;
  iteration_id?: string | null;
  custom_fields?: Record<string, unknown>;
}

// ── Boards (methodology-aware queues): kanban / scrum / waterfall / spiral ──
export const METHODOLOGIES = ["kanban", "scrum", "waterfall", "spiral"] as const;
export type Methodology = (typeof METHODOLOGIES)[number];

export interface BoardStage {
  id: string;
  slug: string;
  name: string;
  kind: string;
  position: number;
  wip_limit?: number | null;
  config?: Record<string, unknown>;
}

export interface BoardIteration {
  id: string;
  name: string;
  sequence: number;
  status: "planned" | "active" | "completed";
  goal?: string | null;
  starts_on?: string | null;
  ends_on?: string | null;
}

export interface Board {
  id: string;
  scope: DefinitionScope;
  organization_id?: string | null;
  project_id?: string | null;
  name: string;
  slug: string;
  methodology: Methodology | string;
  description?: string | null;
  config?: Record<string, unknown>;
  // Present on detail responses.
  stages?: BoardStage[];
  iterations?: BoardIteration[];
}

export interface BoardInput {
  name: string;
  slug: string;
  methodology: Methodology | string;
  description?: string;
  scope?: "org" | "project";
  project_id?: string | null;
}

export interface StageInput {
  slug?: string;
  name?: string;
  kind?: string;
  position?: number;
  wip_limit?: number | null;
}

export interface IterationInput {
  name?: string;
  sequence?: number;
  status?: "planned" | "active" | "completed";
  goal?: string | null;
  starts_on?: string | null;
  ends_on?: string | null;
}

// ── Assets: media-prompt entries + generated outputs ──
// Org-scoped (required), optional project. An entry stores a `.media.prompt`
// (YAML); generating produces outputs backed by artifacts.
export const ASSET_TYPES = [
  "image",
  "video",
  "music",
  "voice",
  "component",
  "html",
  "diagram",
  "document",
  "svg",
  "style_guide",
] as const;
export type AssetType = (typeof ASSET_TYPES)[number];
export const ASSET_STATUSES = ["draft", "generating", "review", "published", "archived"] as const;
export type AssetStatus = (typeof ASSET_STATUSES)[number];

export interface AssetEntry {
  id: string;
  organization_id: string;
  project_id?: string | null;
  slug: string;
  title: string;
  asset_type: AssetType | string;
  status: AssetStatus | string;
  quality?: string | null;
  prompt_yaml: string;
  tags?: string[];
  product_targets?: string[];
  active_output_id?: string | null;
  inserted_at?: string;
  updated_at?: string;
}

export interface AssetEntryInput {
  slug?: string;
  title?: string;
  asset_type?: AssetType | string;
  status?: AssetStatus | string;
  quality?: string | null;
  prompt_yaml?: string;
  tags?: string[];
  product_targets?: string[];
  project_id?: string | null;
}

export interface AssetOutput {
  id: string;
  entry_id: string;
  artifact_id?: string | null;
  provider?: string | null;
  model?: string | null;
  variant_number: number;
  eval_score?: number | null;
  eval_status: string;
  status: string;
  inserted_at?: string;
}

export interface AssetHistory {
  id: string;
  action: string;
  actor?: string | null;
  details?: Record<string, unknown> | null;
  inserted_at?: string;
}

// ── Personas: org-scoped (required), optional project. A persona has a journal
// (work logs, reflections, decisions, notes) and a knowledge base of articles. ──
export interface Persona {
  id: string;
  organization_id: string;
  project_id?: string | null;
  slug: string;
  name: string;
  role?: string | null;
  bio?: string | null;
  avatar?: string | null;
  tags?: string[];
  status: string;
  inserted_at?: string;
  updated_at?: string;
}

export interface PersonaInput {
  slug?: string;
  name?: string;
  role?: string | null;
  bio?: string | null;
  avatar?: string | null;
  tags?: string[];
  status?: string;
  project_id?: string | null;
}

export interface PersonaJournalEntry {
  id: string;
  category: string;
  title?: string | null;
  body: string;
  actor?: string | null;
  tags?: string[];
  inserted_at?: string;
}

export interface PersonaKnowledgeEntry {
  id: string;
  slug: string;
  title: string;
  body: string;
  tags?: string[];
  source?: string | null;
  inserted_at?: string;
  updated_at?: string;
}

// ── Instructions: org-scoped (required), optional project. Versioned prompt
// templates with declared parameters; render fills params into the body. ──
export interface InstructionParam {
  name: string;
  description?: string;
  required?: boolean;
  default?: string;
}

export interface Instruction {
  id: string;
  organization_id: string;
  project_id?: string | null;
  slug: string;
  title: string;
  description?: string | null;
  tags?: string[];
  parameters?: InstructionParam[];
  status: string;
  active_version?: number;
  inserted_at?: string;
  updated_at?: string;
}

export interface InstructionInput {
  slug?: string;
  title?: string;
  description?: string | null;
  body?: string;
  tags?: string[];
  parameters?: InstructionParam[];
  project_id?: string | null;
}

export interface InstructionVersionMeta {
  version: number;
  change_note?: string;
  inserted_at: string;
  active: boolean;
}

export interface RenderedInstruction {
  id: string;
  slug: string;
  title: string;
  version: number;
  params: Record<string, string>;
  body: string;
}

// ── Ticket field & type definitions ──
// Tri-scoped: "global" (system), "org", or "project". Resolution precedence is
// project > org > global; a more-specific scope can override or `disabled`
// (tombstone) an inherited definition. Managed by id (slug is unique per scope).
export const FIELD_TYPES = [
  "text",
  "rich_text",
  "markdown",
  "radio",
  "select",
  "multi_select",
  "number",
  "date",
  "persona",
  "url",
] as const;
export type FieldType = (typeof FIELD_TYPES)[number];

export type DefinitionScope = "global" | "org" | "project";

export interface FieldDefinition {
  id: string;
  scope: DefinitionScope;
  organization_id?: string | null;
  project_id?: string | null;
  slug: string;
  label: string;
  field_type: string;
  options?: Record<string, unknown> | null;
  default_value?: string | null;
  description?: string | null;
  disabled: boolean;
  inserted_at?: string;
  updated_at?: string;
}

export interface FieldDefinitionInput {
  slug?: string;
  label?: string;
  field_type?: string;
  options?: Record<string, unknown> | null;
  default_value?: string | null;
  description?: string | null;
  disabled?: boolean;
  // Only on create: "org" (default) or "project" (with project_id).
  scope?: "org" | "project";
  project_id?: string | null;
}

export interface TypeFieldAssignment {
  id: string;
  slug: string;
  label?: string;
  field_type?: string;
  required: boolean;
  position?: number;
}

export interface TypeDefinition {
  id: string;
  scope: DefinitionScope;
  organization_id?: string | null;
  project_id?: string | null;
  slug: string;
  name: string;
  description?: string | null;
  icon?: string | null;
  status_workflow?: Record<string, unknown> | null;
  disabled: boolean;
  fields?: TypeFieldAssignment[];
  inserted_at?: string;
  updated_at?: string;
}

export interface TypeDefinitionInput {
  slug?: string;
  name?: string;
  description?: string | null;
  icon?: string | null;
  status_workflow?: Record<string, unknown> | null;
  disabled?: boolean;
  // Field assignments reference field-definition ids.
  fields?: { id: string; required: boolean }[];
  // Only on create: "org" (default) or "project" (with project_id).
  scope?: "org" | "project";
  project_id?: string | null;
}

// ── Wiki: spaces, pages, comments, attachments, reactions ──
// Spaces bind to an organization (required); project is optional. Pages live
// in a space and may nest. Comments/attachments/reactions hang off pages;
// reactions are polymorphic over pages and comments.
export interface WikiSpace {
  id: string;
  organization_id: string;
  project_id?: string | null;
  slug: string;
  name: string;
  description?: string | null;
  inserted_at?: string;
  updated_at?: string;
}

export interface WikiSpaceInput {
  name: string;
  slug?: string;
  description?: string | null;
  project_id?: string | null;
}

export interface WikiPageSummary {
  id: string;
  space_id: string;
  parent_id?: string | null;
  slug: string;
  title: string;
  position?: number;
  updated_at?: string;
}

export interface WikiPage extends WikiPageSummary {
  content?: string | null;
  inserted_at?: string;
  // Present on show responses.
  comments?: WikiComment[];
  attachments?: WikiAttachment[];
  reactions?: WikiReaction[];
}

export interface WikiPageInput {
  title: string;
  slug?: string;
  content?: string | null;
  parent_id?: string | null;
  position?: number;
}

export interface WikiComment {
  id: string;
  page_id: string;
  parent_id?: string | null;
  author?: string | null;
  body: string;
  inserted_at?: string;
}

export interface WikiAttachment {
  id: string;
  page_id: string;
  filename: string;
  mime_type?: string | null;
  url?: string | null;
  byte_size?: number | null;
  inserted_at?: string;
}

export interface WikiReaction {
  id: string;
  target_type: "page" | "comment";
  target_id: string;
  emoji: string;
  actor: string;
  inserted_at?: string;
}

// ── NPL (Noizu Prompt Lingua) conventions ──
export interface NplSection {
  section: string;
  name: string;
  slug: string;
  title: string;
  brief: string;
  description: string;
  component_count: number;
  category_count: number;
}

export interface NplConventionSummary {
  section: string;
  name: string;
  slug: string;
  friendly_name: string | null;
  brief: string;
  labels: string[];
  category: string | null;
}

export interface NplSyntaxEntry {
  name: string;
  syntax: string;
  description: string;
}

export interface NplExample {
  name: string;
  brief: string;
  description: string;
  priority: number;
  example: string;
  thread: { role: string; message: string }[];
  labels: string[];
  covers: string[];
}

export interface NplConventionDetail extends NplConventionSummary {
  description: string;
  purpose: string;
  syntax: NplSyntaxEntry[];
  examples: NplExample[];
  require: string[];
}

export interface NplLabelCategory {
  name: string;
  description?: string;
  required?: boolean;
  labels?: { name: string; description?: string }[];
}

export interface NplLabelTaxonomy {
  description?: string;
  categories?: NplLabelCategory[];
}

export interface NplSpecInput {
  components?: { spec: string; component_priority?: number; example_priority?: number }[];
  rendered?: { spec: string; component_priority?: number; example_priority?: number }[];
  component_priority?: number;
  example_priority?: number;
  extension?: boolean;
  concise?: boolean;
  xml?: boolean;
}

// ── Unicode Codex ──
export interface UnicodeLayerRef {
  id: string;
  slug: string;
  scope: 'global' | 'organization' | 'project';
  organization_id: string | null;
  project_id: string | null;
}

export interface UnicodeSpecialUsageRef {
  slug: string;
  title: string;
  scope: string;
}

export interface UnicodeEscapeForms {
  codepoint?: string;
  unicode?: string[];
  hex?: string[];
  html?: string[];
}

export interface UnicodeElement {
  id: string;
  scope: 'global' | 'organization' | 'project';
  organization_id: string | null;
  project_id: string | null;
  slug: string;
  codepoint: string | null;
  codepoint_int: number | null;
  char: string | null;
  name: string;
  title: string;
  description: string | null;
  meaning: string | null;
  printable: boolean;
  visibility: string;
  unicode: Record<string, unknown>;
  flags: string[];
  topics: string[];
  sentiments: string[];
  aliases: string[];
  search_terms: string[];
  display: string;
  copy_value: string | null;
  escape_forms: UnicodeEscapeForms;
  warnings: string[];
  special_usages: UnicodeSpecialUsageRef[];
  special_usage_count: number;
  overrides: UnicodeLayerRef[];
  shadowed_by: UnicodeLayerRef | null;
  relations?: UnicodeRelation[];
}

export interface UnicodeSpecialUsage {
  id: string;
  scope: 'global' | 'organization' | 'project';
  organization_id: string | null;
  project_id: string | null;
  slug: string;
  name: string;
  title: string;
  description: string | null;
  references: { type?: string; ref?: string; [key: string]: unknown }[];
  flags: string[];
  topics: string[];
  overrides: UnicodeLayerRef[];
  shadowed_by: UnicodeLayerRef | null;
}

export interface UnicodeRelation {
  id?: string;
  relation_type: string;
  description: string | null;
  metadata: Record<string, unknown>;
  target: UnicodeElement;
}

export interface UnicodeElementListParams {
  projectId?: string | null;
  q?: string;
  topic?: string;
  flag?: string;
  usage?: string;
  printable?: boolean | null;
  includeShadowed?: boolean;
  limit?: number;
  offset?: number;
}

export interface UnicodeSpecialUsageListParams {
  projectId?: string | null;
  q?: string;
  topic?: string;
  flag?: string;
  includeShadowed?: boolean;
}

// ── Agent memory (read-only browser) ──
// The memory engine is scoped to an "agent" within an organization. An agent is
// one of: a persona, the org-level "weego" overseer, or a team member addressed
// by call sign. Memories carry four facets (content/context/reflection/tangent),
// an emotional state (VAD = valence/arousal/dominance), neurotransmitter levels,
// and recall-tuning signals (salience/decay/recall_count).
export type MemoryScopeType = "persona" | "weego" | "team_member";

export interface MemoryAgent {
  scope_type: MemoryScopeType;
  scope_id: string;
  // The agent's URL slug — used to address it in the memory API path.
  slug: string;
  label: string;
  call_sign?: string;
}

// A mood point in valence-arousal-dominance space (each roughly -1..1).
export interface MemoryMood {
  valence: number;
  arousal: number;
  dominance: number;
}

export interface Memory {
  id: string;
  content: string;
  context?: string | null;
  reflection?: string | null;
  tangent?: string | null;
  summary?: string | null;
  domain?: string | null;
  topic?: string | null;
  content_type?: string | null;
  occurred_at?: string | null;
  // Emotional state (VAD).
  valence: number;
  arousal: number;
  dominance: number;
  // Neurotransmitter levels.
  cortisol: number;
  dopamine: number;
  oxytocin: number;
  serotonin: number;
  // Recall-tuning signals.
  salience: number;
  decay_weight: number;
  recall_count: number;
  // Present on recall responses — how strongly the memory matched the query.
  resonance?: number | null;
}

export type MemoryEdgeType =
  | "association"
  | "causal"
  | "contradiction"
  | "elaboration"
  | "temporal"
  | string;

export interface MemoryEdge {
  id: string;
  source_memory_id: string;
  target_memory_id: string;
  edge_type: MemoryEdgeType;
  weight: number;
  reason?: string | null;
}

interface AuthResponse {
  user: User;
  access_token: string;
  refresh_token: string;
  organizations?: Organization[];
}

interface MagicLinkResponse {
  message: string;
  dev_link?: string;
}

interface OtpResponse {
  message: string;
  dev_code?: string;
}

let refreshPromise: Promise<string | null> | null = null;

async function attemptRefresh(): Promise<string | null> {
  const refreshToken = typeof window !== "undefined" ? localStorage.getItem("refresh_token") : null;
  if (!refreshToken) return null;

  try {
    const res = await fetch(`${API_URL}/api/v1/auth/refresh`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refresh_token: refreshToken }),
    });

    if (!res.ok) return null;

    const data = await res.json();
    if (data.access_token) {
      localStorage.setItem("access_token", data.access_token);
      if (data.refresh_token) {
        localStorage.setItem("refresh_token", data.refresh_token);
      }
      // Sync cookie for middleware
      document.cookie = `access_token=${data.access_token}; path=/; max-age=${AUTH_COOKIE_MAX_AGE_SEC}; SameSite=Lax${cookieDomainAttribute()}`;
      return data.access_token;
    }
    return null;
  } catch {
    return null;
  }
}

async function request<T>(path: string, options: RequestInit = {}): Promise<T> {
  const token = typeof window !== "undefined" ? localStorage.getItem("access_token") : null;

  const res = await fetch(`${API_URL}${path}`, {
    ...options,
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...options.headers,
    },
  });

  if (res.status === 401 && token && !path.includes("/auth/refresh")) {
    // Deduplicate concurrent refresh attempts
    if (!refreshPromise) {
      refreshPromise = attemptRefresh().finally(() => { refreshPromise = null; });
    }

    const newToken = await refreshPromise;
    if (newToken) {
      // Retry the original request with the new token
      const retryRes = await fetch(`${API_URL}${path}`, {
        ...options,
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${newToken}`,
          ...options.headers,
        },
      });

      if (!retryRes.ok) {
        const body = await retryRes.json().catch(() => ({}));
        throw new Error(body.error || body.errors?.email?.[0] || `Request failed: ${retryRes.status}`);
      }

      return retryRes.json();
    }

    // Refresh failed — clear tokens and redirect to login
    localStorage.removeItem("access_token");
    localStorage.removeItem("refresh_token");
    document.cookie = `access_token=; path=/; max-age=0; SameSite=Lax${cookieDomainAttribute()}`;
    if (typeof window !== "undefined") {
      window.location.href = "/login";
    }
  }

  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new Error(body.error || body.errors?.email?.[0] || `Request failed: ${res.status}`);
  }

  return res.json();
}

// ── Mock MCP: LLM-driven pseudo MCP servers (org-scoped) ──
export type MockMCPStatus = "draft" | "active" | "archived";

export interface MockMCPToolDef {
  name: string;
  description?: string;
  inputSchema?: Record<string, unknown>;
  // Private response/format spec — owner-facing only, stripped from the MCP
  // gateway before clients see it.
  handler?: string;
}

export interface MockMCPResourceDef {
  uri: string;
  name?: string;
  description?: string;
  mimeType?: string;
  handler?: string;
}

export interface MockMCPPromptArg {
  name: string;
  description?: string;
  required?: boolean;
}

export interface MockMCPPromptDef {
  name: string;
  description?: string;
  arguments?: MockMCPPromptArg[];
  handler?: string;
}

// An org-scoped, reusable LLM connection. The api key is never returned —
// `api_key_set` reports whether one is stored.
export interface MockMCPLLM {
  id: string;
  label: string;
  provider: string;
  model: string;
  endpoint?: string | null;
  api_key_set?: boolean;
  created_at?: string;
  updated_at?: string;
}

export interface MockMCPLLMInput {
  label: string;
  provider: string;
  model: string;
  endpoint?: string;
  api_key?: string;
}

export interface MockMCPDefinition {
  id: string;
  slug: string;
  title: string;
  prompt: string;
  status: MockMCPStatus | string;
  tools_json: MockMCPToolDef[];
  resources_json?: MockMCPResourceDef[];
  prompts_json?: MockMCPPromptDef[];
  schema_sql?: string | null;
  active_llm_id?: string | null;
  active_llm?: MockMCPLLM | null;
  organization_id?: string;
  db_name?: string | null;
  db_provisioned?: boolean;
  created_by?: string | null;
  project_id?: string | null;
  tool_count?: number;
  resource_count?: number;
  prompt_count?: number;
  created_at?: string;
  updated_at?: string;
}

export interface MockMCPInput {
  slug: string;
  title: string;
  prompt: string;
  active_llm_id?: string | null;
  project_id?: string | null;
  auto_generate_tools?: boolean;
}

// Curated provider/model quick-pick for the "new LLM connection" form.
export interface MockMCPModel {
  id: string;
  label: string;
  provider: string;
  model: string;
}

// ── Admin: editable LLM model catalog (global) ──
export interface LlmModel {
  id: string;
  provider: string;
  model: string;
  label: string;
  endpoint?: string | null;
  enabled: boolean;
  sort_order: number;
  notes?: string | null;
  inserted_at?: string;
}

export interface LlmModelInput {
  provider: string;
  model: string;
  label: string;
  endpoint?: string | null;
  enabled?: boolean;
  sort_order?: number;
  notes?: string | null;
}

// ── Admin: per-org media provider config ──
export interface MediaProviderRegistryEntry {
  slug: string;
  label: string;
  modality: string;
  env_var: string;
  env_key_set: boolean;
}

export interface MediaProviderConfig {
  id: string;
  provider: string;
  modality: string;
  enabled: boolean;
  api_key_set: boolean;
  endpoint?: string | null;
  default_model?: string | null;
  settings?: Record<string, unknown>;
  inserted_at?: string;
}

export interface MediaProviderConfigInput {
  provider: string;
  modality?: string;
  enabled?: boolean;
  api_key?: string;
  endpoint?: string | null;
  default_model?: string | null;
  settings?: Record<string, unknown>;
}

export interface MockMCPCallLog {
  id: string;
  method: string;
  tool_name?: string | null;
  arguments?: Record<string, unknown> | null;
  response?: Record<string, unknown> | null;
  latency_ms?: number | null;
  error?: string | null;
  at?: string;
}

// One internal data-op the agent ran while fulfilling a request.
export interface MockMCPTraceEntry {
  op: string;
  args?: Record<string, unknown>;
  result?: unknown;
  error?: string;
}

export interface MockMCPContentBlock {
  type: string;
  text?: string;
  [k: string]: unknown;
}

export interface MockMCPInvokeResult {
  content: MockMCPContentBlock[];
  trace: MockMCPTraceEntry[];
  latency_ms: number;
}

export interface MockMCPDbResult {
  columns: string[];
  rows: unknown[][];
}

export interface MockMCPRedisEntry {
  key: string;
  value: string | null;
}

// Shared list-query serializer (ticket 3c2d6bbe). Scalars -> `key=v`; arrays ->
// repeated BRACKET params `key[]=v1&key[]=v2` (Phoenix/Plug parses to a list ->
// WHERE col = ANY(...), OR-within-facet), matching the locked BE shape (marcus
// seq578 / aniket seq575). Empty strings, empty arrays, and null/undefined are
// omitted. Centralized so every list method serializes multi-select facets the
// same way (no per-method drift).
function buildQuery(params: Record<string, string | string[] | number | undefined | null>): string {
  const qs = new URLSearchParams();
  for (const [key, value] of Object.entries(params)) {
    if (value == null) continue;
    if (Array.isArray(value)) {
      for (const v of value) if (v != null && v !== '') qs.append(`${key}[]`, String(v));
    } else if (value !== '') {
      qs.set(key, String(value));
    }
  }
  const s = qs.toString();
  return s ? `?${s}` : '';
}

export const api = {
  login(email: string, password: string) {
    return request<AuthResponse>("/api/v1/auth/login", {
      method: "POST",
      body: JSON.stringify({ email, password }),
    });
  },

  requestMagicLink(email: string) {
    return request<MagicLinkResponse>("/api/v1/auth/magic-link", {
      method: "POST",
      body: JSON.stringify({ email }),
    });
  },

  verifyMagicLink(token: string) {
    return request<AuthResponse>("/api/v1/auth/magic-link/verify", {
      method: "POST",
      body: JSON.stringify({ token }),
    });
  },

  requestOtpLogin(email: string) {
    return request<OtpResponse>("/api/v1/auth/otp-login", {
      method: "POST",
      body: JSON.stringify({ email }),
    });
  },

  verifyOtpLogin(email: string, code: string) {
    return request<AuthResponse>("/api/v1/auth/otp-login/verify", {
      method: "POST",
      body: JSON.stringify({ email, code }),
    });
  },

  refresh(refreshToken: string) {
    return request<{ access_token: string; refresh_token?: string }>("/api/v1/auth/refresh", {
      method: "POST",
      body: JSON.stringify({ refresh_token: refreshToken }),
    });
  },

  ssoProviders() {
    return request<{ providers: string[] }>("/api/v1/auth/sso/providers");
  },

  ssoExchange(code: string) {
    return request<AuthResponse>("/api/v1/auth/sso/exchange", {
      method: "POST",
      body: JSON.stringify({ code }),
    });
  },

  getRegistration(token: string) {
    return request<{ email: string; provider: string }>(`/api/v1/auth/sso/registration?token=${encodeURIComponent(token)}`);
  },

  ssoRegister(payload: { token: string; first: string; last: string; bio: string }) {
    return request<AuthResponse>("/api/v1/auth/sso/register", {
      method: "POST",
      body: JSON.stringify(payload),
    });
  },

  me() {
    return request<{ user: User }>("/api/v1/auth/me");
  },

  getProfile() {
    return request<{ user: User }>("/api/v1/users/me");
  },

  updateProfile(data: { user_name?: string; email?: string; bio?: string; role?: string }) {
    return request<{ user: User }>("/api/v1/users/me", {
      method: "PATCH",
      body: JSON.stringify({ user: data }),
    });
  },

  listOrganizations() {
    return request<{ organizations: Organization[] }>("/api/v1/organizations");
  },

  createOrganization(slug: string, name: string) {
    return request<{ organization: Organization }>("/api/v1/organizations", {
      method: "POST",
      body: JSON.stringify({ organization: { slug, name } }),
    });
  },

  getOrganization(id: string) {
    return request<{ organization: Organization }>(`/api/v1/organizations/${id}`);
  },

  updateOrganization(id: string, data: { name?: string; slug?: string }) {
    return request<{ organization: Organization }>(`/api/v1/organizations/${id}`, {
      method: "PUT",
      body: JSON.stringify({ organization: data }),
    });
  },

  deleteOrganization(id: string) {
    return request<{ message: string }>(`/api/v1/organizations/${id}`, {
      method: "DELETE",
    });
  },

  sendVerificationEmail() {
    return request<{ message: string; dev_link?: string }>("/api/v1/auth/verify-email", {
      method: "POST",
    });
  },

  verifyEmail(token: string) {
    return request<{ message: string }>("/api/v1/auth/verify-email/confirm", {
      method: "POST",
      body: JSON.stringify({ token }),
    });
  },

  // PBAC members list (ticket 4a9aa9d9): rows carry member_type, target role, scope
  // (resource_type/id), and the caller's effective_role (16dc3df2). Optional role
  // facet -> ?role[]=admin&role[]=lead (ANY). agents appear here later (ccaf5684).
  // READ via the viewer-gated /memberships path (aniket seq713); WRITES (add/update/
  // remove below) use the admin /organizations/:org/members path.
  listMembers(orgId: string, opts?: { role?: string | string[] }) {
    return request<{ members: OrgMember[] }>(
      `/api/v1/memberships/organizations/${orgId}${buildQuery({ role: opts?.role })}`,
    );
  },

  getMember(orgId: string, id: string) {
    return request<{ member: OrgMember }>(`/api/v1/memberships/organizations/${orgId}/members/${id}`);
  },

  addMember(orgId: string, email: string, role: string) {
    return request<{ members: OrgMember[] }>(`/api/v1/organizations/${orgId}/members`, {
      method: "POST",
      body: JSON.stringify({ email, role }),
    });
  },

  updateMemberRole(orgId: string, memberId: string, role: string) {
    return request<{ members: OrgMember[] }>(`/api/v1/organizations/${orgId}/members/${memberId}`, {
      method: "PATCH",
      body: JSON.stringify({ role }),
    });
  },

  removeMember(orgId: string, memberId: string) {
    return request<{ message: string }>(`/api/v1/organizations/${orgId}/members/${memberId}`, {
      method: "DELETE",
    });
  },

  presignUpload(filename: string, contentType: string) {
    return request<{ upload_url: string; key: string }>("/api/v1/media/presign", {
      method: "POST",
      body: JSON.stringify({ filename, content_type: contentType }),
    });
  },

  getDownloadUrl(key: string) {
    return request<{ download_url: string }>("/api/v1/media/download", {
      method: "POST",
      body: JSON.stringify({ key }),
    });
  },

  adminListUsers(page = 1, perPage = 50) {
    return request<{ users: Array<{ id: string; email: string; user_name: string; status: string; verified: boolean; role: string; created_at: string }>; total: number; page: number; per_page: number }>(`/api/v1/admin/users?page=${page}&per_page=${perPage}`);
  },

  adminShowUser(id: string) {
    return request<{ user: User & { role: string; created_at: string } }>(`/api/v1/admin/users/${id}`);
  },

  adminUpdateUserRole(id: string, role: string) {
    return request<{ user: { id: string; email: string; user_name: string; status: string; verified: boolean; role: string; created_at: string } }>(`/api/v1/admin/users/${id}`, {
      method: "PATCH",
      body: JSON.stringify({ user: { role } }),
    });
  },

  adminListOrganizations(page = 1, perPage = 50) {
    return request<{ organizations: Array<{ id: string; slug: string; name: string; created_at: string }>; total: number; page: number; per_page: number }>(`/api/v1/admin/organizations?page=${page}&per_page=${perPage}`);
  },

  adminShowOrganization(id: string) {
    return request<{ organization: { id: string; slug: string; name: string; created_at: string }; members: Array<{ id: string; email: string; role: string }> }>(`/api/v1/admin/organizations/${id}`);
  },

  // ── GitHub integration (admin, org-scoped). Tokens are returned masked only. ──
  adminListGithubTokens(orgId: string) {
    return request<{ tokens: GithubToken[] }>(`/api/v1/admin/organizations/${orgId}/github/tokens`);
  },

  adminCreateGithubToken(orgId: string, label: string, token: string) {
    return request<{ token: GithubToken }>(`/api/v1/admin/organizations/${orgId}/github/tokens`, {
      method: "POST",
      body: JSON.stringify({ token: { label, token } }),
    });
  },

  adminDeleteGithubToken(orgId: string, id: string) {
    return request<{ message: string }>(`/api/v1/admin/organizations/${orgId}/github/tokens/${id}`, {
      method: "DELETE",
    });
  },

  adminListGithubRepos(orgId: string) {
    return request<{ repos: GithubRepo[] }>(`/api/v1/admin/organizations/${orgId}/github/repos`);
  },

  adminCreateGithubRepo(orgId: string, repo_full_name: string, token_id: string | null, default_acl: RepoAcl = "private") {
    return request<{ repo: GithubRepo }>(`/api/v1/admin/organizations/${orgId}/github/repos`, {
      method: "POST",
      body: JSON.stringify({ repo: { repo_full_name, token_id, default_acl } }),
    });
  },

  adminUpdateGithubRepo(orgId: string, id: string, patch: { token_id?: string | null; default_acl?: RepoAcl }) {
    return request<{ repo: GithubRepo }>(`/api/v1/admin/organizations/${orgId}/github/repos/${id}`, {
      method: "PATCH",
      body: JSON.stringify({ repo: patch }),
    });
  },

  adminDeleteGithubRepo(orgId: string, id: string) {
    return request<{ message: string }>(`/api/v1/admin/organizations/${orgId}/github/repos/${id}`, {
      method: "DELETE",
    });
  },

  adminListGithubRepoGrants(orgId: string, repoId: string) {
    return request<{ grants: GithubRepoGrant[] }>(`/api/v1/admin/organizations/${orgId}/github/repos/${repoId}/grants`);
  },

  adminGrantGithubRepoAccess(orgId: string, repoId: string, group_id: string, level: RepoGrantLevel) {
    return request<{ grants: GithubRepoGrant[] }>(`/api/v1/admin/organizations/${orgId}/github/repos/${repoId}/grants`, {
      method: "POST",
      body: JSON.stringify({ group_id, level }),
    });
  },

  adminRevokeGithubRepoAccess(orgId: string, repoId: string, grantId: string) {
    return request<{ message: string }>(`/api/v1/admin/organizations/${orgId}/github/repos/${repoId}/grants/${grantId}`, {
      method: "DELETE",
    });
  },

  // ── LLM model catalog (admin, global). Drives the Mock MCP picker / ListModels. ──
  adminListLlmModels() {
    return request<{ models: LlmModel[] }>(`/api/v1/admin/llm-models`);
  },

  adminCreateLlmModel(model: LlmModelInput) {
    return request<{ model: LlmModel }>(`/api/v1/admin/llm-models`, {
      method: "POST",
      body: JSON.stringify({ model }),
    });
  },

  adminUpdateLlmModel(id: string, patch: Partial<LlmModelInput>) {
    return request<{ model: LlmModel }>(`/api/v1/admin/llm-models/${id}`, {
      method: "PATCH",
      body: JSON.stringify({ model: patch }),
    });
  },

  adminDeleteLlmModel(id: string) {
    return request<{ message: string }>(`/api/v1/admin/llm-models/${id}`, {
      method: "DELETE",
    });
  },

  // ── LLM provider introspection (admin). Fetch models and test configuration. ───
  adminFetchProviderModels(provider: string) {
    return request<{ models: string[]; provider: string }>(`/api/v1/admin/llm-providers/${provider}/models`);
  },

  adminTestLlmConfiguration(provider: string, model: string, endpoint?: string) {
    return request<{ valid: boolean; result?: any; error?: string }>(`/api/v1/admin/llm-providers/${provider}/test`, {
      method: "POST",
      body: JSON.stringify({ model, endpoint }),
    });
  },

  // ── Media provider config (admin, org-scoped). api_key returned masked only. ──
  adminListMediaProviders(orgId: string) {
    return request<{ registry: MediaProviderRegistryEntry[]; configs: MediaProviderConfig[] }>(
      `/api/v1/admin/organizations/${orgId}/media-providers`,
    );
  },

  adminCreateMediaProvider(orgId: string, config: MediaProviderConfigInput) {
    return request<{ config: MediaProviderConfig }>(`/api/v1/admin/organizations/${orgId}/media-providers`, {
      method: "POST",
      body: JSON.stringify({ config }),
    });
  },

  adminUpdateMediaProvider(orgId: string, id: string, patch: Partial<MediaProviderConfigInput>) {
    return request<{ config: MediaProviderConfig }>(`/api/v1/admin/organizations/${orgId}/media-providers/${id}`, {
      method: "PATCH",
      body: JSON.stringify({ config: patch }),
    });
  },

  adminDeleteMediaProvider(orgId: string, id: string) {
    return request<{ message: string }>(`/api/v1/admin/organizations/${orgId}/media-providers/${id}`, {
      method: "DELETE",
    });
  },

  // ── GitHub operations (org-scoped, ACL-checked, proxied to GitHub API) ───
  listGithubRepos(orgId: string) {
    return request<{ repos: GithubRepoSummary[]; count: number }>(
      `/api/v1/organizations/${orgId}/github`,
    );
  },

  listGithubPulls(
    orgId: string,
    repoId: string,
    opts?: { state?: "open" | "closed" | "all"; page?: number; per_page?: number },
  ) {
    const qs = new URLSearchParams(
      Object.entries(opts ?? {}).filter(([, v]) => v != null).map(([k, v]) => [k, String(v)]),
    );
    const suffix = qs.toString() ? `?${qs.toString()}` : "";
    return request<{ items: GithubPullRequest[]; links?: Record<string, string> } | GithubPullRequest[]>(
      `/api/v1/organizations/${orgId}/github/repos/${repoId}/pulls${suffix}`,
    );
  },

  getGithubPull(orgId: string, repoId: string, pullNumber: number) {
    return request<GithubPullRequest>(
      `/api/v1/organizations/${orgId}/github/repos/${repoId}/pulls/${pullNumber}`,
    );
  },

  createGithubPull(
    orgId: string,
    repoId: string,
    data: { title: string; head: string; base: string; body?: string },
  ) {
    return request<GithubPullRequest>(
      `/api/v1/organizations/${orgId}/github/repos/${repoId}/pulls`,
      { method: "POST", body: JSON.stringify({ pull: data }) },
    );
  },

  mergeGithubPull(
    orgId: string,
    repoId: string,
    pullNumber: number,
    data?: { commit_title?: string; commit_message?: string; merge_method?: "merge" | "squash" | "rebase" },
  ) {
    return request<{ sha?: string | null; merged: boolean; message: string }>(
      `/api/v1/organizations/${orgId}/github/repos/${repoId}/pulls/${pullNumber}/merge`,
      { method: "PUT", body: JSON.stringify({ pull: data ?? {} }) },
    );
  },

  listGithubPullComments(orgId: string, repoId: string, pullNumber: number, opts?: { page?: number }) {
    const qs = new URLSearchParams(
      Object.entries(opts ?? {}).filter(([, v]) => v != null).map(([k, v]) => [k, String(v)]),
    );
    const suffix = qs.toString() ? `?${qs.toString()}` : "";
    return request<{ items: GithubComment[]; links?: Record<string, string> } | GithubComment[]>(
      `/api/v1/organizations/${orgId}/github/repos/${repoId}/pulls/${pullNumber}/comments${suffix}`,
    );
  },

  createGithubPullComment(orgId: string, repoId: string, pullNumber: number, body: string) {
    return request<GithubComment>(
      `/api/v1/organizations/${orgId}/github/repos/${repoId}/pulls/${pullNumber}/comments`,
      { method: "POST", body: JSON.stringify({ comment: { body } }) },
    );
  },

  listGithubIssues(
    orgId: string,
    repoId: string,
    opts?: { state?: "open" | "closed" | "all"; page?: number; per_page?: number },
  ) {
    const qs = new URLSearchParams(
      Object.entries(opts ?? {}).filter(([, v]) => v != null).map(([k, v]) => [k, String(v)]),
    );
    const suffix = qs.toString() ? `?${qs.toString()}` : "";
    return request<{ items: GithubIssue[]; links?: Record<string, string> } | GithubIssue[]>(
      `/api/v1/organizations/${orgId}/github/repos/${repoId}/issues${suffix}`,
    );
  },

  getGithubIssue(orgId: string, repoId: string, issueNumber: number) {
    return request<GithubIssue>(
      `/api/v1/organizations/${orgId}/github/repos/${repoId}/issues/${issueNumber}`,
    );
  },

  createGithubIssue(
    orgId: string,
    repoId: string,
    data: { title: string; body?: string; labels?: string[]; assignees?: string[] },
  ) {
    return request<GithubIssue>(
      `/api/v1/organizations/${orgId}/github/repos/${repoId}/issues`,
      { method: "POST", body: JSON.stringify({ issue: data }) },
    );
  },

  createGithubIssueComment(orgId: string, repoId: string, issueNumber: number, body: string) {
    return request<GithubComment>(
      `/api/v1/organizations/${orgId}/github/repos/${repoId}/issues/${issueNumber}/comments`,
      { method: "POST", body: JSON.stringify({ comment: { body } }) },
    );
  },

  listGithubBranches(orgId: string, repoId: string, opts?: { page?: number }) {
    const qs = new URLSearchParams(
      Object.entries(opts ?? {}).filter(([, v]) => v != null).map(([k, v]) => [k, String(v)]),
    );
    const suffix = qs.toString() ? `?${qs.toString()}` : "";
    return request<{ items: GithubBranch[] } | GithubBranch[]>(
      `/api/v1/organizations/${orgId}/github/repos/${repoId}/branches${suffix}`,
    );
  },

  createGithubBranch(orgId: string, repoId: string, name: string, fromSha: string) {
    return request<{ ref: string; node_id?: string; object?: { sha: string; url?: string } }>(
      `/api/v1/organizations/${orgId}/github/repos/${repoId}/branches`,
      { method: "POST", body: JSON.stringify({ branch: { name, from_sha: fromSha } }) },
    );
  },

  // Groups for grant UI (PBAC groups list)
  listGroups() {
    return request<{ groups: Array<{ id: string; name: string; display_name?: string | null }> }>("/api/v1/groups");
  },

  // ── MCP API keys (admin, user-scoped). raw_key returned only at creation. ──
  adminListMcpKeys(userId: string) {
    return request<{ keys: McpApiKey[] }>(`/api/v1/admin/users/${userId}/mcp-keys`);
  },

  adminCreateMcpKey(userId: string, label = "default", expiresAt?: string) {
    return request<{ key: McpApiKey; raw_key: string }>(`/api/v1/admin/users/${userId}/mcp-keys`, {
      method: "POST",
      body: JSON.stringify({ key: { label, expires_at: expiresAt } }),
    });
  },

  adminRevokeMcpKey(userId: string, id: string) {
    return request<{ key: McpApiKey }>(`/api/v1/admin/users/${userId}/mcp-keys/${id}`, {
      method: "DELETE",
    });
  },

  // ── OAuth clients (admin, global). DCR-registered + first-party. ──
  adminListOAuthClients() {
    return request<{ clients: OAuthClient[] }>("/api/v1/admin/oauth-clients");
  },

  adminRevokeOAuthClient(clientId: string) {
    return request<{ client: OAuthClient }>(`/api/v1/admin/oauth-clients/${encodeURIComponent(clientId)}`, {
      method: "DELETE",
    });
  },

  // ── Custom MCP include scopes (admin, global). ──
  adminMcpCustomScopeCatalog() {
    return request<{ groups: McpCustomGroup[] }>("/api/v1/admin/mcp-custom-scopes/catalog");
  },

  adminListMcpCustomScopes() {
    return request<{ scopes: McpCustomScope[] }>("/api/v1/admin/mcp-custom-scopes");
  },

  adminGetMcpCustomScope(slug: string) {
    return request<{ scope: McpCustomScope }>(`/api/v1/admin/mcp-custom-scopes/${slug}`);
  },

  adminCreateMcpCustomScope(scope: McpCustomScopeInput) {
    return request<{ scope: McpCustomScope }>("/api/v1/admin/mcp-custom-scopes", {
      method: "POST",
      body: JSON.stringify({ scope }),
    });
  },

  adminUpdateMcpCustomScope(slug: string, patch: Partial<McpCustomScopeInput>) {
    return request<{ scope: McpCustomScope }>(`/api/v1/admin/mcp-custom-scopes/${slug}`, {
      method: "PATCH",
      body: JSON.stringify({ scope: patch }),
    });
  },

  adminDeleteMcpCustomScope(slug: string) {
    return request<{ message: string }>(`/api/v1/admin/mcp-custom-scopes/${slug}`, {
      method: "DELETE",
    });
  },

  adminUserDefaultMcp(userId: string) {
    return request<{
      scope: McpCustomScope;
      servers: McpServerConfig[];
      ala_carte: McpServerConfig[];
    }>(`/api/v1/admin/users/${userId}/mcp-default-endpoint`);
  },

  /** Org usage dashboard aggregates (counts, daily/weekly series, attention). */
  getOrgDashboardStats(orgId: string, opts?: { range?: 7 | 14 | 30 }) {
    const suffix = buildQuery({ range: opts?.range });
    return request<{ stats: OrgDashboardStats }>(
      `/api/v1/organizations/${orgId}/dashboard/stats${suffix}`,
    );
  },

  listProjects(orgId: string) {
    return request<{ projects: Project[] }>(`/api/v1/organizations/${orgId}/projects`);
  },

  getProject(orgId: string, id: string) {
    return request<{ project: Project }>(`/api/v1/organizations/${orgId}/projects/${id}`);
  },

  createProject(orgId: string, project: ProjectInput) {
    return request<{ project: Project }>(`/api/v1/organizations/${orgId}/projects`, {
      method: "POST",
      body: JSON.stringify({ project }),
    });
  },

  updateProject(orgId: string, id: string, project: Partial<ProjectInput>) {
    return request<{ project: Project }>(`/api/v1/organizations/${orgId}/projects/${id}`, {
      method: "PUT",
      body: JSON.stringify({ project }),
    });
  },

  archiveProject(orgId: string, id: string) {
    return request<{ project: Project }>(`/api/v1/organizations/${orgId}/projects/${id}/archive`, {
      method: "POST",
    });
  },

  unarchiveProject(orgId: string, id: string) {
    return request<{ project: Project }>(`/api/v1/organizations/${orgId}/projects/${id}/unarchive`, {
      method: "POST",
    });
  },

  deleteProject(orgId: string, id: string) {
    return request<{ message: string }>(`/api/v1/organizations/${orgId}/projects/${id}`, {
      method: "DELETE",
    });
  },

  prepareVoiceApprovalScript(orgId: string, input: { transcript: string; title?: string; ticket_type?: string; description?: string; project_id?: string }) {
    return request<VoiceApprovalScriptResponse>(`/api/v1/organizations/${orgId}/assistant/approval-script`, {
      method: "POST",
      body: JSON.stringify(input),
    });
  },

  listSessions(orgId: string, opts?: { status?: string | string[]; projectId?: string }) {
    const suffix = buildQuery({ status: opts?.status, project_id: opts?.projectId });
    return request<{ sessions: Session[] }>(`/api/v1/organizations/${orgId}/sessions${suffix}`);
  },

  getSession(orgId: string, id: string) {
    return request<{ session: Session }>(`/api/v1/organizations/${orgId}/sessions/${id}`);
  },

  createSession(orgId: string, session: SessionInput) {
    return request<{ session: Session }>(`/api/v1/organizations/${orgId}/sessions`, {
      method: "POST",
      body: JSON.stringify({ session }),
    });
  },

  updateSession(orgId: string, id: string, session: Partial<SessionInput>) {
    return request<{ session: Session }>(`/api/v1/organizations/${orgId}/sessions/${id}`, {
      method: "PUT",
      body: JSON.stringify({ session }),
    });
  },

  archiveSession(orgId: string, id: string) {
    return request<{ session: Session }>(`/api/v1/organizations/${orgId}/sessions/${id}/archive`, {
      method: "POST",
    });
  },

  unarchiveSession(orgId: string, id: string) {
    return request<{ session: Session }>(`/api/v1/organizations/${orgId}/sessions/${id}/unarchive`, {
      method: "POST",
    });
  },

  deleteSession(orgId: string, id: string) {
    return request<{ message: string }>(`/api/v1/organizations/${orgId}/sessions/${id}`, {
      method: "DELETE",
    });
  },

  // ── Chat rooms (org-scoped, optional project) ──
  listChatRooms(orgId: string, opts?: { projectId?: string; sessionId?: string }) {
    const suffix = buildQuery({ project_id: opts?.projectId, session_id: opts?.sessionId });
    return request<{ rooms: ChatRoom[] }>(`/api/v1/organizations/${orgId}/chat/rooms${suffix}`);
  },
  getChatRoom(orgId: string, id: string) {
    return request<{ room: ChatRoom }>(`/api/v1/organizations/${orgId}/chat/rooms/${id}`);
  },
  createChatRoom(orgId: string, room: ChatRoomInput) {
    return request<{ room: ChatRoom }>(`/api/v1/organizations/${orgId}/chat/rooms`, {
      method: "POST",
      body: JSON.stringify({ room }),
    });
  },
  // Edit name/description only — slug is an immutable alias (ADR-013); the BE
  // update_changeset casts name+description only, ignoring any other field (aniket 0c93ddd4).
  updateChatRoom(orgId: string, id: string, room: { name?: string; description?: string }) {
    return request<{ room: ChatRoom }>(`/api/v1/organizations/${orgId}/chat/rooms/${id}`, {
      method: "PUT",
      body: JSON.stringify({ room }),
    });
  },

  // ── Chat messages + reactions (epic ffc795c5) ──
  // Built to marcus-dev's FINAL BE contract (seq124/144): messages carry
  // content/sender and EMBED grouped reaction summaries [{emoji,count,me}] with a
  // server-computed `me` — so the list renders pills with no N+1. All three reaction
  // endpoints (GET/POST/DELETE) return the same regrouped {reactions:[…]} shape, so
  // a write reconciles the optimistic UI to server truth in one round-trip.
  // Messages list (ascending/chrono); before/after are ISO-8601 cursors.
  listChatMessages(
    orgId: string,
    roomId: string,
    // include_replies=true returns the FLAT list (all messages incl. thread replies).
    // Default (omitted) the BE returns top-level only (Slack channel view) once 054
    // threading ships — the flat room view passes true so replies don't vanish (aniket seq629).
    opts?: { before?: string; after?: string; limit?: number; include_replies?: boolean },
  ) {
    const qs = new URLSearchParams();
    if (opts?.before) qs.set("before", opts.before);
    if (opts?.after) qs.set("after", opts.after);
    if (opts?.limit) qs.set("limit", String(opts.limit));
    if (opts?.include_replies) qs.set("include_replies", "true");
    const suffix = qs.toString() ? `?${qs.toString()}` : "";
    return request<{ messages: ChatMessage[] }>(
      `/api/v1/organizations/${orgId}/chat/rooms/${roomId}/messages${suffix}`,
    );
  },
  createChatMessage(orgId: string, roomId: string, message: { content: string; sender?: string }) {
    return request<{ message: ChatMessage }>(
      `/api/v1/organizations/${orgId}/chat/rooms/${roomId}/messages`,
      { method: "POST", body: JSON.stringify({ message }) },
    );
  },
  // All three return the regrouped per-message summary [{emoji,count,me}] (marcus
  // seq144). Callers can apply the returned `reactions` directly as server truth.
  listMessageReactions(orgId: string, roomId: string, messageId: string) {
    return request<{ reactions: ChatReactionSummary[] }>(
      `/api/v1/organizations/${orgId}/chat/rooms/${roomId}/messages/${messageId}/reactions`,
    );
  },
  addMessageReaction(orgId: string, roomId: string, messageId: string, emoji: string) {
    return request<{ reactions: ChatReactionSummary[] }>(
      `/api/v1/organizations/${orgId}/chat/rooms/${roomId}/messages/${messageId}/reactions`,
      { method: "POST", body: JSON.stringify({ emoji }) },
    );
  },
  removeMessageReaction(orgId: string, roomId: string, messageId: string, emoji: string) {
    return request<{ reactions: ChatReactionSummary[] }>(
      `/api/v1/organizations/${orgId}/chat/rooms/${roomId}/messages/${messageId}/reactions`,
      { method: "DELETE", body: JSON.stringify({ emoji }) },
    );
  },

  // ── Artifacts (org-scoped, optional project) ──
  listArtifacts(orgId: string, opts?: { projectId?: string; kind?: string | string[]; search?: string }) {
    const suffix = buildQuery({ project_id: opts?.projectId, kind: opts?.kind, search: opts?.search });
    return request<{ artifacts: Artifact[] }>(`/api/v1/organizations/${orgId}/artifacts${suffix}`);
  },
  getArtifact(orgId: string, id: string, revisionId?: string) {
    const suffix = revisionId ? `?revision_id=${revisionId}` : "";
    return request<{ artifact: Artifact }>(`/api/v1/organizations/${orgId}/artifacts/${id}${suffix}`);
  },
  createArtifact(orgId: string, artifact: ArtifactInput) {
    return request<{ artifact: Artifact }>(`/api/v1/organizations/${orgId}/artifacts`, {
      method: "POST",
      body: JSON.stringify({ artifact }),
    });
  },
  // Edit = append a new revision (aniket c0f97e6b/693842f9): history-preserving, not a
  // destructive PUT. Returns the new current revision as the artifact.
  addArtifactRevision(orgId: string, id: string, body: { content: string; note?: string }) {
    return request<{ artifact: Artifact }>(`/api/v1/organizations/${orgId}/artifacts/${id}/revisions`, {
      method: "POST",
      body: JSON.stringify(body),
    });
  },

  // ── Reviews (org-scoped, optional project) ──
  listReviews(orgId: string, opts?: { projectId?: string; artifactId?: string; status?: string | string[] }) {
    const suffix = buildQuery({ project_id: opts?.projectId, artifact_id: opts?.artifactId, status: opts?.status });
    return request<{ reviews: Review[] }>(`/api/v1/organizations/${orgId}/reviews${suffix}`);
  },
  getReview(orgId: string, id: string) {
    return request<{ review: Review; comments: unknown[]; overlays: unknown[] }>(
      `/api/v1/organizations/${orgId}/reviews/${id}`,
    );
  },
  createReview(orgId: string, review: ReviewInput) {
    return request<{ review: Review }>(`/api/v1/organizations/${orgId}/reviews`, {
      method: "POST",
      body: JSON.stringify({ review }),
    });
  },
  // Edit a non-completed review (soren f73f4cd2). Immutable fields (artifact/revision/
  // org/project) are ignored; status only open|in_progress here (complete via the
  // dedicated endpoint); verdict ∈ approved|changes_requested|rejected|null.
  updateReview(
    orgId: string,
    id: string,
    review: { title?: string; reviewer_persona?: string; summary?: string; verdict?: string | null; status?: string },
  ) {
    return request<{ review: Review }>(`/api/v1/organizations/${orgId}/reviews/${id}`, {
      method: "PUT",
      body: JSON.stringify({ review }),
    });
  },
  completeReview(orgId: string, id: string, body?: { summary?: string; verdict?: string }) {
    return request<{ review: Review }>(`/api/v1/organizations/${orgId}/reviews/${id}/complete`, {
      method: "POST",
      body: JSON.stringify(body ?? {}),
    });
  },

  // ── Tickets / tasks (org-scoped, optional project) ──
  listTickets(
    orgId: string,
    opts?: {
      projectId?: string;
      // Facetable filters accept a single value OR an array (multi-select -> ANY, 3c2d6bbe).
      status?: string | string[];
      ticketType?: string | string[];
      priority?: string | string[];
      assignee?: string | string[];
      queueId?: string;
      parentId?: string;
      stageId?: string;
      iterationId?: string;
    },
  ) {
    const suffix = buildQuery({
      project_id: opts?.projectId,
      parent_id: opts?.parentId,
      status: opts?.status,
      ticket_type: opts?.ticketType,
      priority: opts?.priority,
      assignee: opts?.assignee,
      queue_id: opts?.queueId,
      stage_id: opts?.stageId,
      iteration_id: opts?.iterationId,
    });
    return request<{ tickets: Ticket[] }>(`/api/v1/organizations/${orgId}/tickets${suffix}`);
  },
  getTicket(orgId: string, id: string) {
    return request<{ ticket: Ticket; links: unknown }>(`/api/v1/organizations/${orgId}/tickets/${id}`);
  },
  createTicket(orgId: string, ticket: TicketInput) {
    return request<{ ticket: Ticket }>(`/api/v1/organizations/${orgId}/tickets`, {
      method: "POST",
      body: JSON.stringify({ ticket }),
    });
  },
  updateTicket(orgId: string, id: string, ticket: Partial<TicketInput>) {
    return request<{ ticket: Ticket }>(`/api/v1/organizations/${orgId}/tickets/${id}`, {
      method: "PUT",
      body: JSON.stringify({ ticket }),
    });
  },

  // ── Boards + stages + iterations ──
  listBoards(orgId: string, opts?: { projectId?: string }) {
    const suffix = opts?.projectId ? `?project_id=${opts.projectId}` : "";
    return request<{ boards: Board[]; methodologies: string[] }>(`/api/v1/organizations/${orgId}/boards${suffix}`);
  },
  getBoard(orgId: string, id: string) {
    return request<{ board: Board }>(`/api/v1/organizations/${orgId}/boards/${id}`);
  },
  createBoard(orgId: string, board: BoardInput) {
    return request<{ board: Board }>(`/api/v1/organizations/${orgId}/boards`, {
      method: "POST",
      body: JSON.stringify({ board }),
    });
  },
  updateBoard(orgId: string, id: string, board: Partial<BoardInput> & { config?: Record<string, unknown> }) {
    return request<{ board: Board }>(`/api/v1/organizations/${orgId}/boards/${id}`, {
      method: "PUT",
      body: JSON.stringify({ board }),
    });
  },
  deleteBoard(orgId: string, id: string) {
    return request<{ message: string }>(`/api/v1/organizations/${orgId}/boards/${id}`, { method: "DELETE" });
  },
  addBoardStage(orgId: string, boardId: string, stage: StageInput) {
    return request<{ stage: BoardStage }>(`/api/v1/organizations/${orgId}/boards/${boardId}/stages`, {
      method: "POST",
      body: JSON.stringify({ stage }),
    });
  },
  updateBoardStage(orgId: string, boardId: string, stageId: string, stage: StageInput) {
    return request<{ stage: BoardStage }>(`/api/v1/organizations/${orgId}/boards/${boardId}/stages/${stageId}`, {
      method: "PUT",
      body: JSON.stringify({ stage }),
    });
  },
  deleteBoardStage(orgId: string, boardId: string, stageId: string) {
    return request<{ message: string }>(`/api/v1/organizations/${orgId}/boards/${boardId}/stages/${stageId}`, {
      method: "DELETE",
    });
  },
  addBoardIteration(orgId: string, boardId: string, iteration: IterationInput) {
    return request<{ iteration: BoardIteration }>(`/api/v1/organizations/${orgId}/boards/${boardId}/iterations`, {
      method: "POST",
      body: JSON.stringify({ iteration }),
    });
  },
  updateBoardIteration(orgId: string, boardId: string, iterationId: string, iteration: IterationInput) {
    return request<{ iteration: BoardIteration }>(
      `/api/v1/organizations/${orgId}/boards/${boardId}/iterations/${iterationId}`,
      { method: "PUT", body: JSON.stringify({ iteration }) },
    );
  },
  deleteBoardIteration(orgId: string, boardId: string, iterationId: string) {
    return request<{ message: string }>(`/api/v1/organizations/${orgId}/boards/${boardId}/iterations/${iterationId}`, {
      method: "DELETE",
    });
  },

  // ── Assets (media-prompt entries + generated outputs) ──
  listAssets(orgId: string, opts?: { projectId?: string; assetType?: string | string[]; status?: string | string[]; tag?: string | string[] }) {
    const suffix = buildQuery({ project_id: opts?.projectId, asset_type: opts?.assetType, status: opts?.status, tag: opts?.tag });
    return request<{ assets: AssetEntry[]; asset_types: string[]; statuses: string[] }>(
      `/api/v1/organizations/${orgId}/assets${suffix}`,
    );
  },
  getAsset(orgId: string, id: string) {
    return request<{ asset: AssetEntry; outputs: AssetOutput[] }>(`/api/v1/organizations/${orgId}/assets/${id}`);
  },
  createAsset(orgId: string, asset: AssetEntryInput) {
    return request<{ asset: AssetEntry }>(`/api/v1/organizations/${orgId}/assets`, {
      method: "POST",
      body: JSON.stringify({ asset }),
    });
  },
  updateAsset(orgId: string, id: string, asset: Partial<AssetEntryInput>) {
    return request<{ asset: AssetEntry }>(`/api/v1/organizations/${orgId}/assets/${id}`, {
      method: "PUT",
      body: JSON.stringify({ asset }),
    });
  },
  deleteAsset(orgId: string, id: string) {
    return request<{ message: string }>(`/api/v1/organizations/${orgId}/assets/${id}`, { method: "DELETE" });
  },
  listAssetOutputs(orgId: string, assetId: string) {
    return request<{ outputs: AssetOutput[] }>(`/api/v1/organizations/${orgId}/assets/${assetId}/outputs`);
  },
  generateAsset(orgId: string, assetId: string, body?: { provider?: string; model?: string; content?: string }) {
    return request<{ output: AssetOutput }>(`/api/v1/organizations/${orgId}/assets/${assetId}/generate`, {
      method: "POST",
      body: JSON.stringify(body ?? {}),
    });
  },
  listAssetHistory(orgId: string, assetId: string) {
    return request<{ history: AssetHistory[] }>(`/api/v1/organizations/${orgId}/assets/${assetId}/history`);
  },
  acceptAssetOutput(orgId: string, assetId: string, outputId: string) {
    return request<{ output: AssetOutput }>(
      `/api/v1/organizations/${orgId}/assets/${assetId}/outputs/${outputId}/accept`,
      { method: "POST" },
    );
  },
  rejectAssetOutput(orgId: string, assetId: string, outputId: string) {
    return request<{ output: AssetOutput }>(
      `/api/v1/organizations/${orgId}/assets/${assetId}/outputs/${outputId}/reject`,
      { method: "POST" },
    );
  },
  setActiveAssetOutput(orgId: string, assetId: string, outputId: string) {
    return request<{ asset: AssetEntry }>(`/api/v1/organizations/${orgId}/assets/${assetId}/active`, {
      method: "POST",
      body: JSON.stringify({ output_id: outputId }),
    });
  },

  // ── Ticket field definitions (tri-scoped; managed by id) ──
  listFieldDefinitions(orgId: string, opts?: { projectId?: string }) {
    const suffix = opts?.projectId ? `?project_id=${opts.projectId}` : "";
    return request<{ field_definitions: FieldDefinition[]; field_types: string[] }>(
      `/api/v1/organizations/${orgId}/ticket-field-definitions${suffix}`,
    );
  },
  createFieldDefinition(orgId: string, field_definition: FieldDefinitionInput) {
    return request<{ field_definition: FieldDefinition }>(
      `/api/v1/organizations/${orgId}/ticket-field-definitions`,
      { method: "POST", body: JSON.stringify({ field_definition }) },
    );
  },
  updateFieldDefinition(orgId: string, id: string, field_definition: FieldDefinitionInput) {
    return request<{ field_definition: FieldDefinition }>(
      `/api/v1/organizations/${orgId}/ticket-field-definitions/${id}`,
      { method: "PUT", body: JSON.stringify({ field_definition }) },
    );
  },
  deleteFieldDefinition(orgId: string, id: string) {
    return request<{ message: string }>(`/api/v1/organizations/${orgId}/ticket-field-definitions/${id}`, {
      method: "DELETE",
    });
  },

  // ── Ticket type definitions (tri-scoped; managed by id) ──
  listTypeDefinitions(orgId: string, opts?: { projectId?: string }) {
    const suffix = opts?.projectId ? `?project_id=${opts.projectId}` : "";
    return request<{ type_definitions: TypeDefinition[] }>(
      `/api/v1/organizations/${orgId}/ticket-type-definitions${suffix}`,
    );
  },
  getTypeDefinition(orgId: string, id: string) {
    return request<{ type_definition: TypeDefinition }>(
      `/api/v1/organizations/${orgId}/ticket-type-definitions/${id}`,
    );
  },
  createTypeDefinition(orgId: string, type_definition: TypeDefinitionInput) {
    return request<{ type_definition: TypeDefinition }>(
      `/api/v1/organizations/${orgId}/ticket-type-definitions`,
      { method: "POST", body: JSON.stringify({ type_definition }) },
    );
  },
  updateTypeDefinition(orgId: string, id: string, type_definition: TypeDefinitionInput) {
    return request<{ type_definition: TypeDefinition }>(
      `/api/v1/organizations/${orgId}/ticket-type-definitions/${id}`,
      { method: "PUT", body: JSON.stringify({ type_definition }) },
    );
  },
  deleteTypeDefinition(orgId: string, id: string) {
    return request<{ message: string }>(`/api/v1/organizations/${orgId}/ticket-type-definitions/${id}`, {
      method: "DELETE",
    });
  },

  getFeatureFlags() {
    return request<{ features: string[] }>("/api/v1/config/features");
  },

  // ── MCP API keys (user-scoped). raw_key returned only at creation. ──
  listMcpKeys() {
    return request<{ keys: McpApiKey[] }>("/api/v1/auth/mcp-keys");
  },

  createMcpKey(label = "default", expiresAt?: string) {
    return request<{ key: McpApiKey; raw_key: string }>("/api/v1/auth/mcp-keys", {
      method: "POST",
      body: JSON.stringify({ key: { label, expires_at: expiresAt } }),
    });
  },

  /** One-step: create a key and mint the JWT used by `mcp add` commands. */
  createMcpSetupKey(label = "default", opts?: { expiresAt?: string; resource?: string }) {
    return request<{
      key: McpApiKey;
      raw_key: string;
      token: string;
      expires_at: string;
      token_type?: string;
      expires_in?: number;
    }>("/api/v1/auth/mcp-keys/setup", {
      method: "POST",
      body: JSON.stringify({
        key: { label, expires_at: opts?.expiresAt },
        resource: opts?.resource,
      }),
    });
  },

  revokeMcpKey(id: string) {
    return request<{ key: McpApiKey }>(`/api/v1/auth/mcp-keys/${id}`, {
      method: "DELETE",
    });
  },

  // ── MCP token minter (rate-limited, no auth required). ──
  // Use for non-browser clients that present a raw key directly.
  mintMcpToken(rawKey: string) {
    return request<McpTokenResponse>("/api/mcp/token", {
      method: "POST",
      body: JSON.stringify({ key: rawKey }),
    });
  },

  // ── MCP token minter (authenticated, ownership-checked). ──
  // For logged-in users pasting an existing raw key — verifies the key belongs
  // to the caller before minting. Use this from the browser, not mintMcpToken.
  mintMcpTokenAuthenticated(rawKey: string) {
    return request<McpTokenResponse>("/api/v1/auth/mcp/token", {
      method: "POST",
      body: JSON.stringify({ key: rawKey }),
    });
  },

  // ── MCP connection config (host + server list with full URLs). ──
  mcpConfig(opts?: { packaging?: string }) {
    const q = opts?.packaging
      ? `?packaging=${encodeURIComponent(opts.packaging)}`
      : "";
    return request<McpConfigResponse>(`/api/v1/auth/mcp/config${q}`);
  },

  mcpCatalog() {
    return request<{ groups: McpCustomGroup[] }>("/api/v1/auth/mcp/catalog");
  },

  getDefaultMcpEndpoint() {
    return request<{ scope: McpCustomScope }>("/api/v1/auth/mcp/default-endpoint");
  },

  updateDefaultMcpEndpoint(config: McpCustomScopeConfig) {
    return request<{ scope: McpCustomScope }>("/api/v1/auth/mcp/default-endpoint", {
      method: "PATCH",
      body: JSON.stringify({ scope: { config } }),
    });
  },

  listMcpEndpoints() {
    return request<McpEndpointsResponse>("/api/v1/auth/mcp/endpoints");
  },

  getMcpEndpoint(id: string) {
    return request<{ endpoint: McpCustomScope }>(`/api/v1/auth/mcp/endpoints/${id}`);
  },

  createMcpEndpoint(input: {
    source_id?: string;
    source_slug?: string;
    name?: string;
    description?: string;
    organization_id?: string;
    use?: boolean;
  }) {
    return request<{ endpoint: McpCustomScope }>("/api/v1/auth/mcp/endpoints", {
      method: "POST",
      body: JSON.stringify({ endpoint: input }),
    });
  },

  updateMcpEndpoint(
    id: string,
    patch: Partial<{ name: string; description: string; config: McpCustomScopeConfig; use: boolean; confirm: string }>,
  ) {
    return request<{ endpoint: McpCustomScope; scope: McpCustomScope }>(
      `/api/v1/auth/mcp/endpoints/${id}`,
      {
        method: "PATCH",
        body: JSON.stringify({ endpoint: patch }),
      },
    );
  },

  copyMcpEndpoint(id: string, input?: { name?: string; organization_id?: string; use?: boolean }) {
    return request<{ endpoint: McpCustomScope }>(`/api/v1/auth/mcp/endpoints/${id}/copy`, {
      method: "POST",
      body: JSON.stringify({ endpoint: input ?? {} }),
    });
  },

  useMcpEndpoint(id: string) {
    return request<{ endpoint: McpCustomScope }>(`/api/v1/auth/mcp/endpoints/${id}/use`, {
      method: "POST",
    });
  },

  deleteMcpEndpoint(id: string) {
    return request<{ ok: boolean; id: string }>(`/api/v1/auth/mcp/endpoints/${id}`, {
      method: "DELETE",
    });
  },

  // ── OAuth MCP pairing grants (Phase 4). ──
  listMcpConnections() {
    return request<{ connections: McpOAuthConnection[] }>("/api/v1/auth/mcp/connections");
  },

  revokeMcpConnection(grantId: string) {
    return request<{ ok: boolean; grant_id: string; status: string }>(
      `/api/v1/auth/mcp/connections/${encodeURIComponent(grantId)}`,
      { method: "DELETE" }
    );
  },

  // ── Local Tools MCP download (public, no auth). Absolute URL so a plain
  // anchor triggers a browser download of the tarball. ──
  localMcpDownloadUrl() {
    return `${API_URL}/api/v1/config/local-mcp/download`;
  },

  // ── Browser controller (org-scoped headless browser agent) ──
  // Absolute URL so a plain anchor triggers a browser download of the tarball.
  browserControllerDownloadUrl() {
    return `${API_URL}/api/v1/config/browser-controller/download`;
  },

  // Whether a controller is currently connected for this org.
  browserStatus(orgId: string) {
    return request<{ connected: boolean }>(`/api/v1/organizations/${orgId}/browser/status`);
  },

  // Recent captures (screenshots / recordings). `url` is a relative `/media/<short_id>`
  // path — build absolute media URLs in the page as `${API_URL}${capture.url}`.
  browserCaptures(orgId: string) {
    return request<{ captures: BrowserCapture[] }>(`/api/v1/organizations/${orgId}/browser/captures`);
  },

  // ── Wiki ──
  listWikiSpaces(orgId: string, opts?: { projectId?: string; search?: string }) {
    const suffix = buildQuery({ project_id: opts?.projectId, search: opts?.search });
    return request<{ spaces: WikiSpace[] }>(`/api/v1/organizations/${orgId}/wiki/spaces${suffix}`);
  },

  getWikiSpace(orgId: string, id: string) {
    return request<{ space: WikiSpace; pages: WikiPageSummary[] }>(
      `/api/v1/organizations/${orgId}/wiki/spaces/${id}`,
    );
  },

  createWikiSpace(orgId: string, space: WikiSpaceInput) {
    return request<{ space: WikiSpace }>(`/api/v1/organizations/${orgId}/wiki/spaces`, {
      method: "POST",
      body: JSON.stringify({ space }),
    });
  },

  updateWikiSpace(orgId: string, id: string, space: Partial<WikiSpaceInput>) {
    return request<{ space: WikiSpace }>(`/api/v1/organizations/${orgId}/wiki/spaces/${id}`, {
      method: "PUT",
      body: JSON.stringify({ space }),
    });
  },

  deleteWikiSpace(orgId: string, id: string) {
    return request<{ message: string }>(`/api/v1/organizations/${orgId}/wiki/spaces/${id}`, {
      method: "DELETE",
    });
  },

  listWikiPages(orgId: string, spaceId: string, opts?: { search?: string }) {
    const qs = opts?.search ? `?search=${encodeURIComponent(opts.search)}` : "";
    return request<{ pages: WikiPageSummary[] }>(
      `/api/v1/organizations/${orgId}/wiki/spaces/${spaceId}/pages${qs}`,
    );
  },

  getWikiPage(orgId: string, id: string) {
    return request<{ page: WikiPage }>(`/api/v1/organizations/${orgId}/wiki/pages/${id}`);
  },

  createWikiPage(orgId: string, spaceId: string, page: WikiPageInput) {
    return request<{ page: WikiPage }>(
      `/api/v1/organizations/${orgId}/wiki/spaces/${spaceId}/pages`,
      { method: "POST", body: JSON.stringify({ page }) },
    );
  },

  updateWikiPage(orgId: string, id: string, page: Partial<WikiPageInput>) {
    return request<{ page: WikiPage }>(`/api/v1/organizations/${orgId}/wiki/pages/${id}`, {
      method: "PUT",
      body: JSON.stringify({ page }),
    });
  },

  deleteWikiPage(orgId: string, id: string) {
    return request<{ message: string }>(`/api/v1/organizations/${orgId}/wiki/pages/${id}`, {
      method: "DELETE",
    });
  },

  listWikiComments(orgId: string, pageId: string) {
    return request<{ comments: WikiComment[] }>(
      `/api/v1/organizations/${orgId}/wiki/pages/${pageId}/comments`,
    );
  },

  createWikiComment(orgId: string, pageId: string, comment: { body: string; parent_id?: string | null; author?: string }) {
    return request<{ comment: WikiComment }>(
      `/api/v1/organizations/${orgId}/wiki/pages/${pageId}/comments`,
      { method: "POST", body: JSON.stringify({ comment }) },
    );
  },

  deleteWikiComment(orgId: string, id: string) {
    return request<{ message: string }>(`/api/v1/organizations/${orgId}/wiki/comments/${id}`, {
      method: "DELETE",
    });
  },

  listWikiAttachments(orgId: string, pageId: string) {
    return request<{ attachments: WikiAttachment[] }>(
      `/api/v1/organizations/${orgId}/wiki/pages/${pageId}/attachments`,
    );
  },

  createWikiAttachment(
    orgId: string,
    pageId: string,
    attachment: { filename: string; url?: string; mime_type?: string; byte_size?: number },
  ) {
    return request<{ attachment: WikiAttachment }>(
      `/api/v1/organizations/${orgId}/wiki/pages/${pageId}/attachments`,
      { method: "POST", body: JSON.stringify({ attachment }) },
    );
  },

  deleteWikiAttachment(orgId: string, id: string) {
    return request<{ message: string }>(`/api/v1/organizations/${orgId}/wiki/attachments/${id}`, {
      method: "DELETE",
    });
  },

  addWikiPageReaction(orgId: string, pageId: string, emoji: string) {
    return request<{ reaction: WikiReaction }>(
      `/api/v1/organizations/${orgId}/wiki/pages/${pageId}/reactions`,
      { method: "POST", body: JSON.stringify({ emoji }) },
    );
  },

  removeWikiPageReaction(orgId: string, pageId: string, emoji: string) {
    return request<{ message: string }>(
      `/api/v1/organizations/${orgId}/wiki/pages/${pageId}/reactions`,
      { method: "DELETE", body: JSON.stringify({ emoji }) },
    );
  },

  addWikiCommentReaction(orgId: string, commentId: string, emoji: string) {
    return request<{ reaction: WikiReaction }>(
      `/api/v1/organizations/${orgId}/wiki/comments/${commentId}/reactions`,
      { method: "POST", body: JSON.stringify({ emoji }) },
    );
  },

  removeWikiCommentReaction(orgId: string, commentId: string, emoji: string) {
    return request<{ message: string }>(
      `/api/v1/organizations/${orgId}/wiki/comments/${commentId}/reactions`,
      { method: "DELETE", body: JSON.stringify({ emoji }) },
    );
  },

  // ── NPL conventions reference data (read-only) ──
  listNplSections() {
    return request<{ sections: NplSection[] }>("/api/v1/npl/sections");
  },

  listNplConventions(section?: string) {
    const qs = section ? `?section=${encodeURIComponent(section)}` : "";
    return request<{ conventions: NplConventionSummary[]; count: number }>(
      `/api/v1/npl/conventions${qs}`,
    );
  },

  getNplConvention(section: string, slug: string) {
    return request<{ convention: NplConventionDetail }>(
      `/api/v1/npl/conventions/${encodeURIComponent(section)}/${encodeURIComponent(slug)}`,
    );
  },

  listNplLabels() {
    return request<{ labels: NplLabelTaxonomy }>("/api/v1/npl/labels");
  },

  generateNplSpec(input: NplSpecInput) {
    return request<{ spec: string; length: number }>("/api/v1/npl/spec", {
      method: "POST",
      body: JSON.stringify(input),
    });
  },

  // ── Unicode Codex reference data (layered global/org/project) ──
  listUnicodeElements(orgId: string, opts: UnicodeElementListParams = {}) {
    const qs = new URLSearchParams();
    if (opts.projectId) qs.set("project_id", opts.projectId);
    if (opts.q) qs.set("q", opts.q);
    if (opts.topic) qs.set("topic", opts.topic);
    if (opts.flag) qs.set("flag", opts.flag);
    if (opts.usage) qs.set("usage", opts.usage);
    if (opts.printable !== undefined && opts.printable !== null) qs.set("printable", String(opts.printable));
    if (opts.includeShadowed) qs.set("include_shadowed", "true");
    if (opts.limit) qs.set("limit", String(opts.limit));
    if (opts.offset) qs.set("offset", String(opts.offset));
    const suffix = qs.toString() ? `?${qs.toString()}` : "";
    return request<{ elements: UnicodeElement[]; count: number }>(
      `/api/v1/organizations/${orgId}/unicode/elements${suffix}`,
    );
  },

  getUnicodeElement(orgId: string, slug: string, opts: { projectId?: string | null } = {}) {
    const qs = new URLSearchParams();
    if (opts.projectId) qs.set("project_id", opts.projectId);
    const suffix = qs.toString() ? `?${qs.toString()}` : "";
    return request<{ element: UnicodeElement; layers: UnicodeElement[] }>(
      `/api/v1/organizations/${orgId}/unicode/elements/${encodeURIComponent(slug)}${suffix}`,
    );
  },

  listUnicodeSpecialUsages(orgId: string, opts: UnicodeSpecialUsageListParams = {}) {
    const qs = new URLSearchParams();
    if (opts.projectId) qs.set("project_id", opts.projectId);
    if (opts.q) qs.set("q", opts.q);
    if (opts.topic) qs.set("topic", opts.topic);
    if (opts.flag) qs.set("flag", opts.flag);
    if (opts.includeShadowed) qs.set("include_shadowed", "true");
    const suffix = qs.toString() ? `?${qs.toString()}` : "";
    return request<{ special_usages: UnicodeSpecialUsage[]; count: number }>(
      `/api/v1/organizations/${orgId}/unicode/special-usages${suffix}`,
    );
  },

  getUnicodeSpecialUsage(orgId: string, slug: string, opts: { projectId?: string | null } = {}) {
    const qs = new URLSearchParams();
    if (opts.projectId) qs.set("project_id", opts.projectId);
    const suffix = qs.toString() ? `?${qs.toString()}` : "";
    return request<{ special_usage: UnicodeSpecialUsage; layers: UnicodeSpecialUsage[] }>(
      `/api/v1/organizations/${orgId}/unicode/special-usages/${encodeURIComponent(slug)}${suffix}`,
    );
  },

  // ── Mock MCP (org-scoped) ──
  listMockMcp(orgId: string, opts?: { status?: string; projectId?: string }) {
    const qs = new URLSearchParams();
    if (opts?.status) qs.set("status", opts.status);
    if (opts?.projectId) qs.set("project_id", opts.projectId);
    const suffix = qs.toString() ? `?${qs.toString()}` : "";
    return request<{ definitions: MockMCPDefinition[] }>(
      `/api/v1/organizations/${orgId}/mock-mcp${suffix}`,
    );
  },
  getMockMcp(orgId: string, slug: string) {
    return request<{ definition: MockMCPDefinition }>(
      `/api/v1/organizations/${orgId}/mock-mcp/${slug}`,
    );
  },
  createMockMcp(orgId: string, definition: MockMCPInput) {
    return request<{ definition: MockMCPDefinition }>(
      `/api/v1/organizations/${orgId}/mock-mcp`,
      { method: "POST", body: JSON.stringify(definition) },
    );
  },
  updateMockMcp(orgId: string, slug: string, patch: Partial<MockMCPInput> & { status?: string }) {
    return request<{ definition: MockMCPDefinition }>(
      `/api/v1/organizations/${orgId}/mock-mcp/${slug}`,
      { method: "PUT", body: JSON.stringify(patch) },
    );
  },
  deleteMockMcp(orgId: string, slug: string) {
    return request<{ deleted: boolean }>(
      `/api/v1/organizations/${orgId}/mock-mcp/${slug}`,
      { method: "DELETE" },
    );
  },
  activateMockMcp(orgId: string, slug: string) {
    return request<{ definition: MockMCPDefinition }>(
      `/api/v1/organizations/${orgId}/mock-mcp/${slug}/activate`,
      { method: "POST" },
    );
  },
  generateMockMcpTools(orgId: string, slug: string) {
    return request<{ tools: MockMCPToolDef[] }>(
      `/api/v1/organizations/${orgId}/mock-mcp/${slug}/generate-tools`,
      { method: "POST" },
    );
  },
  provisionMockMcpDb(orgId: string, slug: string) {
    return request<{ db_name: string; provisioned: boolean }>(
      `/api/v1/organizations/${orgId}/mock-mcp/${slug}/provision-db`,
      { method: "POST" },
    );
  },
  listMockMcpCalls(orgId: string, slug: string) {
    return request<{ calls: MockMCPCallLog[] }>(
      `/api/v1/organizations/${orgId}/mock-mcp/${slug}/calls`,
    );
  },
  listMockMcpModels(orgId: string) {
    return request<{ models: MockMCPModel[]; default: string }>(
      `/api/v1/organizations/${orgId}/mock-mcp-models`,
    );
  },

  // ── Mock MCP: playground + private-datastore state browser ──
  invokeMockMcpTool(orgId: string, slug: string, tool: string, args: Record<string, unknown>) {
    return request<MockMCPInvokeResult>(
      `/api/v1/organizations/${orgId}/mock-mcp/${slug}/invoke`,
      { method: "POST", body: JSON.stringify({ tool, arguments: args }) },
    );
  },
  mockMcpDbTables(orgId: string, slug: string) {
    return request<{ tables: string[] }>(
      `/api/v1/organizations/${orgId}/mock-mcp/${slug}/state/db/tables`,
    );
  },
  mockMcpDbQuery(orgId: string, slug: string, sql: string) {
    return request<MockMCPDbResult>(
      `/api/v1/organizations/${orgId}/mock-mcp/${slug}/state/db/query`,
      { method: "POST", body: JSON.stringify({ sql }) },
    );
  },
  mockMcpRedisState(orgId: string, slug: string, pattern = "*") {
    const qs = pattern && pattern !== "*" ? `?pattern=${encodeURIComponent(pattern)}` : "";
    return request<{ entries: MockMCPRedisEntry[] }>(
      `/api/v1/organizations/${orgId}/mock-mcp/${slug}/state/redis${qs}`,
    );
  },

  // ── Mock MCP: org-scoped LLM connection pool ──
  listMockMcpLlms(orgId: string) {
    return request<{ llms: MockMCPLLM[] }>(`/api/v1/organizations/${orgId}/mock-mcp-llms`);
  },
  createMockMcpLlm(orgId: string, llm: MockMCPLLMInput) {
    return request<{ llm: MockMCPLLM }>(`/api/v1/organizations/${orgId}/mock-mcp-llms`, {
      method: "POST",
      body: JSON.stringify(llm),
    });
  },
  updateMockMcpLlm(orgId: string, id: string, patch: Partial<MockMCPLLMInput>) {
    return request<{ llm: MockMCPLLM }>(`/api/v1/organizations/${orgId}/mock-mcp-llms/${id}`, {
      method: "PUT",
      body: JSON.stringify(patch),
    });
  },
  deleteMockMcpLlm(orgId: string, id: string) {
    return request<{ deleted: boolean }>(`/api/v1/organizations/${orgId}/mock-mcp-llms/${id}`, {
      method: "DELETE",
    });
  },

  // ── Personas ──
  listPersonas(orgId: string, opts?: { projectId?: string; status?: string; tag?: string }) {
    const qs = new URLSearchParams();
    if (opts?.projectId) qs.set("project_id", opts.projectId);
    if (opts?.status) qs.set("status", opts.status);
    if (opts?.tag) qs.set("tag", opts.tag);
    const suffix = qs.toString() ? `?${qs.toString()}` : "";
    return request<{ personas: Persona[]; statuses: string[] }>(
      `/api/v1/organizations/${orgId}/personas${suffix}`,
    );
  },
  getPersona(orgId: string, id: string) {
    return request<{ persona: Persona; journal: PersonaJournalEntry[]; knowledge_base: PersonaKnowledgeEntry[] }>(
      `/api/v1/organizations/${orgId}/personas/${id}`,
    );
  },
  createPersona(orgId: string, persona: PersonaInput) {
    return request<{ persona: Persona }>(`/api/v1/organizations/${orgId}/personas`, {
      method: "POST",
      body: JSON.stringify({ persona }),
    });
  },
  updatePersona(orgId: string, id: string, persona: Partial<PersonaInput>) {
    return request<{ persona: Persona }>(`/api/v1/organizations/${orgId}/personas/${id}`, {
      method: "PUT",
      body: JSON.stringify({ persona }),
    });
  },
  deletePersona(orgId: string, id: string) {
    return request<{ message: string }>(`/api/v1/organizations/${orgId}/personas/${id}`, { method: "DELETE" });
  },
  listPersonaJournal(orgId: string, personaId: string, opts?: { category?: string }) {
    const suffix = opts?.category ? `?category=${encodeURIComponent(opts.category)}` : "";
    return request<{ journal: PersonaJournalEntry[] }>(
      `/api/v1/organizations/${orgId}/personas/${personaId}/journal${suffix}`,
    );
  },
  addPersonaJournal(
    orgId: string,
    personaId: string,
    entry: { category?: string; title?: string; body: string; tags?: string[] },
  ) {
    return request<{ entry: PersonaJournalEntry }>(
      `/api/v1/organizations/${orgId}/personas/${personaId}/journal`,
      { method: "POST", body: JSON.stringify({ entry }) },
    );
  },
  deletePersonaJournal(orgId: string, personaId: string, entryId: string) {
    return request<{ message: string }>(
      `/api/v1/organizations/${orgId}/personas/${personaId}/journal/${entryId}`,
      { method: "DELETE" },
    );
  },
  listPersonaKnowledge(orgId: string, personaId: string, opts?: { tag?: string }) {
    const suffix = opts?.tag ? `?tag=${encodeURIComponent(opts.tag)}` : "";
    return request<{ knowledge_base: PersonaKnowledgeEntry[] }>(
      `/api/v1/organizations/${orgId}/personas/${personaId}/knowledge${suffix}`,
    );
  },
  addPersonaKnowledge(
    orgId: string,
    personaId: string,
    entry: { slug: string; title: string; body: string; tags?: string[]; source?: string },
  ) {
    return request<{ entry: PersonaKnowledgeEntry }>(
      `/api/v1/organizations/${orgId}/personas/${personaId}/knowledge`,
      { method: "POST", body: JSON.stringify({ entry }) },
    );
  },
  updatePersonaKnowledge(
    orgId: string,
    personaId: string,
    entryId: string,
    entry: Partial<{ slug: string; title: string; body: string; tags: string[]; source: string }>,
  ) {
    return request<{ entry: PersonaKnowledgeEntry }>(
      `/api/v1/organizations/${orgId}/personas/${personaId}/knowledge/${entryId}`,
      { method: "PUT", body: JSON.stringify({ entry }) },
    );
  },
  deletePersonaKnowledge(orgId: string, personaId: string, entryId: string) {
    return request<{ message: string }>(
      `/api/v1/organizations/${orgId}/personas/${personaId}/knowledge/${entryId}`,
      { method: "DELETE" },
    );
  },

  // ── Instructions ──
  listInstructions(orgId: string, opts?: { projectId?: string; status?: string; tag?: string; query?: string }) {
    const qs = new URLSearchParams();
    if (opts?.projectId) qs.set("project_id", opts.projectId);
    if (opts?.status) qs.set("status", opts.status);
    if (opts?.tag) qs.set("tag", opts.tag);
    if (opts?.query) qs.set("query", opts.query);
    const suffix = qs.toString() ? `?${qs.toString()}` : "";
    return request<{ instructions: Instruction[] }>(
      `/api/v1/organizations/${orgId}/instructions${suffix}`,
    );
  },
  getInstruction(orgId: string, id: string, opts?: { version?: number }) {
    const suffix = opts?.version != null ? `?version=${opts.version}` : "";
    return request<{ instruction: Instruction; version: number; body: string; versions: InstructionVersionMeta[] }>(
      `/api/v1/organizations/${orgId}/instructions/${id}${suffix}`,
    );
  },
  createInstruction(orgId: string, instruction: InstructionInput) {
    return request<{ instruction: Instruction }>(`/api/v1/organizations/${orgId}/instructions`, {
      method: "POST",
      body: JSON.stringify({ instruction }),
    });
  },
  updateInstruction(
    orgId: string,
    id: string,
    instruction: Partial<InstructionInput> & { change_note?: string },
  ) {
    return request<{ instruction: Instruction }>(`/api/v1/organizations/${orgId}/instructions/${id}`, {
      method: "PUT",
      body: JSON.stringify({ instruction }),
    });
  },
  deleteInstruction(orgId: string, id: string) {
    return request<{ message: string }>(`/api/v1/organizations/${orgId}/instructions/${id}`, { method: "DELETE" });
  },
  listInstructionVersions(orgId: string, instructionId: string) {
    return request<{ versions: InstructionVersionMeta[] }>(
      `/api/v1/organizations/${orgId}/instructions/${instructionId}/versions`,
    );
  },
  setInstructionActiveVersion(orgId: string, instructionId: string, version: number) {
    return request<{ instruction: Instruction }>(
      `/api/v1/organizations/${orgId}/instructions/${instructionId}/active-version`,
      { method: "POST", body: JSON.stringify({ version }) },
    );
  },
  renderInstruction(orgId: string, instructionId: string, params: Record<string, string>, version?: number) {
    return request<{ rendered: RenderedInstruction }>(
      `/api/v1/organizations/${orgId}/instructions/${instructionId}/render`,
      { method: "POST", body: JSON.stringify(version != null ? { params, version } : { params }) },
    );
  },

  // ── Agent memory (read-only). Org is carried in the path (slug or uuid;
  // resolved by the backend), and the agent is addressed by slug. All calls go
  // through `request` so the bearer token + refresh handling apply. ──
  listMemoryAgents(orgId: string) {
    return request<{ agents: MemoryAgent[] }>(
      `/api/organization/${encodeURIComponent(orgId)}/agents`,
    );
  },

  // Default "show all" list for an agent (no query).
  listAgentMemories(orgId: string, agentSlug: string, limit = 50) {
    return request<{ results: Memory[] }>(
      `/api/organization/${encodeURIComponent(orgId)}/agent/${encodeURIComponent(agentSlug)}/memory?limit=${limit}`,
    );
  },

  recallMemories(orgId: string, agentSlug: string, query: string, limit = 20) {
    return request<{ results: Memory[] }>(
      `/api/organization/${encodeURIComponent(orgId)}/agent/${encodeURIComponent(agentSlug)}/memory/recall`,
      {
        method: "POST",
        body: JSON.stringify({ query, limit }),
      },
    );
  },

  recallMemoriesByEmotion(orgId: string, agentSlug: string, mood: MemoryMood, limit = 20) {
    return request<{ results: Memory[] }>(
      `/api/organization/${encodeURIComponent(orgId)}/agent/${encodeURIComponent(agentSlug)}/memory/recall_by_emotion`,
      {
        method: "POST",
        body: JSON.stringify({ mood, limit }),
      },
    );
  },

  getMemoryAssociations(orgId: string, agentSlug: string, memoryId: string) {
    return request<{ edges: MemoryEdge[] }>(
      `/api/organization/${encodeURIComponent(orgId)}/agent/${encodeURIComponent(agentSlug)}/memory/${encodeURIComponent(memoryId)}/associations`,
    );
  },
};
