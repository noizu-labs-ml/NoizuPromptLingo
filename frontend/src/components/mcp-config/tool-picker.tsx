'use client';

import { useMemo, useState } from 'react';
import type { McpCustomGroup } from '@/lib/api';

/**
 * PRD-020 FR-7 — standalone manual tool picker (US-112). Wizard-decoupled and
 * embeddable by the endpoint editor and the admin page: lists catalog tools
 * with name, group label, and description; text search + group filter;
 * confirm returns the selected canonical tool names. When reached as the LLM
 * fallback, `fallbackNotice` explains why (D2/D3) — all wizard state above is
 * preserved by the host.
 */
export interface ToolPickerProps {
  /** Catalog groups from api.mcpCatalog(). */
  catalog: McpCustomGroup[];
  /** Initially checked tools, keyed by canonical tool name. */
  selected: Record<string, boolean>;
  /** Called with the selected canonical names on confirm. */
  onConfirm: (names: string[]) => void;
  onCancel?: () => void;
  title?: string;
  /** Shown when routed here via llm_unavailable. */
  fallbackNotice?: string | null;
}

export default function ToolPicker({
  catalog,
  selected,
  onConfirm,
  onCancel,
  title = 'Pick tools',
  fallbackNotice,
}: ToolPickerProps) {
  const [query, setQuery] = useState('');
  const [groupFilter, setGroupFilter] = useState('all');
  const [checked, setChecked] = useState<Record<string, boolean>>({ ...selected });

  const groups = useMemo(
    () =>
      catalog
        .map((group) => ({
          ...group,
          tools: group.tools.filter((tool) => {
            const q = query.trim().toLowerCase();
            const matchesQuery =
              !q ||
              tool.name.toLowerCase().includes(q) ||
              (tool.description ?? '').toLowerCase().includes(q);
            const matchesGroup = groupFilter === 'all' || group.id === groupFilter;
            return matchesQuery && matchesGroup;
          }),
        }))
        .filter((group) => group.tools.length > 0),
    [catalog, query, groupFilter],
  );

  const selectedNames = useMemo(
    () => Object.entries(checked).filter(([, on]) => on).map(([name]) => name),
    [checked],
  );

  function toggle(name: string, on: boolean) {
    setChecked((prev) => ({ ...prev, [name]: on }));
  }

  return (
    <div className="tool-picker" data-testid="tool-picker">
      <h4 style={{ margin: '0 0 8px', fontSize: 14 }}>{title}</h4>

      {fallbackNotice ? (
        <p
          role="status"
          className="sg-page-intro"
          style={{ marginTop: 0, color: 'var(--text-3)' }}
        >
          {fallbackNotice}
        </p>
      ) : null}

      <div style={{ display: 'flex', gap: 8, marginBottom: 10, flexWrap: 'wrap' }}>
        <input
          className="gh-add-form__input"
          style={{ flex: '1 1 180px' }}
          type="search"
          placeholder="Search tools…"
          aria-label="Search tools"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
        />
        <select
          aria-label="Filter by group"
          value={groupFilter}
          onChange={(e) => setGroupFilter(e.target.value)}
          style={{ maxWidth: 220 }}
        >
          <option value="all">All groups</option>
          {catalog.map((group) => (
            <option key={group.id} value={group.id}>
              {group.label || group.id}
            </option>
          ))}
        </select>
      </div>

      <div
        style={{ maxHeight: 320, overflowY: 'auto', border: '1px solid var(--border-1, #ddd)', borderRadius: 8, padding: 8 }}
      >
        {groups.length === 0 ? (
          <p className="sg-page-intro" style={{ margin: 0 }}>
            No tools match the current filter.
          </p>
        ) : null}

        {groups.map((group) => (
          <div key={group.id} style={{ marginBottom: 12 }}>
            <div style={{ fontSize: 11, color: 'var(--text-3)', marginBottom: 4 }}>
              {group.label || group.id}
            </div>
            <ul style={{ listStyle: 'none', margin: 0, padding: 0 }}>
              {group.tools.map((tool) => (
                <li key={tool.name} style={{ padding: '4px 0' }}>
                  <label style={{ display: 'flex', gap: 8, alignItems: 'flex-start' }}>
                    <input
                      type="checkbox"
                      checked={!!checked[tool.name]}
                      onChange={(e) => toggle(tool.name, e.target.checked)}
                    />
                    <span>
                      <span className="font-mono" style={{ fontSize: 12 }}>
                        {tool.name}
                      </span>
                      {tool.description ? (
                        <span
                          style={{ display: 'block', fontSize: 11, color: 'var(--text-3)' }}
                        >
                          {tool.description}
                        </span>
                      ) : null}
                    </span>
                  </label>
                </li>
              ))}
            </ul>
          </div>
        ))}
      </div>

      <div style={{ display: 'flex', gap: 8, marginTop: 10, flexWrap: 'wrap' }}>
        <button
          type="button"
          className="sg-btn sg-btn--black sg-btn--sm"
          onClick={() => onConfirm(selectedNames)}
        >
          Add {selectedNames.length > 0 ? `${selectedNames.length} ` : ''}tools
        </button>
        {onCancel ? (
          <button type="button" className="sg-btn sg-btn--outline sg-btn--sm" onClick={onCancel}>
            Cancel
          </button>
        ) : null}
      </div>
    </div>
  );
}
