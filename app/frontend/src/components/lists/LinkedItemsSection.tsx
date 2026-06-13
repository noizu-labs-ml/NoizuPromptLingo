"use client";

import React from "react";

/**
 * LinkedItemsSection — Section showing related/linked entities with type badges and navigate actions.
 *
 * @example
 * ```tsx
 * <LinkedItemsSection items={[{ id: "1", type: "bug", title: "Auth timeout", status: "open" }]} onNavigate={(id) => router.push(`/items/${id}`)} addEnabled />
 * ```
 */

interface LinkedItem { id: string; type: "bug" | "incident" | "pr" | "deploy" | "doc" | "task"; title: string; status?: string; }
type LinkedVariant = "inline" | "compact" | "expanded";

interface LinkedItemsSectionProps {
  items: LinkedItem[];
  onNavigate?: (id: string) => void;
  onAdd?: () => void;
  onRemove?: (id: string) => void;
  addEnabled?: boolean;
  variant?: LinkedVariant;
}

const typeConfig: Record<string, { color: string; icon: string }> = {
  bug: { color: "var(--error)", icon: "🐛" },
  incident: { color: "var(--warning)", icon: "⚠" },
  pr: { color: "var(--info, var(--blue))", icon: "↗" },
  deploy: { color: "var(--success)", icon: "🚀" },
  doc: { color: "var(--text-secondary)", icon: "📄" },
  task: { color: "var(--violet, #7C3AED)", icon: "✓" },
};

export function LinkedItemsSection({ items, onNavigate, onAdd, onRemove, addEnabled = false, variant = "compact" }: LinkedItemsSectionProps) {
  if (variant === "inline") {
    return (
      <div style={{ display: "flex", flexWrap: "wrap", gap: "4px", alignItems: "center" }}>
        {items.map((item) => {
          const tc = typeConfig[item.type] ?? { color: "var(--text-muted)", icon: "●" };
          return (
            <span key={item.id} onClick={() => onNavigate?.(item.id)} style={{ display: "inline-flex", alignItems: "center", gap: "3px", padding: "1px 8px", borderRadius: "999px", background: `color-mix(in srgb, ${tc.color} 10%, transparent)`, color: tc.color, fontFamily: "var(--font-body)", fontSize: "var(--font-size-2xs, 10px)", cursor: onNavigate ? "pointer" : "default" }}>
              {tc.icon} {item.title}
            </span>
          );
        })}
        {addEnabled && onAdd && <button type="button" onClick={onAdd} style={{ padding: "1px 6px", borderRadius: "999px", border: "1px dashed var(--border)", background: "none", color: "var(--text-muted)", fontSize: "var(--font-size-2xs, 10px)", cursor: "pointer" }}>+ Link</button>}
      </div>
    );
  }

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "4px" }}>
      {items.map((item) => {
        const tc = typeConfig[item.type] ?? { color: "var(--text-muted)", icon: "●" };
        return (
          <div key={item.id} onClick={() => onNavigate?.(item.id)} style={{ display: "flex", alignItems: "center", gap: "8px", padding: variant === "expanded" ? "6px 10px" : "4px 8px", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--surface)", cursor: onNavigate ? "pointer" : "default" }}>
            <span style={{ fontSize: "var(--font-size-sm)" }}>{tc.icon}</span>
            <span style={{ padding: "1px 6px", borderRadius: "999px", background: `color-mix(in srgb, ${tc.color} 12%, transparent)`, color: tc.color, fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 600 }}>{item.type}</span>
            <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", color: "var(--text)", flex: 1, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{item.title}</span>
            {item.status && variant === "expanded" && <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)" }}>{item.status}</span>}
            {onRemove && <button type="button" onClick={(e) => { e.stopPropagation(); onRemove(item.id); }} style={{ background: "none", border: "none", color: "var(--text-muted)", cursor: "pointer", fontSize: "var(--font-size-xs)", padding: "0 2px" }}>✕</button>}
          </div>
        );
      })}
      {addEnabled && onAdd && <button type="button" onClick={onAdd} style={{ padding: "4px 8px", borderRadius: "var(--radius, 6px)", border: "1px dashed var(--border)", background: "none", color: "var(--text-muted)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", cursor: "pointer" }}>⊕ Add linked item</button>}
    </div>
  );
}

export default LinkedItemsSection;
