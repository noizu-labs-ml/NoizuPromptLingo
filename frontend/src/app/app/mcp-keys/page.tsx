'use client';

import { useState, useEffect, useCallback } from 'react';
import { toast } from 'sonner';
import {
  api,
  type McpApiKey,
  type McpTokenResponse,
  type McpServerConfig,
  type McpOAuthConnection,
  type McpCustomGroup,
  type McpCustomScope,
} from '@/lib/api';
import McpSetupPanel from '@/components/mcp-setup-panel';
import McpOauthSetup from '@/components/mcp-oauth-setup';
import McpEndpointManager from '@/components/mcp-endpoint-manager';

// Install snippet for the optional Local Tools MCP (filesystem/git tools).
const LOCAL_MCP_INSTALL = `tar xzf noizu-local-mcp.tar.gz && cd local-mcp && npm i && npm run build
# Claude Code
claude mcp add noizu-local -- node "$PWD/dist/index.js"
# Codex
codex mcp add noizu-local -- node "$PWD/dist/index.js"
# Grok
grok mcp add noizu-local -- node "$PWD/dist/index.js"`;

export default function McpKeysPage() {
  const [keys, setKeys] = useState<McpApiKey[]>([]);
  const [connections, setConnections] = useState<McpOAuthConnection[]>([]);
  // Tokens keyed by api key id (not prefix) — stable across renders.
  const [tokens, setTokens] = useState<Record<string, McpTokenResponse>>({});
  const [newKey, setNewKey] = useState<{ id: string; raw_key: string } | null>(null);
  const [label, setLabel] = useState("");
  const [loading, setLoading] = useState(false);
  const [copied, setCopied] = useState<string | null>(null);
  const [setupKey, setSetupKey] = useState<string | null>(null);

  // Server config (fetched once from backend so the setup panel never hardcodes a host).
  const [servers, setServers] = useState<McpServerConfig[]>([]);
  const [alaCarte, setAlaCarte] = useState<McpServerConfig[]>([]);
  const [catalog, setCatalog] = useState<McpCustomGroup[]>([]);
  const [defaultScope, setDefaultScope] = useState<McpCustomScope | null>(null);
  const [templates, setTemplates] = useState<McpCustomScope[]>([]);
  const [endpoints, setEndpoints] = useState<McpCustomScope[]>([]);
  const [oauthMcpUrl, setOauthMcpUrl] = useState('https://tobor.locker/mcp');
  const [oauthIssuer, setOauthIssuer] = useState('https://tobor.locker');
  const [asMetadataUrl, setAsMetadataUrl] = useState(
    'https://tobor.locker/.well-known/oauth-authorization-server'
  );
  const [legacyMintEnabled, setLegacyMintEnabled] = useState(true);
  // The setup panel only renders when servers.length > 0; if the catalog fetch
  // fails we surface the error here instead of letting the section vanish silently.
  const [configError, setConfigError] = useState<string | null>(null);

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

  const fetchConnections = useCallback(async () => {
    try {
      const data = await api.listMcpConnections();
      setConnections(data.connections || []);
    } catch {
      // Endpoint may 404 on older deploys — ignore
      setConnections([]);
    }
  }, []);

  useEffect(() => {
    fetchKeys();
    fetchConnections();
    api
      .mcpConfig({ packaging: "setup" })
      .then((cfg) => {
        setServers(cfg.servers);
        setAlaCarte(cfg.ala_carte ?? []);
        if (cfg.default_scope) setDefaultScope(cfg.default_scope);
        api.listMcpEndpoints().then((res) => {
          setTemplates(res.templates ?? []);
          setEndpoints(res.endpoints ?? []);
          if (res.default_scope) {
            setDefaultScope(res.default_scope);
            setOauthMcpUrl(res.default_scope.url || cfg.oauth?.mcp_url || `https://${cfg.host}/custom/tobor/mcp`);
          }
        }).catch(() => {
          // Picker is optional; setup URL from packaging=setup still works.
        });
        const issuer = cfg.oauth?.issuer || `https://${cfg.host}`;
        setOauthIssuer(issuer);
        setOauthMcpUrl(
          cfg.default_scope?.url ||
            cfg.oauth?.mcp_url ||
            `https://${cfg.host}/custom/tobor/mcp`
        );
        setAsMetadataUrl(
          cfg.oauth?.authorization_server_metadata ||
            `${issuer.replace(/\/$/, '')}/.well-known/oauth-authorization-server`
        );
        setLegacyMintEnabled(cfg.legacy_api_key_mint_enabled !== false);
        setConfigError(null);
      })
      .catch((err) => {
        // A failed catalog fetch would otherwise leave servers empty and the
        // setup panel hidden with no indication of why — surface it explicitly.
        console.error("Failed to load MCP server config:", err);
        setConfigError(err instanceof Error ? err.message : "Unknown error");
      });
    api.mcpCatalog().then((res) => setCatalog(res.groups ?? [])).catch(() => {
      // Include editor is optional; setup URL still works without it.
    });
  }, [fetchKeys, fetchConnections]);

  function applyScope(scope: McpCustomScope) {
    setDefaultScope(scope);
    if (scope.url) {
      setOauthMcpUrl(scope.url);
      setServers([
        {
          id: `custom:${scope.slug}`,
          label: scope.name,
          required: true,
          default: true,
          desc: scope.description || "Custom MCP include scope",
          url: scope.url,
          kind: scope.kind,
        },
      ]);
    }
  }

  async function createKey(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    setNewKey(null);

    try {
      const data = await api.createMcpSetupKey(label.trim() || "default", {
        resource: defaultScope?.url || undefined,
      });
      setNewKey({ id: data.key.id, raw_key: data.raw_key });
      setLabel("");
      await fetchKeys();
      setTokens((prev) => ({
        ...prev,
        [data.key.id]: { token: data.token, expires_at: data.expires_at },
      }));
      setSetupKey(data.key.id);
      toast.success("Key generated — add command is ready below");
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

  async function revokeConnection(grantId: string) {
    if (!confirm("Revoke this OAuth connection? Connected clients must re-authorize.")) return;
    try {
      await api.revokeMcpConnection(grantId);
      await fetchConnections();
      toast.success("Connection revoked");
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to revoke connection");
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
        <h1 className="sg-page-title">MCP client setup</h1>
        <p className="sg-page-intro">
          <strong>Tobor Locker</strong> is the standard custom endpoint
          {defaultScope?.slug ? (
            <>
              {' '}(<span className="font-mono">/custom/{defaultScope.slug}/mcp</span>)
            </>
          ) : null}
          . Every user and organization gets one from that template. Choose it,
          edit what it includes, or copy it. <strong>OAuth is preferred</strong> —
          hosted clients invent their own <code className="font-mono">client_id</code> via
          Dynamic Client Registration. The À la carte tab is the old per-subdomain flow.
        </p>

        <McpEndpointManager
          templates={templates}
          endpoints={endpoints}
          selected={defaultScope}
          catalog={catalog}
          onSelect={applyScope}
          onChange={({ templates: nextTemplates, endpoints: nextEndpoints, selected }) => {
            setTemplates(nextTemplates);
            setEndpoints(nextEndpoints);
            applyScope(selected);
          }}
        />

        <McpOauthSetup
          mcpUrl={oauthMcpUrl}
          asMetadataUrl={asMetadataUrl}
          issuer={oauthIssuer}
          servers={servers}
          alaCarte={alaCarte}
          catalog={catalog}
          defaultScope={defaultScope}
          onDefaultScopeChange={applyScope}
        />

        <section className="dash-panel" style={{ marginTop: 'var(--space-4)' }}>
          <div className="dash-panel__head">
            <h2 className="dash-panel__title">Your OAuth connections</h2>
            <span className="dash-badge">{connections.length}</span>
          </div>
          <p className="sg-page-intro" style={{ marginBottom: 12 }}>
            After you click <strong>Allow</strong> for a connector, a pairing grant appears here.
            Each row is a client (e.g. Claude) allowed to call a specific MCP resource.
            Revoke to cut off that client immediately (refresh tokens stop working).
          </p>
          {connections.length === 0 ? (
            <p className="sg-page-intro">
              No connections yet — complete a connector setup above. Nothing to copy; the grant is
              created automatically after consent.
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
                    className="sg-btn sg-btn--outline sg-btn--sm"
                    onClick={() => revokeConnection(c.grant_id)}
                  >
                    Revoke
                  </button>
                </li>
              ))}
            </ul>
          )}
        </section>

        {/* Local Tools MCP — an optional, self-hosted MCP for filesystem/git
            tools that can't run in the cloud. Download + install instructions. */}
        <section className="dash-panel" style={{ marginTop: 'var(--space-4)' }}>
          <div className="dash-panel__head">
            <h2 className="dash-panel__title">Local Tools MCP</h2>
            <span className="dash-badge">optional</span>
          </div>
          <p className="sg-page-intro" style={{ marginBottom: 12 }}>
            An optional MCP server you run on your own machine for filesystem and git tools
            that can&apos;t run in the cloud. Download it, build it, and connect it to Claude Code,
            Codex, or Grok.
            It provides:{" "}
            <span className="font-mono">file_search</span>,{" "}
            <span className="font-mono">grep</span>,{" "}
            <span className="font-mono">git_tree</span>,{" "}
            <span className="font-mono">git_dump</span>,{" "}
            <span className="font-mono">dump_files</span>, and{" "}
            <span className="font-mono">file_read</span>.
          </p>

          <a
            className="sg-btn sg-btn--black sg-btn--sm"
            href={api.localMcpDownloadUrl()}
            download
          >
            Download noizu-local-mcp.tar.gz
          </a>

          <div className="authz-reveal" style={{ marginTop: 16 }}>
            <div className="authz-reveal__label">Install &amp; connect:</div>
            <div className="authz-reveal__row">
              <code className="authz-reveal__key font-mono" style={{ whiteSpace: 'pre-wrap' }}>{LOCAL_MCP_INSTALL}</code>
              <button
                className="sg-btn sg-btn--outline sg-btn--sm"
                onClick={() => copyText(LOCAL_MCP_INSTALL, "local-mcp-install")}>
                {copied === "local-mcp-install" ? "Copied!" : "Copy"}
              </button>
            </div>
          </div>
        </section>

        {legacyMintEnabled ? (
          <>
            <section className="dash-panel" style={{ marginTop: 'var(--space-4)' }}>
              <div className="dash-panel__head">
                <h2 className="dash-panel__title">Legacy API keys (Bearer token)</h2>
                <span className="dash-badge">deprecated</span>
              </div>
              <p className="sg-page-intro" style={{ marginBottom: 12 }}>
                Only for CLIs that <strong>cannot</strong> do OAuth yet. One click
                generates a key and the <code className="font-mono">mcp add</code> command
                for the selected custom endpoint. Prefer OAuth above — ChatGPT/Claude.ai
                connectors <strong>reject</strong> static Bearer keys.
              </p>
            </section>

            <section className="dash-panel" style={{ marginTop: 'var(--space-4)' }}>
              <div className="dash-panel__head">
                <h2 className="dash-panel__title">Generate key &amp; add command</h2>
                <span className="dash-badge">one step</span>
              </div>
              <p className="sg-page-intro" style={{ marginBottom: 12 }}>
                Creates a key, mints a JWT, and shows the add command for{' '}
                <span className="font-mono">{defaultScope?.url || oauthMcpUrl}</span>.
              </p>
              <form className="gh-add-form" onSubmit={createKey}>
                <input
                  className="gh-add-form__input"
                  value={label}
                  onChange={(e) => setLabel(e.target.value)}
                  placeholder="Label (e.g. ci-bot, local-dev)"
                  aria-label="Key label"
                />
                <button className="sg-btn sg-btn--black sg-btn--sm" type="submit" disabled={loading}>
                  {loading ? "Generating…" : "Generate key & add command"}
                </button>
              </form>
              <form className="gh-add-form" onSubmit={mintFromPaste} style={{ marginTop: 12 }}>
                <input
                  className="gh-add-form__input"
                  value={pastedKey}
                  onChange={(e) => setPastedKey(e.target.value)}
                  placeholder="Or paste an existing raw API key"
                  aria-label="Raw API key"
                  style={{ flex: 2 }}
                />
                <button className="sg-btn sg-btn--outline sg-btn--sm" type="submit" disabled={minting || !pastedKey.trim()}>
                  {minting ? "Minting…" : "Mint & add command"}
                </button>
              </form>
            </section>
          </>
        ) : (
          <section className="dash-panel" style={{ marginTop: 'var(--space-4)' }}>
            <div className="dash-panel__head">
              <h2 className="dash-panel__title">Legacy API keys disabled</h2>
            </div>
            <p className="sg-page-intro">
              New API key minting is turned off. Use OAuth custom connectors with{' '}
              <code className="font-mono">{oauthMcpUrl}</code>. Existing keys can still be revoked below.
            </p>
          </section>
        )}

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

        {configError && (
          <section className="dash-panel" style={{ marginTop: 'var(--space-4)' }}>
            <div className="dash-panel__head">
              <h2 className="dash-panel__title">MCP Setup Unavailable</h2>
            </div>
            <p className="sg-page-intro">
              The MCP server catalog failed to load, so one-click setup commands
              cannot be shown. You can still create keys and mint tokens above;
              reload the page to retry.
            </p>
            {configError !== "Unknown error" && (
              <p className="gh-row__sub font-mono">{configError}</p>
            )}
          </section>
        )}

        {/* Setup panel for a key with a minted token */}
        {setupKey && tokens[setupKey] && servers.length > 0 && (
          (() => {
            const key = keys.find((k) => k.id === setupKey);
            return (
              <McpSetupPanel
                token={tokens[setupKey].token}
                keyLabel={key?.label ?? "pasted key"}
                servers={servers}
                alaCarte={alaCarte}
                defaultScope={defaultScope}
                endpoints={endpoints}
                templates={templates}
                catalog={catalog}
                rawKey={newKey && setupKey === newKey.id ? newKey.raw_key : null}
                onSelectEndpoint={applyScope}
                onEndpointChange={(scope) => {
                  setEndpoints((prev) => prev.map((s) => (s.id === scope.id ? { ...s, ...scope } : s)));
                  applyScope(scope);
                }}
                onClose={() => setSetupKey(null)}
              />
            );
          })()
        )}
      </main>
    </div>
  );
}
