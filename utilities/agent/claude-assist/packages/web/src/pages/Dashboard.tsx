import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useConversations, useIndexStatus } from "../hooks/useApi.js";

export function Dashboard() {
  const [searchQuery, setSearchQuery] = useState("");
  const [searchMode, setSearchMode] = useState<"fts" | "semantic">("fts");
  const navigate = useNavigate();

  const { data: convData, loading: convLoading } = useConversations({ limit: 20, sort: "updated_at" });
  const { data: idxData, loading: idxLoading } = useIndexStatus();

  const conversations = convData?.data ?? [];
  const total = convData?.meta.total ?? 0;
  const indexStatus = idxData?.data;

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    if (searchQuery.trim()) {
      navigate(`/search?q=${encodeURIComponent(searchQuery)}&mode=${searchMode}`);
    }
  };

  const lastIndexedLabel = indexStatus?.lastIndexed
    ? new Date(indexStatus.lastIndexed).toLocaleString()
    : "Never";

  const stats = [
    { value: convLoading ? "..." : String(total), label: "Conversations" },
    { value: "—", label: "Projects" },
    { value: "—", label: "Dataset Entries" },
    { value: idxLoading ? "..." : lastIndexedLabel, label: "Last Indexed" },
  ];

  return (
    <div className="mx-auto max-w-5xl space-y-8">
      {/* Search bar */}
      <form onSubmit={handleSearch} className="flex h-12 items-center rounded-md border border-border-subtle bg-surface px-4 focus-within:border-glow focus-within:shadow-[0_0_8px_rgba(6,182,212,0.15)]">
        <span className="mr-3 text-text-dim">{"⌕"}</span>
        <input
          type="text"
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          placeholder="Search conversations..."
          className="flex-1 bg-transparent text-sm text-text-primary placeholder:text-text-dim outline-none"
        />
        <div className="flex gap-1">
          <button
            type="button"
            onClick={() => setSearchMode("fts")}
            className={`rounded-full px-3 py-1 text-xs font-medium ${
              searchMode === "fts"
                ? "bg-glow text-void"
                : "bg-surface-active text-text-muted"
            }`}
          >
            Text
          </button>
          <button
            type="button"
            onClick={() => setSearchMode("semantic")}
            className={`rounded-full px-3 py-1 text-xs font-medium ${
              searchMode === "semantic"
                ? "bg-glow text-void"
                : "bg-surface-active text-text-muted"
            }`}
          >
            Semantic
          </button>
        </div>
      </form>

      {/* Stat cards */}
      <div className="grid grid-cols-4 gap-4">
        {stats.map((stat) => (
          <div key={stat.label} className="rounded-md border border-border-subtle bg-surface p-4">
            <p className="font-mono text-2xl font-medium text-text-bright">{stat.value}</p>
            <p className="mt-1 text-xs uppercase tracking-wider text-text-dim">{stat.label}</p>
          </div>
        ))}
      </div>

      {/* Recent conversations */}
      <div>
        <h2 className="mb-4 text-lg font-medium text-text-primary">Recent Conversations</h2>
        {convLoading ? (
          <p className="text-sm text-text-muted">Loading...</p>
        ) : conversations.length === 0 ? (
          <p className="text-sm text-text-muted">
            No conversations indexed. Run <code className="text-glow">claude-assist index</code> to scan for conversations.
          </p>
        ) : (
          <div className="space-y-1">
            {conversations.map((c) => (
              <button
                key={c.id}
                onClick={() => navigate(`/thread/${c.id}`)}
                className="flex w-full items-center gap-3 rounded-md px-3 py-2 text-left hover:bg-surface-active transition-colors"
              >
                <span className="font-mono text-xs text-text-dim">{c.id.slice(0, 8)}</span>
                <span className="text-xs text-glow">[{shortProject(c.projectPath)}]</span>
                <span className="flex-1 truncate text-sm text-text-primary">
                  {c.title.startsWith("/") ? (() => {
                    const spaceIdx = c.title.indexOf(" ");
                    const cmd = spaceIdx === -1 ? c.title : c.title.slice(0, spaceIdx);
                    const args = spaceIdx === -1 ? "" : c.title.slice(spaceIdx + 1);
                    return (
                      <>
                        <span className="text-glow font-mono">{cmd}</span>
                        {args && <span> {args}</span>}
                      </>
                    );
                  })() : c.title}
                </span>
                <span className="text-xs text-text-dim">{c.messageCount} msgs</span>
                <span className="text-xs text-text-dim">{new Date(c.updatedAt).toLocaleDateString()}</span>
              </button>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

function shortProject(path: string): string {
  const parts = path.split("/").filter(Boolean);
  return parts.length > 2 ? parts.slice(-2).join("/") : path;
}
