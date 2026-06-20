'use client';

import { useOrg } from '@/context/org';
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

// ─── Placeholder data (wire up to the API later) ──────────────────────────
const KPIS: { label: string; value: string; delta: number; Icon: HeroIcon; spark: number[] }[] = [
  { label: 'Projects', value: '12', delta: 8, Icon: Squares2X2Icon, spark: [4, 5, 5, 6, 7, 7, 9, 10, 11, 12] },
  { label: 'Sessions', value: '47', delta: 12, Icon: ClockIcon, spark: [20, 22, 19, 26, 24, 31, 29, 35, 41, 47] },
  { label: 'Artifacts', value: '318', delta: -3, Icon: CubeIcon, spark: [330, 327, 331, 322, 319, 325, 321, 318, 316, 318] },
  { label: 'Reviews', value: '9', delta: 25, Icon: CheckBadgeIcon, spark: [3, 4, 4, 5, 6, 6, 7, 8, 8, 9] },
];

const ACTIVITY = [12, 18, 14, 22, 19, 27, 24, 31, 28, 35, 30, 38, 42, 39];
const ACTIVITY_DAYS = ['', '', '', '', '', '', '', '', '', '', '', '', '', ''];

const USAGE: { label: string; value: number; color: string }[] = [
  { label: 'Artifacts', value: 318, color: 'var(--brand-blue, #0047ab)' },
  { label: 'Chat', value: 126, color: 'var(--brand-yellow, #f5d90a)' },
  { label: 'Tickets', value: 54, color: 'var(--success, #16a34a)' },
  { label: 'Sessions', value: 47, color: 'var(--brand-red, #c0392b)' },
  { label: 'Reviews', value: 9, color: 'var(--warning, #d97706)' },
];

const NOTIFICATIONS: { type: string; title: string; body: string; time: string; unread: boolean; Icon: HeroIcon }[] = [
  { type: 'review', title: 'Review requested', body: 'PR #128 “auth refactor” awaits your review', time: '2m', unread: true, Icon: CheckBadgeIcon },
  { type: 'chat', title: 'New mention', body: 'Ava mentioned you in #design-sync', time: '18m', unread: true, Icon: ChatBubbleLeftRightIcon },
  { type: 'artifact', title: 'Artifact published', body: 'spec-v3.md was published to Artifacts', time: '1h', unread: false, Icon: CubeIcon },
  { type: 'session', title: 'Session resumed', body: 'Onboarding flow session reopened', time: '3h', unread: false, Icon: ClockIcon },
];

const FEED: { who: string; action: string; target: string; time: string }[] = [
  { who: 'Ava Chen', action: 'created artifact', target: 'spec-v3.md', time: 'just now' },
  { who: 'Marco Diaz', action: 'opened review on', target: 'auth-refactor', time: '12m ago' },
  { who: 'You', action: 'resumed session', target: 'onboarding-flow', time: '1h ago' },
  { who: 'Priya N.', action: 'closed ticket', target: 'NPL-204', time: '2h ago' },
  { who: 'System', action: 'archived project', target: 'legacy-sandbox', time: 'yesterday' },
];

// ─── Tiny dependency-free SVG charts ──────────────────────────────────────
function linePath(data: number[], w: number, h: number, pad = 4) {
  const max = Math.max(...data);
  const min = Math.min(...data);
  const range = max - min || 1;
  const stepX = (w - pad * 2) / (data.length - 1);
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
  return (
    <svg className="kpi-card__spark" viewBox={`0 0 ${w} ${h}`} preserveAspectRatio="none" aria-hidden="true">
      <path d={linePath(data, w, h)} fill="none" stroke={stroke} strokeWidth={2} strokeLinejoin="round" strokeLinecap="round" />
    </svg>
  );
}

function AreaChart({ data }: { data: number[] }) {
  const w = 640;
  const h = 200;
  const pad = 6;
  const line = linePath(data, w, h, pad);
  const stepX = (w - pad * 2) / (data.length - 1);
  const lastX = pad + (data.length - 1) * stepX;
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

export default function OrgDashboard() {
  const { currentOrg } = useOrg();
  const usageMax = Math.max(...USAGE.map((u) => u.value));

  return (
    <div className="content">
      <div className="dash">
      <div className="dash-header">
        <div>
          <h1 className="dash-title">{currentOrg?.name || 'Organization'} Dashboard</h1>
          <p className="dash-sub">Overview of activity across your workspace.</p>
        </div>
        <div className="dash-range" role="group" aria-label="Date range">
          <button className="dash-range__btn">7d</button>
          <button className="dash-range__btn is-active">14d</button>
          <button className="dash-range__btn">30d</button>
        </div>
      </div>

      {/* KPI cards */}
      <div className="dash-kpis">
        {KPIS.map((k) => {
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

      {/* Charts + side panels */}
      <div className="dash-grid">
        <section className="dash-panel">
          <div className="dash-panel__head">
            <h2 className="dash-panel__title">Activity</h2>
            <span className="dash-panel__hint">Last 14 days</span>
          </div>
          <div className="chart">
            <AreaChart data={ACTIVITY} />
            <div className="chart-axis">
              {ACTIVITY_DAYS.map((_, i) => (
                <span key={i} />
              ))}
            </div>
          </div>
        </section>

        <section className="dash-panel">
          <div className="dash-panel__head">
            <h2 className="dash-panel__title">
              <BellIcon className="dash-panel__title-icon" />
              Notifications
            </h2>
            <span className="dash-badge">{NOTIFICATIONS.filter((n) => n.unread).length} new</span>
          </div>
          <ul className="notif-list">
            {NOTIFICATIONS.map((n, i) => (
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
        </section>

        <section className="dash-panel">
          <div className="dash-panel__head">
            <h2 className="dash-panel__title">Usage by domain</h2>
            <span className="dash-panel__hint">this month</span>
          </div>
          <div className="bars">
            {USAGE.map((u) => (
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
            <a className="dash-panel__action" href="#">
              View all
            </a>
          </div>
          <ul className="feed">
            {FEED.map((f, i) => (
              <li key={i} className="feed__item">
                <span className="feed__avatar">{f.who.charAt(0)}</span>
                <span className="feed__text">
                  <strong>{f.who}</strong> {f.action} <span className="feed__target">{f.target}</span>
                </span>
                <span className="feed__time">{f.time}</span>
              </li>
            ))}
          </ul>
        </section>
      </div>

      <p className="dash-note">Placeholder data — charts and notifications will be wired to live APIs.</p>
      </div>
    </div>
  );
}
