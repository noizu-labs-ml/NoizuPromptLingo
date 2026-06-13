"use client";

import React from "react";

/**
 * TemplateCard — Reusable template preview card with name, type, usage count, and quick-apply.
 *
 * @example
 * ```tsx
 * <TemplateCard name="Sprint Retrospective" type="project" usageCount={42} variant="compact" />
 * <TemplateCard name="Bug Report" type="document" usageCount={128} description="Standard bug report template with reproduction steps" versionCount={3} onApply={handleApply} variant="expanded" />
 * ```
 */

type TemplateType = "project" | "document" | "checklist" | "prompt";
type TemplateVariant = "compact" | "expanded";

interface TemplateCardProps {
  name: string;
  type: TemplateType;
  usageCount?: number;
  description?: string;
  versionCount?: number;
  variant?: TemplateVariant;
  onApply?: () => void;
  onClick?: () => void;
}

const typeConfig: Record<TemplateType, { color: string; bg: string; icon: string }> = {
  project: { color: "var(--info, var(--blue))", bg: "color-mix(in srgb, var(--info, var(--blue)) 12%, transparent)", icon: "📋" },
  document: { color: "var(--success)", bg: "color-mix(in srgb, var(--success) 12%, transparent)", icon: "📄" },
  checklist: { color: "var(--warning)", bg: "color-mix(in srgb, var(--warning) 12%, transparent)", icon: "✓" },
  prompt: { color: "var(--violet, #7C3AED)", bg: "color-mix(in srgb, var(--violet, #7C3AED) 12%, transparent)", icon: "⚡" },
};

export function TemplateCard({ name, type, usageCount, description, versionCount, variant = "compact", onApply, onClick }: TemplateCardProps) {
  const tc = typeConfig[type];
  const interactive = !!onClick;

  if (variant === "compact") {
    return (
      <div role={interactive ? "button" : undefined} tabIndex={interactive ? 0 : undefined} onClick={onClick} onKeyDown={interactive ? (e) => e.key === "Enter" && onClick?.() : undefined} aria-label={name} style={{ display: "flex", alignItems: "center", gap: "8px", padding: "var(--space-2) var(--space-3)", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--surface)", cursor: interactive ? "pointer" : "default" }}>
        <span style={{ fontSize: "var(--font-size-sm)" }}>{tc.icon}</span>
        <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-sm)", fontWeight: 500, color: "var(--text)", flex: 1, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{name}</span>
        <span style={{ padding: "1px 6px", borderRadius: "999px", background: tc.bg, color: tc.color, fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 600 }}>{type}</span>
        {usageCount != null && <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)" }}>{usageCount} uses</span>}
      </div>
    );
  }

  return (
    <div role={interactive ? "button" : undefined} tabIndex={interactive ? 0 : undefined} onClick={onClick} onKeyDown={interactive ? (e) => e.key === "Enter" && onClick?.() : undefined} aria-label={name} style={{ padding: "var(--space-3)", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--surface)", cursor: interactive ? "pointer" : "default", display: "flex", flexDirection: "column", gap: "var(--space-2)" }}>
      <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
        <span style={{ fontSize: "var(--font-size-base)" }}>{tc.icon}</span>
        <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-base)", fontWeight: 600, color: "var(--text)", flex: 1 }}>{name}</span>
        <span style={{ padding: "2px 8px", borderRadius: "999px", background: tc.bg, color: tc.color, fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 600 }}>{type}</span>
      </div>
      {description && <p style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", color: "var(--text-secondary)", margin: 0, lineHeight: 1.4 }}>{description}</p>}
      <div style={{ display: "flex", alignItems: "center", gap: "var(--space-3)" }}>
        {usageCount != null && <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)" }}>{usageCount} uses</span>}
        {versionCount != null && <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)" }}>v{versionCount}</span>}
        {onApply && (
          <button type="button" onClick={(e) => { e.stopPropagation(); onApply(); }} style={{ marginLeft: "auto", padding: "3px 12px", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--surface)", color: tc.color, fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", fontWeight: 600, cursor: "pointer" }}>
            Apply
          </button>
        )}
      </div>
    </div>
  );
}

export default TemplateCard;
