import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useConversations } from "../hooks/useApi.js";

type SortOption = "updated_at" | "started_at" | "message_count" | "title";

function parseTagInput(raw: string): string[] {
  return raw
    .split(",")
    .map((t) => t.trim().toLowerCase())
    .filter(Boolean);
}

export function Browse() {
  const [sort, setSort] = useState<SortOption>("updated_at");
  const [includeTags, setIncludeTags] = useState("");
  const [excludeTags, setExcludeTags] = useState("");
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(25);
  const navigate = useNavigate();

  const offset = (page - 1) * pageSize;
  const { data, loading, error } = useConversations({ sort, limit: pageSize, offset });
  const conversations = data?.data ?? [];
  const totalConvos = data?.meta.total ?? 0;

  const includeList = parseTagInput(includeTags);
  const excludeList = parseTagInput(excludeTags);
  const activeFilterCount = (includeList.length > 0 ? 1 : 0) + (excludeList.length > 0 ? 1 : 0);

  const filtered = conversations.filter((c) => {
    const tags = (c.tags ?? []).map((t: string) => t.toLowerCase());
    if (includeList.length > 0 && !includeList.every((t) => tags.includes(t))) return false;
    if (excludeList.length > 0 && excludeList.some((t) => tags.includes(t))) return false;
    return true;
  });

  const totalCount = totalConvos;
  const totalPages = Math.max(1, Math.ceil(totalCount / pageSize));
  const safePage = Math.min(page, totalPages);

  // Group by project
  const groups = new Map<string, typeof conversations>();
  for (const c of filtered) {
    const key = c.projectPath;
    if (!groups.has(key)) groups.set(key, []);
    groups.get(key)!.push(c);
  }

  return (
    <div className="mx-auto max-w-5xl space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-medium text-text-bright">Browse</h1>
        <div className="flex items-center gap-2">
          <span className="text-xs text-text-dim">Sort:</span>
          <select
            value={sort}
            onChange={(e) => { setSort(e.target.value as SortOption); setPage(1); }}
            className="rounded-md border border-border-subtle bg-surface px-2 py-1 text-xs text-text-primary outline-none"
          >
            <option value="updated_at">Last Updated</option>
            <option value="started_at">Date Started</option>
            <option value="message_count">Message Count</option>
            <option value="title">Title</option>
          </select>
        </div>
      </div>

      <div className="flex flex-row items-center gap-4">
        <div className="flex items-center gap-2">
          <label className="text-xs text-text-muted">Include tags:</label>
          <input
            type="text"
            value={includeTags}
            onChange={(e) => { setIncludeTags(e.target.value); setPage(1); }}
            placeholder="tag1, tag2"
            className="rounded-md border border-border-subtle bg-void px-2 py-1 text-xs text-text-primary outline-none"
          />
        </div>
        <div className="flex items-center gap-2">
          <label className="text-xs text-text-muted">Exclude tags:</label>
          <input
            type="text"
            value={excludeTags}
            onChange={(e) => { setExcludeTags(e.target.value); setPage(1); }}
            placeholder="tag1, tag2"
            className="rounded-md border border-border-subtle bg-void px-2 py-1 text-xs text-text-primary outline-none"
          />
        </div>
        {activeFilterCount > 0 && (
          <span className="rounded-full bg-surface-active px-2 py-0.5 text-xs text-text-primary">
            {activeFilterCount} filter{activeFilterCount !== 1 ? "s" : ""} active
          </span>
        )}
      </div>

      {loading && <p className="text-sm text-text-muted">Loading conversations...</p>}

      {error && <p className="text-sm text-red-400">Error: {error}</p>}

      {!loading && totalCount === 0 && (
        <p className="text-sm text-text-muted">
          No conversations indexed. Run <code className="text-glow">claude-assist index</code> to get started.
        </p>
      )}

      {!loading && totalCount > 0 && (
        <div className="flex flex-row items-center justify-between">
          <span className="text-xs text-text-muted">
            {totalCount} conversation{totalCount !== 1 ? "s" : ""} &mdash; page {safePage} of {totalPages}
          </span>
          <div className="flex items-center gap-2">
            <select
              value={pageSize}
              onChange={(e) => { setPageSize(Number(e.target.value)); setPage(1); }}
              className="rounded-md border border-border-subtle bg-surface px-2 py-1 text-xs text-text-primary outline-none"
            >
              <option value={25}>25 / page</option>
              <option value={50}>50 / page</option>
              <option value={100}>100 / page</option>
            </select>
          </div>
        </div>
      )}

      {[...groups.entries()].map(([project, convs]) => (
        <div key={project}>
          <div className="flex items-center gap-2 mb-2">
            <h2 className="text-sm font-medium text-glow">{shortProject(project)}</h2>
            <span className="text-xs text-text-dim">({convs.length})</span>
          </div>
          <div className="space-y-1 mb-6">
            {convs.map((c) => (
              <button
                key={c.id}
                onClick={() => navigate(`/thread/${c.id}`)}
                className="flex w-full items-center gap-3 rounded-md px-3 py-2 text-left hover:bg-surface-active transition-colors"
              >
                <span className="font-mono text-xs text-text-dim">{c.slug ?? c.id.slice(0, 8)}</span>
                <span className="flex-1 truncate text-sm text-text-primary">{c.title}</span>
                {c.description && (
                  <span className="max-w-[200px] truncate text-xs text-text-muted italic">{c.description}</span>
                )}
                <span className="text-xs text-text-dim">{c.messageCount} msgs</span>
                <span className="text-xs text-text-dim">{new Date(c.updatedAt).toLocaleDateString()}</span>
                {c.status !== "active" && (
                  <span className="rounded-full bg-surface-active px-2 py-0.5 text-xs text-text-dim">{c.status}</span>
                )}
              </button>
            ))}
          </div>
        </div>
      ))}

      {!loading && totalPages > 1 && (
        <div className="flex flex-row items-center justify-between pt-2 border-t border-border-subtle">
          <span className="text-xs text-text-muted">Page {safePage} of {totalPages}</span>
          <div className="flex items-center gap-2">
            <button
              className="btn-action"
              disabled={safePage <= 1}
              onClick={() => setPage((p) => Math.max(1, p - 1))}
            >
              Prev
            </button>
            <button
              className="btn-action"
              disabled={safePage >= totalPages}
              onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
            >
              Next
            </button>
          </div>
        </div>
      )}
    </div>
  );
}

function shortProject(path: string): string {
  const parts = path.split("/").filter(Boolean);
  return parts.length > 2 ? parts.slice(-2).join("/") : path;
}
