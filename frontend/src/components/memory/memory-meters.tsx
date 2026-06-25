'use client';

// Small, dependency-free meters for visualizing a memory's emotional and
// neurochemical state. Everything is plain divs + inline SVG styled with the
// styleguide CSS variables so it tracks the active theme.

// A signed bar centered on zero, for VAD axes which run roughly -1..1. Positive
// fills to the right of center, negative to the left.
export function SignedBar({ label, value }: { label: string; value: number }) {
  const v = Math.max(-1, Math.min(1, value ?? 0));
  const pct = Math.abs(v) * 50; // half-width per side
  const positive = v >= 0;
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 8, fontSize: '0.72rem' }}>
      <span style={{ width: 64, color: 'var(--text-muted)' }}>{label}</span>
      <div
        style={{
          position: 'relative',
          flex: 1,
          height: 8,
          borderRadius: 'var(--radius, 2px)',
          background: 'color-mix(in srgb, var(--text-muted) 18%, transparent)',
        }}
      >
        {/* center line */}
        <div
          style={{
            position: 'absolute',
            left: '50%',
            top: -1,
            bottom: -1,
            width: 1,
            background: 'var(--border)',
          }}
        />
        <div
          style={{
            position: 'absolute',
            top: 0,
            bottom: 0,
            [positive ? 'left' : 'right']: '50%',
            width: `${pct}%`,
            background: positive ? 'var(--green, #15803d)' : 'var(--red, #9a2c3f)',
            borderRadius: 'var(--radius, 2px)',
          }}
        />
      </div>
      <span style={{ width: 40, textAlign: 'right', fontVariantNumeric: 'tabular-nums' }}>
        {v.toFixed(2)}
      </span>
    </div>
  );
}

// An unsigned 0..1 bar for neurotransmitter levels.
export function LevelBar({ label, value, color }: { label: string; value: number; color: string }) {
  const v = Math.max(0, Math.min(1, value ?? 0));
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 8, fontSize: '0.72rem' }}>
      <span style={{ width: 64, color: 'var(--text-muted)' }}>{label}</span>
      <div
        style={{
          position: 'relative',
          flex: 1,
          height: 8,
          borderRadius: 'var(--radius, 2px)',
          background: 'color-mix(in srgb, var(--text-muted) 18%, transparent)',
        }}
      >
        <div
          style={{
            position: 'absolute',
            top: 0,
            bottom: 0,
            left: 0,
            width: `${v * 100}%`,
            background: color,
            borderRadius: 'var(--radius, 2px)',
          }}
        />
      </div>
      <span style={{ width: 40, textAlign: 'right', fontVariantNumeric: 'tabular-nums' }}>
        {v.toFixed(2)}
      </span>
    </div>
  );
}

export function MoodMeters({
  valence,
  arousal,
  dominance,
}: {
  valence: number;
  arousal: number;
  dominance: number;
}) {
  return (
    <div style={{ display: 'grid', gap: 4 }}>
      <SignedBar label="Valence" value={valence} />
      <SignedBar label="Arousal" value={arousal} />
      <SignedBar label="Dominance" value={dominance} />
    </div>
  );
}

export function NeurotransmitterMeters({
  cortisol,
  dopamine,
  oxytocin,
  serotonin,
}: {
  cortisol: number;
  dopamine: number;
  oxytocin: number;
  serotonin: number;
}) {
  return (
    <div style={{ display: 'grid', gap: 4 }}>
      <LevelBar label="Cortisol" value={cortisol} color="var(--red, #9a2c3f)" />
      <LevelBar label="Dopamine" value={dopamine} color="var(--amber, #d97706)" />
      <LevelBar label="Oxytocin" value={oxytocin} color="var(--purple, #9333ea)" />
      <LevelBar label="Serotonin" value={serotonin} color="var(--blue, #1d4e5f)" />
    </div>
  );
}
