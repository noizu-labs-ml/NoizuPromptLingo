import * as assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { test } from 'node:test';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const src = readFileSync(resolve(here, 'connect-instructions.tsx'), 'utf8');
const lib = readFileSync(resolve(here, '../../lib/mcp-setup.ts'), 'utf8');
const connections = readFileSync(resolve(here, 'connections-list.tsx'), 'utf8');
const page = readFileSync(resolve(here, '../../app/app/mcp-setup/page.tsx'), 'utf8');
const panel = readFileSync(resolve(here, '../mcp-setup-panel.tsx'), 'utf8');

function contract(source: string, pattern: RegExp, message: string) {
  assert.ok(pattern.test(source), message);
}

void test('Connect instructions copy OAuth snippets for every required client', () => {
  contract(src, /MCP_OAUTH_CLIENTS/, 'must iterate MCP_OAUTH_CLIENTS');
  contract(src, /mcpOauthSnippet/, 'must render mcpOauthSnippet');
  contract(lib, /id: 'claude-code'/, 'Claude Code');
  contract(lib, /id: 'claude-desktop'/, 'Claude Desktop');
  contract(lib, /id: 'codex'/, 'Codex');
  contract(lib, /id: 'cursor'/, 'Cursor');
  contract(lib, /id: 'vscode'/, 'VS Code Copilot');
  contract(lib, /id: 'grok'/, 'Grok');
  contract(lib, /claude_desktop_config\.json/, 'Desktop dest');
  contract(lib, /~\/\.codex\/config\.toml/, 'Codex dest');
  contract(lib, /\.cursor\/mcp\.json/, 'Cursor dest');
  contract(lib, /\.vscode\/mcp\.json/, 'VS Code dest');
  contract(src, /data-mcp-oauth-client=\{client\}/, 'snippet carries the e2e hook attribute');
  contract(src, /Access is not unlimited/, 'default-grant warning');
  contract(src, /\/oauth/, 'MCP PKCE stays on /oauth');
  contract(src, /not Authentik/, 'Authentik is not the MCP AS');
  assert.doesNotMatch(src, /\btoken\??:/, 'no raw token prop — snippets reference env var names only');
});

void test('mcp-setup page hosts the connect instructions without a bearer paste', () => {
  contract(page, /ConnectInstructions/, 'mcp-setup renders ConnectInstructions');
  const call = page.match(/<ConnectInstructions[\s\S]*?\/>/);
  assert.ok(call, 'ConnectInstructions is invoked');
  assert.doesNotMatch(call[0], /token=/, 'OAuth-first surface is never handed a raw token');
  contract(src, /Manual \/ CLI/, 'per-CLI bearer snippets live on the manual tab');
});

void test('connections list revokes through a confirm dialog', () => {
  contract(connections, /ConfirmDialog/, 'revoke is confirm-guarded');
  contract(connections, /destructive/, 'revocation is marked destructive');
  contract(connections, /onRevoke/, 'revoke action is injected by the host page');
});

void test('legacy setup panel also exposes Desktop, Cursor, and VS Code', () => {
  contract(panel, /id: 'desktop'/, 'Claude Desktop');
  contract(panel, /id: 'cursor'/, 'Cursor');
  contract(panel, /id: 'vscode'/, 'VS Code Copilot');
  contract(panel, /claude_desktop_config\.json/, 'Desktop dest file');
  contract(panel, /\.cursor\/mcp\.json/, 'Cursor dest file');
  contract(panel, /\.vscode\/mcp\.json/, 'VS Code dest file');
});
