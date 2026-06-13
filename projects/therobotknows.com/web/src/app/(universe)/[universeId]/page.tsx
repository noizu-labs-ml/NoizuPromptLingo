import { notFound } from "next/navigation";
import Link from "next/link";
import {
  User,
  MapPin,
  Swords,
  Landmark,
  Gem,
  Lightbulb,
  ScrollText,
  AlertTriangle,
  Network,
  BookOpen,
} from "lucide-react";
import { universes } from "@/data/universes";
import type { EntryType } from "@/lib/constants";
import { ENTRY_TYPE_LABELS } from "@/lib/constants";

// Mock per-type counts for demo
const mockTypeCounts: Record<EntryType, { count: number; latest: string }> = {
  character: { count: 8, latest: "Kael Ashward" },
  location: { count: 5, latest: "Thornwall" },
  event: { count: 4, latest: "The War of Stones" },
  faction: { count: 3, latest: "Blacksmith Guild" },
  object: { count: 2, latest: "The Coldsingers' Blade" },
  concept: { count: 1, latest: "Cold-singing" },
  rule: { count: 1, latest: "Iron Trade Protocols" },
};

const typeIconMap: Record<EntryType, React.ComponentType<{ size?: number; strokeWidth?: number; className?: string }>> = {
  character: User,
  location: MapPin,
  event: Swords,
  faction: Landmark,
  object: Gem,
  concept: Lightbulb,
  rule: ScrollText,
};

const typeColorMap: Record<EntryType, string> = {
  character: "text-accent bg-accent-muted",
  location: "text-success bg-success-muted",
  event: "text-flag-warn bg-flag-warn-muted",
  faction: "text-link bg-[rgba(45,90,142,0.08)]",
  object: "text-ink-secondary bg-elevated",
  concept: "text-[#5B4A8A] bg-[rgba(91,74,138,0.08)]",
  rule: "text-ink bg-elevated",
};

// Mock recent entries
const recentEntries = [
  { id: "kael-ashward", title: "Kael Ashward", type: "character" as EntryType, status: "canon" as const, updatedAt: "2h ago" },
  { id: "thornwall", title: "Thornwall", type: "location" as EntryType, status: "canon" as const, updatedAt: "2h ago" },
  { id: "founding-of-thornwall", title: "Founding of Thornwall", type: "event" as EntryType, status: "generated" as const, updatedAt: "2h ago" },
  { id: "war-of-stones", title: "The War of Stones", type: "event" as EntryType, status: "canon" as const, updatedAt: "yesterday" },
  { id: "iron-trade-routes", title: "Iron Trade Routes", type: "concept" as EntryType, status: "canon" as const, updatedAt: "3d ago" },
];

interface PageProps {
  params: Promise<{ universeId: string }>;
}

export default async function UniverseOverviewPage({ params }: PageProps) {
  const { universeId } = await params;
  const universe = universes.find((u) => u.id === universeId);

  if (!universe) {
    notFound();
  }

  const entryTypes = Object.keys(mockTypeCounts) as EntryType[];

  return (
    <div className="px-8 py-8 max-w-4xl">

      {/* Universe header */}
      <div className="mb-8">
        <h1 className="font-serif text-[32px] font-bold text-ink leading-tight tracking-[-0.01em] mb-1">
          {universe.name}
        </h1>
        <p className="font-mono text-[12px] text-ink-tertiary uppercase tracking-[0.04em]">
          {universe.genre}
        </p>
      </div>

      {/* Quick stats bar */}
      <div className="flex items-center gap-6 p-4 bg-surface border border-rule-subtle rounded-lg mb-8">
        <div className="flex items-center gap-2">
          <BookOpen size={15} strokeWidth={1.5} className="text-ink-tertiary" />
          <span className="font-sans text-[14px] text-ink font-semibold">
            {universe.entryCount}
          </span>
          <span className="font-sans text-[13px] text-ink-secondary">entries</span>
        </div>
        <span className="text-rule-subtle text-ink-tertiary">|</span>
        <div className="flex items-center gap-2">
          <Network size={15} strokeWidth={1.5} className="text-ink-tertiary" />
          <span className="font-sans text-[14px] text-ink font-semibold">
            {universe.connectionCount}
          </span>
          <span className="font-sans text-[13px] text-ink-secondary">connections</span>
        </div>
        <span className="text-rule-subtle text-ink-tertiary">|</span>
        <div className="flex items-center gap-2">
          <AlertTriangle
            size={15}
            strokeWidth={1.5}
            className={universe.flagCount > 0 ? "text-flag-warn" : "text-ink-tertiary"}
          />
          <span
            className={`font-sans text-[14px] font-semibold ${
              universe.flagCount > 0 ? "text-flag-warn" : "text-ink"
            }`}
          >
            {universe.flagCount}
          </span>
          <span className="font-sans text-[13px] text-ink-secondary">
            {universe.flagCount === 1 ? "flag" : "flags"}
          </span>
        </div>

        <div className="flex-1" />

        <Link
          href={`/${universeId}/entries/new`}
          className="font-sans text-[13px] font-semibold text-surface bg-accent hover:bg-accent-hover px-4 py-1.5 rounded transition-colors duration-200"
        >
          + New Entry
        </Link>
      </div>

      {/* Entry type grid */}
      <section className="mb-10">
        <h2 className="font-mono text-[11px] font-semibold uppercase tracking-[0.06em] text-ink-tertiary mb-4">
          Entry Types
        </h2>
        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3">
          {entryTypes.map((type) => {
            const Icon = typeIconMap[type];
            const colorClasses = typeColorMap[type];
            const { count, latest } = mockTypeCounts[type];
            return (
              <Link
                key={type}
                href={`/${universeId}/entries?type=${type}`}
                className="group bg-surface border border-rule-subtle rounded-lg p-4 transition-all duration-200 hover:border-rule hover:shadow-[0_2px_8px_rgba(0,0,0,0.04)]"
              >
                <div
                  className={`inline-flex items-center justify-center w-8 h-8 rounded ${colorClasses} mb-3`}
                >
                  <Icon size={15} strokeWidth={1.5} />
                </div>
                <div className="font-sans text-[13px] font-semibold text-ink mb-0.5">
                  {ENTRY_TYPE_LABELS[type]}
                </div>
                <div className="font-mono text-[11px] text-ink-tertiary mb-2">
                  {count} {count === 1 ? "entry" : "entries"}
                </div>
                {count > 0 && (
                  <div className="font-serif text-[12px] text-ink-secondary truncate">
                    {latest}
                  </div>
                )}
              </Link>
            );
          })}
        </div>
      </section>

      {/* Recent entries */}
      <section>
        <div className="flex items-center justify-between mb-4">
          <h2 className="font-mono text-[11px] font-semibold uppercase tracking-[0.06em] text-ink-tertiary">
            Recent Entries
          </h2>
          <Link
            href={`/${universeId}/entries`}
            className="font-sans text-[12px] text-ink-secondary hover:text-accent transition-colors duration-200"
          >
            View all →
          </Link>
        </div>

        <div className="border-t border-rule-subtle">
          {recentEntries.map((entry) => {
            const Icon = typeIconMap[entry.type];
            const isCanon = entry.status === "canon";
            return (
              <Link
                key={entry.id}
                href={`/${universeId}/entries/${entry.id}`}
                className="flex items-center gap-4 py-3 border-b border-rule-subtle hover:bg-elevated/50 -mx-2 px-2 rounded transition-colors duration-200"
              >
                {/* Canon/generated indicator */}
                <span
                  className={`text-[8px] shrink-0 ${
                    isCanon ? "text-canon" : "text-generated"
                  }`}
                  title={isCanon ? "Canon" : "Generated"}
                >
                  {isCanon ? "■" : "□"}
                </span>

                {/* Entry title */}
                <span className="font-serif text-[15px] text-ink flex-1 truncate">
                  {entry.title}
                </span>

                {/* Type badge */}
                <span className="flex items-center gap-1 font-mono text-[11px] text-ink-tertiary shrink-0">
                  <Icon size={12} strokeWidth={1.5} />
                  {ENTRY_TYPE_LABELS[entry.type]}
                </span>

                {/* Time */}
                <span className="font-mono text-[11px] text-ink-tertiary shrink-0 w-20 text-right">
                  {entry.updatedAt}
                </span>
              </Link>
            );
          })}
        </div>
      </section>
    </div>
  );
}
