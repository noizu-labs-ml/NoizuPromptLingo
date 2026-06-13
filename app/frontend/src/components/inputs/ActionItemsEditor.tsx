"use client";

import React, { useState } from "react";

/**
 * ActionItemsEditor — Editable follow-up task list from retros/reviews that persists to backlogs.
 *
 * @example
 * ```tsx
 * <ActionItemsEditor items={items} onAdd={addItem} onComplete={completeItem} showAssignee variant="expanded" />
 * ```
 */

interface ActionItem { id: string; title: string; done: boolean; assignee?: string; dueDate?: string; project?: string; }

interface ActionItemsEditorProps {
  items: ActionItem[];
  onAdd?: (title: string) => void;
  onComplete?: (id: string) => void;
  onRemove?: (id: string) => void;
  showAssignee?: boolean;
  variant?: "compact" | "expanded";
}

export function ActionItemsEditor({ items, onAdd, onComplete, onRemove, showAssignee = false, variant = "compact" }: ActionItemsEditorProps) {
  const [newTitle, setNewTitle] = useState("");

  const handleAdd = () => { if (newTitle.trim() && onAdd) { onAdd(newTitle.trim()); setNewTitle(""); } };

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "4px" }}>
      {items.map((item) => (
        <div key={item.id} style={{ display: "flex", alignItems: "center", gap: "8px", padding: variant === "expanded" ? "6px 10px" : "4px 8px", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--surface)", opacity: item.done ? 0.6 : 1 }}>
          <input type="checkbox" checked={item.done} onChange={() => onComplete?.(item.id)} aria-label={`Mark "${item.title}" complete`} style={{ flexShrink: 0 }} />
          <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-sm)", color: "var(--text)", flex: 1, textDecoration: item.done ? "line-through" : "none", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{item.title}</span>
          {variant === "expanded" && showAssignee && item.assignee && (
            <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)" }}>{item.assignee}</span>
          )}
          {variant === "expanded" && item.dueDate && (
            <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)" }}>📅 {item.dueDate}</span>
          )}
          {variant === "expanded" && item.project && (
            <span style={{ padding: "1px 6px", borderRadius: "999px", background: "color-mix(in srgb, var(--text-muted) 10%, transparent)", fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)" }}>{item.project}</span>
          )}
          {onRemove && <button type="button" onClick={() => onRemove(item.id)} style={{ background: "none", border: "none", color: "var(--text-muted)", cursor: "pointer", fontSize: "var(--font-size-xs)", padding: "0 2px" }}>✕</button>}
        </div>
      ))}
      {onAdd && (
        <div style={{ display: "flex", gap: "4px", marginTop: "2px" }}>
          <input type="text" value={newTitle} onChange={(e) => setNewTitle(e.target.value)} onKeyDown={(e) => e.key === "Enter" && handleAdd()} placeholder="Add action item..." style={{ flex: 1, padding: "4px 8px", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", outline: "none" }} />
          <button type="button" onClick={handleAdd} style={{ padding: "4px 10px", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--info, var(--blue))", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", fontWeight: 600, cursor: "pointer" }}>+ Add</button>
        </div>
      )}
    </div>
  );
}

export default ActionItemsEditor;
