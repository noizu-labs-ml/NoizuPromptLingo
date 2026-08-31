import React, { useEffect, useState } from "react";
import { useNavigate, useSearchParams } from "react-router-dom";
import { useConversations, useSearch, useIndexStatus } from "../hooks/useApi.js";
import { useHarness } from "../context/HarnessContext.js";

type SortOption = "updated_at" | "started_at" | "message_count" | "title";
type PreviewMode = "both" | "first" | "last" | "none";
type GroupMode = "grouped" | "flat";

function parseTagInput(raw: string): string[] {
  return raw.split(",").map((t) => t.trim().toLowerCase()).filter(Boolean);
}

// ⟦𓎒𓅖𓊽𓆣⟧ Explore :: auto-generated pointer for public function Explore
export function Explore() {
  const navigate = useNavigate();
  const [searchParams, setSearchParams] = useSearchParams();
  const { harness } = useHarness();

  const initialQuery = searchParams.get("q") ?? "";
  const initialMode = (searchParams.get("mode") ?? "fts") as "fts" | "semantic";

  const [inputValue, setInputValue] = useState(initialQuery);
  const [query, setQuery] = useState(initialQuery);
  const [mode, setMode] = useState<"fts" | "semantic">(initialMode);
  const [sort, setSort] = useState<SortOption>("updated_at");
  const [includeTags, setIncludeTags] = useState("");
  const [excludeTags, setExcludeTags] = useState("");
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(25);
  const [previewMode, setPreviewMode] = useState<PreviewMode>("both");
  const [groupMode, setGroupMode] = useState<GroupMode>("flat");

  const isSearching = query.trim().length > 0;
  const offset = (page - 1) * pageSize;

  useEffect(() => {
    setPage(1);
  }, [harness]);

  // Server-side pagination
  const { data: convData, loading: convLoading } = useConversations({ sort, limit: pageSize, offset, harness });
  const { data: searchData, loading: searchLoading } = useSearch(query, mode, { harness });
  const { data: idxData } = useIndexStatus();

  const indexStatus = idxData?.data;
  const conversations = convData?.data ?? [];
  const searchResults = searchData?.data ?? [];
  const totalConvos = convData?.meta.total ?? 0;

  const includeList = parseTagInput(includeTags);
  const excludeList = parseTagInput(excludeTags);

  // Apply tag filters (client-side for search, server handles browse)
  const filterByTags = <T,>(items: T[], getConvTags: (item: T) => string[]): T[] => {
    return items.filter((item) => {
      const tags = getConvTags(item).map((t) => t.toLowerCase());
      if (includeList.length > 0 && !includeList.every((t) => tags.includes(t))) return false;
      if (excludeList.length > 0 && excludeList.some((t) => tags.includes(t))) return false;
      return true;
    });
  };

  const filteredResults = filterByTags(searchResults, (r) => (r as any).conversation?.tags ?? []);

  // Pagination — server-side for browse, client-side for search
  const totalFiltered = isSearching ? filteredResults.length : totalConvos;
  const totalPages = Math.max(1, Math.ceil(totalFiltered / pageSize));
  const safePage = Math.min(page, totalPages);

  const paginatedSearchResults = filteredResults.slice((safePage - 1) * pageSize, safePage * pageSize);

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    setQuery(inputValue);
    setPage(1);
    if (inputValue.trim()) {
      setSearchParams({ q: inputValue, mode });
    } else {
      setSearchParams({});
    }
  };

  const clearSearch = () => {
    setInputValue("");
    setQuery("");
    setPage(1);
    setSearchParams({});
  };

  const loading = isSearching ? searchLoading : convLoading;

  const lastIndexed = indexStatus?.lastIndexed
    ? new Date(indexStatus.lastIndexed).toLocaleString()
    : "Never";

  // Group conversations by project for browse mode
  const groups = new Map<string, typeof conversations>();
  if (groupMode === "grouped") {
    for (const c of conversations) {
      const key = c.projectPath;
      if (!groups.has(key)) groups.set(key, []);
      groups.get(key)!.push(c);
    }
  }

  const renderPreview = (c: { firstMessage?: string; lastMessage?: string }) => {
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

  const renderConversationRow = (c: typeof conversations[0]) => (
    <button
      key={c.id}
      onClick={() => navigate(`/thread/${c.id}`)}
      className="flex w-full items-start gap-3 rounded-md px-3 py-2.5 text-left hover:bg-surface-active transition-colors"
    >
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2">
          <span className="font-mono text-xs text-text-dim">{c.id.slice(0, 8)}</span>
          <span className="rounded border border-border-subtle px-1.5 py-0.5 text-[10px] uppercase text-text-dim">{c.harness}</span>
          <span className="flex-1 truncate text-sm text-text-primary">
            <ConversationTitle title={c.title} />
          </span>
          <span className="text-xs text-text-dim shrink-0">{c.messageCount} msgs</span>
          <span className="text-xs text-text-dim shrink-0">{new Date(c.updatedAt).toLocaleDateString()}</span>
          {c.status !== "active" && (
            <span className="rounded-full bg-surface-active px-2 py-0.5 text-xs text-text-dim shrink-0">{c.status}</span>
          )}
        </div>
        {renderPreview(c)}
      </div>
    </button>
  );

  return (
    <div className="mx-auto max-w-5xl space-y-5">

      {/* Search bar */}
      <form onSubmit={handleSearch} className="flex h-12 items-center rounded-lg border border-border-subtle bg-surface-raised px-4 focus-within:border-glow focus-within:shadow-[0_0_8px_rgba(6,182,212,0.1)]">
        <span className="mr-3 text-text-muted">⌕</span>
        <input
          type="text"
          value={inputValue}
          onChange={(e) => setInputValue(e.target.value)}
          placeholder="Search conversations..."
          className="flex-1 bg-transparent text-sm text-white placeholder:text-text-dim outline-none"
          autoFocus
        />
        {inputValue && (
          <button type="button" onClick={clearSearch} className="mr-2 text-xs text-text-dim hover:text-text-muted">Clear</button>
        )}
        <div className="flex gap-1">
          <button
            type="button"
            onClick={() => setMode("fts")}
            className={`rounded-full px-3 py-1 text-xs font-medium transition-colors ${
              mode === "fts" ? "bg-glow text-void" : "bg-surface-active text-text-muted"
            }`}
          >
            Text
          </button>
          <button
            type="button"
            onClick={() => setMode("semantic")}
            className={`rounded-full px-3 py-1 text-xs font-medium transition-colors ${
              mode === "semantic" ? "bg-glow text-void" : "bg-surface-active text-text-muted"
            }`}
          >
            Semantic
          </button>
        </div>
      </form>

      {/* Stats row */}
      <div className="grid grid-cols-3 gap-3">
        <div className="rounded-lg border border-border-subtle bg-surface-raised p-3">
          <p className="font-mono text-lg font-medium text-white">{totalConvos}</p>
          <p className="text-xs uppercase tracking-wider text-text-dim">Conversations</p>
        </div>
        <div className="rounded-lg border border-border-subtle bg-surface-raised p-3">
          <p className="font-mono text-lg font-medium text-white">{indexStatus?.conversationCount ?? 0}</p>
          <p className="text-xs uppercase tracking-wider text-text-dim">Indexed</p>
        </div>
        <div className="rounded-lg border border-border-subtle bg-surface-raised p-3">
          <p className="font-mono text-sm font-medium text-text-primary truncate">{lastIndexed}</p>
          <p className="text-xs uppercase tracking-wider text-text-dim">Last Indexed</p>
        </div>
      </div>

      {/* Filters + sort + toggles row */}
      <div className="flex flex-wrap items-center gap-3">
        {!isSearching && (
          <select
            value={sort}
            onChange={(e) => { setSort(e.target.value as SortOption); setPage(1); }}
            className="rounded-md border border-border-subtle bg-surface-raised px-2 py-1.5 text-xs text-text-primary outline-none"
          >
            <option value="updated_at">Last Updated</option>
            <option value="started_at">Date Started</option>
            <option value="message_count">Message Count</option>
            <option value="title">Title</option>
          </select>
        )}
        <div className="flex items-center gap-1.5">
          <label className="text-xs text-text-muted">Include:</label>
          <input
            type="text"
            value={includeTags}
            onChange={(e) => { setIncludeTags(e.target.value); setPage(1); }}
            placeholder="tags..."
            className="w-28 rounded-md border border-border-subtle bg-void px-2 py-1 text-xs text-text-primary outline-none placeholder:text-text-dim"
          />
        </div>
        <div className="flex items-center gap-1.5">
          <label className="text-xs text-text-muted">Exclude:</label>
          <input
            type="text"
            value={excludeTags}
            onChange={(e) => { setExcludeTags(e.target.value); setPage(1); }}
            placeholder="tags..."
            className="w-28 rounded-md border border-border-subtle bg-void px-2 py-1 text-xs text-text-primary outline-none placeholder:text-text-dim"
          />
        </div>

        {/* Preview toggle */}
        {!isSearching && (
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
        )}

        {/* Group toggle */}
        {!isSearching && (
          <div className="flex items-center gap-0.5">
            {(["grouped", "flat"] as GroupMode[]).map((gm) => (
              <button
                key={gm}
                type="button"
                onClick={() => setGroupMode(gm)}
                className={`rounded-full px-2.5 py-0.5 text-xs font-medium transition-colors ${
                  groupMode === gm ? "bg-glow text-void" : "bg-surface-active text-text-muted hover:text-text-primary"
                }`}
              >
                {gm === "grouped" ? "Grouped" : "Flat"}
              </button>
            ))}
          </div>
        )}

        <div className="ml-auto flex items-center gap-2">
          <span className="text-xs text-text-dim">{totalFiltered} results</span>
          {!isSearching && (
            <select
              value={pageSize}
              onChange={(e) => { setPageSize(Number(e.target.value)); setPage(1); }}
              className="rounded-md border border-border-subtle bg-surface-raised px-2 py-1 text-xs text-text-primary outline-none"
            >
              <option value={25}>25</option>
              <option value={50}>50</option>
              <option value={100}>100</option>
            </select>
          )}
        </div>
      </div>

      {/* Loading / empty */}
      {loading && <p className="text-sm text-text-muted py-4">Loading...</p>}

      {!loading && totalFiltered === 0 && (
        <p className="text-sm text-text-muted py-4">
          {isSearching
            ? `No results for "${query}". Try a different search or clear filters.`
            : "No conversations indexed. Run llm-toolkit index to get started."}
        </p>
      )}

      {/* Search results */}
      {isSearching && !loading && paginatedSearchResults.length > 0 && (
        <div className="space-y-2">
          {paginatedSearchResults.map((r: any, i: number) => (
            <button
              key={i}
              onClick={() => navigate(`/thread/${r.conversation.id}`)}
              className="block w-full rounded-lg border border-border-subtle bg-surface-raised p-4 text-left hover:border-glow/30 transition-colors"
            >
              <div className="flex items-center gap-2 mb-1">
                <span className="font-mono text-xs text-text-dim">{r.conversation.id.slice(0, 8)}</span>
                <span className="rounded border border-border-subtle px-1.5 py-0.5 text-[10px] uppercase text-text-dim">{r.conversation.harness}</span>
                <span className="text-xs text-glow">[{shortProject(r.conversation.projectPath)}]</span>
                <span className="flex-1 truncate text-sm font-medium text-white">
                  <ConversationTitle title={r.conversation.title} />
                </span>
              </div>
              {r.snippet && (
                <p className="text-xs text-text-muted">{cleanSnippet(r.snippet)}</p>
              )}
            </button>
          ))}
        </div>
      )}

      {/* Browse results */}
      {!isSearching && !loading && (
        <>
          {groupMode === "grouped" ? (
            [...groups.entries()].map(([project, convs]) => (
              <div key={project}>
                <div className="flex items-center gap-2 mb-2">
                  <button onClick={() => navigate(`/projects/${encodeURIComponent(project)}`)} className="text-sm font-medium text-glow hover:text-glow-bright hover:underline transition-colors" title={project}>{shortProject(project)}</button>
                  <span className="text-xs text-text-dim">({convs.length})</span>
                </div>
                <div className="space-y-1 mb-4">
                  {convs.map((c) => renderConversationRow(c))}
                </div>
              </div>
            ))
          ) : (
            <div className="space-y-1">
              {conversations.map((c) => renderConversationRow(c))}
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
        </>
      )}
    </div>
  );
}

function stripToolUse(text: string): string {
  // Strip common tool-use JSON prefixes from message previews
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

function shortProject(path: string): string {
  const parts = path.split("/").filter(Boolean);
  return parts.length > 2 ? parts.slice(-2).join("/") : path;
}

function cleanSnippet(snippet: string): string {
  return snippet.replace(/<<</g, "").replace(/>>>/g, "");
}
