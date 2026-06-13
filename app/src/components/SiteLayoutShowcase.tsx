"use client";

import { useState, useRef, useEffect } from "react";
import type { SimpleDesignSection, DesignComponent } from "@styleguide-engine/lib/types";
import { SubsectionTabs } from "./SubsectionTabs";

interface Props {
  section: SimpleDesignSection;
}

/* ─── Shared wireframe primitives using design-system tokens ─── */

function NavBar({ label }: { label?: string }) {
  return (
    <div className="flex items-center gap-[var(--space-2)] px-[var(--space-3)] bg-[var(--surface-inverse)] text-[var(--text-inverse)]" style={{ height: 36 }}>
      <span className="font-bold text-xs tracking-wide">ACME</span>
      <span className="text-xs opacity-60">{label ?? "Home"}</span>
      <span className="text-xs opacity-60">Docs</span>
      <span className="ml-auto text-xs opacity-60">⚙</span>
    </div>
  );
}

function Sidebar({ items, activeIdx }: { items: string[]; activeIdx?: number }) {
  return (
    <div className="flex flex-col bg-[var(--surface-alt)] border-r border-[var(--border)]" style={{ minWidth: 100 }}>
      {items.map((item, i) => (
        <div
          key={item}
          className="px-[var(--space-2)] py-[var(--space-1)] text-xs cursor-default"
          style={{
            background: i === (activeIdx ?? 0) ? "var(--surface)" : undefined,
            fontWeight: i === (activeIdx ?? 0) ? 700 : 400,
            color: "var(--text-secondary)",
            borderLeft: i === (activeIdx ?? 0) ? "2px solid var(--text)" : "2px solid transparent",
          }}
        >
          {item}
        </div>
      ))}
    </div>
  );
}

function Footer() {
  return (
    <div className="flex items-center justify-center bg-[var(--surface-alt)] border-t border-[var(--border)] text-[var(--text-muted)]" style={{ height: 28 }}>
      <span className="font-mono text-xs">© 2025 ACME Corp</span>
    </div>
  );
}

function MiniCard({ title, body }: { title: string; body?: string }) {
  return (
    <div className="card" style={{ fontSize: "var(--font-size-xs)" }}>
      <div className="card-header" style={{ padding: "var(--space-1) var(--space-2)" }}>
        <span className="card-title" style={{ fontSize: "var(--font-size-xs)" }}>{title}</span>
      </div>
      {body && (
        <div className="card-body" style={{ padding: "var(--space-1) var(--space-2)" }}>
          <p style={{ color: "var(--text-muted)", lineHeight: 1.3 }}>{body}</p>
        </div>
      )}
    </div>
  );
}

/* ─── Visual demos ─── */

function SearchFirstDemo() {
  return (
    <div className="flex flex-col w-full h-full">
      <NavBar label="Search" />
      <div className="flex items-center gap-[var(--space-1)] p-[var(--space-2)] bg-[var(--surface-alt)] border-b border-[var(--border)]">
        <input className="hui combo-input flex-1" style={{ fontSize: "var(--font-size-xs)" }} placeholder="Search products, docs, APIs…" readOnly />
        <button className="btn btn-sm" style={{ fontSize: "var(--font-size-xs)" }}>Search</button>
      </div>
      <div className="flex flex-1 min-h-0">
        <div className="flex flex-col gap-[var(--space-half)] p-[var(--space-2)] border-r border-[var(--border)] bg-[var(--surface)]" style={{ minWidth: 90 }}>
          <span className="font-mono text-xs font-bold" style={{ color: "var(--text-muted)" }}>FILTERS</span>
          {["Type", "Status", "Date", "Author"].map(f => (
            <span key={f} className="text-xs" style={{ color: "var(--text-secondary)" }}>{f}</span>
          ))}
        </div>
        <div className="flex-1 flex flex-col gap-[var(--space-1)] p-[var(--space-2)]">
          {[1,2,3].map(i => (
            <div key={i} className="card" style={{ fontSize: "var(--font-size-xs)" }}>
              <div className="card-body" style={{ padding: "var(--space-1) var(--space-2)" }}>
                <span style={{ color: "var(--text-secondary)" }}>Result {i} — matching document title</span>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

function HierarchyDemo() {
  return (
    <div className="flex flex-col w-full h-full">
      <NavBar />
      <div className="flex items-center justify-center bg-[var(--surface-alt)] border-b border-[var(--border)]" style={{ height: 48 }}>
        <span className="font-bold text-sm" style={{ color: "var(--text-secondary)" }}>Hero / Primary Action</span>
      </div>
      <div className="card-grid p-[var(--space-2)]" style={{ gridTemplateColumns: "repeat(3, 1fr)" }}>
        <MiniCard title="Feature A" body="Summary text" />
        <MiniCard title="Feature B" body="Summary text" />
        <MiniCard title="Feature C" body="Summary text" />
      </div>
      <div className="flex flex-1 min-h-0 border-t border-[var(--border)]">
        <div className="flex-1 flex items-center justify-center p-[var(--space-2)]">
          <span className="text-xs" style={{ color: "var(--text-muted)" }}>Content area</span>
        </div>
        <div className="flex items-center justify-center bg-[var(--surface-alt)] border-l border-[var(--border)]" style={{ width: 80 }}>
          <span className="text-xs" style={{ color: "var(--text-muted)" }}>Sidebar</span>
        </div>
      </div>
      <Footer />
    </div>
  );
}

function DashboardDemo() {
  return (
    <div className="flex flex-col w-full h-full">
      <NavBar label="Dashboard" />
      <div className="flex flex-1 min-h-0">
        <Sidebar items={["Overview", "Analytics", "Reports", "Settings"]} />
        <div className="flex-1 flex flex-col gap-[var(--space-1)] p-[var(--space-2)]">
          <div className="card-grid" style={{ gridTemplateColumns: "repeat(3, 1fr)" }}>
            {["Users", "Revenue", "Uptime"].map(kpi => (
              <div key={kpi} className="card accent-primary" style={{ fontSize: "var(--font-size-xs)" }}>
                <div className="card-body" style={{ padding: "var(--space-1) var(--space-2)", textAlign: "center" }}>
                  <span className="font-bold">{kpi}</span>
                  <div className="font-mono" style={{ color: "var(--text-muted)" }}>—</div>
                </div>
              </div>
            ))}
          </div>
          <div className="grid gap-[var(--space-1)]" style={{ gridTemplateColumns: "2fr 1fr", flex: 1 }}>
            <MiniCard title="Chart" body="Timeseries data" />
            <MiniCard title="Breakdown" body="Pie / bar" />
          </div>
        </div>
      </div>
    </div>
  );
}

function DocumentDemo() {
  return (
    <div className="flex flex-col w-full h-full">
      <NavBar label="Docs" />
      <div className="flex flex-1 min-h-0">
        <div className="flex flex-col gap-[var(--space-half)] p-[var(--space-2)] border-r border-[var(--border)] bg-[var(--surface-alt)]" style={{ minWidth: 80 }}>
          <span className="font-mono text-xs font-bold" style={{ color: "var(--text-muted)" }}>TOC</span>
          {["Intro", "Setup", "Usage", "API"].map(s => (
            <span key={s} className="text-xs" style={{ color: "var(--text-secondary)" }}>{s}</span>
          ))}
        </div>
        <div className="flex-1 flex flex-col gap-[var(--space-1)] p-[var(--space-3)]" style={{ maxWidth: 480 }}>
          <h3 className="font-bold text-sm">Getting Started</h3>
          <div className="flex flex-col gap-[var(--space-half)]">
            {[85, 70, 60, 75].map((w, i) => (
              <div key={i} className="bg-[var(--surface-alt)]" style={{ height: 6, width: `${w}%`, borderRadius: 2 }} />
            ))}
          </div>
          <h4 className="font-bold text-xs" style={{ color: "var(--text-secondary)", marginTop: "var(--space-1)" }}>Installation</h4>
          <div className="flex flex-col gap-[var(--space-half)]">
            {[90, 65].map((w, i) => (
              <div key={i} className="bg-[var(--surface-alt)]" style={{ height: 6, width: `${w}%`, borderRadius: 2 }} />
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

function MultiViewDemo() {
  return (
    <div className="flex flex-col w-full h-full">
      <NavBar label="Editor" />
      <div className="flex flex-1 min-h-0">
        <div className="flex flex-col border-r border-[var(--border)]" style={{ width: "35%" }}>
          {["Item 1", "Item 2", "Item 3", "Item 4"].map((label, i) => (
            <div
              key={label}
              className="px-[var(--space-2)] py-[var(--space-1)] text-xs cursor-default"
              style={{
                background: i === 1 ? "var(--surface-alt)" : "var(--surface)",
                fontWeight: i === 1 ? 700 : 400,
                color: "var(--text-secondary)",
                borderLeft: i === 1 ? "2px solid var(--text)" : "2px solid transparent",
              }}
            >
              {label}
            </div>
          ))}
        </div>
        <div className="w-1 bg-[var(--border)] cursor-col-resize shrink-0" />
        <div className="flex-1 flex flex-col gap-[var(--space-1)] p-[var(--space-2)]">
          <span className="font-bold text-xs">Item 2 — Detail</span>
          <div className="flex flex-col gap-[var(--space-half)]">
            {[80, 65, 70].map((w, i) => (
              <div key={i} className="bg-[var(--surface-alt)]" style={{ height: 5, width: `${w}%`, borderRadius: 2 }} />
            ))}
          </div>
          <button className="btn btn-sm self-start" style={{ fontSize: "var(--font-size-xs)", marginTop: "auto" }}>Save</button>
        </div>
      </div>
    </div>
  );
}

const PANEL_ITEMS = [
  { title: "Dashboard report",  body: "Q1 metrics overview",    status: "Active",   created: "Today",      owner: "Alice" },
  { title: "API integration",   body: "OAuth token refresh",    status: "Pending",  created: "Yesterday",  owner: "Bob" },
  { title: "Design review",     body: "Component audit pass",   status: "Done",     created: "2 days ago", owner: "Carol" },
  { title: "Deploy pipeline",   body: "Staging → prod rollout", status: "Blocked",  created: "3 days ago", owner: "Dave" },
];

function ContextualPanelDemo() {
  const [selected, setSelected] = useState(0);
  const item = PANEL_ITEMS[selected];

  return (
    <div className="flex flex-col w-full h-full">
      <NavBar />
      <div className="flex flex-1 min-h-0">
        {/* Main list */}
        <div className="flex-1 flex flex-col gap-[var(--space-1)] p-[var(--space-2)]">
          {PANEL_ITEMS.map((it, i) => (
            <div
              key={it.title}
              onClick={() => setSelected(i)}
              className="card"
              style={{
                fontSize: "var(--font-size-xs)",
                cursor: "pointer",
                outline: i === selected ? "2px solid var(--text)" : "none",
                outlineOffset: 2,
              }}
            >
              <div className="card-body" style={{ padding: "var(--space-1) var(--space-2)" }}>
                <span style={{ fontWeight: i === selected ? 700 : 400, color: "var(--text-secondary)" }}>
                  {it.title}
                </span>
                <div style={{ color: "var(--text-muted)", marginTop: 2 }}>{it.body}</div>
              </div>
            </div>
          ))}
        </div>

        {/* Details panel */}
        <div className="flex flex-col border-l border-[var(--border)] bg-[var(--surface)]" style={{ width: 150 }}>
          <div className="flex justify-between items-center px-[var(--space-2)] py-[var(--space-1)] border-b border-[var(--border)] bg-[var(--surface-alt)]">
            <span className="font-mono text-xs font-bold">Details</span>
            <span className="text-xs" style={{ color: "var(--text-muted)" }}>✕</span>
          </div>
          <div className="flex flex-col gap-[var(--space-half)] p-[var(--space-2)]">
            <div className="text-xs font-bold" style={{ color: "var(--text)", marginBottom: "var(--space-half)" }}>{item.title}</div>
            {(["status", "created", "owner"] as const).map(key => (
              <div key={key} className="flex justify-between text-xs">
                <span style={{ color: "var(--text-muted)", textTransform: "capitalize" }}>{key}</span>
                <span className="font-mono" style={{ color: "var(--text-secondary)" }}>{item[key]}</span>
              </div>
            ))}
            <button className="btn btn-sm" style={{ fontSize: "var(--font-size-xs)", marginTop: "var(--space-1)" }}>Edit</button>
          </div>
        </div>
      </div>
    </div>
  );
}

function ContextualMenuDemo() {
  const [menu, setMenu] = useState<{ x: number; y: number } | null>(null);
  const containerRef = useRef<HTMLDivElement>(null);
  const menuRef = useRef<HTMLDivElement>(null);

  const items: ({ label: string; shortcut: string; destructive?: boolean } | null)[] = [
    { label: "Open", shortcut: "↵" },
    { label: "Open in new tab", shortcut: "⌘↵" },
    { label: "Copy link", shortcut: "⌘C" },
    null,
    { label: "Rename", shortcut: "F2" },
    { label: "Duplicate", shortcut: "⌘D" },
    null,
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
    <div ref={containerRef} style={{ position: "relative", minHeight: 280 }}>
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
            position: "absolute", top: menu.y, left: menu.x, zIndex: 50,
            background: "var(--surface)", border: "1px solid var(--border)",
            boxShadow: "0 4px 16px rgba(0,0,0,0.12), 0 1px 4px rgba(0,0,0,0.08)",
            minWidth: 200, padding: "var(--space-half) 0",
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
                  color: item.destructive ? "var(--error)" : "var(--text)",
                }}
                onMouseEnter={(e) => { (e.currentTarget as HTMLElement).style.background = "var(--surface-alt)"; }}
                onMouseLeave={(e) => { (e.currentTarget as HTMLElement).style.background = "transparent"; }}
              >
                <span>{item.label}</span>
                <span className="font-mono" style={{ color: "var(--text-muted)", fontSize: "var(--font-size-2xs)" }}>{item.shortcut}</span>
              </div>
            )
          )}
        </div>
      )}
    </div>
  );
}

/* ─── Demo map ─── */

const DEMOS: Record<string, React.ReactNode> = {
  "search-first":      <SearchFirstDemo />,
  "hierarchy":         <HierarchyDemo />,
  "dashboard":         <DashboardDemo />,
  "document":          <DocumentDemo />,
  "multi-view":        <MultiViewDemo />,
  "contextual-panels": <ContextualPanelDemo />,
  "contextual-menu":   <ContextualMenuDemo />,
};

/* ─── Section entry ─── */

function PrincipleRow({ label, colorClass, text, italic }: { label: string; colorClass: string; text: string; italic?: boolean }) {
  return (
    <div className="sg-principle-row">
      <div className={`sg-principle-label ${colorClass}`}>{label}</div>
      <p className={`sg-principle-text${italic ? " muted" : ""}`}>{text}</p>
    </div>
  );
}

function SiteLayoutContent({ component }: { component: DesignComponent }) {
  const demo = DEMOS[component.name];
  return (
    <div className="flex flex-col gap-[var(--space-3)]" id={`site-${component.name}`}>
      <div className="flex flex-col gap-[var(--space-2)]">
        <PrincipleRow label="Principle" colorClass="text-principle" text={component.principle} />
        <PrincipleRow label="Approach"  colorClass="text-approach"  text={component.approach} />
        <PrincipleRow label="Why"       colorClass="text-why"       text={component.rationale} italic />
      </div>
      {demo && (
        <div className="screen-frame">
          <div className="screen-titlebar">
            <span className="screen-dot" />
            <span className="screen-dot" />
            <span className="screen-dot" />
            <span className="screen-url">{component.name}.app</span>
          </div>
          <div className="screen-body">
            {demo}
          </div>
        </div>
      )}
    </div>
  );
}

/* ─── Main component ─── */

export function SiteLayoutShowcase({ section }: Props) {
  const tabs = section.components.map((c) => ({
    id: `site-${c.name}`,
    title: c.title,
    content: <SiteLayoutContent component={c} />,
  }));

  return (
    <div>
      <p className="sg-description">{section.description}</p>
      <SubsectionTabs tabs={tabs} />
    </div>
  );
}
