'use client';

import { useCallback, useEffect, useMemo, useState } from 'react';
import { useOrg, useOrgId } from '@/context/org';
import { MiniRealtimeVoiceWidget } from '@/components/mini-realtime-voice-widget';
import { api, type Artifact, type Project, type Review, type Session, type Ticket, type ChatRoom } from '@/lib/api';
import {
  CubeIcon,
  ClockIcon,
  Squares2X2Icon,
  CheckBadgeIcon,
  BellIcon,
  ChatBubbleLeftRightIcon,
  ArrowTrendingUpIcon,
  ArrowTrendingDownIcon,
} from '@heroicons/react/24/outline';
import type { ComponentType, SVGProps } from 'react';

type HeroIcon = ComponentType<SVGProps<SVGSVGElement>>;
type RangeDays = 7 | 14 | 30;

type Slice = { label: string; value: number; color: string };
type FeedItem = { who: string; action: string; target: string; time: string; at: number };
type NotifItem = { type: string; title: string; body: string; time: string; unread: boolean; Icon: HeroIcon; at: number };

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

const TICKET_STATUS_META: { key: string; label: string; match: string[]; color: string }[] = [
  { key: 'backlog', label: 'Backlog', match: ['open', 'todo', 'backlog', 'new'], color: 'var(--text-muted, #94a3b8)' },
  { key: 'in_progress', label: 'In progress', match: ['in_progress', 'progress', 'active', 'doing'], color: 'var(--brand-blue, #0047ab)' },
  { key: 'in_review', label: 'In review', match: ['in_review', 'review'], color: 'var(--warning, #d97706)' },
  { key: 'blocked', label: 'Blocked', match: ['blocked'], color: 'var(--brand-red, #c0392b)' },
  { key: 'done', label: 'Done', match: ['done', 'closed', 'complete', 'completed'], color: 'var(--success, #16a34a)' },
];

const HEATMAP_DAYS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const HEATMAP_BUCKETS = ['12a', '4a', '8a', '12p', '4p', '8p'];
const DAY_LABELS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

// ─── Aggregation helpers ──────────────────────────────────────────────────
function parseAt(iso?: string | null): number | null {
  if (!iso) return null;
  const t = Date.parse(iso);
  return Number.isFinite(t) ? t : null;
}

function startOfDay(d: Date): Date {
  return new Date(d.getFullYear(), d.getMonth(), d.getDate());
}

function dayKeys(rangeDays: number, end = new Date()): string[] {
  const endDay = startOfDay(end);
  const keys: string[] = [];
  for (let i = rangeDays - 1; i >= 0; i--) {
    const d = new Date(endDay);
    d.setDate(endDay.getDate() - i);
    keys.push(d.toISOString().slice(0, 10));
  }
  return keys;
}

function labelForDayKey(key: string): string {
  const d = new Date(`${key}T12:00:00`);
  return DAY_LABELS[d.getDay()] ?? '';
}

function countByDay(timestamps: (string | null | undefined)[], rangeDays: number): { keys: string[]; counts: number[]; labels: string[] } {
  const keys = dayKeys(rangeDays);
  const index = new Map(keys.map((k, i) => [k, i]));
  const counts = keys.map(() => 0);
  const cutoff = startOfDay(new Date());
  cutoff.setDate(cutoff.getDate() - (rangeDays - 1));
  const cutoffMs = cutoff.getTime();

  for (const iso of timestamps) {
    const t = parseAt(iso);
    if (t == null || t < cutoffMs) continue;
    const key = new Date(t).toISOString().slice(0, 10);
    const i = index.get(key);
    if (i != null) counts[i] += 1;
  }
  return { keys, counts, labels: keys.map(labelForDayKey) };
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

function relativeTime(ms: number, now = Date.now()): string {
  const sec = Math.max(0, Math.floor((now - ms) / 1000));
  if (sec < 60) return 'just now';
  if (sec < 3600) return `${Math.floor(sec / 60)}m ago`;
  if (sec < 86400) return `${Math.floor(sec / 3600)}h ago`;
  if (sec < 172800) return 'yesterday';
  return `${Math.floor(sec / 86400)}d ago`;
}

function countMap(items: string[]): Map<string, number> {
  const m = new Map<string, number>();
  for (const k of items) m.set(k, (m.get(k) ?? 0) + 1);
  return m;
}

function heatmapFromTimestamps(timestamps: (string | null | undefined)[]): number[][] {
  // rows Mon=0 … Sun=6; cols 6×4h buckets
  const cells = Array.from({ length: 7 }, () => Array.from({ length: 6 }, () => 0));
  for (const iso of timestamps) {
    const t = parseAt(iso);
    if (t == null) continue;
    const d = new Date(t);
    const jsDay = d.getDay(); // 0=Sun
    const row = jsDay === 0 ? 6 : jsDay - 1; // Mon=0
    const col = Math.min(5, Math.floor(d.getHours() / 4));
    cells[row][col] += 1;
  }
  return cells;
}

function weekBuckets(
  sessions: Session[],
  artifacts: Artifact[],
  rooms: ChatRoom[],
  tickets: Ticket[],
  weeks = 4,
): { week: string; sessions: number; artifacts: number; chat: number; tickets: number }[] {
  const now = startOfDay(new Date());
  // Align end of current week to Sunday for stable labels
  const out: { week: string; sessions: number; artifacts: number; chat: number; tickets: number }[] = [];
  for (let w = weeks - 1; w >= 0; w--) {
    const end = new Date(now);
    end.setDate(now.getDate() - w * 7);
    const start = new Date(end);
    start.setDate(end.getDate() - 6);
    const startMs = startOfDay(start).getTime();
    const endMs = startOfDay(end).getTime() + 86400000 - 1;
    const inRange = (iso?: string | null) => {
      const t = parseAt(iso);
      return t != null && t >= startMs && t <= endMs;
    };
    out.push({
      week: `W${weeks - w}`,
      sessions: sessions.filter((s) => inRange(s.inserted_at)).length,
      artifacts: artifacts.filter((a) => inRange(a.inserted_at)).length,
      chat: rooms.filter((r) => inRange(r.inserted_at)).length,
      tickets: tickets.filter((t) => inRange(t.inserted_at)).length,
    });
  }
  return out;
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
        {(slices.length ? slices : [{ label: 'None', value: 0, color: 'var(--text-muted, #94a3b8)' }]).map((s) => (
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
          {(cells[ri] ?? []).map((v, ci) => {
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
  const [projects, setProjects] = useState<Project[]>([]);
  const [sessions, setSessions] = useState<Session[]>([]);
  const [artifacts, setArtifacts] = useState<Artifact[]>([]);
  const [reviews, setReviews] = useState<Review[]>([]);
  const [tickets, setTickets] = useState<Ticket[]>([]);
  const [rooms, setRooms] = useState<ChatRoom[]>([]);

  const load = useCallback(async () => {
    if (!orgId) return;
    setLoading(true);
    setError(null);
    try {
      const [p, s, a, r, t, c] = await Promise.all([
        api.listProjects(orgId).then((res) => res.projects ?? []),
        api.listSessions(orgId).then((res) => res.sessions ?? []),
        api.listArtifacts(orgId).then((res) => res.artifacts ?? []),
        api.listReviews(orgId).then((res) => res.reviews ?? []),
        api.listTickets(orgId).then((res) => res.tickets ?? []),
        api.listChatRooms(orgId).then((res) => res.rooms ?? []),
      ]);
      setProjects(p);
      setSessions(s);
      setArtifacts(a);
      setReviews(r);
      setTickets(t);
      setRooms(c);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load dashboard data');
    } finally {
      setLoading(false);
    }
  }, [orgId]);

  useEffect(() => {
    if (orgLoading) return;
    if (!orgId) {
      setLoading(false);
      return;
    }
    void load();
  }, [orgId, orgLoading, load]);

  const half = Math.floor(range / 2);

  const sessionDaily = useMemo(() => countByDay(sessions.map((s) => s.inserted_at), range), [sessions, range]);
  const artifactDaily = useMemo(() => countByDay(artifacts.map((a) => a.inserted_at), range), [artifacts, range]);
  const roomDaily = useMemo(() => countByDay(rooms.map((r) => r.inserted_at), range), [rooms, range]);
  const reviewDaily = useMemo(() => countByDay(reviews.map((r) => r.inserted_at), range), [reviews, range]);
  const projectDaily = useMemo(() => countByDay(projects.map((p) => p.inserted_at), range), [projects, range]);
  const ticketDaily = useMemo(() => countByDay(tickets.map((t) => t.inserted_at), range), [tickets, range]);

  const activity = useMemo(() => {
    const n = sessionDaily.counts.length;
    return Array.from({ length: n }, (_, i) =>
      (sessionDaily.counts[i] ?? 0) +
      (artifactDaily.counts[i] ?? 0) +
      (roomDaily.counts[i] ?? 0) +
      (reviewDaily.counts[i] ?? 0) +
      (ticketDaily.counts[i] ?? 0),
    );
  }, [sessionDaily, artifactDaily, roomDaily, reviewDaily, ticketDaily]);

  const kpis = useMemo(() => {
    const halfSlice = (counts: number[]) => {
      const prior = counts.slice(0, half).reduce((s, n) => s + n, 0);
      const recent = counts.slice(half).reduce((s, n) => s + n, 0);
      return { prior, recent, delta: pctDelta(recent, prior), spark: cumulativeSpark(counts) };
    };
    const p = halfSlice(projectDaily.counts);
    const s = halfSlice(sessionDaily.counts);
    const a = halfSlice(artifactDaily.counts);
    const r = halfSlice(reviewDaily.counts);
    return [
      { label: 'Projects', value: String(projects.length), delta: p.delta, Icon: Squares2X2Icon, spark: p.spark.length ? p.spark : [0, projects.length] },
      { label: 'Sessions', value: String(sessions.length), delta: s.delta, Icon: ClockIcon, spark: s.spark.length ? s.spark : [0, sessions.length] },
      { label: 'Artifacts', value: String(artifacts.length), delta: a.delta, Icon: CubeIcon, spark: a.spark.length ? a.spark : [0, artifacts.length] },
      { label: 'Reviews', value: String(reviews.length), delta: r.delta, Icon: CheckBadgeIcon, spark: r.spark.length ? r.spark : [0, reviews.length] },
    ];
  }, [projects, sessions, artifacts, reviews, projectDaily, sessionDaily, artifactDaily, reviewDaily, half]);

  const usage = useMemo(
    () =>
      [
        { label: 'Artifacts', value: artifacts.length, color: 'var(--brand-blue, #0047ab)' },
        { label: 'Chat', value: rooms.length, color: 'var(--brand-yellow, #f5d90a)' },
        { label: 'Tickets', value: tickets.length, color: 'var(--success, #16a34a)' },
        { label: 'Sessions', value: sessions.length, color: 'var(--brand-red, #c0392b)' },
        { label: 'Reviews', value: reviews.length, color: 'var(--warning, #d97706)' },
      ] as Slice[],
    [artifacts, rooms, tickets, sessions, reviews],
  );
  const usageMax = Math.max(...usage.map((u) => u.value), 1);

  const sessionStatus = useMemo(() => {
    const counts = countMap(sessions.map((s) => (s.status || 'active').toLowerCase()));
    const order = ['active', 'idle', 'completed', 'archived'];
    const slices: Slice[] = order
      .filter((k) => (counts.get(k) ?? 0) > 0 || sessions.length === 0)
      .map((k) => ({
        label: k.charAt(0).toUpperCase() + k.slice(1),
        value: counts.get(k) ?? 0,
        color: SESSION_STATUS_COLORS[k] ?? 'var(--text-muted, #94a3b8)',
      }));
    // include unknown statuses
    for (const [k, v] of counts) {
      if (!order.includes(k) && v > 0) {
        slices.push({ label: k, value: v, color: 'var(--text-muted, #94a3b8)' });
      }
    }
    if (slices.every((s) => s.value === 0) && sessions.length === 0) {
      return order.map((k) => ({
        label: k.charAt(0).toUpperCase() + k.slice(1),
        value: 0,
        color: SESSION_STATUS_COLORS[k],
      }));
    }
    return slices.filter((s) => s.value > 0).length ? slices.filter((s) => s.value > 0) : slices;
  }, [sessions]);

  const artifactKinds = useMemo(() => {
    const counts = countMap(artifacts.map((a) => String(a.kind || 'other').toLowerCase()));
    const slices: Slice[] = [...counts.entries()]
      .sort((a, b) => b[1] - a[1])
      .map(([k, v]) => ({
        label: k.charAt(0).toUpperCase() + k.slice(1),
        value: v,
        color: KIND_COLORS[k] ?? 'var(--text-muted, #94a3b8)',
      }));
    return slices.length
      ? slices
      : [{ label: 'None', value: 0, color: 'var(--text-muted, #94a3b8)' }];
  }, [artifacts]);

  const ticketPipeline = useMemo(() => {
    const statuses = tickets.map((t) => (t.status || 'open').toLowerCase());
    return TICKET_STATUS_META.map((meta) => ({
      label: meta.label,
      value: statuses.filter((s) => meta.match.includes(s)).length,
      color: meta.color,
    }));
  }, [tickets]);

  const stacked = useMemo(() => weekBuckets(sessions, artifacts, rooms, tickets, 4), [sessions, artifacts, rooms, tickets]);

  const heatmap = useMemo(() => {
    const stamps = [
      ...sessions.map((s) => s.inserted_at),
      ...artifacts.map((a) => a.inserted_at),
      ...rooms.map((r) => r.inserted_at),
      ...reviews.map((r) => r.inserted_at),
      ...tickets.map((t) => t.inserted_at),
      ...projects.map((p) => p.inserted_at),
    ];
    return heatmapFromTimestamps(stamps);
  }, [sessions, artifacts, rooms, reviews, tickets, projects]);

  const feed = useMemo(() => {
    const items: FeedItem[] = [];
    for (const a of artifacts) {
      const at = parseAt(a.inserted_at) ?? parseAt(a.updated_at);
      if (at == null) continue;
      items.push({ who: 'Workspace', action: 'created artifact', target: a.title || a.kind || a.id, time: relativeTime(at), at });
    }
    for (const s of sessions) {
      const at = parseAt(s.updated_at) ?? parseAt(s.inserted_at);
      if (at == null) continue;
      items.push({ who: 'Workspace', action: 'session', target: s.title || s.id, time: relativeTime(at), at });
    }
    for (const r of reviews) {
      const at = parseAt(r.updated_at) ?? parseAt(r.inserted_at);
      if (at == null) continue;
      items.push({
        who: r.reviewer_persona || 'Reviewer',
        action: 'review',
        target: r.title || r.status || r.id,
        time: relativeTime(at),
        at,
      });
    }
    for (const t of tickets) {
      const at = parseAt(t.updated_at) ?? parseAt(t.inserted_at);
      if (at == null) continue;
      items.push({
        who: t.assignee || t.reporter || 'Team',
        action: `${t.status || 'ticket'}`,
        target: t.title || t.id,
        time: relativeTime(at),
        at,
      });
    }
    for (const p of projects) {
      const at = parseAt(p.updated_at) ?? parseAt(p.inserted_at);
      if (at == null) continue;
      items.push({ who: 'System', action: 'project', target: p.name || p.slug || p.id, time: relativeTime(at), at });
    }
    return items.sort((a, b) => b.at - a.at).slice(0, 8);
  }, [artifacts, sessions, reviews, tickets, projects]);

  /** Surfaced as “notifications”: open reviews + blocked/in_review tickets */
  const notifications = useMemo(() => {
    const items: NotifItem[] = [];
    for (const r of reviews) {
      const st = (r.status || '').toLowerCase();
      if (st === 'completed') continue;
      const at = parseAt(r.updated_at) ?? parseAt(r.inserted_at) ?? 0;
      items.push({
        type: 'review',
        title: 'Review open',
        body: r.title || r.summary || `Review ${r.id.slice(0, 8)}`,
        time: at ? relativeTime(at) : '',
        unread: st === 'open' || st === 'in_progress',
        Icon: CheckBadgeIcon,
        at,
      });
    }
    for (const t of tickets) {
      const st = (t.status || '').toLowerCase();
      if (!['blocked', 'in_review'].includes(st)) continue;
      const at = parseAt(t.updated_at) ?? parseAt(t.inserted_at) ?? 0;
      items.push({
        type: 'ticket',
        title: st === 'blocked' ? 'Ticket blocked' : 'Ticket in review',
        body: t.title || t.id,
        time: at ? relativeTime(at) : '',
        unread: true,
        Icon: BellIcon,
        at,
      });
    }
    return items.sort((a, b) => b.at - a.at).slice(0, 6);
  }, [reviews, tickets]);

  const sessionTotal = sessions.length;
  const artifactTotal = artifacts.length;
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

        {/* KPI cards */}
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
                {sessionDaily.labels.map((lab, i) => (
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
              <span className="dash-badge">{notifications.filter((n) => n.unread).length} open</span>
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
              labels={sessionDaily.labels}
              series={[
                { key: 'Sessions', data: sessionDaily.counts, color: 'var(--brand-red, #c0392b)' },
                { key: 'Artifacts', data: artifactDaily.counts, color: 'var(--brand-blue, #0047ab)' },
                { key: 'Chat', data: roomDaily.counts, color: 'var(--brand-yellow, #f5d90a)' },
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
              centerValue={String(sessionTotal)}
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
              centerValue={String(artifactTotal)}
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
          Metrics derived from live project, session, artifact, review, ticket, and chat-room lists
          {busy ? ' (loading…)' : ''}. Time series use <code>inserted_at</code> buckets; attention list is open reviews + blocked/in-review tickets.
        </p>
      </div>
    </div>
  );
}
