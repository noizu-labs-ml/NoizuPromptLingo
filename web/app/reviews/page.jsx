"use client";
import { useState, useEffect, useCallback } from "react";
import { useProject } from "../../components/project-context";

const BTN = { background: "var(--accent)", color: "white", border: "none", borderRadius: "var(--radius-sm)", padding: "6px 14px", cursor: "pointer", fontSize: 13, fontWeight: 500, fontFamily: "var(--font)" };
const BTN_SEC = { background: "var(--bg-3)", color: "var(--text-1)", border: "none", borderRadius: "var(--radius-sm)", padding: "6px 14px", cursor: "pointer", fontSize: 13, fontWeight: 500, fontFamily: "var(--font)" };
const BTN_DANGER = { background: "var(--red-dim)", color: "var(--red)", border: "none", borderRadius: "var(--radius-sm)", padding: "6px 14px", cursor: "pointer", fontSize: 13, fontWeight: 500, fontFamily: "var(--font)" };
const INPUT = { background: "var(--bg-2)", border: "1px solid var(--border)", borderRadius: "var(--radius-sm)", padding: "8px 12px", color: "var(--text-0)", fontSize: 13, fontFamily: "var(--font)", width: "100%", outline: "none", boxSizing: "border-box" };
const SELECT = { background: "var(--bg-2)", border: "1px solid var(--border)", borderRadius: "var(--radius-sm)", padding: "8px 12px", color: "var(--text-0)", fontSize: 13, fontFamily: "var(--font)", width: "100%", outline: "none", boxSizing: "border-box" };
const OVERLAY = { position: "fixed", inset: 0, background: "rgba(0,0,0,0.5)", display: "flex", alignItems: "center", justifyContent: "center", zIndex: 50 };
const MODAL = { background: "var(--bg-1)", border: "1px solid var(--border)", borderRadius: "var(--radius-lg)", padding: 24, width: "100%", maxWidth: 480 };

const STATUS_STYLE = {
  open: { bg: "var(--blue-dim)", color: "var(--blue)" },
  in_progress: { bg: "var(--yellow-dim)", color: "var(--yellow)" },
  completed: { bg: "var(--green-dim)", color: "var(--green)" },
};

const VERDICT_STYLE = {
  approved: "var(--green)",
  changes_requested: "var(--yellow)",
  rejected: "var(--red)",
};

function timeAgo(dt) {
  if (!dt) return "";
  const diff = Date.now() - new Date(dt).getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 60) return `${mins}m ago`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `${hrs}h ago`;
  return `${Math.floor(hrs / 24)}d ago`;
}

const EMPTY_FORM = { artifact_id: "", revision_id: "", reviewer_persona: "", title: "", status: "open", summary: "", verdict: "" };

function ReviewModal({ review, projectId, onClose, onSaved }) {
  const editing = !!review;
  const [form, setForm] = useState(review ? {
    artifact_id: review.artifact_id || "",
    revision_id: review.revision_id || "",
    reviewer_persona: review.reviewer_persona || "",
    title: review.title || "",
    status: review.status || "open",
    summary: review.summary || "",
    verdict: review.verdict || "",
  } : EMPTY_FORM);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState(null);

  function set(k, v) { setForm(f => ({ ...f, [k]: v })); }

  async function submit(e) {
    e.preventDefault();
    setSaving(true);
    setError(null);
    try {
      const body = { ...form };
      if (!body.verdict) delete body.verdict;
      if (!editing && projectId) body.project_id = projectId;
      const res = await fetch(editing ? `/api/proxy/reviews/${review.id}` : "/api/proxy/reviews", {
        method: editing ? "PUT" : "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body),
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data?.error || "Save failed");
      onSaved();
    } catch (err) {
      setError(err.message);
      setSaving(false);
    }
  }

  return (
    <div style={OVERLAY} onClick={e => e.target === e.currentTarget && onClose()}>
      <div style={MODAL}>
        <div style={{ fontSize: 16, fontWeight: 600, marginBottom: 20 }}>{editing ? "Edit Review" : "Create Review"}</div>
        <form onSubmit={submit} style={{ display: "flex", flexDirection: "column", gap: 14 }}>
          <div>
            <label style={{ fontSize: 12, color: "var(--text-2)", display: "block", marginBottom: 6 }}>Title</label>
            <input style={INPUT} value={form.title} onChange={e => set("title", e.target.value)} placeholder="Review title" />
          </div>
          <div>
            <label style={{ fontSize: 12, color: "var(--text-2)", display: "block", marginBottom: 6 }}>Artifact ID *</label>
            <input style={INPUT} value={form.artifact_id} onChange={e => set("artifact_id", e.target.value)} placeholder="UUID" required />
          </div>
          <div>
            <label style={{ fontSize: 12, color: "var(--text-2)", display: "block", marginBottom: 6 }}>Revision ID *</label>
            <input style={INPUT} value={form.revision_id} onChange={e => set("revision_id", e.target.value)} placeholder="UUID" required />
          </div>
          <div>
            <label style={{ fontSize: 12, color: "var(--text-2)", display: "block", marginBottom: 6 }}>Reviewer Persona *</label>
            <input style={INPUT} value={form.reviewer_persona} onChange={e => set("reviewer_persona", e.target.value)} placeholder="persona-slug" required />
          </div>
          <div>
            <label style={{ fontSize: 12, color: "var(--text-2)", display: "block", marginBottom: 6 }}>Status</label>
            <select style={SELECT} value={form.status} onChange={e => set("status", e.target.value)}>
              <option value="open">Open</option>
              <option value="in_progress">In Progress</option>
              <option value="completed">Completed</option>
            </select>
          </div>
          {editing && (
            <div>
              <label style={{ fontSize: 12, color: "var(--text-2)", display: "block", marginBottom: 6 }}>Verdict</label>
              <select style={SELECT} value={form.verdict} onChange={e => set("verdict", e.target.value)}>
                <option value="">— none —</option>
                <option value="approved">Approved</option>
                <option value="changes_requested">Changes Requested</option>
                <option value="rejected">Rejected</option>
              </select>
            </div>
          )}
          <div>
            <label style={{ fontSize: 12, color: "var(--text-2)", display: "block", marginBottom: 6 }}>Summary</label>
            <textarea style={{ ...INPUT, resize: "vertical", minHeight: 72 }} value={form.summary} onChange={e => set("summary", e.target.value)} placeholder="Review notes…" />
          </div>
          {error && <div style={{ fontSize: 12, color: "var(--red)" }}>{error}</div>}
          <div style={{ display: "flex", gap: 8, justifyContent: "flex-end", marginTop: 4 }}>
            <button type="button" style={BTN_SEC} onClick={onClose}>Cancel</button>
            <button type="submit" style={BTN} disabled={saving}>{saving ? "Saving…" : (editing ? "Save" : "Create")}</button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default function ReviewsPage() {
  const { current } = useProject();
  const [reviews, setReviews] = useState([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState(null); // null | "create" | review object
  const [deleting, setDeleting] = useState(null);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const qs = current?.id ? `?project_id=${current.id}` : "";
      const res = await fetch(`/api/proxy/reviews${qs}`);
      const data = res.ok ? await res.json() : {};
      setReviews(data.reviews ?? []);
    } catch {
      setReviews([]);
    } finally {
      setLoading(false);
    }
  }, [current?.id]);

  useEffect(() => { load(); }, [load]);

  async function deleteReview(id) {
    if (!confirm("Delete this review?")) return;
    setDeleting(id);
    try {
      await fetch(`/api/proxy/reviews/${id}`, { method: "DELETE" });
      setReviews(r => r.filter(x => x.id !== id));
    } finally {
      setDeleting(null);
    }
  }

  return (
    <div>
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 24 }}>
        <h1 style={{ fontSize: 22, fontWeight: 600, letterSpacing: "-0.02em", margin: 0 }}>
          Reviews{current ? ` — ${current.name}` : ""}
        </h1>
        <button style={BTN} onClick={() => setModal("create")}>+ Create Review</button>
      </div>

      {loading ? (
        <div style={{ padding: 40, textAlign: "center", color: "var(--text-3)", fontSize: 14 }}>Loading…</div>
      ) : (
        <div style={{ background: "var(--bg-1)", border: "1px solid var(--border)", borderRadius: "var(--radius-lg)", overflow: "hidden" }}>
          {reviews.map(r => {
            const s = STATUS_STYLE[r.status] || { bg: "var(--bg-3)", color: "var(--text-2)" };
            return (
              <div key={r.id} style={{ display: "flex", alignItems: "center", gap: 12, padding: "12px 20px", borderBottom: "1px solid var(--border-subtle)" }}>
                <div style={{ width: 36, height: 36, borderRadius: "var(--radius-sm)", background: s.bg, color: s.color, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 16, flexShrink: 0 }}>◎</div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 14, fontWeight: 500 }}>{r.title || `Review ${r.id?.slice(0, 8)}`}</div>
                  <div style={{ fontSize: 12, color: "var(--text-2)" }}>by {r.reviewer_persona || "unassigned"}</div>
                </div>
                <span style={{ fontSize: 11, padding: "2px 8px", borderRadius: 10, background: s.bg, color: s.color }}>{r.status}</span>
                {r.verdict && (
                  <span style={{ fontSize: 11, color: VERDICT_STYLE[r.verdict] || "var(--text-2)" }}>{r.verdict.replace("_", " ")}</span>
                )}
                <span style={{ fontSize: 11, color: "var(--text-3)" }}>{timeAgo(r.updated_at || r.inserted_at)}</span>
                <div style={{ display: "flex", gap: 6 }}>
                  <button style={BTN_SEC} onClick={() => setModal(r)}>Edit</button>
                  <button style={BTN_DANGER} disabled={deleting === r.id} onClick={() => deleteReview(r.id)}>
                    {deleting === r.id ? "…" : "Delete"}
                  </button>
                </div>
              </div>
            );
          })}
          {reviews.length === 0 && (
            <div style={{ padding: 40, textAlign: "center", color: "var(--text-3)", fontSize: 14 }}>
              No reviews. Create one above or via the Review.Create MCP tool.
            </div>
          )}
        </div>
      )}

      {modal && (
        <ReviewModal
          review={modal === "create" ? null : modal}
          projectId={current?.id}
          onClose={() => setModal(null)}
          onSaved={() => { setModal(null); load(); }}
        />
      )}
    </div>
  );
}
