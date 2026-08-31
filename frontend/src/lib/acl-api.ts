'use client';

/**
 * W6 scope-manager-ux — typed API client for ACL + per-client MCP permissions.
 *
 * Backend status (2026-08-31):
 *  - ACL core is F1's (branch feat/acl-core): `NoizuPromptLingua.ACL` context,
 *    tables acl_groups / acl_group_members / acl_rules (TOBOR-CONTRACTS.md §1).
 *    The REST endpoints below DO NOT EXIST yet.
 *  - Per-scope client listing / per-client toolset_config persistence does not
 *    exist yet either (generalized key_toolsets layering lands via F2).
 *
 * Until those endpoints ship, every function here falls back to clearly marked
 * FIXTURE data (or a no-op success) so the W6 UI is fully wireable. Each stub
 * is tagged with `// STUB:` — integration (I1) swaps the fallbacks for real
 * responses without touching callers.
 */

import type { McpCustomScopeConfig } from '@/lib/api';
import type { AclGroup, AclRule, AclState } from '@/types/tool-state';

/** Shared F4 tool-state contract (F1 ERP refs) — re-exported for kit consumers. */
export type { AclGroup, AclRule, AclState } from '@/types/tool-state';

export type ClientKind = 'api_key' | 'oauth_client';

/** A client that can hit a scope's MCP endpoint (API key or OAuth client). */
export interface ScopeClient {
  id: string;
  kind: ClientKind;
  /** Display label (key label or OAuth client_name). */
  label: string;
  status: 'active' | 'revoked';
  inserted_at: string;
}

/**
 * Per-client permission bundle persisted as the client's `toolset_config`
 * jsonb (same shape family as scope config) + ACL rows + permission-group
 * membership. This is the payload W6's Manage Clients tab edits and saves.
 */
export interface ClientPermissions {
  clientId: string;
  clientKind: ClientKind;
  /** Tool restrict config — same jsonb shape as scope config ({groups:{gid:{tools:{name:{disabled,hidden}}}}}). */
  toolsetConfig: McpCustomScopeConfig;
  /** F3 temporal windows per canonical tool name: {hide_until, enable_for_hours} (mutually exclusive). */
  tempWindows: Record<string, { hide_until: string | null; enable_for_hours: number | null }>;
  /** F1 ACL grants/denies bound to this client as subject. */
  acl: AclState;
  /** Names of ACL permission groups this client belongs to (datalist-driven). */
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
    throw new Error(body.error || `Request failed: ${res.status}`);
  }
  return res.json();
}

// ── Fixture data (STUB fallbacks — remove when F1/F2 endpoints land) ──

const FIXTURE_CLIENTS: ScopeClient[] = [
  {
    id: 'key-fixture-1',
    kind: 'api_key',
    label: 'ci-runner key (…ab12)',
    status: 'active',
    inserted_at: '2026-08-01T00:00:00Z',
  },
  {
    id: 'oauth-fixture-1',
    kind: 'oauth_client',
    label: 'Claude Desktop (fixture)',
    status: 'active',
    inserted_at: '2026-08-15T00:00:00Z',
  },
];

const FIXTURE_ACL: AclState = {
  rules: [
    {
      id: 'rule-fixture-1',
      subject: { kind: 'client', id: 'key-fixture-1' },
      resource: { kind: 'organization', id: 'the-robot-lives' },
      effect: 'allow',
      scope: 'read',
      priority: 0,
    },
    {
      id: 'rule-fixture-2',
      subject: { kind: 'client', id: 'key-fixture-1' },
      resource: { kind: 'wiki', id: 'internal-notes' },
      effect: 'deny',
      scope: 'read',
      priority: 0,
    },
  ],
  groups: [
    {
      id: 'group-fixture-1',
      name: 'ci-bots',
      members: [{ kind: 'client', id: 'key-fixture-1' }],
    },
  ],
};

const FIXTURE_GROUPS: AclGroup[] = [
  { id: 'group-fixture-1', name: 'ci-bots', members: [] },
  { id: 'group-fixture-2', name: 'admins', members: [] },
  { id: 'group-fixture-3', name: 'read-only', members: [] },
];

function fixturePermissions(client: ScopeClient): ClientPermissions {
  return {
    clientId: client.id,
    clientKind: client.kind,
    toolsetConfig: { groups: {} },
    tempWindows: {},
    acl: {
      rules: FIXTURE_ACL.rules.map((r) => ({ ...r, subject: { kind: 'client', id: client.id } })),
      groups: FIXTURE_ACL.groups.map((g) => ({ ...g })),
    },
    permissionGroups: client.kind === 'api_key' ? ['ci-bots'] : [],
  };
}

// ── Public API ──

/**
 * List clients (API keys + OAuth clients) attached to a custom scope.
 *
 * STUB: GET /api/v1/admin/mcp-custom-scopes/:slug/clients — endpoint does not
 * exist yet (F2 generalizes client layering). Falls back to fixtures on 404.
 */
export async function fetchScopeClients(scopeSlug: string): Promise<ScopeClient[]> {
  try {
    const res = await request<{ clients: ScopeClient[] }>(
      `/api/v1/admin/mcp-custom-scopes/${encodeURIComponent(scopeSlug)}/clients`,
    );
    return res.clients;
  } catch {
    // STUB fallback — fixture clients until the endpoint exists.
    return FIXTURE_CLIENTS.map((c) => ({ ...c }));
  }
}

/**
 * Load the permission bundle for one client on one scope.
 *
 * STUB: GET /api/v1/admin/mcp-custom-scopes/:slug/clients/:clientId/permissions
 * — falls back to fixtures on 404.
 */
export async function fetchClientPermissions(
  scopeSlug: string,
  client: ScopeClient,
): Promise<ClientPermissions> {
  try {
    const res = await request<{ permissions: ClientPermissions }>(
      `/api/v1/admin/mcp-custom-scopes/${encodeURIComponent(scopeSlug)}/clients/${encodeURIComponent(client.id)}/permissions`,
    );
    return res.permissions;
  } catch {
    // STUB fallback — fixture bundle until the endpoint exists.
    return fixturePermissions(client);
  }
}

/**
 * Persist a client's permission bundle.
 *
 * STUB: PUT /api/v1/admin/mcp-custom-scopes/:slug/clients/:clientId/permissions
 * — endpoint does not exist yet (F1 ACL writes + F2 toolset_config). Resolves
 * as success without persisting anything.
 */
export async function saveClientPermissions(
  scopeSlug: string,
  permissions: ClientPermissions,
): Promise<{ ok: true; stub?: true }> {
  try {
    return await request<{ ok: true }>(
      `/api/v1/admin/mcp-custom-scopes/${encodeURIComponent(scopeSlug)}/clients/${encodeURIComponent(permissions.clientId)}/permissions`,
      { method: 'PUT', body: JSON.stringify({ permissions }) },
    );
  } catch {
    // STUB fallback — pretend-save until the endpoint exists.
    console.info(
      `[acl-api] STUB saveClientPermissions (scope=${scopeSlug}, client=${permissions.clientId}) — backend endpoint not implemented yet`,
    );
    return { ok: true, stub: true };
  }
}

/**
 * List available ACL permission groups (names for the assignment datalist).
 *
 * STUB: GET /api/v1/admin/acl/groups — F1 backend. Falls back to fixtures.
 */
export async function fetchAclGroups(): Promise<AclGroup[]> {
  try {
    const res = await request<{ groups: AclGroup[] }>('/api/v1/admin/acl/groups');
    return res.groups;
  } catch {
    // STUB fallback.
    return FIXTURE_GROUPS.map((g) => ({ ...g }));
  }
}
