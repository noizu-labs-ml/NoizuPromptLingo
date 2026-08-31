import assert from 'node:assert/strict';
import test from 'node:test';
import {
  DEFAULT_MCP_AUTH_ENV_VAR,
  MCP_OAUTH_CLIENTS,
  mcpAuthEnvVar,
  mcpCliServerName,
  mcpOauthHint,
  mcpOauthServerName,
  mcpOauthSnippet,
  type McpOauthClient,
} from './mcp-setup';

const URL = 'https://tobor.locker/custom/tobor/mcp';
const NAME = 'tobor-tobor';

test('mcpAuthEnvVar is org-scoped and never the bare AUTH_TOKEN name', () => {
  assert.equal(mcpAuthEnvVar(null), DEFAULT_MCP_AUTH_ENV_VAR);
  assert.equal(mcpAuthEnvVar('noizu-labs'), 'NOIZU_LABS_AUTH_TOKEN');
  assert.equal(mcpAuthEnvVar('acme-org'), 'ACME_ORG_AUTH_TOKEN');
  assert.notEqual(mcpAuthEnvVar('noizu-labs'), 'AUTH_TOKEN');
});

test('mcpCliServerName / mcpOauthServerName sanitize registration names', () => {
  assert.equal(mcpCliServerName('custom:tobor'), 'tobor-tobor');
  assert.equal(mcpCliServerName('root'), 'tobor-root');
  assert.equal(mcpCliServerName('foo.bar'), 'tobor-foo-bar');
  assert.equal(mcpOauthServerName('tobor'), 'tobor-tobor');
  assert.equal(mcpOauthServerName(null), 'tobor-default-mcp');
});

test('MCP_OAUTH_CLIENTS covers Claude Code, Desktop, Codex, Cursor, VS Code, Grok', () => {
  assert.deepEqual(
    MCP_OAUTH_CLIENTS.map((c) => c.id),
    ['claude-code', 'claude-desktop', 'codex', 'cursor', 'vscode', 'grok'],
  );
  assert.equal(MCP_OAUTH_CLIENTS.find((c) => c.id === 'claude-desktop')?.dest, 'claude_desktop_config.json');
  assert.equal(MCP_OAUTH_CLIENTS.find((c) => c.id === 'codex')?.dest, '~/.codex/config.toml');
  assert.equal(MCP_OAUTH_CLIENTS.find((c) => c.id === 'cursor')?.dest, '.cursor/mcp.json');
  assert.equal(MCP_OAUTH_CLIENTS.find((c) => c.id === 'vscode')?.dest, '.vscode/mcp.json');
});

test('OAuth snippets prefer URL / OAuth CLI, never a long-lived bearer', () => {
  const clients = MCP_OAUTH_CLIENTS.map((c) => c.id);
  for (const client of clients) {
    const snippet = mcpOauthSnippet(client, NAME, URL);
    assert.match(snippet, /tobor\.locker\/custom\/tobor\/mcp/);
    assert.doesNotMatch(snippet, /Bearer/i);
    assert.doesNotMatch(snippet, /Authorization/i);
    assert.doesNotMatch(snippet, /AUTH_TOKEN/);
    assert.ok(mcpOauthHint(client).length > 0, `${client} hint`);
  }
});

test('Claude Code and Grok use http transport CLI; Codex is config.toml', () => {
  assert.equal(
    mcpOauthSnippet('claude-code', NAME, URL),
    `claude mcp add --transport http ${NAME} ${URL}`,
  );
  assert.equal(
    mcpOauthSnippet('grok', NAME, URL),
    `grok mcp add --transport http ${NAME} ${URL}`,
  );
  const toml = mcpOauthSnippet('codex', NAME, URL);
  assert.match(toml, /\[mcp_servers\.tobor-tobor\]/);
  assert.match(toml, /url = "https:\/\/tobor\.locker\/custom\/tobor\/mcp"/);
  assert.match(toml, /codex mcp add tobor-tobor --url /);
});

test('Desktop/Cursor share mcpServers JSON; VS Code uses servers + type http', () => {
  const desktop = JSON.parse(mcpOauthSnippet('claude-desktop', NAME, URL));
  const cursor = JSON.parse(mcpOauthSnippet('cursor', NAME, URL));
  const vscode = JSON.parse(mcpOauthSnippet('vscode', NAME, URL));
  assert.deepEqual(desktop, { mcpServers: { [NAME]: { url: URL } } });
  assert.deepEqual(cursor, desktop);
  assert.deepEqual(vscode, { servers: { [NAME]: { type: 'http', url: URL } } });
});

test('every OAuth client has a dedicated snippet builder', () => {
  const ids: McpOauthClient[] = ['claude-code', 'claude-desktop', 'codex', 'cursor', 'vscode', 'grok'];
  for (const id of ids) {
    assert.ok(mcpOauthSnippet(id, NAME, URL).includes(NAME));
  }
});
