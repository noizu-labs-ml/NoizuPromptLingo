import * as React from "react";
import { cn } from "@/lib/cn";
import { Badge } from "@/components/ui/badge";
import type { Generation } from "@/types/generation";

interface RecentGenerationsProps {
  generations: Generation[];
  onSelect?: (id: string) => void;
}

const STATUS_BADGE: Record<
  Generation["status"],
  { variant: "canon" | "generated" | "flagged" | "success"; label: string }
> = {
  pending:   { variant: "generated", label: "Pending"  },
  complete:  { variant: "generated", label: "Review"   },
  promoted:  { variant: "canon",     label: "Promoted" },
  discarded: { variant: "flagged",   label: "Discarded"},
};

function timeAgo(iso: string): string {
  const diff = Date.now() - new Date(iso).getTime();
  const mins  = Math.floor(diff / 60_000);
  const hours = Math.floor(diff / 3_600_000);
  const days  = Math.floor(diff / 86_400_000);
  if (days > 0) return `${days}d ago`;
  if (hours > 0) return `${hours}h ago`;
  if (mins > 0) return `${mins}m ago`;
  return "just now";
}

export function RecentGenerations({ generations, onSelect }: RecentGenerationsProps) {
  if (generations.length === 0) {
    return (
      <p className="font-sans text-[13px] text-ink-tertiary italic px-1">
        No recent generations.
      </p>
    );
  }

  return (
    <div>
      <p className="font-mono text-[11px] font-semibold uppercase tracking-[0.06em] text-ink-tertiary mb-2">
        Recent generations
      </p>
      <ul className="space-y-1">
        {generations.map((g) => {
          const { variant, label } = STATUS_BADGE[g.status];
          return (
            <li key={g.id}>
              <button
                onClick={() => onSelect?.(g.id)}
                disabled={!onSelect}
                className={cn(
                  "w-full flex items-start gap-3 px-3 py-2.5 rounded-sm text-left",
                  "hover:bg-elevated transition-colors duration-150",
                  "disabled:cursor-default"
                )}
              >
                {/* Status indicator */}
                <span
                  className={cn(
                    "font-mono text-[8px] mt-1 shrink-0",
                    g.status === "promoted" ? "text-canon" : "text-generated"
                  )}
                >
                  {g.status === "promoted" ? "■" : "□"}
                </span>

                {/* Content */}
                <div className="flex-1 min-w-0">
                  <p className="font-serif text-[13px] text-ink truncate leading-snug">
                    {g.outputTitle ?? g.prompt}
                  </p>
                  <div className="flex items-center gap-2 mt-0.5">
                    <span className="font-mono text-[10px] text-ink-tertiary">
                      {timeAgo(g.createdAt)}
                    </span>
                    <Badge variant={variant} className="text-[9px] px-1.5 py-0">
                      {label}
                    </Badge>
                  </div>
                </div>
              </button>
            </li>
          );
        })}
      </ul>
    </div>
  );
}
