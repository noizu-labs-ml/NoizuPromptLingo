import Link from "next/link";
import { fetchAssets } from "../../lib/api";
import styles from "./assets.module.css";

export const dynamic = "force-dynamic";

const TYPE_ICONS = {
  image: "🖼", video: "🎬", music: "♪", voice: "🎙", component: "▣",
  html: "◇", diagram: "◇", document: "📄", svg: "◇", style_guide: "🎨",
};

const STATUS_COLORS = {
  draft: "draft", generating: "generating", review: "review",
  published: "published", archived: "archived",
};

export default async function AssetsPage() {
  let data = null;
  try { data = await fetchAssets(); } catch {}

  const assets = data?.assets ?? [];

  return (
    <div>
      <div className={styles.header}>
        <h1 className={styles.title}>Assets</h1>
        <span className={styles.count}>{assets.length} assets</span>
      </div>

      <div className={styles.table}>
        <div className={styles.tableHeader}>
          <span>Asset</span>
          <span>Type</span>
          <span>Status</span>
          <span>Quality</span>
          <span>Updated</span>
        </div>
        {assets.map(a => (
          <Link key={a.id} href={`/assets/${a.id}`} className={styles.row}>
            <div className={styles.titleCell}>
              <span className={styles.icon}>{TYPE_ICONS[a.asset_type] || "◇"}</span>
              <div>
                <div className={styles.assetTitle}>{a.title}</div>
                <div className={styles.slug}>{a.slug}</div>
              </div>
            </div>
            <span className={styles.typeLabel}>{a.asset_type}</span>
            <span className={`${styles.badge} ${styles[STATUS_COLORS[a.status]]}`}>{a.status}</span>
            <span className={styles.quality}>{a.quality || "—"}</span>
            <span className={styles.time}>{timeAgo(a.updated_at)}</span>
          </Link>
        ))}
        {assets.length === 0 && (
          <div className={styles.empty}>No assets yet. Create one via the MCP tools.</div>
        )}
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
