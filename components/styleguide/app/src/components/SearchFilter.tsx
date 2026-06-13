"use client";

import { useState, useCallback, useRef } from "react";

const HIDDEN_CLASS = "search-hidden";
const ATTR = "data-search-name";

function applyFilter(query: string) {
  const q = query.toLowerCase().trim();
  const all = document.querySelectorAll<HTMLElement>(`[${ATTR}]`);

  if (!q) {
    all.forEach((el) => el.classList.remove(HIDDEN_CLASS));
    return all.length;
  }

  // Convert to array, reverse for bottom-up (leaves first)
  const items = Array.from(all).reverse();

  // Pass 1: mark each element as match/no-match based on its own data attrs
  items.forEach((el) => {
    const text = [
      el.dataset.searchName,
      el.dataset.searchTitle,
      el.dataset.searchDescription,
    ]
      .filter(Boolean)
      .join(" ")
      .toLowerCase();

    if (text.includes(q)) {
      el.classList.remove(HIDDEN_CLASS);
    } else {
      el.classList.add(HIDDEN_CLASS);
    }
  });

  // Pass 2 (still bottom-up): un-hide parents that have visible children
  items.forEach((el) => {
    if (el.classList.contains(HIDDEN_CLASS)) return;
    // Walk up and un-hide any ancestor with data-search-name
    let parent = el.parentElement;
    while (parent) {
      if (parent.hasAttribute(ATTR)) {
        parent.classList.remove(HIDDEN_CLASS);
      }
      parent = parent.parentElement;
    }
  });

  // Pass 3: count visible leaf-level matches (items with no searchable children)
  let shown = 0;
  all.forEach((el) => {
    if (!el.classList.contains(HIDDEN_CLASS)) shown++;
  });

  return shown;
}

export function SearchFilter() {
  const [query, setQuery] = useState("");
  const [shown, setShown] = useState(-1); // -1 = no active filter
  const timerRef = useRef<ReturnType<typeof setTimeout>>(undefined);

  const handleChange = useCallback((value: string) => {
    setQuery(value);
    // Small debounce for DOM operations
    clearTimeout(timerRef.current);
    timerRef.current = setTimeout(() => {
      const count = applyFilter(value);
      setShown(value.trim() ? count : -1);
    }, 80);
  }, []);

  const handleClear = useCallback(() => {
    setQuery("");
    applyFilter("");
    setShown(-1);
  }, []);

  return (
    <div
      className="flex items-center gap-[var(--space-2)]"
      style={{
        padding: "var(--space-2) 0",
      }}
    >
      <div className="relative flex-1" style={{ maxWidth: 400 }}>
        <svg
          width="14" height="14" viewBox="0 0 14 14" fill="none"
          className="absolute left-[var(--space-2)] top-1/2 -translate-y-1/2 text-text-muted pointer-events-none"
        >
          <circle cx="6" cy="6" r="4.5" stroke="currentColor" strokeWidth="1.5" />
          <path d="M9.5 9.5L13 13" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
        </svg>
        <input
          type="text"
          value={query}
          onChange={(e) => handleChange(e.target.value)}
          placeholder="Search all sections…"
          className="hui combo-input w-full"
          style={{ paddingLeft: "var(--space-6)" }}
        />
        {query && (
          <button
            type="button"
            onClick={handleClear}
            className="absolute right-[var(--space-2)] top-1/2 -translate-y-1/2 text-text-muted hover:text-text"
            style={{ background: "none", border: "none", cursor: "pointer", padding: 2 }}
          >
            <svg width="12" height="12" viewBox="0 0 12 12" fill="none">
              <path d="M2 2l8 8M10 2l-8 8" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
            </svg>
          </button>
        )}
      </div>
      {shown >= 0 && (
        <span className="font-mono text-[length:var(--font-size-xs)] text-text-muted shrink-0">
          {shown} matches
        </span>
      )}
    </div>
  );
}
