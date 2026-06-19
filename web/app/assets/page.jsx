"use client";

import { useState, useEffect, useCallback } from "react";
import { useProject } from "../../components/project-context";
import styles from "./assets.module.css";

const TYPE_ICONS = {
  image: "🖼", video: "🎬", music: "♪", voice: "🎙", component: "▣",
  html: "◇", diagram: "◇", document: "📄", svg: "◇", style_guide: "🎨",
};

const STATUS_COLORS = {
  draft: "draft", generating: "generating", review: "review",
  published: "published", archived: "archived",
};

const ASSET_TYPES = ["image", "video", "music", "voice", "component", "html", "diagram", "document", "svg", "style_guide"];

const inputStyle = {
  background: "var(--bg-2)", border: "1px solid var(--border)",
  borderRadius: "var(--radius-sm)", padding: "8px 12px",
  color: "var(--text-0)", fontSize: 13, fontFamily: "var(--font)",
  width: "100%", outline: "none", boxSizing: "border-box",
};

const labelStyle = { fontSize: 12, color: "var(--text-2)", marginBottom: 4, display: "block" };

const primaryBtn = {
  background: "var(--accent)", color: "white", border: "none",
  borderRadius: "var(--radius-sm)", padding: "6px 14px",
  cursor: "pointer", fontSize: 13, fontWeight: 500, fontFamily: "var(--font)",
};

const secondaryBtn = {
  background: "var(--bg-3)", color: "var(--text-1)", border: "none",
  borderRadius: "var(--radius-sm)", padding: "6px 14px",
  cursor: "pointer", fontSize: 13, fontWeight: 500, fontFamily: "var(--font)",
};

const dangerBtn = {
  background: "var(--red-dim)", color: "var(--red)", border: "none",
  borderRadius: "var(--radius-sm)", padding: "6px 14px",
  cursor: "pointer", fontSize: 13, fontWeight: 500, fontFamily: "var(--font)",
};

const overlayStyle = {
  position: "fixed", inset: 0, background: "rgba(0,0,0,0.5)",
  display: "flex", alignItems: "center", justifyContent: "center", zIndex: 50,
};

const cardStyle = {
  background: "var(--bg-1)", border: "1px solid var(--border)",
  borderRadius: "var(--radius-lg)", padding: 24, width: "100%", maxWidth: 520,
};

const EMPTY_FORM = { title: "", slug: "", asset_type: "image", prompt_yaml: "" };

function AssetModal({ asset, projectId, onClose, onSaved }) {
  const isEdit = !!asset;
  const [form, setForm] = useState(
    isEdit
      ? { title: asset.title || "", slug: asset.slug || "", asset_type: asset.asset_type || "image", prompt_yaml: asset.prompt_yaml || "" }
      : EMPTY_FORM
  );
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState(null);

  const set = (k, v) => setForm(f => ({ ...f, [k]: v }));

  const autoSlug = (title) => title.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "");

  const handleTitleChange = (v) => {
    set("title", v);
    if (!isEdit) set("slug", autoSlug(v));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSaving(true);
    setError(null);
    try {
      const body = { ...form, project_id: projectId };
      const url = isEdit ? `/api/proxy/assets/${asset.id}` : "/api/proxy/assets";
      const method = isEdit ? "PUT" : "POST";
      const res = await fetch(url, {
        method,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body),
      });
      if (!res.ok) {
        const d = await res.json().catch(() => ({}));
        throw new Error(d.error || `HTTP ${res.status}`);
      }
      onSaved();
    } catch (err) {
      setError(err.message);
    } finally {
      setSaving(false);
    }
  };

  return (
    <div style={overlayStyle} onClick={(e) => e.target === e.currentTarget && onClose()}>
      <div style={cardStyle}>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 20 }}>
          <span style={{ fontSize: 16, fontWeight: 600 }}>{isEdit ? "Edit Asset" : "Create Asset"}</span>
          <button onClick={onClose} style={{ ...secondaryBtn, padding: "4px 10px" }}>✕</button>
        </div>
        <form onSubmit={handleSubmit} style={{ display: "flex", flexDirection: "column", gap: 14 }}>
          <div>
            <label style={labelStyle}>Title *</label>
            <input style={inputStyle} value={form.title} onChange={e => handleTitleChange(e.target.value)} required />
          </div>
          <div>
            <label style={labelStyle}>Slug *</label>
            <input style={inputStyle} value={form.slug} onChange={e => set("slug", e.target.value)} required />
          </div>
          <div>
            <label style={labelStyle}>Asset Type *</label>
            <select style={{ ...inputStyle }} value={form.asset_type} onChange={e => set("asset_type", e.target.value)}>
              {ASSET_TYPES.map(t => (
                <option key={t} value={t}>{TYPE_ICONS[t] || "◇"} {t}</option>
              ))}
            </select>
          </div>
          <div>
            <label style={labelStyle}>Prompt / Description *</label>
            <textarea
              style={{ ...inputStyle, resize: "vertical", minHeight: 100 }}
              value={form.prompt_yaml}
              onChange={e => set("prompt_yaml", e.target.value)}
              required
            />
          </div>
          {error && <div style={{ color: "var(--red)", fontSize: 12 }}>{error}</div>}
          <div style={{ display: "flex", gap: 8, justifyContent: "flex-end", marginTop: 4 }}>
            <button type="button" style={secondaryBtn} onClick={onClose}>Cancel</button>
            <button type="submit" style={primaryBtn} disabled={saving}>
              {saving ? "Saving…" : isEdit ? "Save" : "Create"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

function DeleteConfirm({ asset, onClose, onDeleted }) {
  const [deleting, setDeleting] = useState(false);
  const [error, setError] = useState(null);

  const handleDelete = async () => {
    setDeleting(true);
    try {
      const res = await fetch(`/api/proxy/assets/${asset.id}`, { method: "DELETE" });
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      onDeleted();
    } catch (err) {
      setError(err.message);
      setDeleting(false);
    }
  };

  return (
    <div style={overlayStyle} onClick={(e) => e.target === e.currentTarget && onClose()}>
      <div style={{ ...cardStyle, maxWidth: 380 }}>
        <div style={{ fontSize: 16, fontWeight: 600, marginBottom: 12 }}>Delete Asset</div>
        <div style={{ fontSize: 13, color: "var(--text-2)", marginBottom: 20 }}>
          Delete <strong>{asset.title}</strong>? This cannot be undone.
        </div>
        {error && <div style={{ color: "var(--red)", fontSize: 12, marginBottom: 12 }}>{error}</div>}
        <div style={{ display: "flex", gap: 8, justifyContent: "flex-end" }}>
          <button style={secondaryBtn} onClick={onClose}>Cancel</button>
          <button style={dangerBtn} onClick={handleDelete} disabled={deleting}>
            {deleting ? "Deleting…" : "Delete"}
          </button>
        </div>
      </div>
    </div>
  );
}

export default function AssetsPage() {
  const { current } = useProject();
  const [assets, setAssets] = useState([]);
  const [loading, setLoading] = useState(false);
  const [modal, setModal] = useState(null); // null | "create" | { edit: asset } | { delete: asset }

  const fetchAssets = useCallback(async () => {
    if (!current?.id) { setAssets([]); return; }
    setLoading(true);
    try {
      const res = await fetch(`/api/proxy/assets?project_id=${current.id}`);
      const data = await res.json();
      setAssets(data?.assets ?? []);
    } catch {
      setAssets([]);
    } finally {
      setLoading(false);
    }
  }, [current?.id]);

  useEffect(() => { fetchAssets(); }, [fetchAssets]);

  const handleSaved = () => { setModal(null); fetchAssets(); };
  const handleDeleted = () => { setModal(null); fetchAssets(); };

  return (
    <div>
      <div className={styles.header}>
        <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
          <h1 className={styles.title}>Assets</h1>
          <span className={styles.count}>{assets.length} assets</span>
        </div>
        {current?.id && (
          <button style={primaryBtn} onClick={() => setModal("create")}>+ Create Asset</button>
        )}
      </div>

      {!current?.id && (
        <div className={styles.empty}>Select a project to view assets.</div>
      )}

      {current?.id && (
        <div className={styles.table}>
          <div className={styles.tableHeader}>
            <span>Asset</span>
            <span>Type</span>
            <span>Status</span>
            <span>Quality</span>
            <span>Updated</span>
            <span></span>
          </div>
          {loading && (
            <div className={styles.empty}>Loading…</div>
          )}
          {!loading && assets.map(a => (
            <div key={a.id} className={styles.row}>
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
              <div style={{ display: "flex", gap: 6, justifyContent: "flex-end" }}>
                <button style={{ ...secondaryBtn, padding: "3px 10px", fontSize: 12 }} onClick={() => setModal({ edit: a })}>Edit</button>
                <button style={{ ...dangerBtn, padding: "3px 10px", fontSize: 12 }} onClick={() => setModal({ delete: a })}>Del</button>
              </div>
            </div>
          ))}
          {!loading && assets.length === 0 && (
            <div className={styles.empty}>No assets yet. Create one above or via MCP tools.</div>
          )}
        </div>
      )}

      {modal === "create" && (
        <AssetModal projectId={current?.id} onClose={() => setModal(null)} onSaved={handleSaved} />
      )}
      {modal?.edit && (
        <AssetModal asset={modal.edit} projectId={current?.id} onClose={() => setModal(null)} onSaved={handleSaved} />
      )}
      {modal?.delete && (
        <DeleteConfirm asset={modal.delete} onClose={() => setModal(null)} onDeleted={handleDeleted} />
      )}
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
