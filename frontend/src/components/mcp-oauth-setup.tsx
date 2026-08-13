'use client';

import { useState } from 'react';
import { toast } from 'sonner';
import type { McpCustomGroup, McpCustomScope, McpServerConfig } from '@/lib/api';
import McpIncludeEditor from '@/components/mcp-include-editor';

type Tab = 'default' | 'alacarte';

interface McpOauthSetupProps {
  mcpUrl: string;
  asMetadataUrl: string;
  issuer: string;
  servers: McpServerConfig[];
  alaCarte?: McpServerConfig[];
  catalog?: McpCustomGroup[];
  defaultScope?: McpCustomScope | null;
  onDefaultScopeChange?: (scope: McpCustomScope) => void;
}

/**
 * OAuth-first MCP client setup. Hosted connectors (Claude.ai, ChatGPT) do not
 * use a static API key — they Dynamic Client Register (DCR) and open a browser
 * consent screen. The only "secret" is your Tobor Locker login at consent time.
 */
export default function McpOauthSetup({
  mcpUrl,
  asMetadataUrl,
  issuer,
  servers,
  alaCarte = [],
  catalog = [],
  defaultScope = null,
  onDefaultScopeChange,
}: McpOauthSetupProps) {
  const [tab, setTab] = useState<Tab>('default');
  const [copied, setCopied] = useState<string | null>(null);

  async function copy(text: string, id: string) {
    try {
      await navigator.clipboard.writeText(text);
      setCopied(id);
      setTimeout(() => setCopied(null), 2000);
      toast.success('Copied');
    } catch {
      toast.error('Copy failed — select and copy manually');
    }
  }

  const handle = defaultScope?.slug;
  const clientName = handle ? `tobor-${handle}` : 'tobor-default-mcp';
  const claudeCodeOauth = `# Claude Code — remote MCP over OAuth (no API key)
# Paste the MCP URL; the client discovers OAuth, registers itself (DCR),
# and opens a browser for you to sign in + Allow.
claude mcp add --transport http ${clientName} ${mcpUrl}

# If your CLI still requires a header, use the Legacy API key section below.`;

  const codexNote = `# Codex — prefer remote MCP URL if your build supports OAuth connectors.
# Otherwise use Legacy API key → mint token, then:
#   codex mcp add tobor --url ${mcpUrl} --bearer-token-env-var AUTH_TOKEN`;

  return (
    <section className="dash-panel" style={{ marginTop: 'var(--space-4)' }}>
      <div className="dash-panel__head">
        <h2 className="dash-panel__title">Connect MCP clients (OAuth)</h2>
        <span className="dash-badge">preferred</span>
      </div>

      <div
        style={{
          marginBottom: 16,
          padding: 12,
          borderRadius: 8,
          background: 'var(--bg-3)',
          border: '1px solid var(--border)',
          fontSize: 13,
          lineHeight: 1.55,
          color: 'var(--text-2)',
        }}
      >
        <strong style={{ color: 'var(--text-1)' }}>You do not mint an OAuth “key” in this UI.</strong>
        <br />
        Hosted apps (Claude.ai, ChatGPT) call our authorization server,{' '}
        <strong>register themselves</strong> (RFC 7591 DCR), and open a browser window.
        You sign in with Authentik and click <strong>Allow</strong>. A pairing grant appears
        under “OAuth connections” below — that is your authorization, not a copy-paste secret.
      </div>

      <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginBottom: 16 }}>
        {(
          [
            { id: 'default' as const, label: 'Default MCP' },
            { id: 'alacarte' as const, label: 'À la carte' },
          ] as const
        ).map((t) => (
          <button
            key={t.id}
            type="button"
            className={`sg-btn sg-btn--sm ${tab === t.id ? 'sg-btn--black' : 'sg-btn--outline'}`}
            onClick={() => setTab(t.id)}
          >
            {t.label}
          </button>
        ))}
      </div>

      {tab === 'default' && (
        <div>
          <ol style={{ margin: '0 0 16px', paddingLeft: 20, fontSize: 13, lineHeight: 1.7, color: 'var(--text-1)' }}>
            <li>
              Open <strong>Claude.ai</strong> → Settings → <strong>Connectors</strong> (or Custom connectors),
              or <strong>ChatGPT</strong> → Settings → <strong>Connectors</strong> (developer mode as needed).
            </li>
            <li>
              Add a remote MCP server / custom connector.
            </li>
            <li>
              Paste this MCP URL only (no client secret, no API key):
            </li>
          </ol>
          <div className="authz-reveal" style={{ marginBottom: 12 }}>
            <div className="authz-reveal__label">
              MCP server URL
              {handle ? (
                <span style={{ marginLeft: 8, fontWeight: 400 }}>
                  handle <span className="font-mono">{handle}</span>
                </span>
              ) : null}
            </div>
            <div className="authz-reveal__row">
              <code className="authz-reveal__key font-mono">{mcpUrl}</code>
              <button type="button" className="sg-btn sg-btn--outline sg-btn--sm" onClick={() => copy(mcpUrl, 'mcp-url')}>
                {copied === 'mcp-url' ? 'Copied!' : 'Copy'}
              </button>
            </div>
          </div>
          <ol start={4} style={{ margin: 0, paddingLeft: 20, fontSize: 13, lineHeight: 1.7, color: 'var(--text-1)' }}>
            <li>
              When prompted, sign in at Tobor Locker and click <strong>Allow</strong> on the consent screen.
            </li>
            <li>
              Tools appear in the host app. Refresh tokens are stored by Claude/ChatGPT — revoke anytime
              under OAuth connections on this page.
            </li>
          </ol>

          {defaultScope && catalog.length > 0 ? (
            <div style={{ marginTop: 16 }}>
              <McpIncludeEditor
                key={defaultScope.id}
                catalog={catalog}
                scope={defaultScope}
                onSaved={onDefaultScopeChange}
              />
            </div>
          ) : null}

          <div className="authz-reveal" style={{ marginTop: 16, marginBottom: 12 }}>
            <div className="authz-reveal__label">CLI (OAuth)</div>
            <div className="authz-reveal__row">
              <code className="authz-reveal__key font-mono" style={{ whiteSpace: 'pre-wrap' }}>{claudeCodeOauth}</code>
              <button type="button" className="sg-btn sg-btn--outline sg-btn--sm" onClick={() => copy(claudeCodeOauth, 'claude-oauth')}>
                {copied === 'claude-oauth' ? 'Copied!' : 'Copy'}
              </button>
            </div>
          </div>
          <div className="authz-reveal">
            <div className="authz-reveal__label">Codex / others</div>
            <div className="authz-reveal__row">
              <code className="authz-reveal__key font-mono" style={{ whiteSpace: 'pre-wrap' }}>{codexNote}</code>
              <button type="button" className="sg-btn sg-btn--outline sg-btn--sm" onClick={() => copy(codexNote, 'codex')}>
                {copied === 'codex' ? 'Copied!' : 'Copy'}
              </button>
            </div>
          </div>
          <p className="sg-page-intro" style={{ marginTop: 16, marginBottom: 0 }}>
            Optional discovery (for debugging):{' '}
            <code className="font-mono" style={{ fontSize: 11 }}>{asMetadataUrl}</code>
            {' · '}
            issuer <code className="font-mono" style={{ fontSize: 11 }}>{issuer}</code>
          </p>
        </div>
      )}

      {tab === 'alacarte' && (
        <div>
          <p className="sg-page-intro" style={{ marginBottom: 12 }}>
            Manual extra endpoints — each subdomain is its own MCP server. Prefer the
            single default-mcp URL unless you need a split catalog.
          </p>
          {alaCarte.length === 0 && servers.length === 0 ? (
            <p className="sg-page-intro">Loading server catalog…</p>
          ) : (
            <ul className="admin-table-wrap">
              {(alaCarte.length > 0 ? alaCarte : servers).map((s) => (
                <li key={s.id} className="gh-row">
                  <div className="gh-row__main">
                    <div className="gh-row__title">
                      {s.label}
                      {s.required ? (
                        <span className="dash-badge" style={{ marginLeft: 8 }}>required</span>
                      ) : null}
                    </div>
                    {s.desc ? <div className="gh-row__sub">{s.desc}</div> : null}
                    <div className="gh-row__sub font-mono" style={{ wordBreak: 'break-all' }}>{s.url}</div>
                  </div>
                  <button
                    type="button"
                    className="sg-btn sg-btn--outline sg-btn--sm"
                    onClick={() => copy(s.url, `srv-${s.id}`)}
                  >
                    {copied === `srv-${s.id}` ? 'Copied!' : 'Copy URL'}
                  </button>
                </li>
              ))}
            </ul>
          )}
        </div>
      )}
    </section>
  );
}
