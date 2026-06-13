"use client";

import React from "react";

/**
 * TabBar — Horizontal tab switcher for content categories within a view.
 *
 * @example
 * ```tsx
 * <TabBar tabs={[{ id: "all", label: "All" }, { id: "active", label: "Active", count: 5 }]} activeTab="all" onChange={setTab} />
 * <TabBar tabs={[{ id: "t1", label: "Templates", icon: "📋" }]} activeTab="t1" onChange={setTab} variant="compact" />
 * ```
 */

interface Tab { id: string; label: string; icon?: string; count?: number; }
type TabVariant = "inline" | "compact" | "expanded";

interface TabBarProps {
  tabs: Tab[];
  activeTab: string;
  onChange: (tabId: string) => void;
  variant?: TabVariant;
}

export function TabBar({ tabs, activeTab, onChange, variant = "inline" }: TabBarProps) {
  const handleKeyDown = (e: React.KeyboardEvent, i: number) => {
    if (e.key === "ArrowRight" && i < tabs.length - 1) { onChange(tabs[i + 1].id); e.preventDefault(); }
    if (e.key === "ArrowLeft" && i > 0) { onChange(tabs[i - 1].id); e.preventDefault(); }
  };

  if (variant === "inline") {
    return (
      <div role="tablist" style={{ display: "flex", gap: 0, borderBottom: "1px solid var(--border)" }}>
        {tabs.map((tab, i) => {
          const active = tab.id === activeTab;
          return (
            <button key={tab.id} role="tab" aria-selected={active} tabIndex={active ? 0 : -1} onClick={() => onChange(tab.id)} onKeyDown={(e) => handleKeyDown(e, i)} style={{ padding: "8px 16px", background: "none", border: "none", borderBottom: `2px solid ${active ? "var(--info, var(--blue))" : "transparent"}`, color: active ? "var(--info, var(--blue))" : "var(--text-secondary)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-sm)", fontWeight: active ? 600 : 400, cursor: "pointer", transition: "all 0.15s" }}>
              {tab.label}
            </button>
          );
        })}
      </div>
    );
  }

  if (variant === "compact") {
    return (
      <div role="tablist" style={{ display: "inline-flex", gap: "2px", padding: 2, borderRadius: "var(--radius, 6px)", background: "color-mix(in srgb, var(--text-muted) 10%, transparent)" }}>
        {tabs.map((tab, i) => {
          const active = tab.id === activeTab;
          return (
            <button key={tab.id} role="tab" aria-selected={active} tabIndex={active ? 0 : -1} onClick={() => onChange(tab.id)} onKeyDown={(e) => handleKeyDown(e, i)} style={{ padding: "4px 12px", borderRadius: "calc(var(--radius, 6px) - 2px)", background: active ? "var(--surface)" : "transparent", border: "none", color: active ? "var(--text)" : "var(--text-muted)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", fontWeight: active ? 600 : 400, cursor: "pointer", boxShadow: active ? "var(--shadow, 0 1px 3px rgba(0,0,0,0.1))" : "none", transition: "all 0.15s" }}>
              {tab.label}
            </button>
          );
        })}
      </div>
    );
  }

  // expanded — icon + label + count
  return (
    <div role="tablist" style={{ display: "flex", gap: "2px", borderBottom: "1px solid var(--border)" }}>
      {tabs.map((tab, i) => {
        const active = tab.id === activeTab;
        return (
          <button key={tab.id} role="tab" aria-selected={active} tabIndex={active ? 0 : -1} onClick={() => onChange(tab.id)} onKeyDown={(e) => handleKeyDown(e, i)} style={{ display: "flex", alignItems: "center", gap: "6px", padding: "8px 16px", background: "none", border: "none", borderBottom: `2px solid ${active ? "var(--info, var(--blue))" : "transparent"}`, color: active ? "var(--info, var(--blue))" : "var(--text-secondary)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-sm)", fontWeight: active ? 600 : 400, cursor: "pointer", transition: "all 0.15s" }}>
            {tab.icon && <span style={{ fontSize: "var(--font-size-sm)" }}>{tab.icon}</span>}
            {tab.label}
            {tab.count != null && (
              <span style={{ minWidth: 18, height: 18, borderRadius: "999px", background: active ? "var(--info, var(--blue))" : "color-mix(in srgb, var(--text-muted) 15%, transparent)", color: active ? "#fff" : "var(--text-muted)", fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 700, display: "flex", alignItems: "center", justifyContent: "center", padding: "0 4px", lineHeight: 1 }}>
                {tab.count}
              </span>
            )}
          </button>
        );
      })}
    </div>
  );
}

export default TabBar;
