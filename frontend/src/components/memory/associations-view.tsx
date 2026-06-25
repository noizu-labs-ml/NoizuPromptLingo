'use client';

import { useEffect, useState } from 'react';
import { toast } from 'sonner';
import { api, type Memory, type MemoryEdge } from '@/lib/api';

// A simple radial graph: the focused memory in the center, each neighbour on a
// ring around it, edges drawn as lines whose thickness reflects the weight.
function EdgeGraph({ focusId, edges }: { focusId: string; edges: MemoryEdge[] }) {
  const size = 320;
  const cx = size / 2;
  const cy = size / 2;
  const r = 120;

  // Collect the distinct neighbour ids (the non-focus end of each edge).
  const neighbours = Array.from(
    new Set(
      edges.map((e) => (e.source_memory_id === focusId ? e.target_memory_id : e.source_memory_id)),
    ),
  );
  const pos = new Map<string, { x: number; y: number }>();
  neighbours.forEach((id, i) => {
    const angle = (i / Math.max(1, neighbours.length)) * Math.PI * 2 - Math.PI / 2;
    pos.set(id, { x: cx + r * Math.cos(angle), y: cy + r * Math.sin(angle) });
  });

  const short = (id: string) => id.slice(0, 6);

  return (
    <svg width="100%" viewBox={`0 0 ${size} ${size}`} role="img" aria-label="Association graph">
      {edges.map((e) => {
        const otherId = e.source_memory_id === focusId ? e.target_memory_id : e.source_memory_id;
        const p = pos.get(otherId);
        if (!p) return null;
        return (
          <line
            key={e.id}
            x1={cx}
            y1={cy}
            x2={p.x}
            y2={p.y}
            stroke="var(--border)"
            strokeWidth={1 + Math.max(0, Math.min(1, e.weight)) * 4}
          />
        );
      })}
      {neighbours.map((id) => {
        const p = pos.get(id)!;
        return (
          <g key={id}>
            <circle cx={p.x} cy={p.y} r={16} fill="var(--surface)" stroke="var(--blue, #1d4e5f)" />
            <text x={p.x} y={p.y + 4} textAnchor="middle" fontSize="9" fill="var(--text-muted)">
              {short(id)}
            </text>
          </g>
        );
      })}
      <circle cx={cx} cy={cy} r={20} fill="var(--blue, #1d4e5f)" />
      <text x={cx} y={cy + 4} textAnchor="middle" fontSize="9" fill="var(--surface)">
        {short(focusId)}
      </text>
    </svg>
  );
}

export function AssociationsView({
  orgId,
  agentSlug,
  memory,
  onClose,
}: {
  orgId: string;
  agentSlug: string;
  memory: Memory;
  onClose: () => void;
}) {
  const [edges, setEdges] = useState<MemoryEdge[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    api
      .getMemoryAssociations(orgId, agentSlug, memory.id)
      .then((res) => {
        if (!cancelled) setEdges(res.edges ?? []);
      })
      .catch((err) => {
        if (!cancelled) toast.error(err instanceof Error ? err.message : 'Failed to load associations');
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, [orgId, memory.id, agentSlug]);

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-card modal-card--lg" onClick={(e) => e.stopPropagation()}>
        <h2 className="modal-title">Associations</h2>
        <p className="sg-page-intro" style={{ marginTop: 0 }}>
          {memory.summary || memory.content.slice(0, 120)}
        </p>

        {loading ? (
          <p className="sg-page-intro">Loading…</p>
        ) : edges.length === 0 ? (
          <p className="sg-page-intro">No associations for this memory.</p>
        ) : (
          <>
            <EdgeGraph focusId={memory.id} edges={edges} />
            <ul className="asset-outputs">
              {edges.map((e) => {
                const outgoing = e.source_memory_id === memory.id;
                const otherId = outgoing ? e.target_memory_id : e.source_memory_id;
                return (
                  <li key={e.id} className="asset-outputs__row">
                    <div className="asset-outputs__main">
                      <span className="project-card__status">{e.edge_type}</span>
                      <span className="font-mono sg-field__hint">
                        {outgoing ? '→' : '←'} {otherId.slice(0, 8)}
                      </span>
                      <span title="Edge weight">weight {e.weight?.toFixed(2)}</span>
                    </div>
                    {e.reason && <pre className="asset-outputs__content">{e.reason}</pre>}
                  </li>
                );
              })}
            </ul>
          </>
        )}

        <div className="modal-actions">
          <button type="button" className="sg-btn sg-btn--outline" onClick={onClose}>
            Close
          </button>
        </div>
      </div>
    </div>
  );
}
