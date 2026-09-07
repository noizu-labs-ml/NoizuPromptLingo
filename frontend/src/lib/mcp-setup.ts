import type { McpCustomGroup, McpCustomScopeConfig } from '@/lib/api';

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

// ── Alacarte: ?t= tool-selection params + endpoint display media ────────────

/**
 * A `?t=` tool-selection spec for custom-scope gateways. Shape mirrors the
 * backend `NoizuPromptLingua.MCP.UrlToolsetParam` decode schema. Kebab-case
 * keys are canonical (what encodeToolsetParam emits, per the plan's
 * "white-list" > "black-list" > tools wording); the snake_case aliases are
 * accepted on input and canonicalized by compactToolsetSpec.
 */
export type ToolsetParamWhiteEntry = string | { name: string; visible?: boolean };

export interface ToolsetParamSpec {
  "white-list"?: ToolsetParamWhiteEntry[];
  "black-list"?: string[];
  // Accepted snake_case aliases for the kebab-case keys above.
  white_list?: ToolsetParamWhiteEntry[];
  black_list?: string[];
  tools?: Record<string, { visible?: boolean }>;
  default?: boolean | string;
}

/** Canonical underscore tool name (`Session.Create` → `Session_Create`). */
function canonTool(name: string): string {
  return name.replace(/\./g, '_');
}

function normalizeWhiteEntries(spec: ToolsetParamSpec | null | undefined): WhiteEntry[] {
  const entries: WhiteEntry[] = [];
  for (const entry of [...(spec?.["white-list"] ?? []), ...(spec?.white_list ?? [])]) {
    if (typeof entry === 'string') {
      if (entry.trim() !== '') entries.push({ name: entry });
    } else if (entry && typeof entry.name === 'string' && entry.name.trim() !== '') {
      entries.push(
        entry.visible === undefined ? { name: entry.name } : { name: entry.name, visible: entry.visible },
      );
    }
  }
  return entries;
}

interface WhiteEntry {
  name: string;
  visible?: boolean;
}

/** Drop empty keys so the JSON — and therefore the URL token — stays small;
 * snake_case aliases are canonicalized to kebab-case here. */
export function compactToolsetSpec(spec: ToolsetParamSpec): ToolsetParamSpec {
  const out: ToolsetParamSpec = {};

  const white = normalizeWhiteEntries(spec);
  if (white.length > 0) {
    out["white-list"] = white.map((entry) =>
      entry.visible === undefined ? entry.name : { name: entry.name, visible: entry.visible },
    );
  }

  const black = [
    ...(spec["black-list"] ?? []),
    ...(spec.black_list ?? []),
  ].filter((name) => typeof name === 'string' && name.trim() !== '');
  if (black.length > 0) out["black-list"] = black;

  const tools: Record<string, { visible?: boolean }> = {};
  for (const [name, flags] of Object.entries(spec.tools ?? {})) {
    if (!flags || flags.visible === undefined) continue;
    tools[name] = { visible: flags.visible };
  }
  if (Object.keys(tools).length > 0) out.tools = tools;

  if (spec.default !== undefined && spec.default !== false) out.default = spec.default;
  return out;
}

/**
 * base64url (no padding — the decoder re-pads and rejects +/) of the compact
 * JSON spec. UTF-8-safe via the classic btoa(unescape(encodeURIComponent())).
 */
export function encodeToolsetParam(spec: ToolsetParamSpec): string {
  const json = JSON.stringify(compactToolsetSpec(spec));
  return btoa(unescape(encodeURIComponent(json)))
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=+$/, '');
}

/** Full gateway URL with the `?t=` token appended (? or & as appropriate). */
export function toolSelectionUrl(path: string, spec: ToolsetParamSpec): string {
  const sep = path.includes('?') ? '&' : '?';
  return `${path}${sep}t=${encodeToolsetParam(spec)}`;
}

// Media refs (endpoint display images).

// Mirrors lib/api's API_URL: empty on the client (same-origin), absolute when
// server-rendered with NEXT_PUBLIC_API_URL set.
const MEDIA_API_URL = process.env.NEXT_PUBLIC_API_URL || '';

export interface MediaRefUrls {
  thumb: string | null;
  banner: string | null;
}

/**
 * Endpoint display image refs are media `short_id`s (from
 * api.uploadEndpointImage) — rendered as `/media/:short_id` variants — or
 * plain http(s) URLs, which pass through unchanged.
 */
export function parseMediaRef(ref?: string | null): MediaRefUrls {
  const value = (ref ?? '').trim();
  if (value === '') return { thumb: null, banner: null };
  if (/^https?:\/\//i.test(value)) return { thumb: value, banner: value };
  const shortId = value.replace(/^\/media\//, '');
  return {
    thumb: `${MEDIA_API_URL}/media/${encodeURIComponent(shortId)}?w=200&f=webp`,
    banner: `${MEDIA_API_URL}/media/${encodeURIComponent(shortId)}?w=1600&fit=cover`,
  };
}

// Effective-toolset preview (TS mirror of the backend compile).

/** One available tool, bounded to the endpoint's included groups. */
export interface ToolsetUniverseEntry {
  group: string;
  name: string;
  /** Catalog default visibility (`tool.hidden`); absent = visible. */
  catalogHidden?: boolean;
}

export interface EffectiveToolFlags {
  enabled: boolean;
  visible: boolean;
}

export interface ToolsetCompileOptions {
  /** Preset name → tool names, mirroring the backend `@presets` registry. */
  presets?: Record<string, string[]>;
}

function storedToolEntry(
  config: McpCustomScopeConfig | null | undefined,
  group: string,
  name: string,
) {
  const tools = config?.groups?.[group]?.tools ?? {};
  const canonical = canonTool(name);
  return tools[name] ?? tools[canonical];
}

/**
 * Group-bounded universe: only tools of groups the scope config includes
 * (group present and not `disabled`). Everything else is outside the param's
 * power — the param narrows within this set, never widens past it.
 */
export function universeFromCatalog(
  catalog: McpCustomGroup[],
  scopeConfig: McpCustomScopeConfig | null | undefined,
): ToolsetUniverseEntry[] {
  const entries: ToolsetUniverseEntry[] = [];
  for (const group of catalog) {
    const groupEntry = scopeConfig?.groups?.[group.id];
    if (!groupEntry || groupEntry.disabled === true) continue;
    for (const tool of group.tools) {
      entries.push({ group: group.id, name: tool.name, catalogHidden: tool.hidden });
    }
  }
  return entries;
}

/**
 * TS mirror of `UrlToolsetParam.compile/2` for live admin preview — keep in
 * lockstep with the backend or the golden vectors drift. Accepts both
 * kebab-case (canonical) and snake_case top-level keys. Precedence:
 *
 *   1) white-list / `default` define the enable set (absent-from-set →
 *      disabled; white-listed tools re-enable stored-disabled entries).
 *      `default: true` expands to the stored-config enabled set; preset
 *      names expand from `opts.presets` (unknown presets expand empty).
 *   2) black-list disables unless the tool is explicitly white-listed
 *      (default-expanded tools do NOT count as white-listed).
 *   3) white-list entry `visible` flags set visibility for that tool.
 *   4) `tools` map is lowest — applies only when no white-list constrains;
 *      `visible: true` re-enables a stored-disabled tool within the universe.
 *
 * Unknown names are dead entries: they never appear in the result. Returns
 * flags keyed by canonical tool name. Absent/empty spec = the stored-config
 * baseline (byte-identical no-param behavior).
 */
export function computeEffectiveTools(
  scopeConfig: McpCustomScopeConfig | null | undefined,
  universe: ToolsetUniverseEntry[],
  spec: ToolsetParamSpec | null | undefined,
  opts: ToolsetCompileOptions = {},
): Record<string, EffectiveToolFlags> {
  const result: Record<string, EffectiveToolFlags> = {};
  const baseline = new Map<string, EffectiveToolFlags>();
  for (const entry of universe) {
    const key = canonTool(entry.name);
    if (baseline.has(key)) continue;
    const stored = storedToolEntry(scopeConfig, entry.group, entry.name);
    const hidden = stored?.hidden ?? entry.catalogHidden === true;
    baseline.set(key, { enabled: stored?.disabled !== true, visible: !hidden });
  }

  const whiteEntries = normalizeWhiteEntries(spec);
  const whiteNames = new Set(whiteEntries.map((entry) => canonTool(entry.name)));
  const blackNames = new Set(
    [...(spec?.["black-list"] ?? []), ...(spec?.black_list ?? [])].map(canonTool),
  );
  const toolsMap = spec?.tools ?? {};
  const hasWhite = whiteNames.size > 0;
  const hasDefault = spec?.default !== undefined && spec.default !== false;

  let enableSet: Set<string> | null = null;
  if (hasWhite || hasDefault) {
    enableSet = new Set(whiteNames);
    if (hasDefault && spec!.default === true) {
      for (const [key, flags] of baseline) {
        if (flags.enabled) enableSet.add(key);
      }
    } else if (hasDefault && typeof spec!.default === 'string') {
      for (const name of opts.presets?.[spec!.default] ?? []) enableSet.add(canonTool(name));
    }
  }

  for (const [key, base] of baseline) {
    let enabled = base.enabled;
    let visible = base.visible;

    if (enableSet) {
      // Absent-from-set → disabled; white-listed re-enables stored-disabled.
      enabled = enableSet.has(key);
    }

    // Black-list loses to an explicit white-list entry.
    if (blackNames.has(key) && !(hasWhite && whiteNames.has(key))) enabled = false;

    if (hasWhite) {
      const entry = whiteEntries.find((e) => canonTool(e.name) === key);
      if (entry?.visible !== undefined) visible = entry.visible;
    } else {
      const flags = toolsMap[key];
      if (flags?.visible !== undefined) {
        visible = flags.visible;
        if (flags.visible) enabled = true; // re-enable stored-disabled, in-universe
      }
    }

    result[key] = { enabled, visible };
  }
  return result;
}
