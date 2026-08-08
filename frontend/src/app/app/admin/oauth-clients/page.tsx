'use client';

import { useState, useEffect } from 'react';
import { toast } from 'sonner';
import { api, type OAuthClient } from '@/lib/api';

export default function AdminOAuthClientsPage() {
  const [clients, setClients] = useState<OAuthClient[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api
      .adminListOAuthClients()
      .then((res) => setClients(res.clients))
      .catch(() => toast.error('Failed to load OAuth clients'))
      .finally(() => setLoading(false));
  }, []);

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

  if (loading) {
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
        <h1 className="sg-page-title">OAuth Clients</h1>
        <p className="sg-page-intro">
          Clients registered for MCP OAuth 2.1 — dynamically via DCR or first-party — with their active
          pairing-grant counts. Revoking a client immediately revokes its grants and refresh tokens.
        </p>

        <section className="dash-panel" style={{ marginTop: 'var(--space-4)' }}>
          <div className="dash-panel__head">
            <h2 className="dash-panel__title">Clients</h2>
            <span className="dash-badge">{clients.length}</span>
          </div>

          {clients.length === 0 ? (
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
                  {c.status === 'active' && (
                    <button className="sg-btn sg-btn--danger sg-btn--sm" onClick={() => revokeClient(c.client_id)}>
                      Revoke
                    </button>
                  )}
                </li>
              ))}
            </ul>
          )}
        </section>
      </main>
    </div>
  );
}
