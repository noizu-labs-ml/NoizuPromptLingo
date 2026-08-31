'use client';

import { useCallback, useEffect, useState } from 'react';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import { toast } from 'sonner';
import { api, type OAuthClient } from '@/lib/api';
import ClientPermissionsEditor, {
  defaultClientPermissions,
  type ClientPermissionsCatalogGroup,
  type ClientPermissionsValue,
} from '@/components/mcp-config/ClientPermissionsEditor';

// W7 — per-item client permission editor for the MCP Config hub.
//   /app/admin/mcp-config/api-key/:id      → legacy API key
//   /app/admin/mcp-config/oauth-client/:id → OAuth client
// Renders the shared W6/W7 client-permission stack (kit ToolTogglesGrid +
// TempWindowEditor + ACLEditor via ClientPermissionsEditor).
//
// Persistence: per-client toolset_config jsonb read/write lands with F2
// (EffectiveToolset consumers) and W6 page wiring — until that API exists the
// editor holds local state and Save reports the pending wiring (contract §8:
// stub cross-module calls; tsc may fail until feat/ui-kit merges).

type ClientKind = 'api-key' | 'oauth-client';

const KINDS: ClientKind[] = ['api-key', 'oauth-client'];

export default function ClientPermissionsPage() {
  const params = useParams<{ kind: string; id: string }>();
  const kind = (params?.kind ?? '') as ClientKind;
  const id = decodeURIComponent(params?.id ?? '');
  const validKind = KINDS.includes(kind);

  const [catalog, setCatalog] = useState<ClientPermissionsCatalogGroup[]>([]);
  const [value, setValue] = useState<ClientPermissionsValue | null>(null);
  const [displayName, setDisplayName] = useState<string>('');
  const [loading, setLoading] = useState(true);

  const loadCatalog = useCallback(async () => {
    try {
      const res = await api.adminMcpCustomScopeCatalog();
      const groups: ClientPermissionsCatalogGroup[] = (res.groups ?? []).map((g) => ({
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

  function save() {
    // toolset_config write arrives with F2/W6 (per-client jsonb + admin API).
    toast.info('Saved locally — per-client persistence lands with the toolset_config API (F2/W6)');
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
          Tool toggles, access windows, and ACL grants for this client.{' '}
          <Link href="/app/admin/mcp-config">Back to MCP Config</Link>
        </p>

        <ClientPermissionsEditor
          label={displayName || id}
          catalog={catalog}
          value={value}
          onChange={setValue}
        />

        <div className="modal-actions">
          <Link className="sg-btn sg-btn--outline" href="/app/admin/mcp-config">
            Cancel
          </Link>
          <button type="button" className="sg-btn sg-btn--black" onClick={save}>
            Save
          </button>
        </div>
      </main>
    </div>
  );
}
