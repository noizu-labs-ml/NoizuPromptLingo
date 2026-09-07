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
import McpEndpointManager from '@/components/mcp-endpoint-manager';
import McpSetupPanel from '@/components/mcp-setup-panel';
import ConnectInstructions from '@/components/mcp/connect-instructions';
import ConnectionsList from '@/components/mcp/connections-list';
import { ClipboardButton, ConfirmDialog, CopyField } from '@/components/kit';
import { useOrg } from '@/context/org';
import { mcpAuthEnvVar } from '@/lib/mcp-setup';

// Install snippet for the optional Local Tools MCP (filesystem/git tools).
const LOCAL_MCP_INSTALL = `tar xzf noizu-local-mcp.tar.gz && cd local-mcp && npm i && npm run build
# Claude Code
claude mcp add noizu-local -- node "$PWD/dist/index.js"
# Codex
codex mcp add noizu-local -- node "$PWD/dist/index.js"
# Grok
grok mcp add noizu-local -- node "$PWD/dist/index.js"`;

/**
 * The one user MCP management surface (/app/mcp-setup — /app/mcp-keys
 * redirects here): Endpoints (McpEndpointManager), Connect
 * (ConnectInstructions + Local Tools MCP), Connected clients
 * (ConnectionsList), and the legacy API keys section.
 */
export default function McpSetupPage() {
  // Endpoints — McpEndpointManager owns the picker, wizard and include editor.
  const [templates, setTemplates] = useState<McpCustomScope[]>([]);
  const [endpoints, setEndpoints] = useState<McpCustomScope[]>([]);
  const [catalog, setCatalog] = useState<McpCustomGroup[]>([]);
  const [defaultScope, setDefaultScope] = useState<McpCustomScope | null>(null);
  // Server config for the per-key setup panel (fetched so no hardcoded host).
  const [servers, setServers] = useState<McpServerConfig[]>([]);

  // Connect URLs for the selected endpoint.
  const [oauthMcpUrl, setOauthMcpUrl] = useState('https://tobor.locker/mcp');
  const [oauthIssuer, setOauthIssuer] = useState('https://tobor.locker');
  const [asMetadataUrl, setAsMetadataUrl] = useState(
    'https://tobor.locker/.well-known/oauth-authorization-server'
  );

  // OAuth connections.
  const [connections, setConnections] = useState<McpOAuthConnection[]>([]);
  const [connectionsLoading, setConnectionsLoading] = useState(true);
  const [connectionsError, setConnectionsError] = useState<string | null>(null);

  // API keys. Tokens keyed by api key id (not prefix) — stable across renders.
  const [keys, setKeys] = useState<McpApiKey[]>([]);
  const [keysLoading, setKeysLoading] = useState(true);
  const [keysError, setKeysError] = useState<string | null>(null);
  const [tokens, setTokens] = useState<Record<string, McpTokenResponse>>({});
  const [newKey, setNewKey] = useState<{ id: string; raw_key: string } | null>(null);
  const [label, setLabel] = useState("");
  const [creating, setCreating] = useState(false);
  const [setupKey, setSetupKey] = useState<string | null>(null);
  // Key id pending revocation (drives the ConfirmDialog).
  const [revokeKeyId, setRevokeKeyId] = useState<string | null>(null);

  // Tri-state: `true` until the config resolves `legacy_api_key_mint_enabled`.
  const [legacyMintEnabled, setLegacyMintEnabled] = useState(true);
  // A failed catalog fetch would otherwise leave the setup panel hidden with
  // no indication of why — surface it explicitly.
  const [configError, setConfigError] = useState<string | null>(null);

  // Paste-an-existing-key flow: lets a logged-in user recover setup access for
  // a key whose raw value they still hold, without recreating it.
  const [pastedKey, setPastedKey] = useState("");
  const [minting, setMinting] = useState(false);

  // Org-scoped env var name for CLI bearer tokens (e.g. NOIZU_LABS_AUTH_TOKEN)
  // so multi-org shells don't collide on a bare AUTH_TOKEN.
  const { organizations } = useOrg();
  const authEnvName = mcpAuthEnvVar(organizations[0]?.slug);

  const fetchKeys = useCallback(async () => {
    setKeysLoading(true);
    try {
      const data = await api.listMcpKeys();
      setKeys(data.keys || []);
      setKeysError(null);
    } catch (err) {
      setKeysError(err instanceof Error ? err.message : "Failed to load keys");
    } finally {
      setKeysLoading(false);
    }
  }, []);

  const fetchConnections = useCallback(async () => {
    setConnectionsLoading(true);
    try {
      const data = await api.listMcpConnections();
      setConnections(data.connections || []);
      setConnectionsError(null);
    } catch (err) {
      setConnectionsError(err instanceof Error ? err.message : "Failed to load connections");
    } finally {
      setConnectionsLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchKeys();
    fetchConnections();
    api
      .mcpConfig({ packaging: "setup" })
      .then((cfg) => {
        setServers(cfg.servers);
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
    setCreating(true);
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
      setCreating(false);
    }
  }

  async function mintFromPaste(e: React.FormEvent) {
    e.preventDefault();
    const raw = pastedKey.trim();
    if (!raw) return;
    setMinting(true);
    try {
      const tokenRes = await api.mintMcpTokenAuthenticated(raw);
      // The backend verifies the key belongs to the caller; match it to a known
      // key by refetching so we can attach the token to the right row.
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

  // Runs behind the ConfirmDialog; throwing keeps the dialog open for retry
  // while the inline error panel explains the failure.
  async function revokeKey(id: string) {
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
      setKeysError(err instanceof Error ? err.message : "Failed to revoke key");
      throw err;
    }
  }

  async function revokeConnection(grantId: string) {
    try {
      await api.revokeMcpConnection(grantId);
      await fetchConnections();
      toast.success("Connection revoked");
    } catch (err) {
      setConnectionsError(err instanceof Error ? err.message : "Failed to revoke connection");
      throw err;
    }
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
          edit what it includes, or copy it below. <strong>OAuth is preferred</strong> —
          hosted clients invent their own <code className="font-mono">client_id</code> via
          Dynamic Client Registration.
        </p>

        {/* Endpoints */}
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

        {/* Connect */}
        <ConnectInstructions
          mcpUrl={oauthMcpUrl}
          asMetadataUrl={asMetadataUrl}
          issuer={oauthIssuer}
          scopeSlug={defaultScope?.slug ?? null}
          authEnvName={authEnvName}
        />

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

          <div style={{ marginTop: 16 }}>
            <CopyField
              label="Install & connect:"
              value={LOCAL_MCP_INSTALL}
              preWrap
              copyLabel="Copy install commands"
            />
          </div>
        </section>

        {/* Connected clients */}
        <ConnectionsList
          connections={connections}
          loading={connectionsLoading}
          error={connectionsError}
          onRevoke={revokeConnection}
          emptyHint={
            <>
              No connections yet — complete a connector setup above. Nothing to copy; the grant is
              created automatically after consent.
            </>
          }
        />

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
                <button className="sg-btn sg-btn--black sg-btn--sm" type="submit" disabled={creating}>
                  {creating ? "Generating…" : "Generate key & add command"}
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

        {/* Your Keys */}
        <section className="dash-panel" style={{ marginTop: 'var(--space-4)' }}>
          <div className="dash-panel__head">
            <h2 className="dash-panel__title">Your Keys</h2>
            <span className="dash-badge">{keys.length}</span>
          </div>

          {keysLoading ? (
            <p className="sg-page-intro">Loading keys…</p>
          ) : keys.length === 0 ? (
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
                          <ClipboardButton
                            text={tokens[k.id].token}
                            label="Copy Token"
                            ariaLabel={`Copy token for ${k.label}`}
                            className="sg-btn sg-btn--outline sg-btn--sm"
                          />
                        </>
                      )}
                      {k.status === "active" && !hasToken && (
                        <span className="gh-row__sub">paste raw key above to mint a token</span>
                      )}
                      {k.status === "active" && (
                        <button
                          className="sg-btn sg-btn--danger sg-btn--sm"
                          aria-label={`Revoke key ${k.label}`}
                          onClick={() => setRevokeKeyId(k.id)}
                        >
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

        {/* Inline error panels — no toast-only failure states. */}
        {keysError && (
          <ErrorPanel
            title="API keys unavailable"
            body="The keys list failed to load, so existing keys cannot be shown or revoked. Reload the page to retry."
            detail={keysError}
          />
        )}
        {configError && (
          <ErrorPanel
            title="MCP Setup Unavailable"
            body="The MCP server catalog failed to load, so one-click setup commands cannot be shown. Key management above still works; reload the page to retry."
            detail={configError}
          />
        )}

        {/* Setup panel for a key with a minted token */}
        {setupKey && tokens[setupKey] && servers.length > 0 && (
          (() => {
            const key = keys.find((k) => k.id === setupKey);
            return (
              <McpSetupPanel
                token={tokens[setupKey].token}
                keyLabel={key?.label ?? "pasted key"}
                authEnvName={authEnvName}
                servers={servers}
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

        <ConfirmDialog
          open={revokeKeyId !== null}
          onClose={() => setRevokeKeyId(null)}
          title="Revoke API key?"
          destructive
          confirmLabel="Revoke"
          onConfirm={async () => {
            if (revokeKeyId) await revokeKey(revokeKeyId);
          }}
        >
          Revoke this MCP key? Clients using it will lose access immediately.
        </ConfirmDialog>
      </main>
    </div>
  );
}

/** Inline fetch-failure panel replacing the old toast-only error paths. */
function ErrorPanel({ title, body, detail }: { title: string; body: string; detail?: string | null }) {
  return (
    <section className="dash-panel" style={{ marginTop: 'var(--space-4)' }}>
      <div className="dash-panel__head">
        <h2 className="dash-panel__title">{title}</h2>
      </div>
      <p className="sg-page-intro">{body}</p>
      {detail && detail !== "Unknown error" ? (
        <p className="gh-row__sub font-mono">{detail}</p>
      ) : null}
    </section>
  );
}
