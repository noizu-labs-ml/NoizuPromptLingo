import * as assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { test } from 'node:test';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const src = readFileSync(resolve(here, 'mcp-oauth-setup.tsx'), 'utf8');
const lib = readFileSync(resolve(here, '../lib/mcp-setup.ts'), 'utf8');
const page = readFileSync(resolve(here, '../app/app/mcp-keys/page.tsx'), 'utf8');
const panel = readFileSync(resolve(here, 'mcp-setup-panel.tsx'), 'utf8');

function contract(source: string, pattern: RegExp, message: string) {
  assert.ok(pattern.test(source), message);
}

void test('OAuth setup copies snippets for every required client', () => {
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
  contract(src, /Access is not unlimited/, 'default-grant warning');
  contract(src, /\/oauth/, 'MCP PKCE stays on /oauth');
  contract(src, /not Authentik/, 'Authentik is not the MCP AS');
  assert.doesNotMatch(src, /Authorization: Bearer/, 'OAuth panel must not paste a bearer');
});

void test('mcp-keys page hosts the OAuth panel', () => {
  contract(page, /McpOauthSetup/, 'mcp-keys renders McpOauthSetup');
  const oauthCall = page.match(/<McpOauthSetup[\s\S]*?\/>/);
  assert.ok(oauthCall, 'McpOauthSetup is invoked');
  assert.doesNotMatch(oauthCall[0], /authEnvName/, 'OAuth panel is not passed a bearer env var');
});

void test('legacy setup panel also exposes Desktop, Cursor, and VS Code', () => {
  contract(panel, /id: 'desktop'/, 'Claude Desktop');
  contract(panel, /id: 'cursor'/, 'Cursor');
  contract(panel, /id: 'vscode'/, 'VS Code Copilot');
  contract(panel, /claude_desktop_config\.json/, 'Desktop dest file');
  contract(panel, /\.cursor\/mcp\.json/, 'Cursor dest file');
  contract(panel, /\.vscode\/mcp\.json/, 'VS Code dest file');
});
