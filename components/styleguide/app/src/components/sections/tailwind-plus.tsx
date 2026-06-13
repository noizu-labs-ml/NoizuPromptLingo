"use client";

import { Suspense, lazy, useState, useMemo, useCallback, type ComponentType } from "react";
import type { SectionProps } from "./section-props";
import { APP_UI, MARKETING, ECOMMERCE, type ComponentEntry, type ComponentGroup } from "./tailwind-plus-registry";

interface SectionDef {
  id: string;
  label: string;
  groups: ComponentGroup[];
}

const SECTIONS: SectionDef[] = [
  { id: "app-ui", label: "App UI", groups: APP_UI },
  { id: "marketing", label: "Marketing", groups: MARKETING },
  { id: "ecommerce", label: "Ecommerce", groups: ECOMMERCE },
];

function LazyDemo({ entry }: { entry: ComponentEntry }) {
  const [error, setError] = useState<string | null>(null);
  const Component = lazy(() =>
    entry.loader().then((mod) => {
      const Comp = mod[entry.exportName];
      if (!Comp) {
        const Fallback = () => <div style={{ color: "var(--error)", fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", padding: "var(--space-2)" }}>Export &quot;{entry.exportName}&quot; not found</div>;
        return { default: Fallback as ComponentType };
      }
      return { default: Comp as ComponentType };
    }).catch((err) => {
      setError(String(err));
      const Noop = (() => null) as unknown as ComponentType;
      return { default: Noop };
    })
  );

  return (
    <div className="border border-[var(--border)] rounded-[var(--radius)] overflow-hidden" style={{ background: "var(--surface)" }}>
      <div
        className="px-[var(--space-3)] py-[var(--space-2)]"
        style={{ borderBottom: "1px solid var(--border)", background: "var(--surface-alt)" }}
      >
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", fontWeight: 600, color: "var(--text)" }}>
          {entry.name}
        </span>
      </div>
      <div style={{ padding: "var(--space-4)", overflow: "auto" }}>
        {error ? (
          <div style={{ color: "var(--error)", fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)" }}>{error}</div>
        ) : (
          <Suspense fallback={<div style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", color: "var(--text-muted)", padding: "var(--space-4)" }}>Loading...</div>}>
            <Component />
          </Suspense>
        )}
      </div>
    </div>
  );
}

function SidebarItem({ entry, active, onClick }: { entry: ComponentEntry; active: boolean; onClick: () => void }) {
  return (
    <button
      onClick={onClick}
      className="w-full text-left truncate"
      style={{
        display: "block",
        padding: "2px 0 2px var(--space-4)",
        fontSize: "var(--font-size-xs)",
        fontFamily: "var(--font-sans)",
        color: active ? "var(--text)" : "var(--text-muted)",
        fontWeight: active ? 600 : 400,
        borderLeft: active ? "2px solid var(--text)" : "2px solid transparent",
        background: "none",
        border: "none",
        borderLeftWidth: "2px",
        borderLeftStyle: "solid",
        borderLeftColor: active ? "var(--text)" : "transparent",
        cursor: "pointer",
        lineHeight: 1.6,
      }}
    >
      {entry.name}
    </button>
  );
}

function SidebarGroup({ group, section, activeKey, onSelect }: {
  group: ComponentGroup;
  section: string;
  activeKey: string;
  onSelect: (key: string) => void;
}) {
  const [open, setOpen] = useState(() => group.entries.some((e) => `${section}/${group.label}/${e.exportName}` === activeKey));
  const hasActive = group.entries.some((e) => `${section}/${group.label}/${e.exportName}` === activeKey);

  return (
    <div>
      <button
        onClick={() => setOpen((o) => !o)}
        className="w-full text-left flex items-center gap-[var(--space-1)]"
        style={{
          padding: "2px 0",
          fontSize: "var(--font-size-xs)",
          fontFamily: "var(--font-mono)",
          fontWeight: hasActive ? 700 : 500,
          color: hasActive ? "var(--text)" : "var(--text-secondary)",
          textTransform: "uppercase",
          letterSpacing: "0.05em",
          background: "none",
          border: "none",
          cursor: "pointer",
        }}
      >
        <span style={{ fontSize: "8px", transition: "transform 0.15s", transform: open ? "rotate(90deg)" : "rotate(0deg)", display: "inline-block" }}>&#9654;</span>
        {group.label}
        <span style={{ fontSize: "10px", color: "var(--text-muted)", fontWeight: 400, marginLeft: "auto" }}>{group.entries.length}</span>
      </button>
      {open && (
        <div style={{ borderLeft: "1px solid var(--border)", marginLeft: "3px", marginTop: "2px" }}>
          {group.entries.map((entry) => {
            const key = `${section}/${group.label}/${entry.exportName}`;
            return <SidebarItem key={key} entry={entry} active={activeKey === key} onClick={() => onSelect(key)} />;
          })}
        </div>
      )}
    </div>
  );
}

function SidebarSection({ section, activeKey, onSelect, searchFilter }: {
  section: SectionDef;
  activeKey: string;
  onSelect: (key: string) => void;
  searchFilter: string;
}) {
  const [open, setOpen] = useState(true);
  const filteredGroups = useMemo(() => {
    if (!searchFilter) return section.groups;
    const q = searchFilter.toLowerCase();
    return section.groups
      .map((g) => ({
        ...g,
        entries: g.entries.filter((e) => e.name.toLowerCase().includes(q) || g.label.toLowerCase().includes(q)),
      }))
      .filter((g) => g.entries.length > 0);
  }, [section.groups, searchFilter]);

  if (filteredGroups.length === 0) return null;

  const totalFiltered = filteredGroups.reduce((s, g) => s + g.entries.length, 0);

  return (
    <div>
      <button
        onClick={() => setOpen((o) => !o)}
        className="w-full text-left flex items-center gap-[var(--space-1)]"
        style={{
          padding: "var(--space-half) 0",
          fontSize: "var(--font-size-sm)",
          fontWeight: 700,
          color: "var(--text)",
          background: "none",
          border: "none",
          cursor: "pointer",
        }}
      >
        <span style={{ fontSize: "10px", transition: "transform 0.15s", transform: open ? "rotate(90deg)" : "rotate(0deg)", display: "inline-block" }}>&#9654;</span>
        {section.label}
        <span style={{ fontSize: "var(--font-size-xs)", color: "var(--text-muted)", fontWeight: 400, marginLeft: "auto" }}>{totalFiltered}</span>
      </button>
      {open && (
        <div style={{ display: "flex", flexDirection: "column", gap: "var(--space-1)", paddingLeft: "var(--space-2)" }}>
          {filteredGroups.map((group) => (
            <SidebarGroup key={group.label} group={group} section={section.id} activeKey={activeKey} onSelect={onSelect} />
          ))}
        </div>
      )}
    </div>
  );
}

export function TailwindPlusSection({ id }: SectionProps) {
  const [search, setSearch] = useState("");
  const [activeKey, setActiveKey] = useState("");

  const activeEntry = useMemo(() => {
    if (!activeKey) return null;
    for (const section of SECTIONS) {
      for (const group of section.groups) {
        for (const entry of group.entries) {
          if (`${section.id}/${group.label}/${entry.exportName}` === activeKey) {
            return { section, group, entry };
          }
        }
      }
    }
    return null;
  }, [activeKey]);

  const handleSelect = useCallback((key: string) => {
    setActiveKey((prev) => prev === key ? "" : key);
  }, []);

  const totalCount = SECTIONS.reduce((s, sec) => s + sec.groups.reduce((gs, g) => gs + g.entries.length, 0), 0);

  return (
    <div id={`section-${id}`}>
      <div style={{
        display: "grid",
        gridTemplateColumns: "260px 1fr",
        gap: "var(--space-3)",
        minHeight: "400px",
      }}>
        {/* Sidebar */}
        <div style={{
          borderRight: "1px solid var(--border)",
          paddingRight: "var(--space-3)",
          display: "flex",
          flexDirection: "column",
          gap: "var(--space-2)",
          maxHeight: "80vh",
          overflowY: "auto",
          position: "sticky",
          top: "var(--space-14, 56px)",
        }}>
          <input
            type="text"
            placeholder={`Search ${totalCount} components...`}
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            style={{
              width: "100%",
              padding: "var(--space-1) var(--space-2)",
              fontSize: "var(--font-size-xs)",
              fontFamily: "var(--font-mono)",
              border: "1px solid var(--border)",
              borderRadius: "var(--radius)",
              background: "var(--surface)",
              color: "var(--text)",
              outline: "none",
            }}
          />
          <div style={{ display: "flex", flexDirection: "column", gap: "var(--space-2)" }}>
            {SECTIONS.map((section) => (
              <SidebarSection
                key={section.id}
                section={section}
                activeKey={activeKey}
                onSelect={handleSelect}
                searchFilter={search}
              />
            ))}
          </div>
        </div>

        {/* Detail pane */}
        <div style={{ minWidth: 0 }}>
          {activeEntry ? (
            <div style={{ display: "flex", flexDirection: "column", gap: "var(--space-3)" }}>
              <div style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", color: "var(--text-muted)" }}>
                {activeEntry.section.label} › {activeEntry.group.label}
              </div>
              <LazyDemo entry={activeEntry.entry} />
            </div>
          ) : (
            <div style={{
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              height: "100%",
              fontFamily: "var(--font-mono)",
              fontSize: "var(--font-size-sm)",
              color: "var(--text-muted)",
            }}>
              ← Select a component from the sidebar
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
