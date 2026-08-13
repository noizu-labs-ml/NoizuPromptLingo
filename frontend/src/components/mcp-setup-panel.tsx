'use client';

import { useState } from 'react';
import { toast } from 'sonner';
import type { McpServerConfig } from '@/lib/api';

type McpClient = 'claude' | 'codex' | 'grok';

interface McpSetupPanelProps {
  token: string; // The MCP JWT token
  keyLabel: string; // Label of the API key
  servers: McpServerConfig[]; // Default grouped endpoint(s)
  alaCarte?: McpServerConfig[]; // Optional individual subdomain endpoints
  onClose: () => void;
}

const CLIENT_OPTIONS: { id: McpClient; label: string }[] = [
  { id: 'claude', label: 'Claude Code' },
  { id: 'codex', label: 'Codex' },
  { id: 'grok', label: 'Grok' },
];

/**
 * Sanitize MCP server registration names.
 * Grok only allows letters, numbers, hyphens, underscores; custom scopes
 * arrive as "custom:slug" and must become "custom-slug".
 */
function serverName(id: string) {
  return `tobor-${id.replace(/[^a-zA-Z0-9_-]/g, '-')}`;
}

/**
 * Generates MCP add commands for the given MCP servers.
 *
 * Claude Code:
 *   claude mcp add --transport http tobor-{id} {url} --header "Authorization: Bearer $AUTH_TOKEN"
 *
 * Codex:
 *   codex mcp add tobor-{id} --url {url} --bearer-token-env-var AUTH_TOKEN
 *
 * Grok:
 *   grok mcp add --transport http tobor-{id} {url} --header "Authorization: Bearer $AUTH_TOKEN"
 *
 * Server URLs come from the backend config endpoint (host-derived), so this
 * component never hardcodes a host.
 */
export default function McpSetupPanel({ token, keyLabel, servers, alaCarte = [], onClose }: McpSetupPanelProps) {
  const [client, setClient] = useState<McpClient>('claude');
  const [showAlaCarte, setShowAlaCarte] = useState(false);
  const [enabled, setEnabled] = useState<Record<string, boolean>>(() => {
    const state: Record<string, boolean> = {};
    servers.forEach((s) => { state[s.id] = true; });
    alaCarte.forEach((s) => { state[s.id] = false; });
    return state;
  });
  const [copiedCmd, setCopiedCmd] = useState<string | null>(null);

  const catalog = showAlaCarte ? [...servers, ...alaCarte] : servers;

  function toggle(id: string) {
    const server = catalog.find((s) => s.id === id);
    if (server?.required) return;
    setEnabled((prev) => ({ ...prev, [id]: !prev[id] }));
  }

  function getCommandLine(server: McpServerConfig) {
    const name = serverName(server.id);
    if (client === 'codex') {
      return `codex mcp add ${name} --url ${server.url} --bearer-token-env-var AUTH_TOKEN`;
    }
    if (client === 'grok') {
      return `grok mcp add --transport http ${name} ${server.url} --header "Authorization: Bearer $AUTH_TOKEN"`;
    }

    return `claude mcp add --transport http ${name} ${server.url} --header "Authorization: Bearer $AUTH_TOKEN"`;
  }

  function buildScript() {
    const lines = [
      `export AUTH_TOKEN=${token}`,
      '',
    ];
    catalog.filter((s) => enabled[s.id]).forEach((s) => {
      lines.push(getCommandLine(s));
    });
    return lines.join('\n');
  }

  async function copyScript() {
    try {
      await navigator.clipboard.writeText(buildScript());
      setCopiedCmd('script');
      setTimeout(() => setCopiedCmd(null), 2000);
      toast.success('Copied to clipboard');
    } catch {
      toast.error('Copy failed — select and copy manually');
    }
  }

  const activeCount = catalog.filter((s) => enabled[s.id]).length;
  const rootServer = servers.find((s) => s.default) ?? servers.find((s) => s.id === 'root') ?? servers[0];
  const oauthMcpUrl = rootServer?.url ?? 'https://tobor.locker/custom/tobor/mcp';

  return (
    <div style={{
      background: 'var(--bg-2)',
      borderRadius: 'var(--radius-md)',
      padding: 16,
      marginTop: 12,
      border: '1px solid var(--border)',
    }}>
      <div style={{
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginBottom: 12,
      }}>
        <span style={{ fontSize: 13, fontWeight: 600 }}>MCP Setup — {keyLabel}</span>
        <div style={{ display: 'flex', gap: 8 }}>
          <button onClick={onClose} style={btnSm}>Close</button>
        </div>
      </div>

      <div style={{
        marginBottom: 14,
        padding: 10,
        borderRadius: 6,
        background: 'var(--bg-3)',
        border: '1px solid var(--border)',
        fontSize: 11,
        lineHeight: 1.5,
        color: 'var(--text-2)',
      }}>
        <strong style={{ color: 'var(--text-1)' }}>Preferred: OAuth (Claude.ai / ChatGPT)</strong>
        <br />
        Add a custom connector with MCP URL{' '}
        <code style={{ fontFamily: 'monospace' }}>{oauthMcpUrl}</code>
        {' '}— no API key paste. Hosted clients use DCR + PKCE against this Tobor Locker AS.
        <br />
        CLI bearer tokens below remain supported during migration.
      </div>

      <div style={{
        display: 'flex',
        alignItems: 'center',
        gap: 8,
        marginBottom: 12,
        flexWrap: 'wrap',
      }}>
        <span style={{ fontSize: 11, fontWeight: 600, color: 'var(--text-2)' }}>
          Client
        </span>
        <div style={{
          display: 'inline-flex',
          border: '1px solid var(--border)',
          borderRadius: 6,
          overflow: 'hidden',
          background: 'var(--bg-3)',
        }}>
          {CLIENT_OPTIONS.map((option) => (
            <button
              key={option.id}
              type="button"
              onClick={() => setClient(option.id)}
              style={{
                ...clientToggleBtn,
                ...(client === option.id
                  ? { background: 'var(--accent)', color: 'white' }
                  : { background: 'transparent', color: 'var(--text-1)' }),
              }}
            >
              {option.label}
            </button>
          ))}
        </div>
      </div>

      {client === 'grok' && (
        <p style={{
          margin: '0 0 12px',
          fontSize: 11,
          lineHeight: 1.5,
          color: 'var(--text-2)',
        }}>
          Commands write to <span style={{ fontFamily: 'monospace' }}>~/.grok/config.toml</span>
          {' '}by default (<span style={{ fontFamily: 'monospace' }}>--scope user</span>).
          Use <span style={{ fontFamily: 'monospace' }}>--scope project</span> for a repo-local
          {' '}<span style={{ fontFamily: 'monospace' }}>.grok/config.toml</span>.
          Verify with <span style={{ fontFamily: 'monospace' }}>grok mcp list</span> or
          {' '}<span style={{ fontFamily: 'monospace' }}>/mcps</span> in the TUI.
        </p>
      )}

      <div style={{
        display: 'grid',
        gridTemplateColumns: 'repeat(auto-fill, minmax(250px, 1fr))',
        gap: 6,
        marginBottom: 16,
      }}>
        {alaCarte.length > 0 && (
          <div style={{ marginBottom: 12 }}>
            <button
              type="button"
              onClick={() => setShowAlaCarte((v) => !v)}
              style={{ ...btnSm, fontSize: 12 }}
            >
              {showAlaCarte ? 'Hide extra endpoints' : 'Add individual endpoints'}
            </button>
            <span style={{ marginLeft: 8, fontSize: 11, color: 'var(--text-3)' }}>
              Default is the grouped Tobor Locker package. Extra subdomain endpoints are optional.
            </span>
          </div>
        )}

        {catalog.map((s) => (
          <label
            key={s.id}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: 8,
              padding: '6px 10px',
              borderRadius: 6,
              background: enabled[s.id] ? 'var(--accent-dim)' : 'var(--bg-3)',
              border: `1px solid ${enabled[s.id] ? 'var(--accent)' : 'var(--border)'}`,
              cursor: s.required ? 'default' : 'pointer',
              fontSize: 12,
            }}
          >
            <input
              type="checkbox"
              checked={enabled[s.id]}
              onChange={() => toggle(s.id)}
              disabled={s.required}
              style={{ accentColor: 'var(--accent)' }}
            />
            <div>
              <div style={{
                fontWeight: 500,
                color: enabled[s.id] ? 'var(--text-0)' : 'var(--text-3)',
              }}>
                {s.label}
                {s.default && (
                  <span style={{ fontSize: 9, color: 'var(--text-3)', marginLeft: 4 }}>
                    default
                  </span>
                )}
                {s.required && (
                  <span style={{ fontSize: 9, color: 'var(--text-3)', marginLeft: 4 }}>
                    required
                  </span>
                )}
              </div>
              <div style={{ fontSize: 10, color: 'var(--text-3)' }}>{s.desc}</div>
            </div>
          </label>
        ))}
      </div>

      <div style={{ position: 'relative' }}>
        <button
          onClick={copyScript}
          style={{
            ...btnSm,
            position: 'absolute',
            top: 8,
            right: 8,
            zIndex: 1,
            ...(copiedCmd === 'script'
              ? { background: 'var(--green-dim)', color: 'var(--green)', borderColor: 'var(--green)' }
              : {}),
          }}
        >
          {copiedCmd === 'script' ? 'Copied!' : `Copy (${activeCount})`}
        </button>
        <pre style={{
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
        }}>
          {buildScript()}
        </pre>
      </div>
    </div>
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

const clientToggleBtn = {
  padding: '5px 10px',
  fontSize: 11,
  border: 0,
  cursor: 'pointer',
  fontFamily: 'var(--font)',
};
