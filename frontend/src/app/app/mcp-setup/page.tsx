'use client';

import { useCallback, useEffect, useState } from 'react';
import { toast } from 'sonner';
import {
  api,
  type McpCustomGroup,
  type McpCustomScope,
  type McpOAuthConnection,
} from '@/lib/api';
import McpEndpointList from '@/components/mcp-endpoint-list';
import EndpointWizard from '@/components/mcp-config/endpoint-wizard';

/**
 * Dedicated user setup page (/app/mcp-setup): visual endpoint picker, the
 * endpoint-creation wizard, and connected-client (OAuth pairing grant)
 * revocation. Lean composition of existing API routes — no new backend
 * surface; detailed per-client install snippets stay on the MCP client setup
 * page.
 */
export default function McpSetupPage() {
  const [templates, setTemplates] = useState<McpCustomScope[]>([]);
  const [endpoints, setEndpoints] = useState<McpCustomScope[]>([]);
  const [selected, setSelected] = useState<McpCustomScope | null>(null);
  const [catalog, setCatalog] = useState<McpCustomGroup[]>([]);
  const [connections, setConnections] = useState<McpOAuthConnection[]>([]);
  const [wizardOpen, setWizardOpen] = useState(false);
  const [copied, setCopied] = useState(false);

  const load = useCallback(async () => {
    try {
      const [endpointRes, catalogRes] = await Promise.all([
        api.listMcpEndpoints(),
        // The wizard needs the catalog; without it the picker still works.
        api.mcpCatalog().catch(() => ({ groups: [] as McpCustomGroup[] })),
      ]);
      setTemplates(endpointRes.templates ?? []);
      setEndpoints(endpointRes.endpoints ?? []);
      setSelected(endpointRes.default_scope ?? endpointRes.endpoints?.[0] ?? null);
      setCatalog(catalogRes.groups ?? []);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load endpoints');
    }
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  const fetchConnections = useCallback(async () => {
    try {
      const data = await api.listMcpConnections();
      setConnections(data.connections ?? []);
    } catch {
      // Endpoint may 404 on older deploys — connections are optional here.
      setConnections([]);
    }
  }, []);

  useEffect(() => {
    void fetchConnections();
  }, [fetchConnections]);

  async function revoke(grantId: string) {
    if (!confirm('Revoke this OAuth connection? Connected clients must re-authorize.')) return;
    try {
      await api.revokeMcpConnection(grantId);
      await fetchConnections();
      toast.success('Connection revoked');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to revoke connection');
    }
  }

  async function copyUrl() {
    if (!selected?.url) return;
    try {
      await navigator.clipboard.writeText(selected.url);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
      toast.success('Copied');
    } catch {
      toast.error('Copy failed — select and copy manually');
    }
  }

  function wizardCreated(endpoint: McpCustomScope) {
    toast.success('Endpoint created');
    setEndpoints((prev) => [endpoint, ...prev.filter((s) => s.id !== endpoint.id)]);
    setSelected(endpoint);
    // Reconcile with the server (templates may have shifted) without blocking
    // on it — the local row already renders.
    void load();
  }

  return (
    <div className="content">
      <main>
        <h1 className="sg-page-title">MCP setup</h1>
        <p className="sg-page-intro">
          Pick an endpoint, copy its MCP URL into your client, and manage what you
          have connected. Per-client install snippets and key minting live on{' '}
          <strong>MCP client setup</strong>.
        </p>

        <section className="dash-panel">
          <div className="dash-panel__head">
            <h2 className="dash-panel__title">Endpoints</h2>
            <button
              type="button"
              className="sg-btn sg-btn--black sg-btn--sm"
              onClick={() => setWizardOpen(true)}
            >
              Add endpoint
            </button>
          </div>

          <McpEndpointList
            templates={templates}
            endpoints={endpoints}
            selectedId={selected?.id ?? null}
            onSelect={setSelected}
          />

          {selected ? (
            <div className="authz-reveal">
              <div className="authz-reveal__label">MCP URL</div>
              <div className="authz-reveal__row">
                <code className="authz-reveal__key font-mono">{selected.url}</code>
                <button type="button" className="sg-btn sg-btn--outline sg-btn--sm" onClick={copyUrl}>
                  {copied ? 'Copied!' : 'Copy'}
                </button>
              </div>
            </div>
          ) : (
            <p className="sg-page-intro">Loading standard Tobor Locker endpoint…</p>
          )}
        </section>

        <section className="dash-panel" style={{ marginTop: 'var(--space-4)' }}>
          <div className="dash-panel__head">
            <h2 className="dash-panel__title">Connected clients</h2>
            <span className="dash-badge">{connections.length}</span>
          </div>
          <p className="sg-page-intro" style={{ marginBottom: 12 }}>
            Clients you allowed via OAuth. Revoke to cut a client off immediately
            (its refresh tokens stop working).
          </p>
          {connections.length === 0 ? (
            <p className="sg-page-intro">No connections yet.</p>
          ) : (
            <ul className="admin-table-wrap">
              {connections.map((connection) => (
                <li key={connection.grant_id} className="gh-row">
                  <div className="gh-row__main">
                    <div className="gh-row__title font-mono">{connection.client_id}</div>
                    <div className="gh-row__sub font-mono">{connection.resource}</div>
                    <span className="gh-row__sub">
                      {connection.scope} · grant {connection.grant_id}
                    </span>
                  </div>
                  <button
                    type="button"
                    className="sg-btn sg-btn--outline sg-btn--sm"
                    onClick={() => revoke(connection.grant_id)}
                  >
                    Revoke
                  </button>
                </li>
              ))}
            </ul>
          )}
        </section>

        <EndpointWizard
          open={wizardOpen}
          catalog={catalog}
          onClose={() => setWizardOpen(false)}
          onCreated={wizardCreated}
        />
      </main>
    </div>
  );
}
