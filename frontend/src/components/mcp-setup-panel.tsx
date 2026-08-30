'use client';

import { useMemo, useState } from 'react';
import { toast } from 'sonner';
import { api, type McpCustomGroup, type McpCustomScope, type McpServerConfig } from '@/lib/api';
import { DEFAULT_MCP_AUTH_ENV_VAR } from '@/lib/mcp-setup';
import McpIncludeEditor from '@/components/mcp-include-editor';

type McpClient = 'claude' | 'codex' | 'grok';
type SetupTab = 'default' | 'alacarte';

interface McpSetupPanelProps {
  token: string; // The MCP JWT token
  keyLabel: string; // Label of the API key
  // Env var the token is exported as (org-scoped; see mcpAuthEnvVar).
  authEnvName?: string;
  servers: McpServerConfig[]; // Default grouped endpoint(s)
  alaCarte?: McpServerConfig[]; // Optional individual subdomain endpoints
  defaultScope?: McpCustomScope | null;
  endpoints?: McpCustomScope[];
  templates?: McpCustomScope[];
  catalog?: McpCustomGroup[];
  rawKey?: string | null;
  onSelectEndpoint?: (scope: McpCustomScope) => void;
  onEndpointChange?: (scope: McpCustomScope) => void;
  onClose: () => void;
}

const CLIENT_OPTIONS: { id: McpClient; label: string }[] = [
  { id: 'claude', label: 'Claude Code' },
  { id: 'codex', label: 'Codex' },
  { id: 'grok', label: 'Grok' },
];

/**
 * Sanitize MCP server registration names.
 * Grok only allows letters, numbers, hyphens, underscores. Custom scopes
 * arrive as "custom:<handle>" and register as "tobor-<handle>".
 */
function serverName(id: string) {
  if (id.startsWith('custom:')) return `tobor-${id.slice('custom:'.length)}`;
  return `tobor-${id.replace(/[^a-zA-Z0-9_-]/g, '-')}`;
}

/**
 * Generates MCP add commands for the given MCP servers. The bearer token is
 * exported under `authEnvName` (org-scoped; see mcpAuthEnvVar).
 *
 * Claude Code:
 *   claude mcp add --transport http tobor-{id} {url} --header "Authorization: Bearer $AUTH_ENV"
 *
 * Codex:
 *   codex mcp add tobor-{id} --url {url} --bearer-token-env-var AUTH_ENV
 *
 * Grok:
 *   grok mcp add --transport http tobor-{id} {url} --header "Authorization: Bearer $AUTH_ENV"
 *
 * Server URLs come from the backend config endpoint (host-derived), so this
 * component never hardcodes a host.
 */
export default function McpSetupPanel({
  token,
  keyLabel,
  authEnvName = DEFAULT_MCP_AUTH_ENV_VAR,
  servers,
  alaCarte = [],
  defaultScope = null,
  endpoints = [],
  templates = [],
  catalog = [],
  rawKey = null,
  onSelectEndpoint,
  onEndpointChange,
  onClose,
}: McpSetupPanelProps) {
  const [client, setClient] = useState<McpClient>('claude');
  const [tab, setTab] = useState<SetupTab>('default');
  const [enabled, setEnabled] = useState<Record<string, boolean>>(() => {
    const state: Record<string, boolean> = {};
    servers.forEach((s) => { state[s.id] = true; });
    alaCarte.forEach((s) => { state[s.id] = false; });
    return state;
  });
  const [copiedCmd, setCopiedCmd] = useState<string | null>(null);

  const selectable = useMemo(() => {
    const seen = new Set<string>();
    const rows: McpCustomScope[] = [];
    for (const row of [...endpoints, ...templates]) {
      if (!row?.id || seen.has(row.id)) continue;
      seen.add(row.id);
      rows.push(row);
    }
    return rows;
  }, [endpoints, templates]);

  const activeScope = defaultScope;

  const defaultServers: McpServerConfig[] = activeScope?.url
    ? [{
        id: `custom:${activeScope.slug}`,
        label: activeScope.name,
        required: true,
        default: true,
        desc: activeScope.description || 'Custom MCP include scope',
        url: activeScope.url,
        kind: activeScope.kind,
      }]
    : servers;

  const endpointCatalog = tab === 'alacarte' ? [...defaultServers, ...alaCarte] : defaultServers;

  function isEnabled(id: string) {
    if (tab === 'default') return enabled[id] !== false;
    return !!enabled[id];
  }

  function toggle(id: string) {
    const server = endpointCatalog.find((s) => s.id === id);
    if (server?.required) return;
    setEnabled((prev) => ({ ...prev, [id]: !isEnabled(id) }));
  }

  function getCommandLine(server: McpServerConfig) {
    const name = serverName(server.id);
    if (client === 'codex') {
      return `codex mcp add ${name} --url ${server.url} --bearer-token-env-var ${authEnvName}`;
    }
    if (client === 'grok') {
      return `grok mcp add --transport http ${name} ${server.url} --header "Authorization: Bearer $${authEnvName}"`;
    }

    return `claude mcp add --transport http ${name} ${server.url} --header "Authorization: Bearer $${authEnvName}"`;
  }

  function buildScript() {
    const lines = [
      `export ${authEnvName}=${token}`,
      '',
    ];
    endpointCatalog.filter((s) => isEnabled(s.id)).forEach((s) => {
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

  const activeCount = endpointCatalog.filter((s) => isEnabled(s.id)).length;
  const rootServer = servers.find((s) => s.default) ?? servers.find((s) => s.id === 'root') ?? servers[0];
  const oauthMcpUrl = defaultScope?.url ?? rootServer?.url ?? 'https://tobor.locker/custom/tobor/mcp';

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

      <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginBottom: 14 }}>
        {([
          { id: 'default' as const, label: 'Default MCP' },
          { id: 'alacarte' as const, label: 'À la carte (old flow)' },
        ]).map((t) => (
          <button
            key={t.id}
            type="button"
            onClick={() => setTab(t.id)}
            style={{
              ...btnSm,
              ...(tab === t.id
                ? { background: 'var(--accent)', color: 'white', borderColor: 'var(--accent)' }
                : {}),
            }}
          >
            {t.label}
          </button>
        ))}
      </div>

      {tab === 'default' && (
        <div style={{ marginBottom: 16 }}>
          {selectable.length > 0 ? (
            <div className="sg-field" style={{ marginBottom: 12 }}>
              <label htmlFor="mcp-setup-endpoint">Custom endpoint</label>
              <select
                id="mcp-setup-endpoint"
                value={activeScope?.id ?? ''}
                onChange={(e) => {
                  const next = selectable.find((s) => s.id === e.target.value);
                  if (next) onSelectEndpoint?.(next);
                }}
              >
                {selectable.map((s) => (
                  <option key={s.id} value={s.id}>
                    {s.name} — /custom/{s.slug}/mcp
                  </option>
                ))}
              </select>
            </div>
          ) : null}
          <div style={{ fontSize: 11, color: 'var(--text-3)', marginBottom: 10 }}>
            One custom endpoint
            {activeScope?.slug ? (
              <>
                {' '}with handle{' '}
                <span className="font-mono" style={{ color: 'var(--text-1)' }}>{activeScope.slug}</span>
              </>
            ) : null}
            . This command registers that single URL. Use the À la carte tab
            for the old per-subdomain flow.
          </div>
          {activeScope && catalog.length > 0 ? (
            <McpIncludeEditor
              key={activeScope.id}
              catalog={catalog}
              scope={activeScope}
              readOnly={activeScope.editable === false}
              save={(config) => api.updateMcpEndpoint(activeScope.id, { config }).then((r) => r.endpoint)}
              onSaved={(scope) => onEndpointChange?.(scope)}
            />
          ) : null}
        </div>
      )}

      {tab === 'alacarte' && (
        <div style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fill, minmax(250px, 1fr))',
          gap: 6,
          marginBottom: 16,
        }}>
          <div style={{ gridColumn: '1 / -1', fontSize: 11, color: 'var(--text-3)', marginBottom: 4 }}>
            Old flow — each selected subdomain is its own <span className="font-mono">mcp add</span>.
            Prefer the Default MCP tab (one Tobor Locker URL) unless you need a split catalog.
          </div>
          {endpointCatalog.map((s) => (
            <label
              key={s.id}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: 8,
                padding: '6px 10px',
                borderRadius: 6,
                background: isEnabled(s.id) ? 'var(--accent-dim)' : 'var(--bg-3)',
                border: `1px solid ${isEnabled(s.id) ? 'var(--accent)' : 'var(--border)'}`,
                cursor: s.required ? 'default' : 'pointer',
                fontSize: 12,
              }}
            >
              <input
                type="checkbox"
                checked={isEnabled(s.id)}
                onChange={() => toggle(s.id)}
                disabled={s.required}
                style={{ accentColor: 'var(--accent)' }}
              />
              <div>
                <div style={{
                  fontWeight: 500,
                  color: isEnabled(s.id) ? 'var(--text-0)' : 'var(--text-3)',
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
      )}

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
        {rawKey ? (
          <div className="authz-reveal" style={{ marginBottom: 12 }}>
            <div className="authz-reveal__label">Raw API key (shown once)</div>
            <div className="authz-reveal__row">
              <code className="authz-reveal__key font-mono">{rawKey}</code>
            </div>
          </div>
        ) : null}
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
