'use client';

import { useMemo, useState } from 'react';
import { toast } from 'sonner';
import {
  api,
  type McpCustomGroup,
  type McpCustomScope,
  type McpCustomScopeConfig,
  type McpCustomTool,
} from '@/lib/api';

interface McpIncludeEditorProps {
  catalog: McpCustomGroup[];
  scope: McpCustomScope;
  onSaved?: (scope: McpCustomScope) => void;
  readOnly?: boolean;
  save?: (config: McpCustomScopeConfig) => Promise<McpCustomScope>;
}

function included(config: McpCustomScopeConfig, groupId: string) {
  return !!config.groups[groupId] && config.groups[groupId].disabled !== true;
}

function toolEnabled(config: McpCustomScopeConfig, groupId: string, toolName: string) {
  const tools = config.groups[groupId]?.tools;
  return !tools || tools[toolName] === undefined || tools[toolName].disabled !== true;
}

// "Listed" = shown in the endpoint's tools/list. The per-scope `hidden` override
// beats the tool's compile-time default (catalog `tool.hidden`). Hidden tools
// stay in the catalog and callable via ToolCall — this only trims what agents
// see up front.
function toolListed(config: McpCustomScopeConfig, groupId: string, tool: McpCustomTool) {
  const override = config.groups[groupId]?.tools?.[tool.name]?.hidden;
  if (typeof override === 'boolean') return !override;
  return !tool.hidden;
}

function toolHiddenOverride(config: McpCustomScopeConfig, groupId: string, toolName: string) {
  return typeof config.groups[groupId]?.tools?.[toolName]?.hidden === 'boolean';
}

export default function McpIncludeEditor({
  catalog,
  scope,
  onSaved,
  readOnly = false,
  save,
}: McpIncludeEditorProps) {
  const [config, setConfig] = useState<McpCustomScopeConfig>(() => ({
    groups: { ...(scope.config?.groups ?? {}) },
  }));
  const [saving, setSaving] = useState(false);
  const [expanded, setExpanded] = useState<Record<string, boolean>>({});

  const selectedCount = useMemo(
    () => catalog.filter((g) => included(config, g.id)).length,
    [catalog, config],
  );

  function toggle(groupId: string, value: boolean) {
    setConfig((current) => {
      const groups = { ...current.groups };
      if (value) {
        const prev = groups[groupId] ?? { tools: {} };
        const next = { ...prev };
        delete next.disabled;
        groups[groupId] = next;
      } else {
        delete groups[groupId];
      }
      return { groups };
    });
  }

  // Per-tool toggles always SET `disabled` (never delete entries) — the backend
  // reads the flag from mcp/custom.ex, so absent vs. explicitly-false must stay
  // indistinguishable to it. Group membership is left untouched.
  function toggleTool(groupId: string, toolName: string, value: boolean) {
    setConfig((current) => {
      // If the group entry was removed (group unchecked), re-create it as
      // disabled so editing tools on an excluded group never re-includes it.
      const prevGroup = current.groups[groupId] ?? { tools: {}, disabled: true };
      const prevTools = prevGroup.tools ?? {};
      const tools = { ...prevTools, [toolName]: { ...(prevTools[toolName] ?? {}), disabled: !value } };
      return { groups: { ...current.groups, [groupId]: { ...prevGroup, tools } } };
    });
  }

  // Visibility toggles write `hidden` as an explicit override; once the value
  // matches the compile-time default the key is dropped again, so future
  // default flips (compile-time changes) flow through untouched scopes.
  function toggleToolListed(groupId: string, tool: McpCustomTool, value: boolean) {
    setConfig((current) => {
      const prevGroup = current.groups[groupId] ?? { tools: {}, disabled: true };
      const prevTools = prevGroup.tools ?? {};
      const prevTool = prevTools[tool.name] ?? {};
      const nextTool = { ...prevTool };
      if (value === !tool.hidden) {
        delete nextTool.hidden;
      } else {
        nextTool.hidden = !value;
      }
      const tools = { ...prevTools };
      if (Object.keys(nextTool).length === 0) {
        delete tools[tool.name];
      } else {
        tools[tool.name] = nextTool;
      }
      return { groups: { ...current.groups, [groupId]: { ...prevGroup, tools } } };
    });
  }

  async function persist() {
    if (readOnly) return;
    setSaving(true);
    try {
      const updated = save
        ? await save(config)
        : (await api.updateDefaultMcpEndpoint(config)).scope;
      onSaved?.(updated);
      toast.success('Included services updated');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to save included services');
    } finally {
      setSaving(false);
    }
  }

  return (
    <div>
      <div style={{
        display: 'flex',
        alignItems: 'baseline',
        justifyContent: 'space-between',
        gap: 12,
        marginBottom: 10,
        flexWrap: 'wrap',
      }}>
        <div>
          <div style={{ fontSize: 12, fontWeight: 600, color: 'var(--text-1)' }}>
            Included services
          </div>
          <div style={{ fontSize: 11, color: 'var(--text-3)' }}>
            {readOnly
              ? 'Read-only template. Copy it to your endpoints to edit included services.'
              : 'These ride on this custom endpoint — one URL, not extra servers. Expand a service to toggle tools: check = included in the catalog; "listed" = shown in tools/list (hidden tools stay callable via ToolCall).'}
          </div>
        </div>
        {!readOnly ? (
          <button
            type="button"
            className="sg-btn sg-btn--black sg-btn--sm"
            onClick={persist}
            disabled={saving}
          >
            {saving ? 'Saving…' : `Save (${selectedCount})`}
          </button>
        ) : null}
      </div>

      <div style={{
        display: 'grid',
        gridTemplateColumns: 'repeat(auto-fill, minmax(220px, 1fr))',
        gap: 6,
      }}>
        {catalog.map((group) => {
          const on = included(config, group.id);
          const open = !!expanded[group.id];
          const tools = group.tools ?? [];
          return (
            <div
              key={group.id}
              style={{
                padding: '6px 10px',
                borderRadius: 6,
                background: on ? 'var(--accent-dim)' : 'var(--bg-3)',
                border: `1px solid ${on ? 'var(--accent)' : 'var(--border)'}`,
                fontSize: 12,
              }}
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                <label
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: 8,
                    flex: 1,
                    minWidth: 0,
                    cursor: readOnly ? 'default' : 'pointer',
                  }}
                >
                  <input
                    type="checkbox"
                    checked={on}
                    onChange={(e) => toggle(group.id, e.target.checked)}
                    disabled={readOnly}
                    style={{ accentColor: 'var(--accent)' }}
                  />
                  <div style={{ minWidth: 0 }}>
                    <div style={{ fontWeight: 500, color: on ? 'var(--text-0)' : 'var(--text-3)' }}>
                      {group.label}
                      {group.required ? (
                        <span style={{ fontSize: 9, color: 'var(--text-3)', marginLeft: 4 }}>
                          recommended
                        </span>
                      ) : null}
                    </div>
                    <div style={{ fontSize: 10, color: 'var(--text-3)' }}>{group.desc}</div>
                  </div>
                </label>
                <span
                  style={{
                    fontSize: 9,
                    color: 'var(--text-3)',
                    background: 'var(--bg-2)',
                    border: '1px solid var(--border)',
                    borderRadius: 8,
                    padding: '1px 6px',
                    whiteSpace: 'nowrap',
                  }}
                >
                  {tools.length} tools
                </span>
                {tools.length > 0 ? (
                  <button
                    type="button"
                    aria-expanded={open}
                    aria-label={`Toggle tools for ${group.label}`}
                    onClick={() => setExpanded((prev) => ({ ...prev, [group.id]: !prev[group.id] }))}
                    style={{
                      border: 0,
                      background: 'transparent',
                      color: 'var(--text-2)',
                      cursor: 'pointer',
                      fontSize: 10,
                      padding: '2px 4px',
                      transform: open ? 'rotate(180deg)' : 'none',
                    }}
                  >
                    ▾
                  </button>
                ) : null}
              </div>

              {open && tools.length > 0 ? (
                <div style={{
                  marginTop: 8,
                  paddingTop: 8,
                  borderTop: '1px solid var(--border)',
                  display: 'flex',
                  flexDirection: 'column',
                  gap: 4,
                }}>
                  {tools.map((tool) => {
                    const toolOn = toolEnabled(config, group.id, tool.name);
                    const listed = toolListed(config, group.id, tool);
                    const custom = toolHiddenOverride(config, group.id, tool.name);
                    return (
                      <div
                        key={tool.name}
                        title={
                          `${tool.description}\n\n` +
                          `Included: in the endpoint's tool catalog (callable via ToolCall).\n` +
                          `Listed: shown in tools/list so agents see it up front. ${tool.hidden ? 'Hidden by default.' : 'Public by default.'}`
                        }
                        style={{
                          display: 'flex',
                          alignItems: 'center',
                          gap: 6,
                          fontSize: 11,
                          color: on && toolOn ? 'var(--text-1)' : 'var(--text-3)',
                        }}
                      >
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: 6,
                            flex: 1,
                            minWidth: 0,
                            cursor: readOnly ? 'default' : 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={toolOn}
                            onChange={(e) => toggleTool(group.id, tool.name, e.target.checked)}
                            disabled={readOnly}
                            style={{ accentColor: 'var(--accent)' }}
                          />
                          <span className="font-mono" style={{ wordBreak: 'break-all' }}>{tool.name}</span>
                        </label>
                        <span
                          style={{
                            width: 5,
                            height: 5,
                            borderRadius: '50%',
                            background: custom ? 'var(--accent)' : 'transparent',
                            flexShrink: 0,
                          }}
                          title={custom ? 'Visibility overridden for this endpoint' : undefined}
                        />
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: 4,
                            fontSize: 10,
                            flexShrink: 0,
                            cursor: readOnly ? 'default' : 'pointer',
                            color: listed ? 'var(--text-2)' : 'var(--text-3)',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={listed}
                            onChange={(e) => toggleToolListed(group.id, tool, e.target.checked)}
                            disabled={readOnly || !toolOn}
                            style={{ accentColor: 'var(--accent)' }}
                          />
                          listed
                        </label>
                      </div>
                    );
                  })}
                </div>
              ) : null}
            </div>
          );
        })}
      </div>
    </div>
  );
}
