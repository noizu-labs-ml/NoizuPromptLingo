'use client';

import { useState, useEffect, useCallback, useMemo } from 'react';
import { toast } from 'sonner';
import { api, type McpApiKey, type McpTokenResponse, type BrowserCapture } from '@/lib/api';
import { useOrgId } from '@/context/org';

// API base — mirrors NEXT_PUBLIC_API_URL used inside lib/api. Media `url` values
// are relative `/media/<short_id>` paths, so we prefix them with this.
const API_URL = process.env.NEXT_PUBLIC_API_URL || '';

// Build the socket URL the controller connects back to (wss on the API host).
function socketUrl(): string {
  try {
    return `wss://${new URL(API_URL).host}/socket`;
  } catch {
    // API_URL may be empty (same-origin dev); fall back to the page origin.
    if (typeof window !== 'undefined') return `wss://${window.location.host}/socket`;
    return 'wss://localhost/socket';
  }
}

// The install.sh script bakes in the minted token, org, and socket URL so the
// controller can self-configure. Generated client-side and downloaded as a Blob
// so the secret token never travels in a URL.
function installScript(token: string, orgId: string): string {
  return `#!/usr/bin/env bash
set -euo pipefail
export BROWSER_CONTROLLER_URL="${socketUrl()}"
export BROWSER_CONTROLLER_TOKEN="${token}"
export BROWSER_CONTROLLER_ORG="${orgId}"
curl -L "${API_URL}/api/v1/config/browser-controller/download" -o noizu-browser-controller.tar.gz
tar xzf noizu-browser-controller.tar.gz && cd browser-controller
npm i && npm run build
node dist/index.js
`;
}

function timeAgo(dt?: string) {
  if (!dt) return '';
  const diff = Date.now() - new Date(dt).getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 1) return 'just now';
  if (mins < 60) return `${mins}m ago`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `${hrs}h ago`;
  return `${Math.floor(hrs / 24)}d ago`;
}

export default function BrowserPage() {
  const { orgId, loading: orgLoading } = useOrgId();

  // ── Connect / register state ──
  const [keys, setKeys] = useState<McpApiKey[]>([]);
  const [pastedKey, setPastedKey] = useState('');
  const [label, setLabel] = useState('');
  const [creating, setCreating] = useState(false);
  const [minting, setMinting] = useState(false);
  // Raw key from a just-created key (shown once). Lets the user mint without re-pasting.
  const [newKey, setNewKey] = useState<{ id: string; raw_key: string } | null>(null);
  const [token, setToken] = useState<McpTokenResponse | null>(null);
  const [copied, setCopied] = useState<string | null>(null);

  // ── Status + captures ──
  const [connected, setConnected] = useState<boolean | null>(null);
  const [captures, setCaptures] = useState<BrowserCapture[]>([]);

  const fetchKeys = useCallback(async () => {
    try {
      const data = await api.listMcpKeys();
      setKeys(data.keys || []);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load keys');
    }
  }, []);

  useEffect(() => {
    fetchKeys();
  }, [fetchKeys]);

  // Poll connection status every ~5s.
  useEffect(() => {
    if (!orgId) return;
    let cancelled = false;
    const tick = () => {
      api.browserStatus(orgId)
        .then((res) => { if (!cancelled) setConnected(res.connected); })
        .catch(() => { /* transient — leave prior state */ });
    };
    tick();
    const h = setInterval(tick, 5000);
    return () => { cancelled = true; clearInterval(h); };
  }, [orgId]);

  // Poll captures every ~10s.
  useEffect(() => {
    if (!orgId) return;
    let cancelled = false;
    const tick = () => {
      api.browserCaptures(orgId)
        .then((res) => { if (!cancelled) setCaptures(res.captures || []); })
        .catch(() => { /* transient */ });
    };
    tick();
    const h = setInterval(tick, 10000);
    return () => { cancelled = true; clearInterval(h); };
  }, [orgId]);

  async function createKey(e: React.FormEvent) {
    e.preventDefault();
    setCreating(true);
    setNewKey(null);
    try {
      const data = await api.createMcpKey(label.trim() || 'browser-controller');
      setNewKey({ id: data.key.id, raw_key: data.raw_key });
      setLabel('');
      await fetchKeys();
      // Auto-mint a connect token so setup is one step.
      try {
        const tok = await api.mintMcpTokenAuthenticated(data.raw_key);
        setToken(tok);
        toast.success('Key created and connect token minted');
      } catch {
        toast.success('Key created — mint a connect token below');
      }
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to create key');
    } finally {
      setCreating(false);
    }
  }

  async function mintFrom(raw: string) {
    const key = raw.trim();
    if (!key) return;
    setMinting(true);
    try {
      const tok = await api.mintMcpTokenAuthenticated(key);
      setToken(tok);
      setPastedKey('');
      toast.success('Connect token minted');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to mint token');
    } finally {
      setMinting(false);
    }
  }

  function copyText(text: string, id: string) {
    navigator.clipboard.writeText(text)
      .then(() => {
        setCopied(id);
        setTimeout(() => setCopied(null), 2000);
        toast.success('Copied to clipboard');
      })
      .catch(() => toast.error('Copy failed — select and copy manually'));
  }

  // Trigger a client-side download of install.sh with the secret baked in.
  function downloadInstall() {
    if (!token || !orgId) return;
    const blob = new Blob([installScript(token.token, orgId)], { type: 'text/x-shellscript' });
    const href = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = href;
    a.download = 'install.sh';
    document.body.appendChild(a);
    a.click();
    a.remove();
    URL.revokeObjectURL(href);
  }

  const runCommand = useMemo(
    () => 'chmod +x install.sh && ./install.sh',
    [],
  );

  return (
    <div className="content">
      <main>
        <h1 className="sg-page-title">Browser</h1>
        <p className="sg-page-intro">
          Connect a headless browser controller to this organization, then watch its
          screenshots and recordings stream into the gallery below.
        </p>

        {/* ── Connect / register ── */}
        <section className="dash-panel" style={{ marginTop: 'var(--space-4)' }}>
          <div className="dash-panel__head">
            <h2 className="dash-panel__title">Connect a controller</h2>
          </div>
          <p className="sg-page-intro" style={{ marginBottom: 12 }}>
            Mint a connect token from an MCP API key, then download the controller and its
            install script. The raw key is shown only once at creation — paste an existing
            raw key, or create a new key to mint a token.
          </p>

          {/* Paste an existing raw key to mint. */}
          <form
            className="gh-add-form"
            onSubmit={(e) => { e.preventDefault(); mintFrom(pastedKey); }}
          >
            <input
              className="gh-add-form__input"
              value={pastedKey}
              onChange={(e) => setPastedKey(e.target.value)}
              placeholder="Paste raw MCP API key"
              aria-label="Raw API key"
              style={{ flex: 2 }}
            />
            <button className="sg-btn sg-btn--black sg-btn--sm" type="submit" disabled={minting || !pastedKey.trim()}>
              {minting ? 'Minting…' : 'Mint connect token'}
            </button>
          </form>

          {/* Or create a new key (which auto-mints). */}
          <form className="gh-add-form" onSubmit={createKey} style={{ marginTop: 8 }}>
            <input
              className="gh-add-form__input"
              value={label}
              onChange={(e) => setLabel(e.target.value)}
              placeholder="New key label (e.g. browser-controller)"
              aria-label="Key label"
            />
            <button className="sg-btn sg-btn--outline sg-btn--sm" type="submit" disabled={creating}>
              {creating ? 'Creating…' : 'Create key & mint'}
            </button>
          </form>

          {newKey && (
            <div className="authz-reveal" style={{ marginTop: 16 }}>
              <div className="authz-reveal__label">Raw key (shown once):</div>
              <div className="authz-reveal__row">
                <code className="authz-reveal__key font-mono">{newKey.raw_key}</code>
                <button
                  className="sg-btn sg-btn--outline sg-btn--sm"
                  onClick={() => copyText(newKey.raw_key, 'raw-key')}>
                  {copied === 'raw-key' ? 'Copied!' : 'Copy'}
                </button>
              </div>
              <p className="sg-page-intro">Store this securely — it cannot be retrieved again.</p>
            </div>
          )}

          {keys.length > 0 && !newKey && (
            <p className="sg-field__hint" style={{ marginTop: 8 }}>
              You have {keys.length} MCP key{keys.length === 1 ? '' : 's'}. Paste a raw key above to mint a connect token.
            </p>
          )}

          {/* After minting: download buttons + run command. */}
          {token && orgId && (
            <div style={{ marginTop: 16 }}>
              <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', alignItems: 'center' }}>
                <a
                  className="sg-btn sg-btn--black sg-btn--sm"
                  href={api.browserControllerDownloadUrl()}
                  download
                >
                  Download controller
                </a>
                <button className="sg-btn sg-btn--black sg-btn--sm" onClick={downloadInstall}>
                  Download install.sh
                </button>
                <span className="sg-field__hint">
                  Token expires {token.expires_at ? timeAgo(token.expires_at) || new Date(token.expires_at).toLocaleString() : 'soon'}
                </span>
              </div>

              <div className="authz-reveal" style={{ marginTop: 16 }}>
                <div className="authz-reveal__label">Run the controller:</div>
                <div className="authz-reveal__row">
                  <code className="authz-reveal__key font-mono">{runCommand}</code>
                  <button
                    className="sg-btn sg-btn--outline sg-btn--sm"
                    onClick={() => copyText(runCommand, 'run-cmd')}>
                    {copied === 'run-cmd' ? 'Copied!' : 'Copy'}
                  </button>
                </div>
                <p className="sg-page-intro">
                  The downloaded <span className="font-mono">install.sh</span> bakes in your
                  connect token, org, and socket URL.
                </p>
              </div>
            </div>
          )}
        </section>

        {/* ── Status ── */}
        <section className="dash-panel" style={{ marginTop: 'var(--space-4)' }}>
          <div className="dash-panel__head">
            <h2 className="dash-panel__title">Status</h2>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            <span
              aria-hidden
              style={{
                color: connected ? 'var(--success, #1a7f37)' : 'var(--muted, #888)',
                fontSize: 18,
                lineHeight: 1,
              }}
            >
              {connected ? '●' : '○'}
            </span>
            <span>
              {connected === null
                ? 'Checking…'
                : connected
                  ? 'Controller connected'
                  : 'Waiting for controller…'}
            </span>
          </div>
        </section>

        {/* ── Captures gallery ── */}
        <section className="dash-panel" style={{ marginTop: 'var(--space-4)' }}>
          <div className="dash-panel__head">
            <h2 className="dash-panel__title">Captures</h2>
            <span className="dash-badge">{captures.length}</span>
          </div>

          {captures.length === 0 ? (
            <p className="sg-page-intro">No captures yet. Connected controllers stream screenshots and recordings here.</p>
          ) : (
            <div className="projects-grid">
              {captures.map((c) => {
                const src = `${API_URL}${c.url}`;
                return (
                  <a key={c.id} className="project-card" href={src} target="_blank" rel="noreferrer">
                    <div className="project-card__body">
                      {c.media_type === 'video' ? (
                        <video src={src} controls style={{ width: '100%', borderRadius: 6, display: 'block' }} />
                      ) : (
                        // eslint-disable-next-line @next/next/no-img-element
                        <img src={src} alt={c.short_id} style={{ width: '100%', borderRadius: 6, display: 'block' }} />
                      )}
                      <div className="project-card__meta" style={{ marginTop: 8 }}>
                        <span className="project-card__status">{c.media_type}</span>
                        <span className="project-card__time">{timeAgo(c.inserted_at)}</span>
                      </div>
                    </div>
                  </a>
                );
              })}
            </div>
          )}
        </section>

        {orgLoading && <p className="sg-page-intro">Loading…</p>}
      </main>
    </div>
  );
}
