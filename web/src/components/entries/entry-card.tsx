import Link from "next/link";
import { cn } from "@/lib/cn";
import type { Entry } from "@/types/entry";
import { ENTRY_TYPE_LABELS } from "@/lib/constants";
import { EntryTypeIcon } from "./entry-type-icon";
import { Share2 } from "lucide-react";

interface EntryCardProps {
  entry: Entry;
  universeId: string;
}

export function EntryCard({ entry, universeId }: EntryCardProps) {
  const isCanon = entry.status === "canon";

  return (
    <Link
      href={`/${universeId}/entries/${entry.id}`}
      className="group block"
    >
      <article
        className={cn(
          // Base card
          "bg-surface border border-rule-subtle rounded-lg p-6",
          "transition-[border-color,box-shadow] duration-200 ease-[ease]",
          "group-hover:border-rule group-hover:shadow-[0_2px_8px_rgba(0,0,0,0.04)]",
          // Canon/generated left border distinction
          isCanon
            ? "border-l-[3px] border-l-canon"
            : "border-l-[3px] border-l-generated [border-left-style:dashed]"
        )}
      >
        {/* Header row: type icon + type label + status dot */}
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center gap-2">
            <EntryTypeIcon type={entry.type} size={16} />
            <span className="font-mono text-[11px] uppercase tracking-[0.06em] text-ink-tertiary">
              {ENTRY_TYPE_LABELS[entry.type]}
            </span>
          </div>
          <span
            className={cn(
              "w-1.5 h-1.5 rounded-full flex-shrink-0",
              isCanon ? "bg-canon" : "bg-generated"
            )}
            title={isCanon ? "Canon" : "Generated"}
          />
        </div>

        {/* Title */}
        <h3 className="font-serif text-[18px] font-semibold leading-snug text-ink mb-2 group-hover:text-accent transition-colors duration-200">
          {entry.title}
        </h3>

        {/* Excerpt — 2-line clamp */}
        <p className="font-body text-[14px] leading-[1.6] text-ink-secondary line-clamp-2 mb-4">
          {entry.excerpt}
        </p>

        {/* Tags */}
        {entry.tags.length > 0 && (
          <div className="flex flex-wrap gap-1.5 mb-3">
            {entry.tags.map((tag) => (
              <span
                key={tag}
                className="font-mono text-[12px] tracking-[0.02em] text-ink-tertiary bg-elevated rounded-sm px-2 py-0.5"
              >
                {tag}
              </span>
            ))}
          </div>
        )}

        {/* Footer: era/region + connection count */}
        <div className="flex items-center justify-between mt-auto pt-3 border-t border-rule-subtle">
          <div className="flex items-center gap-2 font-mono text-[11px] text-ink-tertiary">
            {entry.era && <span>{entry.era}</span>}
            {entry.era && entry.region && (
              <span className="opacity-40">·</span>
            )}
            {entry.region && <span>{entry.region}</span>}
          </div>

          {entry.connectionIds.length > 0 && (
            <div className="flex items-center gap-1 text-ink-tertiary">
              <Share2 size={12} strokeWidth={1.5} />
              <span className="font-mono text-[11px]">
                {entry.connectionIds.length}
              </span>
            </div>
          )}
        </div>
      </article>
    </Link>
  );
}
