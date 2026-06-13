"use client";

import { useState, useEffect } from "react";

interface Tab {
  id: string;
  title: string;
  content: React.ReactNode;
}

interface Props {
  tabs: Tab[];
  initialTab?: string;
}

const SS_TAB_KEY = "sg-subsection-tab";
function loadSubTab(parentId: string): string | null {
  try {
    const all = JSON.parse(localStorage.getItem(SS_TAB_KEY) || "{}");
    return all[parentId] || null;
  } catch { return null; }
}
function persistSubTab(parentId: string, tabId: string) {
  try {
    const all = JSON.parse(localStorage.getItem(SS_TAB_KEY) || "{}");
    all[parentId] = tabId;
    localStorage.setItem(SS_TAB_KEY, JSON.stringify(all));
  } catch { /* noop */ }
}

export function SubsectionTabs({ tabs, initialTab }: Props) {
  const parentId = tabs.map((t) => t.id).join(",");

  const [active, setActive] = useState(() => {
    if (initialTab && tabs.find((t) => t.id === initialTab)) return initialTab;
    const stored = loadSubTab(parentId);
    if (stored && tabs.find((t) => t.id === stored)) return stored;
    return tabs[0]?.id || "";
  });

  useEffect(() => {
    if (initialTab && tabs.find((t) => t.id === initialTab)) {
      setActive(initialTab);
    }
  }, [initialTab, tabs]);

  // Listen for hash changes targeting our tabs
  useEffect(() => {
    const handler = () => {
      const hash = window.location.hash.slice(1);
      if (!hash) return;
      const tab = tabs.find((t) => t.id === hash);
      if (tab) setActive(tab.id);
    };
    window.addEventListener("hashchange", handler);
    return () => window.removeEventListener("hashchange", handler);
  }, [tabs]);

  const select = (id: string) => {
    setActive(id);
    persistSubTab(parentId, id);
    // Update URL hash for deep linking without triggering a scroll
    history.replaceState(null, "", `#${id}`);
  };

  const activeTab = tabs.find((t) => t.id === active);

  return (
    <>
      <div className="hui tab-list" style={{ fontSize: "var(--font-size-xs)" }}>
        {tabs.map((t, i) => (
          <button
            key={t.id || `tab-${i}`}
            className="hui tab"
            data-selected={active === t.id ? "" : undefined}
            onClick={() => select(t.id)}
          >
            {t.title}
            {active === t.id && (
              <a
                href={`#${t.id}`}
                onClick={(e) => e.stopPropagation()}
                style={{
                  marginLeft: "var(--space-half)",
                  opacity: 0.4,
                  fontSize: "var(--font-size-2xs)",
                  textDecoration: "none",
                  color: "inherit",
                }}
                title={`Deep link to ${t.title}`}
              >
                #
              </a>
            )}
          </button>
        ))}
      </div>
      {activeTab && (
        <div id={activeTab.id} style={{ paddingTop: "var(--space-2)" }}>
          {activeTab.content}
        </div>
      )}
    </>
  );
}
