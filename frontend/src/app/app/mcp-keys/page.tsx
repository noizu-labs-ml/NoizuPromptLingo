'use client';

import { useState, useEffect, useCallback } from 'react';
import { toast } from 'sonner';
import { api, type McpApiKey, type McpTokenResponse, type McpServerConfig } from '@/lib/api';
import McpSetupPanel from '@/components/mcp-setup-panel';

export default function McpKeysPage() {
  const [keys, setKeys] = useState<McpApiKey[]>([]);
  // Tokens keyed by api key id (not prefix) — stable across renders.
  const [tokens, setTokens] = useState<Record<string, McpTokenResponse>>({});
  const [newKey, setNewKey] = useState<{ id: string; raw_key: string } | null>(null);
  const [label, setLabel] = useState("");
  const [loading, setLoading] = useState(false);
  const [copied, setCopied] = useState<string | null>(null);
  const [setupKey, setSetupKey] = useState<string | null>(null);

  // Server config (fetched once from backend so the setup panel never hardcodes a host).
  const [servers, setServers] = useState<McpServerConfig[]>([]);

  // Paste-an-existing-key flow: lets a logged-in user recover setup access for a
  // key whose raw value they still hold, without recreating it.
  const [pastedKey, setPastedKey] = useState("");
  const [minting, setMinting] = useState(false);

  const fetchKeys = useCallback(async () => {
    try {
      const data = await api.listMcpKeys();
      setKeys(data.keys || []);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to load keys");
    }
  }, []);

  useEffect(() => {
    fetchKeys();
    api.mcpConfig().then((cfg) => setServers(cfg.servers)).catch(() => { /* non-fatal */ });
  }, [fetchKeys]);

  async function createKey(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    setNewKey(null);

    try {
      const data = await api.createMcpKey(label.trim() || "default");
      setNewKey({ id: data.key.id, raw_key: data.raw_key });
      setLabel("");
      await fetchKeys();

      // Auto-mint a token via the authenticated endpoint so setup is one click.
      try {
        const tokenRes = await api.mintMcpTokenAuthenticated(data.raw_key);
        setTokens((prev) => ({ ...prev, [data.key.id]: tokenRes }));
        setSetupKey(data.key.id);
        toast.success("MCP API key created");
      } catch (tokenErr) {
        console.error("Failed to auto-mint token for new key:", tokenErr);
        toast.success("MCP API key created — paste it below to mint a token");
      }
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to create key");
    } finally {
      setLoading(false);
    }
  }

  async function mintFromPaste(e: React.FormEvent) {
    e.preventDefault();
    const raw = pastedKey.trim();
    if (!raw) return;
    setMinting(true);
    try {
      const tokenRes = await api.mintMcpTokenAuthenticated(raw);
      // The backend verifies the key belongs to the caller; match it to a known key
      // by refetching so we can attach the token to the right row.
      await fetchKeys();
      // We don't know which key id the pasted key maps to from the response, so
      // stash the token under a synthetic id and surface it in the setup panel.
      setTokens((prev) => ({ ...prev, "__pasted__": tokenRes }));
      setSetupKey("__pasted__");
      setPastedKey("");
      toast.success("MCP token minted from pasted key");
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to mint token");
    } finally {
      setMinting(false);
    }
  }

  async function revokeKey(id: string) {
    if (!confirm("Revoke this MCP key? Clients using it will lose access immediately.")) return;
    try {
      await api.revokeMcpKey(id);
      setTokens((prev) => {
        const n = { ...prev };
        delete n[id];
        return n;
      });
      setSetupKey((prev) => prev === id ? null : prev);
      await fetchKeys();
      toast.success("Key revoked");
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to revoke key");
    }
  }

  function copyText(text: string, id: string) {
    navigator.clipboard.writeText(text)
      .then(() => {
        setCopied(id);
        setTimeout(() => setCopied(null), 2000);
        toast.success("Copied to clipboard");
      })
      .catch(() => toast.error("Copy failed — select and copy manually"));
  }

  function timeAgo(dt?: string | null) {
    if (!dt) return "never";
    const diff = Date.now() - new Date(dt).getTime();
    const mins = Math.floor(diff / 60000);
    if (mins < 1) return "just now";
    if (mins < 60) return `${mins}m ago`;
    const hrs = Math.floor(mins / 60);
    if (hrs < 24) return `${hrs}h ago`;
    return `${Math.floor(hrs / 24)}d ago`;
  }

  return (
    <div className="content">
      <main>
        <h1 className="sg-page-title">MCP Keys & Setup</h1>
        <p className="sg-page-intro">
          Create and manage your API keys for MCP server access. Use the setup panel to get
          the <span className="font-mono"> claude mcp add</span> commands to connect to all MCP servers.
        </p>

        {/* Paste an existing key to mint a token (non-destructive). */}
        <section className="dash-panel" style={{ marginTop: 'var(--space-4)' }}>
          <div className="dash-panel__head">
            <h2 className="dash-panel__title">Connect an existing key</h2>
          </div>
          <p className="sg-page-intro" style={{ marginBottom: 12 }}>
            Already have a raw API key? Paste it here — combined with your login it mints an MCP
            token without creating a new key. The backend verifies the key belongs to you.
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
              {minting ? "Minting…" : "Mint Token"}
            </button>
          </form>
        </section>

        {/* Create key form */}
        <section className="dash-panel" style={{ marginTop: 'var(--space-4)' }}>
          <div className="dash-panel__head">
            <h2 className="dash-panel__title">Create MCP Key</h2>
          </div>

          <form className="gh-add-form" onSubmit={createKey}>
            <input
              className="gh-add-form__input"
              value={label}
              onChange={(e) => setLabel(e.target.value)}
              placeholder="Label (e.g. ci-bot, local-dev)"
              aria-label="Key label"
            />
            <button className="sg-btn sg-btn--black sg-btn--sm" type="submit" disabled={loading}>
              {loading ? "Creating…" : "Generate Key"}
            </button>
          </form>

          {newKey && (
            <div className="authz-reveal" style={{ marginTop: 16 }}>
              <div className="authz-reveal__label">Raw key (shown once):</div>
              <div className="authz-reveal__row">
                <code className="authz-reveal__key font-mono">{newKey.raw_key}</code>
                <button
                  className="sg-btn sg-btn--outline sg-btn--sm"
                  onClick={() => copyText(newKey.raw_key, newKey.id)}>
                  {copied === newKey.id ? "Copied!" : "Copy"}
                </button>
              </div>
              <p className="sg-page-intro">Store this securely — it cannot be retrieved again.</p>
            </div>
          )}
        </section>

        {/* Keys list */}
        <section className="dash-panel" style={{ marginTop: 'var(--space-4)' }}>
          <div className="dash-panel__head">
            <h2 className="dash-panel__title">Your Keys</h2>
            <span className="dash-badge">{keys.length}</span>
          </div>

          {keys.length === 0 ? (
            <p className="sg-page-intro">No MCP keys yet. Create one to get started.</p>
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
                    </div>

                    <div style={{ display: "flex", gap: 8, alignItems: "center" }}>
                      {k.status === "active" && hasToken && (
                        <>
                          <button
                            onClick={() => setSetupKey(setupKey === k.id ? null : k.id)}
                            className="sg-btn sg-btn--outline sg-btn--sm"
                            style={{
                              ...(setupKey === k.id
                                ? { background: "var(--accent-dim)", color: "var(--accent)", borderColor: "var(--accent)" }
                                : {})
                            }}
                          >
                            Setup
                          </button>
                          <button
                            className="sg-btn sg-btn--outline sg-btn--sm"
                            onClick={() => copyText(tokens[k.id].token, `token-${k.id}`)}
                          >
                            {copied === `token-${k.id}` ? "Copied!" : "Copy Token"}
                          </button>
                        </>
                      )}
                      {k.status === "active" && !hasToken && (
                        <span className="gh-row__sub">paste raw key above to mint a token</span>
                      )}
                      {k.status === "active" && (
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

        {/* Setup panel for a key with a minted token */}
        {setupKey && tokens[setupKey] && servers.length > 0 && (
          (() => {
            const key = keys.find((k) => k.id === setupKey);
            return (
              <McpSetupPanel
                token={tokens[setupKey].token}
                keyLabel={key?.label ?? "pasted key"}
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
