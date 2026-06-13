"use client";

import * as React from "react";
import { FlagCard } from "@/components/consistency/flag-card";
import { cn } from "@/lib/cn";
import type { FlagSeverity } from "@/lib/constants";

// ── Mock flag data ────────────────────────────────────────────────────────
interface MockFlag {
  id: string;
  severity: FlagSeverity;
  title: string;
  detail: string;
  entries: { id: string; label: string }[];
}

const MOCK_FLAGS: MockFlag[] = [
  {
    id: "flag-1",
    severity: "error",
    title: "Age contradiction — Kael Ashward at the War of Stones",
    detail:
      'Entry "Kael Ashward" states he was 14 at the outbreak of the War of Stones. Entry "War of Stones" gives the outbreak date as Year 312 of the Third Age. Entry "Kael Ashward" gives his birth year as Year 301 — which would make him 11, not 14, at the war\'s start.',
    entries: [
      { id: "kael",       label: "Kael Ashward"  },
      { id: "war-stones", label: "War of Stones" },
    ],
  },
  {
    id: "flag-2",
    severity: "error",
    title: "Duplicate faction name — 'Ironwright Guild' appears twice",
    detail:
      'Two separate faction entries share the name "Ironwright Guild." One describes a smithing guild in Thornwall, the other a weapons manufacturing consortium in the Eastern Reaches. These may be the same organization or two distinct factions requiring different names.',
    entries: [
      { id: "ironwright-thornwall", label: "Ironwright Guild (Thornwall)"        },
      { id: "ironwright-east",      label: "Ironwright Guild (Eastern Reaches)"  },
    ],
  },
  {
    id: "flag-3",
    severity: "warning",
    title: "Possible geographic impossibility — The Amber Road route",
    detail:
      'Entry "Iron Trade Routes" describes the Amber Road as running directly through the Frostspine Mountains without mentioning a pass. Entry "Frostspine Mountains" describes the range as impassable without the Duskgate Pass.',
    entries: [
      { id: "iron-routes", label: "Iron Trade Routes"    },
      { id: "frostspine",  label: "Frostspine Mountains" },
    ],
  },
  {
    id: "flag-4",
    severity: "warning",
    title: "Timeline gap — 40-year silence in Guild records",
    detail:
      'Guild history entries jump from Year 280 to Year 321 with no entries covering the War of Stones period (Years 312–318). This gap coincides with major events that would have directly affected the Guild. Consider whether the gap is intentional or an oversight.',
    entries: [
      { id: "blacksmiths", label: "Blacksmith Guild" },
    ],
  },
  {
    id: "flag-5",
    severity: "suggestion",
    title: "Thornwall has no founding myth entry",
    detail:
      'Thornwall is one of the most-referenced locations with 8 connections, but has no founding myth or origin event. The Generated entry "Founding of Thornwall" has been pending review. Consider promoting it or writing a canon origin.',
    entries: [
      { id: "thornwall",     label: "Thornwall"             },
      { id: "founding-myth", label: "Founding of Thornwall" },
    ],
  },
  {
    id: "flag-6",
    severity: "suggestion",
    title: "Kael Ashward has no physical description",
    detail:
      'Character entry "Kael Ashward" contains extensive biographical and skill information but no physical description. Adding appearance details would help generated entries maintain visual consistency.',
    entries: [
      { id: "kael", label: "Kael Ashward" },
    ],
  },
];

type FilterTab = "all" | FlagSeverity;

const FILTER_TABS: { value: FilterTab; label: string }[] = [
  { value: "all",        label: "All"         },
  { value: "error",      label: "Errors"      },
  { value: "warning",    label: "Warnings"    },
  { value: "suggestion", label: "Suggestions" },
];
// ──────────────────────────────────────────────────────────────────────────

export default function ConsistencyPage() {
  const [activeFilter, setActiveFilter] = React.useState<FilterTab>("all");
  const [resolved, setResolved]         = React.useState<Set<string>>(new Set());

  const visibleFlags = MOCK_FLAGS.filter((f) => {
    if (resolved.has(f.id)) return false;
    if (activeFilter === "all") return true;
    return f.severity === activeFilter;
  });

  const counts = {
    all:        MOCK_FLAGS.filter((f) => !resolved.has(f.id)).length,
    error:      MOCK_FLAGS.filter((f) => !resolved.has(f.id) && f.severity === "error").length,
    warning:    MOCK_FLAGS.filter((f) => !resolved.has(f.id) && f.severity === "warning").length,
    suggestion: MOCK_FLAGS.filter((f) => !resolved.has(f.id) && f.severity === "suggestion").length,
  };

  function handleMarkIntentional(flagId: string) {
    setResolved((prev) => new Set([...prev, flagId]));
  }

  return (
    <div className="min-h-full bg-page">
      {/* Page header */}
      <div className="px-6 pt-8 pb-4 border-b border-rule-subtle">
        <div className="flex items-baseline justify-between">
          <div>
            <h2 className="font-serif text-[28px] font-bold text-ink">Consistency Flags</h2>
            <p className="font-sans text-[14px] text-ink-secondary mt-1">
              Contradictions, conflicts, and suggestions detected by the consistency engine.
            </p>
          </div>
          <span className="font-mono text-[12px] text-ink-secondary shrink-0">
            {counts.all} active flag{counts.all !== 1 ? "s" : ""}
          </span>
        </div>
      </div>

      {/* Filter tabs */}
      <div className="flex items-center gap-1 px-6 py-3 border-b border-rule-subtle bg-surface sticky top-0 z-10">
        {FILTER_TABS.map((tab) => (
          <button
            key={tab.value}
            onClick={() => setActiveFilter(tab.value)}
            className={cn(
              "px-3 py-1.5 rounded-sm font-sans text-[13px] transition-colors duration-150",
              "focus-visible:outline-2 focus-visible:outline-link",
              activeFilter === tab.value
                ? "bg-accent-muted text-accent font-semibold"
                : "text-ink-secondary hover:text-ink hover:bg-elevated"
            )}
          >
            {tab.label}
            <span
              className={cn(
                "ml-1.5 font-mono text-[11px]",
                activeFilter === tab.value ? "text-accent" : "text-ink-tertiary"
              )}
            >
              {counts[tab.value]}
            </span>
          </button>
        ))}
      </div>

      {/* Flag list */}
      <div className="px-6 py-6">
        {visibleFlags.length === 0 ? (
          <div className="text-center py-16">
            <p className="font-serif text-lg text-ink-secondary italic">
              No flags in this category.
            </p>
            <p className="font-sans text-[13px] text-ink-tertiary mt-2">
              {resolved.size > 0
                ? `${resolved.size} flag${resolved.size !== 1 ? "s" : ""} marked as intentional.`
                : "The consistency checker runs continuously as you add or edit entries."}
            </p>
          </div>
        ) : (
          <div className="space-y-4 max-w-3xl">
            {visibleFlags.map((flag) => (
              <FlagCard
                key={flag.id}
                id={flag.id}
                severity={flag.severity}
                title={flag.title}
                detail={flag.detail}
                entries={flag.entries}
                onFixEntry={(entryId) => console.log("Fix entry:", entryId)}
                onMarkIntentional={handleMarkIntentional}
              />
            ))}
          </div>
        )}
      </div>

      {/* Bottom metadata */}
      <div className="px-6 pb-8 max-w-3xl">
        <p className="font-mono text-[11px] text-ink-tertiary border-t border-rule-subtle pt-4">
          <span className="text-flag-error">{counts.error} error{counts.error !== 1 ? "s" : ""}</span>
          {" · "}
          <span className="text-flag-warn">{counts.warning} warning{counts.warning !== 1 ? "s" : ""}</span>
          {" · "}
          <span className="text-flag-suggestion">{counts.suggestion} suggestion{counts.suggestion !== 1 ? "s" : ""}</span>
          {resolved.size > 0 && (
            <span className="text-success ml-2">
              · {resolved.size} resolved
            </span>
          )}
        </p>
      </div>
    </div>
  );
}
