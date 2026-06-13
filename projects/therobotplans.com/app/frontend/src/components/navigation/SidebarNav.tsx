"use client";

import React, { useState } from "react";

/**
 * SidebarNav — Hierarchical sidebar with sections, icons, badge counts, collapsible groups.
 *
 * @example
 * ```tsx
 * <SidebarNav
 *   sections={[
 *     { id: "work", label: "Work", icon: "📋", items: [
 *       { id: "today", label: "Today", href: "/today", badgeCount: 5 },
 *       { id: "inbox", label: "Inbox", href: "/inbox", badgeCount: 12 },
 *     ]},
 *   ]}
 *   activeItem="today"
 *   onItemClick={(id, href) => router.push(href)}
 * />
 * ```
 */

interface NavItem { id: string; label: string; href: string; badgeCount?: number; icon?: string; }
interface NavSection { id: string; label: string; icon?: string; items: NavItem[]; collapsed?: boolean; }

interface SidebarNavProps {
  sections: NavSection[];
  activeItem?: string;
  onItemClick?: (id: string, href: string) => void;
  collapsible?: boolean;
  variant?: "compact" | "expanded";
}

export function SidebarNav({ sections, activeItem, onItemClick, collapsible = true, variant = "expanded" }: SidebarNavProps) {
  const [collapsed, setCollapsed] = useState<Record<string, boolean>>(() => {
    const init: Record<string, boolean> = {};
    sections.forEach((s) => { if (s.collapsed) init[s.id] = true; });
    return init;
  });

  const toggleSection = (id: string) => setCollapsed((c) => ({ ...c, [id]: !c[id] }));

  const isCompact = variant === "compact";

  return (
    <nav aria-label="Sidebar navigation" style={{ display: "flex", flexDirection: "column", gap: "var(--space-2)", width: isCompact ? 48 : 220, padding: "var(--space-2)", background: "var(--surface)", borderRight: "1px solid var(--border)", height: "100%", overflow: "auto" }}>
      {sections.map((section) => {
        const isCollapsed = !!collapsed[section.id];
        return (
          <div key={section.id}>
            {/* Section header */}
            <button type="button" onClick={collapsible ? () => toggleSection(section.id) : undefined} aria-expanded={!isCollapsed} style={{ display: "flex", alignItems: "center", gap: "6px", width: "100%", padding: "4px 8px", background: "none", border: "none", cursor: collapsible ? "pointer" : "default", textAlign: "left" }}>
              {section.icon && <span style={{ fontSize: isCompact ? "var(--font-size-base)" : "var(--font-size-xs)", flexShrink: 0 }}>{section.icon}</span>}
              {!isCompact && (
                <>
                  <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.06em", color: "var(--text-muted)", flex: 1 }}>{section.label}</span>
                  {collapsible && <span style={{ fontSize: "var(--font-size-xs)", color: "var(--text-muted)", transform: isCollapsed ? "rotate(-90deg)" : "none", transition: "transform 0.15s" }}>▾</span>}
                </>
              )}
            </button>

            {/* Items */}
            {!isCollapsed && (
              <div style={{ display: "flex", flexDirection: "column", gap: "1px", marginTop: "2px" }}>
                {section.items.map((item) => {
                  const active = item.id === activeItem;
                  return (
                    <button key={item.id} type="button" onClick={() => onItemClick?.(item.id, item.href)} aria-current={active ? "page" : undefined} style={{ display: "flex", alignItems: "center", gap: "6px", padding: isCompact ? "6px" : "4px 8px 4px 16px", borderRadius: "var(--radius, 6px)", background: active ? "color-mix(in srgb, var(--info, var(--blue)) 10%, transparent)" : "transparent", border: "none", cursor: "pointer", width: "100%", textAlign: "left", justifyContent: isCompact ? "center" : "flex-start" }}>
                      {item.icon && <span style={{ fontSize: "var(--font-size-sm)" }}>{item.icon}</span>}
                      {!isCompact && <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-sm)", color: active ? "var(--info, var(--blue))" : "var(--text)", fontWeight: active ? 600 : 400, flex: 1, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{item.label}</span>}
                      {item.badgeCount != null && item.badgeCount > 0 && (
                        <span style={{ minWidth: 18, height: 18, borderRadius: "999px", background: "var(--error)", color: "#fff", fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 700, display: "flex", alignItems: "center", justifyContent: "center", padding: "0 4px", lineHeight: 1 }}>
                          {item.badgeCount > 99 ? "99+" : item.badgeCount}
                        </span>
                      )}
                    </button>
                  );
                })}
              </div>
            )}
          </div>
        );
      })}
    </nav>
  );
}

export default SidebarNav;
