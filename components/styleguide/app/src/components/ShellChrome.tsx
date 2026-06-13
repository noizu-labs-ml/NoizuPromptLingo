"use client";

import { useState, useEffect } from "react";
import type { SimpleShellLayout } from "@styleguide-engine/lib/types";

interface Props {
  shellLayouts: SimpleShellLayout[];
}

// ─── Per-shell chrome content ───

const SHELL_CONTENT: Record<string, {
  brand: string;
  navLinks?: string[];
  sidebarSections?: { label?: string; items: { glyph: string; label: string; active?: boolean }[] }[];
  asideRows?: { label: string; value: string }[];
  footerItems?: string[];
}> = {
  landing: {
    brand: "Brand",
    navLinks: ["Home", "Features", "Pricing", "Blog", "Docs"],
  },
  dashboard: {
    brand: "AppName",
    sidebarSections: [
      { items: [
        { glyph: "⊞", label: "Dashboard", active: true },
        { glyph: "↗", label: "Analytics" },
        { glyph: "◉", label: "Projects" },
      ]},
      { label: "Manage", items: [
        { glyph: "👥", label: "Team" },
        { glyph: "🔗", label: "Integrations" },
        { glyph: "⚙", label: "Settings" },
      ]},
    ],
    footerItems: ["● Connected", "Last sync: 2m ago", "v2.4.1"],
  },
  editor: {
    brand: "Editor",
    navLinks: ["File", "Edit", "View", "Run"],
    sidebarSections: [
      { label: "Explorer", items: [
        { glyph: "▶", label: "src/", active: true },
        { glyph: " ", label: "  components/" },
        { glyph: " ", label: "  pages/" },
        { glyph: " ", label: "  styles/" },
        { glyph: "▶", label: "public/" },
      ]},
    ],
    asideRows: [
      { label: "File", value: "page.tsx" },
      { label: "Line", value: "42" },
      { label: "Col", value: "18" },
      { label: "Encoding", value: "UTF-8" },
      { label: "Language", value: "TypeScript" },
      { label: "Indent", value: "2 spaces" },
    ],
    footerItems: ["TypeScript", "page.tsx", "42:18", "UTF-8"],
  },
  document: {
    brand: "Docs",
    navLinks: ["Guide", "API", "Examples", "Blog"],
    sidebarSections: [
      { label: "On this page", items: [
        { glyph: "›", label: "Introduction", active: true },
        { glyph: "›", label: "Getting Started" },
        { glyph: "›", label: "Configuration" },
        { glyph: "›", label: "API Reference" },
        { glyph: "›", label: "Examples" },
      ]},
    ],
    footerItems: ["Last updated: Mar 2026", "Edit this page →"],
  },
  settings: {
    brand: "Settings",
    navLinks: ["← Back to app"],
    sidebarSections: [
      { items: [
        { glyph: "⚙", label: "General", active: true },
        { glyph: "🔒", label: "Security" },
        { glyph: "🔔", label: "Notifications" },
        { glyph: "💳", label: "Billing" },
        { glyph: "👥", label: "Team" },
        { glyph: "🔗", label: "API" },
      ]},
    ],
  },
};

// ─── Main component ───

export function ShellChrome({ shellLayouts }: Props) {
  const [activeShell, setActiveShell] = useState<string | null>(null);

  useEffect(() => {
    const handler = (e: Event) => {
      const name = (e as CustomEvent<string>).detail || null;
      setActiveShell(name);
      if (name) document.body.dataset.shell = name;
      else delete document.body.dataset.shell;
    };
    window.addEventListener("shell-change", handler);
    return () => window.removeEventListener("shell-change", handler);
  }, []);

  const dismiss = () => {
    window.dispatchEvent(new CustomEvent("shell-change", { detail: null }));
  };

  useEffect(() => {
    const handler = (e: KeyboardEvent) => { if (e.key === "Escape") dismiss(); };
    window.addEventListener("keydown", handler);
    return () => window.removeEventListener("keydown", handler);
  }, []);

  const shell = shellLayouts.find((s) => s.name === activeShell) ?? null;
  const content = activeShell ? SHELL_CONTENT[activeShell] : null;

  return (
    <>
      {/* Navbar */}
      <nav className="shell-navbar">
        <div className="shell-navbar-brand">
          {content?.brand ?? shell?.title ?? ""}
        </div>
        {content?.navLinks && (
          <div className="shell-navbar-links">
            {content.navLinks.map((l) => (
              <span key={l} className="shell-navbar-link">{l}</span>
            ))}
          </div>
        )}
        <div className="shell-navbar-actions">
          <span className="shell-navbar-action" title="Search">🔍</span>
          <span className="shell-navbar-action" title="Notifications">🔔</span>
          <span className="shell-navbar-action" title="Account">◉</span>
          <button className="shell-navbar-dismiss" onClick={dismiss}>✕ exit shell</button>
        </div>
      </nav>

      {/* Sidebar */}
      <aside className="shell-sidebar">
        {content?.sidebarSections?.map((sec, si) => (
          <div key={si}>
            {sec.label && <div className="shell-sidebar-section">{sec.label}</div>}
            {sec.items.map((item) => (
              <div key={item.label} className={`shell-sidebar-item${item.active ? " active" : ""}`}>
                <span className="shell-sidebar-glyph">{item.glyph}</span>
                <span>{item.label}</span>
              </div>
            ))}
          </div>
        ))}
      </aside>

      {/* Aside */}
      <aside className="shell-aside">
        {content?.asideRows && (
          <>
            <div className="shell-aside-header">Properties</div>
            {content.asideRows.map((row) => (
              <div key={row.label} className="shell-aside-row">
                <span className="shell-aside-label">{row.label}</span>
                <span className="shell-aside-value">{row.value}</span>
              </div>
            ))}
          </>
        )}
      </aside>

      {/* Footer */}
      <footer className="shell-footer">
        {content?.footerItems?.map((item, i) => (
          <span key={i} style={{ display: "flex", alignItems: "center", gap: "var(--space-1)" }}>
            {i > 0 && <span className="shell-footer-sep">·</span>}
            {item.startsWith("●") && <span className="shell-footer-dot" style={{ background: "var(--success)" }} />}
            {item.startsWith("●") ? item.slice(2) : item}
          </span>
        ))}
        {!content?.footerItems && shell && (
          <span style={{ opacity: 0.6 }}>{shell.title} shell active</span>
        )}
        <span style={{ marginLeft: "auto" }}>
          <button
            onClick={dismiss}
            style={{ all: "unset", cursor: "pointer", opacity: 0.6, fontSize: "var(--font-size-xs)" }}
          >
            ✕ exit
          </button>
        </span>
      </footer>
    </>
  );
}
