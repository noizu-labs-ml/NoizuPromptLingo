'use client';

import { useState } from 'react';
import {
  MCP_OAUTH_CLIENTS,
  DEFAULT_MCP_AUTH_ENV_VAR,
  mcpOauthHint,
  mcpOauthServerName,
  mcpOauthSnippet,
  type McpOauthClient,
} from '@/lib/mcp-setup';
import { ClipboardButton, useCopied } from '@/components/kit';

type Tab = 'oauth' | 'manual';
type ManualTabId = 'claude-cli' | 'grok' | 'codex' | 'opencode' | 'generic';

interface ConnectInstructionsProps {
  /** Resolved MCP URL for the selected endpoint. */
  mcpUrl: string;
  /** OAuth issuer shown on the optional discovery line. */
  issuer?: string;
  /** AS metadata URL shown on the optional discovery line. */
  asMetadataUrl?: string;
  /** Custom-endpoint handle shown beside the URL ("handle <slug>"). */
  scopeSlug?: string | null;
  /**
   * Env var the Manual / CLI tab's bearer snippets reference (org-scoped).
   * Only the env var *name* appears — never a token value.
   */
  authEnvName?: string;
}

/**
 * "Connect" section of /app/mcp-setup. OAuth-first: hosted connectors
 * (Claude.ai, ChatGPT) do not use a static API key — they Dynamic Client
 * Register (DCR) and open a browser consent screen; the only "secret" is the
 * Tobor Locker login at consent time. A second tab carries the per-CLI
 * bearer-token snippets (ex-mcp-endpoint-setup-popunder) for CLIs that
 * cannot do OAuth yet.
 */
export default function ConnectInstructions({
  mcpUrl,
  issuer,
  asMetadataUrl,
  scopeSlug,
  authEnvName = DEFAULT_MCP_AUTH_ENV_VAR,
}: ConnectInstructionsProps) {
  const [tab, setTab] = useState<Tab>('oauth');
  const [manualTab, setManualTab] = useState<ManualTabId>('claude-cli');
  const [client, setClient] = useState<McpOauthClient>('claude-code');
  const { copied, copy } = useCopied();

  const snippet = mcpOauthSnippet(client, mcpOauthServerName(scopeSlug), mcpUrl);
  const selected = MCP_OAUTH_CLIENTS.find((c) => c.id === client);

  const manualName = serverName(scopeSlug ?? 'default-mcp');
  const header = `Authorization: Bearer $${authEnvName}`;
  const manualTabs: { id: ManualTabId; label: string; blocks: { label: string; text: string }[] }[] = [
    {
      id: 'claude-cli',
      label: 'Claude CLI',
      blocks: [
        {
          label: 'CLI one-liner',
          text: `claude mcp add --transport http ${manualName} ${mcpUrl} --header "${header}"`,
        },
        {
          label: '~/.claude.json (or project .mcp.json)',
          text: JSON.stringify(
            {
              mcpServers: {
                [manualName]: {
                  type: 'http',
                  url: mcpUrl,
                  headers: { Authorization: `Bearer \${${authEnvName}}` },
                },
              },
            },
            null,
            2,
          ),
        },
      ],
    },
    {
      id: 'grok',
      label: 'Grok',
      blocks: [
        {
          label: 'CLI one-liner',
          text: `grok mcp add --transport http ${manualName} ${mcpUrl} --header "${header}"`,
        },
        {
          label: '~/.grok/config.toml',
          text: `[mcp_servers.${manualName}]
url = "${mcpUrl}"
[mcp_servers.${manualName}.headers]
Authorization = "Bearer \${${authEnvName}}"`,
        },
      ],
    },
    {
      id: 'codex',
      label: 'Codex',
      blocks: [
        {
          label: 'CLI one-liner',
          text: `codex mcp add ${manualName} --url ${mcpUrl} --bearer-token-env-var ${authEnvName}`,
        },
        {
          label: '~/.codex/config.toml',
          text: `[mcp_servers.${manualName}]
url = "${mcpUrl}"
bearer_token_env_var = "${authEnvName}"`,
        },
      ],
    },
    {
      id: 'opencode',
      label: 'OpenCode',
      blocks: [
        {
          label: 'CLI one-liner',
          text: `opencode mcp add -t remote ${manualName} ${mcpUrl} --header "${header}"`,
        },
        {
          label: 'opencode.json',
          text: JSON.stringify(
            {
              mcp: {
                [manualName]: {
                  type: 'remote',
                  url: mcpUrl,
                  headers: { Authorization: `Bearer \${${authEnvName}}` },
                  enabled: true,
                },
              },
            },
            null,
            2,
          ),
        },
      ],
    },
    {
      id: 'generic',
      label: 'Generic / curl',
      blocks: [
        { label: 'MCP endpoint URL', text: mcpUrl },
        {
          label: 'Smoke test (initialize handshake)',
          text: `export ${authEnvName}=<your-token>
curl -s ${mcpUrl} \\
  -H "Content-Type: application/json" \\
  -H "Authorization: Bearer $${authEnvName}" \\
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"manual","version":"0"}}}'`,
        },
      ],
    },
  ];
  const activeManual = manualTabs.find((t) => t.id === manualTab) ?? manualTabs[0];

  return (
    <section className="dash-panel" style={{ marginTop: 'var(--space-4)' }}>
      <div className="dash-panel__head">
        <h2 className="dash-panel__title">Connect MCP clients (OAuth)</h2>
        <span className="dash-badge">preferred</span>
      </div>

      <div style={explainerStyle}>
        <strong style={{ color: 'var(--text-1)' }}>You do not mint an OAuth “key” in this UI.</strong>
        <br />
        Hosted apps (Claude.ai, ChatGPT) call our authorization server,{' '}
        <strong>register themselves</strong> (RFC 7591 DCR), and open a browser window.
        You sign in with Authentik and click <strong>Allow</strong>. A pairing grant appears
        under “Connected clients” below — that is your authorization, not a copy-paste secret.
        <br />
        <strong style={{ color: 'var(--text-1)' }}>Access is not unlimited.</strong>
        {' '}This pairing is the selected endpoint’s standing catalog; revoke it anytime
        under Connected clients. MCP PKCE stays on <code className="font-mono">/oauth</code>
        (not Authentik).
      </div>

      <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginBottom: 16 }}>
        {(
          [
            { id: 'oauth' as const, label: 'OAuth connector' },
            { id: 'manual' as const, label: 'Manual / CLI' },
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

      {tab === 'oauth' && (
        <div>
          <ol style={stepListStyle}>
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
          <div style={{ marginBottom: 12 }}>
            <div className="authz-reveal">
              <div className="authz-reveal__label">
                MCP server URL
                {scopeSlug ? (
                  <span style={{ marginLeft: 8, fontWeight: 400 }}>
                    handle <span className="font-mono">{scopeSlug}</span>
                  </span>
                ) : null}
              </div>
              <div className="authz-reveal__row">
                <code className="authz-reveal__key font-mono">{mcpUrl}</code>
                <button
                  type="button"
                  className="sg-btn sg-btn--outline sg-btn--sm"
                  aria-label="Copy MCP server URL"
                  onClick={() => void copy(mcpUrl, 'mcp-url')}
                >
                  {copied === 'mcp-url' ? 'Copied!' : 'Copy'}
                </button>
              </div>
            </div>
          </div>
          <ol start={4} style={stepListStyle}>
            <li>
              When prompted, sign in at Tobor Locker and click <strong>Allow</strong> on the consent screen.
            </li>
            <li>
              Tools appear in the host app. Refresh tokens are stored by Claude/ChatGPT — revoke anytime
              under Connected clients on this page.
            </li>
          </ol>

          <div style={{ marginTop: 16, marginBottom: 8, fontSize: 12, fontWeight: 600, color: 'var(--text-1)' }}>
            Install snippets
          </div>
          <p className="sg-page-intro" style={{ marginTop: 0, marginBottom: 10 }}>
            OAuth URL only — no long-lived bearer. Pick a client, copy, then Allow in the browser.
          </p>
          <div style={pickerStyle}>
            {MCP_OAUTH_CLIENTS.map((option) => (
              <button
                key={option.id}
                type="button"
                aria-pressed={client === option.id}
                onClick={() => setClient(option.id)}
                style={{
                  padding: '5px 10px',
                  fontSize: 11,
                  border: 0,
                  cursor: 'pointer',
                  fontFamily: 'var(--font)',
                  ...(client === option.id
                    ? { background: 'var(--accent)', color: 'white' }
                    : { background: 'transparent', color: 'var(--text-1)' }),
                }}
              >
                {option.label}
              </button>
            ))}
          </div>
          <p style={{ margin: '0 0 10px', fontSize: 11, lineHeight: 1.5, color: 'var(--text-2)' }}>
            {mcpOauthHint(client)}
          </p>
          <div className="authz-reveal">
            <div className="authz-reveal__label">
              {selected?.label}
              {selected?.dest ? (
                <span style={{ marginLeft: 8, fontWeight: 400 }}>{selected.dest}</span>
              ) : null}
            </div>
            <div className="authz-reveal__row">
              <code
                className="authz-reveal__key font-mono"
                data-mcp-oauth-client={client}
                style={{ whiteSpace: 'pre-wrap' }}
              >
                {snippet}
              </code>
              <button
                type="button"
                className="sg-btn sg-btn--outline sg-btn--sm"
                aria-label={`Copy ${selected?.label ?? 'client'} snippet`}
                onClick={() => void copy(snippet, client)}
              >
                {copied === client ? 'Copied!' : 'Copy'}
              </button>
            </div>
          </div>
          {asMetadataUrl || issuer ? (
            <p className="sg-page-intro" style={{ marginTop: 16, marginBottom: 0 }}>
              Optional discovery (for debugging):{' '}
              <code className="font-mono" style={{ fontSize: 11 }}>{asMetadataUrl}</code>
              {' · '}
              issuer <code className="font-mono" style={{ fontSize: 11 }}>{issuer}</code>
            </p>
          ) : null}
        </div>
      )}

      {tab === 'manual' && (
        <div>
          <p className="sg-page-intro" style={{ marginBottom: 12 }}>
            Legacy bearer-token setup for CLIs that cannot do OAuth yet. The snippets
            reference the env var <span className="font-mono">{authEnvName}</span> — export your
            token under that name (or use the OAuth tab, which needs no token at all).
          </p>
          <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginBottom: 14 }}>
            {manualTabs.map((t) => (
              <button
                key={t.id}
                type="button"
                className={`sg-btn sg-btn--sm ${manualTab === t.id ? 'sg-btn--black' : 'sg-btn--outline'}`}
                onClick={() => setManualTab(t.id)}
              >
                {t.label}
              </button>
            ))}
          </div>
          {activeManual.blocks.map((b) => (
            <SnippetBlock key={b.label} label={b.label} text={b.text} />
          ))}
          <p style={{ margin: 0, fontSize: 11, lineHeight: 1.5, color: 'var(--text-2)' }}>
            Any MCP-compatible client that speaks streamable HTTP can register{' '}
            <span className="font-mono">{mcpUrl}</span> with a{' '}
            <span className="font-mono">Authorization: Bearer</span> header — or use the OAuth
            connector tab (DCR + PKCE) with no token paste at all.
          </p>
        </div>
      )}
    </section>
  );
}

function serverName(slug: string) {
  return `tobor-${slug.replace(/[^a-zA-Z0-9_-]/g, '-')}`;
}

/** One copy-paste block with a floating copy button (per-CLI manual tab). */
function SnippetBlock({ label, text }: { label: string; text: string }) {
  return (
    <div style={{ position: 'relative', marginBottom: 14 }}>
      <ClipboardButton
        text={text}
        ariaLabel={`Copy ${label}`}
        className="sg-btn sg-btn--outline sg-btn--sm"
        style={{ position: 'absolute', top: 8, right: 8, zIndex: 1 }}
        copiedStyle={{
          background: 'var(--green-dim)',
          color: 'var(--green)',
          borderColor: 'var(--green)',
        }}
      />
      <div style={{ fontSize: 11, fontWeight: 600, color: 'var(--text-2)', marginBottom: 6 }}>
        {label}
      </div>
      <pre style={preStyle}>{text}</pre>
    </div>
  );
}

const explainerStyle = {
  marginBottom: 16,
  padding: 12,
  borderRadius: 8,
  background: 'var(--bg-3)',
  border: '1px solid var(--border)',
  fontSize: 13,
  lineHeight: 1.55,
  color: 'var(--text-2)',
} as const;

const stepListStyle = {
  margin: '0 0 16px',
  paddingLeft: 20,
  fontSize: 13,
  lineHeight: 1.7,
  color: 'var(--text-1)',
} as const;

const pickerStyle = {
  display: 'inline-flex',
  flexWrap: 'wrap',
  border: '1px solid var(--border)',
  borderRadius: 6,
  overflow: 'hidden',
  background: 'var(--bg-3)',
  marginBottom: 10,
} as const;

const preStyle = {
  margin: 0,
  padding: 16,
  paddingRight: 80,
  background: 'var(--bg-3)',
  borderRadius: 'var(--radius-sm)',
  fontFamily: 'monospace',
  fontSize: 12,
  lineHeight: 1.7,
  color: 'var(--text-1)',
  overflowX: 'auto',
  whiteSpace: 'pre-wrap',
  wordBreak: 'break-all',
} as const;
