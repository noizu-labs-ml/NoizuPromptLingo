import { fetchReviews } from "../../lib/api";

export const dynamic = "force-dynamic";

const STATUS_STYLE = {
  open: { bg: "var(--blue-dim)", color: "var(--blue)" },
  in_progress: { bg: "var(--yellow-dim)", color: "var(--yellow)" },
  completed: { bg: "var(--green-dim)", color: "var(--green)" },
};

export default async function ReviewsPage() {
  let data = null;
  try { data = await fetchReviews(); } catch {}
  const reviews = data?.reviews ?? [];

  return (
    <div>
      <h1 style={{ fontSize: 22, fontWeight: 600, marginBottom: 24, letterSpacing: "-0.02em" }}>Reviews</h1>
      <div style={{ background: "var(--bg-1)", border: "1px solid var(--border)", borderRadius: "var(--radius-lg)", overflow: "hidden" }}>
        {reviews.map(r => {
          const s = STATUS_STYLE[r.status] || { bg: "var(--bg-3)", color: "var(--text-2)" };
          return (
            <div key={r.id} style={{ display: "flex", alignItems: "center", gap: 12, padding: "12px 20px", borderBottom: "1px solid var(--border-subtle)" }}>
              <div style={{ width: 36, height: 36, borderRadius: "var(--radius-sm)", background: s.bg, color: s.color, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 16, flexShrink: 0 }}>◎</div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 14, fontWeight: 500 }}>{r.title || `Review ${r.id.slice(0,8)}`}</div>
                <div style={{ fontSize: 12, color: "var(--text-2)" }}>by {r.reviewer || "unassigned"}</div>
              </div>
              <span style={{ fontSize: 11, padding: "2px 8px", borderRadius: 10, background: s.bg, color: s.color }}>{r.status}</span>
              {r.verdict && <span style={{ fontSize: 11, color: r.verdict === "approved" ? "var(--green)" : "var(--red)" }}>{r.verdict}</span>}
              <span style={{ fontSize: 11, color: "var(--text-3)" }}>{timeAgo(r.at)}</span>
            </div>
          );
        })}
        {reviews.length === 0 && (
          <div style={{ padding: 40, textAlign: "center", color: "var(--text-3)", fontSize: 14 }}>No reviews. Create one via Review.Create or Asset.RequestReview MCP tools.</div>
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
