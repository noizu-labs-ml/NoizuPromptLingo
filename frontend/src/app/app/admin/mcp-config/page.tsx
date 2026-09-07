'use client';

import { Suspense, useCallback, useEffect, useState } from 'react';
import Link from 'next/link';
import { useRouter, useSearchParams } from 'next/navigation';
import { toast } from 'sonner';
import { ConfirmDialog } from '@/components/kit';
import { api, type OAuthClient, type McpCustomScope } from '@/lib/api';

// W7 — single Admin → MCP Config entry grouping OAuth Clients, API Keys
// (legacy-vs-OAuth subtabs), custom MCP Endpoints, and Tool Sets. Tabs are
// URL-synced (?tab=…) so hub views deep-link; /app/admin/oauth-clients
// redirects here with ?tab=oauth-clients.

type MainTab = 'keys' | 'oauth-clients' | 'endpoints' | 'tool-sets';
type KeysSubTab = 'oauth' | 'legacy';

const MAIN_TABS: { id: MainTab; label: string }[] = [
  { id: 'keys', label: 'API Keys' },
  { id: 'oauth-clients', label: 'OAuth Clients' },
  { id: 'endpoints', label: 'Custom MCP Endpoints' },
  { id: 'tool-sets', label: 'Tool Sets' },
];

function parseTab(raw: string | null): MainTab {
  return MAIN_TABS.some((t) => t.id === raw) ? (raw as MainTab) : 'keys';
}

// Absorbed from /app/admin/oauth-clients (folded into this hub).
function timeAgo(dt?: string | null) {
  if (!dt) return 'unknown';
  const diff = Date.now() - new Date(dt).getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 1) return 'just now';
  if (mins < 60) return `${mins}m ago`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `${hrs}h ago`;
  return `${Math.floor(hrs / 24)}d ago`;
}

export default function AdminMcpConfigPage() {
  // Next 16 CSR bailout: useSearchParams requires a Suspense boundary
  // (precedent: /app/admin/mcp-custom-scopes).
  return (
    <Suspense
      fallback={
        <div className="content">
          <main>
            <p className="sg-page-intro">Loading…</p>
          </main>
        </div>
      }
    >
      <AdminMcpConfigInner />
    </Suspense>
  );
}

function AdminMcpConfigInner() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const tab = parseTab(searchParams.get('tab'));
  const [keysSubTab, setKeysSubTab] = useState<KeysSubTab>('oauth');

  // Legacy mint gate (precedent: /app/mcp-setup legacy_api_key_mint_enabled).
  const [legacyMintEnabled, setLegacyMintEnabled] = useState<boolean | null>(null);

  const [clients, setClients] = useState<OAuthClient[]>([]);
  const [scopes, setScopes] = useState<McpCustomScope[]>([]);
  const [loadingClients, setLoadingClients] = useState(true);
  const [loadingScopes, setLoadingScopes] = useState(true);
  const [clientsError, setClientsError] = useState<string | null>(null);
  const [scopesError, setScopesError] = useState<string | null>(null);
  const [pendingRevoke, setPendingRevoke] = useState<string | null>(null);

  const loadClients = useCallback(async () => {
    setLoadingClients(true);
    setClientsError(null);
    try {
      const res = await api.adminListOAuthClients();
      setClients(res.clients ?? []);
    } catch (err) {
      setClientsError(err instanceof Error ? err.message : 'Failed to load OAuth clients');
    } finally {
      setLoadingClients(false);
    }
  }, []);

  const loadScopes = useCallback(async () => {
    setLoadingScopes(true);
    setScopesError(null);
    try {
      const res = await api.adminListMcpCustomScopes();
      setScopes(res.scopes ?? []);
    } catch (err) {
      setScopesError(err instanceof Error ? err.message : 'Failed to load MCP endpoints');
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
    try {
      const { client } = await api.adminRevokeOAuthClient(clientId);
      setClients((prev) => prev.map((c) => (c.client_id === clientId ? client : c)));
      toast.success('Client revoked');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to revoke client');
      // Rethrow so ConfirmDialog stays open for retry; toast carries the reason.
      throw err;
    }
  }

  function setTab(next: MainTab) {
    const params = new URLSearchParams(searchParams.toString());
    if (next === 'keys') params.delete('tab');
    else params.set('tab', next);
    const qs = params.toString();
    router.replace(qs ? `/app/admin/mcp-config?${qs}` : '/app/admin/mcp-config', {
      scroll: false,
    });
  }

  return (
    <div className="content">
      <main>
        <h1 className="sg-page-title">MCP Config</h1>
        <p className="sg-page-intro">
          One place for MCP client configuration: API keys, OAuth clients, custom MCP endpoints
          (scopes), and tool sets. <Link href="/app/admin">Back to Admin</Link>
        </p>

        <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', margin: 'var(--space-4) 0' }}>
          {MAIN_TABS.map((t) => (
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
                  <Link className="sg-btn sg-btn--black sg-btn--sm" href="/app/mcp-setup">
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
                      <Link className="sg-btn sg-btn--outline sg-btn--sm" href="/app/mcp-setup">
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
                      <Link href="/app/mcp-setup">your key list</Link>.
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

            {clientsError && (
              <div className="sg-error sg-error--block">
                {clientsError}{' '}
                <button type="button" className="sg-btn sg-btn--outline sg-btn--sm" onClick={loadClients}>
                  Retry
                </button>
              </div>
            )}

            {loadingClients ? (
              <p className="sg-page-intro">Loading…</p>
            ) : clients.length === 0 ? (
              <p className="sg-page-intro">No OAuth clients yet.</p>
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
                      <span className="gh-row__sub font-mono">
                        {c.redirect_uris.length > 0 ? c.redirect_uris.join(', ') : 'no redirect URIs'}
                      </span>
                      <span className="gh-row__sub">
                        {c.grant_count} active grant{c.grant_count === 1 ? '' : 's'}
                      </span>
                      <span className="gh-row__sub">registered {timeAgo(c.inserted_at)}</span>
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
                            type="button"
                            className="sg-btn sg-btn--danger sg-btn--sm"
                            onClick={() => setPendingRevoke(c.client_id)}
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

            {scopesError && (
              <div className="sg-error sg-error--block">
                {scopesError}{' '}
                <button type="button" className="sg-btn sg-btn--outline sg-btn--sm" onClick={loadScopes}>
                  Retry
                </button>
              </div>
            )}

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

        {/* ------------------------------------------------ Tool Sets ------ */}
        {tab === 'tool-sets' && (
          <section className="dash-panel">
            <div className="dash-panel__head">
              <h2 className="dash-panel__title">Tool sets</h2>
            </div>
            <p className="sg-page-intro" style={{ marginBottom: 12 }}>
              Tool sets bundle groups of MCP tools into named packages that custom endpoints
              (scopes) and per-client permissions can reference. Built-in profiles ship with
              the platform; org tool sets are composed, cloned, and deactivated by admins.
            </p>

            <ul className="admin-table-wrap">
              <li className="gh-row">
                <div className="gh-row__main">
                  <div className="gh-row__title">Built-in profiles</div>
                  <div className="gh-row__sub">
                    Starter packages — like the restricted “core” set — maintained centrally so
                    every account works out of the box.
                  </div>
                </div>
                <Link className="sg-btn sg-btn--outline sg-btn--sm" href="/app/admin/tool-sets">
                  View
                </Link>
              </li>
              <li className="gh-row">
                <div className="gh-row__main">
                  <div className="gh-row__title">Org tool sets</div>
                  <div className="gh-row__sub">
                    Shared tool packages for your organization — create, edit, clone, or
                    deactivate them from the tool-sets page.
                  </div>
                </div>
                <Link className="sg-btn sg-btn--outline sg-btn--sm" href="/app/admin/tool-sets">
                  Manage
                </Link>
              </li>
            </ul>

            <div style={{ marginTop: 12 }}>
              <Link className="sg-btn sg-btn--black sg-btn--sm" href="/app/admin/tool-sets">
                Manage tool sets
              </Link>
            </div>
          </section>
        )}

        <ConfirmDialog
          open={pendingRevoke !== null}
          onClose={() => setPendingRevoke(null)}
          title="Revoke OAuth client?"
          destructive
          confirmLabel="Revoke"
          onConfirm={async () => {
            if (pendingRevoke) await revokeClient(pendingRevoke);
          }}
        >
          This revokes the client&apos;s pairing grants and refresh tokens immediately.
        </ConfirmDialog>
      </main>
    </div>
  );
}
