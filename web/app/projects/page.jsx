"use client";
import { useState, useEffect, useCallback } from "react";
import { useProject } from "../../components/project-context";

const btnBase = { border: "none", borderRadius: "var(--radius-sm)", padding: "6px 14px", cursor: "pointer", fontSize: 13, fontWeight: 500, fontFamily: "var(--font)" };
const primaryBtn = { ...btnBase, background: "var(--accent)", color: "white" };
const secondaryBtn = { ...btnBase, background: "var(--bg-3)", color: "var(--text-1)" };
const dangerBtn = { ...btnBase, background: "var(--red-dim)", color: "var(--red)" };
const inputStyle = { background: "var(--bg-2)", border: "1px solid var(--border)", borderRadius: "var(--radius-sm)", padding: "8px 12px", color: "var(--text-0)", fontSize: 13, fontFamily: "var(--font)", width: "100%", outline: "none", boxSizing: "border-box" };
const textareaStyle = { ...inputStyle, resize: "vertical", minHeight: 80 };
const overlayStyle = { position: "fixed", inset: 0, background: "rgba(0,0,0,0.5)", display: "flex", alignItems: "center", justifyContent: "center", zIndex: 50 };
const cardStyle = { background: "var(--bg-1)", border: "1px solid var(--border)", borderRadius: "var(--radius-lg)", padding: 24, width: "100%", maxWidth: 480 };
const labelStyle = { display: "block", fontSize: 12, fontWeight: 500, color: "var(--text-2)", marginBottom: 4 };
const fieldGroupStyle = { marginBottom: 16 };

function toSlug(name) {
  return name.toLowerCase().replace(/\s+/g, "-").replace(/[^a-z0-9-]/g, "");
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

function ProjectModal({ project, onClose, onSaved }) {
  const isEdit = !!project;
  const [name, setName] = useState(project?.name ?? "");
  const [slug, setSlug] = useState(project?.slug ?? "");
  const [description, setDescription] = useState(project?.description ?? "");
  const [slugTouched, setSlugTouched] = useState(isEdit);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState(null);

  function handleNameChange(v) {
    setName(v);
    if (!slugTouched) setSlug(toSlug(v));
  }

  function handleSlugChange(v) {
    setSlugTouched(true);
    setSlug(v);
  }

  async function handleSubmit(e) {
    e.preventDefault();
    if (!name.trim()) return;
    setSaving(true);
    setError(null);
    try {
      const method = isEdit ? "PUT" : "POST";
      const url = isEdit ? `/api/proxy/projects/${project.id}` : "/api/proxy/projects";
      const res = await fetch(url, {
        method,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ name, slug, description }),
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || "Request failed");
      onSaved();
    } catch (err) {
      setError(err.message);
    } finally {
      setSaving(false);
    }
  }

  return (
    <div style={overlayStyle} onClick={onClose}>
      <div style={cardStyle} onClick={e => e.stopPropagation()}>
        <div style={{ fontSize: 16, fontWeight: 600, marginBottom: 20 }}>{isEdit ? "Edit Project" : "Create Project"}</div>
        <form onSubmit={handleSubmit}>
          <div style={fieldGroupStyle}>
            <label style={labelStyle}>Name *</label>
            <input style={inputStyle} value={name} onChange={e => handleNameChange(e.target.value)} placeholder="My Project" autoFocus />
          </div>
          <div style={fieldGroupStyle}>
            <label style={labelStyle}>Slug</label>
            <input style={inputStyle} value={slug} onChange={e => handleSlugChange(e.target.value)} placeholder="my-project" />
          </div>
          <div style={fieldGroupStyle}>
            <label style={labelStyle}>Description</label>
            <textarea style={textareaStyle} value={description} onChange={e => setDescription(e.target.value)} placeholder="Optional description" />
          </div>
          {error && <div style={{ fontSize: 12, color: "var(--red)", marginBottom: 12 }}>{error}</div>}
          <div style={{ display: "flex", gap: 8, justifyContent: "flex-end" }}>
            <button type="button" style={secondaryBtn} onClick={onClose}>Cancel</button>
            <button type="submit" style={primaryBtn} disabled={saving || !name.trim()}>{saving ? "Saving…" : isEdit ? "Save" : "Create"}</button>
          </div>
        </form>
      </div>
    </div>
  );
}

function ArchiveConfirm({ project, onClose, onConfirm }) {
  const [loading, setLoading] = useState(false);

  async function handleArchive() {
    setLoading(true);
    await onConfirm();
    setLoading(false);
  }

  return (
    <div style={overlayStyle} onClick={onClose}>
      <div style={{ ...cardStyle, maxWidth: 380 }} onClick={e => e.stopPropagation()}>
        <div style={{ fontSize: 16, fontWeight: 600, marginBottom: 8 }}>Archive Project</div>
        <div style={{ fontSize: 13, color: "var(--text-2)", marginBottom: 20 }}>Archive <strong>{project.name}</strong>? It will no longer appear in active listings.</div>
        <div style={{ display: "flex", gap: 8, justifyContent: "flex-end" }}>
          <button style={secondaryBtn} onClick={onClose}>Cancel</button>
          <button style={dangerBtn} onClick={handleArchive} disabled={loading}>{loading ? "Archiving…" : "Archive"}</button>
        </div>
      </div>
    </div>
  );
}

export default function ProjectsPage() {
  const [projects, setProjects] = useState([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState(null);
  const [archiveTarget, setArchiveTarget] = useState(null);
  const { refresh } = useProject();

  const fetchProjects = useCallback(async () => {
    try {
      const res = await fetch("/api/proxy/projects");
      const data = await res.json();
      setProjects(data?.projects ?? []);
    } catch {}
    setLoading(false);
  }, []);

  useEffect(() => { fetchProjects(); }, [fetchProjects]);

  async function handleSaved() {
    setModal(null);
    await fetchProjects();
    refresh();
  }

  async function handleArchive(project) {
    try {
      await fetch(`/api/proxy/projects/${project.id}`, { method: "DELETE" });
    } catch {}
    setArchiveTarget(null);
    await fetchProjects();
    refresh();
  }

  return (
    <div>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 24 }}>
        <h1 style={{ fontSize: 22, fontWeight: 600, letterSpacing: "-0.02em", margin: 0 }}>Projects</h1>
        <button style={primaryBtn} onClick={() => setModal({ type: "create" })}>Create Project</button>
      </div>

      {loading ? (
        <div style={{ color: "var(--text-3)", fontSize: 14 }}>Loading…</div>
      ) : (
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
              <div style={{ display: "flex", gap: 6, marginTop: 12 }}>
                <button style={secondaryBtn} onClick={() => setModal({ type: "edit", project: p })}>Edit</button>
                <button style={dangerBtn} onClick={() => setArchiveTarget(p)}>Archive</button>
              </div>
            </div>
          ))}
          {projects.length === 0 && (
            <div style={{ padding: 40, textAlign: "center", color: "var(--text-3)", fontSize: 14, gridColumn: "1 / -1" }}>No projects yet. Create one to get started.</div>
          )}
        </div>
      )}

      {modal?.type === "create" && (
        <ProjectModal onClose={() => setModal(null)} onSaved={handleSaved} />
      )}
      {modal?.type === "edit" && (
        <ProjectModal project={modal.project} onClose={() => setModal(null)} onSaved={handleSaved} />
      )}
      {archiveTarget && (
        <ArchiveConfirm project={archiveTarget} onClose={() => setArchiveTarget(null)} onConfirm={() => handleArchive(archiveTarget)} />
      )}
    </div>
  );
}
