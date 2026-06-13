import * as React from "react";
import { cn } from "@/lib/cn";
import type { EntryStatus } from "@/lib/constants";

export interface TimelineEvent {
  id: string;
  date: string;
  era: string;
  title: string;
  summary: string;
  status: EntryStatus;
  entryId?: string;
  isLast?: boolean;
}

interface TimelineItemProps {
  event: TimelineEvent;
  onEntryClick?: (entryId: string) => void;
}

export function TimelineItem({ event, onEntryClick }: TimelineItemProps) {
  const isCanon = event.status === "canon";

  return (
    <div className="flex gap-4">
      {/* Marker + connecting line column */}
      <div className="flex flex-col items-center shrink-0" style={{ width: "20px" }}>
        {/* Dot */}
        <div
          className={cn(
            "w-3 h-3 rounded-full shrink-0 mt-1",
            isCanon ? "bg-accent" : "bg-generated"
          )}
        />
        {/* Vertical line — hidden for last item */}
        {!event.isLast && (
          <div className="w-px flex-1 bg-rule mt-1 min-h-[2rem]" />
        )}
      </div>

      {/* Content */}
      <div
        className={cn(
          "flex-1 min-w-0 pb-8",
          event.isLast && "pb-4"
        )}
      >
        {/* Date + status indicator */}
        <div className="flex items-center gap-2 mb-1">
          <span className="font-mono text-[12px] text-ink-tertiary">
            {event.date}
          </span>
          <span
            className={cn(
              "font-mono text-[8px]",
              isCanon ? "text-canon" : "text-generated"
            )}
          >
            {isCanon ? "■" : "□"}
          </span>
          <span
            className={cn(
              "font-mono text-[10px] uppercase tracking-[0.04em]",
              isCanon ? "text-ink-tertiary" : "text-generated"
            )}
          >
            {isCanon ? "Canon" : "Generated"}
          </span>
        </div>

        {/* Title */}
        {event.entryId && onEntryClick ? (
          <button
            onClick={() => onEntryClick(event.entryId!)}
            className="text-left group"
          >
            <h3
              className={cn(
                "font-serif text-base font-semibold leading-snug",
                "text-ink group-hover:text-link transition-colors duration-200"
              )}
            >
              {event.title}
            </h3>
          </button>
        ) : (
          <h3 className="font-serif text-base font-semibold text-ink leading-snug">
            {event.title}
          </h3>
        )}

        {/* Summary */}
        <p className="font-sans text-[13px] text-ink-secondary leading-relaxed mt-1">
          {event.summary}
        </p>
      </div>
    </div>
  );
}
