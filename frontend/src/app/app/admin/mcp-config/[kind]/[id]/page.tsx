'use client';

import { useCallback, useEffect, useState } from 'react';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import { toast } from 'sonner';
import { api, type McpCustomScopeConfig, type OAuthClient } from '@/lib/api';
import ClientPermissionsEditor, {
  defaultClientPermissions,
  type ClientPermissionsCatalogGroup,
  type ClientPermissionsValue,
} from '@/components/mcp-config/ClientPermissionsEditor';
import { putClientToolsetConfig } from '@/lib/acl-api';
import { canonicalToolName } from '@/lib/tool-overrides';
import ToolSetEditor from '@/components/mcp-config/ToolSetEditor';

// W7 — per-item client permission editor for the MCP Config hub.
//   /app/admin/mcp-config/api-key/:id      → legacy API key (row uuid)
//   /app/admin/mcp-config/oauth-client/:id → OAuth client (uuid or client_id)
//
// Persistence (D3): the editor's tool/window state serializes into the
// client's `toolset_config` jsonb (F2 EffectiveToolset cascade layer 3) via
// PUT /api/v1/admin/mcp-custom-scopes/:slug/clients/:kind/:id/toolset_config.
// The :slug segment is URL context only; the backend resolves the client by
// kind+id. ACL rule editing is hidden here — rule CRUD endpoints are not part
// of D3 (group membership is managed from the W6 Manage Clients tab).

type ClientKind = 'api-key' | 'oauth-client';

const KINDS: ClientKind[] = ['api-key', 'oauth-client'];

/**
 * N4a: `kind=tool-set` branches to the dedicated tool-set editor before any
 * client-permissions state loads; the remaining kinds keep the original body.
 */
export default function ClientPermissionsPage() {
  const params = useParams<{ kind: string; id: string }>();
  const kind = params?.kind ?? '';
  const id = decodeURIComponent(params?.id ?? '');

  if (kind === 'tool-set') {
    return <ToolSetEditor slug={id} />;
  }
  return <ClientPermissionsInner kind={kind as ClientKind} id={id} />;
}

function ClientPermissionsInner({ kind, id }: { kind: ClientKind; id: string }) {
  const validKind = KINDS.includes(kind);

  const [catalog, setCatalog] = useState<ClientPermissionsCatalogGroup[]>([]);
  const [value, setValue] = useState<ClientPermissionsValue | null>(null);
  const [displayName, setDisplayName] = useState<string>('');
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  const loadCatalog = useCallback(async () => {
    try {
      const res = await api.adminMcpCustomScopeCatalog();
      const groups: ClientPermissionsCatalogGroup[] = (res.groups ?? []).map((g) => ({
        id: g.id,
        group: g.label,
        tools: g.tools.map((t) => ({ name: t.name, description: t.description })),
      }));
      setCatalog(groups);
      setValue(defaultClientPermissions(groups));
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load tool catalog');
      setCatalog([]);
      setValue(defaultClientPermissions([]));
    } finally {
      setLoading(false);
    }
  }, []);

  // Best-effort display name so the editor header names the client. Absent
  // lookup APIs fall back to the route id.
  useEffect(() => {
    let cancelled = false;
    (async () => {
      if (!validKind || !id) return;
      try {
        if (kind === 'oauth-client') {
          const res = await api.adminListOAuthClients();
          const match = (res.clients ?? []).find(
            (c: OAuthClient) => c.client_id === id || c.client_name === id,
          );
          if (!cancelled && match) setDisplayName(match.client_name);
        } else {
          // adminListMcpKeys is user-scoped; a key-by-id lookup arrives with the
          // F2/W6 persistence API. Route id is a usable label until then.
          setDisplayName((current) => current || id);
        }
      } catch {
        // Non-fatal — label stays the route id.
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [kind, id, validKind]);

  useEffect(() => {
    if (!validKind) {
      setLoading(false);
      return;
    }
    loadCatalog();
  }, [validKind, loadCatalog]);

  async function save() {
    if (!value) return;
    setSaving(true);
    try {
      // Serialize the editor state into the toolset_config jsonb shape:
      // {groups: {gid: {tools: {canonical_name: {disabled, hidden, windows}}}}}
      // Absent entries stay enabled + visible (inverted semantics). Keys are
      // canonicalized server-side too; doing it here keeps the payload clean.
      const groups: McpCustomScopeConfig['groups'] = {};
      for (const group of catalog) {
        const tools: McpCustomScopeConfig['groups'][string]['tools'] = {};
        for (const tool of group.tools) {
          const state = value.tools[tool.name];
          if (!state) continue;
          const entry: NonNullable<NonNullable<McpCustomScopeConfig['groups'][string]['tools']>[string]> = {};
          if (!state.enabled) entry.disabled = true;
          if (!state.visible) entry.hidden = true;
          if (state.hide_until) entry.hide_until = state.hide_until;
          if (state.enable_for_hours != null) entry.enable_for_hours = state.enable_for_hours;
          if (Object.keys(entry).length > 0) tools[canonicalToolName(tool.name)] = entry;
        }
        if (Object.keys(tools).length > 0) groups[group.id] = { tools };
      }
      // Route kind is hyphenated; the API client type uses snake_case (the
      // backend accepts both spellings).
      const apiKind = kind === 'api-key' ? 'api_key' : 'oauth_client';
      await putClientToolsetConfig('any', apiKind, id, { groups });
      toast.success('Client permissions saved');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Save failed');
    } finally {
      setSaving(false);
    }
  }

  if (!validKind) {
    return (
      <div className="content">
        <main>
          <h1 className="sg-page-title">Unknown client type</h1>
          <p className="sg-page-intro">
            Expected <span className="font-mono">api-key</span> or{' '}
            <span className="font-mono">oauth-client</span>.{' '}
            <Link href="/app/admin/mcp-config">Back to MCP Config</Link>
          </p>
        </main>
      </div>
    );
  }

  if (loading || !value) {
    return (
      <div className="content">
        <main>
          <p className="sg-page-intro">Loading…</p>
        </main>
      </div>
    );
  }

  return (
    <div className="content">
      <main>
        <h1 className="sg-page-title">
          {kind === 'api-key' ? 'API key' : 'OAuth client'} permissions
        </h1>
        <p className="sg-page-intro">
          Tool toggles and access windows for this client (ACL rules arrive with the rules API).{' '}
          <Link href="/app/admin/mcp-config">Back to MCP Config</Link>
        </p>

        <ClientPermissionsEditor
          label={displayName || id}
          catalog={catalog}
          value={value}
          onChange={setValue}
          showAcl={false}
        />

        <div className="modal-actions">
          <Link className="sg-btn sg-btn--outline" href="/app/admin/mcp-config">
            Cancel
          </Link>
          <button type="button" className="sg-btn sg-btn--black" onClick={save} disabled={saving}>
            {saving ? 'Saving…' : 'Save'}
          </button>
        </div>
      </main>
    </div>
  );
}
