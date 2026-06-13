"use client";

import React, { useState, useRef, useEffect, useCallback } from "react";

/**
 * SearchInput — Search field with instant results, keyboard navigation, and recent history.
 *
 * @example
 * ```tsx
 * <SearchInput placeholder="Search tasks..." onSearch={handleSearch} showRecent />
 * ```
 */

interface SearchResult { id: string; label: string; type?: string; }

interface SearchInputProps {
  placeholder?: string;
  onSearch: (query: string) => SearchResult[] | Promise<SearchResult[]>;
  onSelect?: (result: SearchResult) => void;
  debounceMs?: number;
  showRecent?: boolean;
  recentSearches?: string[];
}

export function SearchInput({ placeholder = "Search...", onSearch, onSelect, debounceMs = 200, showRecent = false, recentSearches = [] }: SearchInputProps) {
  const [query, setQuery] = useState("");
  const [results, setResults] = useState<SearchResult[]>([]);
  const [focused, setFocused] = useState(false);
  const [activeIndex, setActiveIndex] = useState(-1);
  const timerRef = useRef<ReturnType<typeof setTimeout>>();
  const inputRef = useRef<HTMLInputElement>(null);

  const search = useCallback(async (q: string) => {
    if (!q.trim()) { setResults([]); return; }
    const r = await onSearch(q);
    setResults(r);
    setActiveIndex(-1);
  }, [onSearch]);

  useEffect(() => {
    if (timerRef.current) clearTimeout(timerRef.current);
    timerRef.current = setTimeout(() => search(query), debounceMs);
    return () => { if (timerRef.current) clearTimeout(timerRef.current); };
  }, [query, debounceMs, search]);

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === "ArrowDown") { e.preventDefault(); setActiveIndex((i) => Math.min(i + 1, results.length - 1)); }
    if (e.key === "ArrowUp") { e.preventDefault(); setActiveIndex((i) => Math.max(i - 1, -1)); }
    if (e.key === "Enter" && activeIndex >= 0 && results[activeIndex]) { onSelect?.(results[activeIndex]); setQuery(""); setResults([]); }
    if (e.key === "Escape") { setFocused(false); setResults([]); }
  };

  const showDropdown = focused && (results.length > 0 || (showRecent && !query && recentSearches.length > 0));

  return (
    <div style={{ position: "relative" }}>
      <div style={{ display: "flex", alignItems: "center", gap: "6px", padding: "4px 10px", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--surface)" }}>
        <span style={{ color: "var(--text-muted)", fontSize: "var(--font-size-sm)" }}>🔍</span>
        <input ref={inputRef} type="text" value={query} onChange={(e) => setQuery(e.target.value)} onFocus={() => setFocused(true)} onBlur={() => setTimeout(() => setFocused(false), 150)} onKeyDown={handleKeyDown} placeholder={placeholder} aria-label={placeholder} style={{ flex: 1, background: "none", border: "none", outline: "none", color: "var(--text)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-sm)" }} />
        {query && <button type="button" onClick={() => { setQuery(""); setResults([]); }} style={{ background: "none", border: "none", color: "var(--text-muted)", cursor: "pointer", fontSize: "var(--font-size-xs)", padding: 0 }}>✕</button>}
      </div>
      {showDropdown && (
        <div style={{ position: "absolute", top: "100%", left: 0, right: 0, marginTop: 4, borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--bg)", boxShadow: "var(--shadow, 0 4px 12px rgba(0,0,0,0.1))", zIndex: 20, maxHeight: 240, overflow: "auto" }}>
          {results.length > 0 ? results.map((r, i) => (
            <div key={r.id} onClick={() => { onSelect?.(r); setQuery(""); setResults([]); }} style={{ padding: "6px 10px", cursor: "pointer", background: i === activeIndex ? "color-mix(in srgb, var(--info, var(--blue)) 10%, transparent)" : "transparent", display: "flex", alignItems: "center", gap: "6px" }}>
              {r.type && <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)", padding: "1px 4px", borderRadius: 3, background: "color-mix(in srgb, var(--text-muted) 10%, transparent)" }}>{r.type}</span>}
              <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-sm)", color: "var(--text)" }}>{r.label}</span>
            </div>
          )) : showRecent && recentSearches.map((s, i) => (
            <div key={i} onClick={() => setQuery(s)} style={{ padding: "6px 10px", cursor: "pointer", display: "flex", alignItems: "center", gap: "6px" }}>
              <span style={{ color: "var(--text-muted)", fontSize: "var(--font-size-xs)" }}>🕐</span>
              <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-sm)", color: "var(--text-secondary)" }}>{s}</span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

export default SearchInput;
