'use client';

import type { Memory } from '@/lib/api';
import { MoodMeters, NeurotransmitterMeters } from './memory-meters';

function Facet({ label, body }: { label: string; body?: string | null }) {
  if (!body) return null;
  return (
    <div className="sg-field" style={{ marginBottom: 8 }}>
      <label style={{ textTransform: 'uppercase', letterSpacing: '0.04em' }}>{label}</label>
      <p style={{ margin: 0, whiteSpace: 'pre-wrap', fontSize: '0.85rem' }}>{body}</p>
    </div>
  );
}

// A read-only card showing all four facets of a memory plus its emotional and
// neurochemical state. `score` (resonance) is rendered as a chip when present,
// e.g. for recall results. Clicking the card surfaces associations.
export function MemoryCard({
  memory,
  score,
  onSelect,
  selected,
}: {
  memory: Memory;
  score?: number | null;
  onSelect?: (m: Memory) => void;
  selected?: boolean;
}) {
  return (
    <div
      className="project-card"
      onClick={onSelect ? () => onSelect(memory) : undefined}
      style={{
        cursor: onSelect ? 'pointer' : 'default',
        outline: selected ? '2px solid var(--blue, #1d4e5f)' : undefined,
      }}
    >
      <div className="project-card__header">
        <div className="project-card__org" style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
          {memory.domain && <span>{memory.domain}</span>}
          {memory.topic && <span>· {memory.topic}</span>}
          {memory.content_type && <span>· {memory.content_type}</span>}
        </div>
        {score != null && (
          <span className="project-card__status" title="Resonance / match score">
            {score.toFixed(3)}
          </span>
        )}
      </div>

      <div className="project-card__body">
        <Facet label="Content" body={memory.content} />
        <Facet label="Context" body={memory.context} />
        <Facet label="Reflection" body={memory.reflection} />
        <Facet label="Tangent" body={memory.tangent} />

        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))',
            gap: 16,
            margin: '12px 0',
          }}
        >
          <div>
            <div className="sg-field__hint" style={{ marginBottom: 4 }}>
              Mood (VAD)
            </div>
            <MoodMeters
              valence={memory.valence}
              arousal={memory.arousal}
              dominance={memory.dominance}
            />
          </div>
          <div>
            <div className="sg-field__hint" style={{ marginBottom: 4 }}>
              Neurotransmitters
            </div>
            <NeurotransmitterMeters
              cortisol={memory.cortisol}
              dopamine={memory.dopamine}
              oxytocin={memory.oxytocin}
              serotonin={memory.serotonin}
            />
          </div>
        </div>

        <div className="project-card__meta" style={{ gap: 12, flexWrap: 'wrap' }}>
          <span title="Salience">salience {memory.salience?.toFixed(2)}</span>
          <span title="Decay weight">decay {memory.decay_weight?.toFixed(2)}</span>
          <span title="Times recalled">recalled {memory.recall_count ?? 0}×</span>
          {memory.occurred_at && (
            <span className="project-card__time">
              {new Date(memory.occurred_at).toLocaleString()}
            </span>
          )}
        </div>
      </div>
    </div>
  );
}
