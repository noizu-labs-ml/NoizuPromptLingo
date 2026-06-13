import Link from "next/link";
import { fetchTickets } from "../../lib/api";

export const dynamic = "force-dynamic";

const PRIORITY_COLORS = { critical: "#ef4444", high: "#f97316", medium: "#eab308", low: "#22c55e" };

export default async function TicketsPage() {
  let data = null;
  try { data = await fetchTickets(); } catch {}
  const tickets = data?.tickets ?? [];

  return (
    <div>
      <h1 style={{ fontSize: 22, fontWeight: 600, marginBottom: 24, letterSpacing: "-0.02em" }}>Tickets</h1>
      <div style={{ background: "var(--bg-1)", border: "1px solid var(--border)", borderRadius: "var(--radius-lg)", overflow: "hidden" }}>
        <div style={{ display: "grid", gridTemplateColumns: "2fr 100px 100px 100px 100px", gap: 8, padding: "10px 20px", borderBottom: "2px solid var(--border)", fontSize: 11, fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.05em", color: "var(--text-3)" }}>
          <span>Ticket</span><span>Type</span><span>Status</span><span>Priority</span><span>Updated</span>
        </div>
        {tickets.map(t => (
          <div key={t.id} style={{ display: "grid", gridTemplateColumns: "2fr 100px 100px 100px 100px", gap: 8, padding: "12px 20px", borderBottom: "1px solid var(--border-subtle)", alignItems: "center", fontSize: 13 }}>
            <div>
              <div style={{ fontWeight: 500 }}>{t.title}</div>
              <div style={{ fontSize: 11, color: "var(--text-3)" }}>{t.assignee || "unassigned"}</div>
            </div>
            <span style={{ fontSize: 12, color: "var(--text-2)", fontFamily: "var(--font-mono)" }}>{t.ticket_type}</span>
            <span style={{ fontSize: 11, padding: "2px 8px", borderRadius: 10, background: "var(--bg-3)", color: "var(--text-2)", width: "fit-content" }}>{t.status}</span>
            <span style={{ display: "flex", alignItems: "center", gap: 4, fontSize: 12, color: "var(--text-2)" }}>
              {t.priority && <span style={{ width: 6, height: 6, borderRadius: "50%", background: PRIORITY_COLORS[t.priority] || "var(--text-3)" }} />}
              {t.priority || "—"}
            </span>
            <span style={{ fontSize: 11, color: "var(--text-3)" }}>{timeAgo(t.updated_at)}</span>
          </div>
        ))}
        {tickets.length === 0 && (
          <div style={{ padding: 40, textAlign: "center", color: "var(--text-3)", fontSize: 14 }}>No tickets. Create one via Ticket.Create MCP tool.</div>
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
