import Link from "next/link";
import { Plus, AlertTriangle, CheckCircle2 } from "lucide-react";
import { universes } from "@/data/universes";

function formatRelativeTime(isoString: string): string {
  const date = new Date(isoString);
  const now = new Date("2026-03-13T14:22:00Z");
  const diffMs = now.getTime() - date.getTime();
  const diffMinutes = Math.floor(diffMs / 60000);
  const diffHours = Math.floor(diffMinutes / 60);
  const diffDays = Math.floor(diffHours / 24);

  if (diffMinutes < 60) return `${diffMinutes}m ago`;
  if (diffHours < 24) return `${diffHours}h ago`;
  if (diffDays === 1) return "yesterday";
  return `${diffDays}d ago`;
}

const recentActivity = [
  {
    id: "1",
    type: "generated" as const,
    label: 'Generated: "Founding of Thornwall"',
    time: "2h ago",
    universeId: "ashward-chronicles",
  },
  {
    id: "2",
    type: "flag" as const,
    label: "Conflict: Kael's age in Ch.3 vs Ch.12",
    time: "3h ago",
    universeId: "ashward-chronicles",
  },
  {
    id: "3",
    type: "promoted" as const,
    label: 'Promoted: "Northern Trade Routes" to canon',
    time: "5h ago",
    universeId: "ashward-chronicles",
  },
  {
    id: "4",
    type: "manual" as const,
    label: 'New entry: "The War of Stones" (manual)',
    time: "yesterday",
    universeId: "ashward-chronicles",
  },
  {
    id: "5",
    type: "generated" as const,
    label: 'Generated: "Ironlight Guild Charter"',
    time: "3d ago",
    universeId: "ironlight-campaign",
  },
];

function ActivityIcon({ type }: { type: typeof recentActivity[number]["type"] }) {
  if (type === "flag") {
    return <AlertTriangle size={14} strokeWidth={1.5} className="text-flag-warn shrink-0 mt-0.5" />;
  }
  if (type === "promoted") {
    return <CheckCircle2 size={14} strokeWidth={1.5} className="text-success shrink-0 mt-0.5" />;
  }
  return (
    <span className="w-[7px] h-[7px] rounded-full bg-accent-muted border border-accent shrink-0 mt-[5px] inline-block" />
  );
}

export default function DashboardPage() {
  return (
    <div>
      {/* Heading */}
      <div className="mb-8">
        <h1 className="font-serif text-[32px] font-bold text-ink leading-tight tracking-[-0.01em]">
          Your Universes
        </h1>
        <p className="font-sans text-[15px] text-ink-secondary mt-1">
          {universes.length} universe{universes.length !== 1 ? "s" : ""} · Select one to explore your world
        </p>
      </div>

      {/* Universe grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-5 mb-12">
        {universes.map((universe) => (
          <Link
            key={universe.id}
            href={`/${universe.id}`}
            className="group block bg-surface border border-rule rounded-xl p-7 transition-all duration-200 hover:-translate-y-0.5 hover:shadow-[0_4px_16px_rgba(0,0,0,0.06)] hover:border-rule-heavy"
          >
            <div className="flex items-start justify-between gap-3 mb-3">
              <h3 className="font-serif text-[20px] font-semibold text-ink leading-snug group-hover:text-accent transition-colors duration-200">
                {universe.name}
              </h3>
              {universe.flagCount > 0 ? (
                <span className="flex items-center gap-1 font-mono text-[11px] text-flag-warn bg-flag-warn-muted px-2 py-0.5 rounded-full shrink-0 mt-0.5">
                  <AlertTriangle size={10} strokeWidth={2} />
                  {universe.flagCount}
                </span>
              ) : (
                <span className="flex items-center gap-1 font-mono text-[11px] text-success bg-success-muted px-2 py-0.5 rounded-full shrink-0 mt-0.5">
                  <CheckCircle2 size={10} strokeWidth={2} />
                  clear
                </span>
              )}
            </div>

            <p className="font-mono text-[11px] text-ink-tertiary uppercase tracking-[0.04em] mb-3">
              {universe.genre}
            </p>

            <p className="font-sans text-[13px] text-ink-secondary leading-relaxed line-clamp-2 mb-5">
              {universe.description}
            </p>

            <div className="flex items-center gap-4 font-mono text-[11px] text-ink-tertiary tracking-[0.02em]">
              <span>{universe.entryCount} entries</span>
              <span className="text-rule">·</span>
              <span>{universe.connectionCount} connections</span>
              <span className="text-rule">·</span>
              <span>Updated {formatRelativeTime(universe.updatedAt)}</span>
            </div>
          </Link>
        ))}

        {/* New Universe card */}
        <Link
          href="/new"
          className="flex flex-col items-center justify-center gap-3 bg-surface border border-dashed border-rule rounded-xl p-7 transition-all duration-200 hover:border-accent hover:bg-accent-muted group min-h-[160px]"
        >
          <div className="w-10 h-10 rounded-full border border-dashed border-rule-heavy group-hover:border-accent flex items-center justify-center transition-colors duration-200">
            <Plus size={18} strokeWidth={1.5} className="text-ink-tertiary group-hover:text-accent transition-colors duration-200" />
          </div>
          <span className="font-sans text-[14px] font-medium text-ink-secondary group-hover:text-accent transition-colors duration-200">
            New Universe
          </span>
        </Link>
      </div>

      {/* Recent Activity */}
      <section>
        <h2 className="font-mono text-[11px] font-semibold uppercase tracking-[0.06em] text-ink-tertiary mb-4">
          Recent Activity
        </h2>
        <div className="border-t border-rule-subtle">
          {recentActivity.map((item) => (
            <div
              key={item.id}
              className="flex items-start gap-3 py-3 border-b border-rule-subtle"
            >
              <ActivityIcon type={item.type} />
              <span className="font-sans text-[14px] text-ink-secondary flex-1 leading-snug">
                {item.label}
              </span>
              <span className="font-mono text-[11px] text-ink-tertiary shrink-0 mt-0.5">
                {item.time}
              </span>
            </div>
          ))}
        </div>
      </section>
    </div>
  );
}
