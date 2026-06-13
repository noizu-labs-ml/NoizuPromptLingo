"use client";

import * as React from "react";
import { useParams, useRouter } from "next/navigation";
import { TimelineItem } from "@/components/timeline/timeline-item";
import { cn } from "@/lib/cn";
import type { TimelineEvent } from "@/components/timeline/timeline-item";

// ── Mock chronological events — The Ashward Chronicles ───────────────────
const ALL_EVENTS: TimelineEvent[] = [
  {
    id: "evt-1",
    date:    "Year 112, Third Age",
    era:     "founding",
    title:   "Founding of Thornwall",
    summary: "A company of smiths settles the coastal cliffs, clearing sea-bramble to set the first forge. Within three winters, forty smiths have joined and iron trade routes reroute east through the new settlement.",
    status:  "generated",
    entryId: "founding-myth",
  },
  {
    id: "evt-2",
    date:    "Year 156, Third Age",
    era:     "founding",
    title:   "The Water Law of the Blacksmith Guild",
    summary: "The Guild codifies its founding charter. The first and most important provision is not about iron but about water: all coastal wells are to remain shared and untaxed. This law will be cited for centuries as the reason Thornwall remained a community rather than a company town.",
    status:  "canon",
    entryId: "blacksmiths",
  },
  {
    id: "evt-3",
    date:    "Year 199, Third Age",
    era:     "age-of-iron",
    title:   "The Amber Road Opens",
    summary: "The Northern Reach's first major trade artery is formally established, running from Thornwall through the Duskgate Pass and into the Eastern Reaches. The iron trade reaches its first peak; three generations of Guild masters oversee the waystation network.",
    status:  "canon",
    entryId: "iron-routes",
  },
  {
    id: "evt-4",
    date:    "Year 247, Third Age",
    era:     "age-of-iron",
    title:   "Cold-Singing Technique Introduced",
    summary: "A journeyman known only as 'Kael's grandfather' descends from the high passes carrying a hammer-tone forging method called cold-singing. He teaches it to any smith who will learn — binding the technique to the Guild's culture of open knowledge.",
    status:  "canon",
    entryId: "cold-singing",
  },
  {
    id: "evt-5",
    date:    "Year 280, Third Age",
    era:     "age-of-iron",
    title:   "Peak of the Iron Trade",
    summary: "Thornwall operates eleven active forges. The Blacksmith Guild has over two hundred members and franchise workshops in seven settlements along the Amber Road. Kael's father is admitted to the Guild as a journeyman.",
    status:  "generated",
    entryId: "iron-routes",
  },
  {
    id: "evt-6",
    date:    "Year 301, Third Age",
    era:     "war",
    title:   "Birth of Kael Ashward",
    summary: "Kael is born in the third-floor rooms of the Thornwall forge-house. He is the fourth generation of his family to work the cold-singing tradition, though he will not begin his apprenticeship until age seven.",
    status:  "canon",
    entryId: "kael",
  },
  {
    id: "evt-7",
    date:    "Year 312, Third Age",
    era:     "war",
    title:   "Outbreak of the War of Stones",
    summary: "The Eastern Reaches Consortium claims control of the Duskgate Pass and levies a transit toll on all iron shipments. The Northern Reach coalition refuses; the first skirmish occurs at the second Amber Road waystation. The war will last six years.",
    status:  "canon",
    entryId: "war-stones",
  },
  {
    id: "evt-8",
    date:    "Year 318, Third Age",
    era:     "war",
    title:   "Treaty of Dusk — War Ends",
    summary: "The War of Stones ends with the Treaty of Dusk, signed at Greymere. The Duskgate Pass is designated a neutral transit corridor. The iron trade never fully recovers its pre-war volume. Kael is 17 and has been working his father's forge for two years.",
    status:  "canon",
    entryId: "treaty-dusk",
  },
  {
    id: "evt-9",
    date:    "Year 341, Third Age",
    era:     "present",
    title:   "Kael Becomes Last Guild Master",
    summary: "Following the deaths of the previous masters in a forge accident, Kael Ashward (40) is elevated to Guild Master — the last to hold the title. Membership has fallen to fewer than thirty smiths.",
    status:  "canon",
    entryId: "kael",
  },
  {
    id: "evt-10",
    date:    "Year 349, Third Age",
    era:     "present",
    title:   "Mira Ashward's Apprenticeship Begins",
    summary: "Kael's daughter Mira begins her formal apprenticeship at fourteen, becoming the first woman to formally apprentice in the Guild since its founding generation. Kael teaches her cold-singing himself.",
    status:  "canon",
    entryId: "mira",
  },
];

const ERAS = [
  { value: "all",         label: "All Eras"      },
  { value: "founding",    label: "Founding Era"  },
  { value: "age-of-iron", label: "Age of Iron"   },
  { value: "war",         label: "War of Stones" },
  { value: "present",     label: "Present Day"   },
];
// ──────────────────────────────────────────────────────────────────────────

export default function TimelinePage() {
  const params = useParams<{ universeId: string }>();
  const router = useRouter();

  const [eraFilter, setEraFilter] = React.useState("all");

  const filteredEvents = React.useMemo(() => {
    if (eraFilter === "all") return ALL_EVENTS;
    return ALL_EVENTS.filter((e) => e.era === eraFilter);
  }, [eraFilter]);

  const eventsWithLast = filteredEvents.map((e, i) => ({
    ...e,
    isLast: i === filteredEvents.length - 1,
  }));

  function handleEntryClick(entryId: string) {
    router.push(`/${params.universeId}/entries/${entryId}`);
  }

  const canonCount = ALL_EVENTS.filter((e) => e.status === "canon").length;
  const genCount   = ALL_EVENTS.filter((e) => e.status === "generated").length;

  return (
    <div className="min-h-full bg-page">
      {/* Page header */}
      <div className="px-6 pt-8 pb-4 border-b border-rule-subtle">
        <div className="flex items-baseline justify-between gap-4">
          <div>
            <h2 className="font-serif text-[28px] font-bold text-ink">Timeline</h2>
            <p className="font-sans text-[14px] text-ink-secondary mt-1">
              Chronological events — canon and generated.
            </p>
          </div>
          {/* Era filter */}
          <div className="relative shrink-0">
            <select
              value={eraFilter}
              onChange={(e) => setEraFilter(e.target.value)}
              className={cn(
                "appearance-none bg-elevated text-ink font-sans text-[13px]",
                "px-3 py-1.5 pr-7 border border-rule rounded-sm",
                "focus:outline-none focus:border-link focus:shadow-[0_0_0_3px_var(--focus-ring)]",
                "cursor-pointer transition-colors duration-200"
              )}
            >
              {ERAS.map((era) => (
                <option key={era.value} value={era.value}>
                  {era.label}
                </option>
              ))}
            </select>
            <span className="pointer-events-none absolute right-2 top-1/2 -translate-y-1/2 text-ink-tertiary text-[10px]">
              ▾
            </span>
          </div>
        </div>
      </div>

      {/* Timeline */}
      <div className="px-6 py-8">
        <div className="max-w-2xl">
          {/* Era label when filtered */}
          {eraFilter !== "all" && (
            <p className="font-mono text-[11px] uppercase tracking-[0.08em] text-ink-tertiary mb-6">
              {ERAS.find((e) => e.value === eraFilter)?.label ?? eraFilter}
              {" — "}
              {filteredEvents.length} event{filteredEvents.length !== 1 ? "s" : ""}
            </p>
          )}

          {filteredEvents.length === 0 ? (
            <p className="font-serif text-[15px] text-ink-tertiary italic">
              No events in this era.
            </p>
          ) : (
            <div>
              {eventsWithLast.map((event) => (
                <TimelineItem
                  key={event.id}
                  event={event}
                  onEntryClick={handleEntryClick}
                />
              ))}
            </div>
          )}

          {/* Footer metadata */}
          <div className="mt-4 pt-4 border-t border-rule-subtle">
            <p className="font-mono text-[11px] text-ink-tertiary">
              {ALL_EVENTS.length} total events &middot; {canonCount} canon &middot; {genCount} generated
              {eraFilter !== "all" && (
                <span className="text-accent ml-2">
                  · Filtered: {filteredEvents.length} shown
                </span>
              )}
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
