/**
 * Env var name for the MCP bearer token in generated setup snippets.
 *
 * Org-scoped so a user wiring multiple orgs (or a personal + org setup) does
 * not have colliding `AUTH_TOKEN` exports in one shell. Falls back to the
 * historical name when no org slug is resolvable.
 */
export const DEFAULT_MCP_AUTH_ENV_VAR = 'TOBOR_LOCKER_AUTH_TOKEN';

export function mcpAuthEnvVar(slug?: string | null): string {
  if (!slug) return DEFAULT_MCP_AUTH_ENV_VAR;
  return `${slug.replace(/[^a-zA-Z0-9]+/g, '_').toUpperCase()}_AUTH_TOKEN`;
}

/**
 * Sanitize MCP server registration names.
 * Grok only allows letters, numbers, hyphens, underscores. Custom scopes
 * arrive as "custom:<handle>" and register as "tobor-<handle>".
 */
export function mcpCliServerName(id: string): string {
  if (id.startsWith('custom:')) return `tobor-${id.slice('custom:'.length)}`;
  return `tobor-${id.replace(/[^a-zA-Z0-9_-]/g, '-')}`;
}

export function mcpOauthServerName(slug?: string | null): string {
  if (!slug) return 'tobor-default-mcp';
  return mcpCliServerName(`custom:${slug}`);
}

export type McpOauthClient =
  | 'claude-code'
  | 'claude-desktop'
  | 'codex'
  | 'cursor'
  | 'vscode'
  | 'grok';

export const MCP_OAUTH_CLIENTS: { id: McpOauthClient; label: string; dest: string }[] = [
  { id: 'claude-code', label: 'Claude Code', dest: 'CLI' },
  { id: 'claude-desktop', label: 'Claude Desktop', dest: 'claude_desktop_config.json' },
  { id: 'codex', label: 'Codex', dest: '~/.codex/config.toml' },
  { id: 'cursor', label: 'Cursor', dest: '.cursor/mcp.json' },
  { id: 'vscode', label: 'VS Code Copilot', dest: '.vscode/mcp.json' },
  { id: 'grok', label: 'Grok', dest: 'CLI' },
];

/** One-line hint under the copy block — not part of the copied snippet. */
export function mcpOauthHint(client: McpOauthClient): string {
  switch (client) {
    case 'claude-code':
      return 'Paste in a terminal. The CLI discovers OAuth (DCR + PKCE) and opens a browser.';
    case 'claude-desktop':
      return 'Merge into ~/Library/Application Support/Claude/claude_desktop_config.json (macOS) or %APPDATA%\\Claude\\claude_desktop_config.json (Windows). Or Settings → Connectors → Add custom connector and paste the MCP URL only.';
    case 'codex':
      return 'Merge into ~/.codex/config.toml, or run the commented `codex mcp add` one-liner. First connect opens a browser when the client supports OAuth.';
    case 'cursor':
      return 'Merge into .cursor/mcp.json (project) or ~/.cursor/mcp.json (global). Then Cursor Settings → Tools & MCP → Connect.';
    case 'vscode':
      return 'Merge into .vscode/mcp.json (workspace) or user MCP config (Command Palette → MCP: Open User Configuration). Copilot reads this file; first connect opens a browser.';
    case 'grok':
      return 'Writes to ~/.grok/config.toml by default (--scope user). First connect opens a browser. Confirm with grok mcp list.';
  }
}

/**
 * OAuth-only install snippet (no long-lived bearer). Clients discover the AS
 * from RFC 9728 on the MCP URL.
 */
export function mcpOauthSnippet(client: McpOauthClient, name: string, url: string): string {
  switch (client) {
    case 'claude-code':
      return `claude mcp add --transport http ${name} ${url}`;
    case 'claude-desktop':
    case 'cursor':
      return JSON.stringify({ mcpServers: { [name]: { url } } }, null, 2);
    case 'codex':
      return [
        `# ~/.codex/config.toml`,
        `# or: codex mcp add ${name} --url ${url}`,
        `[mcp_servers.${name}]`,
        `url = "${url}"`,
      ].join('\n');
    case 'vscode':
      return JSON.stringify({ servers: { [name]: { type: 'http', url } } }, null, 2);
    case 'grok':
      return `grok mcp add --transport http ${name} ${url}`;
  }
}
