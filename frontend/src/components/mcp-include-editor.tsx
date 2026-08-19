'use client';

import { useMemo, useState } from 'react';
import { toast } from 'sonner';
import {
  api,
  type McpCustomGroup,
  type McpCustomScope,
  type McpCustomScopeConfig,
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
              : 'These ride on this custom endpoint — one URL, not extra servers.'}
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
          return (
            <label
              key={group.id}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: 8,
                padding: '6px 10px',
                borderRadius: 6,
                background: on ? 'var(--accent-dim)' : 'var(--bg-3)',
                border: `1px solid ${on ? 'var(--accent)' : 'var(--border)'}`,
                cursor: readOnly ? 'default' : 'pointer',
                fontSize: 12,
              }}
            >
              <input
                type="checkbox"
                checked={on}
                onChange={(e) => toggle(group.id, e.target.checked)}
                disabled={readOnly}
                style={{ accentColor: 'var(--accent)' }}
              />
              <div>
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
          );
        })}
      </div>
    </div>
  );
}
