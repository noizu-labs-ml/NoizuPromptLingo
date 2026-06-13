import Link from "next/link";
import { fetchProjects } from "../../lib/api";

export const dynamic = "force-dynamic";

export default async function ProjectsPage() {
  let data = null;
  try { data = await fetchProjects(); } catch {}
  const projects = data?.projects ?? [];

  return (
    <div>
      <h1 style={{ fontSize: 22, fontWeight: 600, marginBottom: 24, letterSpacing: "-0.02em" }}>Projects</h1>
      <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(300px, 1fr))", gap: 16 }}>
        {projects.map(p => (
          <div key={p.id} style={{ background: "var(--bg-1)", border: "1px solid var(--border)", borderRadius: "var(--radius-lg)", padding: 20 }}>
            <div style={{ fontSize: 16, fontWeight: 600, marginBottom: 4 }}>{p.name}</div>
            <div style={{ fontSize: 12, color: "var(--text-3)", fontFamily: "var(--font-mono)", marginBottom: 8 }}>{p.slug}</div>
            {p.description && <div style={{ fontSize: 13, color: "var(--text-2)", marginBottom: 12 }}>{p.description}</div>}
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
              <span style={{ fontSize: 11, padding: "2px 8px", borderRadius: 10, background: p.status === "active" ? "var(--green-dim)" : "var(--bg-3)", color: p.status === "active" ? "var(--green)" : "var(--text-3)" }}>{p.status}</span>
              <span style={{ fontSize: 11, color: "var(--text-3)" }}>{timeAgo(p.created_at)}</span>
            </div>
          </div>
        ))}
        {projects.length === 0 && (
          <div style={{ padding: 40, textAlign: "center", color: "var(--text-3)", fontSize: 14, gridColumn: "1 / -1" }}>No projects. Create one via Project.Create MCP tool.</div>
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
