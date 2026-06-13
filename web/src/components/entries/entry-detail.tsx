import Link from "next/link";
import { ChevronLeft, AlertTriangle, AlertCircle, Lightbulb, Sparkles, Network } from "lucide-react";
import { cn } from "@/lib/cn";
import type { Entry, Connection } from "@/types/entry";
import { ENTRY_TYPE_LABELS, type FlagSeverity } from "@/lib/constants";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { EntryTypeIcon } from "./entry-type-icon";
import { EntryConnections } from "./entry-connections";

// Extended flag shape — the base Entry type stays minimal;
// the detail view takes the richer shape.
export interface ConsistencyFlag {
  id: string;
  severity: FlagSeverity;
  title: string;
  detail: string;
}

export interface EntryDetailProps {
  entry: Entry;
  connections: Connection[];
  entriesById: Record<string, Entry>;
  flags?: ConsistencyFlag[];
  universeId: string;
}

// ---------------------------------------------------------------------------
// Cross-reference rendering
// Body text encodes inline cross-references as ⌈Entry Name⌉. This function
// parses that syntax and renders matches as styled links. Entries are matched
// by title (case-insensitive). Unresolved references render as plain text.
// ---------------------------------------------------------------------------
function renderBodyWithRefs(
  body: string,
  entriesById: Record<string, Entry>,
  universeId: string
): React.ReactNode[] {
  // Build a lookup: lowercase title → entry
  const byTitle: Record<string, Entry> = {};
  for (const entry of Object.values(entriesById)) {
    byTitle[entry.title.toLowerCase()] = entry;
  }

  // Split on ⌈...⌉ markers
  const parts = body.split(/(⌈[^⌉]+⌉)/g);

  return parts.map((part, i) => {
    const refMatch = part.match(/^⌈([^⌉]+)⌉$/);
    if (!refMatch) {
      // Plain text segment — render as-is within the paragraph context
      return <span key={i}>{part}</span>;
    }

    const refName = refMatch[1];
    const target = byTitle[refName.toLowerCase()];

    if (target) {
      return (
        <Link
          key={i}
          href={`/${universeId}/entries/${target.id}`}
          className={cn(
            "text-link no-underline",
            "border-b border-link/30",
            "hover:border-link",
            "transition-[border-color] duration-200 ease-[ease]"
          )}
        >
          {refName}
        </Link>
      );
    }

    // Unresolved reference — render as muted styled span
    return (
      <span
        key={i}
        className="text-ink-secondary border-b border-dashed border-rule-heavy"
        title="Entry not yet created"
      >
        {refName}
      </span>
    );
  });
}

// ---------------------------------------------------------------------------
// Flag severity helpers
// ---------------------------------------------------------------------------
const flagConfig: Record<
  FlagSeverity,
  { bg: string; border: string; icon: React.ReactNode; label: string }
> = {
  error: {
    bg: "bg-flag-error-muted",
    border: "border-l-flag-error",
    icon: <AlertCircle size={16} strokeWidth={1.5} className="text-flag-error flex-shrink-0 mt-0.5" />,
    label: "Contradiction",
  },
  warning: {
    bg: "bg-flag-warn-muted",
    border: "border-l-flag-warn",
    icon: <AlertTriangle size={16} strokeWidth={1.5} className="text-flag-warn flex-shrink-0 mt-0.5" />,
    label: "Possible Conflict",
  },
  suggestion: {
    bg: "bg-flag-suggestion-muted",
    border: "border-l-flag-suggestion",
    icon: <Lightbulb size={16} strokeWidth={1.5} className="text-flag-suggestion flex-shrink-0 mt-0.5" />,
    label: "Suggestion",
  },
};

// ---------------------------------------------------------------------------
// EntryDetail
// ---------------------------------------------------------------------------
export function EntryDetail({
  entry,
  connections,
  entriesById,
  flags = [],
  universeId,
}: EntryDetailProps) {
  const isCanon = entry.status === "canon";

  return (
    <article className="bg-reading min-h-screen">
      <div className="max-w-[780px] mx-auto px-6 py-12 sm:px-10">

        {/* ── Top bar ── */}
        <div className="flex items-center justify-between mb-8">
          <Link
            href={`/${universeId}/entries`}
            className="inline-flex items-center gap-1.5 font-sans text-[14px] text-ink-secondary hover:text-ink transition-colors duration-200"
          >
            <ChevronLeft size={16} strokeWidth={1.5} />
            Entries
          </Link>

          <Badge variant={isCanon ? "canon" : "generated"}>
            {isCanon ? "■ Canon" : "□ Generated"}
          </Badge>
        </div>

        {/* ── Entry type label ── */}
        <div className="flex items-center gap-2 mb-3">
          <EntryTypeIcon type={entry.type} size={16} />
          <span className="font-mono text-[12px] uppercase tracking-[0.06em] text-ink-tertiary">
            {ENTRY_TYPE_LABELS[entry.type]}
          </span>
        </div>

        {/* ── Title ── */}
        <h1 className="font-serif text-[32px] font-bold leading-tight text-ink mb-5">
          {entry.title}
        </h1>

        {/* ── Tags row ── */}
        {entry.tags.length > 0 && (
          <div className="flex flex-wrap items-center gap-x-2 gap-y-1 mb-3">
            {entry.tags.map((tag, i) => (
              <span key={tag} className="font-mono text-[12px] tracking-[0.02em] text-ink-secondary">
                {i > 0 && (
                  <span className="mr-2 text-ink-tertiary select-none">·</span>
                )}
                {tag}
              </span>
            ))}
          </div>
        )}

        {/* ── Era / Region ── */}
        {(entry.era || entry.region) && (
          <div className="flex items-center gap-2 font-mono text-[12px] text-ink-tertiary mb-6">
            {entry.era && <span>{entry.era}</span>}
            {entry.era && entry.region && (
              <span className="select-none opacity-50">·</span>
            )}
            {entry.region && <span>{entry.region}</span>}
          </div>
        )}

        {/* ── Horizontal rule ── */}
        <hr className="border-0 border-t border-rule mb-8" />

        {/* ── Body ── */}
        <div className="font-body text-lg leading-[1.7] text-ink max-w-[65ch] space-y-6">
          {/* Render paragraphs split by double-newline, each with cross-ref markup */}
          {entry.body.split("\n\n").map((para, i) => (
            <p key={i}>
              {renderBodyWithRefs(para, entriesById, universeId)}
            </p>
          ))}
        </div>

        {/* ── Horizontal rule ── */}
        <hr className="border-0 border-t border-rule mt-10 mb-8" />

        {/* ── Connections section ── */}
        <section aria-labelledby="connections-heading" className="mb-10">
          <h2
            id="connections-heading"
            className="font-serif text-[20px] font-semibold text-ink mb-5"
          >
            Connections
            {connections.length > 0 && (
              <span className="font-mono text-[13px] font-normal text-ink-tertiary ml-2">
                ({connections.length})
              </span>
            )}
          </h2>
          <EntryConnections
            connections={connections}
            entriesById={entriesById}
            universeId={universeId}
            currentEntryId={entry.id}
          />
        </section>

        {/* ── Consistency flags ── */}
        {flags.length > 0 && (
          <>
            <hr className="border-0 border-t border-rule mb-8" />
            <section aria-labelledby="flags-heading" className="mb-10">
              <h2
                id="flags-heading"
                className="font-serif text-[20px] font-semibold text-ink mb-4"
              >
                {flags.length === 1 ? "1 Consistency Flag" : `${flags.length} Consistency Flags`}
              </h2>

              <div className="space-y-3">
                {flags.map((flag) => {
                  const cfg = flagConfig[flag.severity];
                  return (
                    <div
                      key={flag.id}
                      className={cn(
                        "flex gap-3 p-4 rounded-lg",
                        "border-l-[3px]",
                        cfg.bg,
                        cfg.border
                      )}
                    >
                      {cfg.icon}
                      <div className="min-w-0">
                        <p className="font-sans text-[13px] font-semibold text-ink mb-1">
                          <span
                            className={cn(
                              "font-mono text-[10px] uppercase tracking-[0.06em] mr-2 px-1.5 py-0.5 rounded-sm",
                              flag.severity === "error" && "bg-flag-error text-white",
                              flag.severity === "warning" && "bg-flag-warn text-white",
                              flag.severity === "suggestion" && "bg-flag-suggestion text-white"
                            )}
                          >
                            {cfg.label}
                          </span>
                          {flag.title}
                        </p>
                        <p className="font-sans text-[13px] text-ink-secondary leading-[1.5]">
                          {flag.detail}
                        </p>
                        <div className="mt-3">
                          <button className="font-sans text-[13px] font-medium text-link hover:text-link-hover transition-colors duration-200 underline underline-offset-2">
                            Resolve
                          </button>
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            </section>
          </>
        )}

        {/* ── Action buttons ── */}
        <hr className="border-0 border-t border-rule mb-8" />
        <div className="flex flex-wrap gap-3">
          <Button variant="generate" size="md">
            <Sparkles size={15} strokeWidth={1.5} />
            Generate Related
          </Button>
          <Button variant="secondary" size="md">
            <Network size={15} strokeWidth={1.5} />
            View in Graph
          </Button>
        </div>

        {/* ── Footer metadata ── */}
        <div className="mt-10 pt-6 border-t border-rule-subtle flex flex-wrap gap-4 font-mono text-[11px] text-ink-tertiary">
          <span>{entry.wordCount.toLocaleString()} words</span>
          <span className="opacity-40 select-none">·</span>
          <span>v{entry.version}</span>
          <span className="opacity-40 select-none">·</span>
          <span>Updated {new Date(entry.updatedAt).toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" })}</span>
        </div>
      </div>
    </article>
  );
}
