'use client';

/**
 * Typed API client for ACL + per-client MCP permissions (W6/W7, D3 debt sprint).
 *
 * Backend (AdminController D3 section, all behind the admin gate):
 *  - GET   /api/v1/admin/mcp-custom-scopes/:slug/clients
 *  - GET   /api/v1/admin/mcp-custom-scopes/:slug/clients/:kind/:id/toolset_config
 *  - PUT   /api/v1/admin/mcp-custom-scopes/:slug/clients/:kind/:id/toolset_config
 *  - GET   /api/v1/admin/acl/groups
 *  - POST  /api/v1/admin/acl/groups
 *  - PATCH /api/v1/admin/acl/groups/:id
 *  - DELETE /api/v1/admin/acl/groups/:id            (soft archive)
 *  - POST   /api/v1/admin/acl/groups/:id/members    (member = ERP ref map or "type:id")
 *  - DELETE /api/v1/admin/acl/groups/:id/members    (body: {member})
 *
 * The W6 stub-phase fixture fallbacks are gone — every call hits the real API
 * and errors surface to callers. Per-client ACL *rules* are NOT persisted by
 * D3 (rule CRUD endpoints are out of scope); group membership IS.
 */

import type { McpCustomScopeConfig } from '@/lib/api';
import { canonicalToolName, normalizeConfigToolKeys } from '@/lib/tool-overrides';

// NOTE: these ACL shapes intentionally stay local (NOT re-exported from
// @/types/tool-state) — they mirror the real D3 backend payloads:
// rule subject/resource are opaque ERP ref strings (sref model, f5275922c)
// and group members carry the {ref, ref_string, expires_at} jsonb+string
// serialization. The kit's EntityRef-flavored contract in
// @/types/tool-state serves the F4 ACLEditor only, which today is fed
// empty ACL state (rule CRUD endpoints are out of D3 scope). Wire names are
// suffixed *Wire to avoid colliding with the kit's AclRule/AclGroup/AclState;
// converters between the vocabularies live in @/lib/acl-convert.

/** Backend ACL rule payload (subject/resource are opaque ERP ref strings). */
export interface AclRuleWire {
  id: string;
  subject: string;
  resource: string;
  effect: 'allow' | 'deny';
  scope: string;
}

/** An ACL group member — backend serializes ERP refs as jsonb map + string form. */
export interface AclGroupMember {
  ref: { type: string; id: string };
  ref_string: string;
  expires_at: string | null;
}

/** Backend ACL group payload, with real backend membership. */
export interface AclGroupWire {
  id: string;
  name: string;
  description?: string | null;
  status?: string;
  members: AclGroupMember[];
}

export interface AclStateWire {
  rules: AclRuleWire[];
  groups: AclGroupWire[];
}

export type ClientKind = 'api_key' | 'oauth_client';

/** A client that can hit a scope's MCP endpoint (API key or OAuth client). */
export interface ScopeClient {
  id: string;
  kind: ClientKind;
  /** Display label (key label + prefix, or OAuth client_name). */
  label: string;
  status: 'active' | 'revoked';
  inserted_at: string;
  /** No scope↔client association table exists yet — always false today. */
  linked: boolean;
}

/** F3 temporal window fields per canonical tool name (mutually exclusive). */
export type TempWindows = Record<string, { hide_until: string | null; enable_for_hours: number | null }>;

/**
 * Per-client permission bundle persisted as the client's `toolset_config`
 * jsonb (temporal windows ride the per-tool entries, F3) + ACL permission-group
 * membership. ACL rules stay local (no rule CRUD endpoints in D3).
 */
export interface ClientPermissions {
  clientId: string;
  clientKind: ClientKind;
  /** Tool restrict config — same jsonb shape as scope config ({groups:{gid:{tools:{name:{...}}}}}). */
  toolsetConfig: McpCustomScopeConfig;
  tempWindows: TempWindows;
  acl: AclStateWire;
  /** Names of ACL permission groups this client belongs to. */
  permissionGroups: string[];
}

const API_URL =
  typeof window !== 'undefined' ? '' : process.env.NEXT_PUBLIC_API_URL || '';

async function request<T>(path: string, options: RequestInit = {}): Promise<T> {
  const token = typeof window !== 'undefined' ? localStorage.getItem('access_token') : null;
  const res = await fetch(`${API_URL}${path}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...options.headers,
    },
  });
  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new Error(body.error || body.errors?.join?.(', ') || `Request failed: ${res.status}`);
  }
  return res.json();
}

// ── Clients ────────────────────────────────────────────────────────────────

/** GET /mcp-custom-scopes/:slug/clients — api keys + oauth clients (linked: false). */
export async function fetchScopeClients(scopeSlug: string): Promise<ScopeClient[]> {
  const res = await request<{ clients: ScopeClient[] }>(
    `/api/v1/admin/mcp-custom-scopes/${encodeURIComponent(scopeSlug)}/clients`,
  );
  return res.clients;
}

/** Extract F3 temporal windows out of a config's per-tool entries. */
function extractTempWindows(config: McpCustomScopeConfig): TempWindows {
  const windows: TempWindows = {};
  for (const group of Object.values(config.groups ?? {})) {
    for (const [toolName, entry] of Object.entries(group.tools ?? {})) {
      if (entry && (entry.hide_until != null || entry.enable_for_hours != null)) {
        windows[toolName] = {
          hide_until: entry.hide_until ?? null,
          enable_for_hours: entry.enable_for_hours ?? null,
        };
      }
    }
  }
  return windows;
}

/** Merge temporal windows into a config's per-tool entries (canonical keys). */
function mergeTempWindows(
  config: McpCustomScopeConfig,
  tempWindows: TempWindows,
): McpCustomScopeConfig {
  const draft = normalizeConfigToolKeys(config);
  for (const group of Object.values(draft.groups)) {
    for (const [toolName, win] of Object.entries(tempWindows)) {
      const key = canonicalToolName(toolName);
      const entry = group.tools?.[key] ?? {};
      group.tools = group.tools ?? {};
      group.tools[key] = { ...entry, hide_until: win.hide_until, enable_for_hours: win.enable_for_hours };
    }
  }
  return draft;
}

/**
 * Load the permission bundle for one client on one scope (GET toolset_config,
 * ACL/rules state left empty — rule CRUD endpoints are not part of D3).
 */
export async function fetchClientPermissions(
  scopeSlug: string,
  client: ScopeClient,
): Promise<ClientPermissions> {
  const res = await request<{ toolset_config: McpCustomScopeConfig }>(
    `/api/v1/admin/mcp-custom-scopes/${encodeURIComponent(scopeSlug)}/clients/${encodeURIComponent(client.kind)}/${encodeURIComponent(client.id)}/toolset_config`,
  );
  const toolsetConfig = res.toolset_config ?? {};
  return {
    clientId: client.id,
    clientKind: client.kind,
    toolsetConfig,
    tempWindows: extractTempWindows(toolsetConfig),
    acl: { rules: [], groups: [] },
    permissionGroups: [],
  };
}

/**
 * Persist a client's permission bundle: temporal windows fold into the
 * toolset_config entries (keys canonicalized) and the bundle is PUT to the
 * backend. Permission-group membership is synced by the caller.
 */
export async function saveClientPermissions(
  scopeSlug: string,
  permissions: ClientPermissions,
): Promise<{ ok: true; toolsetConfig: McpCustomScopeConfig }> {
  const res = await request<{ toolset_config: McpCustomScopeConfig }>(
    `/api/v1/admin/mcp-custom-scopes/${encodeURIComponent(scopeSlug)}/clients/${encodeURIComponent(permissions.clientKind)}/${encodeURIComponent(permissions.clientId)}/toolset_config`,
    {
      method: 'PUT',
      body: JSON.stringify({
        toolset_config: mergeTempWindows(permissions.toolsetConfig, permissions.tempWindows),
      }),
    },
  );
  return { ok: true, toolsetConfig: res.toolset_config ?? {} };
}

// ── ACL groups ─────────────────────────────────────────────────────────────

/**
 * Raw toolset_config PUT for the W7 per-item editor (no bundle context). The
 * :slug segment is URL context only — the backend resolves the client by
 * kind+id.
 */
export async function putClientToolsetConfig(
  scopeSlug: string,
  kind: ClientKind,
  clientId: string,
  toolsetConfig: McpCustomScopeConfig,
): Promise<McpCustomScopeConfig> {
  const res = await request<{ toolset_config: McpCustomScopeConfig }>(
    `/api/v1/admin/mcp-custom-scopes/${encodeURIComponent(scopeSlug)}/clients/${encodeURIComponent(kind)}/${encodeURIComponent(clientId)}/toolset_config`,
    { method: 'PUT', body: JSON.stringify({ toolset_config: normalizeConfigToolKeys(toolsetConfig) }) },
  );
  return res.toolset_config ?? {};
}

/** GET /admin/acl/groups — active groups with members. */
export async function fetchAclGroups(): Promise<AclGroupWire[]> {
  const res = await request<{ groups: AclGroupWire[] }>('/api/v1/admin/acl/groups');
  return res.groups;
}

/** POST /admin/acl/groups. */
export async function createAclGroup(name: string, description?: string): Promise<AclGroupWire> {
  const res = await request<{ group: AclGroupWire }>('/api/v1/admin/acl/groups', {
    method: 'POST',
    body: JSON.stringify({ group: { name, description } }),
  });
  return res.group;
}

/** DELETE /admin/acl/groups/:id — soft archive (group stops resolving). */
export async function deleteAclGroup(groupId: string): Promise<void> {
  await request(`/api/v1/admin/acl/groups/${encodeURIComponent(groupId)}`, { method: 'DELETE' });
}

function refForClient(kind: ClientKind, clientId: string): { type: string; id: string } {
  return {
    type: kind === 'api_key' ? 'NoizuPromptLingua.Schema.McpApiKey' : 'NoizuPromptLingua.Schema.OAuthClient',
    id: clientId,
  };
}

/** Opaque ERP ref string for a client ("Type:id") — membership comparisons use it. */
export function clientAclRefString(kind: ClientKind, clientId: string): string {
  return refString(kind, clientId);
}

function refString(kind: ClientKind, clientId: string): string {
  const ref = refForClient(kind, clientId);
  return `${ref.type}:${ref.id}`;
}

/** POST /admin/acl/groups/:id/members — attach a client to a permission group. */
export async function addAclGroupMember(
  groupId: string,
  kind: ClientKind,
  clientId: string,
): Promise<void> {
  await request(`/api/v1/admin/acl/groups/${encodeURIComponent(groupId)}/members`, {
    method: 'POST',
    body: JSON.stringify({ member: refForClient(kind, clientId) }),
  });
}

/** DELETE /admin/acl/groups/:id/members — detach a client from a permission group. */
export async function removeAclGroupMember(
  groupId: string,
  kind: ClientKind,
  clientId: string,
): Promise<void> {
  await request(`/api/v1/admin/acl/groups/${encodeURIComponent(groupId)}/members`, {
    method: 'DELETE',
    body: JSON.stringify({ member: refString(kind, clientId) }),
  });
}
