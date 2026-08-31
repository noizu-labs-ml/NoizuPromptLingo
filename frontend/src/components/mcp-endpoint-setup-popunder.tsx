'use client';

import { useState, type ReactNode } from 'react';
import { toast } from 'sonner';
import { TabbedPopunder } from '@/components/kit';
import { DEFAULT_MCP_AUTH_ENV_VAR } from '@/lib/mcp-setup';
import type { McpCustomScope } from '@/lib/api';

/**
 * Per-endpoint "Setup MCP" popunder (W3).
 *
 * Tab per CLI agent (Claude CLI / Grok / Codex / OpenCode) plus a generic
 * curl/manual tab; each renders a copy-paste JSON config block + CLI one-liner
 * for registering the endpoint. Extends the snippet patterns in
 * `components/mcp-setup-panel.tsx` (same `claude mcp add` / `codex mcp add` /
 * `grok mcp add` command shapes and `tobor-<slug>` registration names).
 *
 * The MCP URL arrives as a plain prop — the canonical builder is the backend
 * `NoizuPromptLingua.MCP.Urls` (TOBOR-CONTRACTS §2, F2). Until that merges,
 * callers stub the value with the canonical shape
 * `https://tobor.locker/org/:org_slug/custom/:slug/mcp`.
 */

type TabId = 'claude-cli' | 'grok' | 'codex' | 'opencode' | 'generic';

interface McpEndpointSetupPopunderProps {
  open: boolean;
  onClose: () => void;
  /** Scope being set up (slug names the registered server). */
  scope: Pick<McpCustomScope, 'slug' | 'name'> | null;
  /** Resolved endpoint URL (canonical shape per TOBOR-CONTRACTS §2). */
  mcpUrl: string;
  /** Env var the bearer token is exported under (see lib/mcp-setup). */
  authEnvName?: string;
}

function serverName(slug: string) {
  return `tobor-${slug.replace(/[^a-zA-Z0-9_-]/g, '-')}`;
}

function snippet(label: string, text: string) {
  return <SnippetBlock key={label} label={label} text={text} />;
}

function SnippetBlock({ label, text }: { label: string; text: string }) {
  const [copied, setCopied] = useState(false);

  async function copy() {
    try {
      await navigator.clipboard.writeText(text);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
      toast.success('Copied to clipboard');
    } catch {
      toast.error('Copy failed — select and copy manually');
    }
  }

  return (
    <div style={{ position: 'relative', marginBottom: 14 }}>
      <button
        type="button"
        onClick={copy}
        style={{
          ...btnSm,
          position: 'absolute',
          top: 8,
          right: 8,
          zIndex: 1,
          ...(copied
            ? { background: 'var(--green-dim)', color: 'var(--green)', borderColor: 'var(--green)' }
            : {}),
        }}
      >
        {copied ? 'Copied!' : 'Copy'}
      </button>
      <div style={{ fontSize: 11, fontWeight: 600, color: 'var(--text-2)', marginBottom: 6 }}>
        {label}
      </div>
      <pre
        style={{
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
        }}
      >
        {text}
      </pre>
    </div>
  );
}

export default function McpEndpointSetupPopunder({
  open,
  onClose,
  scope,
  mcpUrl,
  authEnvName = DEFAULT_MCP_AUTH_ENV_VAR,
}: McpEndpointSetupPopunderProps) {
  if (!scope) return null;

  const name = serverName(scope.slug);
  const header = `Authorization: Bearer $${authEnvName}`;

  const tabs: { id: TabId; label: string; render: () => ReactNode }[] = [
    {
      id: 'claude-cli',
      label: 'Claude CLI',
      render: () => (
        <>
          {snippet(
            'CLI one-liner',
            `claude mcp add --transport http ${name} ${mcpUrl} --header "${header}"`,
          )}
          {snippet(
            '~/.claude.json (or project .mcp.json)',
            JSON.stringify(
              {
                mcpServers: {
                  [name]: {
                    type: 'http',
                    url: mcpUrl,
                    headers: { Authorization: `Bearer \${${authEnvName}}` },
                  },
                },
              },
              null,
              2,
            ),
          )}
        </>
      ),
    },
    {
      id: 'grok',
      label: 'Grok',
      render: () => (
        <>
          {snippet(
            'CLI one-liner',
            `grok mcp add --transport http ${name} ${mcpUrl} --header "${header}"`,
          )}
          {snippet(
            '~/.grok/config.toml',
            `[mcp_servers.${name}]
url = "${mcpUrl}"
[mcp_servers.${name}.headers]
Authorization = "Bearer \${${authEnvName}}"`,
          )}
        </>
      ),
    },
    {
      id: 'codex',
      label: 'Codex',
      render: () => (
        <>
          {snippet(
            'CLI one-liner',
            `codex mcp add ${name} --url ${mcpUrl} --bearer-token-env-var ${authEnvName}`,
          )}
          {snippet(
            '~/.codex/config.toml',
            `[mcp_servers.${name}]
url = "${mcpUrl}"
bearer_token_env_var = "${authEnvName}"`,
          )}
        </>
      ),
    },
    {
      id: 'opencode',
      label: 'OpenCode',
      render: () => (
        <>
          {snippet(
            'CLI one-liner',
            `opencode mcp add -t remote ${name} ${mcpUrl} --header "${header}"`,
          )}
          {snippet(
            'opencode.json',
            JSON.stringify(
              {
                mcp: {
                  [name]: {
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
          )}
        </>
      ),
    },
    {
      id: 'generic',
      label: 'Generic / curl',
      render: () => (
        <>
          {snippet('MCP endpoint URL', mcpUrl)}
          {snippet(
            'Smoke test (initialize handshake)',
            `export ${authEnvName}=<your-token>
curl -s ${mcpUrl} \\
  -H "Content-Type: application/json" \\
  -H "Authorization: Bearer $${authEnvName}" \\
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"manual","version":"0"}}}'`,
          )}
          <p style={{ margin: 0, fontSize: 11, lineHeight: 1.5, color: 'var(--text-2)' }}>
            Any MCP-compatible client that speaks streamable HTTP can register{' '}
            <span className="font-mono">{mcpUrl}</span> with a{' '}
            <span className="font-mono">Authorization: Bearer</span> header — or use the OAuth
            connector flow (DCR + PKCE) with no token paste at all.
          </p>
        </>
      ),
    },
  ];

  return (
    <TabbedPopunder
      open={open}
      onClose={onClose}
      title={`Setup MCP — ${scope.name}`}
      tabs={tabs}
      initialTabId="claude-cli"
    />
  );
}

const btnSm = {
  padding: '4px 10px',
  fontSize: 11,
  borderRadius: 4,
  border: '1px solid var(--border)',
  background: 'var(--bg-2)',
  color: 'var(--text-1)',
  cursor: 'pointer',
  fontFamily: 'var(--font)',
};
