"use client";

import { useState, useRef, useEffect } from "react";
import type { SimpleDesignSection, DesignComponent } from "@styleguide-engine/lib/types";
import { SubsectionTabs } from "./SubsectionTabs";

interface Props {
  section: SimpleDesignSection;
}

// ─── Visual demos ───

function NavbarDemo() {
  return (
    <div style={{
      display: "flex", alignItems: "center", gap: "var(--space-1)",
      background: "var(--surface-inverse)", color: "var(--text-inverse)",
      padding: "0 var(--space-2)", height: 44, fontSize: "var(--font-size-sm)",
      borderBottom: "1px solid rgba(255,255,255,0.1)",
    }}>
      <span style={{ fontWeight: 700, fontSize: "var(--font-size-sm)", letterSpacing: "-0.01em", marginRight: "var(--space-1)" }}>ACME</span>
      <div style={{ display: "flex", gap: 2 }}>
        {["Home", "Dashboard", "Reports", "Settings"].map((label, i) => (
          <span key={label} style={{
            padding: "var(--space-half) var(--space-1)", fontSize: "var(--font-size-sm)", borderRadius: "var(--radius)", cursor: "pointer",
            opacity: i === 1 ? 1 : 0.6,
            fontWeight: i === 1 ? 600 : 400,
            background: i === 1 ? "rgba(255,255,255,0.1)" : "transparent",
          }}>
            {label}
          </span>
        ))}
      </div>
      <div style={{ marginLeft: "auto", display: "flex", gap: "var(--space-half)", alignItems: "center" }}>
        <span style={{
          padding: "var(--space-half) var(--space-1)", fontSize: "var(--font-size-xs)", fontFamily: "var(--font-mono)",
          background: "rgba(255,255,255,0.12)", border: "1px solid rgba(255,255,255,0.2)",
          borderRadius: "var(--radius)", cursor: "pointer",
        }}>⌘K search</span>
        <span style={{
          width: 28, height: 28, display: "flex", alignItems: "center", justifyContent: "center",
          borderRadius: "var(--radius)", cursor: "pointer", fontSize: "var(--font-size-sm)",
        }}>⚙</span>
      </div>
    </div>
  );
}

function SidebarDemo() {
  const items = [
    { icon: "⊞", label: "Overview", active: false, section: "WORKSPACE" },
    { icon: "●", label: "Dashboard", active: true, section: null },
    { icon: "✎", label: "Editor", active: false, section: null },
    { icon: "★", label: "Favorites", active: false, section: null },
    { icon: "⚙", label: "Settings", active: false, section: "ACCOUNT" },
    { icon: "●", label: "Profile", active: false, section: null },
  ];

  return (
    <div style={{ display: "flex", gap: "var(--space-2)", alignItems: "flex-start" }}>
      {/* Full sidebar */}
      <div style={{
        width: 180, background: "var(--surface-alt)", border: "1px solid var(--border)",
        fontSize: "var(--font-size-sm)", flexShrink: 0,
      }}>
        {items.map((item, i) => (
          <div key={item.label}>
            {item.section && (
              <div style={{
                padding: "var(--space-1) var(--space-2) var(--space-half)", fontSize: "var(--font-size-xs)", fontFamily: "var(--font-mono)",
                letterSpacing: "0.08em", textTransform: "uppercase", opacity: 0.45,
              }}>
                {item.section}
              </div>
            )}
            <div style={{
              display: "flex", alignItems: "center", gap: "var(--space-1)",
              padding: "var(--space-1) var(--space-2)", cursor: "pointer",
              background: item.active ? "rgba(0,0,0,0.09)" : "transparent",
              fontWeight: item.active ? 600 : 400,
              borderLeft: item.active ? "2px solid var(--text)" : "2px solid transparent",
            }}>
              <span style={{ fontSize: "var(--font-size-sm)", width: 18, textAlign: "center", flexShrink: 0, opacity: 0.7 }}>{item.icon}</span>
              <span>{item.label}</span>
            </div>
            {i === 3 && (
              <div style={{ margin: "var(--space-half) var(--space-2)", borderTop: "1px solid var(--border)" }} />
            )}
          </div>
        ))}
      </div>

      {/* Collapsed rail */}
      <div style={{
        width: 44, background: "var(--surface-alt)", border: "1px solid var(--border)",
        display: "flex", flexDirection: "column", alignItems: "center", gap: 0,
        fontSize: "var(--font-size-md)", flexShrink: 0,
      }}>
        {items.filter((i) => !i.section).map((item) => (
          <div key={item.label} style={{
            width: "100%", height: 40, display: "flex", alignItems: "center", justifyContent: "center",
            background: item.active ? "rgba(0,0,0,0.09)" : "transparent",
            borderLeft: item.active ? "2px solid var(--text)" : "2px solid transparent",
            cursor: "pointer", opacity: item.active ? 1 : 0.55,
          }}>
            {item.icon}
          </div>
        ))}
      </div>
    </div>
  );
}

function BreadcrumbsDemo() {
  const paths = [
    ["Home", "Settings", "Team", "Permissions"],
    ["Docs", "API Reference", "Endpoints"],
  ];
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "var(--space-1)" }}>
      {paths.map((crumbs, pi) => (
        <div key={pi} style={{ display: "flex", alignItems: "center", gap: "var(--space-half)", fontSize: "var(--font-size-sm)" }}>
          {crumbs.map((crumb, ci) => (
            <span key={crumb} style={{ display: "flex", alignItems: "center", gap: "var(--space-half)" }}>
              {ci > 0 && (
                <span style={{ color: "var(--text-muted)", fontSize: "var(--font-size-sm)" }}>›</span>
              )}
              <span style={{
                color: ci === crumbs.length - 1 ? "var(--surface-alt)" : "var(--text-muted)",
                fontWeight: ci === crumbs.length - 1 ? 600 : 400,
                cursor: ci < crumbs.length - 1 ? "pointer" : "default",
                textDecoration: ci < crumbs.length - 1 ? "underline" : "none",
                textDecorationColor: "var(--border)",
                fontSize: "var(--font-size-sm)",
              }}>
                {ci === 1 && crumbs.length > 3 ? "…" : crumb}
              </span>
            </span>
          ))}
        </div>
      ))}
    </div>
  );
}

function ContextualMenuDemo() {
  const [menu, setMenu] = useState<{ x: number; y: number } | null>(null);
  const containerRef = useRef<HTMLDivElement>(null);
  const menuRef = useRef<HTMLDivElement>(null);

  const items = [
    { label: "Open", shortcut: "↵" },
    { label: "Open in new tab", shortcut: "⌘↵" },
    { label: "Copy link", shortcut: "⌘C" },
    null, // divider
    { label: "Rename", shortcut: "F2" },
    { label: "Duplicate", shortcut: "⌘D" },
    null, // divider
    { label: "Delete", shortcut: "⌫", destructive: true },
  ];

  useEffect(() => {
    if (!menu) return;
    const dismiss = (e: MouseEvent) => {
      if (menuRef.current && !menuRef.current.contains(e.target as Node)) setMenu(null);
    };
    const esc = (e: KeyboardEvent) => { if (e.key === "Escape") setMenu(null); };
    document.addEventListener("mousedown", dismiss);
    document.addEventListener("keydown", esc);
    return () => { document.removeEventListener("mousedown", dismiss); document.removeEventListener("keydown", esc); };
  }, [menu]);

  return (
    <div ref={containerRef} style={{ position: "relative" }}>
      {/* Target surface — right-click only fires here */}
      <div
        onContextMenu={(e) => {
          e.preventDefault();
          const rect = containerRef.current!.getBoundingClientRect();
          setMenu({ x: e.clientX - rect.left, y: e.clientY - rect.top });
        }}
        style={{
          padding: "var(--space-4) var(--space-6)",
          background: "var(--surface-alt)", border: "1px dashed var(--border)",
          fontSize: "var(--font-size-sm)", color: "var(--text-muted)",
          textAlign: "center", userSelect: "none", cursor: "context-menu",
        }}
      >
        right-click anywhere in this area
        <div style={{ fontSize: "var(--font-size-xs)", marginTop: "var(--space-1)", opacity: 0.6 }}>
          e.g. table row, card, file item
        </div>
      </div>

      {/* Context menu — position: absolute relative to container */}
      {menu && (
        <div
          ref={menuRef}
          style={{
            position: "absolute",
            top: menu.y,
            left: menu.x,
            background: "var(--surface)",
            border: "1px solid var(--border)",
            boxShadow: "0 4px 16px rgba(0,0,0,0.12), 0 1px 4px rgba(0,0,0,0.08)",
            minWidth: 200,
            padding: "var(--space-half) 0",
            zIndex: 50,
          }}
        >
          {items.map((item, i) =>
            item === null ? (
              <div key={i} style={{ margin: "var(--space-half) 0", borderTop: "1px solid var(--border)" }} />
            ) : (
              <div
                key={item.label}
                onClick={() => setMenu(null)}
                style={{
                  display: "flex", justifyContent: "space-between", alignItems: "center",
                  padding: "var(--space-1) var(--space-2)", fontSize: "var(--font-size-sm)", cursor: "pointer",
                  color: (item as { destructive?: boolean }).destructive ? "var(--brand-red)" : "var(--text)",
                }}
                onMouseEnter={(e) => { (e.currentTarget as HTMLElement).style.background = "var(--surface-alt)"; }}
                onMouseLeave={(e) => { (e.currentTarget as HTMLElement).style.background = "transparent"; }}
              >
                <span>{item.label}</span>
                <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", color: "var(--text-muted)" }}>
                  {item.shortcut}
                </span>
              </div>
            )
          )}
        </div>
      )}
    </div>
  );
}

function MobileNavDemo() {
  return (
    <div style={{ display: "flex", gap: "var(--space-4)", alignItems: "flex-start" }}>
      {/* Closed state */}
      <div style={{ display: "flex", flexDirection: "column", gap: "var(--space-1)", alignItems: "center" }}>
        <div style={{
          width: 120, border: "1px solid var(--border)", overflow: "hidden",
        }}>
          <div style={{
            display: "flex", alignItems: "center", justifyContent: "space-between",
            background: "var(--surface-inverse)", color: "var(--text-inverse)",
            padding: "var(--space-1) var(--space-2)", fontSize: "var(--font-size-sm)",
          }}>
            <span style={{ fontWeight: 700 }}>ACME</span>
            <span style={{ fontSize: "var(--font-size-md)", lineHeight: 1 }}>≡</span>
          </div>
          <div style={{ height: 56, background: "var(--surface-alt)" }} />
        </div>
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", color: "var(--text-muted)" }}>closed</span>
      </div>

      {/* Open drawer state */}
      <div style={{ display: "flex", flexDirection: "column", gap: "var(--space-1)", alignItems: "center" }}>
        <div style={{
          width: 180, border: "1px solid var(--border)", overflow: "hidden", position: "relative",
        }}>
          <div style={{
            display: "flex", alignItems: "center", justifyContent: "space-between",
            background: "var(--surface-inverse)", color: "var(--text-inverse)",
            padding: "var(--space-1) var(--space-2)", fontSize: "var(--font-size-sm)",
          }}>
            <span style={{ fontWeight: 700 }}>ACME</span>
            <span style={{ fontSize: "var(--font-size-sm)" }}>✕</span>
          </div>
          <div style={{ display: "flex" }}>
            {/* Drawer */}
            <div style={{
              width: 130, background: "var(--surface-alt)",
              borderRight: "1px solid var(--border)", fontSize: "var(--font-size-sm)",
            }}>
              {["Home", "Dashboard", "Settings", "Help"].map((label, i) => (
                <div key={label} style={{
                  padding: "var(--space-1) var(--space-2)", cursor: "pointer",
                  background: i === 1 ? "rgba(0,0,0,0.07)" : "transparent",
                  fontWeight: i === 1 ? 600 : 400,
                  borderBottom: "1px solid var(--border)",
                }}>
                  {label}
                </div>
              ))}
            </div>
            {/* Scrim */}
            <div style={{ flex: 1, background: "rgba(0,0,0,0.25)", height: "var(--space-10)" }} />
          </div>
        </div>
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", color: "var(--text-muted)" }}>drawer open</span>
      </div>
    </div>
  );
}

// ─── Demo map ───

const DEMOS: Record<string, React.ReactNode> = {
  navbar:           <NavbarDemo />,
  sidebar:          <SidebarDemo />,
  breadcrumbs:      <BreadcrumbsDemo />,
  "contextual-menu": <ContextualMenuDemo />,
  "mobile-nav":     <MobileNavDemo />,
};

// ─── Section entry ───

function NavContent({ component }: { component: DesignComponent }) {
  const demo = DEMOS[component.name];
  return (
    <div className="flex flex-col gap-[var(--space-3)]" id={`nav-${component.name}`}>
      <div className="flex flex-col gap-[var(--space-2)]">
        <PrincipleRow label="Principle" colorClass="text-principle" text={component.principle} />
        <PrincipleRow label="Approach"  colorClass="text-approach"  text={component.approach} />
        <PrincipleRow label="Why"       colorClass="text-why"       text={component.rationale} italic />
      </div>
      {demo && <div className="sg-demo-box">{demo}</div>}
    </div>
  );
}

function PrincipleRow({ label, colorClass, text, italic }: { label: string; colorClass: string; text: string; italic?: boolean }) {
  return (
    <div className="sg-principle-row">
      <div className={`sg-principle-label ${colorClass}`}>
        {label}
      </div>
      <p className={`sg-principle-text${italic ? " muted" : ""}`}>
        {text}
      </p>
    </div>
  );
}

// ─── Main component ───

export function NavigationShowcase({ section }: Props) {
  const tabs = section.components.map((c) => ({
    id: `nav-${c.name}`,
    title: c.title,
    content: <NavContent component={c} />,
  }));

  return (
    <div>
      <p className="sg-description">{section.description}</p>
      <SubsectionTabs tabs={tabs} />
    </div>
  );
}
