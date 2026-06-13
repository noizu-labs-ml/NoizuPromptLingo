import { fetchChatRooms } from "../../lib/api";

export const dynamic = "force-dynamic";

export default async function ChatPage() {
  let data = null;
  try { data = await fetchChatRooms(); } catch {}
  const rooms = data?.rooms ?? [];

  return (
    <div>
      <h1 style={{ fontSize: 22, fontWeight: 600, marginBottom: 24, letterSpacing: "-0.02em" }}>Chat Rooms</h1>
      <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
        {rooms.map(r => (
          <div key={r.id} style={{ background: "var(--bg-1)", border: "1px solid var(--border)", borderRadius: "var(--radius-md)", padding: 16, display: "flex", alignItems: "center", gap: 12 }}>
            <div style={{ width: 36, height: 36, borderRadius: "var(--radius-sm)", background: "var(--accent-dim)", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 16, flexShrink: 0 }}>▬</div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 14, fontWeight: 500 }}>#{r.name || r.slug}</div>
              {r.topic && <div style={{ fontSize: 12, color: "var(--text-2)" }}>{r.topic}</div>}
            </div>
            <span style={{ fontSize: 11, color: "var(--text-3)" }}>{timeAgo(r.created_at)}</span>
          </div>
        ))}
        {rooms.length === 0 && (
          <div style={{ padding: 40, textAlign: "center", color: "var(--text-3)", fontSize: 14 }}>No chat rooms. Create one via Chat.CreateRoom MCP tool.</div>
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
