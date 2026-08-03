'use client';

import { useCallback, useEffect, useMemo, useState } from 'react';
import { useOrg, useOrgId } from '@/context/org';
import { MiniRealtimeVoiceWidget } from '@/components/mini-realtime-voice-widget';
import { api, type OrgDashboardStats } from '@/lib/api';
import {
  CubeIcon,
  ClockIcon,
  Squares2X2Icon,
  CheckBadgeIcon,
  BellIcon,
  ArrowTrendingUpIcon,
  ArrowTrendingDownIcon,
} from '@heroicons/react/24/outline';
import type { ComponentType, SVGProps } from 'react';

type HeroIcon = ComponentType<SVGProps<SVGSVGElement>>;
type RangeDays = 7 | 14 | 30;
type Slice = { label: string; value: number; color: string };

const STACK_COLORS = {
  sessions: 'var(--brand-red, #c0392b)',
  artifacts: 'var(--brand-blue, #0047ab)',
  chat: 'var(--brand-yellow, #f5d90a)',
  tickets: 'var(--success, #16a34a)',
} as const;

const KIND_COLORS: Record<string, string> = {
  document: 'var(--brand-blue, #0047ab)',
  code: 'var(--brand-red, #c0392b)',
  wiki: 'var(--brand-yellow, #f5d90a)',
  config: 'var(--warning, #d97706)',
  image: 'var(--success, #16a34a)',
  binary: 'var(--text-muted, #94a3b8)',
};

const SESSION_STATUS_COLORS: Record<string, string> = {
  active: 'var(--success, #16a34a)',
  idle: 'var(--brand-yellow, #f5d90a)',
  completed: 'var(--brand-blue, #0047ab)',
  archived: 'var(--text-muted, #94a3b8)',
};

const TICKET_STATUS_META: { label: string; match: string[]; color: string }[] = [
  { label: 'Backlog', match: ['open', 'todo', 'backlog', 'new'], color: 'var(--text-muted, #94a3b8)' },
  { label: 'In progress', match: ['in_progress', 'progress', 'active', 'doing'], color: 'var(--brand-blue, #0047ab)' },
  { label: 'In review', match: ['in_review', 'review'], color: 'var(--warning, #d97706)' },
  { label: 'Blocked', match: ['blocked'], color: 'var(--brand-red, #c0392b)' },
  { label: 'Done', match: ['done', 'closed', 'complete', 'completed'], color: 'var(--success, #16a34a)' },
];

const HEATMAP_DAYS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const HEATMAP_BUCKETS = ['12a', '4a', '8a', '12p', '4p', '8p'];
const DAY_LABELS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

function labelForDayKey(key: string): string {
  const d = new Date(`${key}T12:00:00`);
  return DAY_LABELS[d.getDay()] ?? '';
}

function cumulativeSpark(daily: number[]): number[] {
  let sum = 0;
  return daily.map((n) => {
    sum += n;
    return sum;
  });
}

function pctDelta(recent: number, prior: number): number {
  if (prior === 0) return recent > 0 ? 100 : 0;
  return Math.round(((recent - prior) / prior) * 100);
}

function relativeTime(iso?: string | null, now = Date.now()): string {
  if (!iso) return '';
  const t = Date.parse(iso);
  if (!Number.isFinite(t)) return '';
  const sec = Math.max(0, Math.floor((now - t) / 1000));
  if (sec < 60) return 'just now';
  if (sec < 3600) return `${Math.floor(sec / 60)}m ago`;
  if (sec < 86400) return `${Math.floor(sec / 3600)}h ago`;
  if (sec < 172800) return 'yesterday';
  return `${Math.floor(sec / 86400)}d ago`;
}

function halfDelta(counts: number[]): { delta: number; spark: number[] } {
  const half = Math.floor(counts.length / 2);
  const prior = counts.slice(0, half).reduce((s, n) => s + n, 0);
  const recent = counts.slice(half).reduce((s, n) => s + n, 0);
  return { delta: pctDelta(recent, prior), spark: cumulativeSpark(counts) };
}

function mapToSlices(map: Record<string, number> | undefined, colors: Record<string, string>): Slice[] {
  const entries = Object.entries(map ?? {}).filter(([, v]) => v > 0);
  if (entries.length === 0) {
    return [{ label: 'None', value: 0, color: 'var(--text-muted, #94a3b8)' }];
  }
  return entries
    .sort((a, b) => b[1] - a[1])
    .map(([k, v]) => ({
      label: k.charAt(0).toUpperCase() + k.slice(1),
      value: v,
      color: colors[k] ?? colors[k.toLowerCase()] ?? 'var(--text-muted, #94a3b8)',
    }));
}

// ─── Tiny dependency-free SVG charts ──────────────────────────────────────
function linePath(data: number[], w: number, h: number, pad = 4, yMin?: number, yMax?: number) {
  const max = yMax ?? Math.max(...data, 0);
  const min = yMin ?? Math.min(...data, 0);
  const range = max - min || 1;
  const stepX = (w - pad * 2) / Math.max(data.length - 1, 1);
  return data
    .map((v, i) => {
      const x = pad + i * stepX;
      const y = pad + (h - pad * 2) * (1 - (v - min) / range);
      return `${i === 0 ? 'M' : 'L'}${x.toFixed(1)} ${y.toFixed(1)}`;
    })
    .join(' ');
}

function Sparkline({ data, positive }: { data: number[]; positive: boolean }) {
  const w = 120;
  const h = 36;
  const stroke = positive ? 'var(--success, #16a34a)' : 'var(--error, #dc2626)';
  const series = data.length >= 2 ? data : [0, ...data];
  return (
    <svg className="kpi-card__spark" viewBox={`0 0 ${w} ${h}`} preserveAspectRatio="none" aria-hidden="true">
      <path d={linePath(series, w, h)} fill="none" stroke={stroke} strokeWidth={2} strokeLinejoin="round" strokeLinecap="round" />
    </svg>
  );
}

function AreaChart({ data }: { data: number[] }) {
  const w = 640;
  const h = 200;
  const pad = 6;
  const series = data.length >= 2 ? data : [0, ...data];
  const line = linePath(series, w, h, pad, 0);
  const stepX = (w - pad * 2) / Math.max(series.length - 1, 1);
  const lastX = pad + (series.length - 1) * stepX;
  const area = `${line} L${lastX.toFixed(1)} ${h - pad} L${pad} ${h - pad} Z`;
  return (
    <svg className="chart-svg" viewBox={`0 0 ${w} ${h}`} preserveAspectRatio="none" role="img" aria-label="Activity over time">
      <defs>
        <linearGradient id="dash-area" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor="var(--brand-blue, #0047ab)" stopOpacity="0.28" />
          <stop offset="100%" stopColor="var(--brand-blue, #0047ab)" stopOpacity="0" />
        </linearGradient>
      </defs>
      <path d={area} fill="url(#dash-area)" />
      <path d={line} fill="none" stroke="var(--brand-blue, #0047ab)" strokeWidth={2.5} strokeLinejoin="round" strokeLinecap="round" />
    </svg>
  );
}

function MultiLineChart({
  series,
  labels,
}: {
  series: { key: string; data: number[]; color: string }[];
  labels: string[];
}) {
  const w = 640;
  const h = 200;
  const pad = 16;
  const all = series.flatMap((s) => s.data);
  const yMax = Math.max(...all, 1);
  const yMin = 0;
  const gridYs = [0.25, 0.5, 0.75, 1].map((t) => pad + (h - pad * 2) * (1 - t));

  return (
    <div className="chart">
      <svg className="chart-svg" viewBox={`0 0 ${w} ${h}`} preserveAspectRatio="none" role="img" aria-label="Multi-series activity">
        {gridYs.map((y, i) => (
          <line key={i} x1={pad} y1={y} x2={w - pad} y2={y} className="chart-gridline" strokeWidth={1} strokeDasharray="4 4" />
        ))}
        {series.map((s) => {
          const data = s.data.length >= 2 ? s.data : [0, ...s.data];
          return (
            <path
              key={s.key}
              d={linePath(data, w, h, pad, yMin, yMax)}
              fill="none"
              stroke={s.color}
              strokeWidth={2.25}
              strokeLinejoin="round"
              strokeLinecap="round"
            />
          );
        })}
        {series.map((s) => {
          const data = s.data.length >= 2 ? s.data : [0, ...s.data];
          const last = data[data.length - 1] ?? 0;
          const stepX = (w - pad * 2) / Math.max(data.length - 1, 1);
          const x = pad + (data.length - 1) * stepX;
          const y = pad + (h - pad * 2) * (1 - (last - yMin) / (yMax - yMin || 1));
          return <circle key={`${s.key}-dot`} cx={x} cy={y} r={3.5} fill={s.color} stroke="var(--surface, #fff)" strokeWidth={1.5} />;
        })}
      </svg>
      <div className="chart-legend">
        {series.map((s) => (
          <span key={s.key} className="chart-legend__item">
            <i className="chart-legend__swatch" style={{ background: s.color }} />
            {s.key}
          </span>
        ))}
      </div>
      <div className="chart-axis chart-axis--labels">
        {labels.map((lab, i) => (
          <span key={i}>{i % 2 === 0 ? lab : ''}</span>
        ))}
      </div>
    </div>
  );
}

function polarToCartesian(cx: number, cy: number, r: number, angleDeg: number) {
  const rad = ((angleDeg - 90) * Math.PI) / 180;
  return { x: cx + r * Math.cos(rad), y: cy + r * Math.sin(rad) };
}

function donutSlice(cx: number, cy: number, rOuter: number, rInner: number, startAngle: number, endAngle: number) {
  const large = endAngle - startAngle > 180 ? 1 : 0;
  const o1 = polarToCartesian(cx, cy, rOuter, endAngle);
  const o0 = polarToCartesian(cx, cy, rOuter, startAngle);
  const i1 = polarToCartesian(cx, cy, rInner, endAngle);
  const i0 = polarToCartesian(cx, cy, rInner, startAngle);
  return [
    `M ${o0.x} ${o0.y}`,
    `A ${rOuter} ${rOuter} 0 ${large} 1 ${o1.x} ${o1.y}`,
    `L ${i1.x} ${i1.y}`,
    `A ${rInner} ${rInner} 0 ${large} 0 ${i0.x} ${i0.y}`,
    'Z',
  ].join(' ');
}

function DonutChart({
  slices,
  centerLabel,
  centerValue,
  ariaLabel,
}: {
  slices: Slice[];
  centerLabel: string;
  centerValue: string;
  ariaLabel: string;
}) {
  const nonzero = slices.filter((s) => s.value > 0);
  const total = slices.reduce((s, x) => s + x.value, 0) || 1;
  const size = 200;
  const cx = size / 2;
  const cy = size / 2;
  const rOuter = 88;
  const rInner = 54;
  let angle = 0;
  const paths =
    nonzero.length === 0
      ? []
      : nonzero.map((slice) => {
          const sweep = (slice.value / total) * 360;
          const start = angle;
          const end = angle + Math.max(sweep, 0.01);
          angle += sweep;
          return { ...slice, d: donutSlice(cx, cy, rOuter, rInner, start, end - 0.001) };
        });

  return (
    <div className="donut">
      <svg className="donut__svg" viewBox={`0 0 ${size} ${size}`} role="img" aria-label={ariaLabel}>
        {paths.length === 0 ? (
          <circle cx={cx} cy={cy} r={(rOuter + rInner) / 2} fill="none" stroke="var(--border, #e2e8f0)" strokeWidth={rOuter - rInner} />
        ) : (
          paths.map((p) => <path key={p.label} d={p.d} fill={p.color} stroke="var(--surface, #fff)" strokeWidth={2} />)
        )}
        <text x={cx} y={cy - 6} textAnchor="middle" className="donut__value">
          {centerValue}
        </text>
        <text x={cx} y={cy + 14} textAnchor="middle" className="donut__label">
          {centerLabel}
        </text>
      </svg>
      <ul className="donut__legend">
        {slices.map((s) => (
          <li key={s.label}>
            <i className="chart-legend__swatch" style={{ background: s.color }} />
            <span className="donut__legend-label">{s.label}</span>
            <span className="donut__legend-value">{s.value}</span>
            <span className="donut__legend-pct">{total ? Math.round((s.value / total) * 100) : 0}%</span>
          </li>
        ))}
      </ul>
    </div>
  );
}

function StackedBarChart({
  weeks,
}: {
  weeks: { week: string; sessions: number; artifacts: number; chat: number; tickets: number }[];
}) {
  const keys = ['artifacts', 'chat', 'sessions', 'tickets'] as const;
  const totals = weeks.map((w) => keys.reduce((s, k) => s + w[k], 0));
  const max = Math.max(...totals, 1);
  const w = 640;
  const h = 200;
  const padX = 28;
  const padY = 16;
  const plotW = w - padX * 2;
  const plotH = h - padY * 2;
  const gap = 16;
  const barW = weeks.length ? (plotW - gap * (weeks.length - 1)) / weeks.length : plotW;

  return (
    <div className="chart">
      <svg className="chart-svg" viewBox={`0 0 ${w} ${h}`} preserveAspectRatio="xMidYMid meet" role="img" aria-label="Weekly usage stacked by domain">
        {[0.25, 0.5, 0.75, 1].map((t) => {
          const y = padY + plotH * (1 - t);
          return <line key={t} x1={padX} y1={y} x2={w - padX} y2={y} className="chart-gridline" strokeWidth={1} strokeDasharray="4 4" />;
        })}
        {weeks.map((week, i) => {
          const x = padX + i * (barW + gap);
          let yCursor = padY + plotH;
          return (
            <g key={week.week}>
              {keys.map((k) => {
                const val = week[k];
                const bh = (val / max) * plotH;
                yCursor -= bh;
                return (
                  <rect
                    key={k}
                    x={x}
                    y={yCursor}
                    width={barW}
                    height={Math.max(bh, 0)}
                    fill={STACK_COLORS[k]}
                    rx={k === keys[keys.length - 1] ? 3 : 0}
                  />
                );
              })}
              <text x={x + barW / 2} y={h - 2} textAnchor="middle" className="chart-tick">
                {week.week}
              </text>
            </g>
          );
        })}
      </svg>
      <div className="chart-legend">
        {keys.map((k) => (
          <span key={k} className="chart-legend__item">
            <i className="chart-legend__swatch" style={{ background: STACK_COLORS[k] }} />
            {k}
          </span>
        ))}
      </div>
    </div>
  );
}

function HorizontalBars({ items }: { items: Slice[] }) {
  const max = Math.max(...items.map((i) => i.value), 1);
  return (
    <div className="hbars" role="img" aria-label="Ticket pipeline">
      {items.map((item) => (
        <div key={item.label} className="hbars__row">
          <div className="hbars__label">{item.label}</div>
          <div className="hbars__track">
            <div className="hbars__bar" style={{ width: `${(item.value / max) * 100}%`, background: item.color }} />
          </div>
          <div className="hbars__value">{item.value}</div>
        </div>
      ))}
    </div>
  );
}

function ActivityHeatmap({
  days,
  buckets,
  cells,
}: {
  days: string[];
  buckets: string[];
  cells: number[][];
}) {
  const flat = cells.flat();
  const max = Math.max(...flat, 1);

  return (
    <div className="heatmap" role="img" aria-label="Activity heatmap by day and time">
      <div className="heatmap__corner" />
      {buckets.map((b) => (
        <div key={b} className="heatmap__colhead">
          {b}
        </div>
      ))}
      {days.map((day, ri) => (
        <div key={day} className="heatmap__row">
          <div className="heatmap__rowhead">{day}</div>
          {(cells[ri] ?? Array.from({ length: buckets.length }, () => 0)).map((v, ci) => {
            const intensity = v / max;
            return (
              <div
                key={ci}
                className="heatmap__cell"
                title={`${day} ${buckets[ci]}: ${v}`}
                style={{
                  background: `color-mix(in srgb, var(--brand-blue, #0047ab) ${Math.round(intensity * 85 + (v === 0 ? 0 : 10))}%, var(--surface-alt, #f4f6f8))`,
                }}
              >
                <span className="heatmap__cell-val">{v || ''}</span>
              </div>
            );
          })}
        </div>
      ))}
      <div className="heatmap__scale">
        <span>Less</span>
        <span className="heatmap__scale-swatches">
          {[0, 0.25, 0.5, 0.75, 1].map((t) => (
            <i
              key={t}
              style={{
                background: `color-mix(in srgb, var(--brand-blue, #0047ab) ${Math.round(t * 85 + (t === 0 ? 0 : 10))}%, var(--surface-alt, #f4f6f8))`,
              }}
            />
          ))}
        </span>
        <span>More</span>
      </div>
    </div>
  );
}

// ─── Page ─────────────────────────────────────────────────────────────────
export default function OrgDashboard() {
  const { currentOrg } = useOrg();
  const { orgId, loading: orgLoading } = useOrgId();
  const [range, setRange] = useState<RangeDays>(14);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [stats, setStats] = useState<OrgDashboardStats | null>(null);

  const load = useCallback(async () => {
    if (!orgId) return;
    setLoading(true);
    setError(null);
    try {
      const res = await api.getOrgDashboardStats(orgId, { range });
      setStats(res.stats);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load dashboard stats');
    } finally {
      setLoading(false);
    }
  }, [orgId, range]);

  useEffect(() => {
    if (orgLoading) return;
    if (!orgId) {
      setLoading(false);
      return;
    }
    void load();
  }, [orgId, orgLoading, load]);

  const counts = stats?.counts;
  const daily = stats?.daily;

  const activity = useMemo(() => {
    if (!daily) return [];
    const n = daily.keys?.length ?? 0;
    return Array.from({ length: n }, (_, i) =>
      (daily.sessions[i] ?? 0) +
      (daily.artifacts[i] ?? 0) +
      (daily.chat_rooms[i] ?? 0) +
      (daily.tickets[i] ?? 0) +
      (daily.reviews[i] ?? 0),
    );
  }, [daily]);

  const dayLabels = useMemo(() => (daily?.keys ?? []).map(labelForDayKey), [daily]);

  const kpis = useMemo(() => {
    const empty = { delta: 0, spark: [0] };
    const p = daily?.projects ? halfDelta(daily.projects) : empty;
    const s = daily?.sessions ? halfDelta(daily.sessions) : empty;
    const a = daily?.artifacts ? halfDelta(daily.artifacts) : empty;
    const r = daily?.reviews ? halfDelta(daily.reviews) : empty;
    return [
      {
        label: 'Projects',
        value: String(counts?.projects ?? 0),
        delta: p.delta,
        Icon: Squares2X2Icon,
        spark: p.spark.length ? p.spark : [0, counts?.projects ?? 0],
      },
      {
        label: 'Sessions',
        value: String(counts?.sessions ?? 0),
        delta: s.delta,
        Icon: ClockIcon,
        spark: s.spark.length ? s.spark : [0, counts?.sessions ?? 0],
      },
      {
        label: 'Artifacts',
        value: String(counts?.artifacts ?? 0),
        delta: a.delta,
        Icon: CubeIcon,
        spark: a.spark.length ? a.spark : [0, counts?.artifacts ?? 0],
      },
      {
        label: 'Reviews',
        value: String(counts?.reviews ?? 0),
        delta: r.delta,
        Icon: CheckBadgeIcon,
        spark: r.spark.length ? r.spark : [0, counts?.reviews ?? 0],
      },
    ];
  }, [counts, daily]);

  const usage = useMemo(
    () =>
      [
        { label: 'Artifacts', value: counts?.artifacts ?? 0, color: 'var(--brand-blue, #0047ab)' },
        { label: 'Chat', value: counts?.chat_rooms ?? 0, color: 'var(--brand-yellow, #f5d90a)' },
        { label: 'Tickets', value: counts?.tickets ?? 0, color: 'var(--success, #16a34a)' },
        { label: 'Sessions', value: counts?.sessions ?? 0, color: 'var(--brand-red, #c0392b)' },
        { label: 'Reviews', value: counts?.reviews ?? 0, color: 'var(--warning, #d97706)' },
      ] as Slice[],
    [counts],
  );
  const usageMax = Math.max(...usage.map((u) => u.value), 1);

  const sessionStatus = useMemo(
    () => mapToSlices(stats?.by_status?.sessions, SESSION_STATUS_COLORS),
    [stats],
  );

  const artifactKinds = useMemo(
    () => mapToSlices(stats?.by_kind?.artifacts, KIND_COLORS),
    [stats],
  );

  const ticketPipeline = useMemo(() => {
    const map = stats?.by_status?.tickets ?? {};
    return TICKET_STATUS_META.map((meta) => ({
      label: meta.label,
      value: meta.match.reduce((sum, k) => sum + (map[k] ?? 0), 0),
      color: meta.color,
    }));
  }, [stats]);

  const stacked = stats?.weekly ?? [];
  const heatmap =
    stats?.heatmap && stats.heatmap.length === 7
      ? stats.heatmap
      : Array.from({ length: 7 }, () => Array.from({ length: 6 }, () => 0));

  const notifications = useMemo(() => {
    const items: { title: string; body: string; time: string; unread: boolean; Icon: HeroIcon }[] = [];
    for (const r of stats?.attention?.open_reviews ?? []) {
      items.push({
        title: 'Review open',
        body: r.title || r.id,
        time: relativeTime(r.updated_at),
        unread: true,
        Icon: CheckBadgeIcon,
      });
    }
    for (const t of stats?.attention?.blocked_tickets ?? []) {
      items.push({
        title: t.status === 'blocked' ? 'Ticket blocked' : 'Ticket in review',
        body: t.title || t.id,
        time: relativeTime(t.updated_at),
        unread: true,
        Icon: BellIcon,
      });
    }
    return items;
  }, [stats]);

  const feed = useMemo(() => {
    return (stats?.recent ?? []).map((r) => ({
      who: r.type.charAt(0).toUpperCase() + r.type.slice(1),
      action: 'updated',
      target: r.title || r.id,
      time: relativeTime(r.at),
    }));
  }, [stats]);

  const busy = orgLoading || loading;

  return (
    <div className="content">
      <div className="dash">
        <div className="dash-header">
          <div>
            <h1 className="dash-title">{currentOrg?.name || 'Organization'} Dashboard</h1>
            <p className="dash-sub">Overview of activity and usage across your workspace.</p>
          </div>
          <div className="dash-range" role="group" aria-label="Date range">
            {([7, 14, 30] as RangeDays[]).map((d) => (
              <button
                key={d}
                type="button"
                className={`dash-range__btn${range === d ? ' is-active' : ''}`}
                onClick={() => setRange(d)}
                aria-pressed={range === d}
              >
                {d}d
              </button>
            ))}
          </div>
        </div>

        {error ? (
          <p className="dash-note" role="alert">
            {error}{' '}
            <button type="button" className="dash-panel__action" onClick={() => void load()}>
              Retry
            </button>
          </p>
        ) : null}
        {busy ? <p className="dash-note">Loading workspace metrics…</p> : null}

        <div className="dash-kpis">
          {kpis.map((k) => {
            const positive = k.delta >= 0;
            return (
              <div key={k.label} className="kpi-card">
                <div className="kpi-card__top">
                  <span className="kpi-card__icon">
                    <k.Icon />
                  </span>
                  <span className={`kpi-card__delta${positive ? ' is-up' : ' is-down'}`}>
                    {positive ? <ArrowTrendingUpIcon /> : <ArrowTrendingDownIcon />}
                    {Math.abs(k.delta)}%
                  </span>
                </div>
                <div className="kpi-card__value">{k.value}</div>
                <div className="kpi-card__label">{k.label}</div>
                <Sparkline data={k.spark} positive={positive} />
              </div>
            );
          })}
        </div>

        <div className="dash-grid">
          {orgId ? <MiniRealtimeVoiceWidget orgId={orgId} /> : null}

          <section className="dash-panel">
            <div className="dash-panel__head">
              <h2 className="dash-panel__title">Activity</h2>
              <span className="dash-panel__hint">Last {range} days</span>
            </div>
            <div className="chart">
              <AreaChart data={activity} />
              <div className="chart-axis chart-axis--labels">
                {dayLabels.map((lab, i) => (
                  <span key={i}>{i % 2 === 0 ? lab : ''}</span>
                ))}
              </div>
            </div>
          </section>

          <section className="dash-panel">
            <div className="dash-panel__head">
              <h2 className="dash-panel__title">
                <BellIcon className="dash-panel__title-icon" />
                Attention
              </h2>
              <span className="dash-badge">{notifications.length} open</span>
            </div>
            {notifications.length === 0 ? (
              <p className="dash-note" style={{ margin: 0 }}>
                No open reviews or blocked tickets.
              </p>
            ) : (
              <ul className="notif-list">
                {notifications.map((n, i) => (
                  <li key={i} className={`notif${n.unread ? ' is-unread' : ''}`}>
                    <span className="notif__icon">
                      <n.Icon />
                    </span>
                    <div className="notif__body">
                      <div className="notif__title">{n.title}</div>
                      <div className="notif__text text-info">{n.body}</div>
                    </div>
                    <span className="notif__time">{n.time}</span>
                  </li>
                ))}
              </ul>
            )}
          </section>

          <section className="dash-panel">
            <div className="dash-panel__head">
              <h2 className="dash-panel__title">Usage by domain</h2>
              <span className="dash-panel__hint">totals</span>
            </div>
            <div className="bars">
              {usage.map((u) => (
                <div key={u.label} className="bars__col">
                  <div className="bars__track">
                    <div className="bars__bar" style={{ height: `${(u.value / usageMax) * 100}%`, background: u.color }} />
                  </div>
                  <div className="bars__value">{u.value}</div>
                  <div className="bars__label">{u.label}</div>
                </div>
              ))}
            </div>
          </section>

          <section className="dash-panel">
            <div className="dash-panel__head">
              <h2 className="dash-panel__title">Recent activity</h2>
            </div>
            {feed.length === 0 ? (
              <p className="dash-note" style={{ margin: 0 }}>
                No recent activity yet.
              </p>
            ) : (
              <ul className="feed">
                {feed.map((f, i) => (
                  <li key={i} className="feed__item">
                    <span className="feed__avatar">{f.who.charAt(0)}</span>
                    <span className="feed__text">
                      <strong>{f.who}</strong> {f.action} <span className="feed__target">{f.target}</span>
                    </span>
                    <span className="feed__time">{f.time}</span>
                  </li>
                ))}
              </ul>
            )}
          </section>

          <section className="dash-panel dash-panel--wide">
            <div className="dash-panel__head">
              <h2 className="dash-panel__title">Domain trends</h2>
              <span className="dash-panel__hint">Sessions · Artifacts · Chat · last {range}d</span>
            </div>
            <MultiLineChart
              labels={dayLabels}
              series={[
                { key: 'Sessions', data: daily?.sessions ?? [], color: 'var(--brand-red, #c0392b)' },
                { key: 'Artifacts', data: daily?.artifacts ?? [], color: 'var(--brand-blue, #0047ab)' },
                { key: 'Chat', data: daily?.chat_rooms ?? [], color: 'var(--brand-yellow, #f5d90a)' },
              ]}
            />
          </section>

          <section className="dash-panel">
            <div className="dash-panel__head">
              <h2 className="dash-panel__title">Session status</h2>
              <span className="dash-panel__hint">current mix</span>
            </div>
            <DonutChart
              slices={sessionStatus}
              centerLabel="sessions"
              centerValue={String(counts?.sessions ?? 0)}
              ariaLabel="Session status distribution"
            />
          </section>

          <section className="dash-panel">
            <div className="dash-panel__head">
              <h2 className="dash-panel__title">Artifact kinds</h2>
              <span className="dash-panel__hint">all time</span>
            </div>
            <DonutChart
              slices={artifactKinds}
              centerLabel="artifacts"
              centerValue={String(counts?.artifacts ?? 0)}
              ariaLabel="Artifact kind distribution"
            />
          </section>

          <section className="dash-panel dash-panel--wide">
            <div className="dash-panel__head">
              <h2 className="dash-panel__title">Weekly stacked volume</h2>
              <span className="dash-panel__hint">by domain · last 4 weeks</span>
            </div>
            <StackedBarChart weeks={stacked} />
          </section>

          <section className="dash-panel">
            <div className="dash-panel__head">
              <h2 className="dash-panel__title">Ticket pipeline</h2>
              <span className="dash-panel__hint">by status</span>
            </div>
            <HorizontalBars items={ticketPipeline} />
          </section>

          <section className="dash-panel dash-panel--wide">
            <div className="dash-panel__head">
              <h2 className="dash-panel__title">Activity heatmap</h2>
              <span className="dash-panel__hint">day × time of day (created)</span>
            </div>
            <ActivityHeatmap days={HEATMAP_DAYS} buckets={HEATMAP_BUCKETS} cells={heatmap} />
          </section>
        </div>

        <p className="dash-note">
          Metrics from <code>GET /dashboard/stats</code>
          {busy ? ' (loading…)' : ''} — full org counts (not list-capped). Range toggle refetches daily series.
        </p>
      </div>
    </div>
  );
}
