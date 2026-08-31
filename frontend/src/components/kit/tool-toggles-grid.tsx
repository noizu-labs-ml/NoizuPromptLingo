'use client';

export interface ToolToggleEntry {
  name: string;
  enabled: boolean;
  hidden: boolean;
}

export interface ToolToggleGroup {
  group: string;
  tools: ToolToggleEntry[];
}

interface ToolTogglesGridProps {
  groups: ToolToggleGroup[];
  /** Emits the full next state (pure controlled component). */
  onChange: (next: ToolToggleGroup[]) => void;
  readOnly?: boolean;
}

/**
 * Grid of grouped tool entries with per-tool enabled/hidden toggles and
 * group-level toggles that cascade to every child tool. Pure controlled
 * component — the host owns persistence.
 *
 * Semantics match the tobor.locker toolset model: `enabled` gates execution,
 * `hidden` gates discovery (visible vs hidden in list_tools).
 */
export default function ToolTogglesGrid({ groups, onChange, readOnly = false }: ToolTogglesGridProps) {
  function patchTool(groupName: string, toolName: string, patch: Partial<ToolToggleEntry>) {
    onChange(
      groups.map((g) =>
        g.group !== groupName
          ? g
          : { ...g, tools: g.tools.map((t) => (t.name === toolName ? { ...t, ...patch } : t)) },
      ),
    );
  }

  function cascade(group: ToolToggleGroup, patch: (t: ToolToggleEntry) => Partial<ToolToggleEntry>) {
    onChange(
      groups.map((g) =>
        g.group !== group.group
          ? g
          : { ...g, tools: g.tools.map((t) => ({ ...t, ...patch(t) })) },
      ),
    );
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }} role="group" aria-label="Tool toggles">
      {groups.map((group) => {
        const allEnabled = group.tools.length > 0 && group.tools.every((t) => t.enabled);
        const allHidden = group.tools.length > 0 && group.tools.every((t) => t.hidden);
        return (
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
            {/* Group header with cascading toggles */}
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: 12,
                padding: '8px 12px',
                borderBottom: '1px solid var(--border)',
                background: 'var(--bg-2)',
              }}
            >
              <span style={{ fontSize: 12, fontWeight: 600, flex: 1, color: 'var(--text-0)' }}>
                {group.group}
                <span style={{ fontWeight: 400, fontSize: 10, color: 'var(--text-3)', marginLeft: 6 }}>
                  {group.tools.filter((t) => t.enabled).length}/{group.tools.length} enabled
                </span>
              </span>
              <Toggle
                id={`ttg-${group.group}-enabled`}
                label="Enabled"
                checked={allEnabled}
                disabled={readOnly}
                onChange={(v) => cascade(group, () => ({ enabled: v }))}
              />
              <Toggle
                id={`ttg-${group.group}-hidden`}
                label="Hidden"
                checked={allHidden}
                disabled={readOnly}
                onChange={(v) => cascade(group, () => ({ hidden: v }))}
              />
            </div>

            {/* Tool rows */}
            <div
              style={{
                display: 'grid',
                gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))',
                gap: 6,
                padding: 10,
              }}
            >
              {group.tools.map((tool) => (
                <div
                  key={tool.name}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: 10,
                    padding: '6px 10px',
                    borderRadius: 4,
                    background: 'var(--bg-2)',
                    border: '1px solid var(--border)',
                    opacity: tool.enabled ? 1 : 0.6,
                  }}
                >
                  <span
                    title={tool.name}
                    style={{
                      flex: 1,
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: tool.enabled ? 'var(--text-0)' : 'var(--text-3)',
                      overflow: 'hidden',
                      textOverflow: 'ellipsis',
                      whiteSpace: 'nowrap',
                    }}
                  >
                    {tool.name}
                  </span>
                  <Toggle
                    id={`ttg-${group.group}-${tool.name}-enabled`}
                    label="On"
                    checked={tool.enabled}
                    disabled={readOnly}
                    onChange={(v) => patchTool(group.group, tool.name, { enabled: v })}
                  />
                  <Toggle
                    id={`ttg-${group.group}-${tool.name}-hidden`}
                    label="Hide"
                    checked={tool.hidden}
                    disabled={readOnly}
                    onChange={(v) => patchTool(group.group, tool.name, { hidden: v })}
                  />
                </div>
              ))}
            </div>
          </section>
        );
      })}
    </div>
  );
}

function Toggle({
  id,
  label,
  checked,
  disabled,
  onChange,
}: {
  id: string;
  label: string;
  checked: boolean;
  disabled?: boolean;
  onChange: (v: boolean) => void;
}) {
  return (
    <label
      htmlFor={id}
      style={{
        display: 'inline-flex',
        alignItems: 'center',
        gap: 4,
        fontSize: 10,
        color: 'var(--text-2)',
        cursor: disabled ? 'default' : 'pointer',
        userSelect: 'none',
      }}
    >
      <input
        id={id}
        type="checkbox"
        checked={checked}
        disabled={disabled}
        onChange={(e) => onChange(e.target.checked)}
        style={{ accentColor: 'var(--accent)', margin: 0 }}
      />
      {label}
    </label>
  );
}
