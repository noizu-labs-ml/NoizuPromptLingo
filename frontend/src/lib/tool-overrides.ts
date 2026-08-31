/**
 * Tool name/description override helpers (W9 — name+desc-overrides editor).
 *
 * Per-tool override entries live inside the scope config jsonb, keyed by
 * **canonical underscore tool name** (TOBOR-CONTRACTS.md §4/§7):
 *
 *   config.groups[groupId].tools[toolName] = {
 *     disabled?, hidden?,                       // existing toggle fields
 *     name_override?, description_override?,    // W9
 *     arg_overrides?: { [argName]: string },    // W9 arg-description overrides
 *   }
 *
 * These helpers only ever touch the W9 override fields — `disabled`/`hidden`
 * set by the toggle grids are preserved untouched. Empty values are pruned so
 * the jsonb never accumulates blank-string junk; entries that end up carrying
 * no state at all are removed entirely.
 */
import type { McpCustomScopeConfig } from './api';

/** Canonical underscore tool name (`Session.Create` → `Session_Create`). */
export function canonicalToolName(name: string): string {
  return name.replace(/\./g, '_');
}

/** W9 override fields carried on a per-tool config entry. */
export interface ToolOverrideEntry {
  name_override?: string;
  description_override?: string;
  arg_overrides?: Record<string, string>;
}

type ScopeToolEntry = NonNullable<
  NonNullable<NonNullable<McpCustomScopeConfig['groups']>[string]>['tools']
>[string];

/** Read the override fields for a tool (already key-normalized by the caller or not). */
export function overrideEntry(
  config: McpCustomScopeConfig,
  groupId: string,
  toolKey: string,
): ToolOverrideEntry {
  const tool = config.groups?.[groupId]?.tools?.[toolKey] as ScopeToolEntry | undefined;
  if (!tool) return {};
  return {
    name_override: tool.name_override,
    description_override: tool.description_override,
    arg_overrides: tool.arg_overrides ? { ...tool.arg_overrides } : undefined,
  };
}

function pruneEntry(entry: ScopeToolEntry): ScopeToolEntry | undefined {
  const next: ScopeToolEntry = { ...entry };
  if (typeof next.name_override === 'string') {
    if (next.name_override.trim() === '') delete next.name_override;
  }
  if (typeof next.description_override === 'string') {
    if (next.description_override.trim() === '') delete next.description_override;
  }
  if (next.arg_overrides) {
    const args = Object.fromEntries(
      Object.entries(next.arg_overrides).filter(([, v]) => typeof v === 'string' && v.trim() !== ''),
    );
    if (Object.keys(args).length === 0) delete next.arg_overrides;
    else next.arg_overrides = args;
  }
  const hasOverride =
    next.name_override !== undefined ||
    next.description_override !== undefined ||
    next.arg_overrides !== undefined;
  if (!hasOverride && next.disabled === undefined && next.hidden === undefined) return undefined;
  return next;
}

function cloneConfig(config: McpCustomScopeConfig): McpCustomScopeConfig {
  return {
    groups: Object.fromEntries(
      Object.entries(config.groups ?? {}).map(([groupId, group]) => [
        groupId,
        { ...group, tools: { ...(group.tools ?? {}) } },
      ]),
    ),
  };
}

/**
 * Patch the W9 override fields for one tool. `patch` replaces the full
 * override entry (pass `{}` to clear). Toggle fields (`disabled`/`hidden`)
 * are preserved. Keys the entry under `canonicalToolName(toolName)`.
 * Returns a new config; the input is never mutated.
 */
export function applyOverridePatch(
  config: McpCustomScopeConfig,
  groupId: string,
  toolName: string,
  patch: ToolOverrideEntry,
): McpCustomScopeConfig {
  const draft = cloneConfig(config);
  const group = draft.groups[groupId] ?? { tools: {} };
  group.tools = group.tools ?? {};
  const toolKey = canonicalToolName(toolName);
  // A legacy dotted-key entry may carry earlier state — migrate it (the
  // canonical-key entry, if also present, wins).
  const legacy =
    toolKey !== toolName ? (group.tools[toolName] as ScopeToolEntry | undefined) : undefined;
  const canonical = group.tools[toolKey] as ScopeToolEntry | undefined;
  const prior: ScopeToolEntry = { ...(legacy ?? {}), ...(canonical ?? {}) };
  const merged: ScopeToolEntry = {
    ...prior,
    ...(patch.name_override !== undefined ? { name_override: patch.name_override } : {}),
    ...(patch.description_override !== undefined
      ? { description_override: patch.description_override }
      : {}),
    ...(patch.arg_overrides !== undefined ? { arg_overrides: { ...patch.arg_overrides } } : {}),
  };
  const pruned = pruneEntry(merged);
  delete group.tools[toolKey];
  if (toolKey !== toolName) delete group.tools[toolName];
  if (pruned) group.tools[toolKey] = pruned;
  draft.groups[groupId] = group;
  return draft;
}

/** True when a tool entry carries any W9 override content (for UI badges). */
export function hasOverrides(config: McpCustomScopeConfig, groupId: string, toolKey: string): boolean {
  const entry = overrideEntry(config, groupId, toolKey);
  return (
    !!entry.name_override?.trim() ||
    !!entry.description_override?.trim() ||
    !!entry.arg_overrides && Object.values(entry.arg_overrides).some((v) => v.trim() !== '')
  );
}

/**
 * D3 dotted-write normalization: rewrite EVERY tools key in a config to the
 * canonical underscore form (F5). Legacy dotted entries merge under their
 * canonical key (canonical field values win), so saved configs stop carrying
 * both spellings of the same tool. Run this on save from every write path that
 * keys tool entries by catalog name.
 */
export function normalizeConfigToolKeys(config: McpCustomScopeConfig): McpCustomScopeConfig {
  const draft = cloneConfig(config);
  for (const group of Object.values(draft.groups)) {
    if (!group.tools) continue;
    const next: Record<string, ScopeToolEntry> = {};
    for (const [key, entry] of Object.entries(group.tools)) {
      const canonicalKey = canonicalToolName(key);
      const existing = next[canonicalKey];
      next[canonicalKey] =
        existing && key !== canonicalKey ? { ...entry, ...existing } : { ...(existing ?? entry) };
    }
    group.tools = next;
  }
  return draft;
}
