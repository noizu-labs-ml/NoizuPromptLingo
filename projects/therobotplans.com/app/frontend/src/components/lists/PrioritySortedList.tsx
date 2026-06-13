"use client";

import React from "react";

/**
 * PrioritySortedList — Ranked list sorted by urgency/importance with drag-drop reorder.
 *
 * @example
 * ```tsx
 * <PrioritySortedList items={tasks} onReorder={handleReorder} showBadges />
 * ```
 */

interface ListItem { id: string; title: string; priority?: "p0" | "p1" | "p2" | "p3"; dueDate?: string; project?: string; assignee?: string; badges?: string[]; }
type ListVariant = "compact" | "expanded";

interface PrioritySortedListProps {
  items: ListItem[];
  onReorder?: (fromIndex: number, toIndex: number) => void;
  onItemClick?: (id: string) => void;
  showBadges?: boolean;
  selectable?: boolean;
  variant?: ListVariant;
}

const pColors: Record<string, string> = { p0: "var(--error)", p1: "var(--warning)", p2: "var(--info, var(--blue))", p3: "var(--text-muted)" };

export function PrioritySortedList({ items, onReorder, onItemClick, showBadges = false, variant = "compact" }: PrioritySortedListProps) {
  return (
    <div role="list" aria-label="Priority sorted list" style={{ display: "flex", flexDirection: "column", gap: "2px" }}>
      {items.length === 0 && <span style={{ padding: "var(--space-4)", textAlign: "center", color: "var(--text-muted)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-sm)", fontStyle: "italic" }}>No items</span>}
      {items.map((item, i) => (
        <div
          key={item.id}
          role="listitem"
          draggable={!!onReorder}
          onDragStart={(e) => e.dataTransfer.setData("text/plain", String(i))}
          onDragOver={(e) => e.preventDefault()}
          onDrop={(e) => { e.preventDefault(); const from = parseInt(e.dataTransfer.getData("text/plain")); if (!isNaN(from) && onReorder) onReorder(from, i); }}
          onClick={() => onItemClick?.(item.id)}
          style={{ display: "flex", alignItems: "center", gap: "8px", padding: variant === "compact" ? "6px 10px" : "8px 12px", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--surface)", cursor: onItemClick ? "pointer" : onReorder ? "grab" : "default" }}
        >
          {/* Rank number */}
          <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)", width: 16, textAlign: "right", flexShrink: 0 }}>{i + 1}</span>
          {/* Priority dot */}
          {item.priority && <span style={{ width: 6, height: 6, borderRadius: "50%", background: pColors[item.priority] ?? "var(--text-muted)", flexShrink: 0 }} />}
          {/* Title */}
          <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-sm)", color: "var(--text)", flex: 1, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{item.title}</span>
          {/* Metadata (expanded) */}
          {variant === "expanded" && (
            <>
              {item.assignee && <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)" }}>{item.assignee}</span>}
              {item.dueDate && <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)" }}>📅 {item.dueDate}</span>}
              {item.project && <span style={{ padding: "1px 6px", borderRadius: "999px", background: "color-mix(in srgb, var(--text-muted) 10%, transparent)", fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)" }}>{item.project}</span>}
            </>
          )}
          {/* Badges */}
          {showBadges && item.badges?.map((b, j) => (
            <span key={j} style={{ padding: "1px 6px", borderRadius: "999px", background: "color-mix(in srgb, var(--info, var(--blue)) 10%, transparent)", color: "var(--info, var(--blue))", fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)" }}>{b}</span>
          ))}
        </div>
      ))}
    </div>
  );
}

export default PrioritySortedList;
