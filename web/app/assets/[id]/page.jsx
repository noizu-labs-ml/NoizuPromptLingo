import { fetchAsset, fetchAssetHistory } from "../../../lib/api";
import styles from "./detail.module.css";

export const dynamic = "force-dynamic";

export default async function AssetDetailPage({ params }) {
  const { id } = await params;
  let data = null, history = null;
  try {
    [data, history] = await Promise.all([fetchAsset(id), fetchAssetHistory(id)]);
  } catch {}

  if (!data?.asset) {
    return <div className={styles.empty}>Asset not found</div>;
  }

  const { asset, outputs } = data;
  const events = history?.events ?? [];

  return (
    <div>
      <h1 className={styles.title}>{asset.title}</h1>
      <div className={styles.slug}>{asset.slug}</div>

      <div className={styles.metaGrid}>
        <div className={styles.metaItem}>
          <span className={styles.metaLabel}>Type</span>
          <span>{asset.asset_type}</span>
        </div>
        <div className={styles.metaItem}>
          <span className={styles.metaLabel}>Status</span>
          <span className={styles.badge} data-status={asset.status}>{asset.status}</span>
        </div>
        <div className={styles.metaItem}>
          <span className={styles.metaLabel}>Quality</span>
          <span>{asset.quality || "—"}</span>
        </div>
        <div className={styles.metaItem}>
          <span className={styles.metaLabel}>Tags</span>
          <span>{(asset.tags || []).join(", ") || "—"}</span>
        </div>
      </div>

      <div className={styles.section}>
        <h2 className={styles.sectionTitle}>Outputs ({outputs.length})</h2>
        {outputs.length > 0 ? (
          <div className={styles.outputList}>
            {outputs.map(o => (
              <div key={o.id} className={`${styles.outputCard} ${o.id === asset.active_output_id ? styles.activeOutput : ""}`}>
                <div className={styles.outputHeader}>
                  <span className={styles.variant}>Variant #{o.variant_number}</span>
                  {o.id === asset.active_output_id && <span className={styles.activeBadge}>active</span>}
                  <span className={styles.outputStatus} data-status={o.status}>{o.status}</span>
                </div>
                <div className={styles.outputMeta}>
                  {o.provider && <span>Provider: {o.provider}</span>}
                  {o.model && <span>Model: {o.model}</span>}
                  {o.eval_score != null && <span>Score: {o.eval_score.toFixed(2)}</span>}
                  <span>Eval: {o.eval_status}</span>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className={styles.empty}>No outputs generated yet</div>
        )}
      </div>

      <div className={styles.section}>
        <h2 className={styles.sectionTitle}>History</h2>
        <div className={styles.historyList}>
          {events.map(ev => (
            <div key={ev.id} className={styles.historyItem}>
              <span className={styles.historyAction}>{ev.action}</span>
              <span className={styles.historyActor}>{ev.actor || "system"}</span>
              <span className={styles.historyTime}>{timeAgo(ev.at)}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

function timeAgo(dt) {
  if (!dt) return "";
  const diff = Date.now() - new Date(dt).getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 60) return `${mins}m ago`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `${hrs}h ago`;
  return `${Math.floor(hrs / 24)}d ago`;
}
