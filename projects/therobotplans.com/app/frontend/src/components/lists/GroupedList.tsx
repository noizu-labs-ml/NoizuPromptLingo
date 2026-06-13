"use client";

import React, { useState } from "react";

/**
 * GroupedList — Items organized under collapsible group headers with summary counts.
 *
 * @example
 * ```tsx
 * <GroupedList groups={[{ header: "High Priority", items: [...], count: 5 }]} collapsible />
 * ```
 */

interface GroupItem { id: string; label: string; [key: string]: unknown; }
interface Group { header: string; items: GroupItem[]; count?: number; }

interface GroupedListProps {
  groups: Group[];
  collapsible?: boolean;
  defaultExpanded?: boolean;
  emptyMessage?: string;
  onItemClick?: (id: string) => void;
  renderItem?: (item: GroupItem) => React.ReactNode;
}

export function GroupedList({ groups, collapsible = true, defaultExpanded = true, emptyMessage = "No items", onItemClick, renderItem }: GroupedListProps) {
  const [collapsed, setCollapsed] = useState<Record<string, boolean>>(() => {
    const init: Record<string, boolean> = {};
    if (!defaultExpanded) groups.forEach((g) => { init[g.header] = true; });
    return init;
  });

  if (groups.length === 0) return <span style={{ padding: "var(--space-4)", textAlign: "center", display: "block", color: "var(--text-muted)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-sm)", fontStyle: "italic" }}>{emptyMessage}</span>;

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "var(--space-2)" }}>
      {groups.map((group) => {
        const isCollapsed = !!collapsed[group.header];
        return (
          <div key={group.header}>
            <button type="button" onClick={collapsible ? () => setCollapsed((c) => ({ ...c, [group.header]: !c[group.header] })) : undefined} aria-expanded={!isCollapsed} style={{ display: "flex", alignItems: "center", gap: "6px", width: "100%", padding: "4px 8px", background: "none", border: "none", cursor: collapsible ? "pointer" : "default", textAlign: "left" }}>
              {collapsible && <span style={{ fontSize: "var(--font-size-xs)", color: "var(--text-muted)", transform: isCollapsed ? "rotate(-90deg)" : "none", transition: "transform 0.15s" }}>▾</span>}
              <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-sm)", fontWeight: 600, color: "var(--text)", flex: 1 }}>{group.header}</span>
              <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)", padding: "1px 6px", borderRadius: "999px", background: "color-mix(in srgb, var(--text-muted) 10%, transparent)" }}>{group.count ?? group.items.length}</span>
            </button>
            {!isCollapsed && (
              <div style={{ display: "flex", flexDirection: "column", gap: "2px", paddingLeft: collapsible ? 16 : 0, marginTop: 2 }}>
                {group.items.map((item) => renderItem ? <div key={item.id}>{renderItem(item)}</div> : (
                  <div key={item.id} onClick={() => onItemClick?.(item.id)} style={{ padding: "4px 8px", borderRadius: 4, cursor: onItemClick ? "pointer" : "default", fontFamily: "var(--font-body)", fontSize: "var(--font-size-sm)", color: "var(--text)" }}>{item.label}</div>
                ))}
              </div>
            )}
          </div>
        );
      })}
    </div>
  );
}

export default GroupedList;
