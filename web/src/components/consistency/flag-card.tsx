import * as React from "react";
import { AlertCircle, AlertTriangle, Lightbulb } from "lucide-react";
import { cn } from "@/lib/cn";
import { Button } from "@/components/ui/button";
import type { FlagSeverity } from "@/lib/constants";

interface FlagCardEntry {
  id: string;
  label: string;
}

interface FlagCardProps {
  id: string;
  severity: FlagSeverity;
  title: string;
  detail: string;
  entries: FlagCardEntry[];
  onFixEntry?: (entryId: string) => void;
  onMarkIntentional?: (flagId: string) => void;
}

const SEVERITY_CONFIG: Record<
  FlagSeverity,
  {
    borderColor: string;
    bgClass: string;
    textClass: string;
    icon: React.ComponentType<{ size?: number; strokeWidth?: number; className?: string }>;
    label: string;
  }
> = {
  error: {
    borderColor: "#C4432B",
    bgClass: "bg-flag-error-muted",
    textClass: "text-flag-error",
    icon: AlertCircle,
    label: "Contradiction",
  },
  warning: {
    borderColor: "#B8860B",
    bgClass: "bg-flag-warn-muted",
    textClass: "text-flag-warn",
    icon: AlertTriangle,
    label: "Possible Conflict",
  },
  suggestion: {
    borderColor: "#2D5A8E",
    bgClass: "bg-flag-suggestion-muted",
    textClass: "text-flag-suggestion",
    icon: Lightbulb,
    label: "Suggestion",
  },
};

export function FlagCard({
  id,
  severity,
  title,
  detail,
  entries,
  onFixEntry,
  onMarkIntentional,
}: FlagCardProps) {
  const config = SEVERITY_CONFIG[severity];
  const Icon = config.icon;

  return (
    <div
      className={cn(
        "rounded-md border border-rule overflow-hidden",
        config.bgClass
      )}
      style={{ borderLeft: `3px solid ${config.borderColor}` }}
    >
      <div className="p-4">
        {/* Header row */}
        <div className="flex items-start gap-3">
          <Icon
            size={16}
            strokeWidth={1.5}
            className={cn("mt-0.5 shrink-0", config.textClass)}
          />
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2 mb-0.5">
              <span
                className={cn(
                  "font-mono text-[10px] font-semibold uppercase tracking-[0.06em]",
                  config.textClass
                )}
              >
                {config.label}
              </span>
            </div>
            <h3 className="font-sans text-[14px] font-semibold text-ink leading-snug">
              {title}
            </h3>
          </div>
        </div>

        {/* Detail text */}
        <p className="font-sans text-[13px] text-ink-secondary leading-relaxed mt-2 ml-7">
          {detail}
        </p>

        {/* Entry cross-references */}
        {entries.length > 0 && (
          <div className="ml-7 mt-2 flex flex-wrap gap-x-4 gap-y-1">
            {entries.map((entry) => (
              <span key={entry.id} className="font-sans text-[12px] text-link">
                → {entry.label}
              </span>
            ))}
          </div>
        )}

        {/* Resolution actions */}
        <div className="ml-7 mt-3 flex flex-wrap items-center gap-2">
          {entries.map((entry) => (
            <Button
              key={entry.id}
              variant="secondary"
              size="sm"
              onClick={() => onFixEntry?.(entry.id)}
            >
              Fix in {entry.label}
            </Button>
          ))}
          <Button
            variant="ghost"
            size="sm"
            onClick={() => onMarkIntentional?.(id)}
            className="text-ink-tertiary hover:text-ink-secondary"
          >
            Mark as intentional
          </Button>
        </div>
      </div>
    </div>
  );
}
