'use client';

import type { EffectiveToolState, ToolSection } from '@/types/tool-state';

interface ToolTogglesGridProps {
  sections: ToolSection[];
  /** Emits the full next state (pure controlled component). */
  onChange: (next: ToolSection[]) => void;
  readOnly?: boolean;
}

/**
 * Grid of grouped tool entries with per-tool enabled/visible toggles and
 * group-level toggles that cascade to every child tool. Pure controlled
 * component — the host owns persistence. Binds the shared F4 tool-state
 * contract (`ToolSection` / `EffectiveToolState` from `@/types/tool-state`),
 * which mirrors F2 EffectiveToolset semantics: `enabled` gates execution,
 * `visible` gates discovery (listing). Toggles only touch those two fields —
 * override/temporal fields pass through untouched.
 */
export default function ToolTogglesGrid({ sections, onChange, readOnly = false }: ToolTogglesGridProps) {
  function patchTool(sectionName: string, toolId: string, patch: Partial<EffectiveToolState>) {
    onChange(
      sections.map((s) =>
        s.name !== sectionName
          ? s
          : {
              ...s,
              tools: s.tools.map((e) =>
                e.tool.id === toolId ? { ...e, state: { ...e.state, ...patch } } : e,
              ),
            },
      ),
    );
  }

  function cascade(section: ToolSection, patch: (e: ToolSection['tools'][number]) => Partial<EffectiveToolState>) {
    onChange(
      sections.map((s) =>
        s.name !== section.name
          ? s
          : { ...s, tools: s.tools.map((e) => ({ ...e, state: { ...e.state, ...patch(e) } })) },
      ),
    );
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }} role="group" aria-label="Tool toggles">
      {sections.map((section) => {
        const allEnabled = section.tools.length > 0 && section.tools.every((e) => e.state.enabled);
        const allVisible = section.tools.length > 0 && section.tools.every((e) => e.state.visible);
        return (
          <section
            key={section.name}
            aria-label={`Tool group ${section.label ?? section.name}`}
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
                {section.label ?? section.name}
                <span style={{ fontWeight: 400, fontSize: 10, color: 'var(--text-3)', marginLeft: 6 }}>
                  {section.tools.filter((e) => e.state.enabled).length}/{section.tools.length} enabled
                </span>
              </span>
              <Toggle
                id={`ttg-${section.name}-enabled`}
                label="Enabled"
                checked={allEnabled}
                disabled={readOnly}
                onChange={(v) => cascade(section, () => ({ enabled: v }))}
              />
              <Toggle
                id={`ttg-${section.name}-visible`}
                label="Visible"
                checked={allVisible}
                disabled={readOnly}
                onChange={(v) => cascade(section, () => ({ visible: v }))}
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
              {section.tools.map((entry) => {
                const toolLabel = entry.tool.label ?? entry.tool.id;
                return (
                  <div
                    key={entry.tool.id}
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      gap: 10,
                      padding: '6px 10px',
                      borderRadius: 4,
                      background: 'var(--bg-2)',
                      border: '1px solid var(--border)',
                      opacity: entry.state.enabled ? 1 : 0.6,
                    }}
                  >
                    <span
                      title={entry.tool.id}
                      style={{
                        flex: 1,
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: entry.state.enabled ? 'var(--text-0)' : 'var(--text-3)',
                        overflow: 'hidden',
                        textOverflow: 'ellipsis',
                        whiteSpace: 'nowrap',
                      }}
                    >
                      {toolLabel}
                    </span>
                    <Toggle
                      id={`ttg-${section.name}-${entry.tool.id}-enabled`}
                      label="On"
                      checked={entry.state.enabled}
                      disabled={readOnly}
                      onChange={(v) => patchTool(section.name, entry.tool.id, { enabled: v })}
                    />
                    <Toggle
                      id={`ttg-${section.name}-${entry.tool.id}-visible`}
                      label="Show"
                      checked={entry.state.visible}
                      disabled={readOnly}
                      onChange={(v) => patchTool(section.name, entry.tool.id, { visible: v })}
                    />
                  </div>
                );
              })}
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
