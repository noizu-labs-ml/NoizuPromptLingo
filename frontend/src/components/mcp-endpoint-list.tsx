'use client';

import type { McpCustomScope } from '@/lib/api';
import { parseMediaRef } from '@/lib/mcp-setup';

/**
 * Visual endpoint picker shared by the MCP client-setup page and the endpoint
 * manager (it replaces the old native <select>): 48px display thumb —
 * config.display image → emoji on its color backdrop → initial letter — plus
 * name, the /custom/<slug>/mcp gateway line, and the default badge. The
 * yours / organization / templates groupings from the select are preserved.
 */
export interface McpEndpointListProps {
  templates: McpCustomScope[];
  endpoints: McpCustomScope[];
  selectedId?: string | null;
  onSelect: (scope: McpCustomScope) => void;
}

/** Display thumb per the alacarte precedence: image → emoji on color → initial. */
export function EndpointThumb({ scope, size = 48 }: { scope: McpCustomScope; size?: number }) {
  const display = scope.config?.display;
  const media = parseMediaRef(display?.image);
  if (media.thumb) {
    return (
      <img
        src={media.thumb}
        alt=""
        width={size}
        height={size}
        style={{
          borderRadius: 8,
          objectFit: 'cover',
          border: '1px solid var(--border)',
          flexShrink: 0,
        }}
      />
    );
  }
  const emoji = display?.emoji;
  const background = display?.color || 'var(--bg-3, #fafafa)';
  const glyph = emoji || (scope.name?.trim()?.[0] ?? '?').toUpperCase();
  return (
    <div
      aria-hidden
      style={{
        width: size,
        height: size,
        borderRadius: 8,
        background,
        color: display?.color ? '#fff' : 'var(--text-2)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        fontSize: emoji ? Math.round(size * 0.5) : Math.round(size * 0.4),
        flexShrink: 0,
      }}
    >
      {glyph}
    </div>
  );
}

export default function McpEndpointList({
  templates,
  endpoints,
  selectedId,
  onSelect,
}: McpEndpointListProps) {
  const groups: { label: string; rows: McpCustomScope[] }[] = [
    { label: 'Your endpoints', rows: endpoints.filter((s) => s.owner_kind !== 'organization') },
    { label: 'Organization', rows: endpoints.filter((s) => s.owner_kind === 'organization') },
    { label: 'Standard templates', rows: templates },
  ];

  return (
    <div style={{ display: 'grid', gap: 14, marginBottom: 12 }}>
      {groups
        .filter((group) => group.rows.length > 0)
        .map((group) => (
          <div key={group.label}>
            <div
              style={{
                fontSize: 11,
                fontWeight: 700,
                textTransform: 'uppercase',
                letterSpacing: 0.5,
                color: 'var(--text-3)',
                marginBottom: 6,
              }}
            >
              {group.label}
            </div>
            <div style={{ display: 'grid', gap: 6 }}>
              {group.rows.map((scope) => {
                const isCurrent = scope.id === selectedId;
                return (
                  <button
                    key={scope.id}
                    type="button"
                    aria-pressed={isCurrent}
                    onClick={() => onSelect(scope)}
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      gap: 12,
                      width: '100%',
                      textAlign: 'left',
                      padding: '8px 10px',
                      borderRadius: 10,
                      border: `1px solid ${isCurrent ? 'var(--accent)' : 'var(--border)'}`,
                      background: isCurrent ? 'var(--accent-dim, var(--bg-3, #fafafa))' : 'transparent',
                      cursor: 'pointer',
                      color: 'inherit',
                      font: 'inherit',
                    }}
                  >
                    <EndpointThumb scope={scope} />
                    <span style={{ minWidth: 0, flex: 1 }}>
                      <span
                        style={{
                          display: 'flex',
                          alignItems: 'center',
                          gap: 8,
                          minWidth: 0,
                        }}
                      >
                        <span
                          style={{
                            fontWeight: 600,
                            overflow: 'hidden',
                            textOverflow: 'ellipsis',
                            whiteSpace: 'nowrap',
                          }}
                        >
                          {scope.name}
                        </span>
                        {scope.is_default ? <span className="dash-badge">default</span> : null}
                        {group.label === 'Standard templates' && scope.slug === 'tobor' ? (
                          <span className="dash-badge">standard</span>
                        ) : null}
                      </span>
                      <span
                        className="font-mono"
                        style={{
                          display: 'block',
                          fontSize: 12,
                          color: 'var(--text-3)',
                          overflow: 'hidden',
                          textOverflow: 'ellipsis',
                          whiteSpace: 'nowrap',
                        }}
                      >
                        /custom/{scope.slug}/mcp
                      </span>
                    </span>
                  </button>
                );
              })}
            </div>
          </div>
        ))}
    </div>
  );
}
