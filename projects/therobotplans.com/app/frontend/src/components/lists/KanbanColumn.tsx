"use client";

import React, { useState } from "react";

/**
 * KanbanColumn — Vertical column of cards representing a workflow state with WIP limits and quick-add.
 * Depends on: ItemCard (T1).
 *
 * @example
 * ```tsx
 * <KanbanColumn title="In Progress" items={tasks} wipLimit={5} onDrop={handleDrop} quickAdd onQuickAdd={handleAdd} />
 * <KanbanColumn title="Done" items={doneTasks} variant="compact" />
 * ```
 */

type KanbanVariant = "compact" | "expanded";

interface KanbanItem { id: string; title: string; priority?: "p0" | "p1" | "p2" | "p3"; assignee?: string; }

interface KanbanColumnProps {
  title: string;
  items: KanbanItem[];
  wipLimit?: number;
  onDrop?: (itemId: string, columnId: string) => void;
  quickAdd?: boolean;
  onQuickAdd?: (title: string) => void;
  variant?: KanbanVariant;
  columnId?: string;
  renderItem?: (item: KanbanItem) => React.ReactNode;
}

const priorityColors: Record<string, string> = { p0: "var(--error)", p1: "var(--warning)", p2: "var(--info, var(--blue))", p3: "var(--text-muted)" };

export function KanbanColumn({ title, items, wipLimit, onDrop, quickAdd = false, onQuickAdd, variant = "expanded", columnId, renderItem }: KanbanColumnProps) {
  const [addingText, setAddingText] = useState("");
  const [showAdd, setShowAdd] = useState(false);
  const [collapsed, setCollapsed] = useState(variant === "compact");
  const wipViolation = wipLimit != null && items.length > wipLimit;

  const handleDragOver = (e: React.DragEvent) => { e.preventDefault(); e.dataTransfer.dropEffect = "move"; };
  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    const itemId = e.dataTransfer.getData("text/plain");
    if (itemId && onDrop) onDrop(itemId, columnId ?? title);
  };
  const handleAdd = () => {
    if (addingText.trim() && onQuickAdd) { onQuickAdd(addingText.trim()); setAddingText(""); setShowAdd(false); }
  };

  return (
    <div
      onDragOver={handleDragOver}
      onDrop={handleDrop}
      style={{ display: "flex", flexDirection: "column", width: collapsed ? 40 : 280, minHeight: 200, borderRadius: "var(--radius, 6px)", background: "color-mix(in srgb, var(--text-muted) 5%, transparent)", border: wipViolation ? "1px solid var(--error)" : "1px solid var(--border)", overflow: "hidden", flexShrink: 0, transition: "width 0.2s" }}
    >
      {/* Header */}
      <div
        onClick={() => variant === "compact" || collapsed ? setCollapsed(!collapsed) : undefined}
        style={{ display: "flex", alignItems: "center", gap: "6px", padding: collapsed ? "8px 4px" : "8px 12px", borderBottom: collapsed ? "none" : "1px solid var(--border)", cursor: variant === "compact" ? "pointer" : "default", ...(collapsed ? { writingMode: "vertical-rl", textOrientation: "mixed", height: "100%" } : {}) }}
      >
        <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-sm)", fontWeight: 600, color: "var(--text)", flex: collapsed ? undefined : 1 }}>{title}</span>
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: wipViolation ? "var(--error)" : "var(--text-muted)", fontWeight: wipViolation ? 700 : 400 }}>
          {items.length}{wipLimit != null ? `/${wipLimit}` : ""}
        </span>
        {wipViolation && !collapsed && <span title="WIP limit exceeded" style={{ color: "var(--error)", fontSize: "var(--font-size-xs)" }}>⚠</span>}
      </div>

      {!collapsed && (
        <>
          {/* Quick-add */}
          {quickAdd && (
            <div style={{ padding: "6px 8px", borderBottom: "1px solid var(--border)" }}>
              {showAdd ? (
                <div style={{ display: "flex", gap: "4px" }}>
                  <input type="text" value={addingText} onChange={(e) => setAddingText(e.target.value)} onKeyDown={(e) => e.key === "Enter" && handleAdd()} placeholder="Task title..." autoFocus style={{ flex: 1, padding: "3px 6px", borderRadius: 4, border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)" }} />
                  <button type="button" onClick={handleAdd} style={{ padding: "3px 8px", borderRadius: 4, border: "none", background: "var(--info, var(--blue))", color: "#fff", fontSize: "var(--font-size-xs)", cursor: "pointer" }}>+</button>
                  <button type="button" onClick={() => setShowAdd(false)} style={{ padding: "3px 6px", borderRadius: 4, border: "1px solid var(--border)", background: "none", color: "var(--text-muted)", fontSize: "var(--font-size-xs)", cursor: "pointer" }}>✕</button>
                </div>
              ) : (
                <button type="button" onClick={() => setShowAdd(true)} style={{ width: "100%", padding: "3px", borderRadius: 4, border: "1px dashed var(--border)", background: "none", color: "var(--text-muted)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", cursor: "pointer" }}>⊕ Add item</button>
              )}
            </div>
          )}

          {/* Cards */}
          <div style={{ flex: 1, overflow: "auto", padding: "6px 8px", display: "flex", flexDirection: "column", gap: "4px" }}>
            {items.length === 0 && <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", color: "var(--text-muted)", fontStyle: "italic", textAlign: "center", padding: "var(--space-4)" }}>No items</span>}
            {items.map((item) =>
              renderItem ? (
                <div key={item.id} draggable onDragStart={(e) => e.dataTransfer.setData("text/plain", item.id)}>{renderItem(item)}</div>
              ) : (
                <div
                  key={item.id}
                  draggable
                  onDragStart={(e) => e.dataTransfer.setData("text/plain", item.id)}
                  style={{ padding: "6px 8px", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--surface)", cursor: "grab", display: "flex", alignItems: "center", gap: "6px" }}
                >
                  {item.priority && <span style={{ width: 6, height: 6, borderRadius: "50%", background: priorityColors[item.priority] ?? "var(--text-muted)", flexShrink: 0 }} />}
                  <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", color: "var(--text)", flex: 1, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{item.title}</span>
                  {item.assignee && <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)" }}>{item.assignee}</span>}
                </div>
              )
            )}
          </div>
        </>
      )}
    </div>
  );
}

export default KanbanColumn;
