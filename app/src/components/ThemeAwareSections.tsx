"use client";

import { useState, useEffect, useCallback } from "react";
import { useThemeConfig } from "./ThemeConfigContext";
import { sectionRegistry } from "./sections";
import type { CssSection } from "@styleguide-engine/lib/css-gen";
import { IntroHero } from "./IntroHero";
import { ThemeLogo } from "./ThemeLogo";
import { StyleGuideProductBranding } from "./pkg/product-branding";
import { SearchFilter } from "./SearchFilter";
import type { PageSectionDef, StyleGuideConfig } from "@styleguide-engine/lib/types";

const TAB_STORAGE_KEY = "sg-active-tabs";
function loadPersistedTabs(): { group?: string; section?: string } {
  if (typeof window === "undefined" || typeof localStorage?.getItem !== "function") return {};
  try { return JSON.parse(localStorage.getItem(TAB_STORAGE_KEY) || "{}"); } catch { return {}; }
}
function persistTabs(group: string, section: string) {
  try { localStorage.setItem(TAB_STORAGE_KEY, JSON.stringify({ group, section })); } catch { /* noop */ }
}

interface NumberedSection extends PageSectionDef {
  number: string;
}

interface NumberedGroup {
  group: string;
  desc?: string;
  sections: NumberedSection[];
}

interface Props {
  numberedGroups: NumberedGroup[];
  allNumberedGroups?: Record<string, NumberedGroup[]>;
  allCssSections: Record<string, CssSection[]>;
  styleGuideFiles: { name: string; content: string }[];
  brandingYaml: string;
}

function SectionTabs({ group, config, cssSections, styleGuideFiles, brandingYaml, initialSection, onSectionChange }: {
  group: NumberedGroup;
  config: StyleGuideConfig;
  cssSections: CssSection[];
  styleGuideFiles: Props["styleGuideFiles"];
  brandingYaml: string;
  initialSection?: string;
  onSectionChange?: (id: string) => void;
}) {
  const [activeSection, setActiveSection] = useState(
    initialSection && group.sections.find((s) => s.id === initialSection)
      ? initialSection
      : group.sections[0]?.id || ""
  );

  // Reset section tab when group changes
  useEffect(() => {
    if (!group.sections.find((s) => s.id === activeSection)) {
      const next = group.sections[0]?.id || "";
      setActiveSection(next);
      onSectionChange?.(next);
    }
  }, [group, activeSection, onSectionChange]);

  // Respond to external initialSection changes (hash navigation)
  useEffect(() => {
    if (initialSection && group.sections.find((s) => s.id === initialSection)) {
      setActiveSection(initialSection);
    }
  }, [initialSection, group]);

  const selectSection = useCallback((id: string) => {
    setActiveSection(id);
    onSectionChange?.(id);
  }, [onSectionChange]);

  const section = group.sections.find((s) => s.id === activeSection);
  const Section = section ? sectionRegistry[section.id] : null;

  return (
    <>
      <div className="hui tab-list" style={{ fontSize: "var(--font-size-sm)" }}>
        {group.sections.map((s, i) => (
          <button
            key={s.id || `section-${i}`}
            className="hui tab"
            data-selected={activeSection === s.id ? "" : undefined}
            onClick={() => selectSection(s.id)}
          >
            <span style={{ opacity: 0.4, marginRight: "var(--space-half)" }}>{s.number}</span>
            {s.title}
          </button>
        ))}
      </div>
      {section && Section && (
        <Section
          number={section.number}
          id={section.id}
          title={section.title}
          desc={section.desc}
          config={config}
          cssSections={cssSections}
          styleGuideFiles={styleGuideFiles}
          brandingYaml={brandingYaml}
        />
      )}
    </>
  );
}

export function ThemeAwareSections({ numberedGroups, allNumberedGroups, allCssSections, styleGuideFiles, brandingYaml }: Props) {
  const { config, branding, allBrandings, activeSlug } = useThemeConfig();
  const cssSections = allCssSections[activeSlug] || Object.values(allCssSections)[0] || [];
  const activeGroups = allNumberedGroups?.[activeSlug] || numberedGroups;

  const [activeTab, setActiveTab] = useState(activeGroups[0]?.group || "");
  const [targetSection, setTargetSection] = useState<string | undefined>(undefined);
  const [hydrated, setHydrated] = useState(false);

  useEffect(() => {
    if (hydrated) return;
    const persisted = loadPersistedTabs();
    if (persisted.group && activeGroups.find((g) => g.group === persisted.group)) {
      setActiveTab(persisted.group);
    }
    if (persisted.section) {
      setTargetSection(persisted.section);
    }
    setHydrated(true);
  }, [hydrated, activeGroups]);

  // Subsection prefix → parent section id mapping
  const SUBSECTION_PARENTS: Record<string, string> = {
    "site-": "site-archetypes",
    "nav-": "navigation",
    "form-": "ui-elements",
    "status-": "status-indicators",
    "btn-": "ui-elements",
  };

  // Find the section (group + section) that owns a given anchor
  const findSection = useCallback((hash: string): { group: NumberedGroup; section: NumberedSection } | null => {
    // Direct section match: hash is a section id or "section-{id}"
    for (const g of activeGroups) {
      const match = g.sections.find((s) => s.id === hash || `section-${s.id}` === hash);
      if (match) return { group: g, section: match };
    }
    // Subsection match: hash has a known prefix → find parent section
    for (const [prefix, parentId] of Object.entries(SUBSECTION_PARENTS)) {
      if (hash.startsWith(prefix)) {
        for (const g of activeGroups) {
          const match = g.sections.find((s) => s.id === parentId);
          if (match) return { group: g, section: match };
        }
      }
    }
    return null;
  }, [activeGroups]);

  // Scroll to element after render
  const scrollToHash = useCallback((hash: string) => {
    const tryScroll = (attempts: number) => {
      const el = document.getElementById(hash);
      if (el) {
        el.scrollIntoView({ behavior: "smooth", block: "start" });
      } else if (attempts > 0) {
        requestAnimationFrame(() => tryScroll(attempts - 1));
      }
    };
    requestAnimationFrame(() => tryScroll(5));
  }, []);

  // Resolve hash → select correct group + section tab
  const resolveHash = useCallback(() => {
    const raw = window.location.hash.slice(1);
    if (!raw) return;
    const found = findSection(raw);
    if (found) {
      setActiveTab(found.group.group);
      setTargetSection(found.section.id);
      persistTabs(found.group.group, found.section.id);
      scrollToHash(raw);
    }
  }, [findSection, scrollToHash]);

  // On mount + hashchange
  useEffect(() => {
    resolveHash();
    window.addEventListener("hashchange", resolveHash);
    return () => window.removeEventListener("hashchange", resolveHash);
  }, [resolveHash]);

  // Sync active tab when theme changes and groups differ
  useEffect(() => {
    if (!activeGroups.find((g) => g.group === activeTab)) {
      setActiveTab(activeGroups[0]?.group || "");
    }
  }, [activeGroups, activeTab]);

  const handleGroupChange = useCallback((group: string) => {
    setActiveTab(group);
    setTargetSection(undefined); // let SectionTabs pick default
    persistTabs(group, "");
  }, []);

  const handleSectionChange = useCallback((id: string) => {
    persistTabs(activeTab, id);
  }, [activeTab]);

  const activeGroup = activeGroups.find((g) => g.group === activeTab);

  return (
    <>
      <IntroHero brandings={allBrandings} />

      <div className="hr section" />

      <StyleGuideProductBranding
        actions={null}
        name={branding.name}
        logo={
          <ThemeLogo
            brandings={allBrandings}
            fallback={
              <svg viewBox="0 0 200 60" style={{ width: 180 }}>
                <rect className="fill-surface-inverse" width="200" height="60" rx="4" />
                <text
                  className="fill-text-inverse"
                  x="100" y="38"
                  textAnchor="middle"
                  fontFamily="var(--font-mono)"
                  fontWeight="700"
                  fontSize="22"
                  letterSpacing="0.12em"
                >
                  {branding["logo-text"]}
                </text>
                <line x1="16" y1="50" x2="184" y2="50" className="stroke-red" strokeWidth="2" opacity="0.6" />
              </svg>
            }
          />
        }
        intent={branding.intent}
        perception={branding.perception}
        audience={branding.audience}
        tone={branding.tone}
        keywords={branding.keywords}
      />

      <SearchFilter />

      {/* ─── Group tabs (level 1) ─── */}
      <div className="hui tab-list">
        {activeGroups.map((group, i) => (
          <button
            key={group.group || `group-${i}`}
            className="hui tab"
            data-selected={activeTab === group.group ? "" : undefined}
            onClick={() => handleGroupChange(group.group)}
          >
            {group.group}
          </button>
        ))}
      </div>

      {/* ─── Group description ─── */}
      {activeGroup?.desc && (
        <p style={{
          margin: "var(--space-2) 0 0",
          fontSize: "var(--font-size-sm)",
          color: "var(--text-muted)",
          fontFamily: "var(--font-mono)",
        }}>
          {activeGroup.desc}
        </p>
      )}

      {/* ─── Section tabs (level 2) + content ─── */}
      {activeGroup && <SectionTabs group={activeGroup} config={config} cssSections={cssSections} styleGuideFiles={styleGuideFiles} brandingYaml={brandingYaml} initialSection={targetSection} onSectionChange={handleSectionChange} />}
    </>
  );
}
