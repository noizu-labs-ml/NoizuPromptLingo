import React, { useState, useEffect, useRef } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { apiFetch } from "../hooks/useApi.js";

interface ProjectEntry {
  projectPath: string;
  title: string | null;
  description: string | null;
  tags: string[];
  conversationCount: number;
  lastActive: string | null;
  displayName?: string;
}

interface Conversation {
  id: string;
  title: string;
  projectPath: string;
  messageCount: number;
  startedAt: string;
  updatedAt: string;
  status: string;
  tags: string[];
  firstMessage?: string;
  lastMessage?: string;
}

type PreviewMode = "both" | "first" | "last" | "none";

export function ProjectDetail() {
  const { slug } = useParams<{ slug: string }>();
  const projectPath = slug ? decodeURIComponent(slug) : "";
  const navigate = useNavigate();

  const [project, setProject] = useState<ProjectEntry | null>(null);
  const [conversations, setConversations] = useState<Conversation[]>([]);
  const [totalConvos, setTotalConvos] = useState(0);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState("");
  const [sort, setSort] = useState<"updated_at" | "started_at" | "message_count" | "title">("updated_at");
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(25);
  const [previewMode, setPreviewMode] = useState<PreviewMode>("both");

  const offset = (page - 1) * pageSize;

  useEffect(() => {
    if (!projectPath) return;
    const encoded = encodeURIComponent(projectPath);
    apiFetch<ProjectEntry>(`/projects/${encoded}`).then((proj) => {
      setProject(proj);
      setLoading(false);
    }).catch(() => setLoading(false));
  }, [projectPath]);

  useEffect(() => {
    if (!projectPath) return;
    const encoded = encodeURIComponent(projectPath);
    apiFetch<{ data: Conversation[]; meta: { total: number } }>(
      `/conversations?limit=${pageSize}&offset=${offset}&project=${encoded}&sort=${sort}`
    ).then((res) => {
      setConversations(res.data);
      setTotalConvos(res.meta.total);
    }).catch(() => {});
  }, [projectPath, sort, page, pageSize]);

  const totalPages = Math.max(1, Math.ceil(totalConvos / pageSize));
  const safePage = Math.min(page, totalPages);

  const handlePatch = async (updates: { title?: string | null; description?: string | null; tags?: string[] }) => {
    const encoded = encodeURIComponent(projectPath);
    await apiFetch(`/projects/${encoded}`, {
      method: "PATCH",
      body: JSON.stringify(updates),
    });
    setProject((prev) => prev ? { ...prev, ...updates } : prev);
  };

  const filtered = conversations.filter((c) => {
    if (!filter) return true;
    const q = filter.toLowerCase();
    return c.title.toLowerCase().includes(q) || c.tags.some((t) => t.toLowerCase().includes(q));
  });

  if (loading) {
    return <div className="mx-auto max-w-4xl py-12"><p className="text-sm text-text-muted">Loading...</p></div>;
  }

  const displayName = project?.title || project?.displayName || shortProject(projectPath);

  const renderPreview = (c: Conversation) => {
    if (previewMode === "none") return null;
    return (
      <div className="mt-0.5 space-y-0">
        {(previewMode === "both" || previewMode === "first") && c.firstMessage && (
          <p className="text-xs text-text-dim truncate"><span className="text-text-muted mr-1">▸</span>{stripToolUse(c.firstMessage)}</p>
        )}
        {(previewMode === "both" || previewMode === "last") && c.lastMessage && (
          <p className="text-xs text-text-dim truncate"><span className="text-text-muted mr-1">◂</span>{stripToolUse(c.lastMessage)}</p>
        )}
      </div>
    );
  };

  return (
    <div className="mx-auto max-w-4xl space-y-6">

      {/* Header card */}
      <div className="rounded-lg border border-border-strong bg-surface-raised p-5 space-y-3">
        <div className="flex items-start justify-between">
          <div className="flex-1 min-w-0">
            <EditableText
              value={project?.title ?? null}
              placeholder="Add project title..."
              onSave={(val) => handlePatch({ title: val })}
              className="text-xl font-medium text-white"
              placeholderClass="text-xl font-medium text-text-dim italic"
            />
            <p className="mt-1 font-mono text-xs text-text-muted select-all" title={projectPath}>{projectPath}</p>
            <div className="mt-2">
              <EditableText
                value={project?.description ?? null}
                placeholder="Add project description..."
                onSave={(val) => handlePatch({ description: val })}
                className="text-sm text-text-primary"
                placeholderClass="text-sm text-text-dim italic"
              />
            </div>
          </div>
          <div className="ml-4 flex flex-col items-end gap-1 shrink-0">
            <span className="text-sm text-text-primary">{totalConvos} conversations</span>
            {project?.lastActive && (
              <span className="text-xs text-text-muted">Last active {new Date(project.lastActive).toLocaleDateString()}</span>
            )}
          </div>
        </div>

        {/* Tags */}
        <div className="flex flex-wrap items-center gap-1.5">
          {(project?.tags ?? []).map((tag) => (
            <span key={tag} className="tag-chip group">
              {tag}
              <button
                onClick={() => handlePatch({ tags: (project?.tags ?? []).filter((t) => t !== tag) })}
                className="ml-0.5 opacity-0 group-hover:opacity-100 hover:text-red-400 transition-opacity"
              >&times;</button>
            </span>
          ))}
          <AddTagInline onAdd={(tag) => handlePatch({ tags: [...(project?.tags ?? []), tag] })} />
        </div>

        <button onClick={() => navigate("/projects")} className="btn-action text-xs">Back to Projects</button>
      </div>

      {/* Search + sort + preview toggle */}
      <div className="flex items-center gap-3">
        <input
          type="text"
          value={filter}
          onChange={(e) => setFilter(e.target.value)}
          placeholder="Filter conversations..."
          className="flex-1 rounded-md border border-border-subtle bg-void px-3 py-2 text-sm text-text-primary placeholder:text-text-dim outline-none focus:border-glow"
        />
        <select
          value={sort}
          onChange={(e) => { setSort(e.target.value as typeof sort); setPage(1); }}
          className="rounded-md border border-border-subtle bg-surface-raised px-2 py-1.5 text-xs text-text-primary outline-none"
        >
          <option value="updated_at">Last Updated</option>
          <option value="started_at">Date Started</option>
          <option value="message_count">Message Count</option>
          <option value="title">Title</option>
        </select>
        <div className="flex items-center gap-0.5">
          {(["both", "first", "last", "none"] as PreviewMode[]).map((pm) => (
            <button
              key={pm}
              type="button"
              onClick={() => setPreviewMode(pm)}
              className={`rounded-full px-2 py-0.5 text-xs font-medium transition-colors ${
                previewMode === pm ? "bg-glow text-void" : "bg-surface-active text-text-muted hover:text-text-primary"
              }`}
            >
              {pm === "both" ? "Preview" : pm.charAt(0).toUpperCase() + pm.slice(1)}
            </button>
          ))}
        </div>
        <span className="text-xs text-text-dim">{filtered.length} shown</span>
      </div>

      {/* Conversation list */}
      {filtered.length === 0 ? (
        <p className="text-sm text-text-muted py-4">
          {filter ? "No conversations match your filter." : "No conversations in this project."}
        </p>
      ) : (
        <div className="space-y-1">
          {filtered.map((c) => (
            <button
              key={c.id}
              onClick={() => navigate(`/thread/${c.id}`)}
              className="flex w-full items-start gap-3 rounded-md px-3 py-2.5 text-left hover:bg-surface-active transition-colors"
            >
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2">
                  <span className="font-mono text-xs text-text-dim">{c.id.slice(0, 8)}</span>
                  <span className="flex-1 truncate text-sm text-text-primary">
                    <ConversationTitle title={c.title} />
                  </span>
                  {c.tags.length > 0 && (
                    <span className="text-xs text-glow">{c.tags.slice(0, 2).join(", ")}</span>
                  )}
                  <span className="text-xs text-text-dim shrink-0">{c.messageCount} msgs</span>
                  <span className="text-xs text-text-dim shrink-0">{new Date(c.updatedAt).toLocaleDateString()}</span>
                  {c.status !== "active" && (
                    <span className="rounded-full bg-surface-active px-2 py-0.5 text-xs text-text-dim">{c.status}</span>
                  )}
                </div>
                {renderPreview(c)}
              </div>
            </button>
          ))}
        </div>
      )}

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="flex items-center justify-between pt-2 border-t border-border-subtle">
          <span className="text-xs text-text-muted">Page {safePage} of {totalPages}</span>
          <div className="flex items-center gap-2">
            <button className="btn-action" disabled={safePage <= 1} onClick={() => setPage((p) => p - 1)}>Prev</button>
            <button className="btn-action" disabled={safePage >= totalPages} onClick={() => setPage((p) => p + 1)}>Next</button>
          </div>
        </div>
      )}
    </div>
  );
}

function stripToolUse(text: string): string {
  const cleaned = text.replace(/^\{"type":"tool_use".*?"name":"[^"]*","input":\{.*?\}\}/, "").trim();
  return cleaned || text.slice(0, 100);
}

function ConversationTitle({ title }: { title: string }) {
  if (title.startsWith("/")) {
    const spaceIdx = title.indexOf(" ");
    const cmd = spaceIdx === -1 ? title : title.slice(0, spaceIdx);
    const args = spaceIdx === -1 ? "" : title.slice(spaceIdx + 1);
    return <><span className="text-glow font-mono">{cmd}</span>{args && <span> {args}</span>}</>;
  }
  return <>{title}</>;
}

function EditableText({ value, placeholder, onSave, className, placeholderClass }: {
  value: string | null;
  placeholder: string;
  onSave: (val: string | null) => void;
  className: string;
  placeholderClass: string;
}) {
  const [editing, setEditing] = useState(false);
  const [draft, setDraft] = useState(value ?? "");
  const ref = useRef<HTMLInputElement>(null);

  useEffect(() => { if (editing) ref.current?.focus(); }, [editing]);

  const commit = () => {
    const trimmed = draft.trim();
    onSave(trimmed || null);
    setEditing(false);
  };

  if (editing) {
    return (
      <input
        ref={ref}
        value={draft}
        onChange={(e) => setDraft(e.target.value)}
        onBlur={commit}
        onKeyDown={(e) => { if (e.key === "Enter") commit(); if (e.key === "Escape") { setDraft(value ?? ""); setEditing(false); } }}
        className={`w-full rounded bg-void border border-border-subtle px-2 py-0.5 outline-none focus:border-glow ${className}`}
      />
    );
  }

  return (
    <span
      onClick={() => { setDraft(value ?? ""); setEditing(true); }}
      className={`cursor-text ${value ? className : placeholderClass}`}
      title="Click to edit"
    >
      {value ?? placeholder}
    </span>
  );
}

function AddTagInline({ onAdd }: { onAdd: (tag: string) => void }) {
  const [adding, setAdding] = useState(false);
  const [draft, setDraft] = useState("");
  const ref = useRef<HTMLInputElement>(null);

  useEffect(() => { if (adding) ref.current?.focus(); }, [adding]);

  const commit = () => {
    if (draft.trim()) onAdd(draft.trim());
    setDraft("");
    setAdding(false);
  };

  if (adding) {
    return (
      <form onSubmit={(e) => { e.preventDefault(); commit(); }} className="flex items-center gap-1">
        <input
          ref={ref}
          value={draft}
          onChange={(e) => setDraft(e.target.value)}
          onBlur={commit}
          onKeyDown={(e) => { if (e.key === "Escape") { setDraft(""); setAdding(false); } }}
          placeholder="tag..."
          className="w-20 rounded-full bg-void px-2.5 py-0.5 text-xs text-text-primary placeholder:text-text-dim outline-none border border-border-subtle focus:border-glow"
        />
      </form>
    );
  }

  return (
    <button onClick={() => setAdding(true)} className="rounded-full border border-dashed border-border-subtle px-2 py-0.5 text-xs text-text-dim hover:text-glow hover:border-glow/30 transition-colors" title="Add tag">+ tag</button>
  );
}

function shortProject(path: string): string {
  const parts = path.split("/").filter(Boolean);
  return parts.length > 2 ? parts.slice(-2).join("/") : path;
}
