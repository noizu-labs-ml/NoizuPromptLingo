import React, { useEffect, useState, useRef } from "react";
import { useNavigate } from "react-router-dom";
import { apiFetch } from "../hooks/useApi.js";

interface Conversation {
  id: string;
  tags: string[];
}

interface ConversationsResponse {
  data: Conversation[];
  meta: { total: number; limit: number };
}

interface TagMeta {
  name: string;
  color: string;
  description: string;
  createdAt: string;
}

interface TagMetaResponse {
  data: TagMeta[];
}

interface TagEntry {
  name: string;
  color: string;
  description: string;
  count: number;
  hasMeta: boolean;
}

const COLOR_PRESETS = [
  { value: "#06B6D4", label: "Cyan" },
  { value: "#4ADE80", label: "Green" },
  { value: "#F97316", label: "Orange" },
  { value: "#8B5CF6", label: "Purple" },
  { value: "#EC4899", label: "Pink" },
  { value: "#EAB308", label: "Gold" },
  { value: "#F87171", label: "Red" },
  { value: "#60A5FA", label: "Blue" },
];

const DEFAULT_COLOR = "#06B6D4";

function ColorPicker({
  value,
  onChange,
}: {
  value: string;
  onChange: (color: string) => void;
}) {
  return (
    <div className="flex gap-1 flex-wrap">
      {COLOR_PRESETS.map((preset) => (
        <button
          key={preset.value}
          title={preset.label}
          onClick={() => onChange(preset.value)}
          className="w-5 h-5 rounded-full border-2 transition-all"
          style={{
            backgroundColor: preset.value,
            borderColor: value === preset.value ? "white" : "transparent",
          }}
        />
      ))}
    </div>
  );
}

function TagCard({
  tag,
  onUpdate,
  onDelete,
}: {
  tag: TagEntry;
  onUpdate: (name: string, updates: { color?: string; description?: string }) => Promise<void>;
  onDelete: (name: string) => Promise<void>;
}) {
  const navigate = useNavigate();
  const [editingDesc, setEditingDesc] = useState(false);
  const [descValue, setDescValue] = useState(tag.description);
  const [showColorPicker, setShowColorPicker] = useState(false);
  const [saving, setSaving] = useState(false);
  const descRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    if (editingDesc && descRef.current) {
      descRef.current.focus();
    }
  }, [editingDesc]);

  async function handleDescSave() {
    if (descValue === tag.description) {
      setEditingDesc(false);
      return;
    }
    setSaving(true);
    await onUpdate(tag.name, { description: descValue });
    setSaving(false);
    setEditingDesc(false);
  }

  async function handleColorChange(color: string) {
    setShowColorPicker(false);
    if (color === tag.color) return;
    await onUpdate(tag.name, { color });
  }

  const borderStyle = { borderColor: tag.color + "66" };
  const textStyle = { color: tag.color };

  return (
    <div
      className="rounded-lg border bg-surface-raised p-4 space-y-3"
      style={borderStyle}
    >
      <div className="flex items-start justify-between gap-2">
        <div className="flex items-center gap-2 min-w-0">
          <span
            className="w-3 h-3 rounded-full flex-shrink-0"
            style={{ backgroundColor: tag.color }}
          />
          <button
            onClick={() => navigate(`/browse?tag=${encodeURIComponent(tag.name)}`)}
            className="font-medium text-sm truncate hover:underline"
            style={textStyle}
          >
            {tag.name}
          </button>
          <span className="text-xs text-text-muted flex-shrink-0">
            {tag.count} {tag.count === 1 ? "conv" : "convs"}
          </span>
        </div>
        <button
          onClick={() => onDelete(tag.name)}
          className="text-text-muted hover:text-red-400 transition-colors text-xs flex-shrink-0"
          title="Remove tag metadata"
        >
          ✕
        </button>
      </div>

      <div className="space-y-1">
        {editingDesc ? (
          <div className="flex gap-1">
            <input
              ref={descRef}
              value={descValue}
              onChange={(e) => setDescValue(e.target.value)}
              onBlur={handleDescSave}
              onKeyDown={(e) => {
                if (e.key === "Enter") handleDescSave();
                if (e.key === "Escape") {
                  setDescValue(tag.description);
                  setEditingDesc(false);
                }
              }}
              className="flex-1 bg-surface-active border border-border-subtle rounded px-2 py-1 text-xs text-text-primary outline-none focus:border-glow"
              placeholder="Add a description…"
              disabled={saving}
            />
          </div>
        ) : (
          <button
            onClick={() => setEditingDesc(true)}
            className="text-xs text-text-muted hover:text-text-primary transition-colors text-left w-full"
          >
            {tag.description || <span className="italic opacity-60">Click to add description…</span>}
          </button>
        )}
      </div>

      <div className="space-y-1">
        <button
          onClick={() => setShowColorPicker((v) => !v)}
          className="text-xs text-text-muted hover:text-text-primary transition-colors"
        >
          Color
        </button>
        {showColorPicker && (
          <ColorPicker value={tag.color} onChange={handleColorChange} />
        )}
      </div>
    </div>
  );
}

function CreateTagForm({
  onCreated,
  onCancel,
}: {
  onCreated: (meta: { name: string; color: string; description: string }) => void;
  onCancel: () => void;
}) {
  const [name, setName] = useState("");
  const [color, setColor] = useState(DEFAULT_COLOR);
  const [description, setDescription] = useState("");
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!name.trim()) {
      setError("Name is required");
      return;
    }
    setSaving(true);
    setError(null);
    try {
      await apiFetch("/tags", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ name: name.trim(), color, description }),
      });
      onCreated({ name: name.trim(), color, description });
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to create tag");
      setSaving(false);
    }
  }

  return (
    <form
      onSubmit={handleSubmit}
      className="rounded-lg border border-glow bg-surface-raised p-4 space-y-3"
    >
      <h3 className="text-sm font-medium text-text-bright">Create Tag</h3>

      {error && (
        <p className="text-xs text-red-400">{error}</p>
      )}

      <div className="space-y-1">
        <label className="text-xs text-text-muted">Name</label>
        <input
          value={name}
          onChange={(e) => setName(e.target.value)}
          className="w-full bg-surface-active border border-border-subtle rounded px-2 py-1 text-sm text-text-primary outline-none focus:border-glow"
          placeholder="tag-name"
          autoFocus
        />
      </div>

      <div className="space-y-1">
        <label className="text-xs text-text-muted">Description</label>
        <input
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          className="w-full bg-surface-active border border-border-subtle rounded px-2 py-1 text-sm text-text-primary outline-none focus:border-glow"
          placeholder="Optional description"
        />
      </div>

      <div className="space-y-1">
        <label className="text-xs text-text-muted">Color</label>
        <ColorPicker value={color} onChange={setColor} />
        <div className="flex items-center gap-2 mt-1">
          <span
            className="w-4 h-4 rounded-full border border-white/20"
            style={{ backgroundColor: color }}
          />
          <span className="text-xs text-text-muted">{color}</span>
        </div>
      </div>

      <div className="flex gap-2">
        <button
          type="submit"
          disabled={saving}
          className="px-3 py-1.5 rounded text-xs font-medium bg-glow text-black hover:opacity-90 disabled:opacity-50 transition-opacity"
          style={{ backgroundColor: color }}
        >
          {saving ? "Creating…" : "Create"}
        </button>
        <button
          type="button"
          onClick={onCancel}
          className="px-3 py-1.5 rounded text-xs text-text-muted hover:text-text-primary transition-colors"
        >
          Cancel
        </button>
      </div>
    </form>
  );
}

export function Tags() {
  const [tags, setTags] = useState<TagEntry[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [showCreate, setShowCreate] = useState(false);

  async function loadData() {
    setLoading(true);
    setError(null);
    try {
      const [convRes, metaRes] = await Promise.all([
        apiFetch<ConversationsResponse>("/conversations?limit=1000"),
        apiFetch<TagMetaResponse>("/tags"),
      ]);

      const counts = new Map<string, number>();
      for (const conv of convRes.data) {
        for (const tag of conv.tags ?? []) {
          counts.set(tag, (counts.get(tag) ?? 0) + 1);
        }
      }

      const metaMap = new Map<string, TagMeta>();
      for (const m of metaRes.data) {
        metaMap.set(m.name, m);
      }

      // All tags from conversations + any metadata-only tags
      const allNames = new Set([...counts.keys(), ...metaMap.keys()]);
      const entries: TagEntry[] = [...allNames].map((name) => {
        const meta = metaMap.get(name);
        return {
          name,
          color: meta?.color ?? DEFAULT_COLOR,
          description: meta?.description ?? "",
          count: counts.get(name) ?? 0,
          hasMeta: !!meta,
        };
      });

      entries.sort((a, b) => b.count - a.count || a.name.localeCompare(b.name));
      setTags(entries);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load tags");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadData();
  }, []);

  async function handleUpdate(name: string, updates: { color?: string; description?: string }) {
    await apiFetch("/tags", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ name, ...updates }),
    });
    setTags((prev) =>
      prev.map((t) =>
        t.name === name
          ? { ...t, ...updates, hasMeta: true }
          : t
      )
    );
  }

  async function handleDelete(name: string) {
    await apiFetch(`/tags/${encodeURIComponent(name)}`, { method: "DELETE" });
    setTags((prev) =>
      prev.map((t) =>
        t.name === name
          ? { ...t, color: DEFAULT_COLOR, description: "", hasMeta: false }
          : t
      )
    );
  }

  function handleCreated(meta: { name: string; color: string; description: string }) {
    setShowCreate(false);
    setTags((prev) => {
      const existing = prev.find((t) => t.name === meta.name);
      if (existing) {
        return prev.map((t) =>
          t.name === meta.name
            ? { ...t, color: meta.color, description: meta.description, hasMeta: true }
            : t
        );
      }
      return [
        { name: meta.name, color: meta.color, description: meta.description, count: 0, hasMeta: true },
        ...prev,
      ];
    });
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center py-20 text-text-muted text-sm">
        Loading tags…
      </div>
    );
  }

  if (error) {
    return (
      <div className="rounded-md border border-red-800 bg-red-950/30 px-4 py-3 text-sm text-red-400">
        {error}
      </div>
    );
  }

  const tagsWithCount = tags.filter((t) => t.count > 0);
  const metaOnly = tags.filter((t) => t.count === 0);

  return (
    <div className="space-y-6">
      <div className="space-y-1">
        <div className="flex items-baseline justify-between gap-3">
          <div className="flex items-baseline gap-3">
            <h1 className="text-lg font-semibold text-white">Tags</h1>
            <span className="text-sm text-text-muted">{tagsWithCount.length} unique tags</span>
          </div>
        <button
          onClick={() => setShowCreate((v) => !v)}
          className="text-xs px-3 py-1.5 rounded border border-border-subtle text-text-muted hover:text-text-primary hover:border-glow transition-colors"
        >
          {showCreate ? "Cancel" : "+ Create Tag"}
        </button>
        </div>
        <p className="text-sm text-text-muted">Organize conversations with custom tags. Set colors and descriptions to build a consistent taxonomy across your projects.</p>
      </div>

      {showCreate && (
        <CreateTagForm
          onCreated={handleCreated}
          onCancel={() => setShowCreate(false)}
        />
      )}

      {tags.length === 0 ? (
        <p className="text-sm text-text-muted">No tags found across conversations.</p>
      ) : (
        <div className="space-y-6">
          {tagsWithCount.length > 0 && (
            <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
              {tagsWithCount.map((tag) => (
                <TagCard
                  key={tag.name}
                  tag={tag}
                  onUpdate={handleUpdate}
                  onDelete={handleDelete}
                />
              ))}
            </div>
          )}

          {metaOnly.length > 0 && (
            <div className="space-y-2">
              <h2 className="text-xs text-text-muted uppercase tracking-wide">Metadata only (no conversations)</h2>
              <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
                {metaOnly.map((tag) => (
                  <TagCard
                    key={tag.name}
                    tag={tag}
                    onUpdate={handleUpdate}
                    onDelete={handleDelete}
                  />
                ))}
              </div>
            </div>
          )}
        </div>
      )}
    </div>
  );
}
