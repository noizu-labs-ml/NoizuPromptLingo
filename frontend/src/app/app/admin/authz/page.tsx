'use client';

import { useState, useEffect, useCallback } from 'react';
import { toast } from 'sonner';
import { api, type McpApiKey, type McpTokenResponse, type McpServerConfig } from '@/lib/api';
import McpSetupPanel from '@/components/mcp-setup-panel';

interface AdminUser {
  id: string;
  email: string;
  user_name: string;
  status: string;
  role: string;
}

export default function AdminAuthzPage() {
  const [users, setUsers] = useState<AdminUser[]>([]);
  const [userId, setUserId] = useState('');
  const [keys, setKeys] = useState<McpApiKey[]>([]);
  const [loadingUsers, setLoadingUsers] = useState(true);
  const [loadingKeys, setLoadingKeys] = useState(false);

  // New key form
  const [label, setLabel] = useState('default');
  const [expiryChoice, setExpiryChoice] = useState<'never' | '30d' | '90d' | '1y' | 'custom'>('never');
  const [customExpiry, setCustomExpiry] = useState('');
  const [creating, setCreating] = useState(false);

  // The most recently minted raw key (shown once).
  const [revealedKey, setRevealedKey] = useState<{ id: string; raw: string } | null>(null);

  // MCP tokens by api key id (for setup panel).
  const [tokens, setTokens] = useState<Record<string, McpTokenResponse>>({});

  // Which key's setup panel is open.
  const [setupKey, setSetupKey] = useState<string | null>(null);

  // Server config from the backend (host-derived, never hardcoded).
  const [servers, setServers] = useState<McpServerConfig[]>([]);

  // Paste-an-existing-key flow (non-destructive token mint for the selected user).
  const [pastedKey, setPastedKey] = useState('');
  const [minting, setMinting] = useState(false);

  const fetchKeys = useCallback(async (uid: string) => {
    if (!uid) {
      setKeys([]);
      return;
    }
    setLoadingKeys(true);
    setRevealedKey(null);
    try {
      const res = await api.adminListMcpKeys(uid);
      setKeys(res.keys);
    } catch {
      toast.error('Failed to load MCP keys');
    } finally {
      setLoadingKeys(false);
    }
  }, []);

  useEffect(() => {
    api
      .adminListUsers()
      .then((res) => {
        setUsers(res.users);
        const firstId = res.users[0]?.id ?? '';
        setUserId(firstId);
        fetchKeys(firstId);
      })
      .catch(() => toast.error('Failed to load users'))
      .finally(() => setLoadingUsers(false));
    api.mcpConfig().then((cfg) => setServers(cfg.servers)).catch(() => { /* non-fatal */ });
  }, [fetchKeys]);

  // Resolves the expiry form state to an ISO8601 string, or undefined for
  // "never expires".
  function computeExpiresAt(): string | undefined {
    const now = Date.now();
    const days = { '30d': 30, '90d': 90, '1y': 365 } as const;
    if (expiryChoice === 'never') return undefined;
    if (expiryChoice === 'custom') {
      return customExpiry ? new Date(customExpiry).toISOString() : undefined;
    }
    return new Date(now + days[expiryChoice] * 24 * 60 * 60 * 1000).toISOString();
  }

  async function createKey(e: React.FormEvent) {
    e.preventDefault();
    if (!userId) return;
    setCreating(true);
    try {
      const { key, raw_key } = await api.adminCreateMcpKey(userId, label.trim() || 'default', computeExpiresAt());
      setKeys((prev) => [key, ...prev.filter((k) => k.id !== key.id)]);
      setRevealedKey({ id: key.id, raw: raw_key });
      toast.success('MCP key created — copy it now, it won’t be shown again');

      // Auto-mint a token for the new key so setup is one click. Uses the
      // public possession-only mint (POST /api/mcp/token) — it only requires
      // the raw key, so this works regardless of which user it belongs to.
      try {
        const tokenData = await api.mintMcpToken(raw_key);
        setTokens((prev) => ({ ...prev, [key.id]: tokenData }));
        setSetupKey(key.id);
      } catch (tokenErr) {
        toast.error(tokenErr instanceof Error ? tokenErr.message : 'Failed to mint token for new key');
      }
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to create key');
    } finally {
      setCreating(false);
    }
  }

  async function mintFromPaste(e: React.FormEvent) {
    e.preventDefault();
    const raw = pastedKey.trim();
    if (!raw) return;
    setMinting(true);
    try {
      const tokenData = await api.mintMcpToken(raw);
      await fetchKeys(userId);
      setTokens((prev) => ({ ...prev, '__pasted__': tokenData }));
      setSetupKey('__pasted__');
      setPastedKey('');
      toast.success('MCP token minted from pasted key');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to mint token');
    } finally {
      setMinting(false);
    }
  }

  async function revokeKey(id: string) {
    if (!userId || !confirm('Revoke this MCP key? Clients using it will lose access immediately.')) return;
    try {
      const { key } = await api.adminRevokeMcpKey(userId, id);
      setKeys((prev) => prev.map((k) => (k.id === id ? key : k)));
      setTokens((prev) => {
        const n = { ...prev };
        delete n[id];
        return n;
      });
      toast.success('Key revoked');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to revoke key');
    }
  }

  async function copyRaw(raw: string) {
    try {
      await navigator.clipboard.writeText(raw);
      toast.success('Copied to clipboard');
    } catch {
      toast.error('Copy failed — select and copy manually');
    }
  }

  function timeAgo(dt?: string | null) {
    if (!dt) return 'never';
    const diff = Date.now() - new Date(dt).getTime();
    const mins = Math.floor(diff / 60000);
    if (mins < 1) return 'just now';
    if (mins < 60) return `${mins}m ago`;
    const hrs = Math.floor(mins / 60);
    if (hrs < 24) return `${hrs}h ago`;
    return `${Math.floor(hrs / 24)}d ago`;
  }

  function expiryLabel(dt?: string | null) {
    if (!dt) return 'no expiry';
    const diff = new Date(dt).getTime() - Date.now();
    if (diff <= 0) return 'expired';
    const days = Math.ceil(diff / 86400000);
    return days < 1 ? 'expires <1d' : `expires in ${days}d`;
  }

  if (loadingUsers) {
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
        <h1 className="sg-page-title">Authz — MCP Keys</h1>
        <p className="sg-page-intro">
          Mint and revoke long-lived MCP API keys for a user. Clients exchange a key for a short-lived MCP JWT at
          <span className="font-mono"> POST /api/mcp/token</span>. The raw key is shown only once at creation.
        </p>

        <div className="sg-field">
          <label htmlFor="authz-user">User</label>
          <select id="authz-user" value={userId} onChange={(e) => { setUserId(e.target.value); fetchKeys(e.target.value); }}>
            {users.map((u) => (
              <option key={u.id} value={u.id}>
                {u.email} ({u.role})
              </option>
            ))}
          </select>
        </div>

        {/* Connect an existing key (non-destructive). */}
        <section className="dash-panel" style={{ marginTop: 'var(--space-4)' }}>
          <div className="dash-panel__head">
            <h2 className="dash-panel__title">Connect an existing key</h2>
          </div>
          <p className="sg-page-intro" style={{ marginBottom: 12 }}>
            Paste a raw API key to mint an MCP token for it — possession of the key is all that's required, so
            this mints for whoever the key belongs to, not necessarily the user selected above.
          </p>
          <form className="gh-add-form" onSubmit={mintFromPaste}>
            <input
              className="gh-add-form__input"
              value={pastedKey}
              onChange={(e) => setPastedKey(e.target.value)}
              placeholder="Paste raw API key"
              aria-label="Raw API key"
              style={{ flex: 2 }}
            />
            <button className="sg-btn sg-btn--black sg-btn--sm" type="submit" disabled={minting || !pastedKey.trim()}>
              {minting ? 'Minting…' : 'Mint Token'}
            </button>
          </form>
        </section>

        <section className="dash-panel" style={{ marginTop: 'var(--space-4)' }}>
          <div className="dash-panel__head">
            <h2 className="dash-panel__title">Create key</h2>
          </div>

          <form className="gh-add-form" onSubmit={createKey}>
            <input
              className="gh-add-form__input"
              value={label}
              onChange={(e) => setLabel(e.target.value)}
              placeholder="Label (e.g. ci-bot)"
              aria-label="Label"
            />
            <select
              className="gh-add-form__input"
              value={expiryChoice}
              onChange={(e) => setExpiryChoice(e.target.value as typeof expiryChoice)}
              aria-label="Expiry"
            >
              <option value="never">Never expires</option>
              <option value="30d">30 days</option>
              <option value="90d">90 days</option>
              <option value="1y">1 year</option>
              <option value="custom">Custom date…</option>
            </select>
            {expiryChoice === 'custom' && (
              <input
                className="gh-add-form__input"
                type="date"
                value={customExpiry}
                onChange={(e) => setCustomExpiry(e.target.value)}
                aria-label="Expiry date"
                min={new Date().toISOString().slice(0, 10)}
              />
            )}
            <button className="sg-btn sg-btn--black sg-btn--sm" type="submit" disabled={creating || !userId}>
              {creating ? 'Creating…' : 'Generate key'}
            </button>
          </form>

          {revealedKey && (
            <div className="authz-reveal">
              <div className="authz-reveal__label">Raw key (shown once):</div>
              <div className="authz-reveal__row">
                <code className="authz-reveal__key font-mono">{revealedKey.raw}</code>
                <button className="sg-btn sg-btn--outline sg-btn--sm" onClick={() => copyRaw(revealedKey.raw)}>
                  Copy
                </button>
              </div>
              <p className="sg-page-intro">Store this securely — it cannot be retrieved again.</p>
            </div>
          )}
        </section>

        <section className="dash-panel" style={{ marginTop: 'var(--space-4)' }}>
          <div className="dash-panel__head">
            <h2 className="dash-panel__title">Keys</h2>
            <span className="dash-badge">{keys.length}</span>
          </div>

          {loadingKeys ? (
            <p className="sg-page-intro">Loading…</p>
          ) : keys.length === 0 ? (
            <p className="sg-page-intro">No MCP keys yet.</p>
          ) : (
            <ul className="admin-table-wrap">
              {keys.map((k) => {
                const hasToken = !!tokens[k.id];
                return (
                  <li key={k.id} className="gh-row">
                    <div className="gh-row__main">
                      <div className="gh-row__title">{k.label}</div>
                      <div className="gh-row__sub font-mono">{k.key_prefix}…</div>
                      <span className={`gh-grant__level gh-grant__level--${k.status === 'active' ? 'member' : 'viewer'}`}>
                        {k.status}
                      </span>
                      <span className="gh-row__sub">last used {timeAgo(k.last_used_at)}</span>
                      <span className="gh-row__sub">{expiryLabel(k.expires_at)}</span>
                    </div>

                    <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
                      {k.status === 'active' && hasToken && (
                        <>
                          <button
                            onClick={() => setSetupKey(setupKey === k.id ? null : k.id)}
                            className="sg-btn sg-btn--outline sg-btn--sm"
                            style={{
                              ...(setupKey === k.id
                                ? { background: 'var(--accent-dim)', color: 'var(--accent)', borderColor: 'var(--accent)' }
                                : {})
                            }}
                          >
                            Setup
                          </button>
                          <button
                            className="sg-btn sg-btn--outline sg-btn--sm"
                            onClick={() => copyRaw(tokens[k.id].token)}
                          >
                            Copy Token
                          </button>
                        </>
                      )}
                      {k.status === 'active' && !hasToken && (
                        <span className="gh-row__sub">paste raw key above to mint a token</span>
                      )}
                      {k.status === 'active' && (
                        <button className="sg-btn sg-btn--danger sg-btn--sm" onClick={() => revokeKey(k.id)}>
                          Revoke
                        </button>
                      )}
                    </div>
                  </li>
                );
              })}
            </ul>
          )}
        </section>

        {/* Setup panel for the selected key with a minted token. */}
        {setupKey && tokens[setupKey] && servers.length > 0 && (
          (() => {
            const key = keys.find((k) => k.id === setupKey);
            return (
              <McpSetupPanel
                token={tokens[setupKey].token}
                keyLabel={key?.label ?? 'pasted key'}
                servers={servers}
                onClose={() => setSetupKey(null)}
              />
            );
          })()
        )}
      </main>
    </div>
  );
}
