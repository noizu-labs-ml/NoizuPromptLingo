// Cell-renderer registry (ticket 0f8453f5, diego-frontend). Resolves a string
// `render` hint on a column/detail-field into a ReactNode — `render: 'slugChip'`
// "just works" across all 14 domains. Value-based + cross-domain only; domain-
// specific presentation stays a function renderer in the descriptor.
//
// Division of labor: this owns STRUCTURE + a11y (copyable chips, dot+label, title
// tooltips). COLOR is lena-graphic's reserved channel — statusChip emits a
// `data-status` hook so her CSS maps each status to a palette; we never hardcode hue.
import type { ReactNode } from 'react';
import type { CellRenderHint, CellRenderer } from './types';

/** Human-relative time with the absolute timestamp as a title (a11y + hover). */
function RelativeDate({ value }: { value: unknown }) {
  if (value == null || value === '') return <span className="console-muted">—</span>;
  const iso = String(value);
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return <>{iso}</>;
  const diff = Date.now() - d.getTime();
  const mins = Math.floor(diff / 60000);
  let rel: string;
  if (mins < 1) rel = 'just now';
  else if (mins < 60) rel = `${mins}m ago`;
  else if (mins < 1440) rel = `${Math.floor(mins / 60)}h ago`;
  else rel = `${Math.floor(mins / 1440)}d ago`;
  return (
    <time dateTime={iso} title={d.toLocaleString()}>
      {rel}
    </time>
  );
}

/** Deterministic hue from a string so an identity's dot is stable across renders. */
function hueFor(s: string): number {
  let h = 0;
  for (let i = 0; i < s.length; i++) h = (h * 31 + s.charCodeAt(i)) % 360;
  return h;
}

function truncMiddle(s: string, head = 6, tail = 4): string {
  return s.length <= head + tail + 1 ? s : `${s.slice(0, head)}…${s.slice(-tail)}`;
}

/**
 * The registry. Each renderer takes the cell value (row[column.key]) + the full row
 * (some renderers, e.g. identityChip, may want a sibling field later).
 */
export const CELL_RENDERERS: Record<
  CellRenderHint,
  (value: unknown, row: Record<string, unknown>) => ReactNode
> = {
  // Copyable mono slug chip (matches the chat room-header slug treatment).
  slugChip: (value) =>
    value == null || value === '' ? (
      <span className="console-muted">—</span>
    ) : (
      <span className="console-chip console-chip--slug" title={String(value)}>
        {String(value)}
      </span>
    ),

  // Copyable, middle-truncated UUID; full value revealed on select-all / title.
  idChip: (value) =>
    value == null || value === '' ? (
      <span className="console-muted">—</span>
    ) : (
      <span className="console-chip console-chip--id" title={String(value)}>
        {truncMiddle(String(value))}
      </span>
    ),

  // Status pill. Color comes from lena's CSS via the data-status hook, never here.
  statusChip: (value) =>
    value == null || value === '' ? (
      <span className="console-muted">—</span>
    ) : (
      <span className="console-chip console-chip--status" data-status={String(value)}>
        {String(value)}
      </span>
    ),

  relativeDate: (value) => <RelativeDate value={value} />,

  // Color-dot + label identity cell (the persona-peek throughline yuki is building
  // into chat v2 — shared so table identity + chat identity use one renderer).
  identityChip: (value) => {
    if (value == null || value === '') return <span className="console-muted">—</span>;
    const label = String(value);
    return (
      <span className="console-identity">
        <span
          className="console-identity__dot"
          aria-hidden
          style={{ background: `hsl(${hueFor(label)} 55% 45%)` }}
        />
        <span className="console-identity__label">{label}</span>
      </span>
    );
  },
};

/** True when a `render` value is a registry hint (vs a function renderer). */
export function isRenderHint(r: unknown): r is CellRenderHint {
  return typeof r === 'string' && r in CELL_RENDERERS;
}

/**
 * Resolve a column/detail-field `render` to a ReactNode — shared by DataTable +
 * DetailView so cells look identical in the list and the detail. A function runs
 * against the row; a hint resolves through the registry; absent falls back to the
 * raw value (em-dash for empty).
 */
export function renderField<T>(render: CellRenderer<T> | undefined, key: string, row: T): ReactNode {
  if (typeof render === 'function') return render(row);
  if (isRenderHint(render)) return CELL_RENDERERS[render]((row as Record<string, unknown>)[key], row as Record<string, unknown>);
  const v = (row as Record<string, unknown>)[key];
  return v == null || v === '' ? <span className="console-muted">—</span> : <>{String(v)}</>;
}
