'use client';

/**
 * W9 — name + description override editor (TOBOR-CONTRACTS.md §7).
 *
 * `ToolOverridesEditor` renders the ToolTogglesGrid-style grouping (one
 * section per tool group, one row per tool) with per-tool editors for
 * `name_override`, `description_override`, and `arg_overrides`
 * (arg name → description). Pure controlled component: the host owns the
 * scope config and persistence (the scope-update API), same pattern as the
 * mcp-custom-scopes page edits.
 *
 * Entries are keyed by canonical underscore tool name (§4) via
 * `canonicalToolName` from `@/lib/tool-overrides`.
 */
import { useState } from 'react';
import type { McpCustomScopeConfig } from '@/lib/api';
import {
  applyOverridePatch,
  canonicalToolName,
  hasOverrides,
  overrideEntry,
  type ToolOverrideEntry,
} from '@/lib/tool-overrides';

export interface ToolOverridesTool {
  /** Catalog name — dotted legacy or canonical underscore; entries key canonically. */
  name: string;
  description: string;
  parameters?: { name: string; description: string; type?: string; required?: boolean }[];
}

export interface ToolOverridesGroup {
  /** Group id — matches scope config `groups` keys. */
  group: string;
  label?: string;
  tools: ToolOverridesTool[];
}

interface ToolOverridesEditorProps {
  groups: ToolOverridesGroup[];
  /** Full scope config; only W9 override fields are read/written. */
  value: McpCustomScopeConfig;
  /** Emits the full next config (pure controlled). */
  onChange: (next: McpCustomScopeConfig) => void;
  readOnly?: boolean;
}

/**
 * Single-tool override fields. Also exported for embedding in table rows /
 * sidebars (used by the mcp-custom-scopes page's per-tool expander).
 */
export function ToolOverrideFields({
  tool,
  entry,
  onChange,
  readOnly = false,
  idPrefix,
}: {
  tool: ToolOverridesTool;
  entry: ToolOverrideEntry;
  onChange: (next: ToolOverrideEntry) => void;
  readOnly?: boolean;
  idPrefix: string;
}) {
  const [newArg, setNewArg] = useState('');
  const knownArgs = tool.parameters ?? [];
  const extraArgs = Object.keys(entry.arg_overrides ?? {}).filter(
    (arg) => !knownArgs.some((p) => p.name === arg),
  );
  const argRows = [
    ...knownArgs.map((p) => ({ name: p.name, fallback: p.description })),
    ...extraArgs.map((name) => ({ name, fallback: '' })),
  ];

  function patchArg(arg: string, value: string) {
    const args = { ...(entry.arg_overrides ?? {}) };
    if (value.trim() === '') delete args[arg];
    else args[arg] = value;
    onChange({ ...entry, arg_overrides: args });
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }} aria-label={`Overrides for ${tool.name}`}>
      <div>
        <label htmlFor={`${idPrefix}-name`} style={{ fontSize: 11, fontWeight: 600, color: 'var(--text-2)' }}>
          Name override
        </label>
        <input
          id={`${idPrefix}-name`}
          value={entry.name_override ?? ''}
          placeholder={canonicalToolName(tool.name)}
          readOnly={readOnly}
          onChange={(e) => onChange({ ...entry, name_override: e.target.value })}
          style={{ width: '100%', fontFamily: 'monospace', fontSize: 12 }}
        />
      </div>
      <div>
        <label
          htmlFor={`${idPrefix}-desc`}
          style={{ fontSize: 11, fontWeight: 600, color: 'var(--text-2)' }}
        >
          Description override
        </label>
        <textarea
          id={`${idPrefix}-desc`}
          value={entry.description_override ?? ''}
          placeholder={tool.description}
          readOnly={readOnly}
          rows={2}
          onChange={(e) => onChange({ ...entry, description_override: e.target.value })}
          style={{ width: '100%', fontSize: 12 }}
        />
      </div>
      {argRows.length > 0 && (
        <div>
          <span style={{ fontSize: 11, fontWeight: 600, color: 'var(--text-2)' }}>
            Argument description overrides
          </span>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 4, marginTop: 4 }}>
            {argRows.map((arg) => (
              <div key={arg.name} style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                <span
                  className="font-mono"
                  style={{ flex: '0 0 140px', fontSize: 11, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}
                  title={arg.name}
                >
                  {arg.name}
                </span>
                <input
                  aria-label={`Description override for ${tool.name} argument ${arg.name}`}
                  value={entry.arg_overrides?.[arg.name] ?? ''}
                  placeholder={arg.fallback || 'argument description'}
                  readOnly={readOnly}
                  onChange={(e) => patchArg(arg.name, e.target.value)}
                  style={{ flex: 1, fontSize: 12 }}
                />
              </div>
            ))}
          </div>
        </div>
      )}
      {!readOnly && (
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <input
            aria-label="New argument name"
            value={newArg}
            placeholder="add argument by name"
            onChange={(e) => setNewArg(e.target.value)}
            style={{ flex: '0 0 180px', fontFamily: 'monospace', fontSize: 12 }}
          />
          <button
            type="button"
            className="sg-btn sg-btn--outline sg-btn--sm"
            disabled={!newArg.trim() || argRows.some((r) => r.name === newArg.trim())}
            onClick={() => {
              const name = newArg.trim();
              if (!name) return;
              patchArg(name, entry.arg_overrides?.[name] ?? '');
              setNewArg('');
            }}
          >
            Add argument
          </button>
        </div>
      )}
    </div>
  );
}

export default function ToolOverridesEditor({
  groups,
  value,
  onChange,
  readOnly = false,
}: ToolOverridesEditorProps) {
  const [open, setOpen] = useState<Record<string, boolean>>({});

  function patchTool(groupId: string, tool: ToolOverridesTool, entry: ToolOverrideEntry) {
    onChange(applyOverridePatch(value, groupId, tool.name, entry));
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }} role="group" aria-label="Tool overrides">
      {groups.map((group) => (
        <section
          key={group.group}
          aria-label={`Tool group ${group.group}`}
          style={{
            borderRadius: 6,
            border: '1px solid var(--border)',
            background: 'var(--bg-3)',
            overflow: 'hidden',
          }}
        >
          <div
            style={{
              padding: '8px 12px',
              borderBottom: '1px solid var(--border)',
              background: 'var(--bg-2)',
              fontSize: 12,
              fontWeight: 600,
              color: 'var(--text-0)',
            }}
          >
            {group.label ?? group.group}
            <span style={{ fontWeight: 400, fontSize: 10, color: 'var(--text-3)', marginLeft: 6 }}>
              {group.tools.filter((t) => hasOverrides(value, group.group, canonicalToolName(t.name))).length}/
              {group.tools.length} overridden
            </span>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column' }}>
            {group.tools.map((tool) => {
              const toolKey = canonicalToolName(tool.name);
              const expanded = open[`${group.group}/${toolKey}`] ?? false;
              const overridden = hasOverrides(value, group.group, toolKey);
              return (
                <div
                  key={tool.name}
                  style={{ borderBottom: '1px solid var(--border)' }}
                >
                  <div
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      gap: 10,
                      padding: '6px 12px',
                      background: 'var(--bg-2)',
                    }}
                  >
                    <span
                      title={tool.name}
                      className="font-mono"
                      style={{
                        flex: 1,
                        fontSize: 11,
                        color: 'var(--text-0)',
                        overflow: 'hidden',
                        textOverflow: 'ellipsis',
                        whiteSpace: 'nowrap',
                      }}
                    >
                      {tool.name}
                      {overridden && (
                        <span
                          title="Has overrides"
                          style={{
                            marginLeft: 6,
                            fontSize: 9,
                            padding: '1px 5px',
                            borderRadius: 8,
                            background: 'var(--accent)',
                            color: 'var(--bg-1)',
                            verticalAlign: 'middle',
                          }}
                        >
                          edited
                        </span>
                      )}
                    </span>
                    <button
                      type="button"
                      className="sg-btn sg-btn--outline sg-btn--sm"
                      aria-expanded={expanded}
                      onClick={() =>
                        setOpen((cur) => ({
                          ...cur,
                          [`${group.group}/${toolKey}`]: !expanded,
                        }))
                      }
                    >
                      {expanded ? 'Hide' : 'Overrides'}
                    </button>
                  </div>
                  {expanded && (
                    <div style={{ padding: '8px 12px 12px' }}>
                      <ToolOverrideFields
                        idPrefix={`toe-${group.group}-${toolKey}`}
                        tool={tool}
                        entry={overrideEntry(value, group.group, toolKey)}
                        onChange={(next) => patchTool(group.group, tool, next)}
                        readOnly={readOnly}
                      />
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        </section>
      ))}
    </div>
  );
}

// ---------------------------------------------------------------------------
// N4a — closed-vocabulary tool-set overrides editor (PRD-N4 §4.2).
//
// `ToolSetOverridesEditor` mirrors the ToolOverridesEditor visual grammar but
// emits exactly the PRD-N2 §4.1 tool-set jsonb shape (`ToolSetConfig` from
// `@/lib/acl-api`): group include = key presence, per-tool enabled/name/
// description, per-arg enum_remove/hide/rename/default/description. Unknown
// keys are impossible by construction — every write goes through the typed
// patch helpers below. Pure controlled, host owns persistence.
// ---------------------------------------------------------------------------

import type {
  ToolSetArgConfig,
  ToolSetConfig,
  ToolSetGroupConfig,
  ToolSetToolConfig,
} from '@/lib/acl-api';

interface ToolSetOverridesEditorProps {
  groups: ToolOverridesGroup[];
  /** Full tool-set config; groups/tools/args keys are read/written here. */
  value: ToolSetConfig;
  /** Emits the full next config (pure controlled). */
  onChange: (next: ToolSetConfig) => void;
  readOnly?: boolean;
}

/** Drop keys whose value is absent/empty so stored configs stay minimal. */
function pruneEmpty<T extends Record<string, unknown>>(obj: T): T {
  const out: Record<string, unknown> = {};
  for (const [k, v] of Object.entries(obj)) {
    if (v === undefined || v === null) continue;
    if (typeof v === 'string' && v === '') continue;
    if (Array.isArray(v) && v.length === 0) continue;
    if (typeof v === 'object' && !Array.isArray(v) && Object.keys(v).length === 0) continue;
    out[k] = v;
  }
  return out as T;
}

function patchArg(
  args: Record<string, ToolSetArgConfig> | undefined,
  argName: string,
  patch: Partial<ToolSetArgConfig>,
): Record<string, ToolSetArgConfig> {
  const next: Record<string, ToolSetArgConfig> = { ...(args ?? {}) };
  const merged = pruneEmpty({ ...(next[argName] ?? {}), ...patch }) as ToolSetArgConfig;
  if (Object.keys(merged).length === 0) delete next[argName];
  else next[argName] = merged;
  return next;
}

function patchToolCfg(
  tools: Record<string, ToolSetToolConfig> | undefined,
  toolName: string,
  patch: Partial<ToolSetToolConfig>,
): Record<string, ToolSetToolConfig> {
  const next: Record<string, ToolSetToolConfig> = { ...(tools ?? {}) };
  const merged = pruneEmpty({ ...(next[toolName] ?? {}), ...patch }) as ToolSetToolConfig;
  const { args, ...rest } = merged as ToolSetToolConfig & { args?: unknown };
  if (args === undefined) delete (rest as Record<string, unknown>).args;
  const pruned = pruneEmpty(rest) as ToolSetToolConfig;
  if (args !== undefined) pruned.args = args as ToolSetToolConfig['args'];
  if (Object.keys(pruned).length === 0) delete next[toolName];
  else next[toolName] = pruned;
  return next;
}

/**
 * Single-tool closed-vocabulary fields (enabled/name/description + per-arg
 * enum_remove/hide/rename/default/description rows). Exported for embedding.
 */
export function ToolSetOverrideFields({
  tool,
  entry,
  onEntry,
  readOnly = false,
  idPrefix,
}: {
  tool: ToolOverridesTool;
  entry: ToolSetToolConfig;
  onEntry: (next: ToolSetToolConfig) => void;
  readOnly?: boolean;
  idPrefix: string;
}) {
  const [newArg, setNewArg] = useState('');
  const [newEnum, setNewEnum] = useState('');
  const knownArgs = tool.parameters ?? [];
  const argCfg = entry.args ?? {};
  const extraArgs = Object.keys(argCfg).filter((arg) => !knownArgs.some((p) => p.name === arg));
  const argRows = [
    ...knownArgs.map((p) => ({ name: p.name })),
    ...extraArgs.map((name) => ({ name })),
  ];

  function updateArgs(args: Record<string, ToolSetArgConfig>) {
    onEntry(Object.keys(args).length === 0 ? { ...entry, args: undefined } : { ...entry, args });
  }

  function addEnumValue(arg: string) {
    const value = newEnum.trim();
    if (!value) return;
    const current = argCfg[arg]?.enum_remove ?? [];
    if (current.some((v) => String(v) === value)) return;
    updateArgs(patchArg(argCfg, arg, { enum_remove: [...current, value] }));
    setNewEnum('');
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }} aria-label={`Tool-set overrides for ${tool.name}`}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
        <label htmlFor={`${idPrefix}-enabled`} style={{ fontSize: 11, fontWeight: 600, color: 'var(--text-2)' }}>
          Enabled
        </label>
        <input
          id={`${idPrefix}-enabled`}
          type="checkbox"
          checked={entry.enabled !== false}
          disabled={readOnly}
          onChange={(e) => onEntry(patchToolCfg({ t: entry }, 't', { enabled: e.target.checked ? undefined : false }).t ?? {})}
        />
      </div>
      <div>
        <label htmlFor={`${idPrefix}-name`} style={{ fontSize: 11, fontWeight: 600, color: 'var(--text-2)' }}>
          Name override
        </label>
        <input
          id={`${idPrefix}-name`}
          value={entry.name ?? ''}
          placeholder={canonicalToolName(tool.name)}
          readOnly={readOnly}
          onChange={(e) => onEntry(patchToolCfg({ t: entry }, 't', { name: e.target.value }).t ?? {})}
          style={{ width: '100%', fontFamily: 'monospace', fontSize: 12 }}
        />
      </div>
      <div>
        <label htmlFor={`${idPrefix}-desc`} style={{ fontSize: 11, fontWeight: 600, color: 'var(--text-2)' }}>
          Description override
        </label>
        <textarea
          id={`${idPrefix}-desc`}
          value={entry.description ?? ''}
          placeholder={tool.description}
          readOnly={readOnly}
          rows={2}
          onChange={(e) => onEntry(patchToolCfg({ t: entry }, 't', { description: e.target.value }).t ?? {})}
          style={{ width: '100%', fontSize: 12 }}
        />
      </div>
      {argRows.length > 0 && (
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          <span style={{ fontSize: 11, fontWeight: 600, color: 'var(--text-2)' }}>Argument overrides</span>
          {argRows.map((arg) => {
            const cfg = argCfg[arg.name] ?? {};
            return (
              <div
                key={arg.name}
                style={{ border: '1px solid var(--border)', borderRadius: 6, padding: 8, display: 'flex', flexDirection: 'column', gap: 6 }}
              >
                <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                  <span className="font-mono" style={{ flex: 1, fontSize: 11, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }} title={arg.name}>
                    {arg.name}
                  </span>
                  <label style={{ fontSize: 10, color: 'var(--text-2)', display: 'flex', alignItems: 'center', gap: 4 }}>
                    hide
                    <input
                      type="checkbox"
                      checked={cfg.hide === true}
                      disabled={readOnly}
                      aria-label={`Hide argument ${arg.name} of ${tool.name}`}
                      onChange={(e) => updateArgs(patchArg(argCfg, arg.name, { hide: e.target.checked ? true : undefined }))}
                    />
                  </label>
                </div>
                <div style={{ display: 'flex', gap: 6 }}>
                  <input
                    aria-label={`Rename argument ${arg.name} of ${tool.name}`}
                    value={cfg.rename ?? ''}
                    placeholder="rename to"
                    readOnly={readOnly}
                    onChange={(e) => updateArgs(patchArg(argCfg, arg.name, { rename: e.target.value }))}
                    style={{ flex: 1, fontFamily: 'monospace', fontSize: 11 }}
                  />
                  <input
                    aria-label={`Default value for argument ${arg.name} of ${tool.name}`}
                    value={cfg.default === undefined ? '' : String(cfg.default)}
                    placeholder="pin default"
                    readOnly={readOnly}
                    onChange={(e) => {
                      const raw = e.target.value;
                      updateArgs(patchArg(argCfg, arg.name, { default: raw === '' ? undefined : raw }));
                    }}
                    style={{ flex: 1, fontSize: 11 }}
                  />
                </div>
                <input
                  aria-label={`Description for argument ${arg.name} of ${tool.name}`}
                  value={cfg.description ?? ''}
                  placeholder="argument description"
                  readOnly={readOnly}
                  onChange={(e) => updateArgs(patchArg(argCfg, arg.name, { description: e.target.value }))}
                  style={{ width: '100%', fontSize: 11 }}
                />
                {(cfg.enum_remove?.length ?? 0) > 0 && (
                  <div style={{ display: 'flex', flexWrap: 'wrap', gap: 4 }}>
                    {(cfg.enum_remove ?? []).map((v) => (
                      <span
                        key={String(v)}
                        style={{ fontSize: 10, fontFamily: 'monospace', border: '1px solid var(--border)', borderRadius: 999, padding: '1px 8px', display: 'inline-flex', alignItems: 'center', gap: 4 }}
                      >
                        {String(v)}
                        {!readOnly && (
                          <button
                            type="button"
                            aria-label={`Keep enum value ${String(v)} for ${arg.name}`}
                            onClick={() =>
                              updateArgs(
                                patchArg(argCfg, arg.name, {
                                  enum_remove: (cfg.enum_remove ?? []).filter((x) => x !== v),
                                }),
                              )
                            }
                            style={{ cursor: 'pointer', border: 'none', background: 'none', color: 'var(--text-3)', padding: 0 }}
                          >
                            ×
                          </button>
                        )}
                      </span>
                    ))}
                  </div>
                )}
                {!readOnly && (
                  <div style={{ display: 'flex', gap: 6 }}>
                    <input
                      aria-label={`Enum value to remove from ${arg.name} of ${tool.name}`}
                      value={newEnum}
                      placeholder="enum value to remove"
                      onChange={(e) => setNewEnum(e.target.value)}
                      onKeyDown={(e) => {
                        if (e.key === 'Enter') {
                          e.preventDefault();
                          addEnumValue(arg.name);
                        }
                      }}
                      style={{ flex: 1, fontFamily: 'monospace', fontSize: 11 }}
                    />
                    <button
                      type="button"
                      className="sg-btn sg-btn--outline sg-btn--sm"
                      disabled={!newEnum.trim()}
                      onClick={() => addEnumValue(arg.name)}
                    >
                      Remove value
                    </button>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}
      {!readOnly && (
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <input
            aria-label="New argument name"
            value={newArg}
            placeholder="add argument by name"
            onChange={(e) => setNewArg(e.target.value)}
            style={{ flex: '0 0 180px', fontFamily: 'monospace', fontSize: 12 }}
          />
          <button
            type="button"
            className="sg-btn sg-btn--outline sg-btn--sm"
            disabled={!newArg.trim() || argRows.some((r) => r.name === newArg.trim())}
            onClick={() => {
              const name = newArg.trim();
              if (!name) return;
              updateArgs(patchArg(argCfg, name, {}));
              setNewArg('');
            }}
          >
            Add argument
          </button>
        </div>
      )}
    </div>
  );
}

/**
 * Group-include grid + per-tool closed-vocabulary override rows for a tool
 * set. Group include = presence of `value.groups[group]` (the N2a allowlist
 * semantics); the group-level `enabled` flag is preserved, never written.
 */
export function ToolSetOverridesEditor({
  groups,
  value,
  onChange,
  readOnly = false,
}: ToolSetOverridesEditorProps) {
  const [open, setOpen] = useState<Record<string, boolean>>({});
  const groupsCfg = value.groups ?? {};

  function toggleGroup(groupId: string, include: boolean) {
    const next: Record<string, ToolSetGroupConfig> = { ...groupsCfg };
    if (include) next[groupId] = next[groupId] ?? {};
    else delete next[groupId];
    onChange({ ...value, groups: next });
  }

  function updateTool(groupId: string, toolName: string, entry: ToolSetToolConfig | undefined) {
    const groupCfg = groupsCfg[groupId] ?? {};
    const tools: Record<string, ToolSetToolConfig> = { ...(groupCfg.tools ?? {}) };
    // An entry that carries only args (no tool-level fields) must survive —
    // emptiness is judged on the whole entry, args included.
    if (entry === undefined || Object.keys(entry).length === 0) {
      delete tools[toolName];
    } else {
      tools[toolName] = entry;
    }
    onChange({
      ...value,
      groups: { ...groupsCfg, [groupId]: { ...groupCfg, tools } },
    });
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }} role="group" aria-label="Tool-set overrides">
      {groups.map((group) => {
        const included = groupsCfg[group.group] !== undefined;
        const groupCfg = groupsCfg[group.group] ?? {};
        const tools = groupCfg.tools ?? {};
        const overriddenCount = group.tools.filter((t) => {
          const key = canonicalToolName(t.name);
          return Object.keys(tools[key] ?? {}).length > 0;
        }).length;
        return (
          <section
            key={group.group}
            aria-label={`Tool-set group ${group.group}`}
            style={{
              borderRadius: 6,
              border: included ? '1px solid var(--accent)' : '1px solid var(--border)',
              background: included ? 'var(--accent-dim)' : 'var(--bg-3)',
              overflow: 'hidden',
            }}
          >
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: 10,
                padding: '8px 12px',
                borderBottom: '1px solid var(--border)',
                background: 'var(--bg-2)',
                fontSize: 12,
                fontWeight: 600,
                color: 'var(--text-0)',
              }}
            >
              <label style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                <input
                  type="checkbox"
                  checked={included}
                  disabled={readOnly}
                  aria-label={`Include group ${group.group}`}
                  onChange={(e) => toggleGroup(group.group, e.target.checked)}
                />
                {group.label ?? group.group}
              </label>
              <span style={{ fontWeight: 400, fontSize: 10, color: 'var(--text-3)', marginLeft: 'auto' }}>
                {included ? `${overriddenCount}/${group.tools.length} overridden` : `${group.tools.length} tools`}
              </span>
            </div>
            {included && (
              <div style={{ display: 'flex', flexDirection: 'column' }}>
                {group.tools.map((tool) => {
                  const toolKey = canonicalToolName(tool.name);
                  const expanded = open[`${group.group}/${toolKey}`] ?? false;
                  const entry = tools[toolKey] ?? {};
                  const edited = Object.keys(entry).length > 0;
                  return (
                    <div key={tool.name} style={{ borderBottom: '1px solid var(--border)' }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '6px 12px', background: 'var(--bg-2)' }}>
                        <label style={{ display: 'flex', alignItems: 'center', gap: 4, fontSize: 10, color: 'var(--text-2)' }}>
                          <input
                            type="checkbox"
                            checked={entry.enabled !== false}
                            disabled={readOnly}
                            aria-label={`Enable tool ${tool.name}`}
                            onChange={(e) =>
                              updateTool(group.group, toolKey, {
                                ...entry,
                                enabled: e.target.checked ? undefined : false,
                              })
                            }
                          />
                          on
                        </label>
                        <span
                          title={tool.name}
                          className="font-mono"
                          style={{ flex: 1, fontSize: 11, color: entry.enabled === false ? 'var(--text-3)' : 'var(--text-0)', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}
                        >
                          {tool.name}
                          {edited && (
                            <span
                              title="Has overrides"
                              style={{ marginLeft: 6, fontSize: 9, padding: '1px 5px', borderRadius: 8, background: 'var(--accent)', color: 'var(--bg-1)', verticalAlign: 'middle' }}
                            >
                              edited
                            </span>
                          )}
                        </span>
                        <button
                          type="button"
                          className="sg-btn sg-btn--outline sg-btn--sm"
                          aria-expanded={expanded}
                          onClick={() => setOpen((cur) => ({ ...cur, [`${group.group}/${toolKey}`]: !expanded }))}
                        >
                          {expanded ? 'Hide' : 'Overrides'}
                        </button>
                      </div>
                      {expanded && (
                        <div style={{ padding: '8px 12px 12px' }}>
                          <ToolSetOverrideFields
                            idPrefix={`tse-${group.group}-${toolKey}`}
                            tool={tool}
                            entry={entry}
                            onEntry={(next) => updateTool(group.group, toolKey, next)}
                            readOnly={readOnly}
                          />
                        </div>
                      )}
                    </div>
                  );
                })}
              </div>
            )}
          </section>
        );
      })}
    </div>
  );
}
