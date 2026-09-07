'use client';

import { useState, type ReactNode } from 'react';
import type { McpOAuthConnection } from '@/lib/api';
import ConfirmDialog from '@/components/kit/confirm-dialog';

interface ConnectionsListProps {
  connections: McpOAuthConnection[];
  /**
   * Performs the revoke (API call + list refresh). Throwing keeps the confirm
   * dialog open for retry — surface the failure via `error` or a toast.
   */
  onRevoke: (grantId: string) => void | Promise<void>;
  /** Panel title (default "Connected clients"). */
  title?: string;
  /** Empty-state copy override. */
  emptyHint?: ReactNode;
  loading?: boolean;
  /** Inline fetch error; rendered instead of the list when set. */
  error?: string | null;
}

/**
 * "Connected clients" section: OAuth pairing grants with confirm-guarded
 * revocation. Shared by /app/mcp-setup (and the admin hub) — replaces the
 * near-identical lists that lived in mcp-keys and the old mcp-setup page.
 */
export default function ConnectionsList({
  connections,
  onRevoke,
  title = 'Connected clients',
  emptyHint,
  loading = false,
  error = null,
}: ConnectionsListProps) {
  const [pendingRevoke, setPendingRevoke] = useState<string | null>(null);

  return (
    <section className="dash-panel" style={{ marginTop: 'var(--space-4)' }}>
      <div className="dash-panel__head">
        <h2 className="dash-panel__title">{title}</h2>
        <span className="dash-badge">{connections.length}</span>
      </div>
      <p className="sg-page-intro" style={{ marginBottom: 12 }}>
        After you click <strong>Allow</strong> for a connector, a pairing grant appears here.
        Each row is a client (e.g. Claude) allowed to call a specific MCP resource.
        Revoke to cut off that client immediately (refresh tokens stop working).
      </p>
      {error ? (
        <p className="sg-error">Failed to load connections: {error}</p>
      ) : loading ? (
        <p className="sg-page-intro">Loading connections…</p>
      ) : connections.length === 0 ? (
        <p className="sg-page-intro">
          {emptyHint ?? 'No connections yet — complete a connector setup above.'}
        </p>
      ) : (
        <ul className="admin-table-wrap">
          {connections.map((c) => (
            <li key={c.grant_id} className="gh-row">
              <div className="gh-row__main">
                <div className="gh-row__title font-mono">{c.client_id}</div>
                <div className="gh-row__sub font-mono">{c.resource}</div>
                <span className="gh-row__sub">
                  {c.scope} · grant {c.grant_id}
                </span>
              </div>
              <button
                type="button"
                className="sg-btn sg-btn--outline sg-btn--sm"
                aria-label={`Revoke connection ${c.client_id}`}
                onClick={() => setPendingRevoke(c.grant_id)}
              >
                Revoke
              </button>
            </li>
          ))}
        </ul>
      )}

      <ConfirmDialog
        open={pendingRevoke !== null}
        onClose={() => setPendingRevoke(null)}
        title="Revoke connection?"
        destructive
        confirmLabel="Revoke"
        onConfirm={async () => {
          if (pendingRevoke) await onRevoke(pendingRevoke);
        }}
      >
        Revoke this OAuth connection? Connected clients must re-authorize.
      </ConfirmDialog>
    </section>
  );
}
