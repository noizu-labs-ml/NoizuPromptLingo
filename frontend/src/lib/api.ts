const API_URL = process.env.NEXT_PUBLIC_API_URL || "";

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
  owner?: string | null;
}

export interface Project {
  id: string;
  organization_id?: string;
  name: string;
  slug: string;
  description?: string | null;
  settings?: Record<string, unknown>;
  status?: string;
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
}

export interface McpConfigResponse {
  host: string;
  servers: McpServerConfig[];
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
      document.cookie = `access_token=${data.access_token}; path=/; max-age=${60 * 60}; SameSite=Lax`;
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
    document.cookie = "access_token=; path=/; max-age=0; SameSite=Lax";
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

export const api = {
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

  listMembers(orgId: string) {
    return request<{ members: Array<{ id: string; user_id: string; email: string; user_name: string; role: string; joined_at: string }> }>(`/api/v1/organizations/${orgId}/members`);
  },

  addMember(orgId: string, email: string, role: string) {
    return request<{ members: Array<{ id: string; user_id: string; email: string; user_name: string; role: string; joined_at: string }> }>(`/api/v1/organizations/${orgId}/members`, {
      method: "POST",
      body: JSON.stringify({ email, role }),
    });
  },

  updateMemberRole(orgId: string, memberId: string, role: string) {
    return request<{ members: Array<{ id: string; user_id: string; email: string; user_name: string; role: string; joined_at: string }> }>(`/api/v1/organizations/${orgId}/members/${memberId}`, {
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

  // Groups for grant UI (PBAC groups list)
  listGroups() {
    return request<{ groups: Array<{ id: string; name: string; display_name?: string | null }> }>("/api/v1/groups");
  },

  // ── MCP API keys (admin, user-scoped). raw_key returned only at creation. ──
  adminListMcpKeys(userId: string) {
    return request<{ keys: McpApiKey[] }>(`/api/v1/admin/users/${userId}/mcp-keys`);
  },

  adminCreateMcpKey(userId: string, label = "default") {
    return request<{ key: McpApiKey; raw_key: string }>(`/api/v1/admin/users/${userId}/mcp-keys`, {
      method: "POST",
      body: JSON.stringify({ key: { label } }),
    });
  },

  adminRevokeMcpKey(userId: string, id: string) {
    return request<{ key: McpApiKey }>(`/api/v1/admin/users/${userId}/mcp-keys/${id}`, {
      method: "DELETE",
    });
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

  listSessions(orgId: string, opts?: { status?: string; projectId?: string }) {
    const qs = new URLSearchParams();
    if (opts?.status) qs.set("status", opts.status);
    if (opts?.projectId) qs.set("project_id", opts.projectId);
    const suffix = qs.toString() ? `?${qs.toString()}` : "";
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
    const qs = new URLSearchParams();
    if (opts?.projectId) qs.set("project_id", opts.projectId);
    if (opts?.sessionId) qs.set("session_id", opts.sessionId);
    const suffix = qs.toString() ? `?${qs.toString()}` : "";
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

  // ── Artifacts (org-scoped, optional project) ──
  listArtifacts(orgId: string, opts?: { projectId?: string; kind?: string; search?: string }) {
    const qs = new URLSearchParams();
    if (opts?.projectId) qs.set("project_id", opts.projectId);
    if (opts?.kind) qs.set("kind", opts.kind);
    if (opts?.search) qs.set("search", opts.search);
    const suffix = qs.toString() ? `?${qs.toString()}` : "";
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

  // ── Reviews (org-scoped, optional project) ──
  listReviews(orgId: string, opts?: { projectId?: string; artifactId?: string; status?: string }) {
    const qs = new URLSearchParams();
    if (opts?.projectId) qs.set("project_id", opts.projectId);
    if (opts?.artifactId) qs.set("artifact_id", opts.artifactId);
    if (opts?.status) qs.set("status", opts.status);
    const suffix = qs.toString() ? `?${qs.toString()}` : "";
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
      status?: string;
      ticketType?: string;
      priority?: string;
      assignee?: string;
      queueId?: string;
      stageId?: string;
      iterationId?: string;
    },
  ) {
    const qs = new URLSearchParams();
    if (opts?.projectId) qs.set("project_id", opts.projectId);
    if (opts?.status) qs.set("status", opts.status);
    if (opts?.ticketType) qs.set("ticket_type", opts.ticketType);
    if (opts?.priority) qs.set("priority", opts.priority);
    if (opts?.assignee) qs.set("assignee", opts.assignee);
    if (opts?.queueId) qs.set("queue_id", opts.queueId);
    if (opts?.stageId) qs.set("stage_id", opts.stageId);
    if (opts?.iterationId) qs.set("iteration_id", opts.iterationId);
    const suffix = qs.toString() ? `?${qs.toString()}` : "";
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

  createMcpKey(label = "default") {
    return request<{ key: McpApiKey; raw_key: string }>("/api/v1/auth/mcp-keys", {
      method: "POST",
      body: JSON.stringify({ key: { label } }),
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
  mcpConfig() {
    return request<McpConfigResponse>("/api/v1/auth/mcp/config");
  },

  // ── Wiki ──
  listWikiSpaces(orgId: string, opts?: { projectId?: string; search?: string }) {
    const qs = new URLSearchParams();
    if (opts?.projectId) qs.set("project_id", opts.projectId);
    if (opts?.search) qs.set("search", opts.search);
    const suffix = qs.toString() ? `?${qs.toString()}` : "";
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
};
