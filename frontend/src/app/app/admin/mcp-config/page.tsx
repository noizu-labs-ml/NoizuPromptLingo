'use client';

import { useCallback, useEffect, useState } from 'react';
import Link from 'next/link';
import { toast } from 'sonner';
import { api, type OAuthClient, type McpCustomScope } from '@/lib/api';

// W7 — single Admin → MCP Config entry grouping OAuth Clients, API Keys
// (legacy-vs-OAuth subtabs) and Custom MCP Endpoints, and surfacing the
// previously buried OAuth scopes page (/app/admin/mcp-custom-scopes).

type MainTab = 'keys' | 'oauth-clients' | 'endpoints';
type KeysSubTab = 'oauth' | 'legacy';

export default function AdminMcpConfigPage() {
  const [tab, setTab] = useState<MainTab>('keys');
  const [keysSubTab, setKeysSubTab] = useState<KeysSubTab>('oauth');

  // Legacy mint gate (precedent: /app/mcp-keys legacy_api_key_mint_enabled).
  const [legacyMintEnabled, setLegacyMintEnabled] = useState<boolean | null>(null);

  const [clients, setClients] = useState<OAuthClient[]>([]);
  const [scopes, setScopes] = useState<McpCustomScope[]>([]);
  const [loadingClients, setLoadingClients] = useState(true);
  const [loadingScopes, setLoadingScopes] = useState(true);

  const loadClients = useCallback(async () => {
    setLoadingClients(true);
    try {
      const res = await api.adminListOAuthClients();
      setClients(res.clients ?? []);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load OAuth clients');
    } finally {
      setLoadingClients(false);
    }
  }, []);

  const loadScopes = useCallback(async () => {
    setLoadingScopes(true);
    try {
      const res = await api.adminListMcpCustomScopes();
      setScopes(res.scopes ?? []);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load MCP endpoints');
    } finally {
      setLoadingScopes(false);
    }
  }, []);

  useEffect(() => {
    api
      .mcpConfig({ packaging: 'setup' })
      .then((cfg) => setLegacyMintEnabled(cfg.legacy_api_key_mint_enabled !== false))
      .catch(() => setLegacyMintEnabled(null));
    loadClients();
    loadScopes();
  }, [loadClients, loadScopes]);

  async function revokeClient(clientId: string) {
    if (!confirm('Revoke this OAuth client? Its pairing grants and refresh tokens are revoked immediately.')) return;
    try {
      const { client } = await api.adminRevokeOAuthClient(clientId);
      setClients((prev) => prev.map((c) => (c.client_id === clientId ? client : c)));
      toast.success('Client revoked');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to revoke client');
    }
  }

  const mainTabs: { id: MainTab; label: string }[] = [
    { id: 'keys', label: 'API Keys' },
    { id: 'oauth-clients', label: 'OAuth Clients' },
    { id: 'endpoints', label: 'Custom MCP Endpoints' },
  ];

  return (
    <div className="content">
      <main>
        <h1 className="sg-page-title">MCP Config</h1>
        <p className="sg-page-intro">
          One place for MCP client configuration: API keys, OAuth clients, and the custom MCP
          endpoints (scopes) they connect to.{' '}
          <Link href="/app/admin">Back to Admin</Link>
        </p>

        <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', margin: 'var(--space-4) 0' }}>
          {mainTabs.map((t) => (
            <button
              key={t.id}
              type="button"
              className={`sg-btn ${tab === t.id ? 'sg-btn--black' : 'sg-btn--outline'}`}
              onClick={() => setTab(t.id)}
            >
              {t.label}
            </button>
          ))}
        </div>

        {/* ------------------------------------------------ API Keys ------- */}
        {tab === 'keys' && (
          <section className="dash-panel">
            <div className="dash-panel__head">
              <h2 className="dash-panel__title">API Keys</h2>
            </div>

            <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', margin: '12px 0 16px' }}>
              {(
                [
                  { id: 'oauth' as const, label: 'OAuth (recommended)' },
                  { id: 'legacy' as const, label: 'Legacy (deprecated)' },
                ]
              ).map((t) => (
                <button
                  key={t.id}
                  type="button"
                  className={`sg-btn sg-btn--sm ${keysSubTab === t.id ? 'sg-btn--black' : 'sg-btn--outline'}`}
                  onClick={() => setKeysSubTab(t.id)}
                >
                  {t.label}
                </button>
              ))}
            </div>

            {keysSubTab === 'oauth' && (
              <div>
                <p className="sg-page-intro" style={{ marginBottom: 12 }}>
                  OAuth 2.1 is the preferred auth path — hosted connectors (Claude.ai, ChatGPT)
                  register themselves via DCR and consent in the browser; no static secret is
                  copied. Client permissions (tool toggles, access windows, ACL) are managed per
                  client.
                </p>
                <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
                  <Link className="sg-btn sg-btn--black sg-btn--sm" href="/app/mcp-keys">
                    Open MCP client setup
                  </Link>
                  <button
                    type="button"
                    className="sg-btn sg-btn--outline sg-btn--sm"
                    onClick={() => setTab('oauth-clients')}
                  >
                    Manage OAuth clients
                  </button>
                  <Link className="sg-btn sg-btn--outline sg-btn--sm" href="/app/admin/mcp-custom-scopes">
                    OAuth scopes (custom endpoints)
                  </Link>
                </div>
              </div>
            )}

            {keysSubTab === 'legacy' && (
              <div>
                {legacyMintEnabled === null ? (
                  <p className="sg-page-intro">Checking legacy key minting…</p>
                ) : legacyMintEnabled ? (
                  <>
                    <p className="sg-page-intro" style={{ marginBottom: 12 }}>
                      Legacy Bearer API keys are still mintable — only for CLIs that cannot do
                      OAuth yet. ChatGPT/Claude.ai connectors reject static Bearer keys.
                    </p>
                    <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
                      <Link className="sg-btn sg-btn--black sg-btn--sm" href="/app/admin/authz">
                        Mint / revoke API keys (admin)
                      </Link>
                      <Link className="sg-btn sg-btn--outline sg-btn--sm" href="/app/mcp-keys">
                        Your keys &amp; setup commands
                      </Link>
                    </div>
                  </>
                ) : (
                  <>
                    <div className="dash-panel__head">
                      <h2 className="dash-panel__title">Legacy API keys disabled</h2>
                    </div>
                    <p className="sg-page-intro">
                      New API key minting is turned off. Use OAuth custom connectors. Existing
                      keys can still be revoked from{' '}
                      <Link href="/app/admin/authz">admin key management</Link> or{' '}
                      <Link href="/app/mcp-keys">your key list</Link>.
                    </p>
                  </>
                )}
              </div>
            )}
          </section>
        )}

        {/* ------------------------------------------- OAuth Clients ------- */}
        {tab === 'oauth-clients' && (
          <section className="dash-panel">
            <div className="dash-panel__head">
              <h2 className="dash-panel__title">Clients</h2>
              <span className="dash-badge">{clients.length}</span>
            </div>
            <p className="sg-page-intro" style={{ marginBottom: 12 }}>
              Clients registered for MCP OAuth 2.1 — dynamically via DCR or first-party — with
              their active pairing-grant counts. Revoking a client immediately revokes its grants
              and refresh tokens.
            </p>

            {loadingClients ? (
              <p className="sg-page-intro">Loading…</p>
            ) : clients.length === 0 ? (
              <p className="sg-page-intro">No OAuth clients registered.</p>
            ) : (
              <ul className="admin-table-wrap">
                {clients.map((c) => (
                  <li key={c.client_id} className="gh-row">
                    <div className="gh-row__main">
                      <div className="gh-row__title">{c.client_name}</div>
                      <div className="gh-row__sub font-mono">{c.client_id}</div>
                      <span className="gh-row__sub">
                        {c.token_endpoint_auth_method === 'none' ? 'public' : 'confidential'}
                        {c.is_first_party ? ' · first-party' : ''}
                      </span>
                      <span className="gh-row__sub">
                        {c.grant_count} active grant{c.grant_count === 1 ? '' : 's'}
                      </span>
                      <span className={`gh-grant__level gh-grant__level--${c.status === 'active' ? 'member' : 'viewer'}`}>
                        {c.status}
                      </span>
                    </div>
                    <div style={{ display: 'flex', gap: 8, alignItems: 'center', flexWrap: 'wrap' }}>
                      {c.status === 'active' && (
                        <>
                          <Link
                            className="sg-btn sg-btn--outline sg-btn--sm"
                            href={`/app/admin/mcp-config/oauth-client/${encodeURIComponent(c.client_id)}`}
                          >
                            Permissions
                          </Link>
                          <Link
                            className="sg-btn sg-btn--outline sg-btn--sm"
                            href="/app/admin/mcp-custom-scopes"
                          >
                            Scopes
                          </Link>
                          <button
                            className="sg-btn sg-btn--danger sg-btn--sm"
                            onClick={() => revokeClient(c.client_id)}
                          >
                            Revoke
                          </button>
                        </>
                      )}
                    </div>
                  </li>
                ))}
              </ul>
            )}
          </section>
        )}

        {/* --------------------------------- Custom MCP Endpoints ---------- */}
        {tab === 'endpoints' && (
          <section className="dash-panel">
            <div className="dash-panel__head">
              <h2 className="dash-panel__title">Custom MCP endpoints (scopes)</h2>
              <span className="dash-badge">{scopes.length}</span>
            </div>
            <p className="sg-page-intro" style={{ marginBottom: 12 }}>
              Every user and org is cloned a Tobor Locker endpoint from the global template.
              Edit scope packages, tool defaults, and visibility on the scopes page — the
              full editor now also lives one click away instead of buried under Admin.
            </p>

            {loadingScopes ? (
              <p className="sg-page-intro">Loading…</p>
            ) : scopes.length === 0 ? (
              <p className="sg-page-intro">No custom scopes yet.</p>
            ) : (
              <ul className="admin-table-wrap">
                {scopes.map((s) => (
                  <li key={s.id} className="gh-row">
                    <div className="gh-row__main">
                      <div className="gh-row__title">
                        {s.name}
                        {s.slug === 'tobor' ? ' (default)' : ''}
                      </div>
                      <div className="gh-row__sub font-mono">{s.slug}</div>
                      {s.url && <div className="gh-row__sub font-mono">{s.url}</div>}
                      <span className="gh-row__sub">{s.kind || 'custom'}</span>
                    </div>
                    <Link
                      className="sg-btn sg-btn--outline sg-btn--sm"
                      href={`/app/admin/mcp-custom-scopes?scope=${encodeURIComponent(s.slug)}`}
                    >
                      Edit
                    </Link>
                  </li>
                ))}
              </ul>
            )}

            <div style={{ marginTop: 12 }}>
              <Link className="sg-btn sg-btn--black sg-btn--sm" href="/app/admin/mcp-custom-scopes">
                Open OAuth scopes editor
              </Link>
            </div>
          </section>
        )}
      </main>
    </div>
  );
}
