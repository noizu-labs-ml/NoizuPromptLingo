"use client";

import { useState, useEffect, useCallback } from "react";
import { useProject } from "../../components/project-context";

const PRIORITY_COLORS = { critical: "#ef4444", high: "#f97316", medium: "#eab308", low: "#22c55e" };

const FIELD_TYPES = ["text", "rich_text", "markdown", "radio", "select", "multi_select", "number", "date", "persona", "url"];

const btn = {
  primary: { background: "var(--accent)", color: "white", border: "none", borderRadius: "var(--radius-sm)", padding: "6px 14px", cursor: "pointer", fontSize: 13, fontWeight: 500, fontFamily: "var(--font)" },
  secondary: { background: "var(--bg-3)", color: "var(--text-1)", border: "none", borderRadius: "var(--radius-sm)", padding: "6px 14px", cursor: "pointer", fontSize: 13, fontWeight: 500, fontFamily: "var(--font)" },
  danger: { background: "var(--red-dim)", color: "var(--red)", border: "none", borderRadius: "var(--radius-sm)", padding: "4px 10px", cursor: "pointer", fontSize: 12, fontFamily: "var(--font)" },
  small: { background: "var(--bg-3)", color: "var(--text-2)", border: "none", borderRadius: "var(--radius-sm)", padding: "4px 10px", cursor: "pointer", fontSize: 12, fontFamily: "var(--font)" },
};

const inputStyle = { background: "var(--bg-2)", border: "1px solid var(--border)", borderRadius: "var(--radius-sm)", padding: "8px 12px", color: "var(--text-0)", fontSize: 13, fontFamily: "var(--font)", width: "100%", outline: "none", boxSizing: "border-box" };

const overlayStyle = { position: "fixed", inset: 0, background: "rgba(0,0,0,0.5)", display: "flex", alignItems: "center", justifyContent: "center", zIndex: 50 };
const cardStyle = { background: "var(--bg-1)", border: "1px solid var(--border)", borderRadius: "var(--radius-lg)", padding: 24, width: "100%", maxWidth: 520 };

function tabStyle(active) {
  return {
    background: "none", border: "none", padding: "8px 16px", cursor: "pointer", fontSize: 13,
    fontFamily: "var(--font)", color: active ? "var(--accent)" : "var(--text-2)",
    borderBottom: active ? "2px solid var(--accent)" : "2px solid transparent",
    fontWeight: active ? 600 : 400,
  };
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

function FormField({ label, children }) {
  return (
    <div style={{ marginBottom: 16 }}>
      <label style={{ display: "block", fontSize: 12, fontWeight: 600, color: "var(--text-2)", marginBottom: 6, textTransform: "uppercase", letterSpacing: "0.04em" }}>{label}</label>
      {children}
    </div>
  );
}

// ── Ticket Modal ──────────────────────────────────────────────────────────────

function TicketModal({ ticket, projectId, onClose, onSaved }) {
  const isEdit = !!ticket;
  const [form, setForm] = useState({
    title: ticket?.title ?? "",
    description: ticket?.description ?? "",
    ticket_type: ticket?.ticket_type ?? "",
    priority: ticket?.priority ?? "medium",
    status: ticket?.status ?? "open",
    project_id: ticket?.project_id ?? projectId ?? "",
  });
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState(null);

  const set = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }));

  async function submit(e) {
    e.preventDefault();
    if (!form.title.trim()) { setError("Title is required"); return; }
    setSaving(true);
    setError(null);
    try {
      const url = isEdit ? `/api/proxy/tickets/${ticket.id}` : "/api/proxy/tickets";
      const res = await fetch(url, {
        method: isEdit ? "PUT" : "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(form),
      });
      if (!res.ok) throw new Error(await res.text());
      onSaved();
    } catch (err) {
      setError(err.message);
    } finally {
      setSaving(false);
    }
  }

  return (
    <div style={overlayStyle} onClick={(e) => e.target === e.currentTarget && onClose()}>
      <div style={cardStyle}>
        <h2 style={{ fontSize: 16, fontWeight: 600, marginBottom: 20 }}>{isEdit ? "Edit Ticket" : "Create Ticket"}</h2>
        <form onSubmit={submit}>
          <FormField label="Title *">
            <input style={inputStyle} value={form.title} onChange={set("title")} placeholder="Ticket title" autoFocus />
          </FormField>
          <FormField label="Description">
            <textarea style={{ ...inputStyle, minHeight: 80, resize: "vertical" }} value={form.description} onChange={set("description")} placeholder="Optional description" />
          </FormField>
          <FormField label="Type">
            <input style={inputStyle} value={form.ticket_type} onChange={set("ticket_type")} placeholder="e.g. bug, feature" />
          </FormField>
          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>
            <FormField label="Priority">
              <select style={inputStyle} value={form.priority} onChange={set("priority")}>
                <option value="critical">Critical</option>
                <option value="high">High</option>
                <option value="medium">Medium</option>
                <option value="low">Low</option>
              </select>
            </FormField>
            <FormField label="Status">
              <select style={inputStyle} value={form.status} onChange={set("status")}>
                <option value="open">Open</option>
                <option value="in_progress">In Progress</option>
                <option value="resolved">Resolved</option>
                <option value="closed">Closed</option>
              </select>
            </FormField>
          </div>
          {error && <div style={{ color: "var(--red)", fontSize: 12, marginBottom: 12 }}>{error}</div>}
          <div style={{ display: "flex", gap: 8, justifyContent: "flex-end" }}>
            <button type="button" style={btn.secondary} onClick={onClose}>Cancel</button>
            <button type="submit" style={btn.primary} disabled={saving}>{saving ? "Saving…" : isEdit ? "Save" : "Create"}</button>
          </div>
        </form>
      </div>
    </div>
  );
}

// ── Ticket Type Modal ─────────────────────────────────────────────────────────

function TypeModal({ typeDef, onClose, onSaved }) {
  const isEdit = !!typeDef;
  const [form, setForm] = useState({
    name: typeDef?.name ?? "",
    slug: typeDef?.slug ?? "",
    description: typeDef?.description ?? "",
  });
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState(null);

  const set = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }));

  function autoSlug(e) {
    if (!isEdit) {
      setForm((f) => ({ ...f, name: e.target.value, slug: e.target.value.toLowerCase().replace(/\s+/g, "_").replace(/[^a-z0-9_]/g, "") }));
    } else {
      set("name")(e);
    }
  }

  async function submit(e) {
    e.preventDefault();
    if (!form.name.trim() || !form.slug.trim()) { setError("Name and slug are required"); return; }
    setSaving(true);
    setError(null);
    try {
      const url = isEdit ? `/api/proxy/ticket-definitions/${typeDef.id}` : "/api/proxy/ticket-definitions";
      const res = await fetch(url, {
        method: isEdit ? "PUT" : "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(form),
      });
      if (!res.ok) throw new Error(await res.text());
      onSaved();
    } catch (err) {
      setError(err.message);
    } finally {
      setSaving(false);
    }
  }

  return (
    <div style={overlayStyle} onClick={(e) => e.target === e.currentTarget && onClose()}>
      <div style={cardStyle}>
        <h2 style={{ fontSize: 16, fontWeight: 600, marginBottom: 20 }}>{isEdit ? "Edit Type" : "Create Ticket Type"}</h2>
        <form onSubmit={submit}>
          <FormField label="Name *">
            <input style={inputStyle} value={form.name} onChange={autoSlug} placeholder="e.g. Bug Report" autoFocus />
          </FormField>
          <FormField label="Slug *">
            <input style={inputStyle} value={form.slug} onChange={set("slug")} placeholder="e.g. bug_report" />
          </FormField>
          <FormField label="Description">
            <textarea style={{ ...inputStyle, minHeight: 80, resize: "vertical" }} value={form.description} onChange={set("description")} placeholder="Optional description" />
          </FormField>
          {error && <div style={{ color: "var(--red)", fontSize: 12, marginBottom: 12 }}>{error}</div>}
          <div style={{ display: "flex", gap: 8, justifyContent: "flex-end" }}>
            <button type="button" style={btn.secondary} onClick={onClose}>Cancel</button>
            <button type="submit" style={btn.primary} disabled={saving}>{saving ? "Saving…" : isEdit ? "Save" : "Create"}</button>
          </div>
        </form>
      </div>
    </div>
  );
}

// ── Field Definition Modal ────────────────────────────────────────────────────

function FieldModal({ fieldDef, onClose, onSaved }) {
  const isEdit = !!fieldDef;
  const [form, setForm] = useState({
    label: fieldDef?.label ?? "",
    slug: fieldDef?.slug ?? "",
    field_type: fieldDef?.field_type ?? "text",
    description: fieldDef?.description ?? "",
    default_value: fieldDef?.default_value ?? "",
  });
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState(null);

  const set = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }));

  function autoSlug(e) {
    if (!isEdit) {
      setForm((f) => ({ ...f, label: e.target.value, slug: e.target.value.toLowerCase().replace(/\s+/g, "_").replace(/[^a-z0-9_]/g, "") }));
    } else {
      set("label")(e);
    }
  }

  async function submit(e) {
    e.preventDefault();
    if (!form.label.trim() || !form.slug.trim()) { setError("Label and slug are required"); return; }
    setSaving(true);
    setError(null);
    try {
      const url = isEdit ? `/api/proxy/ticket-field-definitions/${fieldDef.id}` : "/api/proxy/ticket-field-definitions";
      const res = await fetch(url, {
        method: isEdit ? "PUT" : "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(form),
      });
      if (!res.ok) throw new Error(await res.text());
      onSaved();
    } catch (err) {
      setError(err.message);
    } finally {
      setSaving(false);
    }
  }

  return (
    <div style={overlayStyle} onClick={(e) => e.target === e.currentTarget && onClose()}>
      <div style={cardStyle}>
        <h2 style={{ fontSize: 16, fontWeight: 600, marginBottom: 20 }}>{isEdit ? "Edit Field" : "Create Field Definition"}</h2>
        <form onSubmit={submit}>
          <FormField label="Label *">
            <input style={inputStyle} value={form.label} onChange={autoSlug} placeholder="e.g. Severity Level" autoFocus />
          </FormField>
          <FormField label="Slug *">
            <input style={inputStyle} value={form.slug} onChange={set("slug")} placeholder="e.g. severity_level" />
          </FormField>
          <FormField label="Field Type">
            <select style={inputStyle} value={form.field_type} onChange={set("field_type")}>
              {FIELD_TYPES.map((t) => <option key={t} value={t}>{t}</option>)}
            </select>
          </FormField>
          <FormField label="Description">
            <textarea style={{ ...inputStyle, minHeight: 60, resize: "vertical" }} value={form.description} onChange={set("description")} placeholder="Optional description" />
          </FormField>
          <FormField label="Default Value">
            <input style={inputStyle} value={form.default_value} onChange={set("default_value")} placeholder="Optional default" />
          </FormField>
          {error && <div style={{ color: "var(--red)", fontSize: 12, marginBottom: 12 }}>{error}</div>}
          <div style={{ display: "flex", gap: 8, justifyContent: "flex-end" }}>
            <button type="button" style={btn.secondary} onClick={onClose}>Cancel</button>
            <button type="submit" style={btn.primary} disabled={saving}>{saving ? "Saving…" : isEdit ? "Save" : "Create"}</button>
          </div>
        </form>
      </div>
    </div>
  );
}

// ── Tabs ──────────────────────────────────────────────────────────────────────

function TicketsTab({ projectId }) {
  const [tickets, setTickets] = useState([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState(null); // null | "create" | ticket object

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const qs = projectId ? `?project_id=${projectId}` : "";
      const res = await fetch(`/api/proxy/tickets${qs}`);
      const data = await res.json();
      setTickets(data?.tickets ?? []);
    } catch {
      setTickets([]);
    } finally {
      setLoading(false);
    }
  }, [projectId]);

  useEffect(() => { load(); }, [load]);

  async function deleteTicket(id) {
    if (!confirm("Delete this ticket?")) return;
    await fetch(`/api/proxy/tickets/${id}`, { method: "DELETE" });
    load();
  }

  return (
    <>
      <div style={{ display: "flex", justifyContent: "flex-end", marginBottom: 16 }}>
        <button style={btn.primary} onClick={() => setModal("create")}>+ Create Ticket</button>
      </div>
      <div style={{ background: "var(--bg-1)", border: "1px solid var(--border)", borderRadius: "var(--radius-lg)", overflow: "hidden" }}>
        <div style={{ display: "grid", gridTemplateColumns: "2fr 100px 110px 100px 100px 80px", gap: 8, padding: "10px 20px", borderBottom: "2px solid var(--border)", fontSize: 11, fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.05em", color: "var(--text-3)" }}>
          <span>Ticket</span><span>Type</span><span>Status</span><span>Priority</span><span>Updated</span><span></span>
        </div>
        {loading && <div style={{ padding: 40, textAlign: "center", color: "var(--text-3)", fontSize: 14 }}>Loading…</div>}
        {!loading && tickets.map((t) => (
          <div key={t.id} style={{ display: "grid", gridTemplateColumns: "2fr 100px 110px 100px 100px 80px", gap: 8, padding: "12px 20px", borderBottom: "1px solid var(--border-subtle)", alignItems: "center", fontSize: 13 }}>
            <div>
              <div style={{ fontWeight: 500 }}>{t.title}</div>
              <div style={{ fontSize: 11, color: "var(--text-3)" }}>{t.assignee || "unassigned"}</div>
            </div>
            <span style={{ fontSize: 12, color: "var(--text-2)", fontFamily: "var(--font-mono)" }}>{t.ticket_type || "—"}</span>
            <span style={{ fontSize: 11, padding: "2px 8px", borderRadius: 10, background: "var(--bg-3)", color: "var(--text-2)", width: "fit-content" }}>{t.status}</span>
            <span style={{ display: "flex", alignItems: "center", gap: 4, fontSize: 12, color: "var(--text-2)" }}>
              {t.priority && <span style={{ width: 6, height: 6, borderRadius: "50%", background: PRIORITY_COLORS[t.priority] || "var(--text-3)", flexShrink: 0 }} />}
              {t.priority || "—"}
            </span>
            <span style={{ fontSize: 11, color: "var(--text-3)" }}>{timeAgo(t.updated_at)}</span>
            <div style={{ display: "flex", gap: 4 }}>
              <button style={btn.small} onClick={() => setModal(t)}>Edit</button>
              <button style={btn.danger} onClick={() => deleteTicket(t.id)}>Del</button>
            </div>
          </div>
        ))}
        {!loading && tickets.length === 0 && (
          <div style={{ padding: 40, textAlign: "center", color: "var(--text-3)", fontSize: 14 }}>No tickets found.</div>
        )}
      </div>
      {modal && (
        <TicketModal
          ticket={modal === "create" ? null : modal}
          projectId={projectId}
          onClose={() => setModal(null)}
          onSaved={() => { setModal(null); load(); }}
        />
      )}
    </>
  );
}

function TypesTab() {
  const [types, setTypes] = useState([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState(null);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const res = await fetch("/api/proxy/ticket-definitions");
      const data = await res.json();
      setTypes(data?.ticket_type_definitions ?? data?.types ?? []);
    } catch {
      setTypes([]);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { load(); }, [load]);

  async function deleteType(id) {
    if (!confirm("Delete this ticket type?")) return;
    await fetch(`/api/proxy/ticket-definitions/${id}`, { method: "DELETE" });
    load();
  }

  return (
    <>
      <div style={{ display: "flex", justifyContent: "flex-end", marginBottom: 16 }}>
        <button style={btn.primary} onClick={() => setModal("create")}>+ Create Type</button>
      </div>
      <div style={{ background: "var(--bg-1)", border: "1px solid var(--border)", borderRadius: "var(--radius-lg)", overflow: "hidden" }}>
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 2fr 80px", gap: 8, padding: "10px 20px", borderBottom: "2px solid var(--border)", fontSize: 11, fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.05em", color: "var(--text-3)" }}>
          <span>Name</span><span>Slug</span><span>Description</span><span></span>
        </div>
        {loading && <div style={{ padding: 40, textAlign: "center", color: "var(--text-3)", fontSize: 14 }}>Loading…</div>}
        {!loading && types.map((t) => (
          <div key={t.id} style={{ display: "grid", gridTemplateColumns: "1fr 1fr 2fr 80px", gap: 8, padding: "12px 20px", borderBottom: "1px solid var(--border-subtle)", alignItems: "center", fontSize: 13 }}>
            <span style={{ fontWeight: 500 }}>{t.name}</span>
            <span style={{ fontSize: 12, color: "var(--text-2)", fontFamily: "var(--font-mono)" }}>{t.slug}</span>
            <span style={{ fontSize: 12, color: "var(--text-3)" }}>{t.description || "—"}</span>
            <div style={{ display: "flex", gap: 4 }}>
              <button style={btn.small} onClick={() => setModal(t)}>Edit</button>
              <button style={btn.danger} onClick={() => deleteType(t.id)}>Del</button>
            </div>
          </div>
        ))}
        {!loading && types.length === 0 && (
          <div style={{ padding: 40, textAlign: "center", color: "var(--text-3)", fontSize: 14 }}>No ticket types defined.</div>
        )}
      </div>
      {modal && (
        <TypeModal
          typeDef={modal === "create" ? null : modal}
          onClose={() => setModal(null)}
          onSaved={() => { setModal(null); load(); }}
        />
      )}
    </>
  );
}

function FieldsTab() {
  const [fields, setFields] = useState([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState(null);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const res = await fetch("/api/proxy/ticket-field-definitions");
      const data = await res.json();
      setFields(data?.ticket_field_definitions ?? data?.fields ?? []);
    } catch {
      setFields([]);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { load(); }, [load]);

  async function deleteField(id) {
    if (!confirm("Delete this field definition?")) return;
    await fetch(`/api/proxy/ticket-field-definitions/${id}`, { method: "DELETE" });
    load();
  }

  return (
    <>
      <div style={{ display: "flex", justifyContent: "flex-end", marginBottom: 16 }}>
        <button style={btn.primary} onClick={() => setModal("create")}>+ Create Field</button>
      </div>
      <div style={{ background: "var(--bg-1)", border: "1px solid var(--border)", borderRadius: "var(--radius-lg)", overflow: "hidden" }}>
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 120px 2fr 80px", gap: 8, padding: "10px 20px", borderBottom: "2px solid var(--border)", fontSize: 11, fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.05em", color: "var(--text-3)" }}>
          <span>Label</span><span>Slug</span><span>Type</span><span>Description</span><span></span>
        </div>
        {loading && <div style={{ padding: 40, textAlign: "center", color: "var(--text-3)", fontSize: 14 }}>Loading…</div>}
        {!loading && fields.map((f) => (
          <div key={f.id} style={{ display: "grid", gridTemplateColumns: "1fr 1fr 120px 2fr 80px", gap: 8, padding: "12px 20px", borderBottom: "1px solid var(--border-subtle)", alignItems: "center", fontSize: 13 }}>
            <span style={{ fontWeight: 500 }}>{f.label}</span>
            <span style={{ fontSize: 12, color: "var(--text-2)", fontFamily: "var(--font-mono)" }}>{f.slug}</span>
            <span style={{ fontSize: 11, padding: "2px 8px", borderRadius: 10, background: "var(--bg-3)", color: "var(--text-2)", width: "fit-content" }}>{f.field_type}</span>
            <span style={{ fontSize: 12, color: "var(--text-3)" }}>{f.description || "—"}</span>
            <div style={{ display: "flex", gap: 4 }}>
              <button style={btn.small} onClick={() => setModal(f)}>Edit</button>
              <button style={btn.danger} onClick={() => deleteField(f.id)}>Del</button>
            </div>
          </div>
        ))}
        {!loading && fields.length === 0 && (
          <div style={{ padding: 40, textAlign: "center", color: "var(--text-3)", fontSize: 14 }}>No field definitions.</div>
        )}
      </div>
      {modal && (
        <FieldModal
          fieldDef={modal === "create" ? null : modal}
          onClose={() => setModal(null)}
          onSaved={() => { setModal(null); load(); }}
        />
      )}
    </>
  );
}

// ── Page ──────────────────────────────────────────────────────────────────────

export default function TicketsPage() {
  const { current } = useProject();
  const [tab, setTab] = useState("tickets");

  return (
    <div>
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 8 }}>
        <h1 style={{ fontSize: 22, fontWeight: 600, letterSpacing: "-0.02em" }}>Tickets</h1>
      </div>

      {!current && (
        <div style={{ fontSize: 12, color: "var(--text-3)", marginBottom: 16, padding: "6px 12px", background: "var(--bg-2)", border: "1px solid var(--border)", borderRadius: "var(--radius-sm)", width: "fit-content" }}>
          Showing all tickets — select a project to filter
        </div>
      )}

      <div style={{ display: "flex", borderBottom: "1px solid var(--border)", marginBottom: 20 }}>
        <button style={tabStyle(tab === "tickets")} onClick={() => setTab("tickets")}>Tickets</button>
        <button style={tabStyle(tab === "types")} onClick={() => setTab("types")}>Types</button>
        <button style={tabStyle(tab === "fields")} onClick={() => setTab("fields")}>Fields</button>
      </div>

      {tab === "tickets" && <TicketsTab projectId={current?.id} />}
      {tab === "types" && <TypesTab />}
      {tab === "fields" && <FieldsTab />}
    </div>
  );
}
