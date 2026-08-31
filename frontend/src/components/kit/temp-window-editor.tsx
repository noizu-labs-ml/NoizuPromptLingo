'use client';

import { useId } from 'react';
import { kitBtnSm, kitFieldLabel, kitInput } from './shared';

/** Upper bound for `enable_for_hours` (30 days). */
export const MAX_ENABLE_HOURS = 720;

export interface TempWindow {
  /** ISO 8601 datetime; tool stays hidden until this instant (F3 field). */
  hide_until: string | null;
  /** Hours from apply-time the tool is enabled; null = no timed enable. */
  enable_for_hours: number | null;
}

interface TempWindowEditorProps {
  value: TempWindow;
  onChange: (next: TempWindow) => void;
  readOnly?: boolean;
}

type Mode = 'none' | 'hide_until' | 'enable_for';

function modeOf(v: TempWindow): Mode {
  if (v.hide_until) return 'hide_until';
  if (v.enable_for_hours !== null) return 'enable_for';
  return 'none';
}

/**
 * Editor for time-boxed tool visibility (binds the F3 temporal-windows shape:
 * `hide_until` + `enable_for_hours`). Presets for common windows plus custom
 * datetime/hours entry. The two windows are mutually exclusive — applying one
 * clears the other, mirroring the F3 evaluation semantics (hide_until wins
 * until it lapses, then enable_for_hours takes over).
 */
export default function TempWindowEditor({ value, onChange, readOnly = false }: TempWindowEditorProps) {
  const mode = modeOf(value);
  const uid = useId();
  const hideUntilId = `${uid}-hide-until`;
  const enableHoursId = `${uid}-enable-hours`;

  function setMode(next: Mode) {
    if (next === 'none') {
      onChange({ hide_until: null, enable_for_hours: null });
    } else if (next === 'hide_until') {
      // Default to 24h out — always ISO 8601 UTC, never a naive local string.
      onChange({ hide_until: new Date(Date.now() + 24 * 3600 * 1000).toISOString(), enable_for_hours: null });
    } else {
      onChange({ hide_until: null, enable_for_hours: 24 });
    }
  }

  const summary = describe(value);

  return (
    <fieldset
      disabled={readOnly}
      style={{
        border: '1px solid var(--border)',
        borderRadius: 6,
        padding: 12,
        margin: 0,
        background: 'var(--bg-3)',
        display: 'flex',
        flexDirection: 'column',
        gap: 10,
      }}
    >
      <legend style={{ fontSize: 11, fontWeight: 600, color: 'var(--text-0)', padding: '0 4px' }}>
        Time-boxed visibility
      </legend>

      <div role="radiogroup" aria-label="Visibility window mode" style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
        {(
          [
            { id: 'none' as const, label: 'Always visible' },
            { id: 'hide_until' as const, label: 'Hide until…' },
            { id: 'enable_for' as const, label: 'Enable for…' },
          ]
        ).map((opt) => (
          <button
            key={opt.id}
            type="button"
            role="radio"
            aria-checked={mode === opt.id}
            onClick={() => setMode(opt.id)}
            style={{
              ...kitBtnSm,
              ...(mode === opt.id
                ? { background: 'var(--accent)', color: 'white', borderColor: 'var(--accent)' }
                : {}),
            }}
          >
            {opt.label}
          </button>
        ))}
      </div>

      {mode === 'hide_until' ? (
        <div>
          <label htmlFor={hideUntilId} style={kitFieldLabel}>Hidden until</label>
          <input
            id={hideUntilId}
            type="datetime-local"
            value={value.hide_until ? toLocalInput(new Date(value.hide_until)) : ''}
            onChange={(e) => onChange({ ...value, hide_until: e.target.value ? new Date(e.target.value).toISOString() : null })}
            style={{ ...kitInput, width: '100%' }}
          />
          <div style={{ display: 'flex', gap: 6, marginTop: 6, flexWrap: 'wrap' }}>
            {HIDE_PRESETS.map((p) => (
              <button
                key={p.label}
                type="button"
                onClick={() => onChange({ ...value, hide_until: new Date(Date.now() + p.ms).toISOString() })}
                style={kitBtnSm}
              >
                {p.label}
              </button>
            ))}
          </div>
        </div>
      ) : null}

      {mode === 'enable_for' ? (
        <div>
          <label htmlFor={enableHoursId} style={kitFieldLabel}>Enabled for (hours)</label>
          <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
            <input
              id={enableHoursId}
              type="number"
              min={1}
              max={MAX_ENABLE_HOURS}
              step={1}
              value={value.enable_for_hours ?? ''}
              onChange={(e) => {
                const n = e.target.value === ''
                  ? null
                  : Math.min(MAX_ENABLE_HOURS, Math.max(1, Math.floor(Number(e.target.value))));
                onChange({ ...value, enable_for_hours: Number.isNaN(n as number) ? null : n });
              }}
              style={{ ...kitInput, width: 90 }}
            />
            {[1, 8, 24, 72].map((h) => (
              <button
                key={h}
                type="button"
                onClick={() => onChange({ ...value, enable_for_hours: h })}
                style={kitBtnSm}
              >
                {h}h
              </button>
            ))}
          </div>
          <p style={{ fontSize: 10, color: 'var(--text-3)', margin: '6px 0 0' }}>
            The tool becomes visible/enabled when applied and auto-hides once the window lapses.
          </p>
        </div>
      ) : null}

      {mode !== 'none' ? (
        <p style={{ fontSize: 10, color: 'var(--text-2)', margin: 0 }} aria-live="polite">
          {summary}
        </p>
      ) : null}
    </fieldset>
  );
}

const HIDE_PRESETS: { label: string; ms: number }[] = [
  { label: '1h', ms: 3600 * 1000 },
  { label: 'Until tomorrow', ms: 24 * 3600 * 1000 },
  { label: '1 week', ms: 7 * 24 * 3600 * 1000 },
  { label: '30 days', ms: 30 * 24 * 3600 * 1000 },
];

/** ISO datetime → value accepted by <input type="datetime-local"> (local time). */
function toLocalInput(d: Date): string {
  const pad = (n: number) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`;
}

function describe(v: TempWindow): string {
  if (v.hide_until) {
    return `Hidden until ${new Date(v.hide_until).toLocaleString()}.`;
  }
  if (v.enable_for_hours !== null) {
    return `Enabled for the next ${v.enable_for_hours}h after saving, then hidden.`;
  }
  return 'No time window.';
}
