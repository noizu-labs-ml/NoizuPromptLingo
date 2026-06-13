import { fetchStats, fetchActivity } from "../../lib/api";
import styles from "./dashboard.module.css";

export const dynamic = "force-dynamic";

export default async function DashboardPage() {
  let stats = null;
  let activity = null;
  try {
    [stats, activity] = await Promise.all([fetchStats(), fetchActivity()]);
  } catch (e) {
    // backend may not be running
  }

  const cards = stats ? [
    { label: "Active Sessions", value: stats.sessions?.active ?? 0, color: "blue" },
    { label: "Open Tickets", value: stats.tickets?.by_status?.open ?? 0, color: "orange" },
    { label: "Assets", value: Object.values(stats.assets?.by_status ?? {}).reduce((a,b) => a+b, 0), color: "accent",
      sub: `${stats.assets?.by_status?.published ?? 0} published` },
    { label: "Pending Reviews", value: stats.reviews?.by_status?.open ?? 0, color: "yellow" },
  ] : [];

  return (
    <div>
      <div className={styles.header}>
        <h1 className={styles.title}>Dashboard</h1>
      </div>

      {stats ? (
        <>
          <div className={styles.statsGrid}>
            {cards.map(c => (
              <div key={c.label} className={styles.statCard}>
                <div className={styles.statValue} data-color={c.color}>{c.value}</div>
                <div className={styles.statLabel}>{c.label}</div>
                {c.sub && <div className={styles.statSub}>{c.sub}</div>}
              </div>
            ))}
          </div>

          <div className={styles.panels}>
            <div className={styles.panel}>
              <h3 className={styles.panelTitle}>Recent Activity</h3>
              <div className={styles.feedList}>
                {(activity?.events ?? []).map((ev, i) => (
                  <div key={i} className={styles.feedItem}>
                    <span className={`${styles.domainTag} ${styles[`domain_${ev.domain}`]}`}>{ev.domain}</span>
                    <span className={styles.feedText}>
                      {ev.type === "ticket" && `${ev.title} — ${ev.status}`}
                      {ev.type === "asset" && `${ev.title} (${ev.asset_type}) — ${ev.status}`}
                      {ev.type === "review" && `Review by ${ev.reviewer} — ${ev.status}`}
                    </span>
                    <span className={styles.feedTime}>{timeAgo(ev.at)}</span>
                  </div>
                ))}
                {(activity?.events ?? []).length === 0 && (
                  <div className={styles.empty}>No recent activity</div>
                )}
              </div>
            </div>

            <div className={styles.panel}>
              <h3 className={styles.panelTitle}>Stats Breakdown</h3>
              <div className={styles.breakdownList}>
                {stats.assets?.by_type && Object.entries(stats.assets.by_type).map(([k, v]) => (
                  <div key={k} className={styles.breakdownRow}>
                    <span className={styles.breakdownLabel}>{k}</span>
                    <span className={styles.breakdownValue}>{v}</span>
                  </div>
                ))}
                <div className={styles.breakdownSep} />
                <div className={styles.breakdownRow}>
                  <span className={styles.breakdownLabel}>Artifacts</span>
                  <span className={styles.breakdownValue}>
                    {Object.values(stats.artifacts?.by_kind ?? {}).reduce((a,b) => a+b, 0)}
                  </span>
                </div>
                <div className={styles.breakdownRow}>
                  <span className={styles.breakdownLabel}>Projects</span>
                  <span className={styles.breakdownValue}>{stats.projects?.total ?? 0}</span>
                </div>
              </div>
            </div>
          </div>
        </>
      ) : (
        <div className={styles.empty}>
          Backend not available. Start the Elixir server to see live data.
        </div>
      )}
    </div>
  );
}

function timeAgo(dt) {
  if (!dt) return "";
  const diff = Date.now() - new Date(dt).getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 1) return "just now";
  if (mins < 60) return `${mins}m ago`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `${hrs}h ago`;
  return `${Math.floor(hrs / 24)}d ago`;
}
