"use client";
import { useState, useEffect, useCallback } from "react";
import { useProject } from "../../components/project-context";

const BTN = { background: "var(--accent)", color: "white", border: "none", borderRadius: "var(--radius-sm)", padding: "6px 14px", cursor: "pointer", fontSize: 13, fontWeight: 500, fontFamily: "var(--font)" };
const BTN_SEC = { background: "var(--bg-3)", color: "var(--text-1)", border: "none", borderRadius: "var(--radius-sm)", padding: "6px 14px", cursor: "pointer", fontSize: 13, fontWeight: 500, fontFamily: "var(--font)" };
const BTN_DANGER = { background: "var(--red-dim)", color: "var(--red)", border: "none", borderRadius: "var(--radius-sm)", padding: "6px 14px", cursor: "pointer", fontSize: 13, fontWeight: 500, fontFamily: "var(--font)" };
const INPUT = { background: "var(--bg-2)", border: "1px solid var(--border)", borderRadius: "var(--radius-sm)", padding: "8px 12px", color: "var(--text-0)", fontSize: 13, fontFamily: "var(--font)", width: "100%", outline: "none", boxSizing: "border-box" };
const OVERLAY = { position: "fixed", inset: 0, background: "rgba(0,0,0,0.5)", display: "flex", alignItems: "center", justifyContent: "center", zIndex: 50 };
const MODAL = { background: "var(--bg-1)", border: "1px solid var(--border)", borderRadius: "var(--radius-lg)", padding: 24, width: "100%", maxWidth: 480 };

function timeAgo(dt) {
  if (!dt) return "";
  const diff = Date.now() - new Date(dt).getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 60) return `${mins}m ago`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `${hrs}h ago`;
  return `${Math.floor(hrs / 24)}d ago`;
}

const EMPTY_FORM = { name: "", description: "" };

function RoomModal({ room, projectId, onClose, onSaved }) {
  const editing = !!room;
  const [form, setForm] = useState(room ? { name: room.name || "", description: room.description || "" } : EMPTY_FORM);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState(null);

  function set(k, v) { setForm(f => ({ ...f, [k]: v })); }

  async function submit(e) {
    e.preventDefault();
    setSaving(true);
    setError(null);
    try {
      const body = { ...form };
      if (!editing && projectId) body.project_id = projectId;
      const res = await fetch(editing ? `/api/proxy/chat/rooms/${room.id}` : "/api/proxy/chat/rooms", {
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
        <div style={{ fontSize: 16, fontWeight: 600, marginBottom: 20 }}>{editing ? "Edit Room" : "Create Room"}</div>
        <form onSubmit={submit} style={{ display: "flex", flexDirection: "column", gap: 14 }}>
          <div>
            <label style={{ fontSize: 12, color: "var(--text-2)", display: "block", marginBottom: 6 }}>Name *</label>
            <input style={INPUT} value={form.name} onChange={e => set("name", e.target.value)} placeholder="room-name" required />
          </div>
          <div>
            <label style={{ fontSize: 12, color: "var(--text-2)", display: "block", marginBottom: 6 }}>Description</label>
            <input style={INPUT} value={form.description} onChange={e => set("description", e.target.value)} placeholder="What is this room about?" />
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

export default function ChatPage() {
  const { current } = useProject();
  const [rooms, setRooms] = useState([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState(null); // null | "create" | room object
  const [deleting, setDeleting] = useState(null);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const qs = current?.id ? `?project_id=${current.id}` : "";
      const res = await fetch(`/api/proxy/chat/rooms${qs}`);
      const data = res.ok ? await res.json() : {};
      setRooms(data.rooms ?? []);
    } catch {
      setRooms([]);
    } finally {
      setLoading(false);
    }
  }, [current?.id]);

  useEffect(() => { load(); }, [load]);

  async function deleteRoom(id) {
    if (!confirm("Delete this room?")) return;
    setDeleting(id);
    try {
      await fetch(`/api/proxy/chat/rooms/${id}`, { method: "DELETE" });
      setRooms(r => r.filter(x => x.id !== id));
    } finally {
      setDeleting(null);
    }
  }

  return (
    <div>
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 24 }}>
        <h1 style={{ fontSize: 22, fontWeight: 600, letterSpacing: "-0.02em", margin: 0 }}>
          Chat Rooms{current ? ` — ${current.name}` : ""}
        </h1>
        <button style={BTN} onClick={() => setModal("create")}>+ Create Room</button>
      </div>

      {loading ? (
        <div style={{ padding: 40, textAlign: "center", color: "var(--text-3)", fontSize: 14 }}>Loading…</div>
      ) : (
        <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
          {rooms.map(r => (
            <div key={r.id} style={{ background: "var(--bg-1)", border: "1px solid var(--border)", borderRadius: "var(--radius-md)", padding: 16, display: "flex", alignItems: "center", gap: 12 }}>
              <div style={{ width: 36, height: 36, borderRadius: "var(--radius-sm)", background: "var(--accent-dim)", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 16, flexShrink: 0 }}>▬</div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 14, fontWeight: 500 }}>#{r.name}</div>
                {r.description && <div style={{ fontSize: 12, color: "var(--text-2)" }}>{r.description}</div>}
              </div>
              <span style={{ fontSize: 11, color: "var(--text-3)" }}>{timeAgo(r.inserted_at || r.created_at)}</span>
              <div style={{ display: "flex", gap: 6 }}>
                <button style={BTN_SEC} onClick={() => setModal(r)}>Edit</button>
                <button style={BTN_DANGER} disabled={deleting === r.id} onClick={() => deleteRoom(r.id)}>
                  {deleting === r.id ? "…" : "Delete"}
                </button>
              </div>
            </div>
          ))}
          {rooms.length === 0 && (
            <div style={{ padding: 40, textAlign: "center", color: "var(--text-3)", fontSize: 14 }}>
              No chat rooms. Create one above or via the Chat.CreateRoom MCP tool.
            </div>
          )}
        </div>
      )}

      {modal && (
        <RoomModal
          room={modal === "create" ? null : modal}
          projectId={current?.id}
          onClose={() => setModal(null)}
          onSaved={() => { setModal(null); load(); }}
        />
      )}
    </div>
  );
}
