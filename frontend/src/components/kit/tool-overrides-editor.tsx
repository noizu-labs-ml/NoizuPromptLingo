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
